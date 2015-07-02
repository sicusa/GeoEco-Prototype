local class = require "lib.middleclass"

local Component = {}

function Component:receiveMessage(msg, ...)
end

function Component:onAdded(node)
	assert(self.node == nil, "The component has been added to another node")
	self.node = node
	self.enabled = false
end

function Component:onRemoved()
end

function Component:isEnabled()
	return self.enabled
end

function Component:enable()
	self.enabled = true
	self.node:onComponentEnabled(self)
end

function Component:disable()
	self.enabled = false
	self.node:onComponentDisabled(self)
end

function Component:getNode()
	return node
end

function Component:render()
end

function Component:update(dt)
end

return Component