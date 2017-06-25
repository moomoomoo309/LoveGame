--Look ma, no dependencies!

local timer
timer = {
    paused = {},
    functions = {},
    groups = {},
    sleep = function(seconds)
        --- Sleeps the running coroutine until seconds has passed. Will not work on the main thread.

        --Check for the main thread
        local co = coroutine.running()
        local success, errMessage = pcall(coroutine.yield)
        assert(success, errMessage:find("C-call", nil, true) and "You can't sleep on the main thread!" or errMessage)
        coroutine.resume(co)
        --Actually sleep
        love.timer.sleep(seconds)
    end,
    after = function(seconds, fct, group)
        --- Run fct after seconds has passed. Returns a function which cancels this function.
        assert(type(fct)=="function", ("Function expected, got %s."):format(type(fct)))
        group = group or "default"
        timer.functions[group] = timer.functions[group] or {}
        local index = #timer.functions[group] + 1
        local timeElapsed = 0
        timer.functions[group][index] = function(dt)
            timeElapsed = timeElapsed + dt
            if timeElapsed >= seconds then
                fct()
                timer.functions[group][index] = nil
            end
        end
        return function()
            if timer.functions[group][index] then
                timer.functions[group][index] = nil
            end
        end
    end,
    before = function(seconds, fct, cancelFct, group)
        --- Run fct until seconds has passed. Returns a function which cancels this function.
        assert(type(fct)=="function", ("Function expected, got %s."):format(type(fct)))
        group = group or "default"
        timer.functions[group] = timer.functions[group] or {}
        local index = #timer.functions[group] + 1
        local timeElapsed = 0
        timer.functions[group][index] = function(dt)
            timeElapsed = timeElapsed + dt
            if timeElapsed >= seconds then
                timer.functions[group][index] = nil
            else
                fct(timeElapsed)
            end
        end
        return function()
            if timer.functions[group][index] then
                timer.functions[group][index] = nil
                if type(cancelFct) == "function" then
                    cancelFct()
                end
            end
        end
    end,
    ["until"] = function(conditionFct, fct, cancelFct, group)
        --- Runs fct until conditionFct returns a truthy value or the function returned is called.
        assert(type(fct)=="function", ("Function expected, got %s."):format(type(fct)))
        assert(type(conditionFct)=="function", ("Function expected, got %s."):format(type(conditionFct)))
        local done = conditionFct()
        group = group or "default"
        timer.functions[group] = timer.functions[group] or {}
        local index = #timer.functions[group] + 1
        timer.functions[group][index] = function()
            if done then
                timer.groups[timer.functions[group][index]] = nil
                timer.functions[group][index] = nil
                return
            end
            fct()
            done = done or conditionFct()
        end
        timer.groups[timer.functions[group][index]] = group
        return function()
            done = true
            if type(cancelFct) == "function" then
                cancelFct()
            end
        end
    end,
    when = function(conditionFct, fct, cancelFct, group)
        --- Runs fct when conditionFct returns a truthy value or the function returned is called.
        assert(type(fct)=="function", ("Function expected, got %s."):format(type(fct)))
        assert(type(conditionFct)=="function", ("Function expected, got %s."):format(type(conditionFct)))
        local done = conditionFct()
        group = group or "default"
        timer.functions[group] = timer.functions[group] or {}
        local index = #timer.functions[group] + 1
        timer.functions[group][index] = function()
            if done then
                fct()
                timer.groups[timer.functions[group][index]] = nil
                timer.functions[group][index] = nil
                return
            end
            done = done or conditionFct()
        end
        timer.groups[timer.functions[group][index]] = group
        return function()
            done = true
            if type(cancelFct) == "function" then
                cancelFct()
            end
        end
    end,
    every = function(seconds, fct, cancelFct, group)
        --- Runs fct every seconds seconds.
        assert(type(fct)=="function", ("Function expected, got %s."):format(type(fct)))
        group = group or "default"
        timer.functions[group] = timer.functions[group] or {}
        local index = #timer.functions[group] + 1
        local timeElapsed = 0
        local timesRun = 0
        timer.functions[group][index] = function(dt)
            timeElapsed = timeElapsed + dt
            if timeElapsed >= seconds then
                timeElapsed = 0
                timesRun = timesRun + 1
                fct(timesRun)
            end
        end
        timer.groups[timer.functions[group][index]] = group
        return function()
            if timer.functions[group][index] then
                timer.functions[group][index] = nil
                if type(cancelFct) == "function" then
                    cancelFct()
                end
            end
        end
    end,
    everyCondition = function(conditionFct, fct, cancelFct, group)
        --- Runs fct every seconds seconds.
        assert(type(fct)=="function", ("Function expected, got %s."):format(type(fct)))
        assert(type(conditionFct)=="function", ("Function expected, got %s."):format(type(conditionFct)))
        group = group or "default"
        timer.functions[group] = timer.functions[group] or {}
        local index = #timer.functions[group] + 1
        local timesRun = 0
        timer.functions[group][index] = function()
            if conditionFct() then
                timesRun = timesRun + 1
                fct(timesRun)
            end
        end
        timer.groups[timer.functions[group][index]] = group
        return function()
            if timer.functions[group][index] then
                timer.functions[group][index] = nil
                if type(cancelFct) == "function" then
                    cancelFct()
                end
            end
        end
    end,
    pause = function(group)
        timer.paused[group] = true
    end,
    resume = function(group)
        timer.paused[group] = false
    end ,
    update = function(dt)
        for group, fcts in pairs(timer.functions) do
            if not timer.paused[group] then
                for _, fct in pairs(fcts) do
                    fct(dt)
                end
            end
        end
    end
}
timer.unpause = timer.resume


return timer