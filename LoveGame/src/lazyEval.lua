local function lazyEval(fct, ...)
    local args={...}
    return function()
        return fct(unpack(args))
    end
end

return lazyEval