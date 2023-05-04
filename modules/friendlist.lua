local NEL = _G.NelUI

local FL = NEL:NewModule("FriendList", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
NEL.FriendList = FL

local ONE_MINUTE = 60
local ONE_HOUR = 60 * ONE_MINUTE
local ONE_DAY = 24 * ONE_HOUR
local ONE_MONTH = 30 * ONE_DAY
local ONE_YEAR = 12 * ONE_MONTH

function FL:UpdateFriends(button)
    local nameText, infoText
    local cooperateColor = GRAY_FONT_COLOR

    if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
        local info = C_FriendList.GetFriendInfoByIndex(button.id)

        if info.connected then
            local name, level, class = info.name, info.level, info.className
            local classcolor = RAID_CLASS_COLORS[string.gsub(string.upper(class), " ", "")].colorStr

            nameText = format("%s |cFFFFFFFF(|r%s - %s %s|cFFFFFFFF)|r", WrapTextInColorCode(name, classcolor), class, LEVEL, WrapTextInColorCode(level, "FFFFE519"))
            infoText = info.area

            button.gameIcon:Show()
            button.gameIcon:SetTexture("Interface/WorldStateFrame/Icons-Classes")
            button.gameIcon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[string.gsub(string.upper(class), " ", "")]))
        else
            nameText = info.name
        end
    elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
        local info = NEL.GetBattleNetInfo(button.id)

        if info then
            nameText = info.accountName
            infoText = info.gameAccountInfo.richPresence

            if info.gameAccountInfo.isOnline then
                local client = info.gameAccountInfo.clientProgram

                if client == BNET_CLIENT_WOW then
                    local level = info.gameAccountInfo.characterLevel
                    local characterName = info.gameAccountInfo.characterName

                    if characterName then
                        local classcolor

                        if info.gameAccountInfo.className and info.gameAccountInfo.characterLevel then
                            classcolor = RAID_CLASS_COLORS[string.gsub(string.upper(info.gameAccountInfo.className), " ", "")].colorStr
                            nameText = format("%s (%s - %s %s)", nameText, WrapTextInColorCode(characterName, classcolor), LEVEL, WrapTextInColorCode(level, "FFFFE519"))
                        else
                            nameText = format("%s", nameText)
                        end

                        if info.gameAccountInfo.areaName and info.gameAccountInfo.realmDisplayName then
                            infoText = format("%s - %s", info.gameAccountInfo.areaName, info.gameAccountInfo.realmDisplayName)
                        end
                        
                        if info.gameAccountInfo.realmDisplayName == GetRealmName() and info.gameAccountInfo.factionName == UnitFactionGroup("player") then
                            cooperateColor = LIGHTYELLOW_FONT_COLOR
                        end
                    end

                    local faction = info.gameAccountInfo.factionName

                    button.gameIcon:SetTexture(faction and NEL.Games[faction].Icon or NEL.Games.Neutral.Icon)
                else
                    nameText = format("|cFF%s%s|r", NEL.Games[client].Color or "FFFFFF", nameText)
                    button.gameIcon:SetTexture(NEL.Games[client].Icon)
                end

                button.gameIcon:SetTexCoord(0, 1, 0, 1)
                button.gameIcon:SetDrawLayer("OVERLAY")
                button.gameIcon:SetAlpha(1)
                button.gameIcon:SetScale(1.1)
            else
                local lastOnline = info.lastOnlineTime

                infoText = (not lastOnline or lastOnline == 0 or time() - lastOnline >= ONE_YEAR) and FRIENDS_LIST_OFFLINE or format(BNET_LAST_ONLINE_TIME, FriendsFrame_GetLastOnline(lastOnline))
            end
        end
    end

    if nameText then button.name:SetText(nameText) end
    if infoText then button.info:SetText(infoText) end

    if button.Favorite and button.Favorite:IsShown() then
        button.Favorite:ClearAllPoints()
        button.Favorite:SetPoint("TOPLEFT", button.name, "TOPLEFT", button.name:GetStringWidth(), 0)
    end

    button.info:SetTextColor(cooperateColor.r, cooperateColor.g, cooperateColor.b)
end

function FL:OnInitialize()
    self:SecureHook("FriendsFrame_UpdateFriendButton", "UpdateFriends")
end