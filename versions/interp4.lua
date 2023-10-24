local lpeg = require "lpeg"
local pt = require "pt"

-- MARK: Functions
local function foldBinop (t)
  local res = t[1]
  for i = 2, #t, 2 do
    res = {tag = "binop", e1 = res, op = t[i], e2 = t[i + 1]}
  end
  return res
end

local function packNumber (n)
    return {tag = "number", num = n}
end

local function packUnop (op, e)
  return {tag = "unop", op = op, e1 = e}
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
  primary = (integer / packNumber) + (OP * lpeg.V"exp" * CP);
  factor = primary + ((opN * primary) / packUnop);
  expM = lpeg.Ct(factor * (opM * factor)^0) / foldBinop;
  expA = lpeg.Ct(expM * (opA * expM)^0) / foldBinop;
  expC = lpeg.Ct(expA * (opC * expA)^-1) / foldBinop;
  exp = expC
}

-- MARK: Test Calls
local input = io.read("a")
print(pt.pt((S * exp):match(input)))
