local object
object = {
    --The "object" class, so to speak. Adds callbacks.
    type = "guiElement",
    callbacks = {}, --The actual table containing the callback functions when they are added.
    addCallback = function(self, key, fct) --Adds a callback to the given property (running the function when the property changes)
        object.callbacks[key] = object.callbacks[key] or {}
        table.insert(object.callbacks[key], fct)
    end,
    triggerCallback = function(self, property)
        local i = 0
        for _, v in pairs(self.callbacks[property]) do
            v(self, self[property])
        end
    end,
    new = function(self, tbl)
        local realElement --This table stores values, the actual element is empty, because that's how callbacks are easily done in Lua.
        realElement = {}
        realElement.class = object
        realElement.realTbl = setmetatable(realElement, { __index = object })
        local element = setmetatable({}, --Gives the element its metatable for callbacks
            {
                __newindex = function(_, key, val, ...)
                    if realElement[key] == val then return end
                    realElement[key] = val --Set the value in the real table first, then run any callbacks
                    if type(realElement.callbacks[key]) == "table" then
                        realElement.triggerCallback(realElement, key)
                    end
                end,
                __index = realElement, --Read the value from the real table, since this one is empty.
                __len = realElement, --Get the length of the real table, since this one is empty.
            })
        element:addCallback("class",
            function(self, class)
                if not getmetatable(self) then
                    setmetatable(self, { __call = class.new })
                end
                getmetatable(self).__index = class
            end)
        for k, v in pairs(tbl) do --Set all the specified properties of the element in the constructor to the user set ones
            realElement[k] = v
        end
        return element --Return the created "object"
    end
}

return setmetatable(object, { __call = object.new })
