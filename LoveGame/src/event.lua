--Event subsystem
local event = {}
function event:register(eventName, f)
  local eventList=event.events[eventName]
  if type(eventList)=="table" then
    eventList[#eventList+1]=f
  else
    eventList={f}
  end
end

function event:pass(eventName,...)
  local eventList=event.events[eventName]
  for i=1,#eventList do
    eventList[i](...)
  end
end

function event:remove(eventName,f)
  local eventList=event.events[eventName]
  table.remove(f)
end
