local E, L, V, P, G = unpack(ElvUI)
local NEL = _G.NelUI

local Skin = E:GetModule("Skins")

function NEL:CreateOptionFrame()
    local frame = CreateFrame("Frame", "NelUIOptionFrame", UIParent)
    frame:SetTemplate("Transparent")
    frame:Size(858, 660)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("HIGH")

    frame:SetMovable(true)
    frame:EnableMouse(true)

    frame:SetScript("OnMouseDown", function(frame, button)
        if button == "LeftButton" and not frame.isMoving then
            frame:StartMoving()
            frame.isMoving = true
        end
    end)
    frame:SetScript("OnMouseUp", function(frame, button)
        if button == "LeftButton" and frame.isMoving then
            frame:StopMovingOrSizing()
            frame.isMoving = false
        end
    end)

    local header = frame:CreateFontString(frame, "OVERLAY", "GameTooltipText")
    header:SetPoint("TOP", 0, -13)
    header:SetText(format("%s - %s", NEL.Title, NEL.Version))

    local close = CreateFrame("Button", "NelUIOptionFrameCloseButton", frame, "UIPanelCloseButton")
    close:Point("TOPRIGHT", 5, 5)
    close:SetFrameLevel(close:GetFrameLevel() + 1)
    close:EnableMouse(true)

    local setupChat = CreateFrame("Button", "NelUIOptionFrameSetupChatButton", frame, "UIPanelButtonTemplate")
    setupChat:SetSize(170, 24)
    setupChat:SetPoint("TOPRIGHT", -22, -40)
    setupChat:SetText("Setup Chat")

    setupChat:SetScript("OnClick", function() 
        NEL.SetupChat()
        ReloadUI()
    end)

    local content = CreateFrame("Frame", "NelUIOptionFrameContent", frame)
    content:SetTemplate("Transparent")
    content:SetPoint("TOPLEFT", 199, -70)
    content:SetPoint("BOTTOMRIGHT", -22, 22)

    Skin:HandleCloseButton(close)
    Skin:HandleButton(setupChat)

    self:CreateOptionMenu()

    frame:Hide()
end

function NEL:CreateOptionMenu()
    local general = CreateFrame("Button", "NelUIOptionMenuGeneral", NelUIOptionFrame, "UIPanelButtonTemplate")
    general:SetSize(175, 24)
    general:SetPoint("TOPLEFT", 22, -70)
    general:SetText("General")

    local am = CreateFrame("Button", "NelUIOptionMenuAltManager", general, "UIPanelButtonTemplate")
    am:SetSize(175, 24)
    am:SetPoint("TOP", general, "BOTTOM", 0, -2)
    am:SetText("Alt Manager")

    local sw = CreateFrame("Button", "NelUIOptionMenuStatWeights", am, "UIPanelButtonTemplate")
    sw:SetSize(175, 24)
    sw:SetPoint("TOP", am, "BOTTOM", 0, -2)
    sw:SetText("Stat Weights")

    Skin:HandleButton(general)
    Skin:HandleButton(am)
    Skin:HandleButton(sw)
end

SLASH_NELUICHAT1 = "/nelui"
SlashCmdList["NELUICHAT"] = function()
    if NelUIOptionFrame:IsShown() then
        NelUIOptionFrame:Hide()
    else
        NelUIOptionFrame:Show()
    end
end