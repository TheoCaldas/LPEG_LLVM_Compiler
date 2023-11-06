local shared = require "shared"

-- MARK: Global Variables
local types = {
  void = "void",
  int = "int",
  float = "float",
}

local BAOmap = {
  ["+"] = "add",
  ["-"] = "sub",
  ["*"] = "mul",
  ["/"] = "div",
}

local BCOmap = {
  [">="] = "ge",
  ["<="] = "le",
  [">"] = "gt",
  ["<"] = "lt",
  ["=="] = "eq",
  ["!="] = "ne",
}

local maptype = {
  [types.void] = "void",
  [types.int] = "i32",
  [types.float] = "double",
}

-- MARK: Auxiliar Functions
local function errorMsg(msg)
  shared.log:write("SEMANTIC ERROR\n" .. msg)
  os.exit(1)
end

local function isEmpty(string)
  return string == ""
end

local function notType(typeString)
  return types[typeString] == nil
end

-- MARK: LLVM Header
local premable = [[
@.strI = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@.strD = private unnamed_addr constant [4 x i8] c"%g\0A\00"

declare dso_local i32 @printf(i8*, ...)

]]

-- MARK: Compiler
-- translates syntatic tree into LLVM code
local Compiler = {
  tempCount = 0, variables = {}, functions = {},
  currentFunc = "",  
}

-- START: Vars
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

function Compiler:findVar (id)
  local vars = self.variables
  for i = #vars, 1, -1 do
    if vars[i].id == id then
      return vars[i].temp, vars[i].type
    end
  end
  errorMsg("variable not found: " .. id)
end

function Compiler:createVar (id, _type, temp)
  local vars = self.variables
  vars[#vars + 1] = {id = id, type = _type, temp = temp}
end

function Compiler:result_type(result, _type)
  return {result=result, type=_type}
end
-- END: Vars

-- START: Conditional
function Compiler:codeLabel (label)
  shared.fw("  %s:\n", label)
end

function Compiler:codeJmp (label)
  shared.fw("  br label %%%s\n", label)
end

function Compiler:codeCond (exp, Ltrue, Lfalse)
  local c = self:codeExp(exp)
  local aux = self:newTemp()
  if c.type ~= types.int then
    errorMsg("Not a comparison")
  end
  shared.fw([[
  %s = icmp ne i32 %s, 0
  br i1 %s, label %%%s, label %%%s
]], aux, c.result, aux, Ltrue, Lfalse)
end
-- END: Conditional

-- START: Function Call
function Compiler:codeArgs (args, params)
  if #params <= 0 then return ")\n" end
  local s = ""
  for i = 1, #args do
    local c = self:codeExp(args[i])
    if params[i] ~= c.type then
      errorMsg(params[i] .. " argument expected")
    end
    s = s .. string.format((i > 1 and ", " or "") .. "%s %s", maptype[params[i]], c.result)
  end
  s = s .. ")\n"
  return s
end

function Compiler:codeCall(call)
  if not self.functions[call.name] then
    errorMsg("unknown function " .. call.name)
  end
  local func = self.functions[call.name]
  local args = call.optArgs
  local count = isEmpty(args) and 0 or #args
  local exptdCount = #func.params
  if count ~= exptdCount then
    errorMsg(call.name .. " expected " .. exptdCount .. " arguments, " .. count .. " were given")
  end
  local rArgs = self:codeArgs(args, func.params)
  local temp = self:newTemp()
  shared.fw("  %s = call %s @%s(%s", temp, maptype[func.type], call.name, rArgs)
  return self:result_type(temp, func.type)
end
-- END: Function Call

-- START: Expression
function Compiler:codeExp_INT(exp)
  return self:result_type(string.format("%d", exp.num), types.int)
end

function Compiler:codeExp_FLOAT(exp)
  return self:result_type(string.format("%.15e", exp.num), types.float)
end

function Compiler:codeExp_uVAR (exp)
  local varRef, varType = self:findVar(exp.id)	  
  local temp = self:newTemp()
  shared.fw("  %s = load %s, %s* %s\n", temp, maptype[varType], maptype[varType], varRef)
  return self:result_type(temp, varType)
end

function Compiler:codeExp_UAO (exp)
  local coded = self:codeExp(exp.e)
  local temp = self:newTemp()
  if coded.type == types.int then 
    shared.fw("  %s = sub %s 0, %s\n", temp, maptype[coded.type], coded.result)
  elseif coded.type == types.float then 
    shared.fw("  %s = fneg %s %s\n", temp, maptype[coded.type], coded.result)
  else
    errorMsg("Unary operation not defined for " .. coded.type)
  end
  return self:result_type(temp, coded.type)
end

function Compiler:codeExp_BAO (exp)
  local coded1 = self:codeExp(exp.e1)
  local coded2 = self:codeExp(exp.e2)
  local temp = self:newTemp()
  if coded1.type ~= coded2.type then
    errorMsg(coded1.type .. " " .. exp.op .. " " .. coded2.type .. " is not defined")
  elseif coded1.type == types.int then
    local inst = exp.op == "/" and "s" .. BAOmap[exp.op] or BAOmap[exp.op]
    shared.fw("  %s = %s i32 %s, %s\n", temp, inst, coded1.result, coded2.result)
  elseif coded1.type == types.float then
    shared.fw("  %s = f%s double %s, %s\n", temp, BAOmap[exp.op], coded1.result, coded2.result)
  else
    errorMsg("Binary operation not defined for " .. coded.type)
  end
  return self:result_type(temp, coded1.type)
end

function Compiler:codeExp_BCO (exp)
  local c1 = self:codeExp(exp.e1)
  local c2 = self:codeExp(exp.e2)
  local t1 = self:newTemp()
  local t2 = self:newTemp()

  if c1.type ~= c2.type then
    errorMsg(c1.type .. " " .. exp.op .. " " .. c2.type .. " is not defined")
  elseif c1.type == types.int then
    local inst = (exp.op == "==" or exp.op == "!=") and BCOmap[exp.op] or "s" .. BCOmap[exp.op]
    shared.fw("  %s = icmp %s i32 %s, %s\n  %s = zext i1 %s to i32\n", t1, inst, c1.result, c2.result, t2, t1)
  elseif c1.type == types.float then
    local inst = (exp.op == "!=") and "u" .. BCOmap[exp.op] or "o" .. BCOmap[exp.op]
    shared.fw("  %s = fcmp %s double %s, %s\n  %s = zext i1 %s to i32\n", t1, inst, c1.result, c2.result, t2, t1)
  else
    errorMsg("Comparative operation not defined for " .. coded.type)
  end
  return self:result_type(t2, types.int)
end

function Compiler:codeExp (exp)
  local tag = exp.tag
  if tag == "INT" then return self:codeExp_INT(exp)
  elseif tag == "FLOAT" then return self:codeExp_FLOAT(exp)
  elseif tag == "uVAR" then return self:codeExp_uVAR(exp)
  elseif tag == "UAO" then return self:codeExp_UAO(exp)
  elseif tag == "BAO" then return self:codeExp_BAO(exp)
  elseif tag == "BCO" then return self:codeExp_BCO(exp)
  elseif tag == "call" then
    local r = self:codeCall(exp)
    if self.functions[exp.name].type == "void" then
      errorMsg(exp.name .. " is a void function")
    end
    return r
  else
    errorMsg(tag .. ": expression not yet implemented")
  end
end
-- END: Expression

-- START: Statement
function Compiler:codeStat_seq(st)
  self:codeStat(st.s1)
  self:codeStat(st.s2)
end

function Compiler:codeStat_block(st)
  local vars = self.variables
  local level = #vars
  self:codeStat(st.body)
  for i = #vars, level + 1, -1 do
    table.remove(vars)
  end
end

function Compiler:codeStat_if(st)
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
end

function Compiler:codeStat_while(st)
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
end

function Compiler:codeStat_return(st)
  currentType = self.functions[self.currentFunc].type
  if isEmpty(st.e) then
    if currentType ~= types.void then
      errorMsg(currentType .. " return expected")
    end
    io.write("  ret void\n")
  else
    local c = self:codeExp(st.e)
    if currentType ~= c.type then
      errorMsg(currentType .. " return expected")
    end
    shared.fw("  ret %s %s\n", maptype[c.type], c.result)
  end
end

function Compiler:codeStat_print(st)
  local coded = self:codeExp(st.e)
  local common = "  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* %s, i64 0, i64 0), %s %s)\n"
  if coded.type == types.int then
    shared.fw(common, "@.strI", maptype[coded.type], coded.result)
  elseif coded.type == types.float then
    shared.fw(common, "@.strD", maptype[coded.type], coded.result)
  else
    errorMsg("cannot print " .. coded.type)
  end
end

function Compiler:codeStat_daVAR(st)
  local c = self:codeExp(st.e)
  local temp = self:newTemp()
  self:createVar(st.id, c.type, temp)

  if isEmpty(st.optType) then
    -- implicit type
    shared.fw("  %s = alloca %s\n  store %s %s, %s* %s\n",
    temp, maptype[c.type], maptype[c.type], c.result, maptype[c.type], temp)
  else
    -- explicit type
    if notType(st.optType) then
      errorMsg(st.optType .. " is not a type")
    elseif st.optType == types.void then
      errorMsg("Cannot alloc a void variable")
    elseif c.type ~= st.optType then
      errorMsg("Cannot store " .. c.type .. " value in a " .. st.optType .. " variable")
    end
    local map = maptype[st.optType]
    shared.fw("  %s = alloca %s\n  store %s %s, %s* %s\n",
    temp, map, map, c.result, map, temp)
  end
end

function Compiler:codeStat_aVAR(st)
  local c = self:codeExp(st.e)
  local varRef, varType = self:findVar(st.id)
  if c.type ~= varType then
    errorMsg("Cannot store " .. c.type .. " value in a " .. varType .. " variable")
  end
  shared.fw("  store %s %s, %s* %s\n", maptype[c.type], c.result, maptype[c.type], varRef)
end

function Compiler:codeStat_dVAR(st)
  local temp = self:newTemp()
  local var = st.var
  self:createVar(var.id, var.type, temp)
  if notType(var.type) then
    errorMsg(var.type .. " is not a type")
  elseif var.type == types.void then
    errorMsg("Cannot alloc a void variable")
  end
  shared.fw("  %s = alloca %s\n", temp, maptype[var.type])
end

function Compiler:codeStat(st)
  if st == nil then return end
  local tag = st.tag

  if tag == "seq" then return self:codeStat_seq(st)
  elseif tag == "block" then return self:codeStat_block(st)
  elseif tag == "call" then return self:codeCall(st)
  elseif tag == "if" then return self:codeStat_if(st)
  elseif tag == "while" then return self:codeStat_while(st)
  elseif tag == "return" then return self:codeStat_return(st)
  elseif tag == "print" then return self:codeStat_print(st)
  elseif tag == "daVAR" then return self:codeStat_daVAR(st)
  elseif tag == "aVAR" then return self:codeStat_aVAR(st)
  elseif tag == "dVAR" then return self:codeStat_dVAR(st)
  elseif tag == "comment" then return
  else errorMsg(tag .. ": statement not yet implemented")
  end
end
-- END: Statement

-- START: Function Def
function Compiler:codeParam (func)
  if isEmpty(func.optParams) then
    io.write(") {\n")
    return
  end
  local params = func.optParams
  for i = 1, #params do
    local temp = Compiler:newTemp()
    local paramType = params[i].type
    if notType(paramType) then
      errorMsg(paramType .. " type does not exist")
    end
    local map = maptype[paramType]
    shared.fw((i > 1 and ", " or "") .. "%s %s", map, temp)
    params[i].temp = temp
    params[i].typemap = map
  end
  io.write(") {\n")
  for i = 1, #params do
    local paramID = params[i].id
    local paramTemp = params[i].temp
    local paramType = params[i].type
    local paramMap = params[i].typemap
    local varTemp = self:newTemp()
    self:createVar(paramID, paramType, varTemp)
    shared.fw("  %s = alloca %s\n  store %s %s, %s* %s\n",
     varTemp, paramMap, paramMap, paramTemp, paramMap, varTemp)
    table.insert(self.functions[func.name].params, paramType)
  end
end

function Compiler:codeFunc (func)
  local fType = isEmpty(func.optType) and types.void or func.optType
  self.functions[func.name] = {type = fType, params = {}}
  self.currentFunc = func.name

  if notType(fType) then
    errorMsg(fType .. " type does not exist")
  end
  shared.fw("define %s @%s(", maptype[fType], func.name)
  self:codeParam(func)
  self:codeStat(func.body)
  if fType == types.void then
    io.write("  ret void\n")
  end
  io.write("}\n\n")
end
-- END: Function Def

-- START: Program
function Compiler:codeProg (prog)
  for i = 1, #prog do
    self:codeFunc(prog[i])
  end
  if not self.functions["main"] then
    errorMsg("missing main function")
  end
end
-- END: Program

return {
  Compiler=Compiler, 
  semanticError=errorMsg,
  premable=premable,
}