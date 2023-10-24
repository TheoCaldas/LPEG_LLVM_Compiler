local lpeg = require "lpeg"
local pt = require "pt"


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


local function fold (t)
  local res = t[1]
  for i = 2, #t, 2 do
    res = {tag = "binarith", e1 = res, op = t[i], e2 = t[i + 1]}
  end
  return res
end


local S = lpeg.S(" \n\t")^0

local OP = "(" * S
local CP = ")" * S

local integer = (lpeg.R"09"^1) / tonumber * S
local opA = lpeg.C(lpeg.S("+-")) * S
local opM = lpeg.C(lpeg.S("*/")) * S
local opUn = lpeg.C("-") * S

local primary = lpeg.V"primary"
local factor = lpeg.V"factor"
local expM = lpeg.V"expM"
local exp = lpeg.P{"exp";
  primary = (integer / node("number", "num"))
          + OP * lpeg.V"exp" * CP;
  factor = opUn * factor / node("unarith", "op", "e")
         + primary;
  expM = lpeg.Ct(factor * (opM * factor)^0) / fold;
  expA = lpeg.Ct(expM * (opA * expM)^0) / fold;
  exp = lpeg.V"expA"
}





local Compiler = { tempCount = 0 }

function Compiler:newTemp ()
  local temp = string.format("%%T%d", self.tempCount)
  self.tempCount = self.tempCount + 1
  return temp
end


local binAOps = {
  ["+"] = "add",
  ["-"] = "sub",
  ["*"] = "mul",
  ["/"] = "sdiv",
}


function Compiler:codeExp (exp)
  local tag = exp.tag
  if tag == "number" then
    return string.format("%d", exp.num) 
  elseif tag == "unarith" then
    local e = self:codeExp(exp.e)
    local res = self:newTemp()
    io.write(string.format("%s = sub i32 0, %s\n", res, e))
    return res
  elseif tag == "binarith" then
    local r1 = self:codeExp(exp.e1)
    local r2 = self:codeExp(exp.e2)
    local res = self:newTemp()
    io.write(string.format("%s = %s i32 %s, %s\n",
               res, binAOps[exp.op], r1, r2))
    return res
  else
    error(tag .. ": expression not yet implemented")
  end
end


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


local input = io.read("a")
local tree = exp:match(input)
if not tree then
  error("syntax error")
end
io.write(premable)
local e = Compiler:codeExp(tree)
io.write(string.format(poscode, e))


