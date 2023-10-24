local lpeg = require "lpeg"
local pt = require "pt"

-- MARK: Global Vars
local reservedWords = {"var", "ret", "fun", "if", "else", "while"}
local lastpos = 0
local log = io.open("log.txt", "w")

-- MARK: Auxiliar Functions
local function node (tag, ...)
  local labels = {...}
  return function (...)
    local values = {...}
    local t = {tag = tag}
    for i = 1, #labels do
      t[labels[i]] = values[i]
    end
    return t
  end
end

local function tagFold (tag)
  return function (t)
    local res = t[1]
    for i = 2, #t, 2 do
      res = {tag = tag, e1 = res, op = t[i], e2 = t[i + 1]}
    end
    return res
  end
end

local function formatWrite (string, ...)
  io.write(string.format(string, ...))
end

local function packProg(st, pg)
  return pg and {tag="seq", s1 = st, s2 = pg} or st
end

local function notRW (s, i, id)
  for i = 1, #reservedWords do
    if id == reservedWords[i] then
      return false
    end
  end
  return true, id
end

local function I (msg)
  return lpeg.P(function () log:write(msg); return true end)
end

local function syntaxError(input)
  log:write("SYNTAX ERROR NEAR <<" ..
    string.sub(input, lastpos - 10, lastpos - 1) .. "|" ..
    string.sub(input, lastpos, lastpos + 10), ">>\n")
  os.exit(1)
end

local function errorMsg(msg)
  log:write("SEMANTIC ERROR: " .. msg)
  os.exit(1)
end

-- MARK: Lexical Patterns
local digit = lpeg.R"09"
local alpha = lpeg.R("az", "AZ", "__")
local alphanum = alpha + digit
local S = lpeg.V"S"

local OP = "(" * S
local CP = ")" * S
local OB = "{" * S
local CB = "}" * S
local SC = ";" * S
local CL = ":" * S
local CM = "," * S
local AT = "@" * S
local EQ = "=" * S
local HT = lpeg.P"#"

local integer = digit^1 / tonumber * S
local opA = lpeg.C(lpeg.S("+-")) * S
local opM = lpeg.C(lpeg.S("*/")) * S
local opN = lpeg.C(lpeg.P("-")) * S
local opC = lpeg.C(lpeg.P(">=") + "<=" + ">" + "<" + "==" + "!=") * S
local id = lpeg.C(alpha * alphanum^0) * S

local function rw (string)
  return lpeg.P(string) * -alphanum * S
end

-- optional pattern
local function opt(p)
  return p + lpeg.C""
end

local function isEmpty(string)
  return string == ""
end

-- MARK: Syntax Patterns
local primary = lpeg.V"primary"
local factor = lpeg.V"factor"
local expM = lpeg.V"expM"
local expA = lpeg.V"expA"
local expC = lpeg.V"expC"
local exp = lpeg.V"exp"
local stat = lpeg.V"stat"
local prog = lpeg.V"prog"
local block = lpeg.V"block"
local call = lpeg.V"call"
local def = lpeg.V"def"
local postfix = lpeg.V"postfix"
local comment = lpeg.V"comment"

local syntax = lpeg.P{"defs";
  defs = lpeg.Ct(def^1);
  def = rw"fun" * id * OP * opt(lpeg.Ct(id * (CM * id)^0)) * CP * opt(CL * id) * block / node("func", "name", "optArgs", "optType", "body");
  block = OB * prog * CB / node("block", "body");
  prog = stat * SC^-1 * prog^-1 * SC^-1 / node("seq", "s1", "s2");
  stat = 
    block +
    (AT * exp / node("print", "e")) +
    (rw"var" * lpeg.Cmt(id, notRW) * EQ * exp / node("daVAR", "id", "e")) +
    (rw"var" * lpeg.Cmt(id, notRW) / node("dVAR", "id")) + 
    (id * EQ * exp / node("aVAR", "id", "e")) +
    (rw"if" * exp * block * (rw"else" * block)^-1 / node("if", "cond", "th", "el")) + 
    (rw"while" * exp * block / node("while", "cond", "body")) +
    (rw"ret" * opt(exp) / node("return", "e")) +
    call +
    comment;
  comment = HT * lpeg.C((1 - HT)^0) * HT * S / node("comment", "body");
  call = id * OP * opt(lpeg.Ct(exp * (CM * exp)^0)) * CP / node("call", "name", "optParams");
  primary = 
    (integer / node("NUMBER", "num")) + 
    id / node("uVAR", "id") +
    (OP * exp * CP);
  postfix = call + primary;
  factor = postfix + ((opN * postfix) / node("UAO", "op", "e"));
  expM = lpeg.Ct(factor * (opM * factor)^0) / tagFold("BAO");
  expA = lpeg.Ct(expM * (opA * expM)^0) / tagFold("BAO");
  expC = lpeg.Ct(expA * (opC * expA)^-1) / tagFold("BCO");
  exp = expC;
  S = lpeg.S(" \n\t")^0 * lpeg.P(
    function (_,p)
      lastpos = math.max(lastpos, p); 
      return true end
  )
}

-- Do not succeed if there are token remains
syntax = syntax * -1

-- MARK: Compiler
local Compiler = {
  tempCount = 0, variables = {}, functions = {},
  currentFunc = "",
  BAOmap = {
    ["+"] = "add",
    ["-"] = "sub",
    ["*"] = "mul",
    ["/"] = "sdiv",
  },
  BCOmap = {
    [">="] = "sge",
    ["<="] = "sle",
    [">"] = "sgt",
    ["<"] = "slt",
    ["=="] = "eq",
    ["!="] = "ne",
  }
}

function Compiler:newTemp ()
  local temp = string.format("%%T%d", self.tempCount)
  self.tempCount = self.tempCount + 1
  return temp
end

function Compiler:newLabel ()
  local temp = string.format("L%d", self.tempCount)
  self.tempCount = self.tempCount + 1
  return temp
end

function Compiler:codeLabel (label)
  formatWrite("  %s:\n", label)
end

function Compiler:codeJmp (label)
  formatWrite("  br label %%%s\n", label)
end

function Compiler:codeCond (exp, Ltrue, Lfalse)
  local reg = self:codeExp(exp)
  local aux = self:newTemp()
  formatWrite([[
  %s = icmp ne i32 %s, 0
  br i1 %s, label %%%s, label %%%s
]], aux, reg, aux, Ltrue, Lfalse)
end

function Compiler:findVar (id)
  local vars = self.variables
  for i = #vars, 1, -1 do
    if vars[i].id == id then
      return vars[i].temp
    end
  end
  errorMsg("variable not found: " .. id)
end

function Compiler:createVar (id, temp)
  local vars = self.variables
  vars[#vars + 1] = {id = id, temp = temp}
end

function Compiler:codeParams (params, n)
  if n <= 0 then return ")\n" end
  local s = ""
  for i = 1, #params do
    local r = self:codeExp(params[i])
    s = s .. string.format((i > 1 and ", " or "") .. "i32 %s", r)
  end
  s = s .. ")\n"
  return s
end

function Compiler:codeCall(call)
  if not self.functions[call.name] then
    errorMsg("unknown function " .. call.name)
  end
  local params = call.optParams
  local count = isEmpty(params) and 0 or #params
  local exptdCount = self.functions[call.name].argCount
  if count ~= exptdCount then
    errorMsg(call.name .. " expected " .. exptdCount .. " parameters, " .. count .. " were given")
  end
  local rParams = self:codeParams(params, count)
  local reg = self:newTemp()
  formatWrite("  %s = call i32 @%s(%s", reg, call.name, rParams)
  return reg
end

function Compiler:codeExp (exp)
  local tag = exp.tag
  if tag == "NUMBER" then
    return string.format("%d", exp.num) 
  elseif tag == "uVAR" then
    local varRef = self:findVar(exp.id)	  
    local temp = self:newTemp()
    formatWrite("  %s = load i32, i32* %s\n", temp, varRef)
    return temp
  elseif tag == "UAO" then
    local rExp = self:codeExp(exp.e)
    local temp = self:newTemp()
    formatWrite("  %s = sub i32 0, %s\n", temp, rExp)
    return temp
  elseif tag == "BAO" then
    local rExp1 = self:codeExp(exp.e1)
    local rExp2 = self:codeExp(exp.e2)
    local temp = self:newTemp()
    formatWrite("  %s = %s i32 %s, %s\n", temp, self.BAOmap[exp.op], rExp1, rExp2)
    return temp
  elseif tag == "BCO" then
    local rExp1 = self:codeExp(exp.e1)
    local rExp2 = self:codeExp(exp.e2)
    local temp1 = self:newTemp()
    local temp2 = self:newTemp()
    formatWrite("  %s = icmp %s i32 %s, %s\n  %s = zext i1 %s to i32\n",
    temp1, self.BCOmap[exp.op], rExp1, rExp2, temp2, temp1)
    return temp2
  elseif tag == "call" then
    if self.functions[exp.name].type == "void" then
      errorMsg(exp.name .. " is a void function")
    end
    return self:codeCall(exp)
  else
    errorMsg(tag .. ": expression not yet implemented")
  end
end

function Compiler:codeStat (st)
  if st == nil then return end
  local tag = st.tag
  if tag == "seq" then
    self:codeStat(st.s1)
    self:codeStat(st.s2)
  elseif tag == "block" then
    local vars = self.variables
    local level = #vars
    self:codeStat(st.body)
    for i = #vars, level + 1, -1 do
      table.remove(vars)
    end
  elseif tag == "call" then
    return self:codeCall(st)
  elseif tag == "if" then
    local Lthen = self:newLabel()
    local Lend = self:newLabel()
    local Lelse = self:newLabel()
    self:codeCond(st.cond, Lthen, st.el and Lelse or Lend)
    self:codeLabel(Lthen)
    self:codeStat(st.th)
    self:codeJmp(Lend)
    if st.el then
      self:codeLabel(Lelse)
      self:codeStat(st.el)
      self:codeJmp(Lend)
    end
    self:codeLabel(Lend)
  elseif tag == "while" then
    local Lcond = self:newLabel()
    local Lbody = self:newLabel()
    local Lend = self:newLabel()
    self:codeJmp(Lcond)
    self:codeLabel(Lcond)
    self:codeCond(st.cond, Lbody, Lend)
    self:codeLabel(Lbody)
    self:codeStat(st.body)
    self:codeJmp(Lcond)
    self:codeLabel(Lend)
  elseif tag == "return" then
    currentType = self.functions[self.currentFunc].type
    if isEmpty(st.e) then
      if currentType ~= "void" then
        errorMsg(currentType .. " return expected")
      end
      io.write("  ret void\n")
    else
      if currentType ~= "int" then
        errorMsg(currentType .. " return expected")
      end
      local rExp = self:codeExp(st.e)
      formatWrite("  ret i32 %s\n", rExp)
    end
  elseif tag == "print" then
    local rExp = self:codeExp(st.e)
    formatWrite("  call void @printI(i32 %s)\n", rExp)
  elseif tag == "daVAR" then
    local rExp = self:codeExp(st.e)
    local temp = self:newTemp()
    self:createVar(st.id, temp)
    formatWrite("  %s = alloca i32\n  store i32 %s, i32* %s\n", temp, rExp, temp)
  elseif tag == "aVAR" then
    local rExp = self:codeExp(st.e)
    local varRef = self:findVar(st.id)
    formatWrite("  store i32 %s, i32* %s\n", rExp, varRef)
  elseif tag == "dVAR" then
    local temp = self:newTemp()
    self:createVar(st.id, temp)
    formatWrite("  %s = alloca i32\n", temp)
  elseif tag == "comment" then
    return
  else
    errorMsg(tag .. ": statement not yet implemented")
  end
end

function Compiler:codeArg (func)
  if isEmpty(func.optArgs) then
    io.write(") {\n")
    return
  end
  local args = func.optArgs
  local temps = {}
  for i = 1, #args do
    local temp = Compiler:newTemp()
    formatWrite((i > 1 and ", " or "") .. "i32 %s", temp)
    temps[i] = temp
  end
  io.write(") {\n")
  for i = 1, #args do
    local argID = args[i]
    local varTemp = self:newTemp()
    self:createVar(argID, varTemp)
    formatWrite("  %s = alloca i32\n  store i32 %s, i32* %s\n", varTemp, temps[i], varTemp)
  end
end

function Compiler:codeFunc (func)
  local fType = isEmpty(func.optType) and "void" or func.optType
  local args = isEmpty(func.optArgs) and 0 or #func.optArgs
  self.functions[func.name] = {type = fType, argCount = args}
  self.currentFunc = func.name
  if fType == "void" then
    formatWrite("define void @%s(", func.name)
    self:codeArg(func)
    self:codeStat(func.body)
    io.write("  ret void\n}\n")
  elseif fType == "int" then
    formatWrite("define i32 @%s(", func.name)
    self:codeArg(func)
    self:codeStat(func.body)
    io.write("}\n")
  else
    errorMsg(fType .. " type does not exist")
  end
end

function Compiler:codeProg (prog)
  for i = 1, #prog do
    self:codeFunc(prog[i])
  end
  if not self.functions["main"] then
    errorMsg("missing main function")
  end
end

-- MARK: LLVM
local premable = [[
@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00"

declare dso_local i32 @printf(i8*, ...)

define internal void @printI(i32 %x) {
  %y = call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %x)
  ret void
}

]]

-- MARK: Test Calls
local input = io.read("a")
local tree = syntax:match(input)
if not tree then syntaxError(input) end
io.write(premable)
local e = Compiler:codeProg(tree)
log:write("COMPILATION SUCCEED")
log:close()