local lpeg = require "lpeg"
local shared = require "shared"

-- MARK: Local Vars
local reservedWords = {"var", "ret", "fun", "if", "else", "while", "as", "for", "from", "to", "by", "new"}
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

local function fold (tag, ...)
  local labels = {...}
  return function (t)
    local res = t[1]
    for i = 2, #t, #labels - 1 do
      res = {tag = tag, [labels[1]] = res}
      for j = 2, #labels do
        res[labels[j]] = t[i + j - 2]
      end
    end
    return res
  end
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
  return lpeg.P(function () shared.log:write(msg .. "\n"); return true end)
end

local function updateLastPos(_,p)
  lastpos = math.max(lastpos, p); 
  return true 
end

local function varToExp(var)
  return {tag = "varExp", var = var}
end

local function foldIndexed(t)
  local res = t[1]
  for i = 2, #t, 1 do
      res = {tag = "indexed", e = varToExp(res), index = t[i]}
  end

  return res
end


local function syntaxError(input)
  shared.log:write("SYNTAX ERROR NEAR\n<<" ..
    string.sub(input, lastpos - 10, lastpos - 1) .. "|" ..
    string.sub(input, lastpos, lastpos + 10), ">>\n")
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
local OSB = "[" * S
local CSB = "]" * S
local SC = ";" * S
local CL = ":" * S
local CM = "," * S
local AT = "@" * S
local EQ = "=" * S
local HT = lpeg.P"#"

local dot = lpeg.P"."
-- TO DO: Read other types of float rep
local float = (digit^1 * dot * digit^1) / tonumber * S
local integer = digit^1 / tonumber * S

local opA = lpeg.C(lpeg.S("+-")) * S
local opM = lpeg.C(lpeg.S("*/")) * S
local opN = lpeg.C(lpeg.P("-")) * S
local opC = lpeg.C(lpeg.P(">=") + "<=" + ">" + "<" + "==" + "!=") * S
local id = lpeg.C(alpha * alphanum^0) * S

-- reserved word
local function rw (string)
  return lpeg.P(string) * -alphanum * S
end

-- optional pattern
local function opt(p)
  return p + lpeg.C""
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
local rawType = lpeg.V"rawType"
local typed = lpeg.V"typed"
local arrayType = lpeg.V"arrayType"
local typedVar = lpeg.V"typedVar"
local newArray = lpeg.V"newArray"
local indexedVar = lpeg.V"indexedVar"
local postfix = lpeg.V"postfix"
local casted = lpeg.V"casted"
local comment = lpeg.V"comment"

local syntax = lpeg.P{"defs";
  -- function, blocks, call, statement
  defs = lpeg.Ct(def^1);
  def = rw"fun" * id * OP * opt(lpeg.Ct(typedVar * (CM * typedVar)^0)) * CP * opt(typed) * block / node("func", "name", "optParams", "optType", "body");
  call = id * OP * opt(lpeg.Ct(exp * (CM * exp)^0)) * CP / node("call", "name", "optArgs");
  block = OB * prog * CB / node("block", "body");
  prog = stat * SC^-1 * prog^-1 * SC^-1 / node("seq", "s1", "s2");
  stat = 
    block +
    (AT * exp / node("print", "e")) +
    (rw"var" * lpeg.Cmt(id, notRW) * opt(typed) * EQ * exp / node("daVAR", "id", "optType", "e")) +
    (rw"var" * typedVar / node("dVAR", "var")) + 
    (id * EQ * exp / node("aVAR", "id", "e")) +
    (rw"if" * exp * block * (rw"else" * block)^-1 / node("if", "cond", "th", "el")) + 
    (rw"while" * exp * block / node("while", "cond", "body")) +
    (rw"ret" * opt(exp) / node("return", "e")) +
    ( (rw"for" * id * opt(rw"from" * exp) * rw"to" * exp * opt(rw"by" * exp) * block) / node("for", "counter", "optStart", "stop", "optStep", "block")) + 
    call +
    comment;

  -- variable, type
  rawType = id;
  arrayType = 
    (OSB * arrayType * CSB) / node("arrayType", "nestedType") + 
    rawType / node("primitiveType", "type");
  typed = CL * arrayType;
  newArray = rw"new" * arrayType * OP * exp * CP / node("new", "type", "size");
  typedVar = lpeg.Cmt(id, notRW) * typed / node("typedVAR", "id", "type");
  indexedVar = lpeg.Ct((id / node("uVAR", "id")) * (OSB * exp * CSB)^0) / foldIndexed ;
  
  -- comment
  comment = HT * lpeg.C((1 - HT)^0) * HT * S / node("comment", "body");
  
  -- exp
  primary = 
    newArray + 
    (float / node("FLOAT", "num")) +
    (integer / node("INT", "num")) + 
    indexedVar / varToExp + 
    (OP * exp * CP);
  postfix = call + primary;
  casted = lpeg.Ct(postfix * (rw"as" * rawType)^0) / fold("cast", "e", "type");
  factor = casted + ((opN * casted) / node("UAO", "op", "e"));
  expM = lpeg.Ct(factor * (opM * factor)^0) / fold("BAO", "e1", "op", "e2");
  expA = lpeg.Ct(expM * (opA * expM)^0) / fold("BAO", "e1", "op", "e2");
  expC = lpeg.Ct(expA * (opC * expA)^-1) / fold("BCO", "e1", "op", "e2");
  exp = expC;

  -- space
  S = lpeg.S(" \n\t")^0 * lpeg.P(updateLastPos);
}

-- Do not succeed if there are token remains
syntax = syntax * -1

return {
  syntaxError=syntaxError,
  syntax = syntax,
}