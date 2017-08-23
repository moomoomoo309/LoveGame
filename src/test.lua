local function all(...)
    ---Returns if all arguments are true.
    return (select("#", ...) == 1 and (...) or ((...) and all(select(2, ...)))) and true or false
end

local function all2(...)
    if select("#", ...) == 1 then
        return (...) and true or false
    elseif (...) then
        return all2(select(2, ...))
    end
    return false
end

local function all3(args)
    for i = 1, #args do
        if not args[i] then
            return false
        end
    end
    return true
end

local tbl = {}
for i = 1, 1000 do
    tbl[i] = i
end

for i = 1, 1000000 do
    all2(unpack(tbl))
end