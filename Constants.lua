

local name, addon = ...;

StaticPopupDialogs["FANCY_PANELS_CONFIRM_LEARN_PREVIEW_TALENTS"] = {
	text = CONFIRM_LEARN_PREVIEW_TALENTS,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		LearnPreviewTalents(data.isPet);
	end,
	OnCancel = function(dialog, data)
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

StaticPopupDialogs['FancyPanelsSaveLoadoutDialog'] = {
    text = "%s.",
    button1 = YES,
    button2 = NO,
    OnAccept = function(self, data)
        local str = self.editBox:GetText()
        if str and (#str > 0) and (str ~= " ") then
            data.callback(str)
        end
    end,
    OnCancel = function(self)

    end,
    timeout = 0,
    hasEditBox = true,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = 1,
}

StaticPopupDialogs['FancyPanelsConfirmTalentRecordTalentSpendDialog'] = {
    text = "%s.",
    button1 = PREVIEW,
    button2 = LEARN,
    button3 = NO,
    OnAccept = function(self, data)
        data.accept()
    end,
    OnAlt = function(self, data)
        data.cancel()
    end,
    OnCancel = function(self, data)
        data.alt()
    end,
    timeout = 0,
    --hasEditBox = true,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
    showAlert = 1,
}

addon.Constants = {}

addon.Constants.StarterBuilds = {
    DRUID = {
        "https://www.wowhead.com/cata/talent-calc/druid/33230221121212111201-01-020331",
        "https://www.wowhead.com/cata/talent-calc/druid/-2320322312010221202301-020311", --dps
        "https://www.wowhead.com/cata/talent-calc/druid/-2302322310310001220311-020331", --tank
        "https://www.wowhead.com/cata/talent-calc/druid/30232--122301302103223100311",
    },
    DEATHKNIGHT = {
        "https://www.wowhead.com/cata/talent-calc/death-knight/03321200132222311301-32001-003",
        "https://www.wowhead.com/cata/talent-calc/death-knight/203-20330022233112012301-032",
        "https://www.wowhead.com/cata/talent-calc/death-knight/2032-1-13300321230231021231",
    },
    HUNTER = {
        "https://www.wowhead.com/cata/talent-calc/hunter/2330230311320112121-2302-012",
        "https://www.wowhead.com/cata/talent-calc/hunter/032002-2302320032120231221-03",
        "https://www.wowhead.com/cata/talent-calc/hunter/03-2302-03223003023022121311",
    },
    MAGE = {
        "https://www.wowhead.com/cata/talent-calc/mage/303302021230122212121-23-01",
        "https://www.wowhead.com/cata/talent-calc/mage/003-230330221120121213231-03",
        "https://www.wowhead.com/cata/talent-calc/mage/002-2303-2323001013331301221",
    },
    PALADIN = {
        "https://www.wowhead.com/cata/talent-calc/paladin/03331001221131312301-3-032002",
        "https://www.wowhead.com/cata/talent-calc/paladin/-32023023121121101231-032032",
        "https://www.wowhead.com/cata/talent-calc/paladin/203002-12-03203213211113002321",
    },
    PRIEST = {
        "https://www.wowhead.com/cata/talent-calc/priest/232210221213200312021-033002",
        "https://www.wowhead.com/cata/talent-calc/priest/033-233122221210201103211-3",
        "https://www.wowhead.com/cata/talent-calc/priest/033211--322032210201222100231",
    },
    ROGUE = {
        "https://www.wowhead.com/cata/talent-calc/rogue/0333230013122110321-002-203003",
        "https://www.wowhead.com/cata/talent-calc/rogue/0322-0332230312030012321-003",
        "https://www.wowhead.com/cata/talent-calc/rogue/023003-002-0332031321310012321",
    },
    SHAMAN = {
        "https://www.wowhead.com/cata/talent-calc/shaman/3032023212231101321-2-20302",
        "https://www.wowhead.com/cata/talent-calc/shaman/3022021-2323320013003012321",
        "https://www.wowhead.com/cata/talent-calc/shaman/3020002-2-23322302132100121301",
    },
    WARLOCK = {
        "https://www.wowhead.com/cata/talent-calc/warlock/223222003013321321-03-33",
        "https://www.wowhead.com/cata/talent-calc/warlock/003-3312222300310212211-03202",
        "https://www.wowhead.com/cata/talent-calc/warlock/003-03202-3320202312201312211",
    },
    WARRIOR = {
        "https://www.wowhead.com/cata/talent-calc/warrior/32120303120212312201-0322-3",
        "https://www.wowhead.com/cata/talent-calc/warrior/320003-03222203130111022321-2",
        "https://www.wowhead.com/cata/talent-calc/warrior/320001-002-33233201121210212031",
    },
}


addon.Constants.InvSlotLayouts = {
    Left = {
        "INVTYPE_HEAD",
        "INVTYPE_NECK",
        "INVTYPE_SHOULDER",
        "INVTYPE_CLOAK",
        "INVTYPE_CHEST",
        "INVTYPE_SHIRT",
        "INVTYPE_TABARD",
        "INVTYPE_WRIST",
    },
    Right = {
        "INVTYPE_HAND",
        "INVTYPE_WAIST",
        "INVTYPE_LEGS",
        "INVTYPE_FEET",
        "INVTYPE_FINGER",
        "INVTYPE_FINGER",
        "INVTYPE_TRINKET",
        "INVTYPE_TRINKET",
    },

}

addon.Constants.InventorySlots = {
    {
        slot = "HEADSLOT",
        icon = 136516,
    },
    {
        slot = "NECKSLOT",
        icon = 136519,
    },
    {
        slot = "SHOULDERSLOT",
        icon = 136526,
    },
    {
        slot = "BACKSLOT",
        icon = 136512, -- 136521,
    },
    {
        slot = "CHESTSLOT",
        icon = 136512,
    },
    {
        slot = "SHIRTSLOT",
        icon = 136525,
    },
    {
        slot = "TABARDSLOT",
        icon = 136527,
    },
    {
        slot = "WRISTSLOT",
        icon = 136530,
    },
    {
        slot = "HANDSSLOT",
        icon = 136515,
    },
    {
        slot = "WAISTSLOT",
        icon = 136529,
    },
    {
        slot = "LEGSSLOT",
        icon = 136517,
    },
    {
        slot = "FEETSLOT",
        icon = 136513,
    },
    {
        slot = "FINGER0SLOT",
        icon = 136514,
    },
    {
        slot = "FINGER1SLOT",
        icon = 136523,
    },
    {
        slot = "TRINKET0SLOT",
        icon = 136528,
    },
    {
        slot = "TRINKET1SLOT",
        icon = 136528,
    },
    {
        slot = "MAINHANDSLOT",
        icon = 136518,
    },
    {
        slot = "SECONDARYHANDSLOT",
        icon = 136524,
    },
    {
        slot = "RANGEDSLOT",
        icon = 136520,
    },
    {
        slot = "RELICSLOT",
        icon = 136522,
    },
}

addon.Constants.Locales = {
    enUS = {
        STARTER_BUILD = "Starter Builds",
        SAVE_TALENTS = "Save Talents",
        RECORD_TALENTS = "Record Talents",
        APPLY_TALENT_LOADOUT = "Apply Talent loadout",

        TALENT_RECORDER_START = "Start recording talents",
        TALENT_RECORDER_RESTART = "Restart recording",
        TALENT_RECORDER_CONFIRM = "Save talent recording",
        TALENT_RECORDER_CANCEL = "Cancel",

        RECORD_TALENTS_HELPTIP = "You are currently recording talents, during this time learning talents is disabled.",

        CLICK_BINDINGS_SET_BINDING_PROMPT = "Mouseover and click a mouse button to set a binding",
        CLICK_BINDINGS_UNBOUND_TEXT = "Unbound - Mouseover and click to set",
    }
}

addon.Constants.AtlasShortcuts = {
    Padlock = "AdventureMapIcon-Lock",
    PadlockLarge = "BonusChest-Lock",
}

addon.Constants.NineSliceLayouts = {
    ParentBorder = {
        TopLeftCorner =	{ atlas = "Tooltip-NineSlice-CornerTopLeft", x=-3, y=3 },
        TopRightCorner =	{ atlas = "Tooltip-NineSlice-CornerTopRight", x=3, y=3 },
        BottomLeftCorner =	{ atlas = "Tooltip-NineSlice-CornerBottomLeft", x=-3, y=-3 },
        BottomRightCorner =	{ atlas = "Tooltip-NineSlice-CornerBottomRight", x=3, y=-3 },
        TopEdge = { atlas = "_Tooltip-NineSlice-EdgeTop", },
        BottomEdge = { atlas = "_Tooltip-NineSlice-EdgeBottom", },
        LeftEdge = { atlas = "!Tooltip-NineSlice-EdgeLeft", },
        RightEdge = { atlas = "!Tooltip-NineSlice-EdgeRight", },
    },
    ListviewMetal = {
        TopLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopLeft", x=-15, y=15 },
        TopRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerTopRight", x=15, y=15 },
        BottomLeftCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomLeft", x=-15, y=-15 },
        BottomRightCorner =	{ atlas = "UI-Frame-DiamondMetal-CornerBottomRight", x=15, y=-15 },
        TopEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeTop", },
        BottomEdge = { atlas = "_UI-Frame-DiamondMetal-EdgeBottom", },
        LeftEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeLeft", },
        RightEdge = { atlas = "!UI-Frame-DiamondMetal-EdgeRight", },
        Center = { layer = "BACKGROUND", atlas = "ClassHall_InfoBoxMission-BackgroundTile", x = -20, y = 20, x1 = 20, y1 = -20 },
    },
    DeckListviewItem = {
        ["TopRightCorner"] = { atlas = "Tooltip-NineSlice-CornerTopRight" },
		["TopLeftCorner"] = { atlas = "Tooltip-NineSlice-CornerTopLeft" },
		["BottomLeftCorner"] = { atlas = "Tooltip-NineSlice-CornerBottomLeft" },
		["BottomRightCorner"] = { atlas = "Tooltip-NineSlice-CornerBottomRight" },
		["TopEdge"] = { atlas = "_Tooltip-NineSlice-EdgeTop" },
		["BottomEdge"] = { atlas = "_Tooltip-NineSlice-EdgeBottom" },
		["LeftEdge"] = { atlas = "!Tooltip-NineSlice-EdgeLeft" },
		["RightEdge"] = { atlas = "!Tooltip-NineSlice-EdgeRight" },
    }
}

addon.Constants.Atlas = {
	["spellbookelements"] = {
        ['spellbook-skilllinetab'] = {0.0009765625,0.0400390625,0.0009765625,0.0576171875,},
        ['spellbook-divider'] = {0.2470703125,0.888671875,0.4111328125,0.421875,},
        ['spellbook-list-backplate'] = {0.0009765625,0.3095703125,0.3056640625,0.4091796875,},
        ['spellbook-background-evergreen-left'] = {0.892578125,1.6796875,0.0595703125,0.845703125,},
        ['spellbook-background-evergreen-ribbon'] = {0.791015625,0.890625,0.0595703125,0.603515625,},
        ['spellbook-background-evergreen-right'] = {0.0009765625,0.7890625,0.0595703125,0.845703125,},
        ['spellbook-background-evergreen-header'] = {0.0009765625,1.5771484375,0.0009765625,0.0576171875,},
        ['spellbook-corner-flipbook-evergreen'] = {0.0009765625,0.5869140625,0.0009765625,0.3037109375,},
        ['spellbook-item-backplate'] = {0.3115234375,0.5615234375,0.3056640625,0.3681640625,},
        ['spellbook-item-iconframe-hover'] = {0.0009765625,0.1298828125,0.537109375,0.6591796875,},
        ['spellbook-item-iconframe-inactive'] = {0.0009765625,0.1337890625,0.4111328125,0.53515625,},
        ['spellbook-item-iconframe-passive-inactive'] = {0.1357421875,0.2451171875,0.4111328125,0.5205078125,},
        ['spellbook-item-iconframe'] = {0.8544921875,0.9892578125,0.0009765625,0.12890625,},
        ['spellbook-item-unassigned-glow'] = {0.0009765625,0.125,0.6611328125,0.78515625,},
        ['spellbook-item-iconframe-sheen-mask'] = {0,0.125,0,0.125,},
        ['spellbook-item-spellicon-mask'] = {0,0.0625,0,0.0625,},
        ['spellbook-item-iconframe-passive-hover'] = {0.1357421875,0.2412109375,0.5224609375,0.6279296875,},
        ['spellbook-item-needtrainer-iconframe-backplate'] = {0.8544921875,0.98828125,0.130859375,0.2587890625,},
        ['spellbook-item-needtrainer-passive-backplate'] = {0.0009765625,0.111328125,0.787109375,0.8994140625,},
        ['spellbook-item-needtrainer-shadow'] = {0.5888671875,0.8525390625,0.0009765625,0.2646484375,},
        ['spellbook-item-petautocast-corners'] = {0.5634765625,0.6513671875,0.3056640625,0.3935546875,},
        ['spellbook-item-petautocast-mask'] = {0,0.0625,0,0.0625,},
	},
    ["interface/talentframe/specialization"] = {
		["spec-background"] = { 1612, 856, 0.00048828125, 0.78759765625, 0.00048828125, 0.41845703125, false, false },
		["spec-columndivider"] = { 7, 856, 0.982421875, 0.98583984375, 0.00048828125, 0.41845703125, false, false },
		["spec-dividerline"] = { 254, 2, 0.00048828125, 0.12451171875, 0.93798828125, 0.93896484375, false, false },
		["spec-hover-background"] = { 395, 856, 0.78857421875, 0.9814453125, 0.00048828125, 0.41845703125, false, false },
		["spec-role-dps"] = { 29, 29, 0.15869140625, 0.1728515625, 0.86865234375, 0.8828125, false, false },
		["spec-role-heal"] = { 29, 29, 0.173828125, 0.18798828125, 0.86865234375, 0.8828125, false, false },
		["spec-role-tank"] = { 29, 29, 0.15869140625, 0.1728515625, 0.8837890625, 0.89794921875, false, false },
		["spec-sampleabilityring"] = { 62, 60, 0.15869140625, 0.18896484375, 0.83837890625, 0.86767578125, false, false },
		["spec-selected-background1"] = { 395, 856, 0.00048828125, 0.193359375, 0.41943359375, 0.83740234375, false, false },
		["spec-selected-background2"] = { 395, 856, 0.1943359375, 0.38720703125, 0.41943359375, 0.83740234375, false, false },
		["spec-selected-background3"] = { 395, 856, 0.38818359375, 0.5810546875, 0.41943359375, 0.83740234375, false, false },
		["spec-selected-background4"] = { 395, 856, 0.58203125, 0.77490234375, 0.41943359375, 0.83740234375, false, false },
		["spec-selected-background5"] = { 395, 856, 0.77587890625, 0.96875, 0.41943359375, 0.83740234375, false, false },
		["spec-thumbnailborder-off"] = { 322, 202, 0.00048828125, 0.15771484375, 0.83837890625, 0.93701171875, false, false },
		["spec-thumbnailborder-on"] = { 322, 202, 0.1943359375, 0.3515625, 0.83837890625, 0.93701171875, false, false },
	},
	["interface/talentframe/specialization2"] = {
		["spec-animations-mask-filigree-activate"] = { 2048, 1024, 0, 1, 0, 1, false, false },
	},
	["interface/talentframe/specializationclassthumbnails"] = {
		["spec-thumbnail-deathknight-blood"] = { 306, 186, 0.00048828125, 0.14990234375, 0.00048828125, 0.09130859375, false, false },
		["spec-thumbnail-deathknight-frost"] = { 306, 186, 0.15087890625, 0.30029296875, 0.00048828125, 0.09130859375, false, false },
		["spec-thumbnail-deathknight-unholy"] = { 306, 186, 0.30126953125, 0.45068359375, 0.00048828125, 0.09130859375, false, false },
		["spec-thumbnail-demonhunter-havoc"] = { 306, 186, 0.45166015625, 0.60107421875, 0.00048828125, 0.09130859375, false, false },
		["spec-thumbnail-demonhunter-vengeance"] = { 306, 186, 0.60205078125, 0.75146484375, 0.00048828125, 0.09130859375, false, false },
		["spec-thumbnail-druid-balance"] = { 306, 186, 0.75244140625, 0.90185546875, 0.00048828125, 0.09130859375, false, false },
		["spec-thumbnail-druid-feral"] = { 306, 186, 0.00048828125, 0.14990234375, 0.09228515625, 0.18310546875, false, false },
		["spec-thumbnail-druid-guardian"] = { 306, 186, 0.15087890625, 0.30029296875, 0.09228515625, 0.18310546875, false, false },
		["spec-thumbnail-druid-restoration"] = { 306, 186, 0.30126953125, 0.45068359375, 0.09228515625, 0.18310546875, false, false },
		["spec-thumbnail-evoker-augmentation"] = { 306, 186, 0.60205078125, 0.75146484375, 0.45947265625, 0.55029296875, false, false },
		["spec-thumbnail-evoker-devastation"] = { 306, 186, 0.45166015625, 0.60107421875, 0.09228515625, 0.18310546875, false, false },
		["spec-thumbnail-evoker-preservation"] = { 306, 186, 0.60205078125, 0.75146484375, 0.09228515625, 0.18310546875, false, false },
		["spec-thumbnail-hunter-beastmastery"] = { 306, 186, 0.75244140625, 0.90185546875, 0.09228515625, 0.18310546875, false, false },
		["spec-thumbnail-hunter-marksmanship"] = { 306, 186, 0.00048828125, 0.14990234375, 0.18408203125, 0.27490234375, false, false },
		["spec-thumbnail-hunter-survival"] = { 306, 186, 0.15087890625, 0.30029296875, 0.18408203125, 0.27490234375, false, false },
		["spec-thumbnail-mage-arcane"] = { 306, 186, 0.30126953125, 0.45068359375, 0.18408203125, 0.27490234375, false, false },
		["spec-thumbnail-mage-fire"] = { 306, 186, 0.45166015625, 0.60107421875, 0.18408203125, 0.27490234375, false, false },
		["spec-thumbnail-mage-frost"] = { 306, 186, 0.60205078125, 0.75146484375, 0.18408203125, 0.27490234375, false, false },
		["spec-thumbnail-monk-brewmaster"] = { 306, 186, 0.75244140625, 0.90185546875, 0.18408203125, 0.27490234375, false, false },
		["spec-thumbnail-monk-mistweaver"] = { 306, 186, 0.00048828125, 0.14990234375, 0.27587890625, 0.36669921875, false, false },
		["spec-thumbnail-monk-windwalker"] = { 306, 186, 0.15087890625, 0.30029296875, 0.27587890625, 0.36669921875, false, false },
		["spec-thumbnail-paladin-holy"] = { 306, 186, 0.30126953125, 0.45068359375, 0.27587890625, 0.36669921875, false, false },
		["spec-thumbnail-paladin-protection"] = { 306, 186, 0.45166015625, 0.60107421875, 0.27587890625, 0.36669921875, false, false },
		["spec-thumbnail-paladin-retribution"] = { 306, 186, 0.60205078125, 0.75146484375, 0.27587890625, 0.36669921875, false, false },
		["spec-thumbnail-priest-discipline"] = { 306, 186, 0.75244140625, 0.90185546875, 0.27587890625, 0.36669921875, false, false },
		["spec-thumbnail-priest-holy"] = { 306, 186, 0.00048828125, 0.14990234375, 0.36767578125, 0.45849609375, false, false },
		["spec-thumbnail-priest-shadow"] = { 306, 186, 0.15087890625, 0.30029296875, 0.36767578125, 0.45849609375, false, false },
		["spec-thumbnail-rogue-assassination"] = { 306, 186, 0.30126953125, 0.45068359375, 0.36767578125, 0.45849609375, false, false },
		["spec-thumbnail-rogue-outlaw"] = { 306, 186, 0.45166015625, 0.60107421875, 0.36767578125, 0.45849609375, false, false },
		["spec-thumbnail-rogue-subtlety"] = { 306, 186, 0.60205078125, 0.75146484375, 0.36767578125, 0.45849609375, false, false },
		["spec-thumbnail-shaman-elemental"] = { 306, 186, 0.75244140625, 0.90185546875, 0.36767578125, 0.45849609375, false, false },
		["spec-thumbnail-shaman-enhancement"] = { 306, 186, 0.00048828125, 0.14990234375, 0.45947265625, 0.55029296875, false, false },
		["spec-thumbnail-shaman-restoration"] = { 306, 186, 0.00048828125, 0.14990234375, 0.55126953125, 0.64208984375, false, false },
		["spec-thumbnail-warlock-affliction"] = { 306, 186, 0.00048828125, 0.14990234375, 0.64306640625, 0.73388671875, false, false },
		["spec-thumbnail-warlock-demonology"] = { 306, 186, 0.00048828125, 0.14990234375, 0.73486328125, 0.82568359375, false, false },
		["spec-thumbnail-warlock-destruction"] = { 306, 186, 0.00048828125, 0.14990234375, 0.82666015625, 0.91748046875, false, false },
		["spec-thumbnail-warrior-arms"] = { 306, 186, 0.15087890625, 0.30029296875, 0.45947265625, 0.55029296875, false, false },
		["spec-thumbnail-warrior-fury"] = { 306, 186, 0.30126953125, 0.45068359375, 0.45947265625, 0.55029296875, false, false },
		["spec-thumbnail-warrior-protection"] = { 306, 186, 0.45166015625, 0.60107421875, 0.45947265625, 0.55029296875, false, false },
	},
	["interface/talentframe/talentframeatlas"] = {
		["_Talent-blue-glow"] = { 16, 16, 0, 0.0625, 0.0009765625, 0.0166015625, true, false },
		["_Talent-Bottom-Tile"] = { 64, 5, 0, 0.25, 0.0771484375, 0.08203125, true, false },
		["_Talent-green-glow"] = { 16, 16, 0, 0.0625, 0.083984375, 0.099609375, true, false },
		["_Talent-Top-Tile"] = { 64, 13, 0, 0.25, 0.0625, 0.0751953125, true, false },
		["pvptalents-background"] = { 131, 379, 0.00390625, 0.515625, 0.5546875, 0.9248046875, false, false },
		["pvptalents-list-background"] = { 147, 40, 0.19921875, 0.7734375, 0.1474609375, 0.1865234375, false, false },
		["pvptalents-list-background-mouseover"] = { 147, 40, 0.26171875, 0.8359375, 0.1962890625, 0.2353515625, false, false },
		["pvptalents-list-background-selected"] = { 147, 40, 0.27734375, 0.8515625, 0.251953125, 0.291015625, false, false },
		["pvptalents-list-checkmark"] = { 28, 26, 0.78125, 0.890625, 0.1474609375, 0.1728515625, false, false },
		["pvptalents-selectedarrow"] = { 43, 44, 0.79296875, 0.9609375, 0.455078125, 0.498046875, false, false },
		["pvptalents-talentborder"] = { 58, 58, 0.5234375, 0.75, 0.634765625, 0.69140625, false, false },
		["pvptalents-talentborder-empty"] = { 80, 80, 0.5234375, 0.8359375, 0.5546875, 0.6328125, false, false },
		["pvptalents-talentborder-glow"] = { 68, 68, 0.00390625, 0.26953125, 0.302734375, 0.369140625, false, false },
		["pvptalents-talentborder-locked"] = { 58, 58, 0.7578125, 0.984375, 0.634765625, 0.69140625, false, false },
		["pvptalents-warmode-firecover"] = { 127, 73, 0.00390625, 0.5, 0.9267578125, 0.998046875, false, false },
		["pvptalents-warmode-glow"] = { 105, 110, 0.5234375, 0.93359375, 0.693359375, 0.80078125, false, false },
		["pvptalents-warmode-incentive-ring"] = { 48, 48, 0.00390625, 0.19140625, 0.1474609375, 0.1943359375, false, false },
		["pvptalents-warmode-orb"] = { 80, 84, 0.32421875, 0.63671875, 0.37109375, 0.453125, false, false },
		["pvptalents-warmode-ring"] = { 80, 84, 0.64453125, 0.95703125, 0.37109375, 0.453125, false, false },
		["pvptalents-warmode-ring-disabled"] = { 80, 84, 0.00390625, 0.31640625, 0.37109375, 0.453125, false, false },
		["pvptalents-warmode-swords"] = { 46, 43, 0.75390625, 0.93359375, 0.1015625, 0.1435546875, false, false },
		["pvptalents-warmode-swords-disabled"] = { 46, 43, 0.79296875, 0.97265625, 0.302734375, 0.3447265625, false, false },
		["Talent-Background"] = { 32, 43, 0, 0.125, 0.0185546875, 0.060546875, true, false },
		["Talent-BottomLeftCurlies"] = { 65, 55, 0.5234375, 0.77734375, 0.921875, 0.9755859375, false, false },
		["Talent-BottomRightCurlies"] = { 65, 55, 0.27734375, 0.53125, 0.302734375, 0.3564453125, false, false },
		["Talent-Highlight"] = { 200, 53, 0.00390625, 0.78515625, 0.455078125, 0.5068359375, false, false },
		["Talent-RingWithDot"] = { 121, 120, 0.5234375, 0.99609375, 0.802734375, 0.919921875, false, false },
		["Talent-Selection"] = { 190, 45, 0.00390625, 0.74609375, 0.1015625, 0.1455078125, false, false },
		["Talent-Selection-Legendary"] = { 190, 45, 0.00390625, 0.74609375, 0.5087890625, 0.552734375, false, false },
		["Talent-Separator"] = { 68, 50, 0.00390625, 0.26953125, 0.251953125, 0.30078125, false, false },
		["Talent-TopLeftCurlies"] = { 63, 55, 0.5390625, 0.78515625, 0.302734375, 0.3564453125, false, false },
		["Talent-TopRightCurlies"] = { 64, 55, 0.00390625, 0.25390625, 0.1962890625, 0.25, false, false },
	},
	["interface/talentframe/talents"] = {
        ['talents-node-choice-gray'] = {0.37060546875,0.42724609375,0.7744140625,0.8759765625,},
        ['talents-node-choice-green'] = {0.37060546875,0.42724609375,0.8779296875,0.9794921875,},
        ['talents-node-choice-locked'] = {0.43310546875,0.48974609375,0.1708984375,0.2724609375,},
        ['talents-node-choice-shadow'] = {0.5341796875,0.5712890625,0.8125,0.88671875,},
        ['talents-node-choice-yellow'] = {0.43310546875,0.48974609375,0.3779296875,0.4794921875,},
        ['talents-node-circle-gray'] = {0.10693359375,0.13134765625,0.5556640625,0.6044921875,},
        ['talents-node-circle-green'] = {0.10693359375,0.13134765625,0.6064453125,0.6552734375,},
        ['talents-node-circle-locked'] = {0.10693359375,0.13134765625,0.6572265625,0.7060546875,},
        ['talents-node-circle-shadow'] = {0.5341796875,0.5712890625,0.888671875,0.962890625,},
        ['talents-node-circle-yellow'] = {0.67822265625,0.70263671875,0.107421875,0.15625,},
        ['talents-node-pvp-filled'] = {0.43310546875,0.48974609375,0.4814453125,0.5830078125,},
        ['talents-node-pvp-green'] = {0.43310546875,0.48974609375,0.5849609375,0.6865234375,},
        ['talents-node-pvp-locked'] = {0.43310546875,0.48974609375,0.8955078125,0.9970703125,},
        ['talents-node-pvp-shadow'] = {0.26806640625,0.30615234375,0.9228515625,0.998046875,},
        ['talents-node-square-gray'] = {0.49072265625,0.52978515625,0.7998046875,0.8779296875,},
        ['talents-node-square-green'] = {0.49072265625,0.52978515625,0.8798828125,0.9580078125,},
        ['talents-node-square-locked'] = {0.5341796875,0.5732421875,0.572265625,0.650390625,},
        ['talents-node-square-shadow'] = {0.22900390625,0.26708984375,0.9228515625,0.9990234375,},
        ['talents-node-square-yellow'] = {0.5341796875,0.5732421875,0.732421875,0.810546875,},
        ['talents-node-circle-mask'] = {0,0.03125,0,0.0625,},
        ['talents-node-choice-mask'] = {0,0.03125,0,0.0625,},
        ['talents-node-choice-greenglow'] = {0.13623046875,0.22216796875,0.3681640625,0.5322265625,},
        ['talents-node-circle-greenglow'] = {0.873046875,0.9130859375,0.0009765625,0.0810546875,},
        ['talents-node-square-greenglow'] = {0.13623046875,0.21826171875,0.7001953125,0.8642578125,},
        ['talents-node-choiceflyout-mask'] = {0,0.03125,0,0.0625,},
        ['talents-node-pvpflyout-green'] = {0.587890625,0.625,0.1708984375,0.2451171875,},
        ['talents-node-pvpflyout-yellow'] = {0.6259765625,0.6630859375,0.1708984375,0.2451171875,},
        ['talents-node-pvpflyout-yellow-dimmed'] = {0.6640625,0.701171875,0.1708984375,0.2451171875,},
        ['talents-node-choice-mask-half'] = {0,0.03125,0,0.0625,},
        ['talents-node-choiceflyout-circle-gray'] = {0.09326171875,0.12451171875,0.9365234375,0.9990234375,},
        ['talents-node-choiceflyout-circle-green'] = {0.30712890625,0.33837890625,0.9306640625,0.9931640625,},
        ['talents-node-choiceflyout-circle-locked'] = {0.7021484375,0.7333984375,0.1708984375,0.2333984375,},
        ['talents-node-choiceflyout-circle-yellow'] = {0.7666015625,0.7978515625,0.1708984375,0.2333984375,},
        ['talents-node-choiceflyout-square-gray'] = {0.30712890625,0.36962890625,0.1708984375,0.2958984375,},
        ['talents-node-choiceflyout-square-green'] = {0.30712890625,0.36962890625,0.2978515625,0.4228515625,},
        ['talents-node-choiceflyout-square-locked'] = {0.30712890625,0.36962890625,0.4248046875,0.5498046875,},
        ['talents-node-choiceflyout-square-yellow'] = {0.30712890625,0.36962890625,0.6787109375,0.8037109375,},
        ['talents-node-choiceflyout-circle-shadow'] = {0.22900390625,0.30419921875,0.3271484375,0.4775390625,},
        ['talents-node-choiceflyout-square-shadow'] = {0.22900390625,0.30615234375,0.1708984375,0.3251953125,},
        ['talents-node-choice-ghost'] = {0.37060546875,0.42919921875,0.6708984375,0.7724609375,},
        ['talents-node-circle-ghost'] = {0.5341796875,0.5849609375,0.2783203125,0.3798828125,},
        ['talents-node-square-ghost'] = {0.5341796875,0.5849609375,0.3818359375,0.4833984375,},
        ['talents-node-pvp-inspect-empty'] = {0.43310546875,0.48974609375,0.7919921875,0.8935546875,},
        ['talents-node-pvp-inspect'] = {0.43310546875,0.48974609375,0.6884765625,0.7900390625,},
        ['talents-node-choiceflyout-circle-ghost'] = {0.13623046875,0.20263671875,0.8662109375,0.9990234375,},
        ['talents-node-choiceflyout-square-ghost'] = {0.22900390625,0.30322265625,0.4794921875,0.6279296875,},
        ['talents-node-choiceflyout-circle-greenglow'] = {0.5341796875,0.5869140625,0.1708984375,0.2763671875,},
        ['talents-node-choiceflyout-square-greenglow'] = {0.00048828125,0.10595703125,0.5556640625,0.7666015625,},
        ['talents-node-square-sheenmask'] = {0,0.0625,0,0.125,},
        ['talents-node-circle-sheenmask'] = {0,0.03125,0,0.0625,},
        ['talents-node-choice-sheenmask'] = {0,0.0625,0,0.125,},
        ['talents-node-choiceflyout-circle-sheenmask'] = {0,0.03125,0,0.0625,},
        ['talents-node-choiceflyout-square-sheenmask'] = {0,0.0625,0,0.125,},
        ['talents-node-choice-red'] = {0.43310546875,0.48974609375,0.2744140625,0.3759765625,},
        ['talents-node-choiceflyout-circle-red'] = {0.734375,0.765625,0.1708984375,0.2333984375,},
        ['talents-node-choiceflyout-square-red'] = {0.30712890625,0.36962890625,0.5517578125,0.6767578125,},
        ['talents-node-circle-red'] = {0.10693359375,0.13134765625,0.7080078125,0.7568359375,},
        ['talents-node-square-red'] = {0.5341796875,0.5732421875,0.65234375,0.73046875,},
        ['talents-node-choice-newglow'] = {0.13623046875,0.22216796875,0.5341796875,0.6982421875,},
        ['talents-node-apex-active-large-glow'] = {0.22900390625,0.30126953125,0.6298828125,0.7744140625,},
        ['talents-node-apex-active-large-gray'] = {0.9140625,0.953125,0.0009765625,0.0791015625,},
        ['talents-node-apex-active-large-green'] = {0.9541015625,0.9931640625,0.0009765625,0.0791015625,},
        ['talents-node-apex-active-large-locked'] = {0.49072265625,0.52978515625,0.5595703125,0.6376953125,},
        ['talents-node-apex-active-large-red'] = {0.49072265625,0.52978515625,0.6396484375,0.7177734375,},
        ['talents-node-apex-active-large-yellow'] = {0.49072265625,0.52978515625,0.7197265625,0.7978515625,},
        ['talents-node-apex-large-glow'] = {0.22900390625,0.30126953125,0.7763671875,0.9208984375,},
        ['talents-node-apex-large-gray'] = {0.09326171875,0.13427734375,0.7685546875,0.8505859375,},
        ['talents-node-apex-large-green'] = {0.09326171875,0.13427734375,0.8525390625,0.9345703125,},
        ['talents-node-apex-large-locked'] = {0.49072265625,0.53173828125,0.3076171875,0.3896484375,},
        ['talents-node-apex-large-red'] = {0.49072265625,0.53173828125,0.3916015625,0.4736328125,},
        ['talents-node-apex-large-yellow'] = {0.49072265625,0.53173828125,0.4755859375,0.5576171875,},
        ['talents-node-apex-small-gray'] = {0.70361328125,0.72509765625,0.107421875,0.150390625,},
        ['talents-node-apex-small-locked'] = {0.72607421875,0.74755859375,0.107421875,0.150390625,},
        ['talents-node-apex-large-sheenmask'] = {0.00048828125,0.03173828125,0.0009765625,0.0634765625,},
        ['talents-node-apex-active-large-sheenmask'] = {0.00048828125,0.03173828125,0.0009765625,0.0634765625,},
        ['talents-node-apex-small-sheenmask'] = {0.00048828125,0.01220703125,0.0009765625,0.0244140625,},
        ['talents-node-apex-large-mask'] = {0.00048828125,0.03369140625,0.0009765625,0.0673828125,},
        ['talents-node-apex-active-large-mask'] = {0.00048828125,0.03369140625,0.0009765625,0.0673828125,},
        ['talents-node-apex-small-mask'] = {0.00048828125,0.01416015625,0.0009765625,0.0283203125,},
        ['talents-node-apex-bar-base'] = {0.00048828125,0.03369140625,0.0009765625,0.01953125,},
        ['talents-node-apex-bar-full'] = {0.00048828125,0.03369140625,0.021484375,0.0400390625,},
        ['talents-node-apex-bar-half'] = {0.00048828125,0.03369140625,0.0419921875,0.060546875,},
        ['talents-node-apex-active-bar-base'] = {0.00048828125,0.03662109375,0.0009765625,0.0029296875,},
        ['talents-node-apex-active-bar-full'] = {0.03759765625,0.07373046875,0.0009765625,0.0029296875,},
        ['talents-node-apex-active-bar-half'] = {0.07470703125,0.11083984375,0.0009765625,0.0029296875,},

	},
	["interface/talentframe/talentsanimations2"] = {
		["talents-animations-activationgrid"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875, false, false },
		["talents-animations-class-evoker"] = { 461, 461, 0.64013671875, 0.865234375, 0.37939453125, 0.6044921875, false, false },
		["talents-animations-particles"] = { 1308, 774, 0.00048828125, 0.63916015625, 0.37939453125, 0.75732421875, false, false },
	},
	["interface/talentframe/talentsanimations3"] = {
		["talents-animations-class-deathknight"] = { 461, 461, 0.50146484375, 0.7265625, 0.00048828125, 0.2255859375, false, false },
		["talents-animations-class-demonhunter"] = { 461, 461, 0.7275390625, 0.95263671875, 0.00048828125, 0.2255859375, false, false },
		["talents-animations-class-druid"] = { 461, 461, 0.50146484375, 0.7265625, 0.2265625, 0.45166015625, false, false },
		["talents-animations-class-hunter"] = { 461, 461, 0.7275390625, 0.95263671875, 0.2265625, 0.45166015625, false, false },
		["talents-animations-class-mage"] = { 461, 461, 0.00048828125, 0.2255859375, 0.50146484375, 0.7265625, false, false },
		["talents-animations-class-monk"] = { 461, 461, 0.00048828125, 0.2255859375, 0.7275390625, 0.95263671875, false, false },
		["talents-animations-class-paladin"] = { 461, 461, 0.2265625, 0.45166015625, 0.50146484375, 0.7265625, false, false },
		["talents-animations-class-priest"] = { 461, 461, 0.2265625, 0.45166015625, 0.7275390625, 0.95263671875, false, false },
		["talents-animations-class-rogue"] = { 461, 461, 0.45263671875, 0.677734375, 0.50146484375, 0.7265625, false, false },
		["talents-animations-class-shaman"] = { 461, 461, 0.45263671875, 0.677734375, 0.7275390625, 0.95263671875, false, false },
		["talents-animations-class-warlock"] = { 461, 461, 0.6787109375, 0.90380859375, 0.50146484375, 0.7265625, false, false },
		["talents-animations-class-warrior"] = { 461, 461, 0.6787109375, 0.90380859375, 0.7275390625, 0.95263671875, false, false },
		["talents-animations-gridburst"] = { 1024, 1024, 0.00048828125, 0.50048828125, 0.00048828125, 0.50048828125, false, false },
	},
	["interface/talentframe/talentsanimations4"] = {
		["talents-animations-titans"] = { 972, 810, 0.0009765625, 0.9501953125, 0.0009765625, 0.7919921875, false, false },
	},
	["interface/talentframe/talentsanimationsmaskfiligree"] = {
		["talents-animations-mask-filigree"] = { 2048, 1024, 0, 1, 0, 1, false, false },
	},
	["interface/talentframe/talentsanimationsmaskfiligreeactivate"] = {
		["talents-animations-mask-filigree-activate"] = { 2048, 1024, 0, 1, 0, 1, false, false },
	},
	["interface/talentframe/talentsanimationsmaskfull"] = {
		["talents-animations-mask-full"] = { 1024, 1024, 0, 1, 0, 1, false, false },
	},
	["interface/talentframe/talentsanimationsmasknodesheenchoice"] = {
		["talents-node-choice-sheenmask"] = { 64, 64, 0, 1, 0, 1, false, false },
	},
	["interface/talentframe/talentsanimationsmasknodesheenchoiceflyoutcircle"] = {
		["talents-node-choiceflyout-circle-sheenmask"] = { 64, 64, 0, 1, 0, 1, false, false },
	},
	["interface/talentframe/talentsanimationsmasknodesheenchoiceflyoutsquare"] = {
		["talents-node-choiceflyout-square-sheenmask"] = { 64, 64, 0, 1, 0, 1, false, false },
	},
	["interface/talentframe/talentsanimationsmasknodesheencircle"] = {
		["talents-node-circle-sheenmask"] = { 64, 64, 0, 1, 0, 1, false, false },
	},
	["interface/talentframe/talentsanimationsmasknodesheensquare"] = {
		["talents-node-square-sheenmask"] = { 64, 64, 0, 1, 0, 1, false, false },
	},
	["interface/talentframe/talentsanimationsmaskspecart"] = {
		["talents-animations-mask-specart"] = { 2048, 1024, 0, 1, 0, 1, false, false },
	},
	["interface/talentframe/talentsanimationsmaskspecartmid"] = {
		["talents-animations-mask-specart-mid"] = { 2048, 1024, 0, 1, 0, 1, false, false },
	},
	["interface/talentframe/talentsanimationssheen"] = {
		["talents-animations-clouds"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875, false, false },
		["talents-animations-sheen"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875, false, false },
	},
	["interface/talentframe/talentsarrowline"] = {
		["talents-arrow-line-ghost"] = { 8, 8, 0, 1, 0.0078125, 0.1328125, true, false },
		["talents-arrow-line-gray"] = { 8, 8, 0, 1, 0.1484375, 0.2734375, true, false },
		["talents-arrow-line-locked"] = { 8, 8, 0, 1, 0.2890625, 0.4140625, true, false },
		["talents-arrow-line-red"] = { 8, 8, 0, 1, 0.5703125, 0.6953125, true, false },
		["talents-arrow-line-yellow"] = { 8, 8, 0, 1, 0.4296875, 0.5546875, true, false },
	},
	["interface/talentframe/talentsclassbackgrounddeathknight1"] = {
		["talents-background-deathknight-blood"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875, false, false },
		["talents-background-deathknight-frost"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875, false, false },
	},
	["interface/talentframe/talentsclassbackgrounddeathknight2"] = {
		["talents-background-deathknight-unholy"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.0009765625, 0.7568359375, false, false },
	},
	["interface/talentframe/talentsclassbackgrounddemonhunter"] = {
		["talents-background-demonhunter-havoc"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875, false, false },
		["talents-background-demonhunter-vengeance"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875, false, false },
	},
	["interface/talentframe/talentsclassbackgrounddruid1"] = {
		["talents-background-druid-balance"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875, false, false },
		["talents-background-druid-feral"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875, false, false },
	},
	["interface/talentframe/talentsclassbackgrounddruid2"] = {
		["talents-background-druid-guardian"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875, false, false },
		["talents-background-druid-restoration"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875, false, false },
	},
	["interface/talentframe/talentsclassbackgroundevoker"] = {
		["talents-background-evoker-devastation"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875, false, false },
		["talents-background-evoker-preservation"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875, false, false },
	},
	["interface/talentframe/talentsclassbackgroundevoker2"] = {
		["talents-background-evoker-augmentation"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.0009765625, 0.7568359375, false, false },
	},
	["interface/talentframe/talentsclassbackgroundhunter1"] = {
		["talents-background-hunter-beastmastery"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875, false, false },
		["talents-background-hunter-marksmanship"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875, false, false },
	},
	["interface/talentframe/talentsclassbackgroundhunter2"] = {
		["talents-background-hunter-survival"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.0009765625, 0.7568359375, false, false },
	},
	["interface/talentframe/talentsclassbackgroundmage1"] = {
		["talents-background-mage-arcane"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875, false, false },
		["talents-background-mage-fire"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875, false, false },
	},
	["interface/talentframe/talentsclassbackgroundmage2"] = {
		["talents-background-mage-frost"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.0009765625, 0.7568359375, false, false },
	},
	["interface/talentframe/talentsclassbackgroundmonk1"] = {
		["talents-background-monk-brewmaster"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875, false, false },
		["talents-background-monk-mistweaver"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875, false, false },
	},
	["interface/talentframe/talentsclassbackgroundmonk2"] = {
		["talents-background-monk-windwalker"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.0009765625, 0.7568359375, false, false },
	},
	["interface/talentframe/talentsclassbackgroundpaladin1"] = {
		["talents-background-paladin-holy"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875, false, false },
		["talents-background-paladin-protection"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875, false, false },
	},
	["interface/talentframe/talentsclassbackgroundpaladin2"] = {
		["talents-background-paladin-retribution"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.0009765625, 0.7568359375, false, false },
	},
	["interface/talentframe/talentsclassbackgroundpriest1"] = {
		["talents-background-priest-discipline"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875, false, false },
		["talents-background-priest-holy"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875, false, false },
	},
	["interface/talentframe/talentsclassbackgroundpriest2"] = {
		["talents-background-priest-shadow"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.0009765625, 0.7568359375, false, false },
	},
	["interface/talentframe/talentsclassbackgroundrogue1"] = {
		["talents-background-rogue-assassination"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875, false, false },
		["talents-background-rogue-outlaw"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875, false, false },
	},
	["interface/talentframe/talentsclassbackgroundrogue2"] = {
		["talents-background-rogue-subtlety"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.0009765625, 0.7568359375, false, false },
	},
	["interface/talentframe/talentsclassbackgroundshaman1"] = {
		["talents-background-shaman-elemental"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875, false, false },
		["talents-background-shaman-enhancement"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875, false, false },
	},
	["interface/talentframe/talentsclassbackgroundshaman2"] = {
		["talents-background-shaman-restoration"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.0009765625, 0.7568359375, false, false },
	},
	["interface/talentframe/talentsclassbackgroundwarlock1"] = {
		["talents-background-warlock-affliction"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875, false, false },
		["talents-background-warlock-demonology"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875, false, false },
	},
	["interface/talentframe/talentsclassbackgroundwarlock2"] = {
		["talents-background-warlock-destruction"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.0009765625, 0.7568359375, false, false },
	},
	["interface/talentframe/talentsclassbackgroundwarrior1"] = {
		["talents-background-warrior-arms"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875, false, false },
		["talents-background-warrior-fury"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875, false, false },
	},
	["interface/talentframe/talentsclassbackgroundwarrior2"] = {
		["talents-background-warrior-protection"] = { 1612, 774, 0.00048828125, 0.78759765625, 0.0009765625, 0.7568359375, false, false },
	},
	["interface/talentframe/talentsmasknodechoice"] = {
		["talents-node-choice-mask"] = { 64, 64, 0, 1, 0, 1, false, false },
	},
	["interface/talentframe/talentsmasknodechoiceflyout"] = {
		["talents-node-choiceflyout-mask"] = { 64, 64, 0, 1, 0, 1, false, false },
	},
	["interface/talentframe/talentsmasknodechoicehalf"] = {
		["talents-node-choice-mask-half"] = { 64, 64, 0, 1, 0, 1, false, false },
	},
	["interface/talentframe/talentsmasknodecircle"] = {
		["talents-node-circle-mask"] = { 64, 64, 0, 1, 0, 1, false, false },
	}
}

addon.specInfo = {
    { classID = 8, specID = 62, iconFileID = 135932, roleID = 2, description = 'Manipulate the arcane, destroying enemies with overwhelming power.', name = 'Arcane', tabIndex = 0, primaryStat = 0, }, 
    { classID = 8, specID = 63, iconFileID = 135810, roleID = 2, description = 'Ignite enemies with balls of fire and combustive flames.', name = 'Fire', tabIndex = 1, primaryStat = 0, }, 
    { classID = 8, specID = 64, iconFileID = 135846, roleID = 2, description = 'Freezes enemies in their tracks and shatters them with Frost magic.', name = 'Frost', tabIndex = 2, primaryStat = 0, }, 
    { classID = 2, specID = 65, iconFileID = 135920, roleID = 1, description = 'Invokes the power of the Light to protect and to heal.', name = 'Holy', tabIndex = 0, primaryStat = 1, }, 
    { classID = 2, specID = 66, iconFileID = 236264, roleID = 0, description = 'Uses Holy magic to shield themself and defend allies from attackers.', name = 'Protection', tabIndex = 1, primaryStat = 5, }, 
    { classID = 2, specID = 70, iconFileID = 135873, roleID = 2, description = 'A righteous crusader who judges and punishes opponents with weapons and Holy magic.', name = 'Retribution', tabIndex = 2, primaryStat = 5, }, 
    { classID = 1, specID = 71, iconFileID = 132355, roleID = 2, description = 'A battle-hardened master of two-handed weapons, using mobility and overpowering attacks to strike their opponents down.', name = 'Arms', tabIndex = 0, primaryStat = 5, }, 
    { classID = 1, specID = 72, iconFileID = 132347, roleID = 2, description = 'A furious berserker wielding a weapon in each hand, unleashing a flurry of attacks to carve their opponents to pieces.', name = 'Fury', tabIndex = 1, primaryStat = 5, }, 
    { classID = 1, specID = 73, iconFileID = 132341, roleID = 0, description = 'A stalwart protector who uses a shield to safeguard themself and their allies.', name = 'Protection', tabIndex = 2, primaryStat = 5, }, 
    { classID = 0, specID = 74, iconFileID = 236159, roleID = 2, description = 'Driven by a frenzied persistence to pursue prey, these beasts stop at nothing to achieve victory; even death is temporary for these predators.', name = 'Ferocity', tabIndex = 0, primaryStat = 0, }, 
    { classID = 0, specID = 79, iconFileID = 132150, roleID = 2, description = 'Guileful creatures capable of skillfully mitigating lethal blows dealt to themselves and their allies.', name = 'Cunning', tabIndex = 2, primaryStat = 0, }, 
    { classID = 0, specID = 81, iconFileID = 132121, roleID = 0, description = 'Stalwart and veteran defenders who unquestionably place their thick hides and protective exteriors in harm\'s way for their allies.', name = 'Tenacity', tabIndex = 1, primaryStat = 0, }, 
    { classID = 11, specID = 102, iconFileID = 136096, roleID = 2, description = 'Can take on the form of a powerful Moonkin, balancing the power of Arcane and Nature magic to destroy enemies at a distance.', name = 'Balance', tabIndex = 0, primaryStat = 0, }, 
    { classID = 11, specID = 103, iconFileID = 132115, roleID = 2, description = 'Takes on the form of a great cat to deal damage with bleeds and bites.', name = 'Feral', tabIndex = 1, primaryStat = 3, }, 
    { classID = 11, specID = 104, iconFileID = 132276, roleID = 0, description = 'Takes on the form of a mighty bear to absorb damage and protect allies.', name = 'Guardian', tabIndex = 2, primaryStat = 3, }, 
    { classID = 11, specID = 105, iconFileID = 136041, roleID = 1, description = 'Uses heal-over-time Nature spells to keep allies alive.', name = 'Restoration', tabIndex = 3, primaryStat = 0, }, 
    { classID = 6, specID = 250, iconFileID = 135770, roleID = 0, description = 'A dark guardian who manipulates and corrupts life energy to sustain themself in the face of an enemy onslaught.', name = 'Blood', tabIndex = 0, primaryStat = 5, }, 
    { classID = 6, specID = 251, iconFileID = 135773, roleID = 2, description = 'An icy harbinger of doom, channeling runic power and delivering vicious weapon strikes.', name = 'Frost', tabIndex = 1, primaryStat = 5, }, 
    { classID = 6, specID = 252, iconFileID = 135775, roleID = 2, description = 'A master of death and decay, spreading infection and controlling undead minions to do their bidding.', name = 'Unholy', tabIndex = 2, primaryStat = 5, }, 
    { classID = 3, specID = 253, iconFileID = 461112, roleID = 2, description = 'A master of the wild who can tame a wide variety of beasts to assist them in combat.', name = 'Beast Mastery', tabIndex = 0, primaryStat = 2, }, 
    { classID = 3, specID = 254, iconFileID = 236179, roleID = 2, description = 'A master archer or sharpshooter who excels in bringing down enemies from afar.', name = 'Marksmanship', tabIndex = 1, primaryStat = 2, }, 
    { classID = 3, specID = 255, iconFileID = 461113, roleID = 2, description = 'A rugged tracker who favors using animal venom, explosives and traps as deadly weapons.', name = 'Survival', tabIndex = 2, primaryStat = 2, }, 
    { classID = 5, specID = 256, iconFileID = 135940, roleID = 1, description = 'Uses magic to shield allies from taking damage as well as heal their wounds.', name = 'Discipline', tabIndex = 0, primaryStat = 0, }, 
    { classID = 5, specID = 257, iconFileID = 237542, roleID = 1, description = 'A versatile healer who can reverse damage on individuals or groups and even heal from beyond the grave.', name = 'Holy', tabIndex = 1, primaryStat = 0, }, 
    { classID = 5, specID = 258, iconFileID = 136207, roleID = 2, description = 'Uses sinister Shadow magic, especially damage-over-time spells, to eradicate enemies.', name = 'Shadow', tabIndex = 2, primaryStat = 0, }, 
    { classID = 4, specID = 259, iconFileID = 236270, roleID = 2, description = 'A deadly master of poisons who dispatches victims with vicious dagger strikes.', name = 'Assassination', tabIndex = 0, primaryStat = 3, }, 
    { classID = 4, specID = 260, iconFileID = 135340, roleID = 2, description = 'A ruthless fugitive who uses agility and guile to stand toe-to-toe with enemies.', name = 'Outlaw', tabIndex = 1, primaryStat = 3, }, 
    { classID = 4, specID = 261, iconFileID = 132320, roleID = 2, description = 'A dark stalker who leaps from the shadows to ambush their unsuspecting prey.', name = 'Subtlety', tabIndex = 2, primaryStat = 3, }, 
    { classID = 7, specID = 262, iconFileID = 136048, roleID = 2, description = 'A spellcaster who harnesses the destructive forces of nature and the elements.', name = 'Elemental', tabIndex = 0, primaryStat = 0, }, 
    { classID = 7, specID = 263, iconFileID = 237581, roleID = 2, description = 'A totemic warrior who strikes foes with weapons imbued with elemental power.', name = 'Enhancement', tabIndex = 1, primaryStat = 2, }, 
    { classID = 7, specID = 264, iconFileID = 136052, roleID = 1, description = 'A healer who calls upon ancestral spirits and the cleansing power of water to mend allies\' wounds.', name = 'Restoration', tabIndex = 2, primaryStat = 0, }, 
    { classID = 9, specID = 265, iconFileID = 136145, roleID = 2, description = 'A master of shadow magic who specializes in drains and damage-over-time spells.', name = 'Affliction', tabIndex = 0, primaryStat = 0, }, 
    { classID = 9, specID = 266, iconFileID = 136172, roleID = 2, description = 'A master of demons who compels demonic powers to aid them.', name = 'Demonology', tabIndex = 1, primaryStat = 0, }, 
    { classID = 9, specID = 267, iconFileID = 136186, roleID = 2, description = 'A master of chaos who calls down fire to burn and demolish enemies.', name = 'Destruction', tabIndex = 2, primaryStat = 0, }, 
    { classID = 10, specID = 268, iconFileID = 608951, roleID = 0, description = 'A sturdy brawler who uses liquid fortification and unpredictable movement to avoid damage and protect allies.', name = 'Brewmaster', tabIndex = 0, primaryStat = 2, }, 
    { classID = 10, specID = 269, iconFileID = 608953, roleID = 2, description = 'A martial artist without peer who pummels foes with hands and fists.', name = 'Windwalker', tabIndex = 2, primaryStat = 2, }, 
    { classID = 10, specID = 270, iconFileID = 608952, roleID = 1, description = 'A healer who masters the mysterious art of manipulating life energies, aided by the wisdom of the Jade Serpent and Pandaren medicinal techniques.', name = 'Mistweaver', tabIndex = 1, primaryStat = 0, }, 
    { classID = 0, specID = 535, iconFileID = 236159, roleID = 2, description = 'Driven by a rabid persistence to pursue prey, these carnivorous beasts stop at nothing to achieve victory; even death is temporary for these predators.', name = 'Ferocity', tabIndex = 0, primaryStat = 0, }, 
    { classID = 0, specID = 536, iconFileID = 132150, roleID = 2, description = 'Guileful creatures capable of skillfully mitigating lethal blows dealt to themselves and their allies.', name = 'Cunning', tabIndex = 2, primaryStat = 0, }, 
    { classID = 0, specID = 537, iconFileID = 132121, roleID = 0, description = 'Stalwart and veteran defenders who unquestionably place their thick hides and protective exteriors in harm\'s way for their allies.', name = 'Tenacity', tabIndex = 1, primaryStat = 0, }, 
    { classID = 12, specID = 577, iconFileID = 1247264, roleID = 2, description = 'A brooding master of warglaives and the destructive power of Fel magic.', name = 'Havoc', tabIndex = 0, primaryStat = 3, }, 
    { classID = 12, specID = 581, iconFileID = 1247265, roleID = 0, description = 'Embraces the demon within to incinerate enemies and protect their allies.', name = 'Vengeance', tabIndex = 1, primaryStat = 3, }, 
}

addon.rawPetTalentData = {
    {2106,2,0,0,410,0,0,0,0,0,0,0,61680,61681,52858,0,0,0,0,0,0,0,0,0,0,0,0},
    {2107,0,0,0,410,0,0,0,0,0,0,0,61682,61683,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2109,0,1,1,410,0,0,0,0,0,2055742496,209715200,61684,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2110,2,0,0,409,0,0,0,0,0,0,0,61680,61681,52858,0,0,0,0,0,0,0,0,0,0,0,0},
    {2111,2,1,3,410,0,0,0,0,0,713565216,243269632,61685,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2112,0,0,2,410,0,0,0,0,0,0,0,61686,61687,61688,0,0,0,0,0,0,0,0,0,0,0,0},
    {2113,0,0,3,410,0,0,0,0,0,0,0,61689,61690,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2114,0,0,0,409,0,0,0,0,0,0,0,61682,61683,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2116,0,0,2,409,0,0,0,0,0,0,0,61686,61687,61688,0,0,0,0,0,0,0,0,0,0,0,0},
    {2117,0,0,3,409,0,0,0,0,0,0,0,61689,61690,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2118,0,0,0,411,0,0,0,0,0,0,0,61682,61683,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2119,0,1,1,411,0,0,0,0,0,268648448,-2147483648,61684,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2120,0,0,2,411,0,0,0,0,0,0,0,61686,61687,61688,0,0,0,0,0,0,0,0,0,0,0,0},
    {2121,0,0,3,411,0,0,0,0,0,0,0,61689,61690,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2122,1,0,3,409,0,0,0,0,0,0,0,53175,53176,0,0,0,0,0,0,0,2117,0,0,1,0,0},
    {2123,2,0,1,409,0,0,0,0,0,0,0,53178,53179,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2124,1,0,0,410,0,0,0,0,0,0,0,53180,53181,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2125,1,0,2,410,0,0,0,0,0,0,0,53182,53183,53184,0,0,0,0,0,0,0,0,0,0,0,0},
    {2126,1,0,0,409,0,0,0,0,0,0,0,53182,53183,53184,0,0,0,0,0,0,0,0,0,0,0,0},
    {2127,1,0,3,411,0,0,0,0,0,0,0,53182,53183,53184,0,0,0,0,0,0,0,0,0,0,0,0},
    {2128,1,0,1,410,0,0,0,0,0,0,0,53186,53187,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2129,3,0,2,410,0,0,0,0,0,0,0,53203,53204,53205,0,0,0,0,0,0,0,0,0,0,0,0},
    {2151,1,0,3,410,0,0,0,0,0,0,0,19596,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2152,2,0,2,410,0,0,0,0,0,0,0,53409,53411,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2153,4,1,1,410,0,0,0,0,0,0,0,53426,0,0,0,0,0,0,0,0,2156,0,0,0,0,0},
    {2154,3,0,3,410,0,0,0,0,0,0,0,53427,53429,53430,0,0,0,0,0,0,0,0,0,0,0,0},
    {2155,4,1,0,410,0,0,0,0,0,0,0,53401,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2156,3,1,1,410,0,0,0,0,0,0,0,55709,0,0,0,0,0,0,0,0,2128,0,0,1,0,0},
    {2157,4,1,2,410,0,0,0,0,0,0,0,53434,0,0,0,0,0,0,0,0,2129,0,0,2,0,0},
    {2160,1,0,1,409,0,0,0,0,0,0,0,19596,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2161,3,0,3,409,0,0,0,0,0,0,0,53427,53429,53430,0,0,0,0,0,0,0,0,0,0,0,0},
    {2162,2,0,2,409,0,0,0,0,0,0,0,53409,53411,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2163,3,0,2,409,0,0,0,0,0,0,0,53450,53451,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2165,1,0,0,411,0,0,0,0,0,0,0,19596,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2166,2,0,0,411,0,0,0,0,0,0,0,61680,61681,52858,0,0,0,0,0,0,0,0,0,0,0,0},
    {2167,2,0,1,411,0,0,0,0,0,0,0,53409,53411,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2168,3,0,1,411,0,0,0,0,0,0,0,53427,53429,53430,0,0,0,0,0,0,0,0,0,0,0,0},
    {2169,4,1,3,409,0,0,0,0,0,0,0,53476,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2170,4,1,1,409,0,0,0,0,0,0,0,53477,0,0,0,0,0,0,0,0,2123,0,0,1,0,0},
    {2171,4,1,0,409,0,0,0,0,0,0,0,53478,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2172,4,1,2,409,0,0,0,0,0,0,0,53480,0,0,0,0,0,0,0,0,2163,0,0,1,0,0},
    {2173,1,0,2,409,0,0,0,0,0,0,0,53481,53482,0,0,0,0,0,0,0,2116,0,0,2,0,0},
    {2175,4,1,2,411,0,0,0,0,0,0,0,53490,0,0,0,0,0,0,0,0,2177,0,0,1,0,0},
    {2177,3,0,2,411,0,0,0,0,0,0,0,52234,53497,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2181,4,1,0,411,0,0,0,0,0,0,0,53508,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2182,1,0,2,411,0,0,0,0,0,0,0,53514,53516,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2183,3,0,3,411,0,0,0,0,0,0,0,53511,53512,0,0,0,0,0,0,0,2127,0,0,2,0,0},
    {2184,4,1,1,411,0,0,0,0,0,0,0,53517,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2201,0,1,1,411,0,0,0,0,0,21238021,0,23145,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2203,0,1,1,410,0,0,0,0,0,2064,268435456,23145,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2206,2,1,2,411,0,0,0,0,0,0,0,54044,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2207,1,0,1,411,0,0,0,0,0,268648448,-2147483648,53483,53485,0,0,0,0,0,0,0,2119,0,0,0,0,0},
    {2208,1,0,1,411,0,0,0,0,0,21238021,0,53554,53555,0,0,0,0,0,0,0,2201,0,0,0,0,0},
    {2219,2,1,3,410,0,0,0,0,0,2064,268435456,52825,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2237,0,1,1,409,0,0,0,0,0,0,0,61685,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2253,5,0,2,410,0,0,0,0,0,0,0,62758,62762,0,0,0,0,0,0,0,2157,0,0,0,0,0},
    {2254,5,0,0,410,0,0,0,0,0,0,0,62759,62760,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2255,5,0,2,409,0,0,0,0,0,0,0,62758,62762,0,0,0,0,0,0,0,2172,0,0,0,0,0},
    {2256,5,0,0,411,0,0,0,0,0,0,0,62758,62762,0,0,0,0,0,0,0,2181,0,0,0,0,0},
    {2257,4,0,3,411,0,0,0,0,0,0,0,53450,53451,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2258,5,0,1,409,0,0,0,0,0,0,0,62764,62765,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2277,2,1,3,409,0,0,0,0,0,0,0,63900,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {2278,5,1,3,411,0,0,0,0,0,0,0,53480,0,0,0,0,0,0,0,0,2257,0,0,1,0,0},    
}

addon.Constants.PetTalents = {
    [410] = {
        ["1"] = {
            ["1"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 2,
                ["talentSpellIDs"] = {
                    61682, -- [1]
                    61683, -- [2]
                },
            },
            ["4"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 6,
                ["talentSpellIDs"] = {
                    61689, -- [1]
                    61690, -- [2]
                },
            },
            ["3"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 5,
                ["talentSpellIDs"] = {
                    61686, -- [1]
                    61687, -- [2]
                    61688, -- [3]
                },
            },
            ["2"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 3,
                ["talentSpellIDs"] = {
                    61684, -- [1]
                },
            },
        },
        ["3"] = {
            ["1"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 1,
                ["talentSpellIDs"] = {
                    61680, -- [1]
                    61681, -- [2]
                    52858, -- [3]
                },
            },
            ["4"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 4,
                ["talentSpellIDs"] = {
                    61685, -- [1]
                },
            },
            ["3"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 12,
                ["talentSpellIDs"] = {
                    53409, -- [1]
                    53411, -- [2]
                },
            },
        },
        ["2"] = {
            ["1"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 7,
                ["talentSpellIDs"] = {
                    53180, -- [1]
                    53181, -- [2]
                },
            },
            ["4"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 11,
                ["talentSpellIDs"] = {
                    19596, -- [1]
                },
            },
            ["3"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 8,
                ["talentSpellIDs"] = {
                    53182, -- [1]
                    53183, -- [2]
                    53184, -- [3]
                },
            },
            ["2"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 9,
                ["talentSpellIDs"] = {
                    53186, -- [1]
                    53187, -- [2]
                },
            },
        },
        ["5"] = {
            ["1"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 15,
                ["talentSpellIDs"] = {
                    53401, -- [1]
                },
            },
            ["3"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 17,
                ["talentSpellIDs"] = {
                    53434, -- [1]
                },
            },
            ["2"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 13,
                ["talentSpellIDs"] = {
                    53426, -- [1]
                },
            },
        },
        ["4"] = {
            ["4"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 14,
                ["talentSpellIDs"] = {
                    53427, -- [1]
                    53429, -- [2]
                    53430, -- [3]
                },
            },
            ["3"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 10,
                ["talentSpellIDs"] = {
                    53203, -- [1]
                    53204, -- [2]
                    53205, -- [3]
                },
            },
            ["2"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 16,
                ["talentSpellIDs"] = {
                    55709, -- [1]
                },
            },
        },
        ["6"] = {
            ["3"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 20,
                ["talentSpellIDs"] = {
                    62758, -- [1]
                    62762, -- [2]
                },
            },
            ["1"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 21,
                ["talentSpellIDs"] = {
                    62759, -- [1]
                    62760, -- [2]
                },
            },
        },
    },
    [411] = {
        ["1"] = {
            ["1"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 1,
                ["talentSpellIDs"] = {
                    61682, -- [1]
                    61683, -- [2]
                },
            },
            ["4"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 4,
                ["talentSpellIDs"] = {
                    61689, -- [1]
                    61690, -- [2]
                },
            },
            ["3"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 3,
                ["talentSpellIDs"] = {
                    61686, -- [1]
                    61687, -- [2]
                    61688, -- [3]
                },
            },
            ["2"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 2,
                ["talentSpellIDs"] = {
                    61684, -- [1]
                },
            },
        },
        ["3"] = {
            ["1"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 7,
                ["talentSpellIDs"] = {
                    61680, -- [1]
                    61681, -- [2]
                    52858, -- [3]
                },
            },
            ["3"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 17,
                ["talentSpellIDs"] = {
                    54044, -- [1]
                },
            },
            ["2"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 8,
                ["talentSpellIDs"] = {
                    53409, -- [1]
                    53411, -- [2]
                },
            },
        },
        ["2"] = {
            ["1"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 6,
                ["talentSpellIDs"] = {
                    19596, -- [1]
                },
            },
            ["4"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 5,
                ["talentSpellIDs"] = {
                    53182, -- [1]
                    53183, -- [2]
                    53184, -- [3]
                },
            },
            ["3"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 13,
                ["talentSpellIDs"] = {
                    53514, -- [1]
                    53516, -- [2]
                },
            },
            ["2"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 18,
                ["talentSpellIDs"] = {
                    53483, -- [1]
                    53485, -- [2]
                },
            },
        },
        ["5"] = {
            ["1"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 12,
                ["talentSpellIDs"] = {
                    53508, -- [1]
                },
            },
            ["4"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 21,
                ["talentSpellIDs"] = {
                    53450, -- [1]
                    53451, -- [2]
                },
            },
            ["3"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 10,
                ["talentSpellIDs"] = {
                    53490, -- [1]
                },
            },
            ["2"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 15,
                ["talentSpellIDs"] = {
                    53517, -- [1]
                },
            },
        },
        ["4"] = {
            ["4"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 14,
                ["talentSpellIDs"] = {
                    53511, -- [1]
                    53512, -- [2]
                },
            },
            ["3"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 11,
                ["talentSpellIDs"] = {
                    52234, -- [1]
                    53497, -- [2]
                },
            },
            ["2"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 9,
                ["talentSpellIDs"] = {
                    53427, -- [1]
                    53429, -- [2]
                    53430, -- [3]
                },
            },
        },
        ["6"] = {
            ["1"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 20,
                ["talentSpellIDs"] = {
                    62758, -- [1]
                    62762, -- [2]
                },
            },
            ["4"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 22,
                ["talentSpellIDs"] = {
                    53480, -- [1]
                },
            },
        },
    },
    [409] = {
        ["1"] = {
            ["1"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 2,
                ["talentSpellIDs"] = {
                    61682, -- [1]
                    61683, -- [2]
                },
            },
            ["4"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 4,
                ["talentSpellIDs"] = {
                    61689, -- [1]
                    61690, -- [2]
                },
            },
            ["3"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 3,
                ["talentSpellIDs"] = {
                    61686, -- [1]
                    61687, -- [2]
                    61688, -- [3]
                },
            },
            ["2"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 17,
                ["talentSpellIDs"] = {
                    61685, -- [1]
                },
            },
        },
        ["3"] = {
            ["1"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 1,
                ["talentSpellIDs"] = {
                    61680, -- [1]
                    61681, -- [2]
                    52858, -- [3]
                },
            },
            ["4"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 20,
                ["talentSpellIDs"] = {
                    63900, -- [1]
                },
            },
            ["3"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 10,
                ["talentSpellIDs"] = {
                    53409, -- [1]
                    53411, -- [2]
                },
            },
            ["2"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 6,
                ["talentSpellIDs"] = {
                    53178, -- [1]
                    53179, -- [2]
                },
            },
        },
        ["2"] = {
            ["1"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 7,
                ["talentSpellIDs"] = {
                    53182, -- [1]
                    53183, -- [2]
                    53184, -- [3]
                },
            },
            ["4"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 5,
                ["talentSpellIDs"] = {
                    53175, -- [1]
                    53176, -- [2]
                },
            },
            ["3"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 16,
                ["talentSpellIDs"] = {
                    53481, -- [1]
                    53482, -- [2]
                },
            },
            ["2"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 8,
                ["talentSpellIDs"] = {
                    19596, -- [1]
                },
            },
        },
        ["5"] = {
            ["1"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 14,
                ["talentSpellIDs"] = {
                    53478, -- [1]
                },
            },
            ["4"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 12,
                ["talentSpellIDs"] = {
                    53476, -- [1]
                },
            },
            ["3"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 15,
                ["talentSpellIDs"] = {
                    53480, -- [1]
                },
            },
            ["2"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 13,
                ["talentSpellIDs"] = {
                    53477, -- [1]
                },
            },
        },
        ["4"] = {
            ["3"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 11,
                ["talentSpellIDs"] = {
                    53450, -- [1]
                    53451, -- [2]
                },
            },
            ["4"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 9,
                ["talentSpellIDs"] = {
                    53427, -- [1]
                    53429, -- [2]
                    53430, -- [3]
                },
            },
        },
        ["6"] = {
            ["3"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 18,
                ["talentSpellIDs"] = {
                    62758, -- [1]
                    62762, -- [2]
                },
            },
            ["2"] = {
                ["tabIndex"] = 1,
                ["talentIndex"] = 19,
                ["talentSpellIDs"] = {
                    62764, -- [1]
                    62765, -- [2]
                },
            },
        },
    },
}
