local lpeg = require "lpeg"
local shared = require "shared"

-- MARK: Local Vars
local reservedWords = {"var", "ret", "fun", "if", "else", "while"}
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
local SC = ";" * S
local CL = ":" * S
local CM = "," * S
local AT = "@" * S
local EQ = "=" * S
local HT = lpeg.P"#"

local dot = lpeg.P"."
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
    (rw"var" * lpeg.Cmt(id, notRW) * opt(CL * id) * EQ * exp / node("daVAR", "id", "optType", "e")) +
    (rw"var" * lpeg.Cmt(id, notRW) * CL * id / node("dVAR", "id", "type")) + 
    (id * EQ * exp / node("aVAR", "id", "e")) +
    (rw"if" * exp * block * (rw"else" * block)^-1 / node("if", "cond", "th", "el")) + 
    (rw"while" * exp * block / node("while", "cond", "body")) +
    (rw"ret" * opt(exp) / node("return", "e")) +
    call +
    comment;
  comment = HT * lpeg.C((1 - HT)^0) * HT * S / node("comment", "body");
  call = id * OP * opt(lpeg.Ct(exp * (CM * exp)^0)) * CP / node("call", "name", "optParams");
  primary = 
    (float / node("FLOAT", "num")) +
    (integer / node("INT", "num")) + 
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

return {
  syntaxError=syntaxError,
  syntax = syntax,
}