local class = require "lib.middleclass"
local Signal = require "lib.signal"
local Component = require "component"

local EventListener = class("EventListener")
EventListener:include(Component)

-- Override
function EventListener:onAdded(node)
	Component.onAdded(self, node)
	self.registeredEvents = {}
end

-- Override
function EventListener:onRemoved()
	for callback, eventType in pairs(self.registeredEvents) do
		Signal.remove(eventType, callback)
	end
end

function EventListener:getRegisteredEvents()
	return self.registeredEvents
end

function EventListener:registerCallback(eventType, callback)
	self.registeredEvents[callback] = eventType
	Signal.register(eventType, callback)
end

function EventListener:removeCallback(callback)
	Signal.remove(self.registeredEvents[callback], callback)
end

return EventListener