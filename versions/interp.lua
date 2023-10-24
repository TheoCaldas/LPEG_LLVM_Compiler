local lpeg = require "lpeg"
local pt = require "pt"


local function fold (t)
  local res = t[1]
  for i = 2, #t, 2 do
    res = {tag = "binop", e1 = res, op = t[i], e2 = t[i + 1]}
  end
  return res
end


local S = lpeg.S(" \n\t")^0

local OP = "(" * S
local CP = ")" * S

local integer = (lpeg.R"09"^1) / tonumber * S
local opA = lpeg.C(lpeg.S("+-")) * S
local opM = lpeg.C(lpeg.S("*/")) * S

local factor = lpeg.V"factor"
local expM = lpeg.V"expM"
local exp = lpeg.P{"exp";
  factor = (integer / function (n) return {tag = "number", num = n} end)
             + OP * lpeg.V"exp" * CP;
  expM = lpeg.Ct(factor * (opM * factor^0)) / fold;
  expA = lpeg.Ct(expM * (opA * expM^0)) / fold;
  exp = lpeg.V"expA"
}



local input = io.read("a")

print(pt.pt(exp:match(input)))


-- 3 + 5 + 2

