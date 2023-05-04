local E, L, V, P, G = unpack(ElvUI)
local NEL = _G.NelUI

function NEL.spairs(t, order)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function NEL.SetupChat()
    FCF_ResetChatWindows()

    FCF_SetLocked(_G.ChatFrame1, 1)
    FCF_SetLocked(_G.ChatFrame2, 1)
    FCF_SetLocked(_G.ChatFrame3, 1)

    FCF_OpenNewWindow(GENERAL)
    FCF_OpenNewWindow(LOOT)

    for _, name in ipairs(_G.CHAT_FRAMES) do
        local frame = _G[name]
        local id = frame:GetID()

        FCF_SavePositionAndDimensions(frame)
        FCF_StopDragging(frame)
        FCF_SetChatWindowFontSize(nil, frame, 12)

        if id == 1 then
            FCF_SetWindowName(frame, "G, S & W")
        elseif id == 2 then
            FCF_SetWindowName(frame, GUILD_EVENT_LOG)
        elseif id == 3 then
            VoiceTranscriptionFrame_UpdateVisibility(frame)
            VoiceTranscriptionFrame_UpdateVoiceTab(frame)
            VoiceTranscriptionFrame_UpdateEditBox(frame)
        end
    end

    local chatGroup = {
        "SAY", "EMOTE", "YELL", "GUILD", "OFFICER", "GUILD_ACHIEVEMENT",
        "ACHIEVEMENT", "WHISPER", "BN_WHISPER", "BN_CONVERSATION", "PARTY", "PARTY_LEADER",
        "RAID", "RAID_LEADER", "RAID_WARNING", "BATTLEGROUND", "BATTLEGROUND_LEADER", "INSTANCE_CHAT",
        "INSTANCE_CHAT_LEADER", "SYSTEM", "ERRORS", "IGNORED", "AFK", "DND",
        "BN_INLINE_TOAST_ALERT", "ACHIEVEMENT", "MONSTER_SAY", "MONSTER_EMOTE", "MONSTER_YELL", "MONSTER_WHISPER",
        "MONSTER_BOSS_EMOTE", "MONSTER_BOSS_WHISPER", "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL"
    }

    ChatFrame_RemoveAllMessageGroups(_G.ChatFrame1)
    for _, v in ipairs(chatGroup) do
        ChatFrame_AddMessageGroup(_G.ChatFrame1, v)
    end

    ChatFrame_RemoveChannel(_G.ChatFrame1, GENERAL)
    ChatFrame_RemoveChannel(_G.ChatFrame1, TRADE)
    ChatFrame_RemoveChannel(_G.ChatFrame1, L["LocalDefense"])

    ChatFrame_RemoveAllMessageGroups(_G.ChatFrame4)
    ChatFrame_AddChannel(_G.ChatFrame4, GENERAL)
    ChatFrame_AddChannel(_G.ChatFrame4, TRADE)
    ChatFrame_AddChannel(_G.ChatFrame4, L["LocalDefense"])

    chatGroup = {
        "COMBAT_FACTION_CHANGE", "SKILL", "LOOT", "MONEY", "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN",
        "COMBAT_GUILD_XP_GAIN", "CURRENCY"
    }

    ChatFrame_RemoveAllMessageGroups(_G.ChatFrame5)
    for _, v in ipairs(chatGroup) do
        ChatFrame_AddMessageGroup(_G.ChatFrame5, v)
    end

   chatGroup = {
        "SAY", "EMOTE", "YELL", "WHISPER", "PARTY", "PARTY_LEADER", 
        "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD",
        "OFFICER", "ACHIEVEMENT", "GUILD_ACHIEVEMENT", "COMMUNITIES_CHANNEL" 
    }

    for i = 1, _G.MAX_WOW_CHAT_CHANNELS do
        tinsert(chatGroup, 'CHANNEL'..i)
    end

    for _, v in ipairs(chatGroup) do
        ToggleChatColorNamesByClassGroup(true, v)
    end
end

function NEL.SetLevelColor(level)
    if level ~= "" then
        local color = GetQuestDifficultyColor(level)
        local colored = format("|cff%02x%02x%02x%d|r", color.r * 255, color.g * 255, color.b * 255, level)

        return colored
    end
end

function NEL.GetBattleNetInfo(friendIndex)
    local accountInfo = C_BattleNet.GetFriendAccountInfo(friendIndex)
    local client, gameText, wowProjectID = accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.richPresence, accountInfo.gameAccountInfo.wowProjectID

    if client == _G.BNET_CLIENT_WOW and wowProjectID ~= 1 then
        local _, realmName = strsplit("-", gameText)
        if realmName then
            accountInfo.gameAccountInfo.realmDisplayName = realmName:sub(2)
        end
    end

    return accountInfo
end