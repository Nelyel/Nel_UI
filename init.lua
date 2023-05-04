local E, L, V, P, G = unpack(ElvUI)
local _G = _G

local AddOnName = ...
local LibStub = LibStub

local NEL = LibStub("AceAddon-3.0"):NewAddon(AddOnName)

_G.NelUI = NEL

NEL.LQT = LibStub("LibQTip-1.0")
NEL.LSM = LibStub("LibSharedMedia-3.0")

NEL.Title = format("|cffc41f3b%s|r|cffffffff%s|r", "Nel", "UI")
NEL.Version = GetAddOnMetadata("NelUI", "Version")

NEL.MyGUID = UnitGUID("player")
NEL.MyName = UnitName("player")
NEL.MyRealm = GetRealmName("player")

NEL.MediaPath = "Interface\\AddOns\\NelUI\\media\\"

NEL.Games = {
    ODIN = {Color = "FFFFFF", Name = "Call of Duty: MW",         Icon = NEL.MediaPath..[[icons\codmw]]},
    AUKS = {Color = "FFFFFF", Name = "Call of Duty: MW2",        Icon = NEL.MediaPath..[[icons\codmw2]]},
    VIPR = {Color = "FFFFFF", Name = "Call of Duty: BO 4",       Icon = NEL.MediaPath..[[icons\codbo4]]},
    ZEUS = {Color = "FFFFFF", Name = "Call of Duty: BO CW",      Icon = NEL.MediaPath..[[icons\codbocw]]},
    FORE = {Color = "FFFFFF", Name = "Call of Duty: VG",         Icon = NEL.MediaPath..[[icons\codbocw]]},
    DST2 = {Color = "FFFFFF", Name = "Destiny 2",                Icon = NEL.MediaPath..[[icons\destiny2]]},
    OSI  = {Color = "C41F3B", Name = "Diablo 2: Resurrected",    Icon = NEL.MediaPath..[[icons\d2]]},
    D3   = {Color = "C41F3B", Name = "Diablo 3",                 Icon = NEL.MediaPath..[[icons\d3]]},
    ANBS = {Color = "C41F3B", Name = "Diablo Immortal",          Icon = NEL.MediaPath..[[icons\di]]},
    WTCG = {Color = "FFB100", Name = "Hearthstone",              Icon = NEL.MediaPath..[[icons\hs]]},
    Hero = {Color = "00CCFF", Name = "Hero of the Storm",        Icon = NEL.MediaPath..[[icons\hots]]},
    Pro  = {Color = "FFFFFF", Name = "Overwatch",                Icon = NEL.MediaPath..[[icons\ow]]},
    S1   = {Color = "C495DD", Name = "Starcraft",                Icon = NEL.MediaPath..[[icons\sc]]},
    S2   = {Color = "C495DD", Name = "Starcraft 2",              Icon = NEL.MediaPath..[[icons\sc2]]},
    GRY  = {Color = "FFFFFF", Name = "Warcraft Arclight Rumble", Icon = NEL.MediaPath..[[icons\arclight]]},
    W3   = {Color = "FFFFFF", Name = "Warcraft 3 Reforged",      Icon = NEL.MediaPath..[[icons\wc3r]]},
    App  = {Color = "82C5FF", Name = "Desktop Application",      Icon = NEL.MediaPath..[[icons\battlenet]]},
    BSAp = {Color = "82C5FF", Name = "Mobile App",               Icon = NEL.MediaPath..[[icons\battlenet]]},

    -- WORLD OF WARCRAFT FACTION ICONS
    WoW  = {Color = "FFFFFF", Name = "World of Warcraft"},

    Alliance = {Icon = NEL.MediaPath..[[icons\alliance]]},
    Horde    = {Icon = NEL.MediaPath..[[icons\horde]]},
    Neutral  = {Icon = NEL.MediaPath..[[icons\neutral]]}
}

NEL.ClassicRealmNameByID = {
    -- AMERICAS & OCEANIA
    [4715] = "Anathema",                [4716] = "Arcanite Reaper",         [4669] = "Arugal",
    [4387] = "Ashkandi",                [4372] = "Atiesh",                  [4376] = "Azuresong",
    [4728] = "Benediction",             [4398] = "Bigglesworth",            [4397] = "Blaumeux",
    [4648] = "Bloodsail Buccaneers",    [4386] = "Deviate Delight",         [4731] = "Earthfury",
    [4408] = "Faerlina",                [4396] = "Fairbanks",               [4739] = "Felstriker",
    [4647] = "Grobbulus",               [4732] = "Heartseeker",             [4406] = "Herod",
    [4698] = "Incendius",               [4700] = "Kirtonos",                [4699] = "Kromcrush",
    [4399] = "Kurinnaxx",               [4801] = "Loatheb",                 [4384] = "Mankrik",
    [4373] = "Myzrael",                 [4729] = "Netherwind",              [4374] = "Old Blanchy",
    [4385] = "Pagle",                   [4695] = "Rattlegore",              [4667] = "Remulos",
    [4410] = "Skeram",                  [4696] = "Smolderweb",              [4409] = "Stalagg",
    [4737] = "Sul'thraze",              [4726] = "Sulfuras",                [4407] = "Thalnos",
    [4714] = "Thunderfury",             [4388] = "Westfall",                [4395] = "Whitemane",
    [4727] = "Windseeker",              [4670] = "Yojamba",

    --EUROPE
    [4703] = "Amnennar",                [4742] = "Ashbringer",              [4441] = "Auberdine",
    [4746] = "Bloodfang",               [4759] = "Celebras",                [4452] = "Chromie",
    [4756] = "Dragon's Call",           [4751] = "Dragonfang",              [4755] = "Dreadmist",
    [4749] = "Earthshaker",             [4440] = "Everlook",                [4744] = "Finkle",
    [4467] = "Firemaw",                 [4474] = "Flamegor",                [4706] = "Flamelash",
    [4702] = "Gandling",                [4476] = "Gehennas",                [4465] = "Golemagg",
    [4766] = "Harbinger of Doom",       [4763] = "Heartstriker",            [4678] = "Hydraxian Waterlords",
    [4758] = "Judgement",               [4442] = "Lakeshire",               [4463] = "Lucifron",
    [4813] = "Mandokir",                [4454] = "Mirage Raceway",          [4701] = "Mograine",
    [4456] = "Nethergarde Keep",        [4741] = "Noggenfogger",            [4466] = "Patchwerk",
    [4453] = "Pyrewood Village",        [4455] = "Razorfen",                [4478] = "Razorgore",
    [4754] = "Rhok'delar",              [4475] = "Shazzrah",                [4743] = "Skullflame",
    [4705] = "Stonespine",              [4464] = "Sulfuron",                [4757] = "Ten Storms",
    [4745] = "Transcendence",           [4477] = "Venoxis",                 [4704] = "Wyrmthalak",
    [4676] = "Zandalar Tribe",

    --SoM
    [5264] = "Kingsfall"
}

NEL.ScanTooltip = CreateFrame("GameTooltip", "NELScanTooltip", nil, "GameTooltipTemplate")

function NEL:InitDB()
    return {}
end

function NEL:InitConfig()
    return {}
end

function NEL:InitDefaultProfile()
    local t = {
        ["AltManager"] = {
            ["enable"] = true
        },
    }

    return t
end

function NEL:OnInitialize()
    NelDB = NelDB or self:InitDB()
    NelDB.config = NelDB.config or self:InitConfig()
    NelDB.config.modules = NelDB.config.modules or self:InitDefaultProfile()

    NEL.config = NelDB.config

    --self:CreateOptionFrame()
end