local all = function(...) --Returns the last true value, or false if any value is false.
    return select("#", ...) == 1 and (...) or ((...) and all(select(2, ...)))
end

local any = function(...) --Returns the first true value, or the last false value.
    return (...) or any(select(2, ...))
end

function math.round(num) --Rounds a floating point number to the nearest integer.
    return num>=0 and math.floor(num+.5) or math.ceil(num-.5)
end

function math.frandom(low, high) --Works like math.random(low,high), but returns a float instead of an int.
    return math.random(low - (high and 0 or 1), high and high - 1 or nil) + math.random()
end

function map(fct, numArgs, ...) --Allows functions to take unlimited arguments.
  assert(type(fct) == "function" and type(numArgs) == "number")
  local results = {}
  local function innerWrap(fct, numArgs, results, args)
    local tbl, argsLen, tblLen = {}, #args, 0 --Do only one length lookup per table
    for i = argsLen, argsLen - numArgs + 1, -1 do
      tblLen = tblLen + 1
      tbl[tblLen] = args[i]
      args[argsLen] = nil --Remove the last argument, so to avoid a table.remove() call (which is n-i, where this is O(1))
      argsLen = argsLen - 1
    end
    for i = 1, tblLen / 2 do
      tbl[i], tbl[tblLen - i + 1] = tbl[tblLen - i + 1], tbl[i]
    end
    if argsLen < 0 and tblLen < numArgs then
      return results
    end
    results[#results + 1] = fct(unpack(tbl))
    return #args >= numArgs and innerWrap(fct, numArgs, results, args) or results
  end

  local tbl = innerWrap(fct, numArgs, results, { ... })
  local tblLen = #tbl
  for i = 1, tblLen / 2 do --Reverse the table, since inserting it backwards is n(n-i) iterations, but reversing it is n/2.
    tbl[i], tbl[tblLen - i + 1] = tbl[tblLen - i + 1], tbl[i] --Swap the first half of the elements with the last half
  end
  return unpack(tbl)
end

return all,any,map

