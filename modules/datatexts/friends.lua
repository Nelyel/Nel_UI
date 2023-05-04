local E, L, V, P, G = unpack(ElvUI)
local NEL = _G.NelUI

local DT = E:GetModule("DataTexts")
local ANCHOR

local _G = _G

local FRIENDS_TABLE = {
    ["wowRetail"] = {},
    ["wowClassic"] = {},
    ["otherGames"] = {},
    ["bnet"] = {}
}

local SHOW_FRIENDS_TABLE = {
    ["wowRetail"] = true,
    ["wowClassic"] = true,
    ["otherGames"] = true,
    ["bnet"] = false
}

local TFont = CreateFont("NelUIFriendsTitleFont")
TFont:SetTextColor(255/255, 210/255, 0/255)
local HFont = CreateFont("NelUIFriendsHeaderFont")
HFont:SetTextColor(102/255, 199/255, 255/255)
local RFont = CreateFont("NelUIFriendsRegFont")
RFont:SetTextColor(255/255, 210/255, 0/255)

local function BuildFriendsTable()
    FRIENDS_TABLE.wowRetail = {}
    FRIENDS_TABLE.wowClassic = {}
    FRIENDS_TABLE.otherGames = {}
    FRIENDS_TABLE.bnet = {}

    local _, onlineBN = BNGetNumFriends()
    local online = C_FriendList.GetNumOnlineFriends()

    -- BATTLE.NET FRIENDS
    for i = 1, onlineBN do
        local info = NEL.GetBattleNetInfo(i)

        local bnetAccountID, accountName, client, gameText, wowProjectID, note, isAFK, isDND = info.bnetAccountID, info.accountName, info.gameAccountInfo.clientProgram, info.gameAccountInfo.richPresence, info.gameAccountInfo.wowProjectID, info.note, info.gameAccountInfo.isGameAFK, info.isDND
        local level, characterName, class, zoneName, realmName, faction = info.gameAccountInfo.characterLevel, info.gameAccountInfo.characterName, info.gameAccountInfo.className, info.gameAccountInfo.areaName, info.gameAccountInfo.realmDisplayName, info.gameAccountInfo.factionName

        local statusInfo = false
        if isAFK then statusInfo = WrapTextInColorCode("©", "ffff9900") end
        if isDND then statusInfo = WrapTextInColorCode("©", "ffff3333") end

        if client == BNET_CLIENT_WOW or client == "WoW" then
            if wowProjectID == 1 then
                FRIENDS_TABLE.wowRetail[#FRIENDS_TABLE.wowRetail + 1] = {
                    ["level"] = level, 
                    ["characterName"] = characterName,
                    ["class"] = class,
                    ["faction"] = faction,
                    ["zoneName"] = zoneName, 
                    ["realmName"] = realmName,
                    ["bnetAccountID"] = bnetAccountID, 
                    ["accountName"] = accountName, 
                    ["note"] = note,
                    ["statusInfo"] = statusInfo,
                    ["isBattleNetFriend"] = true
                }
            else
                FRIENDS_TABLE.wowClassic[#FRIENDS_TABLE.wowClassic + 1] = {
                    ["level"] = level, 
                    ["characterName"] = characterName,
                    ["class"] = class,
                    ["faction"] = faction,
                    ["zoneName"] = zoneName, 
                    ["realmName"] = realmName,
                    ["bnetAccountID"] = bnetAccountID, 
                    ["accountName"] = accountName, 
                    ["note"] = note,
                    ["statusInfo"] = statusInfo,
                    ["isBattleNetFriend"] = true
                }
            end 
        elseif client ~= BNET_CLIENT_APP and client ~= "BSAp" then
            FRIENDS_TABLE.otherGames[#FRIENDS_TABLE.otherGames + 1] = {
                ["bnetAccountID"] = bnetAccountID,
                ["accountName"] = accountName,
                ["client"] = client,
                ["gameText"] = gameText,
                ["note"] = note,
                ["statusInfo"] = statusInfo,
                ["isBattleNetFriend"] = true
            }
        else
            FRIENDS_TABLE.bnet[#FRIENDS_TABLE.bnet + 1] = {
                ["bnetAccountID"] = bnetAccountID,
                ["accountName"] = accountName,
                ["client"] = client,
                ["note"] = note,
                ["statusInfo"] = statusInfo,
                ["isBattleNetFriend"] = true
            }
        end
    end
end

local function HideCategory(cell, category)
    if category == "RETAIL" then SHOW_FRIENDS_TABLE.wowRetail = not SHOW_FRIENDS_TABLE.wowRetail end
    if category == "CLASSIC" then SHOW_FRIENDS_TABLE.wowClassic = not SHOW_FRIENDS_TABLE.wowClassic end
    if category == "OTHER_GAMES" then SHOW_FRIENDS_TABLE.otherGames = not SHOW_FRIENDS_TABLE.otherGames end
    if category == "BATTLENET" then SHOW_FRIENDS_TABLE.bnet = not SHOW_FRIENDS_TABLE.bnet end

    CreateFriendsTooltip(ANCHOR)
end

local function ClickRetail(frame, info, button)
    if button == "LeftButton" then
        if info.isBattleNetFriend then
            if IsAltKeyDown() then
                _G["FriendsFrame"].NotesID = info.bnetAccountID
                StaticPopup_Show("SET_BNFRIENDNOTE", info.accountName)
                return
            end
            ChatFrame_SendBNetTell(info.accountName)
        else
            if IsAltKeyDown() then
                _G["FriendsFrame"].NotesID = info.characterName
                StaticPopup_Show("SET_FRIENDNOTE", info.characterName)
                return
            end
            SetItemRef("player:"..info.characterName, format("|Hplayer:%1$s|h[%1$s]|h", info.characterName), "LeftButton")
        end
    elseif button == "RightButton" then
        C_PartyInfo.InviteUnit(info.characterName.."-"..info.realmName)
    end
end

local function ClickFriends(frame, info, button)
    if button == "LeftButton" then
        if info.isBattleNetFriend then
            if IsAltKeyDown() then
                _G["FriendsFrame"].NotesID = info.bnetAccountID
                StaticPopup_Show("SET_BNFRIENDNOTE", info.accountName)
                return
            end
            ChatFrame_SendBNetTell(info.accountName)
        end
    end
end

local function OnEvent(self, event)
    local online = C_FriendList.GetNumOnlineFriends()
    local _, onlineBN = BNGetNumFriends()

    self.text:SetFormattedText("%s: %s", _G.FRIENDS, WrapTextInColorCode(online + onlineBN, "ff008cff"))
end

local function OnClick(self, button)
    if button == "LeftButton" then
        ToggleFriendsFrame(1)
    end
end

function CreateFriendsTooltip(self)
    ANCHOR = self

    BuildFriendsTable()

    if NEL.LQT:IsAcquired("NelUI Friends") then
        tooltip:Clear()
    else
        tooltip = NEL.LQT:Acquire("NelUI Friends", 7)

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

    local online = C_FriendList.GetNumOnlineFriends()
    local totalBN, onlineBN = BNGetNumFriends()

    tooltip:SetCell(line, 1, _G.FRIENDS, HFont, "LEFT", 6)
    tooltip:SetCell(line, 7, format("%d/%d", online + onlineBN, totalBN), HFont, "RIGHT")

    tooltip:AddLine(" ")

    -- RETAIL
    if #FRIENDS_TABLE.wowRetail > 0 then
        line = tooltip:AddLine()
        tooltip:SetCell(line, 1, (SHOW_FRIENDS_TABLE.wowRetail and "|cffffffff- WoW Retail|r" or "|cffffffff+ WoW Retail|r"), HFont, "LEFT", 7)
        tooltip:SetLineScript(line, "OnMouseUp", HideCategory, "RETAIL")

        if SHOW_FRIENDS_TABLE.wowRetail then
            line = tooltip:AddHeader()
            line = tooltip:SetCell(line, 1, "", "RIGHT")
            line = tooltip:SetCell(line, 2, "Character", "LEFT")
            line = tooltip:SetCell(line, 3, "", "CENTER")
            line = tooltip:SetCell(line, 4, _G.NAME, "LEFT")
            line = tooltip:SetCell(line, 5, _G.ZONE, "LEFT")
            line = tooltip:SetCell(line, 6, "Realm", "LEFT")
            line = tooltip:SetCell(line, 7, _G.LABEL_NOTE, "LEFT")

            tooltip:AddSeparator()

            for _, info in ipairs(FRIENDS_TABLE.wowRetail) do
                line = tooltip:AddLine()
                if info.class and info.level then
                    local classColor = RAID_CLASS_COLORS[string.gsub(string.upper(info.class), " ", "")].colorStr

                    line = tooltip:SetCell(line, 1, NEL.SetLevelColor(info.level), "RIGHT")
                    line = tooltip:SetCell(line, 2, format("|c%s%s|r", classColor, info.characterName), "LEFT")
                    line = tooltip:SetCell(line, 5, info.zoneName, "LEFT")
                    line = tooltip:SetCell(line, 6, format("|c%s%s|r", info.faction == "Horde" and "ffff2020" or "ff0070dd", info.realmName), "LEFT")
                end

                if info.statusInfo then
                    line = tooltip:SetCell(line, 3, info.statusInfo, "CENTER")
                end

                line = tooltip:SetCell(line, 4, WrapTextInColorCode(info.accountName, "ff82c5ff"), "LEFT")
                line = tooltip:SetCell(line, 7, info.note, "LEFT")

                tooltip:SetLineScript(line, "OnMouseUp", ClickRetail, info)
            end

            tooltip:AddLine(" ")
        end
    end

    -- CLASSIC
    if #FRIENDS_TABLE.wowClassic > 0 then
        line = tooltip:AddLine()
        tooltip:SetCell(line, 1, (SHOW_FRIENDS_TABLE.wowClassic and "|cffffffff- WoW Classic|r" or "|cffffffff+ WoW Classic|r"), HFont, "LEFT", 7)
        tooltip:SetLineScript(line, "OnMouseUp", HideCategory, "CLASSIC")

        if SHOW_FRIENDS_TABLE.wowClassic then
            line = tooltip:AddHeader()
            line = tooltip:SetCell(line, 1, "", "RIGHT")
            line = tooltip:SetCell(line, 2, "Character", "LEFT")
            line = tooltip:SetCell(line, 3, "", "CENTER")
            line = tooltip:SetCell(line, 4, _G.NAME, "LEFT")
            line = tooltip:SetCell(line, 5, _G.ZONE, "LEFT")
            line = tooltip:SetCell(line, 6, "Realm", "LEFT")
            line = tooltip:SetCell(line, 7, _G.LABEL_NOTE, "LEFT")

            tooltip:AddSeparator()

            for _, info in ipairs(FRIENDS_TABLE.wowClassic) do
                local classColor = RAID_CLASS_COLORS[string.gsub(string.upper(info.class), " ", "")].colorStr

                line = tooltip:AddLine()
                line = tooltip:SetCell(line, 1, NEL.SetLevelColor(info.level), "RIGHT")
                line = tooltip:SetCell(line, 2, format("|c%s%s|r", classColor, info.characterName), "LEFT")

                if info.statusInfo then
                    line = tooltip:SetCell(line, 3, info.statusInfo, "CENTER")
                end

                line = tooltip:SetCell(line, 4, WrapTextInColorCode(info.accountName, "ff82c5ff"), "LEFT")
                line = tooltip:SetCell(line, 5, info.zoneName, "LEFT")
                line = tooltip:SetCell(line, 6, WrapTextInColorCode(info.realmName, info.faction == "Horde" and "ffff2020" or "ff0070dd"), "LEFT")
                line = tooltip:SetCell(line, 7, info.note, "LEFT")

                tooltip:SetLineScript(line, "OnMouseUp", ClickFriends, info)
            end

            tooltip:AddLine(" ")
        end
    end

    -- OTHER GAMES
    if #FRIENDS_TABLE.otherGames > 0 then
        line = tooltip:AddLine()
        tooltip:SetCell(line, 1, (SHOW_FRIENDS_TABLE.otherGames and "|cffffffff- Other Games|r" or "|cffffffff+ Other Games|r"), HFont, "LEFT", 7)
        tooltip:SetLineScript(line, "OnMouseUp", HideCategory, "OTHER_GAMES")

        if SHOW_FRIENDS_TABLE.otherGames then
            line = tooltip:AddHeader()
            line = tooltip:SetCell(line, 1, _G.NAME, "LEFT", 2)
            line = tooltip:SetCell(line, 3, "", "CENTER")
            line = tooltip:SetCell(line, 4, "Game", "LEFT")
            line = tooltip:SetCell(line, 5, "Information", "LEFT", 2)
            line = tooltip:SetCell(line, 7, _G.LABEL_NOTE, "LEFT")

            tooltip:AddSeparator()

            for _, info in ipairs(FRIENDS_TABLE.otherGames) do
                line = tooltip:AddLine()
                line = tooltip:SetCell(line, 1, format("|c%s%s|r", "ff82c5ff", info.accountName), "LEFT", 2)

                if info.statusInfo then
                    line = tooltip:SetCell(line, 3, info.statusInfo, "CENTER")
                end

                line = tooltip:SetCell(line, 4, WrapTextInColorCode(NEL.Games[info.client].Name, "ff"..NEL.Games[info.client].Color), "LEFT")
                line = tooltip:SetCell(line, 5, info.gameText, "LEFT", 2)
                line = tooltip:SetCell(line, 7, info.note, "LEFT")

                tooltip:SetLineScript(line, "OnMouseUp", ClickFriends, info)
            end

            tooltip:AddLine(" ")
        end
    end

    if #FRIENDS_TABLE.bnet > 0 then
        line = tooltip:AddLine()
        tooltip:SetCell(line, 1, (SHOW_FRIENDS_TABLE.bnet and "|cffffffff- Battle.net|r" or "|cffffffff+ Battle.net|r"), HFont, "LEFT", 6)
        tooltip:SetLineScript(line, "OnMouseUp", HideCategory, "BATTLENET")

        if SHOW_FRIENDS_TABLE.bnet then
            line = tooltip:AddHeader()
            line = tooltip:SetCell(line, 1, _G.NAME, "LEFT", 2)
            line = tooltip:SetCell(line, 3, "", "CENTER")
            line = tooltip:SetCell(line, 4, "Client", "LEFT", 3)
            line = tooltip:SetCell(line, 7, _G.LABEL_NOTE, "LEFT")

            tooltip:AddSeparator()

            for _, info in ipairs(FRIENDS_TABLE.bnet) do
                line = tooltip:AddLine()
                line = tooltip:SetCell(line, 1, format("|c%s%s|r", "ff82c5ff", info.accountName), "LEFT", 2)
                if info.statusInfo then
                    line = tooltip:SetCell(line, 3, info.statusInfo, "CENTER")
                end
                line = tooltip:SetCell(line, 4, WrapTextInColorCode(NEL.Games[info.client].Name, "ff"..NEL.Games[info.client].Color), "LEFT", 3)
                line = tooltip:SetCell(line, 7, info.note, "LEFT")

                tooltip:SetLineScript(line, "OnMouseUp", ClickFriends, info)
            end
        end
    end
    
    tooltip:UpdateScrolling()
    tooltip:Show()
end

local events = {
    "PLAYER_ENTERING_WORLD",
    "BN_FRIEND_ACCOUNT_ONLINE",
    "BN_FRIEND_ACCOUNT_OFFLINE",
    "BN_FRIEND_INFO_CHANGED",
    "FRIENDLIST_UPDATE",
    "CHAT_MSG_SYSTEM"
}

DT:RegisterDatatext("Friends", "NelUI", events, OnEvent, nil, OnClick, CreateFriendsTooltip)