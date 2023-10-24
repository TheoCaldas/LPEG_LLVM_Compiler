local lpeg = require "lpeg"
local pt = require "pt"

local reservedWords = {"var", "return"}

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
    --   return false
      error("this is a reserved word: " .. id)
    end
  end
  return true, id
end

-- MARK: Lexical Patterns
local digit = lpeg.R"09"
local alpha = lpeg.R("az", "AZ")
local alphanum = alpha + digit
local S = lpeg.S(" \n\t")^0

local OP = "(" * S
local CP = ")" * S
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

local syntax = lpeg.P{"prog";
  prog = stat * (SC * prog)^-1 / node("seq", "s1", "s2");
  stat = 
    (AT * exp / node("print", "e")) +
    (rw"var" * lpeg.Cmt(id, notRW) * EQ * exp / node("daVAR", "id", "e")) +
    (rw"var" * lpeg.Cmt(id, notRW) / node("dVAR", "id")) + 
    (id * EQ * exp / node("aVAR", "id", "e"));
  primary = 
    (integer / node("NUMBER", "num")) + 
    id / node("uVAR", "id") +
    (OP * lpeg.V"exp" * CP);
  factor = primary + ((opN * primary) / node("UAO", "op", "e"));
  expM = lpeg.Ct(factor * (opM * factor)^0) / tagFold("BAO");
  expA = lpeg.Ct(expM * (opA * expM)^0) / tagFold("BAO");
  expC = lpeg.Ct(expA * (opC * expA)^-1) / tagFold("BCO");
  exp = expC
}

-- MARK: Compiler
local Compiler = {
  tempCount = 0, variables = {},
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

-- MARK: LLVM
local premable = [[
@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00"

declare dso_local i32 @printf(i8*, ...)

define internal void @printI(i32 %x) {
  %y = call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), i32 %x)
  ret void
}

define i32 @main() {
]]

local poscode = [[
  ret i32 0
}
]]

-- MARK: Test Calls
local input = io.read("a")
local tree = syntax:match(input)
if not tree then
  error("syntax error")
end
-- print(pt.pt(tree))
io.write(premable)
local e = Compiler:codeStat(tree)
io.write(poscode)