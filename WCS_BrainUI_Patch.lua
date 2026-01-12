--[[
    WCS_BrainUI_Patch.lua - Parche para agregar funcionalidad faltante a la UI
    Agrega funciones que faltan para que los botones funcionen correctamente
]]--

-- ============================================================================
-- FUNCIONES FALTANTES PARA WCS_BrainML
-- ============================================================================

-- Agregar ToggleUI a WCS_BrainML si no existe
if WCS_BrainML and not WCS_BrainML.ToggleUI then
    function WCS_BrainML:ToggleUI()
        -- Por ahora, solo mostrar un mensaje
        -- En el futuro se puede crear una UI dedicada para ML
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFAA00[BrainML]|r UI de Machine Learning no implementada aún")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFAA00[BrainML]|r Usa /brain status para ver estadísticas")
        
        -- Mostrar estadísticas básicas
        if self.Data and self.Data.globalStats then
            local stats = self.Data.globalStats
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF[ML Stats]|r Combates: " .. (stats.totalCombats or 0))
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF[ML Stats]|r Victorias: " .. (stats.wins or 0))
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF[ML Stats]|r DPS Promedio: " .. string.format("%.1f", stats.avgDPS or 0))
        end
    end
end

-- ============================================================================
-- VERIFICACIÓN DE INICIALIZACIÓN
-- ============================================================================

-- Función para verificar que todos los módulos estén cargados
local function VerifyModules()
    local modules = {
        {name = "WCS_Brain", obj = WCS_Brain},
        {name = "WCS_BrainCore", obj = WCS_BrainCore},
        {name = "WCS_BrainUI", obj = WCS_BrainUI},
        {name = "WCS_BrainML", obj = WCS_BrainML},
        {name = "WCS_BrainPetAI", obj = WCS_BrainPetAI}
    }
    
    local allLoaded = true
    for i = 1, table.getn(modules) do
        local mod = modules[i]
        if not mod.obj then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[WCS_Brain]|r Módulo no cargado: " .. mod.name)
            allLoaded = false
        end
    end
    
    if allLoaded then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[WCS_Brain]|r Todos los módulos cargados correctamente")
    end
    
    return allLoaded
end

-- ============================================================================
-- COMANDO DE DIAGNÓSTICO
-- ============================================================================

SLASH_WCSDIAG1 = "/wcsdiag"
SlashCmdList["WCSDIAG"] = function(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF=== WCS_Brain Diagnóstico ===|r")
    
    -- Verificar módulos
    VerifyModules()
    
    -- Verificar estado de WCS_Brain
    if WCS_Brain then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00WCS_Brain:|r v" .. (WCS_Brain.VERSION or "?"))
        DEFAULT_CHAT_FRAME:AddMessage("  ENABLED: " .. tostring(WCS_Brain.ENABLED))
        DEFAULT_CHAT_FRAME:AddMessage("  DEBUG: " .. tostring(WCS_Brain.DEBUG))
        DEFAULT_CHAT_FRAME:AddMessage("  Fase: " .. (WCS_Brain.Context and WCS_Brain.Context.phase or "?"))
        
        -- Verificar hechizos aprendidos
        local spellCount = 0
        if WCS_Brain.LearnedSpells then
            for _ in pairs(WCS_Brain.LearnedSpells) do
                spellCount = spellCount + 1
            end
        end
        DEFAULT_CHAT_FRAME:AddMessage("  Hechizos aprendidos: " .. spellCount)
    end
    
    -- Verificar WCS_BrainCore
    if WCS_BrainCore then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00WCS_BrainCore:|r v" .. (WCS_BrainCore.VERSION or "?"))
        DEFAULT_CHAT_FRAME:AddMessage("  Soul Shards: " .. (WCS_BrainCore.State and WCS_BrainCore.State.soulShards or 0))
    end
    
    -- Verificar WCS_BrainML
    if WCS_BrainML then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00WCS_BrainML:|r v" .. (WCS_BrainML.VERSION or "?"))
        if WCS_BrainML.Data and WCS_BrainML.Data.globalStats then
            local stats = WCS_BrainML.Data.globalStats
            DEFAULT_CHAT_FRAME:AddMessage("  Combates: " .. (stats.totalCombats or 0))
            DEFAULT_CHAT_FRAME:AddMessage("  Victorias: " .. (stats.wins or 0))
        end
    end
    
    -- Verificar WCS_BrainPetAI
    if WCS_BrainPetAI then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00WCS_BrainPetAI:|r v" .. (WCS_BrainPetAI.VERSION or "?"))
        DEFAULT_CHAT_FRAME:AddMessage("  ENABLED: " .. tostring(WCS_BrainPetAI.ENABLED))
        if UnitExists("pet") then
            DEFAULT_CHAT_FRAME:AddMessage("  Mascota: " .. (UnitName("pet") or "?"))
        else
            DEFAULT_CHAT_FRAME:AddMessage("  Mascota: Ninguna")
        end
    end
    
    -- Verificar UI
    if WCS_BrainUI then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00WCS_BrainUI:|r v" .. (WCS_BrainUI.VERSION or "?"))
        if WCS_BrainUI.MainFrame then
            DEFAULT_CHAT_FRAME:AddMessage("  UI creada: Sí")
            DEFAULT_CHAT_FRAME:AddMessage("  UI visible: " .. tostring(WCS_BrainUI.MainFrame:IsVisible()))
        else
            DEFAULT_CHAT_FRAME:AddMessage("  UI creada: No (usa /brainui para abrir)")
        end
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF=== Fin del diagnóstico ===|r")
end

-- ============================================================================
-- COMANDO DE PRUEBA DE BOTONES
-- ============================================================================

SLASH_WCSTEST1 = "/wcstest"
SlashCmdList["WCSTEST"] = function(msg)
    local cmd = string.lower(msg or "")
    
    if cmd == "toggle" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00[Test]|r Probando botón ON/OFF...")
        if WCS_Brain then
            WCS_Brain.ENABLED = not WCS_Brain.ENABLED
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Test]|r ENABLED = " .. tostring(WCS_Brain.ENABLED))
        end
        
    elseif cmd == "debug" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00[Test]|r Probando botón Debug...")
        if WCS_Brain then
            WCS_Brain.DEBUG = not WCS_Brain.DEBUG
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Test]|r DEBUG = " .. tostring(WCS_Brain.DEBUG))
        end
        
    elseif cmd == "cast" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00[Test]|r Probando botón Cast...")
        if WCS_Brain and WCS_Brain.Execute then
            local result = WCS_Brain:Execute()
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Test]|r Execute() = " .. tostring(result))
        end
        
    elseif cmd == "reset" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00[Test]|r Probando botón Reset Memory...")
        if WCS_Brain and WCS_Brain.ResetMemory then
            WCS_Brain:ResetMemory()
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Test]|r ResetMemory() ejecutado")
        end
        
    elseif cmd == "ml" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00[Test]|r Probando botón ML...")
        if WCS_BrainML and WCS_BrainML.ToggleUI then
            WCS_BrainML:ToggleUI()
        end
        
    elseif cmd == "petai" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00[Test]|r Probando checkbox Pet AI...")
        if WCS_BrainPetAI_SetEnabled and WCS_BrainPetAI_IsEnabled then
            local current = WCS_BrainPetAI_IsEnabled()
            WCS_BrainPetAI_SetEnabled(not current)
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Test]|r Pet AI = " .. tostring(WCS_BrainPetAI_IsEnabled()))
        end
        
    elseif cmd == "action" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00[Test]|r Probando GetNextAction()...")
        if WCS_Brain and WCS_Brain.GetNextAction then
            local action = WCS_Brain:GetNextAction()
            if action then
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Test]|r Acción sugerida: " .. (action.spell or "?"))
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Test]|r Razón: " .. (action.reason or "?"))
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFAA00[Test]|r No hay acción disponible")
            end
        end
        
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF[WCS Test]|r Comandos disponibles:")
        DEFAULT_CHAT_FRAME:AddMessage("  /wcstest toggle - Probar botón ON/OFF")
        DEFAULT_CHAT_FRAME:AddMessage("  /wcstest debug - Probar botón Debug")
        DEFAULT_CHAT_FRAME:AddMessage("  /wcstest cast - Probar botón Cast")
        DEFAULT_CHAT_FRAME:AddMessage("  /wcstest reset - Probar botón Reset Memory")
        DEFAULT_CHAT_FRAME:AddMessage("  /wcstest ml - Probar botón ML")
        DEFAULT_CHAT_FRAME:AddMessage("  /wcstest petai - Probar checkbox Pet AI")
        DEFAULT_CHAT_FRAME:AddMessage("  /wcstest action - Probar GetNextAction()")
    end
end

-- ============================================================================
-- INICIALIZACIÓN
-- ============================================================================

DEFAULT_CHAT_FRAME:AddMessage("|cFF9482C9[WCS_BrainUI_Patch]|r Parche de funcionalidad cargado")
DEFAULT_CHAT_FRAME:AddMessage("|cFF9482C9[WCS_BrainUI_Patch]|r Usa |cFFFFCC00/wcsdiag|r para diagnóstico")
DEFAULT_CHAT_FRAME:AddMessage("|cFF9482C9[WCS_BrainUI_Patch]|r Usa |cFFFFCC00/wcstest|r para probar botones")

