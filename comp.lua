local shared = require "shared"
local frontend = require "frontend"
local backend = require "backend"

local input = io.read("a")
local tree = frontend.syntax:match(input)
if not tree then frontend.syntaxError(input) end
io.write(backend.premable)
local e = backend.Compiler:codeProg(tree)
shared.log:write("COMPILATION SUCCEED")
shared.log:close()