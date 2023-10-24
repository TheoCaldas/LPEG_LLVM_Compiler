local lpeg = require "lpeg"
local pt = require "pt"

--  function (n) return {tag = "number", num = n} end)
--  node("number", "num") --> function (...) 

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
local SC = ";" * S
local Prt = "@" * S
local Eq = "=" * S

local digit = lpeg.R"09"
local alpha = lpeg.R("az", "AZ", "__")
local alphanum = alpha + digit

local reservedwords = {}
local function Rw (id)
  reservedwords[id] = true
  return lpeg.P(id) * -alphanum * S
end


local integer = (digit^1) / tonumber * S
local opA = lpeg.C(lpeg.S("+-")) * S
local opM = lpeg.C(lpeg.S("*/")) * S
local opUn = lpeg.C("-") * S

local Id = lpeg.C(alpha * alphanum^0) * S

local primary = lpeg.V"primary"
local factor = lpeg.V"factor"
local expM = lpeg.V"expM"
local exp = lpeg.V"exp"
local stat = lpeg.V"stat"
local prog = lpeg.V"prog"

local exp = lpeg.P{"prog";
  prog = stat * (SC * prog)^-1 / function (st, pg)
	  return pg and {tag="seq", s1 = st, s2 = pg} or st
	end;
  stat = Prt * exp / node("print", "e")
       + Rw"var" * Id * Eq * exp / node("var", "id", "e")
       + Id * Eq * exp / node("ass", "id", "e");
  primary = integer / node("number", "num")
          + OP * lpeg.V"exp" * CP
	  + Id / node("varId", "id");
  factor = opUn * factor / node("unarith", "op", "e")
         + primary;
  expM = lpeg.Ct(factor * (opM * factor)^0) / fold;
  expA = lpeg.Ct(expM * (opA * expM)^0) / fold;
  exp = lpeg.V"expA"
}



-- print(pt.pt(exp:match(input)))



local Compiler = { tempCount = 0; vars = {} }

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


function Compiler:findVar (id)
  local vars = self.vars
  for i = #vars, 1, -1 do
   if vars[i].id == id then
     return vars[i].reg
   end
  end
  error("variable not found " .. id)
end


function Compiler:codeExp (exp)
  local tag = exp.tag
  if tag == "number" then
    return string.format("%d", exp.num) 
  elseif tag == "varId" then
    local regV = self:findVar(exp.id)	  
    local res = self:newTemp()
    io.write(string.format("%s = load i32, i32* %s\n", res, regV))
    return res
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


function Compiler:codeStat (st)
  local tag = st.tag
  if tag == "seq" then
    self:codeStat(st.s1)
    self:codeStat(st.s2)
  elseif tag == "print" then
    local reg = self:codeExp(st.e)
    io.write(string.format("call void @printI(i32 %s)\n", reg))
  elseif tag == "var" then
    local regE = self:codeExp(st.e)
    local regV = self:newTemp()
    io.write(string.format("%s = alloca i32\nstore i32 %s, i32* %s\n", 
                            regV, regE, regV))
    self.vars[#self.vars + 1] = {id = st.id, reg = regV}
  elseif tag == "ass" then
    local regE = self:codeExp(st.e)
    local regV = self:findVar(st.id)
    io.write(string.format("store i32 %s, i32* %s\n", regE, regV))
  else
    error(tag .. ": statement not yet implemented")
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
  ret i32 0
}
]]


local input = io.read("a")
local tree = exp:match(input)
if not tree then
  error("syntax error")
end
io.write(premable)
--  do print(pt.pt(tree)); return end
local e = Compiler:codeStat(tree)
io.write(poscode)


