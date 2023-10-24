local lpeg = require "lpeg"
local pt = require "pt"

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

-- MARK: Lexical Patterns
local S = lpeg.S(" \n\t")^0
local OP = "(" * S
local CP = ")" * S
local integer = (lpeg.R"09"^1) / tonumber * S
local opA = lpeg.C(lpeg.S("+-")) * S
local opM = lpeg.C(lpeg.S("*/")) * S
local opN = lpeg.C(lpeg.P("-")) * S
local opC = lpeg.C(lpeg.P(">=") + "<=" + ">" + "<" + "==" + "!=") * S

-- MARK: Syntax Patterns
local primary = lpeg.V"primary"
local factor = lpeg.V"factor"
local expM = lpeg.V"expM"
local expA = lpeg.V"expA"
local expC = lpeg.V"expC"
local exp = lpeg.P{"exp";
  primary = (integer / node("NUMBER", "num")) + (OP * lpeg.V"exp" * CP);
  factor = primary + ((opN * primary) / node("UAO", "op", "e"));
  expM = lpeg.Ct(factor * (opM * factor)^0) / tagFold("BAO");
  expA = lpeg.Ct(expM * (opA * expM)^0) / tagFold("BAO");
  expC = lpeg.Ct(expA * (opC * expA)^-1) / tagFold("BCO");
  exp = expC
}

-- MARK: Compiler
local Compiler = {
  tempCount = 0,
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

function Compiler:codeExp (exp)
  local tag = exp.tag
  if tag == "NUMBER" then
    return string.format("%d", exp.num) 
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
  call void @printI(i32 %s)
  ret i32 0
}
]]

-- MARK: Test Calls
local input = io.read("a")
local tree = exp:match(input)
if not tree then
  error("syntax error")
end
io.write(premable)
local e = Compiler:codeExp(tree)
formatWrite(poscode, e)