-- WCS_BrainDashboard_Fix.lua
-- Corrección para el Dashboard - Sobrescribe la función CollectMetrics

-- Esperar a que el Dashboard esté inicializado
local function ApplyFix()
    if not WCS_Brain or not WCS_Brain.Dashboard then 
        DEFAULT_CHAT_FRAME:AddMessage("WCS Dashboard Fix: Dashboard no encontrado, reintentando...", 1, 1, 0)
        return false
    end
    
    local Dashboard = WCS_Brain.Dashboard

    -- Sobrescribir la función CollectMetrics con las correcciones
    Dashboard.CollectMetrics = function(self)
    -- FPS
    self.metrics.fps = GetFramerate()
    
    -- Latencia
    local _, _, latency = GetNetStats()
    self.metrics.latency = latency or 0
    
    -- Memoria del addon
    -- En WoW 1.12 no existe UpdateAddOnMemoryUsage, así que estimamos basado en otros factores
    local memEstimate = 0
    
    -- Estimar memoria basada en estructuras de datos
    if WCS_Brain.Cooldowns then
        for _ in pairs(WCS_Brain.Cooldowns) do
            memEstimate = memEstimate + 0.5 -- ~0.5 KB por cooldown
        end
    end
    
    if WCS_BrainCache and WCS_BrainCache.Storage then
        for _ in pairs(WCS_BrainCache.Storage) do
            memEstimate = memEstimate + 1 -- ~1 KB por item en caché
        end
    end
    
    if WCS_BrainPetAI and WCS_BrainPetAI.cooldowns then
        for _ in pairs(WCS_BrainPetAI.cooldowns) do
            memEstimate = memEstimate + 0.3 -- ~0.3 KB por pet cooldown
        end
    end
    
    -- Agregar memoria base del addon (estimado)
    memEstimate = memEstimate + 50 -- Base de ~50 KB
    
    self.metrics.memoryUsage = memEstimate
    
    -- CPU estimado (basado en combate activo)
    local cpuEstimate = 0
    if WCS_BrainMetrics and WCS_BrainMetrics.Combat and WCS_BrainMetrics.Combat.active then
        cpuEstimate = 15.0 -- CPU moderado durante combate
    else
        cpuEstimate = 0.5 -- CPU mínimo fuera de combate
    end
    self.metrics.cpuUsage = cpuEstimate
    
    -- Eventos - Usar combates ganados/perdidos de WCS_BrainMetrics
    if WCS_BrainMetrics and WCS_BrainMetrics.Data then
        local totalCombats = (WCS_BrainMetrics.Data.combatsWon or 0) + (WCS_BrainMetrics.Data.combatsLost or 0)
        self.metrics.eventsProcessed = totalCombats
        self.metrics.eventsThrottled = 0 -- No usado
    else
        self.metrics.eventsProcessed = 0
        self.metrics.eventsThrottled = 0
    end
    
    -- Cooldowns
    local cdCount = 0
    if WCS_Brain.Cooldowns then
        for _ in pairs(WCS_Brain.Cooldowns) do
            cdCount = cdCount + 1
        end
    end
    self.metrics.cooldownsActive = cdCount
    
    -- Pet Cooldowns (CORREGIDO: usar WCS_BrainPetAI en lugar de WCS_Brain.PetAI)
    local petCdCount = 0
    if WCS_BrainPetAI and WCS_BrainPetAI.cooldowns then
        for _ in pairs(WCS_BrainPetAI.cooldowns) do
            petCdCount = petCdCount + 1
        end
    end
    self.metrics.petCooldownsActive = petCdCount
    
    -- Caché
    local cacheCount = 0
    if WCS_BrainCache and WCS_BrainCache.Storage then
        for _ in pairs(WCS_BrainCache.Storage) do
            cacheCount = cacheCount + 1
        end
    end
    self.metrics.cacheSize = cacheCount
    
    -- Decisiones de IA - Usar WCS_BrainMetrics (sistema original del addon)
    local aiDecisions = 0
    local petAIDecisions = 0
    
    -- Contar hechizos casteados desde WCS_BrainMetrics
    if WCS_BrainMetrics and WCS_BrainMetrics.Data and WCS_BrainMetrics.Data.spellUsage then
        for spell, count in pairs(WCS_BrainMetrics.Data.spellUsage) do
            aiDecisions = aiDecisions + count
        end
    end
    
    -- Contar acciones de mascota desde WCS_BrainPetAI
    if WCS_BrainPetAI and WCS_BrainPetAI.Stats and WCS_BrainPetAI.Stats.totalActions then
        petAIDecisions = WCS_BrainPetAI.Stats.totalActions
    elseif WCS_BrainPetAI and WCS_BrainPetAI.actionCount then
        petAIDecisions = WCS_BrainPetAI.actionCount
    end
    
    self.metrics.aiDecisions = aiDecisions
    self.metrics.petAIDecisions = petAIDecisions
    
    -- Agregar al historial
    self:AddToHistory("fps", self.metrics.fps)
    self:AddToHistory("memory", self.metrics.memoryUsage)
    self:AddToHistory("cpu", self.metrics.cpuUsage)
    self:AddToHistory("events", self.metrics.eventsProcessed)
end

    -- Mensaje de confirmación
    if WCS_Brain.Notifications then
        WCS_Brain.Notifications:Success("Dashboard Fix aplicado - Métricas corregidas")
    else
        DEFAULT_CHAT_FRAME:AddMessage("WCS Dashboard: Fix aplicado correctamente", 0, 1, 0)
    end
    
    return true
end

-- Intentar aplicar el fix inmediatamente
if not ApplyFix() then
    -- Si falla, intentar de nuevo después de un delay
    local frame = CreateFrame("Frame")
    local attempts = 0
    frame:SetScript("OnUpdate", function()
        attempts = attempts + 1
        if ApplyFix() or attempts > 50 then
            this:SetScript("OnUpdate", nil)
        end
    end)
end
