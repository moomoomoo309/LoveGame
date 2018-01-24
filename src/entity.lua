--- In progress, nothing to see here
--- @classmod entity

local object = require "object"
local sprite = require "sprite"

local defaultEntitySprite
local defaultEntityState = "default"
local entity = {}

function entity.new(args)
    assert(args, "Cannot create an entity without arguments!")
    assert(args.name, "Cannot create an entity without a name!")
    local obj = object {
        x = args.x or 0,
        y = args.y or 0,
        w = args.w or 0,
        h = args.h or 0,
        states = {},
        currentState = args.state or defaultEntityState,
        name = args.name,
        transitions = args.transitions or {},
        currentSprite = nil,
        sprites = {}
    }
    for _, state in pairs(args.state) do
        obj.state[state] = true
    end
    return obj
end

function entity:draw()
    self.currentSprite:draw()
end

function entity:setState(state)
    assert(type(state) == "string", ("String expected, got %s."):format(type(state)))
    assert(self.states[state], ("State \"%s\" does not exist for entity %s! Valid states: %s"):format(state, self.name, table.concat(self.states, ", ")))
    entity:transition(self.state, state)
    self.currentState = state
end

function entity:transition(oldState, newState)
    if oldState == newState then
        return
    end
    if type(self.transitions[oldState]) == "table" then
        assert(type(self.transitions[oldState][newState]) == "function", ("Tried to transition from %s to %s, but transition was %s."):format(oldState, newState, type(self.transitions[oldState][newState]) == "nil" and "nil" or "a " .. type(self.transitions[oldState][newState])))
        return self:transitions[oldState][newState]()
    else
        assert(type(self.transitions[oldState] == "function"), ("Function or table expected, got %s."):format(type(self.transitions[oldState])))
        return self:transitions[oldState](newState)
    end
    assert(self.transitions and self.transitions.default, ("No default transition defined for entity \"%s\"."):format(self.name))
    return self:transitions.default(oldState, newState)
end

function entity:getState()
    return self.currentState
end



return entity