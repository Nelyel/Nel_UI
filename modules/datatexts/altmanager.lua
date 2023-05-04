local E, L, V, P, G = unpack(ElvUI)
local NEL = _G.NelUI

local DT = E:GetModule("DataTexts")

local TFont = CreateFont("NelUITitleFont")
TFont:SetTextColor(255/255, 210/255, 0/255)
local HFont = CreateFont("NelUIHeaderFont")
HFont:SetTextColor(102/255, 199/255, 255/255)
local RFont = CreateFont("NelUIRegFont")
RFont:SetTextColor(255/255, 255/255, 255/255)

local LABELS = {
    [1] = {["line"] = 5,  ["label"] = "Renown:"},
    [2] = {["line"] = 7,  ["label"] = "Keystone:"},
    [3] = {["line"] = 9,  ["label"] = "Torghast:"},
    [4] = {["line"] = 10, ["label"] = "Maw:"},
    [5] = {["line"] = 12, ["label"] = "Legendary:"},
    [6] = {["line"] = 15, ["label"] = "Currency:"},
    [7] = {["line"] = 18, ["label"] = "Raids:"},
    [8] = {["line"] = 19, ["label"] = "M+:"},
}

local function GetCurrency(t)
    local quantity, iconFileID = t.quantity, t.iconFileID

    iconFileID = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", iconFileID, 12, 12)

    return format("%s %s", iconFileID, quantity)
end

local function GetGreatVaultProgress(vault)
    local progress, count = "", 0

    for i, t in NEL.spairs(vault, function(t, a, b) return t[a].threshold < t[b].threshold end) do
        if t.progress < t.threshold then
            progress = format("%s%s/%s|r", progress, t.progress, t.threshold)
        else
            local color = t.reward == 421 and "6c7378" or "ffffff"
            progress = format("%s|cff%s%s|r", progress, color, t.reward)
        end

        local spacer = count < 2 and " - " or ""
        count = count + 1

        progress = progress..spacer
    end

    return progress
end

local function CreateTooltip(self)
    local data = NEL.AltManager:CollectData()
    NEL.AltManager:StoreData(data)

    local REALMS, CHARS = NEL.AltManager:GetCharacters(true)
    local numChars = NEL.AltManager:GetNumCharacters(CHARS)

    if NEL.LQT:IsAcquired("NelUI AltManager") then
        tooltip:Clear()
    else
        tooltip = NEL.LQT:Acquire("NelUI AltManager", numChars + 1)

        HFont:SetFont(GameTooltipHeaderText:GetFont())
        RFont:SetFont(GameTooltipText:GetFont())

        tooltip:SetHeaderFont(HFont)
        tooltip:SetFont(RFont)

        tooltip:SmartAnchorTo(self)

        tooltip:ClearAllPoints()
        tooltip:SetPoint("BOTTOM", self, "TOP", 0, 4)

        tooltip:SetAutoHideDelay(0.1, self)
    end

    for i = 1, 19 do
        if i == 2 or i == 4 or i == 6 or i == 8 or i == 11 or i == 14 or i == 17 then
            tooltip:AddSeparator(1, 108/255, 115/255, 120/255)
        else
            tooltip:AddLine()
        end
    end

    for i = 1, #LABELS do
        tooltip:SetCell(LABELS[i].line, 1, LABELS[i].label, "RIGHT")
    end

    local cChars, pRealm = 1, 2
    for i, realm in pairs(REALMS) do
        tooltip:SetCell(1, pRealm, format("|c%s%s|r", "ff6c7378", realm), "LEFT", #CHARS[i])
        for j, char in pairs(CHARS[i]) do
            local c = NEL.alts[realm][char]

            local pChar = cChars + 1
            tooltip:SetCell(3,  pChar, format("|c%s%s|r |c%silvl %.2f|r", RAID_CLASS_COLORS[c.class].colorStr, c.name, "ff6c7378", c.ilvl), "CENTER")
            tooltip:SetCell(5,  pChar, c.renown, "CENTER")
            tooltip:SetCell(7,  pChar, c.keystone, "CENTER")
            --tooltip:SetCell(9,  pChar, format("|cff%s%d/2|r", c.torghast == 2 and "6c7378" or "ffffff", c.torghast), "CENTER")
            --tooltip:SetCell(10, pChar, format("|cff%sA|r - |cff%sT|r", c.maw.assault and "6c7378" or "ffffff" ,c.maw.tormentors and "6c7378" or "ffffff"), "CENTER")
            tooltip:SetCell(12, pChar, GetCurrency(c.currency[1828]), "CENTER")
            tooltip:SetCell(13, pChar, GetCurrency(c.currency[1906]), "CENTER")
            tooltip:SetCell(15, pChar, GetCurrency(c.currency[1813]), "CENTER")
            tooltip:SetCell(16, pChar, GetCurrency(c.currency[1810]), "CENTER")
            tooltip:SetCell(18, pChar, GetGreatVaultProgress(c.greatvault[3]), "CENTER")
            tooltip:SetCell(19, pChar, GetGreatVaultProgress(c.greatvault[1]), "CENTER")

            cChars = cChars + 1
        end

        pRealm = cChars + 1

        if cChars > numChars then return tooltip:Show() end  
    end

    tooltip:Show()
end

local function OnEvent(self)
    local keystone = "unk. +?"
    if NEL.alts[NEL.MyRealm][NEL.MyGUID].keystone then
        keystone = NEL.alts[NEL.MyRealm][NEL.MyGUID].keystone
    end

    local quantity = C_CurrencyInfo.GetCurrencyInfo(1813).quantity
    local iconFileID = C_CurrencyInfo.GetCurrencyInfo(1813).iconFileID

    iconFileID = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", iconFileID, 12, 12)

    local currency = format("%s %s", iconFileID, quantity)

    self.text:SetText(format("Keystone: %s | %s", keystone, currency))
end

local function OnClick(self)
    LoadAddOn("Blizzard_WeeklyRewards")
    WeeklyRewardsFrame:Show()
end

local function OnEnter(self)
    CreateTooltip(self)
end

local events = {
    "PLAYER_ENTERING_WORLD",
    "CHAT_MSG_CURRENCY",
    "CURRENCY_DISPLAY_UPDATE",
    "BAG_UPDATE_DELAYED",
    "CHALLENGE_MODE_COMPLETED"
}

DT:RegisterDatatext("Alt Manager", "NelUI", events, OnEvent, nil, OnClick, OnEnter)