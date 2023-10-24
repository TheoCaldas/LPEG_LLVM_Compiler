local function spairs(t, order)
  -- from https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
  
  -- collect the keys
  local keys = {}
  for k in pairs(t) do keys[#keys+1] = k end

  -- if order function given, sort by it by passing the table and keys a, b,
  -- otherwise just sort the keys 
  if order then
      table.sort(keys, function(a,b) return order(t, a, b) end)
  else
      table.sort(keys)
  end

  -- return the iterator function
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
  elseif visited[x] and not nocut then return "..."    -- cycle
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

return {pt=pt}

