-- ============================================================================
-- WCS_BrainNotifications_LocalizationFix.lua
-- Parche para compatibilidad con cliente español
-- Versión: 1.1.0
-- Fecha: Enero 2026
-- ============================================================================

-- Este archivo parchea WCS_BrainWarlockNotifications para que use el sistema
-- de localización existente (WCS_SpellLocalization) correctamente.

-- Función helper para normalizar nombres de hechizos (español -> inglés)
local function NormalizeSpellName(spellName)
    if not spellName then return spellName end
    
    -- Si WCS_SpellLocalization existe y tiene la tabla esES, usarla
    if WCS_SpellLocalization and WCS_SpellLocalization.esES then
        local englishName = WCS_SpellLocalization.esES[spellName]
        if englishName then
            return englishName
        end
    end
    
    -- Si no se encontró traducción, retornar el nombre original
    return spellName
end

-- Esperar a que WCS_BrainWarlockNotifications se cargue
local function ApplyLocalizationFix()
    if not WCS_BrainWarlockNotif then
        -- Si WCS_BrainWarlockNotif no existe aún, intentar de nuevo
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:SetScript("OnEvent", function()
            ApplyLocalizationFix()
            this:UnregisterAllEvents()
        end)
        return
    end
    
    local WarlockNotif = WCS_BrainWarlockNotif
    
    -- Guardar la función original
    WarlockNotif.HasBuff_Original = WarlockNotif.HasBuff
    
    -- Sobrescribir HasBuff con versión que soporta localización
    function WarlockNotif:HasBuff(buffName, unit)
        unit = unit or "player"
        local i = 1
        
        -- Normalizar el nombre del buff que buscamos (convertir a inglés si está en español)
        local normalizedSearchName = NormalizeSpellName(buffName)
        
        while true do
            local buffTexture = UnitBuff(unit, i)
            if not buffTexture then break end
            
            -- Obtener el tooltip del buff para comparar el nombre
            WCS_TooltipScanner = WCS_TooltipScanner or CreateFrame("GameTooltip", "WCS_TooltipScanner", nil, "GameTooltipTemplate")
            WCS_TooltipScanner:SetOwner(WorldFrame, "ANCHOR_NONE")
            WCS_TooltipScanner:SetUnitBuff(unit, i)
            
            local tooltipText = WCS_TooltipScannerTextLeft1:GetText()
            if tooltipText then
                -- Normalizar el nombre del buff encontrado (español -> inglés)
                local normalizedBuffName = NormalizeSpellName(tooltipText)
                
                -- Comparar nombres normalizados (ambos en inglés)
                if normalizedBuffName == normalizedSearchName or string.find(normalizedBuffName, normalizedSearchName) then
                    return true
                end
            end
            
            i = i + 1
        end
        
        return false
    end
    
    -- Guardar la función original de GetBuffTimeLeft
    WarlockNotif.GetBuffTimeLeft_Original = WarlockNotif.GetBuffTimeLeft
    
    -- Sobrescribir GetBuffTimeLeft con versión que soporta localización
    function WarlockNotif:GetBuffTimeLeft(buffName, unit)
        unit = unit or "player"
        local i = 1
        
        -- Normalizar el nombre del buff que buscamos
        local normalizedSearchName = NormalizeSpellName(buffName)
        
        -- Crear tooltip scanner si no existe
        WCS_TooltipScanner = WCS_TooltipScanner or CreateFrame("GameTooltip", "WCS_TooltipScanner", nil, "GameTooltipTemplate")
        
        while true do
            local buffTexture = UnitBuff(unit, i)
            if not buffTexture then break end
            
            -- Obtener el tooltip del buff
            WCS_TooltipScanner:SetOwner(WorldFrame, "ANCHOR_NONE")
            WCS_TooltipScanner:SetUnitBuff(unit, i)
            
            local tooltipText = WCS_TooltipScannerTextLeft1:GetText()
            if tooltipText then
                -- Normalizar el nombre del buff encontrado
                local normalizedBuffName = NormalizeSpellName(tooltipText)
                
                -- Comparar nombres normalizados
                if normalizedBuffName == normalizedSearchName or string.find(normalizedBuffName, normalizedSearchName) then
                    -- En WoW 1.12, no hay forma nativa de obtener el tiempo restante de buffs
                    -- Necesitamos usar un addon como ClassicAuraDurations o estimarlo
                    -- Por ahora, retornamos que existe pero sin tiempo
                    return true, nil
                end
            end
            
            i = i + 1
        end
        return false, nil
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("[WCS_Brain] Parche de localizacion aplicado correctamente (v1.1.0)", 0, 1, 0)
end

-- Aplicar el parche cuando el addon se cargue
ApplyLocalizationFix()
