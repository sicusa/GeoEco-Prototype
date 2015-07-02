local CComponentSupport = {}

-- users must invoke initComponentSupport after included.
function CComponentSupport:initComponentSupport()
    self.components = {}
    self.ready_to_remove = {}
end

function CComponentSupport:getComponents()
    return self.components
end

function CComponentSupport:addComponent(component)
    self.components[component] = true

    if component["onAdded"] ~= nil then
        component:onAdded(self)
    end
end

function CComponentSupport:getComponent(comptype)
    for com, _ in pairs(self.components) do
        if com.class == comptype then
            return com
        end
    end
    return nil
end

function CComponentSupport:getCompnents(comptype)
    local coms = {}
    for com, _ in pairs(self.components) do
        if com.class == comptype then
            table.insert(com)
        end
    end
    return coms
end

function CComponentSupport:removeComponent(component)
    if self.components[component] == nil then
        return
    end
    self.components[component] = false
    table.insert(self.ready_to_remove, component)
end

function CComponentSupport:clearComponents()
    for _, com in pairs(self.components) do
        self:removeComponent(com)
    end
    self.components = {}
end

function CComponentSupport:setComponentEnabled(component, enabled)
    self.components[component] = enabled
end

function CComponentSupport:invokeComponents(funcname, ...)
    for com, enabled in pairs(self.components) do
        if enabled then
            local func = com[funcname]
            if func ~= nil then
                func(com, self, ...)
            end
        end
    end
end

function CComponentSupport:updateComponents()
    for _, com in pairs(self.ready_to_remove) do
        self.components[component] = nil
        if component["onRemoved"] ~= nil then
            component:onRemoved(self)
        end
    end
    self.ready_to_remove = {}
end

return CComponentSupport
