local class = require "lib.middleclass"

local Env = require "GeoEco.Environment"
local PhyInteractions = require "GeoEco.Physics.PhyInteractions"
local PtlInteractions = require "GeoEco.Simulation.PtlInteractions"

local function compile(code)
    local translated = {}
    local current_regin = {}
    translated["CONTROL"] = current_regin
    code = code:upper()

    local line_num = 0
    for line in code:gmatch("[^\n]+") do
        line_num = line_num + 1
        local matcher = line:gmatch("%g+")
        local head = matcher()

        if head == nil then
            -- next line
        elseif head:byte(1) == 91 then -- '['
            -- regin indicator
            local s, e = line:find("%[.*%]")
            if s == nil then
                return nil, "invalid regin indicator at line "..line_num
            end
            local regin_name = line:sub(s + 1, e - 1)
            if regin_name == "" then
                return nil, "empty regin name at line "..line_num
            end
            current_regin = translated[regin_name]
            if current_regin == nil then
                current_regin = {}
                translated[regin_name] = current_regin
            end
        else
            -- command
            local oprands = {}
            while true do
                local v = matcher()
                if v == nil then
                    break
                end
                local n = tonumber(v)
                if n ~= nil then
                    table.insert(oprands, n)
                else
                    table.insert(oprands, v)
                end
            end
            table.insert(current_regin, {head, oprands})
        end
    end
    return translated
end

function ignoreFirst(a, ...)
    return ...
end

local LifeCode = class("LifeCode")

local commands = {
    FRAME = {
        args = { "number" },
        handler = function(life_code, particle, args)
            return args[1] <= particle:getLifeCount()
        end
    },

    SLEEP = {
        args = { "number" },
        handler = function(life_code, particle, args)
            return args[1] <= life_code:getCurrentCommandTimer()
        end
    },

    GENERATION = {
        args = { "number" },
        handler = function(life_code, particle, args)
            local max_gen = args[1]
            if max_gen < particle:getGeneration() then
                life_code:returnFromCurrentRegin()
            end
            return true
        end
    },

    UNTIL_SINGLE = {
        args = {},
        handler = function(life_code, particle, args)
            if particle:getConnectionCount() ~= 0 then
                return false
            end
            return true
        end
    },

    PRODUCE = {
        args = { "string", "string", "number" }, -- category, regin, mass
        handler = function(life_code, particle, args)
            local child = nil
            local child_mass = args[3]
            local ptl_mass = particle:getMass()
            local ptl_heat = particle:getHeat()
            local new_pos = particle:getPosition():clone()

            if child_mass >= particle:getMass() then
                child = Env:createParticle(new_pos, ptl_mass, args[1])
                child:setHeat(ptl_heat)
                particle:removeSelf()
                return true
            else
                local new_mass = ptl_mass - child_mass
                particle:setMass(new_mass)
                particle:setHeat(new_mass / ptl_mass * ptl_heat)

                child = Env:createParticle(new_pos, child_mass, args[1])
                child:setHeat(child_mass / ptl_mass * ptl_heat)
            end

            if args[2] ~= "[]" then
                local newCode = LifeCode:new()
                newCode:loadCompiledCode(life_code:getCompiledCode())
                newCode:setLogListener(life_code:getLogListener())
                local thread = newCode:createThread(args[2])
                thread.linked_particle = particle
                child:setCode(newCode)
            end
            child:setGeneration(particle:getGeneration() + 1)
            life_code:setLinkedParticle(child)
            return true
        end
    },

    CONNECT = {
        args = { "string", "..." },
        handler = function(life_code, particle, args)
            local linked_ptl = life_code:getLinkedParticle()
            if linked_ptl == nil then
                life_code:log(
                    "error",
                    "CONNECT failed: linked particle is empty"
                )
                return true
            end
            local interaction_type = PhyInteractions[args[1]:lower()]
            if interaction_type == nil then
                life_code:log(
                    "error",
                    "CONNECT failed: interaction not found"
                )
                return true
            end
            local interaction = interaction_type:new(ignoreFirst(unpack(args)))
            Env:createConnection(particle, linked_ptl, interaction)
            return true
        end
    },

    CLEAR_CONNECTIONS = {
        args = {},
        handler = function(life_code, particle, args)
            Env:clearEntityConnections(particle)
            return true
        end
    },

    CALL = {
        args = { "string" },
        handler = function(life_code, particle, args)
            life_code:invokeRegin(args[1])
            -- This makes sure that life code will be runing at index 1 in
            -- the regin args[1]
            return false
        end
    },

    THREAD = {
        args = { "string" },
        handler = function(life_code, particle, args)
            life_code:createThread(args[1])
            return true
        end
    },

    EXIT = {
        args = {},
        handler = function(life_code, particle, args)
            life_code:terminateAllThreads()
            return true
        end
    }
}

function LifeCode.static:addCommand(command_name, func)
    commands[command_name] = func
end

function LifeCode:initialize()
    self.code = nil
    self.threads = {}
    self.current_thread = nil

    self.log_listener = nil
end

function LifeCode:loadString(code)
    local code = compile(code)
    self:loadCompiledCode(code)
end

function LifeCode:loadCompiledCode(code)
    self.code = code
    self.call_stack = {}
end

function LifeCode:getCompiledCode()
    return self.code
end

function LifeCode:getCurrentRegin()
    return self.current_thread.regin
end

function LifeCode:getCurrentReginName()
    return self.current_thread.regin_name
end

function LifeCode:getLinkedParticle()
    return self.current_thread.linked_particle
end

function LifeCode:setLinkedParticle(entity)
    self.current_thread.linked_particle = entity
end

function LifeCode:getCurrentCommandTimer()
    return self.current_thread.command_timer
end

function LifeCode:createThread(regin_name)
    local thread = {
        regin_name = "",
        regin = nil,

        index = 1,
        command_handler = nil,
        command_oprands = nil,
        command_timer = 0,

        linked_particle = nil,
        call_stack = {}
    }

    local old_thread = self.current_thread
    self.current_thread = thread
    if self:invokeRegin(regin_name) then
        self.threads[thread] = true
    end
    self.current_thread = old_thread

    return thread
end

function LifeCode:switchCommand(index)
    local thread = self.current_thread
    local current_regin = thread.regin

    if #current_regin < index then
        self:log(
            "error",
            string.format(
                "command switching failed: regin index '%d' out of range",
                index
            )
        )
        return false
    end

    for i = index, #current_regin do
        repeat
            local cmd_info = current_regin[index]
            local command = commands[cmd_info[1]]

            if command == nil then
                self:log(
                    "error",
                    string.format(
                        "command switching failed: "..
                        "command '%s' at regin index '%d' was invalid",
                        cmd_info[1], index
                    )
                )
                break
            end

            local oprands = cmd_info[2]
            local args = command.args
            for i, t in pairs(args) do
                if t == "..." then
                    break
                elseif type(oprands[i]) ~= t then
                    self:log(
                        "error",
                        string.format(
                            "command switching failed: "..
                            "command '%s' at regin index '%d' had invalid arg "..
                            "(argnum: '%d', expected: '%s', actual: '%s')",
                            cmd_info[1], index, i, t, type(oprands[i])
                        )
                    )
                    break
                end
            end

            thread.index = index
            thread.command_handler = command.handler
            thread.command_oprands = oprands
            thread.command_timer = 0
            return true
        until true
    end
    self:log("error", "command switching failed: no valid command found")
    return false
end

function LifeCode:invokeRegin(regin_name)
    local regin = self.code[regin_name]
    if regin == nil then
        self:log(
            "error",
            string.format(
                "regin invoking failed: regin name [%s] not found",
                regin_name
            )
        )
        return false
    end

    local thread = self.current_thread
    if thread == nil then
        self:log(
            "error",
            "regin switching failed: no thread was running"
        )
        return false
    end

    if thread.regin ~= nil and thread.regin_name ~= regin_name then
        table.insert(thread.call_stack, {
            thread.regin_name,
            thread.index
        })
    end
    thread.regin_name = regin_name
    thread.regin = regin

    if self:switchCommand(1) == false then
        self:log(
            "error",
            "regin switching failed: no valid command could be found"
        )
        self:returnFromCurrentRegin()
        return false
    end
    return true
end

function LifeCode:returnFromCurrentRegin()
    local thread = self.current_thread
    local call_stack = thread.call_stack
    if #call_stack == 0 then
        self:terminateCurrentThread()
        return
    end

    local last = call_stack[#call_stack]
    table.remove(call_stack, #call_stack)

    thread.regin_name = last[1]
    thread.regin = self.code[thread.regin_name]
    if self:switchCommand(last[2] + 1) == false then
       self:terminateCurrentThread()
    end
end

function LifeCode:terminateAllThreads()
    self.threads = {}
    self.current_thread = nil
    self:log("info", "life code terminated")
end

function LifeCode:terminateCurrentThread()
    local thread = self.current_thread
    if thread == nil then
        return
    end
    self.threads[thread] = nil
    self.current_thread = nil
    self:log("info", "current thread terminated")
end

function LifeCode:getLogListener()
    return self.log_listener
end

function LifeCode:setLogListener(listener)
    self.log_listener = listener
end

function LifeCode:log(head, msg)
    if self.log_listener == nil then
        return
    end
    self.log_listener:log(self, head, msg)
end

require "lib.debug"

function LifeCode:update(ptl)
    for thread, _ in pairs(self.threads) do
        self.current_thread = thread
        local current_regin = thread.regin

        -- self:log(
        --     "info",
        --     string.format(
        --         "[LIFE_CODE_TICK]\n"..
        --         "  PTL_GENERATION: %d\n"..
        --         "  CURRENT_REGIN: %s\n"..
        --         "  CURRENT_INDEX: %d",
        --         ptl:getGeneration(),
        --         thread.regin_name,
        --         thread.index
        --     )
        -- )
        while thread.command_handler(self, ptl, thread.command_oprands) do
            if self.current_thread == nil then
                return
            end
            if self:switchCommand(thread.index + 1) == false then
                self:returnFromCurrentRegin()
                if self.current_thread == nil then
                    break
                end
            end
        end
        if thread.regin == current_regin then
            thread.command_timer = thread.command_timer + 1
        end
    end
    self.current_thread = nil
end

return LifeCode
