local NEL = _G.NelUI

local AM = NEL:NewModule("AltManager", "AceEvent-3.0")
NEL.AltManager = AM

local MAWASSAULT = {
    63543,  -- Necrolord Assault
    63822,  -- Venthyr Assault
    63823,  -- Night Fae Assault
    63824,  -- Kyrian Assault
}

local function GetKeystone()
    local keystone = "unk. +?"

    local dungeonID = {
    -- MISTS OF PANDARIA
        [2] =   "TJS",   -- Temple of the Jade 
        [165] = "SBG",   -- Shadowmoon Burial Grounds

	-- WARLORD OF DRAENOR
	    [166] = "GD",    -- Grimrail Depot
	    [169] = "ID",    -- Iron Docks

	-- LEGION
        [200] = "HOV",   -- Halls of Valor
        [210] = "COS",   -- Court of Stars
	    [227] = "LOWR",  -- Lower Karazhan
	    [234] = "UPPR",  -- Upper Karazhan

	-- BATTLE OF AZEROTH
	    [369] = "YARD",  -- Mechagon Junkyard
	    [370] = "WORK",  -- Mechagon Workshop

	-- SHADOWLANDS
        [375] = "MISTS", -- Mists of Tirna Scithe
        [376] = "NW",    -- The Necrotic Wake
        [377] = "DOS",   -- De Other Side
        [378] = "HOA",   -- Halls of Atonement
        [379] = "PF",    -- Plaguefall
        [380] = "SD",    -- Sanguine Depths
        [381] = "SOA",   -- Spires of Ascension
        [382] = "TOP",   -- Theater of Pain
        [391] = "STRT",  -- Tazavesh: Streets of Wonder
        [392] = "GMBT",  -- Tazavesh: Gambit

    -- DRAGONFLIGHT
        [399] = "RLP",   -- Ruby Life Pools
        [400] = "NO",    -- The Nokhud Offensive
        [401] = "AV",    -- The Azure Vault
        [402] = "AA",    -- Algeth'ar Academy
        [403] = "ULT",   -- Uldaman: Legacy of Tyr
        [404] = "NEL",   -- Neltharus
        [405] = "BH",    -- Brackenhide Hollow
        [406] = "HOI",   -- Halls of Infusion
    }

    if C_MythicPlus.GetOwnedKeystoneChallengeMapID() then
        local dungeon = dungeonID[tonumber(C_MythicPlus.GetOwnedKeystoneChallengeMapID())] or ""

        local level = C_MythicPlus.GetOwnedKeystoneLevel()

        keystone = format("%s +%d", dungeon, level)
    end

    return keystone
end

local function GetCurrencyInfo(id)
    local table = {}

    table.quantity = C_CurrencyInfo.GetCurrencyInfo(id).quantity
    table.iconFileID = C_CurrencyInfo.GetCurrencyInfo(id).iconFileID

    return table
end

local function GetGreatVaultProgress()
    local vault = {{},{},{}}

    for i = 1, 3 do
        for _, tier in pairs(C_WeeklyRewards.GetActivities(i)) do
            local temp = {}
            local itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(tier.id)

            temp.index = tier.index
            temp.progress = tier.progress
            temp.threshold = tier.threshold
            temp.reward = itemLink and GetDetailedItemLevelInfo(itemLink) or 0

            table.insert(vault[i], temp)
        end
    end
    
    return vault
end

local function GetGreatVaultReset()
    local vault = {{},{},{}}
    local threshold = {{1,4,8},{1250,2500,5000},{2,4,6}}

    for i = 1, 3 do
        for j = 1, 3 do
            local temp = {}

            temp.index = j
            temp.progress = 0
            temp.threshold = threshold[i][j]
            temp.reward = 0

            table.insert(vault[i], temp)
        end
    end

    return vault
end

function AM:GetCharacters(filter)
    local db = NEL.alts
    local realms, chars  = {}, {}

    for realm in NEL.spairs(db, function(t, a, b) return t[a].order < t[b].order end) do
        table.insert(realms, realm)

        local order = db[realm].order
        db[realm].order = nil

        local temp = {}
        for char in NEL.spairs(db[realm], function(t, a, b) return t[a].order < t[b].order end) do
            if filter then
                if db[realm][char].show then table.insert(temp, char) end
            else
                table.insert(temp, char)
            end
        end
        table.insert(chars, temp)

        db[realm].order = order
    end

    return realms, chars
end

function AM:GetNumCharacters(t)
    local num = 0
    for realm, v in pairs(t) do
        num = num + #t[realm]
    end

    return num
end

function AM:ValidateReset()
    if not NEL.alts then return end
    local REALMS, CHARS = AM:GetCharacters()

    for i, realm in pairs(REALMS) do
        for _, char in pairs(CHARS[i]) do
            local table = NEL.alts[realm][char]

            local weeklyreset = table.weeklyreset or 0

            if time() > weeklyreset then
                table.keystone = "unk. +?"
                table.greatvault = GetGreatVaultReset()

                table.weeklyreset = self:GetNextWeeklyResetTime()
            end
        end
    end
end

function AM:CollectData()
    local guid  = NEL.MyGUID
    local name  = NEL.MyName
    local realm = NEL.MyRealm
    
    local _, ilvl = GetAverageItemLevel()
    local _, class = UnitClass("player")
    
    local renown = C_CovenantSanctumUI.GetRenownLevel()
    
    local keystone = GetKeystone()
    
    local currency = {
        [1810] = GetCurrencyInfo(1810),
        [1813] = GetCurrencyInfo(1813),
        [1828] = GetCurrencyInfo(1828),
        [1906] = GetCurrencyInfo(1906),
    }

    local greatvault = GetGreatVaultProgress()
    
    local table = {}

    table.guid = guid
    table.name = name
    table.realm = realm

    table.ilvl = ilvl
    table.class = class

    table.renown = renown

    table.keystone = keystone
    
    table.currency = currency
    table.greatvault = greatvault

    table.weeklyreset = self:GetNextWeeklyResetTime()

    return table
end

function AM:StoreData(data)
    if not self.addonLoaded then return end
    if not data or not data.guid then return end

    if UnitLevel("player") < 60 then return end

    local db = NEL.alts
    local realm = data.realm
    local guid = data.guid

    db[realm] = db[realm] or {["order"] = 1}

    local update = false
    for k, v in pairs(db[realm]) do
        if k == guid then
            update = true
        end
    end

    if not update then
        db[realm][guid] = data
        db[realm][guid].show = true
        db[realm][guid].order = 1
    else
        local show, order = db[realm][guid].show, db[realm][guid].order
        db[realm][guid] = data
        db[realm][guid].show = show
        db[realm][guid].order = order
    end
end

function AM:InitDB()
    return {}
end

function AM:ADDON_LOADED(...)
    local event, addon = ...
    if event == "ADDON_LOADED" then
        if addon == "NelUI" then
            self:UnregisterEvent("ADDON_LOADED")
            self.addonLoaded = true

            NelDB.altmanager = NelDB.altmanager or self:InitDB()
        end
    end
end

function AM:PLAYER_LOGIN()
    self:ValidateReset()
    self:StoreData(self:CollectData())
end

function AM:PLAYER_LEAVING_WORLD()
    self:StoreData(self:CollectData())
end

function AM:CHAT_MSG_CURRENCY()
    self:StoreData(self:CollectData())
end

function AM:OnInitialize()
    NelDB.altmanager = NelDB.altmanager or self:InitDB()
    NEL.alts = NelDB.altmanager

    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("CHAT_MSG_CURRENCY")
end

-----------------------------------
-- MISC (COPYRIGHT SAVEDINSTANCES)
-----------------------------------
function AM:GetServerOffset()
    local weekday = C_DateAndTime.GetCurrentCalendarTime().weekday
    local serverDay = weekday - 1
    local localDay = tonumber(date("%w"))
    local serverHour, serverMinute = GetGameTime()
    local localHour, localMinute = tonumber(date("%H")), tonumber(date("%M"))
    if serverDay == (localDay + 1) % 7 then
        serverHour = serverHour + 24
    elseif localDay == (serverDay + 1) % 7 then
        localHour = localHour + 24
    end
    local server = serverHour + serverMinute / 60
    local localT = localHour + localMinute / 60
    local offset = floor((server - localT) * 2 + 0.5) / 2
    return offset
end

function AM:GetRegion()
    if not self.region then
        local reg
        reg = GetCVar("portal")
        if reg == "public-test" then
            reg = "US"
        end
        if not reg or #reg ~= 2 then
            local gcr = GetCurrentRegion()
            reg = gcr and ({ "US", "KR", "EU", "TW", "CN" })[gcr]
        end
        if not reg or #reg ~= 2 then
            reg = (GetCVar("realmList") or ""):match("^(%a+)%.")
        end
        if not reg or #reg ~= 2 then
            reg = (GetRealmName() or ""):match("%((%a%a)%)")
        end
        reg = reg and reg:upper()
        if reg and #reg == 2 then
            self.region = reg
        end
    end
    return self.region
end

function AM:GetNextDailyResetTime()
    local resettime = GetQuestResetTime()
    if not resettime or resettime <= 0 or
        resettime > 24 * 3600 + 30 then
        return nil
    end
    if false then
        local serverHour, serverMinute = GetGameTime()
        local serverResetTime = (serverHour * 3600 + serverMinute * 60 + resettime) % 86400
        local diff = serverResetTime - 10800
        if math.abs(diff) > 3.5 * 3600
            and self:GetRegion() == "US" then
            local diffhours = math.floor((diff + 1800) / 3600)
            resettime = resettime - diffhours * 3600
            if resettime < -900 then
                resettime = resettime + 86400
                elseif resettime > 86400 + 900 then
                resettime = resettime - 86400
            end
        end
    end
    return time() + resettime
end

function AM:GetNextMidWeekResetTime()
    if (self:GetNextWeeklyResetTime() - 302400) > time() then
        return self:GetNextWeeklyResetTime() - 302400
    end

    return self:GetNextWeeklyResetTime()
end

function AM:GetNextWeeklyResetTime()
    if not self.resetDays then
        local region = self:GetRegion()
        if not region then return nil end
        self.resetDays = {}
        self.resetDays.DLHoffset = 0
        if region == "US" then
            self.resetDays["2"] = true
            self.resetDays.DLHoffset = -3 
        elseif region == "EU" then
            self.resetDays["3"] = true
        elseif region == "CN" or region == "KR" or region == "TW" then
            self.resetDays["4"] = true
        else
            self.resetDays["2"] = true
        end
    end
    local offset = (self:GetServerOffset() + self.resetDays.DLHoffset) * 3600
    local nightlyReset = self:GetNextDailyResetTime()
    if not nightlyReset then return nil end
    while not self.resetDays[date("%w", nightlyReset + offset)] do
        nightlyReset = nightlyReset + 24 * 3600
    end
    return nightlyReset
end