-- WCS_BrainWeakAuras_Fix.lua
-- Corrección para el error de cdData

if not WCS_Brain or not WCS_Brain.WeakAuras then return end

local WeakAuras = WCS_Brain.WeakAuras

-- Sobrescribir UpdateCooldowns para manejar cdData como número o tabla
WeakAuras.UpdateCooldowns = function(self)
    local cooldowns = {}
    
    if WCS_Brain.Cooldowns then
        for spellName, cdData in pairs(WCS_Brain.Cooldowns) do
            local endTime = nil
            local duration = 0
            
            -- cdData puede ser un número (timestamp) o una tabla
            if type(cdData) == "table" and cdData.endTime then
                endTime = cdData.endTime
                duration = cdData.duration or 0
            elseif type(cdData) == "number" then
                endTime = cdData
                duration = 0
            end
            
            if endTime then
                local remaining = endTime - GetTime()
                if remaining > 0 then
                    cooldowns[spellName] = {
                        remaining = remaining,
                        duration = duration,
                        percent = duration > 0 and ((remaining / duration) * 100) or 0,
                    }
                end
            end
        end
    end
    
    self.exports.cooldowns = cooldowns
end

DEFAULT_CHAT_FRAME:AddMessage("WCS WeakAuras Fix aplicado", 0, 1, 0)
