local E, L, V, P, G = unpack(ElvUI)
local NEL = _G.NelUI

local WQ = NEL:NewModule("WorldQuests", "AceEvent-3.0")
NEL.WorldQuests = WQ

local DT = E:GetModule("DataTexts")

local ANIMA = ANIMA

local TFont = CreateFont("NelUITitleFont")
TFont:SetTextColor(255/255, 210/255, 0/255)
local HFont = CreateFont("NelUIHeaderFont")
HFont:SetTextColor(102/255, 199/255, 255/255)
local RFont = CreateFont("NelUIRegFont")
RFont:SetTextColor(255/255, 255/255, 255/255)

local ZONEID = {2022, 2023, 2024, 2025, 2026, 2085, 2112}
local WORLDQUESTICONS = {
    [113] = "|TInterface\\QUESTFRAME\\WorldQuest:12:12:::512:512:423:439:266:282|t",    -- PVP
    [115] = "|TInterface\\QUESTFRAME\\WorldQuest:12:12:::512:512:51:66:452:465|t",      -- PETBATTLE
    [111] = "|TInterface\\QUESTFRAME\\WorldQuest:12:12:::512:512:42:76:383:419|t",      -- ELITE WORLDQUESTS
    [112] = "|TInterface\\QUESTFRAME\\WorldQuest:12:12:::512:512:42:76:383:419|t",      -- ELITE WORLDQUESTS
    [136] = "|TInterface\\QUESTFRAME\\WorldQuest:12:12:::512:512:42:76:383:419|t",      -- ELITE WORLDQUESTS
}

local WORLDQUESTS = {
    ["totalQuests"] = 0,
    ["totalAnima"] = 0,
    ["totalGold"] = 0,
}

local function FormatMoneyReward(money)
    local str = ""
    
    local value  = abs(money)
    local gold   = floor(value / 10000)
    local silver = floor((value / 100) % 100)
    local copper = floor(value % 100)
    
    if gold > 0 then
        str = format("%d%s%s", gold, "|cffffd700g|r", (silver > 0 or copper > 0) and " " or "")
    end
    if silver > 0 then
        str = format("%s%d%s%s", str, silver, "|cffc7c7cfs|r", copper > 0 and " " or "")
    end
    if copper > 0 or value == 0 then
        str = format("%s%d%s", str, copper, "|cffeda55fc|r")
    end
    
    return str
end

local function FormatTimeLeft(timeLeft)
    if timeLeft <= 0 then return "" end
    local timeLeftStr = ""

    if timeLeft >= 60 then -- hours
        timeLeftStr = string.format("%.0fh", math.floor(timeLeft / 60))
    end

    timeLeftStr = string.format("%s%s%sm", timeLeftStr, timeLeftStr ~= "" and " " or "", timeLeft % 60) -- always show minutes

    if         timeLeft <= 120 then timeLeftStr = string.format("|cffD96932%s|r", timeLeftStr)
    elseif     timeLeft <= 240 then timeLeftStr = string.format("|cffDBA43B%s|r", timeLeftStr)
    elseif     timeLeft <= 480 then timeLeftStr = string.format("|cffE6D253%s|r", timeLeftStr)
    elseif     timeLeft <= 960 then timeLeftStr = string.format("|cffE6DA8E%s|r", timeLeftStr)
    end
    
    return timeLeftStr
end

local function GetAnimaValue(itemID)
    local _, itemLink = GetItemInfo(itemID)

    if itemLink then
        NEL.ScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
        NEL.ScanTooltip:SetHyperlink(itemLink)
        local numLines = NEL.ScanTooltip:NumLines()
        local isAnima = false
        
        for i = 2, numLines do
            local text = _G["NELScanTooltipTextLeft" .. i]:GetText()

            if text then
                if text:find("Anima") then isAnima = true end

                if isAnima and text:find(ITEM_SPELL_TRIGGER_ONUSE) then
                    local power = text:gsub(" ", ""):match("%d+%p?%d*") or "0"
                    
                    power = power:gsub("%p", "")

                    return tonumber(power)
                end
            end
        end
    end

    return 0
end

local function GetItemLevelValueForQuestID(questID)
    NEL.ScanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    NEL.ScanTooltip:SetQuestLogItem("reward", 1, questID)
    local numLines = NEL.ScanTooltip:NumLines()
    
    for i = 2, numLines do
        local text = _G["NELScanTooltipTextLeft" .. i]:GetText()
        local e = ITEM_LEVEL_PLUS:find("%%d")
        
        if text and text:find(ITEM_LEVEL_PLUS:sub(1, e - 1)) then
            return text:match("%d+%+?") or nil
        end
    end
    
    return nil
end

local function GetWorldQuestReward(questID)
    local reward = {}

    if GetNumQuestLogRewards(questID) > 0 then
        local itemName, itemTexture, numItems, quality, isUsable, itemID, itemLevel = GetQuestLogRewardInfo(1, questID)

        if GetAnimaValue(itemID) ~= 0 then
            reward.anima = GetAnimaValue(itemID) * numItems
        else
            local item = {}

            item.itemID = itemID
            item.name = itemName
            item.texture = itemTexture
            item.numItems = numItems
            item.quality = quality

            item.itemLevel = GetItemLevelValueForQuestID(questID)

            reward.item = item
        end
    end

    if GetQuestLogRewardMoney(questID) > 20000 then
        local money = GetQuestLogRewardMoney(questID)
        reward.money = money
    end

    if GetQuestLogRewardHonor(questID) > 0 then
        local honor = GetQuestLogRewardHonor(questID)
        reward.honor = honor
    end
    
    if GetQuestLogRewardCurrencyInfo(1, questID) then
        local currency = {}
        local name, texture, numItems, currencyID = GetQuestLogRewardCurrencyInfo(1, questID)

        currency.currencyID = currencyID
        currency.name = name
        currency.texture = texture
        currency.numItems = numItems

        reward.currency = currency
    end

    return reward
end

local function GetRewards(reward)
    local rewardText = ""

    if reward.item then
        local itemText = string.format("%s[%s%s]|r", 
            ITEM_QUALITY_COLORS[reward.item.quality].hex,
            reward.item.itemLevel and (reward.item.itemLevel .. " ") or "",
            reward.item.name
        )
        rewardText = string.format("|T%s:0:0:0:0:64:64:4:60:4:60|t %s%s",
            reward.item.texture,
            reward.item.numItems > 1 and reward.item.numItems .. "x " or "",
            itemText
        )
    end

    if reward.anima then
        rewardText = string.format("%s%s|T%s:0:0:0:0:64:64:4:60:4:60|t %s[%s %s]|r",
            rewardText,
            rewardText ~= "" and "   " or "",
            3528288,
            ITEM_QUALITY_COLORS[6].hex,
            reward.anima,
            "Anima"
        )
    end

    if reward.currency then
        rewardText = string.format("%s%s|T%s:0:0:0:0:64:64:4:60:4:60|t %s: %d %s",
            rewardText,
            rewardText ~= "" and "   " or "",
            reward.currency.texture,
            reward.currency.name,
            reward.currency.numItems,
            REPUTATION
        )
    end

    if reward.money and reward.money > 0 then
        local moneyText = GetCoinTextureString(reward.money)
        rewardText = string.format("%s%s%s",
            rewardText,
            rewardText ~= "" and "   " or "",
            moneyText
        )
    end

    if reward.honor and reward.honor > 0 then
        rewardText = string.format("%s%s|T%s:0:0:0:0:64:64:4:60:4:60|t %d %s",
            rewardText,
            rewardText ~= "" and "   " or "",
            1455894,
            reward.honor,
            HONOR
        )
    end

    return rewardText
end

function WQ:GetCurrentWorldQuests()
    WORLDQUESTS.totalQuests = 0
    WORLDQUESTS.totalAnima = 0
    WORLDQUESTS.totalGold = 0

    for i, zoneID in pairs(ZONEID) do
        local quests = C_TaskQuest.GetQuestsForPlayerByMapID(zoneID)
        
        if #quests > 0 then
            WORLDQUESTS[zoneID] = {}
            for j, quest in pairs(quests) do
                local temp = {}
                local questID = quest.questId
                local numObjectives = quest.numObjectives

                local questTagInfo = C_QuestLog.GetQuestTagInfo(questID)

                if questTagInfo then
                    if questTagInfo.worldQuestType ~= nil then
                        local tagID, title, reward, faction, factionID, timeLeft, isRare, reward

                        tagID = questTagInfo.tagID
                        title, factionID = C_TaskQuest.GetQuestInfoByQuestID(questID)
                        faction = factionID and GetFactionInfoByID(factionID)

                        timeLeft = C_TaskQuest.GetQuestTimeLeftMinutes(questID) or 0
                        isRare = questTagInfo.quality

                        reward = GetWorldQuestReward(questID)

                        temp.zoneID = zoneID
                        temp.x = quest.x
                        temp.y = quest.y

                        temp.questID = questID
                        temp.numObjectives = numObjectives

                        temp.tagID = tagID
                        temp.title = title
                        temp.faction = faction

                        temp.timeLeft = timeLeft
                        temp.isRare = isRare

                        temp.reward = reward

                        table.insert(WORLDQUESTS[zoneID], temp)

                        if reward.anima then
                            WORLDQUESTS.totalAnima = WORLDQUESTS.totalAnima + reward.anima
                        end

                        if reward.money then
                            WORLDQUESTS.totalGold = WORLDQUESTS.totalGold + reward.money
                        end
                    end
                end
            end
        end

        WORLDQUESTS.totalQuests = WORLDQUESTS.totalQuests + #quests
    end
end

local mapTextures = CreateFrame("Frame", "WQ_MapTextures", WorldMapFrame:GetCanvas())
mapTextures:SetSize(200,200)
mapTextures:SetFrameStrata("DIALOG")
mapTextures:SetFrameLevel(2001)

local highlightArrow = mapTextures:CreateTexture("highlightArrow")
highlightArrow:SetTexture("Interface\\minimap\\MiniMap-DeadArrow")
highlightArrow:SetSize(56, 56)
highlightArrow:SetRotation(3.14)
highlightArrow:SetPoint("CENTER", mapTextures)
highlightArrow:SetDrawLayer("ARTWORK", 1)
mapTextures.highlightArrow = highlightArrow

local animationGroup = mapTextures:CreateAnimationGroup()
animationGroup:SetLooping("REPEAT")
animationGroup:SetScript("OnPlay", function(self) mapTextures.highlightArrow:Show() end)
animationGroup:SetScript("OnStop", function(self) mapTextures.highlightArrow:Hide() end)

local downAnimation = animationGroup:CreateAnimation("Translation")
downAnimation:SetChildKey("highlightArrow")
downAnimation:SetOffset(0, -10)
downAnimation:SetDuration(0.4)
downAnimation:SetOrder(1)

local upAnimation = animationGroup:CreateAnimation("Translation")
upAnimation:SetChildKey("highlightArrow")
upAnimation:SetOffset(0, 10)
upAnimation:SetDuration(0.4)
upAnimation:SetOrder(2)

mapTextures.animationGroup = animationGroup
WQ.mapTextures = mapTextures

local function ShowQuestObjectiveTooltip(self, quest)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:SetFrameLevel(self:GetFrameLevel() + 1)

    local color = WORLD_QUEST_QUALITY_COLORS[quest.isRare]
    GameTooltip:AddLine(quest.title, color.r, color.g, color.b, true)

    for objectiveIndex = 1, quest.numObjectives do
        local objectiveText, objectiveType, finished = GetQuestObjectiveInfo(quest.questID, objectiveIndex, false)
        if objectiveText and #objectiveText > 0 then
            color = finished and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR
            GameTooltip:AddLine(QUEST_DASH .. objectiveText, color.r, color.g, color.b, true)
        end
    end

    local percent = C_TaskQuest.GetQuestProgressBarInfo(quest.questID)
    if percent then
        GameTooltip_ShowProgressBar(GameTooltip, 0, 100, percent, PERCENTAGE_STRING:format(percent))
    end
    GameTooltip:Show()
end

local function ShowQuestLogItemTooltip(self, questID)
    local itemName, itemTexture, numItems, quality, isUsable, itemID, itemLevel = GetQuestLogRewardInfo(1, questID)

    if itemName and itemTexture then
        if GetAnimaValue(itemID) > 0 then return end

        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        NEL.ScanTooltip:SetQuestLogItem("reward", 1, questID)
            
        GameTooltip:SetFrameLevel(self:GetFrameLevel()+1)

        local _, itemLink = NEL.ScanTooltip:GetItem()
        GameTooltip:SetHyperlink(itemLink)

        GameTooltip:SetFrameLevel(5)

        GameTooltip:Show()
    end
end

local function CalculateMapPosition(x, y)
    return x * WorldMapFrame:GetCanvas():GetWidth() , -1 * y * WorldMapFrame:GetCanvas():GetHeight() 
end

local function ShowWorldQuestOnWorldMap(self, quest)
    if not WorldMapFrame:IsShown() then ShowUIPanel(WorldMapFrame) end
    if WorldMapFrame:IsShown() then
        WorldMapFrame:SetMapID(quest.zoneID)
        if quest.x and quest.y then
            local x, y = CalculateMapPosition(quest.x, quest.y)
            local scale = WorldMapFrame:GetCanvasScale()
            local size = 30 / scale

            WQ.mapTextures:ClearAllPoints()
            WQ.mapTextures.highlightArrow:SetSize(size, size)
            WQ.mapTextures:SetPoint("CENTER", WorldMapFrame:GetCanvas(), "TOPLEFT", x, y + 25 + (scale < 0.5 and 50 or 0))
            WQ.mapTextures.animationGroup:Play()
        end
    end
end

local function CreateTooltip(self)
    if NEL.LQT:IsAcquired("NelUI WorldQuests") then
        tooltip:Clear()
    else
        tooltip = NEL.LQT:Acquire("NelUI WorldQuests", 5)

        HFont:SetFont(GameTooltipHeaderText:GetFont())
        RFont:SetFont(GameTooltipText:GetFont())
        
        tooltip:SetHeaderFont(HFont)
        tooltip:SetFont(RFont)
 
        tooltip:SetHighlightTexture(nil)
        
        tooltip:SetAutoHideDelay(0.1, self)
        tooltip:SmartAnchorTo(self)

        tooltip:ClearAllPoints()
        tooltip:SetPoint("BOTTOM", self, "TOP", 0, 4)
    end

    for i, zoneID in pairs(ZONEID) do
        if WORLDQUESTS[zoneID] then
            local quests = WORLDQUESTS[zoneID]

            line = tooltip:AddLine()
            line = tooltip:SetCell(line, 1, C_Map.GetMapInfo(zoneID).name, HFont, "LEFT", 5)
            line = tooltip:AddSeparator(1, 108/255, 115/255, 120/255)

            for k, quest in NEL.spairs(quests, function(t, a, b) return t[a].timeLeft < t[b].timeLeft end) do
                line = tooltip:AddLine()
                line = tooltip:SetCell(line, 1, WORLDQUESTICONS[quest.tagID], "LEFT")
                line = tooltip:SetCell(line, 2, WORLD_QUEST_QUALITY_COLORS[quest.isRare].hex..quest.title.."|r", "LEFT")
                line = tooltip:SetCell(line, 3, GetRewards(quest.reward), "LEFT")
                line = tooltip:SetCell(line, 4, quest.faction, "LEFT")
                line = tooltip:SetCell(line, 5, FormatTimeLeft(quest.timeLeft), "RIGHT")

                tooltip:SetCellScript(line, 2, "OnEnter", ShowQuestObjectiveTooltip, quest)
                tooltip:SetCellScript(line, 2, "OnLeave", function() GameTooltip:Hide() end)
                tooltip:SetCellScript(line, 2, "OnMouseUp", ShowWorldQuestOnWorldMap, quest)

                tooltip:SetCellScript(line, 3, "OnEnter", ShowQuestLogItemTooltip, quest.questID)
                tooltip:SetCellScript(line, 3, "OnLeave", function() GameTooltip:Hide() end)
                tooltip:SetCellScript(line, 3, "OnMouseUp", ShowWorldQuestOnWorldMap, quest)

                tooltip:SetLineScript(line, "OnMouseUp", ShowWorldQuestOnWorldMap, quest)
            end

            if i ~= #ZONEID then
                tooltip:AddLine(" ")
            end
        end
    end

    if WORLDQUESTS.totalQuests == 0 then
        tooltip:Clear()

        line = tooltip:AddLine()
        line = tooltip:SetCell(line, 1, "No World Quest available!", HFont, "LEFT", 5)
    end

    tooltip:Show()
end

local function OnEvent(self)
    local totalAnima = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t %d", 3528288, 12, 12, WORLDQUESTS.totalAnima)
    local totalGold = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t %d", "Interface\\Minimap\\Tracking\\Auctioneer", 12, 12, WORLDQUESTS.totalGold / 10000)

    self.text:SetText(format("%s %s", totalAnima, totalGold))
end

local function OnEnter(self)
    WQ.GetCurrentWorldQuests()
    CreateTooltip(self)
end

function WQ:PLAYER_LOGIN()
    self:GetCurrentWorldQuests()
end

function WQ:QUEST_LOG_UPDATE()
    self:GetCurrentWorldQuests()
end

function WQ:OnInitialize()
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("QUEST_LOG_UPDATE")

    hooksecurefunc(WorldMapFrame, "Hide", function(self)
        WQ.mapTextures.animationGroup:Stop()
    end)

    hooksecurefunc(WorldMapFrame, "OnMapChanged", function(self)
        WQ.mapTextures.animationGroup:Stop()
    end)
end

local events = {
    "PLAYER_LOGIN", 
    "QUEST_LOG_UPDATE"
}

DT:RegisterDatatext("WorldQuests", "NelUI", events, OnEvent, nil, nil, OnEnter)