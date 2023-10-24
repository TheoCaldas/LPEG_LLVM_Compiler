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
local opGt = lpeg.C(lpeg.P(">")) * S
local opGoEt = lpeg.C(lpeg.P(">=")) * S
local opLt = lpeg.C(lpeg.P("<")) * S
local opLoEt = lpeg.C(lpeg.P("<=")) * S
local opEQ = lpeg.C(lpeg.P("==")) * S
local opNEQ = lpeg.C(lpeg.P("!=")) * S

-- MARK: Syntax Patterns
local factor = lpeg.V"factor"
local expM = lpeg.V"expM"
local exp = lpeg.P{"exp";
  factor = 
    (integer / foldNumber) + --just int
    (OP * lpeg.V"exp" * CP) + --exp inside ()
    (lpeg.Ct(opN * factor) / foldUnop); --negative factor
  expM = (lpeg.Ct(factor * (opM * factor)^0) / foldBinop) ;
  expA = lpeg.Ct(expM * (opA * expM)^0) / foldBinop;
  exp = lpeg.V"expA" * S
}

local cond = lpeg.P{"cond";
  cond = 
    lpeg.Ct(exp * opGt * exp) / foldBinop + 
    lpeg.Ct(exp * opGoEt * exp) / foldBinop + 
    lpeg.Ct(exp * opLt * exp) / foldBinop + 
    lpeg.Ct(exp * opLoEt * exp) / foldBinop + 
    lpeg.Ct(exp * opEQ * exp) / foldBinop + 
    lpeg.Ct(exp * opNEQ * exp) / foldBinop;
}

-- MARK: Test Calls
local input = io.read("a")
-- print(pt.pt((S * exp):match(input))) -- test exp
print(pt.pt((S * cond):match(input))) -- test cond
