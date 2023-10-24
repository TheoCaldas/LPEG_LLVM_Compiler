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

local function foldNumber (n)
    return {tag = "number", num = n}
end

local function foldUnop (t)
  return {tag = "unop", op = t[1], e1 = t[2]}
end

-- MARK: Lexical Patterns
local S = lpeg.S(" \n\t")^0
local OP = "(" * S
local CP = ")" * S
local integer = (lpeg.R"09"^1) / tonumber * S
local opA = lpeg.C(lpeg.S("+-")) * S
local opM = lpeg.C(lpeg.S("*/")) * S
local opN = lpeg.C(lpeg.P("-")) * S

-- MARK: Syntax Patterns
local factor = lpeg.V"factor"
local expM = lpeg.V"expM"
local exp = lpeg.P{"exp";
  factor = 
    (integer / foldNumber) + --just int
    (OP * lpeg.V"exp" * CP) + --exp inside ()
    lpeg.Ct(opN * factor) / foldUnop; --negative factor
  expM = (lpeg.Ct(factor * (opM * factor)^0) / foldBinop) ;
  expA = lpeg.Ct(expM * (opA * expM)^0) / foldBinop;
  exp = S * lpeg.V"expA"
}

-- MARK: Calls
local input = io.read("a")
print(pt.pt(exp:match(input)))
