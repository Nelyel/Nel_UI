local E, L, V, P, G = unpack(ElvUI)
local NEL = _G.NelUI

local DT = E:GetModule("DataTexts")

local function OnUpdate(self)
    local slash = WrapTextInColorCode("/", "ff008cff")
    local colon = WrapTextInColorCode(":", "ff008cff")

    local day, month, year = date("%d"), date("%m"), date("%y")
    local hours, minutes, seconds = date("%H"), date("%M"), date("%S")

    local date = format("%02d%s%02d%s%d", day, slash, month, slash, year)
    local time = format("%02d%s%02d%s%02d", hours, colon, minutes, colon, seconds)

    self.text:SetText(date.." - "..time)
end

local function OnClick(self)
    ToggleCalendar()
end

DT:RegisterDatatext("Time", "NelUI", nil, nil, OnUpdate, OnClick)