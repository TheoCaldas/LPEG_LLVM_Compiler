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


local S = lpeg.V"S"

local OP = "(" * S
local CP = ")" * S
local OB = "{" * S
local CB = "}" * S
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
local stats = lpeg.V"stats"
local block = lpeg.V"block"
local call = lpeg.V"call"
local def = lpeg.V"def"

local lastpos = 0

local prog = lpeg.P{"defs";
  defs = lpeg.Ct(def^1);
  def = Rw"fun" * Id * OP * CP * block / node("func", "name", "body");
  stats = stat * (SC * stats)^-1 * SC^-1 / function (st, pg)
	  return pg and {tag="seq", s1 = st, s2 = pg} or st
	end;
  block = OB * stats * CB / node("block", "body");
  stat = block
       + Prt * exp / node("print", "e")
       + Rw"var" * Id * Eq * exp / node("var", "id", "e")
       + Rw"if" * exp * block * (Rw"else" * block)^-1
                       / node("if", "cond", "th", "el")
       + Rw"while" * exp * block / node("while", "cond", "body")
       + Id * Eq * exp / node("ass", "id", "e")
       + call;
  call = Id * OP * CP / node("call", "name");
  primary = integer / node("number", "num")
          + OP * lpeg.V"exp" * CP
	  + Id / node("varId", "id");
  factor = opUn * factor / node("unarith", "op", "e")
         + primary;
  expM = lpeg.Ct(factor * (opM * factor)^0) / fold;
  expA = lpeg.Ct(expM * (opA * expM)^0) / fold;
  exp = lpeg.V"expA";
  S = lpeg.S(" \n\t")^0 *
        lpeg.P(function (_,p)
                 lastpos = math.max(lastpos, p); return true end);
}


prog = prog * -1



-- print(pt.pt(exp:match(input)))



local Compiler = { tempCount = 0; vars = {}; funcs = {} }

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
  io.write(string.format("%s:\n", label))
end


function Compiler:codeJmp (label)
  io.write(string.format("br label %%%s\n", label))
end


function Compiler:codeCond (exp, Ltrue, Lfalse)
  local reg = self:codeExp(exp)
  local aux = self:newTemp()
  io.write(string.format([[
   %s = icmp ne i32 %s, 0
   br i1 %s, label %%%s, label %%%s
 ]], aux, reg, aux, Ltrue, Lfalse))
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
  elseif tag == "block" then
    local vars = self.vars
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
    io.write(string.format("%s = call i32 @%s()\n", reg, st.name))
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

]]

local poscode = [[
  ret i32 0
}
]]


function Compiler:codeFunc (func)
  self.funcs[func.name] = true
  io.write(string.format("define i32 @%s() {\n", func.name))
  self:codeStat(func.body)
  io.write(poscode)  
end


function Compiler:codeProg (prog)
  for i = 1, #prog do
    self:codeFunc(prog[i])
  end
  if not self.funcs["main"] then
    error("missing main function")
  end
end


local input = io.read("a")
local tree = prog:match(input)
if not tree then
  io.write("syntax error near <<" ..
    string.sub(input, lastpos - 10, lastpos - 1) .. "|" ..
    string.sub(input, lastpos, lastpos + 10), ">>\n")
  os.exit(1)
end
io.write(premable)
--  do print(pt.pt(tree)); return end
local e = Compiler:codeProg(tree)


