local lpeg = require "lpeg"
local pt = require "pt"

-- MARK: Global Vars
local reservedWords = {"var", "return", "fun", "if", "else", "while"}
local lastpos = 0

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
      -- error("this is a reserved word: " .. id)
    end
  end
  return true, id
end

-- MARK: Lexical Patterns
local digit = lpeg.R"09"
local alpha = lpeg.R("az", "AZ", "__")
local alphanum = alpha + digit
local S = lpeg.V"S"
-- local S = lpeg.S(" \n\t")^0

local OP = "(" * S
local CP = ")" * S
local OB = "{" * S
local CB = "}" * S
local SC = ";" * S
local AT = "@" * S
local EQ = "=" * S

local integer = digit^1 / tonumber * S
local opA = lpeg.C(lpeg.S("+-")) * S
local opM = lpeg.C(lpeg.S("*/")) * S
local opN = lpeg.C(lpeg.P("-")) * S
local opC = lpeg.C(lpeg.P(">=") + "<=" + ">" + "<" + "==" + "!=") * S
local id = lpeg.C(alpha * alphanum^0) * S

local function rw (string)
  return lpeg.P(string) * -alphanum * S
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
local stats = lpeg.V"stats"
local block = lpeg.V"block"
local call = lpeg.V"call"
local def = lpeg.V"def"

local syntax = lpeg.P{"defs";
  defs = lpeg.Ct(def^1);
  def = rw"fun" * id * OP * CP * block / node("func", "name", "body");
  stats = stat * (SC * stats)^-1 * SC^-1 / function (st, pg)
    return pg and {tag="seq", s1 = st, s2 = pg} or st
  end;
  block = OB * stats * CB / node("block", "body");
  prog = stat * (SC * prog)^-1 / node("seq", "s1", "s2");
  stat = 
    block +
    (AT * exp / node("print", "e")) +
    (rw"var" * lpeg.Cmt(id, notRW) * EQ * exp / node("daVAR", "id", "e")) +
    (rw"var" * lpeg.Cmt(id, notRW) / node("dVAR", "id")) + 
    (id * EQ * exp / node("aVAR", "id", "e")) +
    (rw"if" * exp * block * (rw"else" * block)^-1 / node("if", "cond", "th", "el")) + 
    (rw"while" * exp * block / node("while", "cond", "body")) +
    call;
  call = id * OP * CP / node("call", "name");
  primary = 
    (integer / node("NUMBER", "num")) + 
    id / node("uVAR", "id") +
    (OP * lpeg.V"exp" * CP);
  factor = primary + ((opN * primary) / node("UAO", "op", "e"));
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
prog = prog * -1

-- MARK: Compiler
local Compiler = {
  tempCount = 0, variables = {}, funcs = {},
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
  formatWrite("%s:\n", label)
end

function Compiler:codeJmp (label)
  formatWrite("br label %%%s\n", label)
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
  error("variable not found: " .. id)
end

function Compiler:createVar (id, temp)
  local vars = self.variables
  vars[#vars + 1] = {id = id, temp = temp}
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
  else
    error(tag .. ": expression not yet implemented")
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
    if not self.funcs[st.name] then
      error("unknown function " .. st.name)
    end
    local reg = self:newTemp()
    formatWrite("%s = call i32 @%s()\n", reg, st.name)
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
  else
    error(tag .. ": statement not yet implemented")
  end
end

function Compiler:codeFunc (func)
  self.funcs[func.name] = true
  formatWrite("define i32 @%s() {\n", func.name)
  self:codeStat(func.body)
  io.write([[
  ret i32 0
}
  ]])  
end

function Compiler:codeProg (prog)
  for i = 1, #prog do
    self:codeFunc(prog[i])
  end
  if not self.funcs["main"] then
    error("missing main function")
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
if not tree then
  io.write("syntax error near <<" ..
    string.sub(input, lastpos - 10, lastpos - 1) .. "|" ..
    string.sub(input, lastpos, lastpos + 10), ">>\n")
  os.exit(1)
end
io.write(premable)
local e = Compiler:codeProg(tree)