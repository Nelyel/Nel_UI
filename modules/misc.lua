local E, L, V, P, G = unpack(ElvUI)
local NEL = _G.NelUI

local MC = NEL:NewModule("Misc", "AceEvent-3.0")
NEL.Misc = MC

-----------------------------------
-- DETAILS BACKDROP
-----------------------------------

local details = CreateFrame("Frame", "NelUIDetailsBackdrop", UIParent)
details:SetTemplate("Transparent")
details:Size(E.db.chat.panelWidthRight + 0.5, E.db.chat.panelHeightRight)
details:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -(E.db.chat.panelWidthRight + 10 + 2), 25)
details:SetFrameStrata("BACKGROUND")
details:SetFrameLevel(300)

-----------------------------------
-- FASTERLOOT
-----------------------------------

local function LootItems()
    if MC.isLooting then
        return
    end
    
    for i = 0, NUM_BAG_SLOTS do
        if not C_Container.GetBagName(i) then
            MC.HaveEmptyBagSlots = MC.HaveEmptyBagSlots + 1
        end
    end

    local link, itemEquipLoc, bindType, _
    if (GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE")) then
        MC.isLooting = true
        for i = GetNumLootItems(), 1, -1 do
            link = GetLootSlotLink(i)
            LootSlot(i)
            if link then
                itemEquipLoc, _, _, _, _, bindType = select(9, GetItemInfo(link))

                if itemEquipLoc == "INVTYPE_BAG" and bindType < 2 and MC.HaveEmptyBagSlots > 0 then
                    EquipItemByName(link)
                end
            end
        end
    end
end

local function LootClosed()
    MC.isLooting = false
    MC.HaveEmptyBagSlots = 0
end

function MC:FasterLoot()
    MC.HaveEmptyBagSlots = 0

    LOOTFRAME_AUTOLOOT_DELAY = 0.1
    LOOTFRAME_AUTOLOOT_RATE = 0.1

    MC:RegisterEvent("LOOT_READY", LootItems)
    MC:RegisterEvent("LOOT_OPENED", LootItems)
    MC:RegisterEvent("LOOT_CLOSED", LootClosed)
end

-----------------------------------
-- READYCHECK
-----------------------------------

local function PlayReadyCheckSound()
    PlaySound(SOUNDKIT.READY_CHECK, "master")
end

function MC:ReadyCheck()
    self:RegisterEvent("READY_CHECK", PlayReadyCheckSound)
end

-----------------------------------
-----------------------------------
-----------------------------------

function MC:OnInitialize()
    self:FasterLoot()
    self:ReadyCheck()
end