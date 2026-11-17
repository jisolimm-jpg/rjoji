local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- ================= LOAD NETWORK & DATA MODULES =================
local network = nil
pcall(function()
    network = require(ReplicatedStorage.Shared.Packages.Network)
end)

local eraTripData = nil
pcall(function()
    eraTripData = require(ReplicatedStorage.Shared.Data.Events.EraTripData)
end)

-- ================= CONSTANTS & COORDINATES =================
local AUTO_WALK_SPEED = 250

-- TimeLab & Portal Coordinates
local TIMELAB_TRIGGER_POS = Vector3.new(761.3, 6.3, 232.0)

-- Future Coordinates
local FUTURE_KICK_READY_CF = CFrame.new(710, 8.75, 3000)
local FUTURE_COLLECT_CF    = CFrame.new(748, 12, 3000)
local FUTURE_TRADER_CF     = CFrame.new(740, 2, 3044)
local FUTURE_EXIT_CF       = CFrame.new(781.6, 6.2, 3000.1)

-- Future Zones (X bounds along the lane, Z ~ 3000)
local FUTURE_ZONES = {
    { Index = 5, Name = "Zone 5 (Mythic/Boss)", MinX = -130, MaxX = 110, Center = Vector3.new(-10, 4, 3000) },
    { Index = 4, Name = "Zone 4 (Legendary)",   MinX = 110,  MaxX = 290, Center = Vector3.new(200, 4, 3000) },
    { Index = 3, Name = "Zone 3 (Epic)",        MinX = 290,  MaxX = 440, Center = Vector3.new(350, 4, 3000) },
    { Index = 2, Name = "Zone 2 (Rare)",        MinX = 440,  MaxX = 560, Center = Vector3.new(500, 4, 3000) },
    { Index = 1, Name = "Zone 1 (Common)",      MinX = 560,  MaxX = 670, Center = Vector3.new(615, 4, 3000) },
}

-- Future Robot Names
local FUTURE_ROBOT_NAMES = {
    ["Robottino Bulloncino"] = true,
    ["Alienino Hoverboard"]  = true,
    ["Droncello Laserello"]  = true,
    ["Cyborgatto Ologramma"] = true,
    ["Mecha Pizzone 3000"]   = true,
}

-- Mecha Pizzone 3000 Craft Recipe Cost
local FUTURE_MYTHIC_COST = {
    Future1 = 45, -- Scrap Metal
    Future2 = 25, -- Robot Scraps
    Future3 = 14, -- Laser Goggles
    Future4 = 7,  -- Plasma Core
    Future5 = 1,  -- Quantum Chip
}

-- Roman Coordinates
local ROMAN_KICK_READY_CF = CFrame.new(710, 8.75, 3000)
local ROMAN_COLLECT_CF    = CFrame.new(748, 12, 3000)
local ROMAN_TRADER_CF     = CFrame.new(740, 2, 3044)
local ROMAN_EXIT_CF       = CFrame.new(781.6, 6.2, 3000.1)

-- Roman Zones (X bounds along the lane, Z ~ 3000)
local ROMAN_ZONES = {
    { Index = 5, Name = "Zone 5 (Mythic/Boss)", MinX = -150, MaxX = 50 },
    { Index = 4, Name = "Zone 4 (Legendary)",   MinX = 50,   MaxX = 250 },
    { Index = 3, Name = "Zone 3 (Epic)",        MinX = 250,  MaxX = 420 },
    { Index = 2, Name = "Zone 2 (Rare)",        MinX = 420,  MaxX = 560 },
    { Index = 1, Name = "Zone 1 (Common)",      MinX = 560,  MaxX = 680 },
}

-- Roman Guard Names
local ROMAN_GUARD_NAMES = {
    ["Gladiatorino Pomodoro"] = true,
    ["Centurione Spaghettone"] = true,
    ["Lupetta Capitolina"]     = true,
    ["Leone Colosseone"]       = true,
}

-- Cesarone Imperatore (Roman Mythic) Craft Recipe Cost
local ROMAN_MYTHIC_COST = {
    Roman1 = 45, -- Bronze Coin
    Roman2 = 25, -- Laurel Wreath
    Roman3 = 14, -- Centurion Helm
    Roman4 = 7,  -- Golden Eagle
    Roman5 = 1,  -- Caesar Seal
}

-- Jurassic Coordinates
local JURASSIC_KICK_READY_CF = CFrame.new(710, 8.75, 3000)
local JURASSIC_COLLECT_CF    = CFrame.new(748, 12, 3000)
local JURASSIC_TRADER_CF     = CFrame.new(740, 2, 3044)
local JURASSIC_EXIT_CF       = CFrame.new(781.6, 6.2, 3000.1)

-- T-Rexone Braccino (Jurassic Mythic) Craft Recipe Cost
local JURASSIC_MYTHIC_COST = {
    Jurassic1 = 45, -- Amber Shard
    Jurassic2 = 25, -- Raptor Claw
    Jurassic3 = 14, -- Fossil Skull
    Jurassic4 = 7,  -- Volcano Ember
    Jurassic5 = 1,  -- Primal Egg
}

-- IceAge Coordinates
local ICEAGE_KICK_READY_CF = CFrame.new(710, 8.75, 3000)
local ICEAGE_COLLECT_CF    = CFrame.new(748, 12, 3000)
local ICEAGE_TRADER_CF     = CFrame.new(740, 2, 3044)
local ICEAGE_EXIT_CF       = CFrame.new(781.6, 6.2, 3000.1)

-- Frosty / Mammutone (IceAge Mythic) Craft Recipe Cost
local ICEAGE_MYTHIC_COST = {
    IceAge1 = 45, -- Frozen Pebble
    IceAge2 = 25, -- Ice Shard
    IceAge3 = 14, -- Glacial Tooth
    IceAge4 = 7,  -- Frost Core
    IceAge5 = 1,  -- Mammoth Tusk
}

-- IceAge constants
local ICEAGE_MAX_SHARDS = 4   -- HoldMax default (attribute di model IceAge)
local ICEAGE_CHASER_SAFE_DIST = 25  -- jarak aman dari Avalanche/Yeti

-- Eighties Coordinates
local EIGHTIES_KICK_READY_CF = CFrame.new(710, 8.75, 3000)
local EIGHTIES_COLLECT_CF    = CFrame.new(748, 12, 3000)
local EIGHTIES_TRADER_CF     = CFrame.new(740, 2, 3044)
local EIGHTIES_EXIT_CF       = CFrame.new(781.6, 6.2, 3000.1)

-- Era Name Mapping
local ERA_DISPLAY_NAMES = {
    ["Future"]   = "The Future",
    ["IceAge"]   = "Ice Age",
    ["Jurassic"] = "Jurassic",
    ["Roman"]    = "Roman Empire",
    ["Eighties"] = "80s Arcade",
}

local ERA_INTERNAL_NAMES = {
    ["The Future"]   = "Future",
    ["Ice Age"]      = "IceAge",
    ["Jurassic"]     = "Jurassic",
    ["Roman Empire"] = "Roman",
    ["80s Arcade"]   = "Eighties",
}

-- ================= LOAD WINDUI (DIAGNOSTIC) =================
local WINDUI_URL = "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"

local winduiLoaded, WindUI = pcall(function()
    local source = game:HttpGet(WINDUI_URL)
    assert(type(source) == "string" and #source > 0, "WindUI returned an empty response")

    local chunk, compileError = loadstring(source)
    assert(type(chunk) == "function", "WindUI compile failed: " .. tostring(compileError))

    return chunk()
end)

if not winduiLoaded then
    local message = "[KALB Auto EraTrip] WindUI load failed: " .. tostring(WindUI)
    warn(message)
    error(message, 0)
end

assert(type(WindUI) == "table" and type(WindUI.CreateWindow) == "function",
    "[KALB Auto EraTrip] WindUI loaded, but CreateWindow is unavailable")

pcall(function()
    if _G.EraTripWindow then
        _G.EraTripWindow:Destroy()
    end
end)

local windowCreated, Window = pcall(function()
    return WindUI:CreateWindow({
        Title = "KALB Auto EraTrip",
        Icon = "clock",
        Author = "Isengbikin",
        Folder = "EraTripPanel",
        Size = UDim2.fromOffset(500, 390),
        ToggleKey = Enum.KeyCode.RightShift,
        Theme = "Dark",
    })
end)

if not windowCreated then
    local message = "[KALB Auto EraTrip] CreateWindow failed: " .. tostring(Window)
    warn(message)
    error(message, 0)
end

assert(Window and type(Window.Tab) == "function",
    "[KALB Auto EraTrip] Window was created, but Tab is unavailable")

_G.EraTripWindow = Window

-- ================= HELPER FUNCTIONS =================
local function getCharacterParts()
    local char = player.Character
    if not char then return nil, nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    return humanoid, rootPart
end

local function safePivotTo(targetCF)
    local char = player.Character
    if not char then return false end
    pcall(function()
        char:PivotTo(targetCF)
    end)
    return true
end

local function countCarriedAboveHead()
    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return 0 end
    local headPos = head.Position
    local count = 0
    
    -- Future (CarriedCrate) & Jurassic (CarriedEgg) diposisikan di Workspace tepat di atas kepala
    for _, obj in ipairs(Workspace:GetChildren()) do
        if (obj.Name == "CarriedCrate" or obj.Name == "CarriedEgg") and obj:IsA("Model") then
            local p = obj:GetPivot().Position
            local xzDist = math.sqrt((p.X - headPos.X)^2 + (p.Z - headPos.Z)^2)
            if xzDist < 8 and p.Y >= (headPos.Y - 1) then
                count = count + 1
            end
        end
    end
    
    return count
end

local function countFromHUD()
    local playerGui = player:FindFirstChild("PlayerGui")
    local haulHUD = playerGui and playerGui:FindFirstChild("EraHaulHUD")
    if haulHUD then
        for _, desc in ipairs(haulHUD:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Text and desc.Text ~= "" then
                local cur, maxVal = string.match(desc.Text, "HAUL%s*(%d+)%s*/%s*(%d+)")
                if cur then
                    return tonumber(cur), tonumber(maxVal)
                end
            end
        end
    end
    return nil, nil
end

local function getCarriedCratesCount()
    -- 1. Deteksi dari attribute EraCarry (server-side)
    local countAttr = 0
    local carry = player:GetAttribute("EraCarry")
    if typeof(carry) == "string" and carry ~= "" then
        for _ in string.gmatch(carry, "[^,]+") do
            countAttr = countAttr + 1
        end
    elseif typeof(carry) == "number" then
        countAttr = carry
    end
    
    -- 2. Deteksi fisik: hitung model CarriedCrate yang melayang di atas kepala kita
    local countHead = countCarriedAboveHead()
    
    -- 3. Deteksi GUI: baca teks HUD "HAUL X/Y"
    local countHUD, maxFromHUD = countFromHUD()
    
    -- Ambil nilai terbesar yang terdeteksi
    local finalCount = math.max(countAttr, countHead, countHUD or 0)
    return finalCount, maxFromHUD
end

-- Jurassic memakai attribute EraCarry dan model CarriedEgg yang sama.
-- Wrapper ini mencegah pemanggilan fungsi yang sebelumnya belum didefinisikan.
local function getCarriedEggsCount()
    return getCarriedCratesCount()
end

-- Future: EraCarry menjadi sumber hitungan utama.
-- Jangan memakai nilai HUD untuk jumlah bawaan karena HUD dapat terlambat
-- memperbarui angka setelah proses setor selesai.
local function getFutureCarriedCount()
    local carry = player:GetAttribute("EraCarry")
    if typeof(carry) == "string" then
        if carry == "" then return 0 end
        local count = 0
        for _ in string.gmatch(carry, "[^,]+") do
            count = count + 1
        end
        return count
    elseif typeof(carry) == "number" then
        return math.max(0, carry)
    end

    -- Fallback jika attribute belum tersedia.
    return countCarriedAboveHead()
end

local function getFutureCarryCapacity()
    local _, maxFromHUD = countFromHUD()
    return maxFromHUD or 10
end

local function getAllRelics()
    local attr = player:GetAttribute("EraRelics")
    local relics = {}
    if typeof(attr) == "string" then
        pcall(function()
            relics = HttpService:JSONDecode(attr)
        end)
    end
    return relics
end

local function canCraftMechaPizzone()
    local relics = getAllRelics()
    for reqKey, reqVal in pairs(FUTURE_MYTHIC_COST) do
        local cur = tonumber(relics[reqKey]) or 0
        if cur < reqVal then
            return false, relics
        end
    end
    return true, relics
end

local function canCraftRomanMythic()
    local relics = getAllRelics()
    for reqKey, reqVal in pairs(ROMAN_MYTHIC_COST) do
        local cur = tonumber(relics[reqKey]) or 0
        if cur < reqVal then
            return false, relics
        end
    end
    return true, relics
end

local function canCraftJurassicMythic()
    local relics = getAllRelics()
    for reqKey, reqVal in pairs(JURASSIC_MYTHIC_COST) do
        local cur = tonumber(relics[reqKey]) or 0
        if cur < reqVal then
            return false, relics
        end
    end
    return true, relics
end

local function canCraftIceAgeMythic()
    local relics = getAllRelics()
    for reqKey, reqVal in pairs(ICEAGE_MYTHIC_COST) do
        local cur = tonumber(relics[reqKey]) or 0
        if cur < reqVal then
            return false, relics
        end
    end
    return true, relics
end

local function isInEra(eraInternalName)
    return player:GetAttribute("InEra") == eraInternalName
end

local function getEventTimeRemaining()
    local endsAt = Workspace:GetAttribute("EraTripEndsAt") or 0
    local now = Workspace:GetServerTimeNow()
    return math.max(0, endsAt - now)
end

local function craftMechaPizzone()
    if not network then return false end
    local ok, res = pcall(function()
        return network.InvokeServer("EraCraft", "FutureMythic")
    end)
    return ok and res
end

local function craftRomanMythic()
    if not network then return false end
    local ok, res = pcall(function()
        return network.InvokeServer("EraCraft", "RomanMythic")
    end)
    return ok and res
end

local function craftJurassicMythic()
    if not network then return false end
    local ok, res = pcall(function()
        return network.InvokeServer("EraCraft", "JurassicMythic")
    end)
    return ok and res
end

local function craftIceAgeMythic()
    if not network then return false end
    local ok, res = pcall(function()
        return network.InvokeServer("EraCraft", "IceAgeMythic")
    end)
    return ok and res
end

local function shootBlaster()
    if not network then return end
    pcall(function()
        network.FireServer("EraGameAction", "Shoot")
    end)
end

local function swingGladius(step)
    if not network then return end
    pcall(function()
        network.FireServer("EraGameAction", "Swing", step or 1)
    end)
end

local function equipGladius()
    local char = player.Character
    if not char then return end
    local gladius = char:FindFirstChild("Gladius")
    if not gladius and player.Backpack then
        gladius = player.Backpack:FindFirstChild("Gladius")
        if gladius then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:EquipTool(gladius)
            end
        end
    end
end

-- ================= TABS =================
local EraTripTab = Window:Tab({
    Title = "Auto EraTrip",
    Icon = "compass",
})

local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "settings",
})

local ScheduleTab = Window:Tab({
    Title = "Jadwal",
    Icon = "calendar",
})

local InventoryTab = Window:Tab({
    Title = "Inventaris",
    Icon = "package",
})

-- ================= CONFIG STATE =================
local autoEraTripEnabled = false
local autoEraTripRunning = false
local autoEraTripGeneration = 0  -- naik setiap ON/OFF → loop lama otomatis stop
local movementMode = "TP ⚡"
local craftedCount = 0

-- Selected Eras (Supports Multiple Selection)
local selectedEras = {
    ["The Future"]   = true,
    ["Ice Age"]      = true,
    ["Jurassic"]     = true,
    ["Roman Empire"] = true,
    ["80s Arcade"]   = true,
}

local function isEraSelected(eraInternalName)
    local displayName = ERA_DISPLAY_NAMES[eraInternalName]
    if displayName and selectedEras[displayName] then
        return true
    end
    return false
end

-- Status UI Element
local statusParagraph = EraTripTab:Paragraph({
    Title = "Status Event",
    Content = "Memuat status...",
})

-- ================= ROTASI TETAP PER JAM (HOURLY ROTATION) =================
-- Urutan tetap berputar setiap jam:
-- Jam 1: The Future | Jam 2: Roman Empire | Jam 3: Jurassic | Jam 4: Ice Age (berulang terus)
local HOURLY_ERA_ROTATION = { "Future", "Roman", "Jurassic", "IceAge" }

local function getEraForHour(hourNumber)
    -- hourNumber: 0..23 (jam dinding)
    local h = (hourNumber == 0) and 24 or hourNumber
    local idx = ((h - 1) % #HOURLY_ERA_ROTATION) + 1
    return HOURLY_ERA_ROTATION[idx]
end

-- Dedicated loop to update status: "Next event apa & berapa menit lagi" (Tiap 1 Jam / Hourly)
task.spawn(function()
    while true do
        pcall(function()
            if statusParagraph then
                local state = Workspace:GetAttribute("EraTripState") or "Closed"
                local curEra = Workspace:GetAttribute("EraTripEra") or "None"
                local endsAt = Workspace:GetAttribute("EraTripEndsAt") or Workspace:GetServerTimeNow()
                local now = Workspace:GetServerTimeNow()

                local dateNow = os.date("*t", now)
                local currentHour = dateNow.hour
                local currentMin = dateNow.min
                local currentSec = dateNow.sec

                -- Hitung sisa waktu hingga jam berikutnya
                local nextMins = 59 - currentMin
                local nextSecs = 60 - currentSec
                if nextSecs == 60 then
                    nextSecs = 0
                    nextMins = nextMins + 1
                end

                -- Jam event berikutnya & era sesuai urutan tetap
                local nextHour = (currentHour + 1) % 24
                local nextEraInternal = getEraForHour(nextHour)
                local nextEraName = ERA_DISPLAY_NAMES[nextEraInternal] or nextEraInternal
                local nextHourLabel = string.format("%02d:00", nextHour)

                if state == "Open" then
                    local remain = math.max(0, math.floor(endsAt - now))
                    local curDisplayName = ERA_DISPLAY_NAMES[curEra] or curEra
                    
                    statusParagraph:SetDesc(string.format(
                        "Event Aktif: %s (Sisa %02d:%02d)\nNext Event: %s jam %s (dalam %d menit)",
                        curDisplayName, math.floor(remain / 60), remain % 60, nextEraName, nextHourLabel, nextMins
                    ))
                elseif state == "Rolling" then
                    local curDisplayName = ERA_DISPLAY_NAMES[curEra] or curEra
                    statusParagraph:SetDesc(string.format(
                        "Sedang Rolling Event: %s...\nNext Event: %s jam %s",
                        curDisplayName, nextEraName, nextHourLabel
                    ))
                else
                    statusParagraph:SetDesc(string.format(
                        "Next Event: %s jam %s (%d menit %02d detik lagi)",
                        nextEraName, nextHourLabel, nextMins, nextSecs
                    ))
                end
            end
        end)
        task.wait(1)
    end
end)

-- ================= TAB: JADWAL (SCHEDULE 24 JAM) =================
-- ERA icon mapping untuk tampilan
local ERA_ICONS = {
    ["Future"]   = "🤖",
    ["IceAge"]   = "🧊",
    ["Jurassic"] = "🦕",
    ["Roman"]    = "⚔️",
    ["Eighties"] = "🕹️",
}

-- Paragraphs untuk jadwal
local scheduleHeaderParagraph = ScheduleTab:Paragraph({
    Title = "📅 Jadwal Event 24 Jam Ke Depan",
    Content = "Memuat jadwal...",
})

local scheduleListParagraph = ScheduleTab:Paragraph({
    Title = "Daftar Event",
    Content = "Menghitung...",
})

-- Build schedule string untuk 24 jam ke depan (tiap 1 jam rotasi tetap)
local function buildScheduleText()
    local now = Workspace:GetServerTimeNow()
    local state  = Workspace:GetAttribute("EraTripState") or "Closed"
    local curEra = Workspace:GetAttribute("EraTripEra") or ""
    local endsAt = Workspace:GetAttribute("EraTripEndsAt") or now
    
    local dateNow = os.date("*t", now)
    local currentHour = dateNow.hour
    local currentMin = dateNow.min
    local nextMins = 59 - currentMin
    
    local lines = {}
    
    -- Tampilkan event yang sedang berjalan jika aktif
    if state == "Open" and curEra ~= "" then
        local remain = math.max(0, math.floor(endsAt - now))
        local icon = ERA_ICONS[curEra] or "⭐"
        local displayName = ERA_DISPLAY_NAMES[curEra] or curEra
        local jamNow = string.format("%02d:%02d", currentHour, currentMin)
        table.insert(lines, string.format("▶ SEKARANG [%s] %s %s (sisa %dm %02ds)", jamNow, icon, displayName, math.floor(remain/60), remain%60))
        table.insert(lines, "----------------------------------------")
    else
        local nextHour = (currentHour + 1) % 24
        local nextEraInternal = getEraForHour(nextHour)
        local nextEraName = ERA_DISPLAY_NAMES[nextEraInternal] or nextEraInternal
        local jamNow = string.format("%02d:%02d", currentHour, currentMin)
        table.insert(lines, string.format("🕒 Waktu Sekarang: %s | Next: %s (%dm lagi)", jamNow, nextEraName, nextMins))
        table.insert(lines, "----------------------------------------")
    end
    
    -- Iterasi 24 jam ke depan per 1 jam urut berputar (Future -> Roman -> Jurassic -> IceAge)
    for i = 1, 24 do
        local h = (currentHour + i) % 24
        local eraInternal = getEraForHour(h)
        local icon = ERA_ICONS[eraInternal] or "⭐"
        local displayName = ERA_DISPLAY_NAMES[eraInternal] or eraInternal
        
        local timeLabel = string.format("Jam %02d:00", h)
        local diffMins = (i - 1) * 60 + nextMins
        local diffH = math.floor(diffMins / 60)
        local diffM = diffMins % 60
        
        local diffLabel = ""
        if diffH > 0 and diffM > 0 then
            diffLabel = string.format("(+%dj %02dm lagi)", diffH, diffM)
        elseif diffH > 0 then
            diffLabel = string.format("(+%dj lagi)", diffH)
        else
            diffLabel = string.format("(%dm lagi)", diffM)
        end
        
        table.insert(lines, string.format("  [%s] %s %-16s %s", timeLabel, icon, displayName, diffLabel))
    end
    
    return table.concat(lines, "\n")
end

-- Header paragraph: tampilkan waktu server sekarang
local function buildScheduleHeader()
    local now = Workspace:GetServerTimeNow()
    local state = Workspace:GetAttribute("EraTripState") or "Closed"
    local stateStr = (state == "Open" and "🟢 Event Aktif") or (state == "Rolling" and "🔄 Rolling...") or "⚫ Tutup"
    return string.format("Status: %s\nWaktu Server: %.0f", stateStr, now)
end

-- Update loop jadwal (setiap 5 detik)
task.spawn(function()
    while true do
        pcall(function()
            if scheduleHeaderParagraph then
                scheduleHeaderParagraph:SetDesc(buildScheduleHeader())
            end
            if scheduleListParagraph then
                scheduleListParagraph:SetDesc(buildScheduleText())
            end
        end)
        task.wait(5)
    end
end)

-- ================= TAB: INVENTARIS =================
-- Item label: key relic → nama tampilan (urutan: highest rarity dulu)
local ITEM_DISPLAY = {
    -- The Future
    { key = "Future5", label = "Quantum Chip",   era = "Future",   icon = "🤖", cost = 1  },
    { key = "Future4", label = "Plasma Core",    era = "Future",   icon = "🤖", cost = 7  },
    { key = "Future3", label = "Laser Goggles",  era = "Future",   icon = "🤖", cost = 14 },
    { key = "Future2", label = "Robot Scraps",   era = "Future",   icon = "🤖", cost = 25 },
    { key = "Future1", label = "Scrap Metal",    era = "Future",   icon = "🤖", cost = 45 },
    -- Roman Empire
    { key = "Roman5",  label = "Caesar Seal",    era = "Roman",    icon = "⚔️", cost = 1  },
    { key = "Roman4",  label = "Golden Eagle",   era = "Roman",    icon = "⚔️", cost = 7  },
    { key = "Roman3",  label = "Centurion Helm", era = "Roman",    icon = "⚔️", cost = 14 },
    { key = "Roman2",  label = "Laurel Wreath",  era = "Roman",    icon = "⚔️", cost = 25 },
    { key = "Roman1",  label = "Bronze Coin",    era = "Roman",    icon = "⚔️", cost = 45 },
    -- Jurassic
    { key = "Jurassic5", label = "Primal Egg",     era = "Jurassic", icon = "🦕", cost = 1  },
    { key = "Jurassic4", label = "Volcano Ember",  era = "Jurassic", icon = "🦕", cost = 7  },
    { key = "Jurassic3", label = "Fossil Skull",   era = "Jurassic", icon = "🦕", cost = 14 },
    { key = "Jurassic2", label = "Raptor Claw",    era = "Jurassic", icon = "🦕", cost = 25 },
    { key = "Jurassic1", label = "Amber Shard",    era = "Jurassic", icon = "🦕", cost = 45 },
    -- Ice Age
    { key = "IceAge5", label = "Mammoth Tusk",   era = "IceAge",   icon = "🧊", cost = 1  },
    { key = "IceAge4", label = "Frost Core",     era = "IceAge",   icon = "🧊", cost = 7  },
    { key = "IceAge3", label = "Glacial Tooth",  era = "IceAge",   icon = "🧊", cost = 14 },
    { key = "IceAge2", label = "Ice Shard",      era = "IceAge",   icon = "🧊", cost = 25 },
    { key = "IceAge1", label = "Frozen Pebble",  era = "IceAge",   icon = "🧊", cost = 45 },
    -- 80s Arcade (tidak ada craft mythic, tapi punya item sendiri)
    { key = "Eighties5", label = "Gold Record",    era = "Eighties", icon = "🕹️", cost = 1  },
    { key = "Eighties4", label = "Neon Sign",      era = "Eighties", icon = "🕹️", cost = 7  },
    { key = "Eighties3", label = "Cassette Tape",  era = "Eighties", icon = "🕹️", cost = 14 },
    { key = "Eighties2", label = "Arcade Token",   era = "Eighties", icon = "🕹️", cost = 25 },
    { key = "Eighties1", label = "Quarter Coin",   era = "Eighties", icon = "🕹️", cost = 45 },
}

-- Paragraphs per era untuk inventaris
local invFutureParagraph   = InventoryTab:Paragraph({ Title = "🤖 The Future",    Content = "Memuat..." })
local invRomanParagraph    = InventoryTab:Paragraph({ Title = "⚔️ Roman Empire",  Content = "Memuat..." })
local invJurassicParagraph = InventoryTab:Paragraph({ Title = "🦕 Jurassic",      Content = "Memuat..." })
local invIceAgeParagraph   = InventoryTab:Paragraph({ Title = "🧊 Ice Age",       Content = "Memuat..." })
local invEightiesParagraph = InventoryTab:Paragraph({ Title = "🕹️ 80s Arcade",   Content = "Memuat..." })
local invCraftParagraph    = InventoryTab:Paragraph({ Title = "⚒️ Bisa Craft Sekarang?", Content = "Mengecek..." })

local INV_PARAGRAPH = {
    Future   = invFutureParagraph,
    Roman    = invRomanParagraph,
    Jurassic = invJurassicParagraph,
    IceAge   = invIceAgeParagraph,
    Eighties = invEightiesParagraph,
}

local function buildInventoryLines(eraName)
    local relics = getAllRelics()
    local lines = {}
    for _, item in ipairs(ITEM_DISPLAY) do
        if item.era == eraName then
            local count = tonumber(relics[item.key]) or 0
            local needed = item.cost
            -- Craft readiness bar: berapa kali bisa craft dari item ini saja
            local craftable = math.floor(count / needed)
            local bar = ""
            if craftable >= 1 then
                bar = " ✅ x" .. craftable
            else
                -- Progress menuju 1 craft
                local pct = math.floor((count / needed) * 10)
                bar = " [" .. string.rep("█", pct) .. string.rep("░", 10 - pct) .. "]"
            end
            table.insert(lines, string.format("%-16s %3d / %-3d%s", item.label, count, needed, bar))
        end
    end
    return table.concat(lines, "\n")
end

local function buildCraftStatus()
    local relics = getAllRelics()
    local results = {}
    
    local function checkCraft(eraName, cost, mythicName)
        local canCraft = true
        for key, needed in pairs(cost) do
            local cur = tonumber(relics[key]) or 0
            if cur < needed then canCraft = false; break end
        end
        local icon = ERA_ICONS[eraName] or "⭐"
        local status = canCraft and "✅ BISA CRAFT" or "❌ Belum cukup"
        table.insert(results, string.format("%s %-15s %s", icon, mythicName, status))
    end
    
    checkCraft("Future",   FUTURE_MYTHIC_COST,   "Mecha Pizzone")
    checkCraft("Roman",    ROMAN_MYTHIC_COST,     "Cesarone Imper.")
    checkCraft("Jurassic", JURASSIC_MYTHIC_COST,  "T-Rexone Bracino")
    checkCraft("IceAge",   ICEAGE_MYTHIC_COST,    "Mammutone")
    
    -- 80s Arcade: tidak ada mythic craft, tampilkan Gold Record count saja
    local gr = tonumber(relics["Eighties5"]) or 0
    table.insert(results, string.format("🕹️ %-15s %d Gold Record (no craft)", "80s Arcade", gr))
    
    return table.concat(results, "\n")
end

-- Update loop inventaris (setiap 3 detik)
task.spawn(function()
    while true do
        pcall(function()
            for eraName, para in pairs(INV_PARAGRAPH) do
                if para then
                    para:SetDesc(buildInventoryLines(eraName))
                end
            end
            if invCraftParagraph then
                invCraftParagraph:SetDesc(buildCraftStatus())
            end
        end)
        task.wait(3)
    end
end)

EraTripTab:Toggle({
    Title = "Auto EraTrip",
    Desc = "Otomatis Ikut Event Terpilih & Jalankan Automasi",
    Value = false,
    Callback = function(state)
        autoEraTripEnabled = state
        if state then
            -- Naikkan generation → loop lama otomatis berhenti saat di-ON ulang
            autoEraTripGeneration = autoEraTripGeneration + 1
            local myGen = autoEraTripGeneration
            task.spawn(function()
                runAutoEraTrip(myGen)
            end)
        else
            -- Di-OFF → naikkan generation supaya semua loop aktif langsung stop
            autoEraTripGeneration = autoEraTripGeneration + 1
        end
    end,
})

EraTripTab:Dropdown({
    Title = "Pilih Event Era (Bisa Pilih Banyak)",
    Values = { "The Future", "Ice Age", "Jurassic", "Roman Empire", "80s Arcade" },
    Value = { "The Future", "Ice Age", "Roman Empire", "Jurassic", "80s Arcade" },
    Multi = true,
    Callback = function(selected)
        -- Reset all
        for k in pairs(selectedEras) do
            selectedEras[k] = false
        end
        
        -- Parse selection (handles array or dictionary)
        if typeof(selected) == "table" then
            for k, v in pairs(selected) do
                if typeof(k) == "string" and v == true then
                    selectedEras[k] = true
                elseif typeof(v) == "string" then
                    selectedEras[v] = true
                end
            end
        elseif typeof(selected) == "string" then
            selectedEras[selected] = true
        end
    end,
})

EraTripTab:Dropdown({
    Title = "Movement Mode",
    Values = { "TP ⚡", "Walk 🚶" },
    Value = "TP ⚡",
    Callback = function(option)
        movementMode = option
    end,
})

-- ================= TRADER & FINAL MINUTE CRAFT HELPERS =================
local function interactWithTrader(eraName)
    local eraTrip = Workspace:FindFirstChild("EraTrip")
    local curEra = eraName or Workspace:GetAttribute("EraTripEra") or player:GetAttribute("InEra")
    local eraModel = eraTrip and curEra and eraTrip:FindFirstChild(curEra)
    local trader = eraModel and eraModel:FindFirstChild("Trader")
    if not trader and eraTrip then
        trader = eraTrip:FindFirstChild("Trader", true)
    end
    
    if trader then
        local prompt = trader:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            pcall(function()
                fireproximityprompt(prompt)
            end)
            return true
        end
    end
    return false
end

local function closeCraftUI()
    local pGui = player:FindFirstChild("PlayerGui")
    local tradeGui = pGui and pGui:FindFirstChild("EraTradeGui")
    local craftWin = tradeGui and tradeGui:FindFirstChild("CraftWindow")
    if craftWin then
        for _, btn in ipairs(craftWin:GetDescendants()) do
            if btn:IsA("ImageButton") or btn:IsA("TextButton") then
                if btn.Name == "Close" or string.find(string.lower(btn.Name), "close") then
                    pcall(function()
                        firesignal(btn.Activated)
                    end)
                end
            end
        end
    end
end

local lastFinalMinuteCraftEndsAt = 0

local function checkFinalMinuteTraderCraft(eraName, mythicId, canCraftFn, traderCF, returnCF)
    local endsAt = Workspace:GetAttribute("EraTripEndsAt") or 0
    if endsAt == 0 or endsAt == lastFinalMinuteCraftEndsAt then
        return
    end
    
    local remain = getEventTimeRemaining()
    -- Menit ke-9: sisa waktu 65 detik atau kurang, tapi masih di atas 5 detik
    if remain <= 65 and remain > 5 then
        lastFinalMinuteCraftEndsAt = endsAt
        
        pcall(function()
            if statusParagraph then
                statusParagraph:SetDesc(string.format("Menit 9: Mampir dekat Trader (%s) & auto-craft remote...", eraName))
            end
        end)
        
        -- TP ke posisi dekat Trader agar valid jika server ada distance check
        safePivotTo(traderCF)
        task.wait(0.15)
        
        -- Langsung panggil Remote "EraCraft" tanpa buka UI sama sekali!
        local craftCount = 0
        while canCraftFn() and craftCount < 10 do
            craftCount = craftCount + 1
            local ok = false
            pcall(function()
                ok = network.InvokeServer("EraCraft", mythicId)
            end)
            if ok then
                craftedCount = craftedCount + 1
            end
            task.wait(0.2)
        end
        
        -- Langsung kembali ke KickReady untuk lanjut farming
        safePivotTo(returnCF)
        task.wait(0.2)
    end
end

-- ================= FUTURE ERA SCANNING =================

-- Ambil semua SciCrate di arena yang belum diambil
-- Prioritas: Urutkan berdasarkan Rarity Tertinggi (Tier 5 Mythic > Tier 4 > Tier 3 > Tier 2 > Tier 1)
local function getSciCrates()
    local crates = {}
    
    local eraTrip = Workspace:FindFirstChild("EraTrip")
    local future = eraTrip and eraTrip:FindFirstChild("Future")
    local arena = future and future:FindFirstChild("RobotArena")
    local cratesFolder = arena and arena:FindFirstChild("Crates")
    
    if cratesFolder then
        for _, child in ipairs(cratesFolder:GetChildren()) do
            if child.Name == "SciCrate" and child:IsA("Model") and child.Parent == cratesFolder then
                table.insert(crates, child)
            end
        end
    end
    
    -- Fallback: cek Workspace jika ada crate yang belum dipungut
    for _, child in ipairs(Workspace:GetChildren()) do
        if child.Name == "SciCrate" and child:IsA("Model") and child.Name ~= "CarriedCrate" then
            local pos = child:GetPivot().Position
            -- Pastikan bukan model yang melayang di atas kepala
            if pos.Y < 15 and not table.find(crates, child) then
                table.insert(crates, child)
            end
        end
    end
    
    -- PRIORITAS UTAMA: Rarity tertinggi lebih dulu (Tier 5 > 4 > 3 > 2 > 1)
    -- Jika tier sama, ambil yang posisinya paling jauh (Zone 5 = X paling kecil)
    table.sort(crates, function(a, b)
        local tierA = a:GetAttribute("Tier") or 1
        local tierB = b:GetAttribute("Tier") or 1
        if tierA ~= tierB then
            return tierA > tierB
        end
        return a:GetPivot().Position.X < b:GetPivot().Position.X
    end)
    
    return crates
end

local function getRobotsInZone(zone)
    local robots = {}
    
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") and FUTURE_ROBOT_NAMES[child.Name] then
            local root = child:FindFirstChild("RootPart") or child.PrimaryPart
            if root then
                local x = root.Position.X
                if x >= zone.MinX and x <= zone.MaxX then
                    table.insert(robots, child)
                end
            end
        end
    end
    
    local eraTrip = Workspace:FindFirstChild("EraTrip")
    local future = eraTrip and eraTrip:FindFirstChild("Future")
    local chasers = future and future:FindFirstChild("Chasers")
    if chasers then
        for _, child in ipairs(chasers:GetChildren()) do
            if child:IsA("Model") and FUTURE_ROBOT_NAMES[child.Name] then
                local root = child:FindFirstChild("RootPart") or child.PrimaryPart
                if root then
                    local x = root.Position.X
                    if x >= zone.MinX and x <= zone.MaxX then
                        if not table.find(robots, child) then
                            table.insert(robots, child)
                        end
                    end
                end
            end
        end
    end
    
    return robots
end

local function collectFutureCrates(checkLimit, getCarryCount)
    local collectedAny = false
    local crates = getSciCrates() -- Sudah di-sort prioritas rarity tertinggi
    local targetCap = getFutureCarryCapacity()
    local readCarry = getCarryCount or getFutureCarriedCount

    for _, crate in ipairs(crates) do
        if not autoEraTripEnabled or not isInEra("Future") then break end

        local curCount = readCarry()
        if checkLimit and curCount >= targetCap then
            break
        end

        if not crate.Parent then continue end

        local cratePos = crate:GetPivot().Position
        safePivotTo(CFrame.new(cratePos.X, cratePos.Y + 1.2, cratePos.Z))

        local _, myRoot = getCharacterParts()
        if myRoot then
            myRoot.AssemblyLinearVelocity = Vector3.zero
        end

        -- Tunggu konfirmasi pickup, bukan menganggap berhasil hanya karena
        -- karakter sudah teleport ke posisi crate.
        local deadline = os.clock() + 0.35
        local pickedUp = false
        while os.clock() < deadline do
            local newCount = readCarry()
            if newCount > curCount or not crate.Parent then
                pickedUp = true
                break
            end
            if checkLimit and newCount >= targetCap then
                pickedUp = true
                break
            end
            task.wait(0.03)
        end

        if pickedUp then
            collectedAny = true
        end

        if checkLimit and readCarry() >= targetCap then
            break
        end
    end

    return collectedAny
end

-- Satu jalur setor Future. Prompt diaktifkan bila tersedia; timeout tetap
-- membatasi waktu agar karakter tidak tertahan di EraCollect.
local function depositFuture()
    safePivotTo(FUTURE_COLLECT_CF)
    task.wait(0.2)

    local eraTrip = Workspace:FindFirstChild("EraTrip")
    local future = eraTrip and eraTrip:FindFirstChild("Future")
    local collectPart = future and future:FindFirstChild("EraCollect")
    local prompt = collectPart and collectPart:FindFirstChildWhichIsA("ProximityPrompt", true)

    if prompt and prompt.Enabled then
        pcall(function() fireproximityprompt(prompt) end)
    end

    local deadline = os.clock() + 2.5
    while getFutureCarriedCount() > 0 and os.clock() < deadline do
        task.wait(0.1)
    end

    -- Retry prompt satu kali jika server belum mengosongkan carry.
    if getFutureCarriedCount() > 0 and prompt and prompt.Parent and prompt.Enabled then
        pcall(function() fireproximityprompt(prompt) end)
        local retryDeadline = os.clock() + 1.5
        while getFutureCarriedCount() > 0 and os.clock() < retryDeadline do
            task.wait(0.1)
        end
    end

    local remaining = getFutureCarriedCount()
    safePivotTo(FUTURE_KICK_READY_CF)
    task.wait(0.25)
    return remaining
end


-- ================= MAIN FUTURE ROUTINE =================
local function handleFutureEra()
    local initializedAtKickReady = false
    local carryOffset = 0

    local function getEffectiveCarryCount()
        local rawCount = getFutureCarriedCount()

        -- Jika carry lama tidak di-clear oleh HUD/replication, abaikan baseline
        -- itu. Kenaikan berikutnya tetap dihitung sebagai crate baru.
        if carryOffset > 0 then
            if rawCount < carryOffset then
                carryOffset = 0
                return rawCount
            end
            return rawCount - carryOffset
        end

        return rawCount
    end

    local function depositAndResume()
        local remaining = depositFuture()
        if remaining > 0 then
            -- Jangan ulangi deposit untuk carry lama yang tidak berubah.
            carryOffset = remaining
        else
            carryOffset = 0
        end
    end

    while autoEraTripEnabled and isInEra("Future")
        and Workspace:GetAttribute("EraTripState") == "Open" do

        if not initializedAtKickReady then
            safePivotTo(FUTURE_KICK_READY_CF)
            task.wait(0.35)
            initializedAtKickReady = true
        end

        local carried = getEffectiveCarryCount()
        local targetCap = getFutureCarryCapacity()

        -- Hanya setor jika ada crate baru yang benar-benar terhitung penuh.
        if carried > 0 and carried >= targetCap then
            depositAndResume()
            continue
        end

        -- Looting dari Zone 5 ke Zone 1.
        for _, zone in ipairs(FUTURE_ZONES) do
            if not autoEraTripEnabled or not isInEra("Future")
                or Workspace:GetAttribute("EraTripState") ~= "Open" then
                break
            end

            if getEffectiveCarryCount() >= targetCap then
                break
            end

            local zoneTimeout = os.clock() + 20
            while autoEraTripEnabled and isInEra("Future")
                and Workspace:GetAttribute("EraTripState") == "Open"
                and os.clock() < zoneTimeout do

                if getEffectiveCarryCount() >= targetCap then
                    break
                end

                collectFutureCrates(true, getEffectiveCarryCount)
                if getEffectiveCarryCount() >= targetCap then
                    break
                end

                local robots = getRobotsInZone(zone)
                if #robots == 0 then
                    break
                end

                local targetRobot = robots[1]
                local root = targetRobot:FindFirstChild("RootPart") or targetRobot.PrimaryPart

                if root and targetRobot.Parent then
                    local robotPos = root.Position
                    local safeCF = CFrame.lookAt(
                        Vector3.new(robotPos.X, robotPos.Y + 15, robotPos.Z + 16),
                        robotPos
                    )
                    safePivotTo(safeCF)

                    local _, initRoot = getCharacterParts()
                    if initRoot then
                        initRoot.AssemblyLinearVelocity = Vector3.zero
                    end

                    for _ = 1, 6 do
                        if not autoEraTripEnabled or not targetRobot.Parent
                            or getEffectiveCarryCount() >= targetCap then
                            break
                        end

                        local curRoot = targetRobot:FindFirstChild("RootPart") or targetRobot.PrimaryPart
                        if curRoot then
                            local rPos = curRoot.Position
                            local hoverCF = CFrame.lookAt(
                                Vector3.new(rPos.X, rPos.Y + 15, rPos.Z + 16),
                                rPos
                            )
                            safePivotTo(hoverCF)

                            local _, myRoot = getCharacterParts()
                            if myRoot then
                                myRoot.AssemblyLinearVelocity = Vector3.zero
                            end
                        end

                        shootBlaster()
                        task.wait(0.12)
                    end

                    collectFutureCrates(true, getEffectiveCarryCount)
                else
                    task.wait(0.1)
                end
            end

            collectFutureCrates(true, getEffectiveCarryCount)
            task.wait(0.15)

            if getEffectiveCarryCount() >= targetCap then
                break
            end
        end

        -- Ambil sisa crate yang tersedia, lalu setor hanya jika ada hasil.
        collectFutureCrates(true, getEffectiveCarryCount)

        local finalCarry = getEffectiveCarryCount()
        if finalCarry > 0 then
            depositAndResume()
        end

        checkFinalMinuteTraderCraft(
            "Future", "FutureMythic", canCraftMechaPizzone,
            FUTURE_TRADER_CF, FUTURE_KICK_READY_CF
        )

        task.wait(0.25)
    end
end


-- ================= ROMAN ERA SCANNING & AUTOMATION =================
local function getRomanGuards()
    local guards = {}
    local eraTrip = Workspace:FindFirstChild("EraTrip")
    local roman = eraTrip and (eraTrip:FindFirstChild("Roman") or eraTrip)
    if not roman then return guards end
    
    -- Cari folder Chasers (bisa langsung di bawah Roman atau di dalam VaultRaid)
    local chasersFolder = roman:FindFirstChild("Chasers", true)
    if chasersFolder then
        for _, child in ipairs(chasersFolder:GetChildren()) do
            local isDead = child:GetAttribute("Dead") == true
            local hp = child:GetAttribute("HP")
            local isAlive = not isDead and (hp == nil or hp > 0)
            if isAlive then
                table.insert(guards, child)
            end
        end
    end
    
    -- Fallback: cari model / basepart yang punya atribut MaxHP di area Roman
    if #guards == 0 then
        for _, desc in ipairs(roman:GetDescendants()) do
            if desc:IsA("Model") or desc:IsA("BasePart") then
                local maxHP = desc:GetAttribute("MaxHP")
                local hp = desc:GetAttribute("HP")
                local isDead = desc:GetAttribute("Dead") == true
                if maxHP and not isDead and (hp == nil or hp > 0) then
                    table.insert(guards, desc)
                end
            end
        end
    end
    
    -- Urutkan prioritas: Rarity Tertinggi (Tier 5 Boss -> 1) atau posisi paling dalam (Zone 5 = X paling kecil)
    table.sort(guards, function(a, b)
        local tierA = a:GetAttribute("Tier") or 1
        local tierB = b:GetAttribute("Tier") or 1
        if tierA ~= tierB then
            return tierA > tierB
        end
        local posA = a:IsA("BasePart") and a.Position or a:GetPivot().Position
        local posB = b:IsA("BasePart") and b.Position or b:GetPivot().Position
        return posA.X < posB.X
    end)
    
    return guards
end

local function getVaultChests(zoneIndex)
    local chests = {}
    local eraTrip = Workspace:FindFirstChild("EraTrip")
    local roman = eraTrip and (eraTrip:FindFirstChild("Roman") or eraTrip)
    local vaultRaid = roman and (roman:FindFirstChild("VaultRaid", true) or roman)
    if vaultRaid then
        for _, child in ipairs(vaultRaid:GetDescendants()) do
            if child.Name == "VaultChest" then
                local tier = child:GetAttribute("Tier")
                if zoneIndex == nil or tier == zoneIndex then
                    table.insert(chests, child)
                end
            end
        end
    end
    -- Prioritas Rarity Tertinggi (Tier 5 Mythic > 4 > 3 > 2 > 1)
    table.sort(chests, function(a, b)
        local tierA = a:GetAttribute("Tier") or 1
        local tierB = b:GetAttribute("Tier") or 1
        if tierA ~= tierB then
            return tierA > tierB
        end
        return a:GetPivot().Position.X < b:GetPivot().Position.X
    end)
    return chests
end

local function getReadyChests()
    local allChests = getVaultChests()
    local ready = {}
    for _, chest in ipairs(allChests) do
        local isReady = chest:GetAttribute("Ready") == true
        local prompt = chest:FindFirstChild("ChestBody") and chest.ChestBody:FindFirstChild("OpenChest")
        if (isReady or (prompt and prompt.Enabled)) and chest.Parent then
            table.insert(ready, { chest = chest, prompt = prompt })
        end
    end
    return ready
end

local function collectDroppedLoot()
    local eraTrip = Workspace:FindFirstChild("EraTrip")
    local roman = eraTrip and (eraTrip:FindFirstChild("Roman") or eraTrip)
    if not roman then return false end
    
    local collected = false
    for _, child in ipairs(roman:GetDescendants()) do
        if child.Name == "DroppedLoot" and child:FindFirstChild("Base") then
            local prompt = child.Base:FindFirstChild("SwapLoot")
            if prompt and getCarriedCratesCount() < 5 then
                safePivotTo(CFrame.new(child.Base.Position) * CFrame.new(0, 2, 0))
                task.wait(0.15)
                pcall(function() fireproximityprompt(prompt) end)
                task.wait(0.35)
                collected = true
            end
        end
    end
    return collected
end

local function fightGuard(guard)
    equipGladius()
    
    local timeout = os.clock() + 10
    while autoEraTripEnabled and isInEra("Roman") and guard.Parent and os.clock() < timeout do
        local isDead = guard:GetAttribute("Dead") == true
        local hp = guard:GetAttribute("HP")
        local isAlive = not isDead and (hp == nil or hp > 0)
        if not isAlive then break end
        
        local guardPos = guard:IsA("BasePart") and guard.Position or guard:GetPivot().Position
        local guardCF = guard:IsA("BasePart") and guard.CFrame or guard:GetPivot()
        
        -- POSISI AMAN: TEPAT DI BELAKANG GUARD (-3.5 studs) dan SEDIKIT DI ATAS (+4.5 studs)
        local safeCF = CFrame.new(guardPos - (guardCF.LookVector * 3.5) + Vector3.new(0, 4.5, 0), guardPos)
        safePivotTo(safeCF)
        
        local _, rootPart = getCharacterParts()
        if rootPart then
            rootPart.AssemblyLinearVelocity = Vector3.zero
        end
        
        -- SUPER SPAM SWING: Kirim burst remote serangan combo (1 -> 2 -> 3) bertubi-tubi tanpa delay!
        for _ = 1, 3 do
            network.FireServer("EraGameAction", "Swing", 1)
            network.FireServer("EraGameAction", "Swing", 2)
            network.FireServer("EraGameAction", "Swing", 3)
        end
        
        -- Trigger activate Gladius juga
        local char = player.Character
        local tool = char and char:FindFirstChild("Gladius")
        if tool and tool:IsA("Tool") then
            pcall(function() tool:Activate() end)
        end
        
        task.wait(0.03)
    end
end

local function depositRoman()
    -- 1. TP ke EraCollect untuk setor peti
    safePivotTo(ROMAN_COLLECT_CF)
    local depositStart = os.clock()
    while getCarriedCratesCount() > 0 and os.clock() - depositStart < 2.5 do
        task.wait(0.2)
    end
    task.wait(0.2)
    
    -- 2. Langsung kembali ke EraKickReady
    safePivotTo(ROMAN_KICK_READY_CF)
    task.wait(0.3)
end

-- ================= MAIN ROMAN ROUTINE =================
local function handleRomanEra()
    -- TP sekali di awal masuk Roman
    safePivotTo(ROMAN_KICK_READY_CF)
    task.wait(0.5)
    
    local isWaitingAtKickReady = false

    while autoEraTripEnabled and isInEra("Roman") and Workspace:GetAttribute("EraTripState") == "Open" do
        -- 1. Jika tas penuh (>= 5), langsung setor ke EraCollect
        if getCarriedCratesCount() >= 5 then
            depositRoman()
            isWaitingAtKickReady = false
        end

        -- 2. Ambil DroppedLoot yang ada di tanah
        collectDroppedLoot()
        if getCarriedCratesCount() >= 5 then
            depositRoman()
            isWaitingAtKickReady = false
        end

        -- 3. Cari dan buka Chest yang sudah Ready (Prioritas Tier 5 Mythic -> 1)
        local readyChests = getReadyChests()
        if #readyChests > 0 and getCarriedCratesCount() < 5 then
            isWaitingAtKickReady = false
            for _, item in ipairs(readyChests) do
                if not autoEraTripEnabled or not isInEra("Roman") or getCarriedCratesCount() >= 5 then break end
                local chest = item.chest
                local prompt = item.prompt or (chest:FindFirstChild("ChestBody") and chest.ChestBody:FindFirstChild("OpenChest"))
                if chest.Parent and (chest:GetAttribute("Ready") == true or (prompt and prompt.Enabled)) then
                    local pos = chest:GetPivot().Position
                    safePivotTo(CFrame.new(pos.X, pos.Y + 2, pos.Z))
                    task.wait(0.15)
                    if prompt then
                        pcall(function() fireproximityprompt(prompt) end)
                    end
                    task.wait(0.5)
                    collectDroppedLoot()
                end
            end

            if getCarriedCratesCount() >= 5 then
                depositRoman()
            end
        end

        -- 4. Cari Guard yang masih hidup (Prioritas Tier 5 Boss -> 1)
        local guards = getRomanGuards()
        if #guards > 0 and getCarriedCratesCount() < 5 then
            isWaitingAtKickReady = false
            local targetGuard = guards[1]
            local targetName = targetGuard:GetAttribute("Model") or targetGuard.Name
            statusParagraph:SetDesc("Roman: Melawan Guard " .. tostring(targetName) .. "...")
            fightGuard(targetGuard)
            task.wait(0.2)

            -- Buka chest dan ambil loot yang baru saja dibuka dari guard ini
            collectDroppedLoot()
            local afterChests = getReadyChests()
            for _, item in ipairs(afterChests) do
                if getCarriedCratesCount() >= 5 then break end
                local chest = item.chest
                local prompt = item.prompt
                if chest.Parent and (chest:GetAttribute("Ready") == true or (prompt and prompt.Enabled)) then
                    safePivotTo(CFrame.new(chest:GetPivot().Position) * CFrame.new(0, 2, 0))
                    task.wait(0.15)
                    if prompt then pcall(function() fireproximityprompt(prompt) end) end
                    task.wait(0.5)
                    collectDroppedLoot()
                end
            end

            if getCarriedCratesCount() >= 5 then
                depositRoman()
            end
        end

        -- 5. Jika tidak ada lagi guard hidup & tidak ada chest ready, tapi masih membawa peti (>0), setor ke EraCollect
        if #guards == 0 and #readyChests == 0 and getCarriedCratesCount() > 0 then
            depositRoman()
            isWaitingAtKickReady = false
        end

        -- 6. Mampir ke Trader HANYA di menit ke-9 (sisa <= 65s)
        checkFinalMinuteTraderCraft("Roman", "RomanMythic", canCraftRomanMythic, ROMAN_TRADER_CF, ROMAN_KICK_READY_CF)

        -- 7. Jika arena bersih (guard kalah semua & chest habis), tunggu wave berikutnya di EraKickReady
        -- PENTING: Hanya TP sekali saat masuk mode tunggu agar tidak terjadi loop-teleport yang stuttering!
        if #guards == 0 and #readyChests == 0 and getCarriedCratesCount() == 0 then
            statusParagraph:SetDesc("Roman: Menunggu wave guard / chest berikutnya...")
            if not isWaitingAtKickReady then
                safePivotTo(ROMAN_KICK_READY_CF)
                isWaitingAtKickReady = true
            end
            task.wait(1.0)
        else
            isWaitingAtKickReady = false
            task.wait(0.2)
        end
    end

    statusParagraph:SetDesc("Roman selesai.")
end

-- ================= JURASSIC ERA SCANNING & AUTOMATION =================
local function getJurassicNests()
    local nests = {}
    local eraTrip = Workspace:FindFirstChild("EraTrip")
    local jurassic = eraTrip and eraTrip:FindFirstChild("Jurassic")
    local eggHeist = jurassic and jurassic:FindFirstChild("EggHeist")
    
    if eggHeist then
        for _, child in ipairs(eggHeist:GetChildren()) do
            if child.Name == "Nest" and child:IsA("Model") then
                table.insert(nests, child)
            end
        end
    end
    
    -- PRIORITAS UTAMA: Rarity Tertinggi (Tier 5 Mythic > Tier 4 > Tier 3 > Tier 2 > Tier 1)
    table.sort(nests, function(a, b)
        local tierA = a:GetAttribute("Tier") or 1
        local tierB = b:GetAttribute("Tier") or 1
        if tierA ~= tierB then
            return tierA > tierB
        end
        return a:GetPivot().Position.X < b:GetPivot().Position.X
    end)
    
    return nests
end

local function getActiveEggsInNest(nest)
    local eggs = {}
    for _, child in ipairs(nest:GetChildren()) do
        if child.Name == "Egg" and child:IsA("Model") then
            local prompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and prompt.Parent then
                table.insert(eggs, { Model = child, Prompt = prompt })
            end
        end
    end
    return eggs
end

local function depositJurassic()
    -- 1. TP ke EraCollect untuk menetaskan telur
    local eraTrip = Workspace:FindFirstChild("EraTrip")
    local jurassic = eraTrip and eraTrip:FindFirstChild("Jurassic")
    local collectPart = jurassic and jurassic:FindFirstChild("EraCollect", true)
    local targetCF = (collectPart and collectPart:IsA("BasePart")) and collectPart.CFrame or JURASSIC_COLLECT_CF

    safePivotTo(targetCF)
    local _, myRoot = getCharacterParts()
    if myRoot then myRoot.AssemblyLinearVelocity = Vector3.zero end

    -- Trigger ProximityPrompt jika ada pada part EraCollect
    if collectPart then
        local prompt = collectPart:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then pcall(function() fireproximityprompt(prompt) end) end
    end

    local depositStart = os.clock()
    while getCarriedEggsCount() > 0 and (os.clock() - depositStart) < 3.0 do
        task.wait(0.15)
        if collectPart then
            local prompt = collectPart:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then pcall(function() fireproximityprompt(prompt) end) end
        end
    end

    task.wait(0.2)
    -- Setelah setor di EraCollect, WAJIB kembali ke KickReady agar siap melooping berikutnya!
    safePivotTo(JURASSIC_KICK_READY_CF)
    local _, r = getCharacterParts()
    if r then r.AssemblyLinearVelocity = Vector3.zero end
    task.wait(0.3)
end

-- ================= ICEAGE ERA SCANNING & AUTOMATION =================

-- Ambil semua IceShard yang belum diambil (Taken == false), sort berdasarkan Tier tertinggi
local function getIceShards()
    local shards = {}
    local eraTrip = Workspace:FindFirstChild("EraTrip")
    local iceAge = eraTrip and eraTrip:FindFirstChild("IceAge")
    local iceBrainrots = iceAge and iceAge:FindFirstChild("IceBrainrots")
    if iceBrainrots then
        for _, part in ipairs(iceBrainrots:GetChildren()) do
            if part:IsA("BasePart") and not part:GetAttribute("Taken") then
                table.insert(shards, {obj = part, tier = part:GetAttribute("Tier") or 1})
            end
        end
    end
    -- sort: tier tertinggi dulu (Tier 5 Mythic → 1 Common)
    table.sort(shards, function(a, b) return (a.tier or 1) > (b.tier or 1) end)
    return shards
end

-- Hitung shard yang sedang dibawa via EraCarry attribute
local function getCarriedShardsCount()
    local carry = player:GetAttribute("EraCarry")
    local count = 0
    if typeof(carry) == "string" and carry ~= "" then
        for _ in string.gmatch(carry, "[^,]+") do count = count + 1 end
    elseif typeof(carry) == "number" then
        count = carry
    end
    return count
end

-- ================= MAIN ICEAGE ROUTINE =================
local function equipTorch()
    local char = player.Character
    if not char then return end
    local torch = char:FindFirstChild("Torch")
    if not torch and player.Backpack then
        torch = player.Backpack:FindFirstChild("Torch")
        if torch then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:EquipTool(torch) end
        end
    end
end

local function handleIceAgeEra()
    equipTorch()

    while autoEraTripEnabled and isInEra("IceAge") and Workspace:GetAttribute("EraTripState") == "Open" do
        equipTorch()

        -- 1. Jika sudah bawa shard, langsung setor ke EraCollect dulu
        if getCarriedShardsCount() > 0 then
            safePivotTo(ICEAGE_COLLECT_CF)
            local eraTrip = Workspace:FindFirstChild("EraTrip")
            local iceAge = eraTrip and eraTrip:FindFirstChild("IceAge")
            local collectPart = iceAge and iceAge:FindFirstChild("EraCollect")
            local prompt = collectPart and collectPart:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then pcall(function() fireproximityprompt(prompt) end) end

            local depositStart = os.clock()
            while getCarriedShardsCount() > 0 and os.clock() - depositStart < 2.5 do
                task.wait(0.15)
            end
            task.wait(0.2)
        end

        -- 2. Ambil semua shard di arena, sudah terurut dari Tier 5 (Mythic) -> Tier 1
        local shards = getIceShards()

        if #shards > 0 then
            -- Langsung pilih shard dengan rarity TERTINGGI
            local targetShard = shards[1].obj
            if targetShard and targetShard.Parent and not targetShard:GetAttribute("Taken") then
                local shardPos = targetShard.Position

                -- TP LANGSUNG KE SHARD TERTINGGI
                safePivotTo(CFrame.new(shardPos.X, shardPos.Y + 1.2, shardPos.Z))
                
                -- Tunggu 1 detik agar es meleleh terkena torch sebelum mengambil
                task.wait(1.0)

                -- Cari dan trigger ProximityPrompt untuk mengambil shard (yang muncul setelah es meleleh)
                local shardPrompt = nil
                local findDeadline = os.clock() + 1.0
                while os.clock() < findDeadline and not shardPrompt do
                    shardPrompt = targetShard:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if not shardPrompt and targetShard.Parent then
                        shardPrompt = targetShard.Parent:FindFirstChildWhichIsA("ProximityPrompt", true)
                    end
                    if not shardPrompt then
                        local eraTrip = Workspace:FindFirstChild("EraTrip")
                        local iceAge = eraTrip and eraTrip:FindFirstChild("IceAge")
                        local searchRoot = iceAge or Workspace
                        for _, desc in ipairs(searchRoot:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") and desc.Parent and desc.Parent:IsA("BasePart") then
                                if (desc.Parent.Position - shardPos).Magnitude < 12 then
                                    shardPrompt = desc
                                    break
                                end
                            end
                        end
                    end
                    if shardPrompt then break end
                    task.wait(0.1)
                end

                if shardPrompt then
                    pcall(function()
                        fireproximityprompt(shardPrompt)
                    end)
                    local holdTime = shardPrompt.HoldDuration or 0.5
                    task.wait(math.max(0.2, holdTime + 0.1))
                end

                -- Tunggu konfirmasi shard terambil (Taken == true atau EraCarry bertambah)
                local deadline = os.clock() + 1.5
                while os.clock() < deadline and not targetShard:GetAttribute("Taken") and getCarriedShardsCount() == 0 do
                    task.wait(0.1)
                end

                -- Setelah shard benar-benar terambil, mampir ke titik tengah
                -- antara posisi shard dan EraCollect sebelum melakukan deposit.
                local shardPickedUp = targetShard:GetAttribute("Taken") == true
                    or getCarriedShardsCount() > 0

                if shardPickedUp then
                    -- Total waktu sejak shard terkonfirmasi terambil hingga tiba di EraCollect: 2 detik.
                    local pickupConfirmedAt = os.clock()
                    local midpointPos = shardPos:Lerp(ICEAGE_COLLECT_CF.Position, 0.5)
                    safePivotTo(CFrame.new(midpointPos.X, midpointPos.Y + 2, midpointPos.Z))

                    local remainingTravelTime = 2 - (os.clock() - pickupConfirmedAt)
                    if remainingTravelTime > 0 then
                        task.wait(remainingTravelTime)
                    end

                    safePivotTo(ICEAGE_COLLECT_CF)
                    local eraTrip = Workspace:FindFirstChild("EraTrip")
                    local iceAge = eraTrip and eraTrip:FindFirstChild("IceAge")
                    local collectPart = iceAge and iceAge:FindFirstChild("EraCollect")
                    local prompt = collectPart and collectPart:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then pcall(function() fireproximityprompt(prompt) end) end

                    local depositDeadline = os.clock() + 2.5
                    while getCarriedShardsCount() > 0 and os.clock() < depositDeadline do
                        task.wait(0.15)
                    end
                    task.wait(0.2)
                end
            end
        else
            -- Jika belum ada shard yang muncul, tunggu sebentar di EraKickReady
            safePivotTo(ICEAGE_KICK_READY_CF)
            task.wait(0.5)
        end

        -- Mampir ke Trader HANYA di menit ke-9 (sisa <= 65s) selama 1 detik untuk borong craft
        checkFinalMinuteTraderCraft("IceAge", "IceAgeMythic", canCraftIceAgeMythic, ICEAGE_TRADER_CF, ICEAGE_KICK_READY_CF)

        task.wait(0.15)
    end

    statusParagraph:SetDesc("IceAge selesai.")
end

-- ================= MAIN JURASSIC ROUTINE =================
local function handleJurassicEra()
    -- Helper: tunggu sampai Chaser berjarak aman dari target posisi
    local function waitForChaserSafe(targetPos, safeDist)
        local eraTripFolder = Workspace:FindFirstChild("EraTrip")
        local jurassicFolder = eraTripFolder and eraTripFolder:FindFirstChild("Jurassic")
        local chaser = jurassicFolder and jurassicFolder:FindFirstChild("Chaser")
        if not chaser then return true end
        local maxWait = 6  -- seconds, hindari freeze lama
        local start = os.clock()
        while os.clock() - start < maxWait do
            local chaserPos = chaser:GetPivot().Position
            local dist = (targetPos - chaserPos).Magnitude
            if dist >= safeDist then return true end
            -- Jika terlalu dekat dengan Chaser, mundur sementara ke KickReady
            safePivotTo(JURASSIC_KICK_READY_CF)
            local _, myRoot = getCharacterParts()
            if myRoot then myRoot.AssemblyLinearVelocity = Vector3.zero end
            task.wait(0.4)
        end
        return false
    end

    -- Inisialisasi: teleport ke KickReady
    safePivotTo(JURASSIC_KICK_READY_CF)
    local _, initRoot = getCharacterParts()
    if initRoot then initRoot.AssemblyLinearVelocity = Vector3.zero end
    task.wait(0.4)

    local maxCap = 1  -- Ambil 1 telur langsung setor ke EraCollect
    local CHASER_SAFE_DIST = 20  -- jarak aman minimal (studs)

    while autoEraTripEnabled and isInEra("Jurassic") and Workspace:GetAttribute("EraTripState") == "Open" do
        -- 1. Jika masih ada telur yang terbawa, langsung setor ke EraCollect & balik ke KickReady
        if getCarriedEggsCount() > 0 then
            depositJurassic()
        end

        local nests = getJurassicNests()
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        -- Cari sarang yang memiliki telur aktif (prompt StealEgg yang Enabled)
        local availableNests = {}
        for _, nest in ipairs(nests) do
            local hasActiveEgg = false
            for _, desc in ipairs(nest:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Enabled and (desc.Name == "StealEgg" or desc.ActionText == "Steal" or desc.ObjectText == "Egg") then
                    hasActiveEgg = true
                    break
                end
            end
            if hasActiveEgg then
                table.insert(availableNests, nest)
            end
        end

        -- Jika seluruh telur di arena sedang kosong/cooldown respawn:
        if #availableNests == 0 then
            -- Tunggu sebentar di KickReady secara aman lalu rescan loop
            safePivotTo(JURASSIC_KICK_READY_CF)
            local _, myRoot = getCharacterParts()
            if myRoot then myRoot.AssemblyLinearVelocity = Vector3.zero end
            task.wait(1.5)
            continue
        end

        -- Prioritas sarang: Tier tertinggi duluan (Tier 5 Mythic > 4 > 3 > 2 > 1)
        table.sort(availableNests, function(a, b)
            local tierA = a:GetAttribute("Tier") or 1
            local tierB = b:GetAttribute("Tier") or 1
            if tierA ~= tierB then
                return tierA > tierB
            end

            if rootPart then
                return (a:GetPivot().Position - rootPart.Position).Magnitude <
                       (b:GetPivot().Position - rootPart.Position).Magnitude
            end
            return a.Name < b.Name
        end)

        local safeNests = {}
        local unsafeNests = {}
        local eraTripFolder = Workspace:FindFirstChild("EraTrip")
        local jurassicFolder = eraTripFolder and eraTripFolder:FindFirstChild("Jurassic")
        local chaser = jurassicFolder and jurassicFolder:FindFirstChild("Chaser")

        for _, nest in ipairs(availableNests) do
            local distToChaser = chaser and
                (nest:GetPivot().Position - chaser:GetPivot().Position).Magnitude or math.huge

            if distToChaser >= CHASER_SAFE_DIST then
                table.insert(safeNests, nest)
            else
                table.insert(unsafeNests, {obj = nest, dist = distToChaser})
            end
        end

        local processingList = {}
        if #safeNests > 0 then
            processingList = safeNests
        else
            table.sort(unsafeNests, function(a, b) return a.dist > b.dist end)
            for _, item in ipairs(unsafeNests) do
                table.insert(processingList, item.obj)
            end
        end

        local eggDeposited = false
        for _, nest in ipairs(processingList) do
            if not autoEraTripEnabled or not isInEra("Jurassic") or Workspace:GetAttribute("EraTripState") ~= "Open" then break end
            if getCarriedEggsCount() >= maxCap then break end

            local nestPos = nest:GetPivot().Position
            local safe = waitForChaserSafe(nestPos, CHASER_SAFE_DIST)
            if not safe then continue end

            -- Cari semua prompt StealEgg di sarang ini
            local activePrompts = {}
            for _, desc in ipairs(nest:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Enabled and (desc.Name == "StealEgg" or desc.ActionText == "Steal" or desc.ObjectText == "Egg") then
                    table.insert(activePrompts, desc)
                end
            end

            for _, prompt in ipairs(activePrompts) do
                if not autoEraTripEnabled or not isInEra("Jurassic") or Workspace:GetAttribute("EraTripState") ~= "Open" then break end
                if getCarriedEggsCount() >= maxCap then break end
                if not prompt.Enabled or not prompt.Parent then continue end

                -- Teleport ke telur
                local eggPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                local targetPos = eggPart and eggPart.Position or nestPos
                safePivotTo(CFrame.new(targetPos.X, targetPos.Y + 1.2, targetPos.Z))
                local _, myRoot = getCharacterParts()
                if myRoot then myRoot.AssemblyLinearVelocity = Vector3.zero end
                task.wait(0.12)

                -- Tangani hold duration
                local hold = prompt.HoldDuration or 0.7
                pcall(function() prompt.HoldDuration = 0 end)
                pcall(function() fireproximityprompt(prompt) end)
                task.wait(math.max(0.75, hold + 0.1))

                -- Begitu ambil 1 telur langsung setor ke EraCollect & kembali ke KickReady!
                if getCarriedEggsCount() >= maxCap then
                    depositJurassic()
                    eggDeposited = true
                    break
                end
            end

            -- Begitu telur disetor, break loop sarang untuk langsung mulai putaran ambil telur berikutnya!
            if eggDeposited then
                break
            end
        end

        -- Mampir ke Trader HANYA di menit ke-9 (sisa <= 65s) selama 1 detik untuk borong craft
        checkFinalMinuteTraderCraft("Jurassic", "JurassicMythic", canCraftJurassicMythic, JURASSIC_TRADER_CF, JURASSIC_KICK_READY_CF)

        task.wait(0.3)
    end

    statusParagraph:SetDesc("Jurassic selesai.")
end

-- ================= 80s ARCADE DANCE-OFF AUTOMATION =================
local EightiesClient = nil
pcall(function()
    EightiesClient = require(ReplicatedStorage.Client.HandlerLoader.EraTripClient.EraGamesClient.Eighties)
end)

local function getEightiesDanceFloor()
    local eraTrip = Workspace:FindFirstChild("EraTrip")
    local eighties = eraTrip and eraTrip:FindFirstChild("Eighties")
    if eighties then
        local df = eighties:FindFirstChild("DanceFloor", true)
        if df then return df end
        local pad = eighties:FindFirstChild("Pad", true) or eighties:FindFirstChild("Tiles", true)
        if pad then return pad end
    end
    if eraTrip then
        local df = eraTrip:FindFirstChild("DanceFloor", true)
        if df then return df end
    end
    return nil
end

local function handleEightiesEra()
    statusParagraph:SetDesc("80s Arcade: Menuju Dance Floor...")
    
    -- TP awal ke KickReady
    safePivotTo(EIGHTIES_KICK_READY_CF)
    task.wait(0.5)

    local pGui = player:FindFirstChild("PlayerGui")
    local hitNotes = {}

    while autoEraTripEnabled and isInEra("Eighties") and Workspace:GetAttribute("EraTripState") == "Open" do
        local danceOffGui = pGui and pGui:FindFirstChild("EraDanceOff")
        
        if not danceOffGui then
            -- Cari DanceFloor untuk memicu DanceStart
            local df = getEightiesDanceFloor()
            if df then
                local dfPos = df:IsA("BasePart") and df.Position or df:GetPivot().Position
                safePivotTo(CFrame.new(dfPos.X, dfPos.Y + 2.5, dfPos.Z))
                statusParagraph:SetDesc("80s Arcade: Di Dance Floor, menunggu mini-game dansa...")
            else
                safePivotTo(EIGHTIES_KICK_READY_CF)
                task.wait(0.5)
            end
            task.wait(0.5)
        else
            -- Mini-game EraDanceOff SEDANG BERLANGSUNG!
            statusParagraph:SetDesc("80s Arcade: Auto-Playing 100% PERFECT Dance-Off! 🕺⚡")
            
            local pressEvent = danceOffGui:FindFirstChild("Press")
            local root = danceOffGui:FindFirstChild("Root")
            local panel = root and root:FindFirstChild("Panel")
            local frame = panel and panel:FindFirstChild("Frame")
            
            -- Method 1: Deteksi Note Visual yang meluncur ke garis hit (Y = 360)
            if frame then
                for _, child in ipairs(frame:GetChildren()) do
                    if child:IsA("Frame") and child.Name ~= "Frame" and not hitNotes[child] then
                        local yPos = child.Position.Y.Offset
                        -- Target line berada tepat di Y = 360. Window Perfect = 345 - 375
                        if yPos >= 346 and yPos <= 374 then
                            hitNotes[child] = true
                            local xPos = child.Position.X.Offset
                            local lane = nil
                            if math.abs(xPos - 37) < 22 then
                                lane = 1
                            elseif math.abs(xPos - 111) < 22 then
                                lane = 2
                            elseif math.abs(xPos - 185) < 22 then
                                lane = 3
                            elseif math.abs(xPos - 259) < 22 then
                                lane = 4
                            end
                            
                            if lane then
                                if pressEvent then
                                    pcall(function() pressEvent:Fire(lane) end)
                                elseif EightiesClient and EightiesClient.Press then
                                    pcall(function() EightiesClient.Press(lane) end)
                                end
                            end
                        end
                    end
                end
            end
            
            -- Method 2: Membaca Upvalues Memori secara langsung jika didukung executor
            pcall(function()
                if debug and debug.getupvalues and EightiesClient and EightiesClient.Press then
                    local uvals = debug.getupvalues(EightiesClient.Press)
                    local session = uvals and uvals[1]
                    if session and session.Notes then
                        local n2 = if session.Song and session.Song.IsPlaying and session.Song.TimeLength > 0 
                            then session.Song.TimePosition - session.SongStart 
                            else Workspace:GetServerTimeNow() - session.StartAt
                        
                        for idx, note in ipairs(session.Notes) do
                            if not note.Done then
                                local diff = note.T - n2
                                if diff <= 0.05 and diff >= -0.05 then
                                    if pressEvent then
                                        pressEvent:Fire(note.Lane)
                                    else
                                        EightiesClient.Press(note.Lane)
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end)
            
            task.wait(0.015)
        end
    end
    
    statusParagraph:SetDesc("80s Arcade selesai.")
end

-- ================= MAIN CONTROLLER LOOP =================
function runAutoEraTrip()
    if autoEraTripRunning then return end
    autoEraTripRunning = true
    
    while autoEraTripEnabled do
        local humanoid, rootPart = getCharacterParts()
        if not humanoid or not rootPart then
            task.wait(0.5)
            continue
        end
        
        -- Cek jika sedang berada di dalam Era IceAge
        if isInEra("IceAge") then
            if Workspace:GetAttribute("EraTripState") == "Open" then
                handleIceAgeEra()
            else
                safePivotTo(ICEAGE_EXIT_CF)
                task.wait(0.3)
                if network then
                    pcall(function()
                        network.FireServer("EraTripLeave")
                    end)
                end
                task.wait(2)
            end
            task.wait(0.5)
            continue
        end

        -- Cek jika sedang berada di dalam Era Future
        if isInEra("Future") then
            if Workspace:GetAttribute("EraTripState") == "Open" then
                handleFutureEra()
            else
                -- Event berakhir, keluar lewat portal
                safePivotTo(FUTURE_EXIT_CF)
                task.wait(0.3)
                if network then
                    pcall(function()
                        network.FireServer("EraTripLeave")
                    end)
                end
                task.wait(2)
            end
            task.wait(0.5)
            continue
        end
        
        -- Cek jika sedang berada di dalam Era Roman
        if isInEra("Roman") then
            if Workspace:GetAttribute("EraTripState") == "Open" then
                handleRomanEra()
            else
                -- Event berakhir, keluar lewat portal
                safePivotTo(ROMAN_EXIT_CF)
                task.wait(0.3)
                if network then
                    pcall(function()
                        network.FireServer("EraTripLeave")
                    end)
                end
                task.wait(2)
            end
            task.wait(0.5)
            continue
        end
        
        -- Cek jika sedang berada di dalam Era Jurassic
        if isInEra("Jurassic") then
            if Workspace:GetAttribute("EraTripState") == "Open" then
                handleJurassicEra()
            else
                -- Event berakhir, keluar lewat portal
                safePivotTo(JURASSIC_EXIT_CF)
                task.wait(0.3)
                if network then
                    pcall(function()
                        network.FireServer("EraTripLeave")
                    end)
                end
                task.wait(2)
            end
            task.wait(0.5)
            continue
        end

        -- Cek jika sedang berada di dalam Era Eighties (80s Arcade)
        if isInEra("Eighties") then
            if Workspace:GetAttribute("EraTripState") == "Open" then
                handleEightiesEra()
            else
                -- Event berakhir, keluar lewat portal
                safePivotTo(EIGHTIES_EXIT_CF)
                task.wait(0.3)
                if network then
                    pcall(function()
                        network.FireServer("EraTripLeave")
                    end)
                end
                task.wait(2)
            end
            task.wait(0.5)
            continue
        end
        
        -- Jika karakter sedang di lobi utama
        local state = Workspace:GetAttribute("EraTripState") or "Closed"
        local curEra = Workspace:GetAttribute("EraTripEra") or "None"
        
        -- Cek apakah era yang sedang aktif dipilih oleh user
        if isEraSelected(curEra) then
            if state == "Open" then
                if curEra == "Future" or curEra == "Roman" or curEra == "Jurassic" or curEra == "IceAge" or curEra == "Eighties" then
                    safePivotTo(CFrame.new(TIMELAB_TRIGGER_POS))
                    task.wait(0.3)
                    
                    if network then
                        pcall(function()
                            network.FireServer("EraTripEnter")
                        end)
                    end
                    
                    local deadline = os.clock() + 4
                    while autoEraTripEnabled and os.clock() < deadline do
                        if isInEra(curEra) then break end
                        task.wait(0.2)
                    end
                end
            elseif state == "Rolling" then
                safePivotTo(CFrame.new(TIMELAB_TRIGGER_POS) * CFrame.new(0, 0, 10))
                task.wait(1)
            end
        end
        
        task.wait(1)
    end
    
    autoEraTripRunning = false
end

-- ================= MISC TAB =================
local lowGraphicsEnabled = false
local lowGraphicsOriginalValues = {}
local antiAfkEnabled = false
local antiAfkConnection = nil

local function setLowGraphicsProperty(instance, property, value)
    local properties = lowGraphicsOriginalValues[instance]
    if not properties then
        properties = {}
        lowGraphicsOriginalValues[instance] = properties
    end
    
    if properties[property] == nil then
        properties[property] = instance[property]
    end
    instance[property] = value
end

local function applyLowGraphics(instance)
    if instance:IsA("BasePart") then
        setLowGraphicsProperty(instance, "Material", Enum.Material.SmoothPlastic)
        setLowGraphicsProperty(instance, "CastShadow", false)
    elseif instance:IsA("Decal") or instance:IsA("Texture") then
        setLowGraphicsProperty(instance, "Transparency", 1)
    elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") then
        setLowGraphicsProperty(instance, "Enabled", false)
    elseif instance:IsA("PostEffect") then
        setLowGraphicsProperty(instance, "Enabled", false)
    end
end

local function setLowGraphicsEnabled(enabled)
    lowGraphicsEnabled = enabled
    
    if enabled then
        setLowGraphicsProperty(Lighting, "GlobalShadows", false)
        setLowGraphicsProperty(Lighting, "FogEnd", 9e9)
        
        for _, instance in ipairs(Workspace:GetDescendants()) do
            applyLowGraphics(instance)
        end
        for _, instance in ipairs(Lighting:GetDescendants()) do
            applyLowGraphics(instance)
        end
        return
    end
    
    for instance, properties in pairs(lowGraphicsOriginalValues) do
        for property, originalValue in pairs(properties) do
            instance[property] = originalValue
        end
    end
    table.clear(lowGraphicsOriginalValues)
end

Workspace.DescendantAdded:Connect(function(instance)
    if lowGraphicsEnabled then
        applyLowGraphics(instance)
    end
end)

Lighting.DescendantAdded:Connect(function(instance)
    if lowGraphicsEnabled then
        applyLowGraphics(instance)
    end
end)

local function startAntiAfk()
    if antiAfkConnection then return end
    antiAfkEnabled = true
    antiAfkConnection = player.Idled:Connect(function()
        if not antiAfkEnabled then return end
        local camera = Workspace.CurrentCamera
        if not camera then return end
        
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), camera.CFrame)
        end)
        task.wait(1)
        pcall(function()
            VirtualUser:Button2Up(Vector2.new(0, 0), camera.CFrame)
        end)
    end)
end

local function stopAntiAfk()
    antiAfkEnabled = false
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
end

MiscTab:Toggle({
    Title = "Low Graphics",
    Value = false,
    Callback = function(state)
        setLowGraphicsEnabled(state)
    end,
})

MiscTab:Toggle({
    Title = "Anti-AFK",
    Value = false,
    Callback = function(state)
        if state then
            startAntiAfk()
        else
            stopAntiAfk()
        end
    end,
})
