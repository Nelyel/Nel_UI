local E, L, V, P, G = unpack(ElvUI)
local NEL = _G.NelUI

local DT = E:GetModule("DataTexts")

local TFont = CreateFont("NelUIGuildTitleFont")
TFont:SetTextColor(255/255, 210/255, 0/255)
local HFont = CreateFont("NelUIGuildHeaderFont")
HFont:SetTextColor(102/255, 199/255, 255/255)
local RFont = CreateFont("NelUIGuildRegFont")
RFont:SetTextColor(255/255, 210/255, 0/255)

local function OnEvent(self)
    if IsInGuild() then
        local _, _, numOnline = GetNumGuildMembers()
        self.text:SetFormattedText("%s: %s", _G.GUILD, WrapTextInColorCode(numOnline, "ff008cff"))
    else
        self.text:SetText(WrapTextInColorCode("No Guild", "ff008cff"))
    end
end

local function OnClick(self, button)
    if button == "LeftButton" then
        ToggleGuildFrame(1)
    end
end

local function ClickMember(frame, index, button)
    local name = GetGuildRosterInfo(index)

    if button == "LeftButton" then
        SetItemRef("player:"..name, format("|Hplayer:%1$s|h[%1$s]|h", name), "LeftButton")
    elseif button == "RightButton" then
        C_PartyInfo.InviteUnit(name)
    end
end

local function CreateGuildTooltip(self)
    if not IsInGuild() then return end

    if NEL.LQT:IsAcquired("NelUI Guild") then
        tooltip:Clear()
    else
        tooltip = NEL.LQT:Acquire("NelUI Guild", 5)

        tooltip:SetBackdropColor(0, 0, 0, 1)

        HFont:SetFont(GameTooltipHeaderText:GetFont())
        RFont:SetFont(GameTooltipText:GetFont())
        tooltip:SetHeaderFont(HFont)
        tooltip:SetFont(RFont)

        tooltip:SmartAnchorTo(self)

        tooltip:ClearAllPoints()
        tooltip:SetPoint("BOTTOM", self, "TOP", 0, 4)

        tooltip:SetAutoHideDelay(0.2, self)
    end

    local line = tooltip:AddLine()
    local guildName, guildRank = GetGuildInfo("player")
    local numTotal, _, numOnline = GetNumGuildMembers()

    tooltip:SetCell(line, 1, guildName, HFont, "LEFT", 3)
    tooltip:SetCell(line, 4, format("%d/%d", numOnline, numTotal), HFont, "RIGHT", 2)

    line = tooltip:AddLine()
    tooltip:SetCell(line, 1, guildRank, 5)

    tooltip:AddLine(" ")

    line = tooltip:AddLine()
    line = tooltip:SetCell(line, 2, _G.NAME, HFont,"LEFT")
    line = tooltip:SetCell(line, 3, _G.ZONE, HFont, "LEFT")
    line = tooltip:SetCell(line, 4, _G.RANK, HFont, "LEFT")
    line = tooltip:SetCell(line, 5, _G.LABEL_NOTE, HFont, "LEFT")

    tooltip:AddSeparator()

    for i = 1,  numTotal do
        local statusInfo
        local info = GetGuildRosterInfo(i)
        local name, rank, _, level, _, zoneName, note, officerNote, connected, memberstatus, class, _, _, isMobile, _, _, guid = GetGuildRosterInfo(i)

        if memberstatus == 1 then statusInfo = WrapTextInColorCode("  ©", "ffff9900")
        elseif memberstatus == 2 then statusInfo = WrapTextInColorCode("  ©", "ffff3333")
        else statusInfo = "" end

        if connected then
            local classColor = RAID_CLASS_COLORS[string.gsub(string.upper(class), " ", "")].colorStr
            name = strsplit("-", name)

            line = tooltip:AddLine()
            line = tooltip:SetCell(line, 1, NEL.SetLevelColor(level)..statusInfo, "LEFT")
            line = tooltip:SetCell(line, 2, format("|c%s%s|r", classColor, name), "LEFT")
            line = tooltip:SetCell(line, 3, zoneName, "LEFT")
            line = tooltip:SetCell(line, 4, rank, "LEFT")
            line = tooltip:SetCell(line, 5, note, "LEFT")

            tooltip:SetLineScript(line, "OnMouseUp", ClickMember, i)
        end
    end

    tooltip:UpdateScrolling()
    tooltip:Show()
end

local events = {
    "CHAT_MSG_SYSTEM", 
    "GUILD_ROSTER_UPDATE", 
    "PLAYER_GUILD_UPDATE", 
    "GUILD_MOTD"
}

DT:RegisterDatatext("Guild", "NelUI", events, OnEvent, nil, OnClick, CreateGuildTooltip)