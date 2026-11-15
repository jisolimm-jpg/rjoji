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
        -- Cek Pill/Frame container: kalau Visible = false, HUD hidden (sudah deposit)
        -- Jangan percaya teks yang tertinggal saat HUD tidak tampil
        local pill = haulHUD:FindFirstChild("Pill", true) or haulHUD:FindFirstChild("Frame", true)
        if pill and not pill.Visible then
            return 0, nil
        end
        for _, desc in ipairs(haulHUD:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Visible and desc.Text and desc.Text ~= "" then
                local cur, maxVal = string.match(desc.Text, "HAUL%s*(%d+)%s*/%s*(%d+)")
                if cur then
                    return tonumber(cur), tonumber(maxVal)
                end
            end
        end
    end
    return 0, nil
end

local function getCarriedCratesCount()
    -- 1. PRIORITAS UTAMA: attribute EraCarry dari server (paling akurat)
    local countAttr = 0
    local carry = player:GetAttribute("EraCarry")
    if typeof(carry) == "string" and carry ~= "" then
        for _ in string.gmatch(carry, "[^,]+") do
            countAttr = countAttr + 1
        end
    elseif typeof(carry) == "number" then
        countAttr = carry
    end
    
    -- 2. Fallback: hitung model CarriedCrate di atas kepala
    local countHead = countCarriedAboveHead()
    
    -- 3. HUD: HANYA untuk maxCapacity, TIDAK untuk current count
    --    (HUD sering stuck di nilai lama setelah deposit)
    local _, maxFromHUD = countFromHUD()
    
    -- Pakai attribute (server truth) + fallback head, BUKAN HUD count
    local finalCount = math.max(countAttr, countHead)
    return finalCount, maxFromHUD
end

-- Jurassic memakai attribute EraCarry dan model CarriedEgg yang sama.
-- Wrapper ini mencegah pemanggilan fungsi yang sebelumnya belum didefinisikan.
local function getCarriedEggsCount()
    return getCarriedCratesCount()
end

-- Roman: gunakan hitungan EraCarry dari server sebagai sumber utama.
-- Ini menghindari hitungan palsu dari model/HUD lama setelah setor.
local function getRomanCarriedCount()
    local carry = player:GetAttribute("EraCarry")
    if typeof(carry) == "string" then
        local count = 0
        for _ in string.gmatch(carry, "[^,]+") do
            count = count + 1
        end
        return count
    elseif typeof(carry) == "number" then
        return carry
    end

    local countHUD = countFromHUD()
    if countHUD ~= nil then
        return countHUD
    end
    return countCarriedAboveHead()
end

-- Future: gunakan EraCarry server terlebih dahulu agar hitungan HUD/model lama
-- setelah setor tidak memicu teleport EraCollect berulang.
local function getFutureCarriedCount()
    local carry = player:GetAttribute("EraCarry")
    if typeof(carry) == "string" and carry ~= "" then
        local count = 0
        for _ in string.gmatch(carry, "[^,]+") do count = count + 1 end
        return count
    elseif typeof(carry) == "number" then
        return carry
    end
    -- Fallback fisik saja, TIDAK pakai HUD (HUD bisa stuck setelah deposit)
    return countCarriedAboveHead()
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

-- Dedicated loop to update status: "Next event apa & berapa menit lagi"
task.spawn(function()
    while true do
        pcall(function()
            if statusParagraph then
                local state = Workspace:GetAttribute("EraTripState") or "Closed"
                local curEra = Workspace:GetAttribute("EraTripEra") or "None"
                local nextAt = Workspace:GetAttribute("EraTripNextAt") or (Workspace:GetServerTimeNow() + 3600)
                local endsAt = Workspace:GetAttribute("EraTripEndsAt") or Workspace:GetServerTimeNow()
                local now = Workspace:GetServerTimeNow()

                -- Predict next era
                local nextEraName = "Belum Diketahui"
                if eraTripData and eraTripData.EraAt then
                    pcall(function()
                        local rawNext = eraTripData.EraAt(nextAt)
                        nextEraName = ERA_DISPLAY_NAMES[rawNext] or rawNext or "Belum Diketahui"
                    end)
                end

                if state == "Open" then
                    local remain = math.max(0, math.floor(endsAt - now))
                    local curDisplayName = ERA_DISPLAY_NAMES[curEra] or curEra
                    local nextDiff = math.max(0, math.floor(nextAt - now))
                    local nextMins = math.floor(nextDiff / 60)
                    
                    statusParagraph:SetDesc(string.format(
                        "Event Aktif: %s (Sisa %02d:%02d)\nNext Event: %s (dalam %d menit)",
                        curDisplayName, math.floor(remain / 60), remain % 60, nextEraName, nextMins
                    ))
                elseif state == "Rolling" then
                    local curDisplayName = ERA_DISPLAY_NAMES[curEra] or curEra
                    statusParagraph:SetDesc(string.format(
                        "Sedang Rolling Event: %s...\nNext Event: %s",
                        curDisplayName, nextEraName
                    ))
                else
                    local diff = math.max(0, math.floor(nextAt - now))
                    local mins = math.floor(diff / 60)
                    local secs = diff % 60
                    statusParagraph:SetDesc(string.format(
                        "Next Event: %s (%d menit %02d detik lagi)",
                        nextEraName, mins, secs
                    ))
                end
            end
        end)
        task.wait(1)
    end
end)

-- ================= TAB: JADWAL (SCHEDULE 24 JAM) =================
local ERA_ICONS = {
    ["Future"]   = "🤖",
    ["IceAge"]   = "🧊",
    ["Jurassic"] = "🦕",
    ["Roman"]    = "⚔️",
    ["Eighties"] = "🕹️",
}

local scheduleHeaderParagraph = ScheduleTab:Paragraph({
    Title = "📅 Jadwal Event 24 Jam Ke Depan",
    Content = "Memuat jadwal...",
})

local scheduleListParagraph = ScheduleTab:Paragraph({
    Title = "Daftar Event",
    Content = "Menghitung...",
})

local function buildScheduleText()
    if not eraTripData or not eraTripData.EraAt then
        return "Data jadwal tidak tersedia.\n(eraTripData.EraAt tidak ditemukan)"
    end
    
    local now = Workspace:GetServerTimeNow()
    local nextAt = Workspace:GetAttribute("EraTripNextAt") or (now + 600)
    local state  = Workspace:GetAttribute("EraTripState") or "Closed"
    local curEra = Workspace:GetAttribute("EraTripEra") or ""
    local endsAt = Workspace:GetAttribute("EraTripEndsAt") or now
    
    local ERA_INTERVAL_EST = 660  -- ~10 menit event + ~1 menit jeda rolling
    local HOURS_24 = 86400
    
    local lines = {}
    local lineCount = 0
    local maxLines = 25
    
    -- Tambahkan event yang sedang berjalan
    if state == "Open" and curEra ~= "" then
        local remain = math.max(0, math.floor(endsAt - now))
        local icon = ERA_ICONS[curEra] or "⭐"
        local displayName = ERA_DISPLAY_NAMES[curEra] or curEra
        table.insert(lines, string.format("▶ SEKARANG  %s %s (sisa %dm %02ds)", icon, displayName, math.floor(remain/60), remain%60))
        lineCount = lineCount + 1
    end
    
    -- Iterasi event ke depan
    local checkTime = nextAt
    while checkTime < (now + HOURS_24) and lineCount < maxLines do
        local eraRaw = nil
        pcall(function() eraRaw = eraTripData.EraAt(checkTime) end)
        
        if eraRaw then
            local icon = ERA_ICONS[eraRaw] or "⭐"
            local displayName = ERA_DISPLAY_NAMES[eraRaw] or eraRaw
            local diffSec = math.floor(checkTime - now)
            local h = math.floor(diffSec / 3600)
            local m = math.floor((diffSec % 3600) / 60)
            local timeStr = h > 0 and string.format("+%dj %02dm", h, m) or string.format("+%dm", m)
            table.insert(lines, string.format("  %-9s %s %s", timeStr, icon, displayName))
            lineCount = lineCount + 1
        end
        checkTime = checkTime + ERA_INTERVAL_EST
    end
    
    if #lines == 0 then return "Tidak ada data jadwal yang tersedia." end
    return table.concat(lines, "\n")
end

local function buildScheduleHeader()
    local now = Workspace:GetServerTimeNow()
    local state = Workspace:GetAttribute("EraTripState") or "Closed"
    local stateStr = (state == "Open" and "🟢 Event Aktif") or (state == "Rolling" and "🔄 Rolling...") or "⚫ Tutup"
    return string.format("Status: %s\nWaktu Server: %.0f", stateStr, now)
end

task.spawn(function()
    while true do
        pcall(function()
            if scheduleHeaderParagraph then scheduleHeaderParagraph:SetDesc(buildScheduleHeader()) end
            if scheduleListParagraph then scheduleListParagraph:SetDesc(buildScheduleText()) end
        end)
        task.wait(5)
    end
end)

-- ================= TAB: INVENTARIS =================
local ITEM_DISPLAY = {
    -- The Future
    { key = "Future5",   label = "Quantum Chip",   era = "Future",   cost = 1  },
    { key = "Future4",   label = "Plasma Core",    era = "Future",   cost = 7  },
    { key = "Future3",   label = "Laser Goggles",  era = "Future",   cost = 14 },
    { key = "Future2",   label = "Robot Scraps",   era = "Future",   cost = 25 },
    { key = "Future1",   label = "Scrap Metal",    era = "Future",   cost = 45 },
    -- Roman Empire
    { key = "Roman5",    label = "Caesar Seal",    era = "Roman",    cost = 1  },
    { key = "Roman4",    label = "Golden Eagle",   era = "Roman",    cost = 7  },
    { key = "Roman3",    label = "Centurion Helm", era = "Roman",    cost = 14 },
    { key = "Roman2",    label = "Laurel Wreath",  era = "Roman",    cost = 25 },
    { key = "Roman1",    label = "Bronze Coin",    era = "Roman",    cost = 45 },
    -- Jurassic
    { key = "Jurassic5", label = "Primal Egg",     era = "Jurassic", cost = 1  },
    { key = "Jurassic4", label = "Volcano Ember",  era = "Jurassic", cost = 7  },
    { key = "Jurassic3", label = "Fossil Skull",   era = "Jurassic", cost = 14 },
    { key = "Jurassic2", label = "Raptor Claw",    era = "Jurassic", cost = 25 },
    { key = "Jurassic1", label = "Amber Shard",    era = "Jurassic", cost = 45 },
    -- Ice Age
    { key = "IceAge5",   label = "Mammoth Tusk",   era = "IceAge",   cost = 1  },
    { key = "IceAge4",   label = "Frost Core",     era = "IceAge",   cost = 7  },
    { key = "IceAge3",   label = "Glacial Tooth",  era = "IceAge",   cost = 14 },
    { key = "IceAge2",   label = "Ice Shard",      era = "IceAge",   cost = 25 },
    { key = "IceAge1",   label = "Frozen Pebble",  era = "IceAge",   cost = 45 },
    -- 80s Arcade (tidak ada craft mythic, item nama berdasarkan kemungkinan)
    { key = "Eighties5", label = "Gold Record",    era = "Eighties", cost = 1  },
    { key = "Eighties4", label = "Neon Sign",      era = "Eighties", cost = 7  },
    { key = "Eighties3", label = "Cassette Tape",  era = "Eighties", cost = 14 },
    { key = "Eighties2", label = "Arcade Token",   era = "Eighties", cost = 25 },
    { key = "Eighties1", label = "Quarter Coin",   era = "Eighties", cost = 45 },
}

local invFutureParagraph   = InventoryTab:Paragraph({ Title = "🤖 The Future",   Content = "Memuat..." })
local invRomanParagraph    = InventoryTab:Paragraph({ Title = "⚔️ Roman Empire", Content = "Memuat..." })
local invJurassicParagraph = InventoryTab:Paragraph({ Title = "🦕 Jurassic",     Content = "Memuat..." })
local invIceAgeParagraph   = InventoryTab:Paragraph({ Title = "🧊 Ice Age",      Content = "Memuat..." })
local invEightiesParagraph = InventoryTab:Paragraph({ Title = "🕹️ 80s Arcade",  Content = "Memuat..." })
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
            local craftable = math.floor(count / needed)
            local bar
            if craftable >= 1 then
                bar = " ✅ x" .. craftable
            else
                local pct = math.floor((count / needed) * 10)
                bar = " [" .. string.rep("█", pct) .. string.rep("░", 10 - pct) .. "]"
            end
            table.insert(lines, string.format("%-16s %3d/%-3d%s", item.label, count, needed, bar))
        end
    end
    return table.concat(lines, "\n")
end

local function buildCraftStatus()
    local relics = getAllRelics()
    local results = {}
    local function checkCraft(eraInternal, cost, mythicName)
        local canCraft = true
        for key, needed in pairs(cost) do
            if (tonumber(relics[key]) or 0) < needed then canCraft = false; break end
        end
        local icon = ERA_ICONS[eraInternal] or "⭐"
        table.insert(results, string.format("%s %-18s %s", icon, mythicName, canCraft and "✅ BISA CRAFT" or "❌ Belum cukup"))
    end
    checkCraft("Future",   FUTURE_MYTHIC_COST,   "Mecha Pizzone 3000")
    checkCraft("Roman",    ROMAN_MYTHIC_COST,     "Cesarone Imperatore")
    checkCraft("Jurassic", JURASSIC_MYTHIC_COST,  "T-Rexone Braccino")
    checkCraft("IceAge",   ICEAGE_MYTHIC_COST,    "Mammutone")
    -- 80s Arcade: tidak ada mythic craft
    local gr = tonumber(relics["Eighties5"]) or 0
    table.insert(results, string.format("🕹️ %-18s %d Gold Record (no craft)", "80s Arcade", gr))
    return table.concat(results, "\n")
end

task.spawn(function()
    while true do
        pcall(function()
            for eraName, para in pairs(INV_PARAGRAPH) do
                if para then para:SetDesc(buildInventoryLines(eraName)) end
            end
            if invCraftParagraph then invCraftParagraph:SetDesc(buildCraftStatus()) end
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
            -- Naikkan generation → loop lama yang masih jalan otomatis berhenti
            autoEraTripGeneration = autoEraTripGeneration + 1
            local myGen = autoEraTripGeneration
            task.spawn(function() runAutoEraTrip(myGen) end)
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

local function collectFutureCrates(checkLimit)
    local collectedAny = false
    local crates = getSciCrates() -- Sudah di-sort prioritas rarity tertinggi
    local targetCap = 10
    
    for _, crate in ipairs(crates) do
        if not autoEraTripEnabled or not isInEra("Future") then break end
        
        local curCount, maxFromHUD = getCarriedCratesCount()
        local cap = maxFromHUD or targetCap
        if checkLimit and curCount >= cap then
            break
        end
        
        if not crate.Parent then continue end
        
        local cratePos = crate:GetPivot().Position
        -- TP tepat ke crate di tanah
        safePivotTo(CFrame.new(cratePos.X, cratePos.Y + 1.5, cratePos.Z))
        
        -- Tunggu sampai crate diambil: crate di-destroy server ATAU count bertambah
        local deadline = os.clock() + 0.5
        while os.clock() < deadline and crate.Parent do
            local newCount = getCarriedCratesCount()
            if newCount > curCount or newCount >= cap then
                break
            end
            task.wait(0.05)
        end
        
        collectedAny = true
        
        local nowCount = getCarriedCratesCount()
        if checkLimit and nowCount >= cap then
            break
        end
    end
    
    return collectedAny
end

-- Satu jalur setor Future: trigger prompt, tunggu konfirmasi, lalu kembali KickReady.
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

    local depositStart = os.clock()
    while getFutureCarriedCount() > 0 and os.clock() - depositStart < 5 do
        task.wait(0.2)
    end
    task.wait(0.3)
    safePivotTo(FUTURE_KICK_READY_CF)
    task.wait(0.3)
end

-- ================= MAIN FUTURE ROUTINE =================
local function handleFutureEra()
    local myGen = autoEraTripGeneration
    local initializedAtKickReady = false
    
    while autoEraTripEnabled and autoEraTripGeneration == myGen
        and isInEra("Future") and Workspace:GetAttribute("EraTripState") == "Open" do
        -- Step 1: Sekali di awal, TP ke EraKickReady, jeda 0.5s
        if not initializedAtKickReady then
            safePivotTo(FUTURE_KICK_READY_CF)
            task.wait(0.5)
            initializedAtKickReady = true
        end
        
        local carried, maxFromHUD = getFutureCarriedCount()
        local targetCap = maxFromHUD or 10
        
        -- Step 2: Cek apakah sudah bawa 10 peti (atau penuh) -> langsung setor ke EraCollect & kembali ke KickReady
        -- Guard: carried > 0 mencegah infinite deposit loop saat HUD stuck di angka lama
        if carried > 0 and carried >= targetCap then
            depositFuture()
            -- Setelah setor, mulai ulang dari Zone 5.
            continue
        end
        
        -- Step 3: Looting dari Zona Tertinggi ke Bawah (Zone 5 -> 1)
        for _, zone in ipairs(FUTURE_ZONES) do
            if not autoEraTripEnabled or autoEraTripGeneration ~= myGen
                or not isInEra("Future") or Workspace:GetAttribute("EraTripState") ~= "Open" then
                break
            end
            
            local currentCarried = getFutureCarriedCount()
            if currentCarried >= targetCap then
                break
            end
            
            local zoneTimeout = os.clock() + 20
            while autoEraTripEnabled and isInEra("Future") and os.clock() < zoneTimeout do
                -- Cek batas bawa LEBIH DULU
                if getFutureCarriedCount() >= targetCap then break end
                
                -- Pungut crate dengan prioritas rarity tertinggi duluan
                collectFutureCrates(true)
                if getFutureCarriedCount() >= targetCap then break end
                
                local robots = getRobotsInZone(zone)
                if #robots == 0 then break end
                
                local targetRobot = robots[1]
                local root = targetRobot:FindFirstChild("RootPart") or targetRobot.PrimaryPart
                
                if root and targetRobot.Parent then
                    local robotPos = root.Position
                    local safeCF = CFrame.new(robotPos.X, robotPos.Y + 12, robotPos.Z + 18)
                    safePivotTo(safeCF)
                    
                    -- Spam tembakan ke robot, sambil cek carry limit setiap tembakan
                    for _ = 1, 6 do
                        if not autoEraTripEnabled or not targetRobot.Parent or getFutureCarriedCount() >= targetCap then break end
                        shootBlaster()
                        task.wait(0.12)
                    end
                    
                    collectFutureCrates(true)
                else
                    task.wait(0.1)
                end
            end
            
            collectFutureCrates(true)
            task.wait(0.2)
            
            -- Jika setelah zona selesai peti sudah 10 / penuh, langsung break ke setor
            if getFutureCarriedCount() >= targetCap then
                break
            end
        end
        
        -- Kumpulkan sisa peti
        collectFutureCrates(true)
        
        -- Jika membawa peti setelah putaran zona selesai, setor ke EraCollect & kembali ke KickReady
        if getFutureCarriedCount() > 0 then
            depositFuture()
            -- Jangan lanjutkan putaran lama; mulai ulang dari Zone 5.
            continue
        end
        
        -- Mampir ke Trader HANYA di menit ke-9 (sisa <= 65s) selama 1 detik untuk borong craft
        checkFinalMinuteTraderCraft("Future", "FutureMythic", canCraftMechaPizzone, FUTURE_TRADER_CF, FUTURE_KICK_READY_CF)
        
        task.wait(0.3)
    end
end

-- ================= ROMAN ERA SCANNING & AUTOMATION =================
local function getRomanGuards()
    local guards = {}
    local eraTrip = Workspace:FindFirstChild("EraTrip")
    local roman = eraTrip and eraTrip:FindFirstChild("Roman")
    local chasers = roman and roman:FindFirstChild("Chasers")
    if chasers then
        for _, child in ipairs(chasers:GetChildren()) do
            local modelName = child:GetAttribute("Model") or child.Name
            local isAlive = not child:GetAttribute("Dead") and (child:GetAttribute("HP") == nil or child:GetAttribute("HP") > 0)
            if isAlive and (ROMAN_GUARD_NAMES[modelName] or ROMAN_GUARD_NAMES[child.Name] or child.Name == "Guard") then
                table.insert(guards, child)
            end
        end
    end
    return guards
end

local function getVaultChests(zoneIndex)
    local chests = {}
    local eraTrip = Workspace:FindFirstChild("EraTrip")
    local roman = eraTrip and eraTrip:FindFirstChild("Roman")
    local vaultRaid = roman and roman:FindFirstChild("VaultRaid")
    if vaultRaid then
        for _, child in ipairs(vaultRaid:GetChildren()) do
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
        return tierA > tierB
    end)
    return chests
end

local function openReadyChests(zoneIndex)
    local chests = getVaultChests(zoneIndex)
    for _, chest in ipairs(chests) do
        if not autoEraTripEnabled or not isInEra("Roman") then break end
        if getCarriedCratesCount() >= 5 then break end
        
        local isReady = chest:GetAttribute("Ready") == true
        local prompt = chest:FindFirstChild("ChestBody") and chest.ChestBody:FindFirstChild("OpenChest")
        if (isReady or (prompt and prompt.Enabled)) and chest.Parent then
            local pos = chest:GetPivot().Position
            safePivotTo(CFrame.new(pos) * CFrame.new(0, 2, 0))
            task.wait(0.2)
            if prompt then
                pcall(function()
                    fireproximityprompt(prompt)
                end)
            end
            task.wait(0.65)
        end
    end
    
    -- Ambil juga DroppedLoot jika ada di area
    local eraTrip = Workspace:FindFirstChild("EraTrip")
    local roman = eraTrip and eraTrip:FindFirstChild("Roman")
    local vaultRaid = roman and roman:FindFirstChild("VaultRaid")
    if vaultRaid then
        for _, child in ipairs(vaultRaid:GetChildren()) do
            if child.Name == "DroppedLoot" and child:FindFirstChild("Base") then
                local prompt = child.Base:FindFirstChild("SwapLoot")
                if prompt and getCarriedCratesCount() < 5 then
                    safePivotTo(CFrame.new(child.Base.Position) * CFrame.new(0, 2, 0))
                    task.wait(0.2)
                    pcall(function()
                        fireproximityprompt(prompt)
                    end)
                    task.wait(0.5)
                end
            end
        end
    end
end

local function fightGuard(guard)
    equipGladius()
    
    local timeout = os.clock() + 10
    while autoEraTripEnabled and isInEra("Roman") and guard.Parent and os.clock() < timeout do
        local isAlive = not guard:GetAttribute("Dead") and (guard:GetAttribute("HP") == nil or guard:GetAttribute("HP") > 0)
        if not isAlive then break end
        
        local guardPos = guard:IsA("BasePart") and guard.Position or guard:GetPivot().Position
        local guardCF = guard:IsA("BasePart") and guard.CFrame or guard:GetPivot()
        
        -- POSISI AMAN: TEPAT DI BELAKANG GUARD (-3.5 studs) dan SEDIKIT DI ATAS (+4.5 studs)
        -- Serangan Guard (AttackDir) selalu mengarah ke depan. Di belakang guard, kita 100% kebal dari tebasan!
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
    -- 1. TP ke EraCollect Roman.
    safePivotTo(ROMAN_COLLECT_CF)
    task.wait(0.2)

    -- 2. Aktifkan ProximityPrompt EraCollect.
    -- Sebelumnya script hanya teleport dan menunggu, tanpa trigger prompt setor.
    local eraTrip = Workspace:FindFirstChild("EraTrip")
    local roman = eraTrip and eraTrip:FindFirstChild("Roman")
    local collectPart = roman and roman:FindFirstChild("EraCollect")
    local prompt = collectPart and collectPart:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt and prompt.Enabled then
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end

    -- 3. Tunggu server mengosongkan bawaan setelah setor.
    local depositStart = os.clock()
    while getRomanCarriedCount() > 0 and os.clock() - depositStart < 5 do
        task.wait(0.2)
    end
    task.wait(0.3)

    -- 4. Kembali ke KickReady agar farming berlanjut.
    safePivotTo(ROMAN_KICK_READY_CF)
    task.wait(0.3)
end

-- ================= MAIN ROMAN ROUTINE =================
local function handleRomanEra()
    local initializedAtKickReady = false
    
    while autoEraTripEnabled and isInEra("Roman") and Workspace:GetAttribute("EraTripState") == "Open" do
        -- Step 1: Sekali di awal masuk Roman, TP ke EraKickReady, jeda 0.5s
        if not initializedAtKickReady then
            safePivotTo(ROMAN_KICK_READY_CF)
            task.wait(0.5)
            initializedAtKickReady = true
        end
        
        -- Step 2: Cek kapasitas bawaan (Maksimal 5 di Roman)
        if getRomanCarriedCount() >= 5 then
            depositRoman()
            task.wait(0.2)
            continue
        end
        
        -- Step 3: SELALU MULAI DARI ZONA TERTINGGI (Zone 5 Mythic/Boss -> 4 -> 3 -> 2 -> 1)
        local depositedThisPass = false
        for _, zone in ipairs(ROMAN_ZONES) do
            if not autoEraTripEnabled or not isInEra("Roman") or Workspace:GetAttribute("EraTripState") ~= "Open" then
                break
            end
            
            -- Jika di tengah perjalanan tas penuh (>= 5), langsung setor lalu balik ke EraKickReady dan break
            if getRomanCarriedCount() >= 5 then
                depositRoman()
                depositedThisPass = true
                break
            end
            
            local zoneTimeout = os.clock() + 25
            while autoEraTripEnabled and isInEra("Roman") and os.clock() < zoneTimeout do
                if getRomanCarriedCount() >= 5 then break end
                
                local allGuards = getRomanGuards()
                local zoneGuards = {}
                for _, g in ipairs(allGuards) do
                    local gPos = g:IsA("BasePart") and g.Position or g:GetPivot().Position
                    if gPos.X >= zone.MinX and gPos.X <= zone.MaxX then
                        table.insert(zoneGuards, g)
                    end
                end
                
                if #zoneGuards == 0 then
                    break
                end
                
                local targetGuard = zoneGuards[1]
                fightGuard(targetGuard)
                
                openReadyChests(zone.Index)
            end
            
            -- Buka chest di zona ini setelah guard dikalahkan
            openReadyChests(zone.Index)
            
            -- Jika setelah buka chest tas penuh (>= 5), langsung setor lalu balik ke EraKickReady dan break
            if getRomanCarriedCount() >= 5 then
                depositRoman()
                depositedThisPass = true
                break
            end
            
            task.wait(0.2)
        end
        
        -- Jika putaran zona selesai dan masih membawa peti (>0), setor ke EraCollect lalu balik ke EraKickReady
        if getRomanCarriedCount() > 0 and not depositedThisPass then
            depositRoman()
        end
        
        -- Mampir ke Trader HANYA di menit ke-9 (sisa <= 65s) selama 1 detik untuk borong craft
        checkFinalMinuteTraderCraft("Roman", "RomanMythic", canCraftRomanMythic, ROMAN_TRADER_CF, ROMAN_KICK_READY_CF)
        
        -- Jika semua guard di arena sedang kosong / wave belum muncul, tunggu di EraKickReady
        local remainingGuards = getRomanGuards()
        if #remainingGuards == 0 then
            safePivotTo(ROMAN_KICK_READY_CF)
            task.wait(1.5)
        end
        
        task.wait(0.3)
    end
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
    safePivotTo(JURASSIC_COLLECT_CF)
    local depositStart = os.clock()
    while getCarriedEggsCount() > 0 and os.clock() - depositStart < 3.5 do
        task.wait(0.2)
    end
    task.wait(0.3)
    safePivotTo(JURASSIC_KICK_READY_CF)
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

                -- BEGITU DIAMBIL, LANGSUNG TP KE ERACOLLECT!
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
    -- Helper: wait until chaser is far enough or move to safe spot
    local function waitForChaserSafe(targetPos, safeDist)
        local eraTripFolder = Workspace:FindFirstChild("EraTrip")
        local jurassicFolder = eraTripFolder and eraTripFolder:FindFirstChild("Jurassic")
        local chaser = jurassicFolder and jurassicFolder:FindFirstChild("Chaser")
        if not chaser then return true end
        local maxWait = 8  -- seconds, to avoid infinite loop
        local start = os.clock()
        while os.clock() - start < maxWait do
            local dist = (targetPos - chaser:GetPivot().Position).Magnitude
            if dist >= safeDist then return true end
            -- if too close, temporarily retreat to KickReady
            safePivotTo(JURASSIC_KICK_READY_CF)
            task.wait(0.5)
        end
        return false
    end

    -- Initialize: teleport to KickReady
    safePivotTo(JURASSIC_KICK_READY_CF)
    task.wait(0.5)

    local maxCap = 1  -- Ambil 1 telur langsung collect
    local nestsVisited = {}
    local CHASER_SAFE_DIST = 20  -- jarak minimal yang dianggap aman (stud)

    while autoEraTripEnabled and isInEra("Jurassic") do
        -- Jika masih ada telur yang terbawa, langsung setor ke EraCollect dulu
        if getCarriedEggsCount() > 0 then
            safePivotTo(JURASSIC_COLLECT_CF)
            local depositStart = os.clock()
            while getCarriedEggsCount() > 0 and os.clock() - depositStart < 3.5 do
                task.wait(0.2)
            end
            task.wait(0.3)
            safePivotTo(JURASSIC_KICK_READY_CF)
            task.wait(0.4)
        end
        local nests = getJurassicNests()
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        -- getJurassicNests mengembalikan Model Nest secara langsung.
        table.sort(nests, function(a, b)
            local tierA = a:GetAttribute("Tier") or 1
            local tierB = b:GetAttribute("Tier") or 1
            if tierA ~= tierB then
                return tierA > tierB
            end

            if not rootPart then return a.Name < b.Name end
            return (a:GetPivot().Position - rootPart.Position).Magnitude <
                   (b:GetPivot().Position - rootPart.Position).Magnitude
        end)

        local safeNests = {}
        local unsafeNests = {}
        local eraTripFolder = Workspace:FindFirstChild("EraTrip")
        local jurassicFolder = eraTripFolder and eraTripFolder:FindFirstChild("Jurassic")
        local chaser = jurassicFolder and jurassicFolder:FindFirstChild("Chaser")

        for _, nest in ipairs(nests) do
            if nestsVisited[nest] then continue end
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

        for _, nest in ipairs(processingList) do
            if not autoEraTripEnabled or not isInEra("Jurassic") then break end

            local nestPos = nest:GetPivot().Position
            local safe = waitForChaserSafe(nestPos, CHASER_SAFE_DIST)
            if not safe then continue end

            -- Cari semua telur aktif di dalam sarang ini (prompt StealEgg yang Enabled)
            local activePrompts = {}
            for _, desc in ipairs(nest:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Enabled and (desc.Name == "StealEgg" or desc.ActionText == "Steal") then
                    table.insert(activePrompts, desc)
                end
            end

            -- Jika tidak ada telur aktif di nest ini, tandai sudah dikunjungi dan lewati
            if #activePrompts == 0 then
                nestsVisited[nest] = true
                continue
            end

            for _, prompt in ipairs(activePrompts) do
                if not autoEraTripEnabled or not isInEra("Jurassic") then break end
                if getCarriedEggsCount() >= maxCap then break end
                if not prompt.Enabled or not prompt.Parent then continue end

                -- Teleport tepat ke telur (part Egg1)
                local eggPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                local targetPos = eggPart and eggPart.Position or nestPos
                safePivotTo(CFrame.new(targetPos.X, targetPos.Y + 1.2, targetPos.Z))
                task.wait(0.15)

                -- Tangani hold duration (0.7 detik)
                local hold = prompt.HoldDuration or 0.7
                pcall(function()
                    prompt.HoldDuration = 0
                end)
                pcall(function()
                    fireproximityprompt(prompt)
                end)
                -- Berikan jeda waktu hold duration agar server menyelesaikan steal
                task.wait(math.max(0.75, hold + 0.1))

                -- Tunggu hingga telur terambil
                -- Begitu ambil 1 telur langsung setor ke EraCollect!
                if getCarriedEggsCount() >= maxCap then
                    local collectPos = JURASSIC_COLLECT_CF.Position
                    waitForChaserSafe(collectPos, CHASER_SAFE_DIST)

                    -- Deposit ke EraCollect (hatch otomatis ketika pemain berada di EraCollect)
                    safePivotTo(JURASSIC_COLLECT_CF)
                    local depositStart = os.clock()
                    while getCarriedEggsCount() > 0 and os.clock() - depositStart < 3.5 do
                        task.wait(0.2)
                    end
                    task.wait(0.3)

                    -- Kembali ke KickReady untuk lanjut ambil telur berikutnya
                    safePivotTo(JURASSIC_KICK_READY_CF)
                    task.wait(0.4)
                    break
                end
            end

            -- Begitu 1 telur disetor, langsung break loop sarang untuk scan ulang sarang tertinggi berikutnya!
            break
        end

        -- Mampir ke Trader HANYA di menit ke-9 (sisa <= 65s) selama 1 detik untuk borong craft
        checkFinalMinuteTraderCraft("Jurassic", "JurassicMythic", canCraftJurassicMythic, JURASSIC_TRADER_CF, JURASSIC_KICK_READY_CF)

        task.wait(0.3)
    end

    statusParagraph:SetDesc("Jurassic selesai – semua telur terkumpul atau tidak ada lagi yang dapat diambil.")
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
function runAutoEraTrip(myGen)
    -- Jika ada loop lama yang masih jalan, tunggu dia exit dulu (max 3 detik)
    if autoEraTripRunning then
        local t0 = os.clock()
        while autoEraTripRunning and os.clock() - t0 < 3 do
            task.wait(0.1)
        end
    end
    autoEraTripRunning = true
    
    while autoEraTripEnabled and autoEraTripGeneration == myGen do
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
                    while autoEraTripEnabled and autoEraTripGeneration == myGen and os.clock() < deadline do
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
