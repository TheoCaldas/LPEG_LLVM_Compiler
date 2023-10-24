local log = io.open("log.txt", "w")

local function spairs(t, order)
  -- from https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
  local keys = {}
  for k in pairs(t) do keys[#keys+1] = k end
  if order then
      table.sort(keys, function(a,b) return order(t, a, b) end)
  else
      table.sort(keys)
  end
  local i = 0
  return function()
      i = i + 1
      if keys[i] then
          return keys[i], t[keys[i]]
      end
  end
end

local function pt (x, nocut, id, visited)
  visited = visited or {}
  id = id or ""
  if type(x) == "string" then return "'" .. tostring(x) .. "'"
  elseif type(x) ~= "table" then return tostring(x)
  elseif visited[x] and not nocut then return "..."
  else
    visited[x] = true
    local s = id .. "{\n"
    for k,v in spairs(x) do
      s = s .. id .. tostring(k) .. " = " .. pt(v, nocut, id .. "  ", visited) .. ";\n"
    end
    s = s .. id .. "}"
    return s
  end
end

local function formatWrite (string, ...)
  io.write(string.format(string, ...))
end

return {log=log, pt=pt, fw=formatWrite}