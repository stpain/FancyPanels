--[[

    © 2026 Sam Pain. All Rights Reserved.
    
    No part of this work may be reproduced 
    without the prior written permission 
    of the author.

]]

local name, addon = ...;

local Util = addon.Util;
local SavedVars = addon.SavedVars;




FancyPanelsSpellbookHeaderMixin = {};

function FancyPanelsSpellbookHeaderMixin:OnLoad()
    Util.ApplyAtlas(self.FontBackground, "spellbookelements", "spellbook-list-backplate");
    Util.ApplyAtlas(self.Divider, "spellbookelements", "spellbook-divider");
end

function FancyPanelsSpellbookHeaderMixin:SetText(text)
    self.Text:SetText(text);
end







local function TrimTextSpace(textFrame)
	if (not textFrame:GetText() or textFrame:GetText() == "") then
		textFrame:SetHeight(1);
		textFrame:Hide();
	else
		textFrame:SetHeight(min(textFrame:GetStringHeight(), textFrame:GetLineHeight() * textFrame:GetMaxLines()));
		textFrame:Show();
	end
end

FancyPanelsSpellbookSpellItemMixin = {};

function FancyPanelsSpellbookSpellItemMixin:OnLoad()

	self.Name = self.TextContainer.Name;
	self.SubName = self.TextContainer.SubName;

    self.Button:RegisterForDrag("LeftButton")

    Util.ApplyAtlas(self.Backplate, "spellbookelements", "spellbook-item-backplate")
    Util.ApplyAtlas(self.Button.Border, "spellbookelements", "spellbook-item-iconframe")
    Util.ApplyAtlas(self.Button.IconHighlight, "interface/talentframe/talents", "talents-node-square-greenglow")

    addon.CallbackRegistry:RegisterCallback(addon.Callbacks.SpellbookClickToCast_OnToggle, self.SpellbookClickToCast_OnToggle, self)

    self.Button:SetScript("OnDragStart", function(_, hwButtonPressed)
        if (self.captureEnabled == false) and self.spell then
            PickupSpell(self.spell:GetSpellID());
        end
    end)
    
    self.Button:SetScript("OnLeave", function(_, hwButtonPressed)
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

    self.Button:SetScript("OnEnter", function(_, hwButtonPressed)
        if self.captureEnabled then
            FancyPanelsCliqueKeyGrabber:SetID(self:GetID());
            FancyPanelsCliqueKeyGrabber:ClearAllPoints();
            FancyPanelsCliqueKeyGrabber:SetParent(self.Button);
            FancyPanelsCliqueKeyGrabber:SetPoint("CENTER", self.Button, "CENTER", 0, 0);
            FancyPanelsCliqueKeyGrabber:SetSize(40, 40)
            
            Clique_RegisterQuickbindButtonScripts(FancyPanelsCliqueKeyGrabber);

            FancyPanelsCliqueKeyGrabber:Show();

            self:OnEnter();
        end
    end)

end

function FancyPanelsSpellbookSpellItemMixin:UpdateTextContainer()
	-- The TrimTextSpace function call here is needed to work around
	-- a bug with FontStrings with a specified maxLine count
	TrimTextSpace(self.Name);
	TrimTextSpace(self.SubName);
	self.TextContainer:Layout();
end

function FancyPanelsSpellbookSpellItemMixin:SpellbookClickToCast_OnToggle(enabled)
    self.captureEnabled = enabled;
    self:UpdateVisuals();
end

function FancyPanelsSpellbookSpellItemMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    -- Clique_UnregisterQuickbindButtonScripts(FancyPanelsCliqueKeyGrabber)
    -- FancyPanelsCliqueKeyGrabber:SetID(0);
    -- FancyPanelsCliqueKeyGrabber:ClearAllPoints();
    -- FancyPanelsCliqueKeyGrabber:SetParent(UIParent);
    -- FancyPanelsCliqueKeyGrabber:SetPoint("TOPLEFT")
    -- FancyPanelsCliqueKeyGrabber:SetSize(1,1);
end

function FancyPanelsSpellbookSpellItemMixin:ClearSpell()
    self.spell = nil;
end

function FancyPanelsSpellbookSpellItemMixin:InitSpell()
    self:ClearSpell();
    local spell = Spell:CreateFromSpellID(self:GetID());
    spell:ContinueOnSpellLoad(function()
        self.spell = spell;
        self:UpdateVisuals();
    end)
end

function FancyPanelsSpellbookSpellItemMixin:OnEnter()
    if self.spell then

        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
        GameTooltip:SetSpellByID(self:GetID());

        if (self.captureEnabled == true) then

            local bindingData = Clique_GetBindingInfoForSpellID(self:GetID());

            if bindingData then
                GameTooltip_AddBlankLineToTooltip(GameTooltip)

                for _, binding in ipairs(bindingData) do
                    local text = string.format("%s - %s", binding.bindingText, binding.actionText)
                    GameTooltip_AddColoredLine(GameTooltip, text, BLUE_FONT_COLOR)
                end
            else
                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                GameTooltip_AddColoredLine(GameTooltip, addon.Constants.Locales[GetLocale()].CLICK_BINDINGS_UNBOUND_TEXT, BLUE_FONT_COLOR)

            end
        end

        GameTooltip:Show();
    end

end

function FancyPanelsSpellbookSpellItemMixin:UpdateVisuals()

    if self.spell then
        self.Name:SetText(self.spell:GetSpellName());
        self.SubName:SetText(self.spell:GetSpellSubtext());

        self.Button.Icon:SetTexture(C_Spell.GetSpellTexture(self.spell:GetSpellID()))
        self:UpdateTextContainer();

        self.Button.name = self.spell:GetSpellName();
    end

    if self.captureEnabled then
        self.Button.Border:Hide()
        self.Button.IconHighlight:Show()
    else
        self.Button.Border:Show()
        self.Button.IconHighlight:Hide()
    end
end



















FancyPanelsCircleButtonMixin = {}
function FancyPanelsCircleButtonMixin:OnLoad()
    if self.atlas then
        self.icon:SetAtlas(self.atlas);
    end
end

function FancyPanelsCircleButtonMixin:SetSizeRatio(size)
    self:SetSize(size, size)
    self.icon:SetSize(size, size)
    self.mask:SetSize(size*0.9, size*0.9)
    self.border:SetSize(size*1.8, size*1.8)
end







local function SetSpec(spec, val, trigger)
    SavedVars:Set(string.format("specializations.druidSpec%s", spec), val);
    if (trigger == true) then
        addon.CallbackRegistry:TriggerEvent(addon.Callbacks.SpecializationOptions_OnChanged, spec)
    end
end

local function GetSpec(spec)
    return SavedVars:Get(string.format("specializations.druidSpec%s", spec))
end

local function InitFeralDruidOptions(button)
    
    local specOptions = {"Bear", "Cat"};
    MenuUtil.CreateContextMenu(button, function(_, root)
        root:CreateTitle("Select Feral Specializations");
        root:CreateDivider();
        root:CreateTitle("Spec 1");

        for k, v in ipairs(specOptions) do
            local checkbox = root:CreateTemplate("ContextMenuCheckbox");
            checkbox:AddInitializer(function(frame)
                frame:SetSize(180, 26);
                frame.Checkbox.label:SetText(v);
                frame.Checkbox:SetChecked(GetSpec(1) == v and true or false);
                frame.Checkbox:SetScript("OnClick", function(cb)
                    if (cb:GetChecked() == true) then
                        SetSpec(1, v, true);
                    else
                        SetSpec(1, "", true);
                    end
                end)
                addon.CallbackRegistry:RegisterCallback(addon.Callbacks.SpecializationOptions_OnChanged, function(_, spec)
                    --print("callback",spec)
                    if (spec == 1) then
                        frame.Checkbox:SetChecked(GetSpec(1) == v and true or false);
                    end
                end);
            end)
        end

        root:CreateDivider();
        root:CreateTitle("Spec 2");

        for k, v in ipairs(specOptions) do
            local checkbox = root:CreateTemplate("ContextMenuCheckbox");

            checkbox:AddInitializer(function(frame)
                frame:SetSize(180, 26);
                frame.Checkbox.label:SetText(v);
                frame.Checkbox:SetChecked(GetSpec(2) == v and true or false);
                frame.Checkbox:SetScript("OnClick", function(cb)
                    if (cb:GetChecked() == true) then
                        SetSpec(2, v, true);
                    else
                        SetSpec(2, "", true);
                    end
                end)
                addon.CallbackRegistry:RegisterCallback(addon.Callbacks.SpecializationOptions_OnChanged, function(_, spec)
                    if (spec == 2) then
                        frame.Checkbox:SetChecked(GetSpec(2) == v and true or false);
                    end
                end);
            end)
        end

    end)
end



FancyPanelsSpecPanelMixin = {}
function FancyPanelsSpecPanelMixin:SetSpec(info)

    --print(info.name, info.specID)

    if (info.specID == 281) then

        self.options:SetScript("OnClick", function(button)
            InitFeralDruidOptions(button);
        end)

        self.options:Show();
    else
        self.options:Hide();
    end

    self.name:SetText(info.name)
    self.thumbnail:SetTexCoord(info.thumbnailAtlas[1], info.thumbnailAtlas[2], info.thumbnailAtlas[3], info.thumbnailAtlas[4])
    self.description:SetText(info.description)

    self.majorBonus1:SetSizeRatio(65)
    self.majorBonus2:SetSizeRatio(65)

    self.majorBonus2:SetPoint("TOP", 60, -470);

    self:SetSampleTalent(info.sampleTalents)

    self.majorBonus1:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)
    self.majorBonus2:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

    --DevTools_Dump({info})


end

local rolesAtlasMap = {
    HEALER = "UI-LFG-RoleIcon-Healer-Micro",
    TANK = "UI-LFG-RoleIcon-Tank-Micro",
    DAMAGER = "UI-LFG-RoleIcon-DPS-Micro",
}
function FancyPanelsSpecPanelMixin:SetRole(role1, role2)
    local s = "";
    if role1 then
        s = string.format("%s %s", CreateAtlasMarkup(rolesAtlasMap[role1], 20, 20), _G[role1])
    end
    if role2 then
        s = string.format("%s    %s %s", s, CreateAtlasMarkup(rolesAtlasMap[role2], 20, 20), _G[role2])
    end
    self.role:SetText(s)
end

function FancyPanelsSpecPanelMixin:SetSampleTalent(info)
    -- local spell = Spell:CreateFromSpellID(info.sampleTalent);
    -- spell:ContinueOnSpellLoad(function()
    --     self.majorBonus.icon:SetTexture(C_Spell.GetSpellTexture(info.sampleTalent))
    -- end)

    self.majorBonus1:ClearAllPoints();

    if info == nil then
        return;
    end

    if info[1] == nil then
        return;
    end

    --need to adjust for table data
    if #info == 1 then
        self.majorBonus1:SetPoint("TOP", 0, -470);
        self.majorBonus2:Hide();

        self.majorBonus1.text:SetText(C_Spell.GetSpellName(info[1][13]))
        self.majorBonus1.icon:SetTexture(C_Spell.GetSpellTexture(info[1][13]))
    else
        self.majorBonus1:SetPoint("TOP", -60, -470);

        self.majorBonus1.text:SetText(C_Spell.GetSpellName(info[1][13]))
        self.majorBonus1.icon:SetTexture(C_Spell.GetSpellTexture(info[1][13]))

        self.majorBonus2.text:SetText(C_Spell.GetSpellName(info[2][13]))
        self.majorBonus2.icon:SetTexture(C_Spell.GetSpellTexture(info[2][13]))
    end


    self.majorBonus1:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self.majorBonus1, "ANCHOR_TOPRIGHT");
        GameTooltip:SetSpellByID(info[1][13]);
        GameTooltip:Show()
    end)
    self.majorBonus2:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self.majorBonus2, "ANCHOR_TOPRIGHT");
        GameTooltip:SetSpellByID(info[2][13]);
        GameTooltip:Show()
    end)
end

function FancyPanelsSpecPanelMixin:ShowDivider()
    self.divider:Show()
end

function FancyPanelsSpecPanelMixin:SetSelected(selected)
    if selected then
        for k, v in ipairs(self.selectedBackgrounds) do
            v:Show()
        end
        self.thumbnailBorder:SetTexCoord(0.1943359375, 0.3515625, 0.83837890625, 0.93701171875)
    else
        for k, v in ipairs(self.selectedBackgrounds) do
            v:Hide()
        end
        self.thumbnailBorder:SetTexCoord(0.00048828125, 0.15771484375, 0.83837890625, 0.93701171875)
    end
end













FancyPanelsTalentIconMixin = {}

function FancyPanelsTalentIconMixin:OnLoad()

    local function UpdateTooltip()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local activeTalentGroup = C_SpecializationInfo.GetActiveSpecGroup(false, false);
        GameTooltip:SetTalent(self.talentInfo.talentID, false, false, activeTalentGroup);
        GameTooltip:Show()
    end

    self:SetScript("OnEnter", function()
        if self.talentInfo then
            self.UpdateTooltip = UpdateTooltip;
            UpdateTooltip()
        end
    end)

    self.pointsBackground:SetTexture(136960)
    self.pointsLabel:SetText(1)

end

function FancyPanelsTalentIconMixin:OnEvent(event, ...)
    
end

function FancyPanelsTalentIconMixin:OnClick(button)
    local isPet, isInspect = false, false;
	local selectedSpec = TalentUIUtil.GetSelectedSpec();
    local activeTalentGroup = C_SpecializationInfo.GetActiveSpecGroup(false, false);
	if ( IsModifiedClick("CHATLINK") ) then
		local link = GetTalentLink(self.tabIndex, self.talentIndex, isInspect, isPet, activeTalentGroup, GetCVarBool("previewTalentsOption"));
		if ( link ) then
			ChatFrameUtil.InsertLink(link);
		end
	elseif ( selectedSpec and (TalentUIUtil.IsActiveSpecSelected() or selectedSpec.pet) ) then
		-- only allow functionality if an active spec is selected
		if ( button == "LeftButton" ) then
			if ( GetCVarBool("previewTalentsOption") ) then
				AddPreviewTalentPoints(self.tabIndex, self.talentIndex, 1, isPet, activeTalentGroup);
                --print("AddPreviewTalentPoints");

                --DevTools_Dump({self.talentInfo})
            else
				--LearnTalent(self.tabIndex, self.talentIndex, isPet, activeTalentGroup);
			    --print("LearnTalent")
            end
		elseif ( button == "RightButton" ) then
			if ( GetCVarBool("previewTalentsOption") ) then
				AddPreviewTalentPoints(self.tabIndex, self.talentIndex, -1, isPet, activeTalentGroup);
			    --print("Remove-AddPreviewTalentPoints")
            end
		end
	end
end

function FancyPanelsTalentIconMixin:SetDataBinding(binding)
    --this func is only called once and is used to set some frame attributes
    --these attributes are used in a t[row][col] manner
    if binding.rowId then
        self.rowId = binding.rowId
    end
    if binding.colId then
        self.colId = binding.colId
    end
end

function FancyPanelsTalentIconMixin:ResetDataBinding()
    
end


--this is the main call to set the players tree talents
function FancyPanelsTalentIconMixin:SetTalent(talentInfo, talentIndex, tabID)

    self:ClearTalent()

    self:SetID(talentIndex)

    self.tabIndex, self.talentIndex = tabID, talentIndex;
    self.talentInfo = talentInfo;

    local data = Util.GetTalentDataByID(talentInfo.talentID);
    self.isPassive = IsPassiveSpell(data[13])

    if not self.isPassive then
        self.mask:Hide()
    else
        self.mask:Show()
    end

    self.icon:SetDesaturation(0)
    self.icon:Show()
    self.pointsBackground:Show()
    self.pointsLabel:Show()
    self.border:Show()

    self:UpdateVisuals();

    self:Show();
end

function FancyPanelsTalentIconMixin:SetNoRank()
    self:SetBorder("gray")
    self.icon:SetDesaturation(1)
    self.pointsLabel:SetText(0)
end

--IsPassiveSpell

function FancyPanelsTalentIconMixin:UpdateVisuals()

    local x, y = self:GetSize()
    self.pointsBackground:SetSize(x*0.3, x*0.3)
    self.pointsLabel:SetSize(x*0.3, x*0.3)

    self.icon:SetTexture(self.talentInfo.icon);

    if (self.talentInfo.previewRank > self.talentInfo.rank) then
        if (self.talentInfo.previewRank == self.talentInfo.maxRank) then
            self:SetBorder("yellow")
        else
            self:SetBorder("green")
        end
        self.pointsLabel:SetText(self.talentInfo.previewRank);
    else
        if (self.talentInfo.rank == 0) then
            self:SetBorder("gray")
            self.icon:SetDesaturation(1)
        elseif (self.talentInfo.rank == self.talentInfo.maxRank) then
            self:SetBorder("yellow")
        else
            self:SetBorder("green")
        end
        self.pointsLabel:SetText(self.talentInfo.rank);
    end
end


function FancyPanelsTalentIconMixin:ClearTalent()
    self.spellId = nil
    self.border:Hide()
    self.pointsBackground:Hide()
    self.pointsLabel:Hide()
    self.icon:Hide()
    self.talentIndex = false;
    self:SetScript("OnMouseDown", nil)
    --self.border:SetAtlas("orderhalltalents-spellborder")
    self:SetBorder("gray")
    self.icon:SetDesaturation(1)
end

local talentBorderAtlas = {
    ['square-gray'] = {0.49072265625,0.52978515625,0.7998046875,0.8779296875,},
    ['square-green'] = {0.49072265625,0.52978515625,0.8798828125,0.9580078125,},
    ['square-locked'] = {0.5341796875,0.5732421875,0.572265625,0.650390625,},
    ['square-shadow'] = {0.22900390625,0.26708984375,0.9228515625,0.9990234375,},
    ['square-yellow'] = {0.5341796875,0.5732421875,0.732421875,0.810546875,},

    ['circle-gray'] = {0.10693359375,0.13134765625,0.5556640625,0.6044921875,},
    ['circle-green'] = {0.10693359375,0.13134765625,0.6064453125,0.6552734375,},
    ['circle-locked'] = {0.10693359375,0.13134765625,0.6572265625,0.7060546875,},
    ['circle-shadow'] = {0.5341796875,0.5712890625,0.888671875,0.962890625,},
    ['circle-yellow'] = {0.67822265625,0.70263671875,0.107421875,0.15625,},
}
function FancyPanelsTalentIconMixin:SetBorder(colour)
    local atlas = ""
    if self.isPassive then
        atlas = "circle-" .. colour;
    else
        atlas = "square-" .. colour;
    end
    self.border:SetTexCoord(talentBorderAtlas[atlas][1], talentBorderAtlas[atlas][2], talentBorderAtlas[atlas][3],
        talentBorderAtlas[atlas][4])
end










--[[
    Equipment tab faux tmog template
]]

FancyPanelsItemModelMixin = {}

function FancyPanelsItemModelMixin:OnLoad()
	self:SetAutoDress(false);
	self:SetUnit("player", false, true);
	self:FreezeAnimation(0, 0, 0);
	local x, y, z = self:TransformCameraSpaceToModelSpace(CreateVector3D(0, 0, -0.25)):GetXYZ();
	self:SetPosition(x, y, z);

	local lightValues = { omnidirectional = false, point = CreateVector3D(-1, 1, -1), ambientIntensity = 1, ambientColor = CreateColor(1, 1, 1), diffuseIntensity = 0, diffuseColor = CreateColor(1, 1, 1) };
	local enabled = true;
	self:SetLight(enabled, lightValues);
    print("model onload")
end

function FancyPanelsItemModelMixin:OnModelLoaded()
    self:SetRotation(0.0);
    self:SetPosition(0,0,0);
    self:FreezeAnimation(0, 0, 0);
    self:SetPortraitZoom(0);

	local x, y, z = self:TransformCameraSpaceToModelSpace(CreateVector3D(0, 0, -0.25)):GetXYZ();
	self:SetPosition(x, y, z);

    local lightValues = {
        omnidirectional = false,
        point = CreateVector3D(-1, 1, -1),
        ambientIntensity = 1,
        ambientColor = CreateColor(1, 1, 1),
        diffuseIntensity = 0,
        diffuseColor = CreateColor(1, 1, 1),
    };
	local enabled = true;
	self:SetLight(enabled, lightValues);

    print("OnModelLoaded")
end


function FancyPanelsItemModelMixin:OnEnter()

end

function FancyPanelsItemModelMixin:OnLeave()
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
end

function FancyPanelsItemModelMixin:OnUpdate()

end

function FancyPanelsItemModelMixin:OnMouseDown(button)

end

function FancyPanelsItemModelMixin:OnShow()

end
















local raceFileStringToId = {
    Human = 1,
    Orc = 2,
    Dwarf = 3,
    NightElf = 4,
    Scourge = 5,
    Tauren = 6,
    Gnome = 7,
    Troll = 8,
    Goblin = 9,
    BloodElf = 10,
    Draenei = 11,

    Worgen = 22,
    Pandaren = 24,
    PandarenAlliance = 25,
    PandarenHorde = 26,
}


--[[

    This needs a massive work through to establish the best data for models per race and slot

]]

addon.modelRaceOffsets = {
    Human = {
        INVTYPE_CHEST = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HEAD = {
            pos = {0,0,-0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HAND = {
            pos = {0.5,0,0.2},
            zoom = 0.5,
            rotation = 0.9,
        },
        INVTYPE_FEET = {
            pos = {0,0,0.8},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_LEGS = {
            pos = {0,0,0.5},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_WRIST = {
            pos = {0.6,0,0.2},
            zoom = 0.52,
            rotation = 0.9,
        },
        INVTYPE_WAIST = {
            pos = {0,0,0.2},
            zoom = 0.8,
            rotation = 0.0,
        },
        INVTYPE_ROBE = {
            pos = {0,0,0.1},
            zoom = 0.45,
            rotation = 0.0,
        },
        INVTYPE_SHOULDER = {
            pos = {0.3,0,-0.15},
            zoom = 0.39,
            rotation = -0.4,
        },
        INVTYPE_BODY = {
            pos = {0,0,0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_SHIELD = {
            pos = {0.2,0,0.2},
            zoom = 0.45,
            rotation = -1.6,
        },
        INVTYPE_RANGED = {
            pos = {0.2,0,0.2},
            zoom = 0.2,
            rotation = -1.6,
        },
        INVTYPE_CLOAK = {
            pos = {0,0,0.15},
            zoom = 0.65,
            rotation = 2.9,
        },
        INVTYPE_TABARD = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_MAINHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_SECONDARYHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_RANGEDRIGHT = {
            pos = {0,0,0.4},
            zoom = 0.4,
            rotation = 0.6,
        },
        INVTYPE_WEAPONOFFHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_WEAPONMAINHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_2HWEAPON = {
            pos = {0,0,0.0},
            zoom = 0.15,
            rotation = 0.8,
        },
        INVTYPE_WEAPON = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
    },
    Dwarf = {
        INVTYPE_CHEST = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HEAD = {
            pos = {0,0,-0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HAND = {
            pos = {0.75,0,0.25},
            zoom = 0.3,
            rotation = 1.1,
        },
        INVTYPE_FEET = {
            pos = {0,0,0.6},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_LEGS = {
            pos = {0,0,0.4},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_WRIST = {
            pos = {0.75,0,0.25},
            zoom = 0.3,
            rotation = 1.1,
        },
        INVTYPE_WAIST = {
            pos = {0,0,0.2},
            zoom = 0.8,
            rotation = 0.0,
        },
        INVTYPE_ROBE = {
            pos = {0,0,0.1},
            zoom = 0.45,
            rotation = 0.0,
        },
        INVTYPE_SHOULDER = {
            pos = {-0.1,0,-0.1},
            zoom = 0.6,
            rotation = -1.1,
        },
        INVTYPE_BODY = {
            pos = {0,0,0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_SHIELD = {
            pos = {0.2,0,0.2},
            zoom = 0.45,
            rotation = -1.6,
        },
        INVTYPE_RANGED = {
            pos = {0.2,0,0.2},
            zoom = 0.2,
            rotation = -1.6,
        },
        INVTYPE_CLOAK = {
            pos = {0,0,0.15},
            zoom = 0.65,
            rotation = 2.9,
        },
        INVTYPE_TABARD = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_MAINHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_SECONDARYHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_RANGEDRIGHT = {
            pos = {0,0,0.4},
            zoom = 0.4,
            rotation = 0.6,
        },
        INVTYPE_WEAPONOFFHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_WEAPONMAINHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_2HWEAPON = {
            pos = {0,0,0.0},
            zoom = 0.15,
            rotation = 0.8,
        },
        INVTYPE_WEAPON = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
    },
    Gnome = {
        INVTYPE_CHEST = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HEAD = {
            pos = {0,0,-0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HAND = {
            pos = {0.75,0,0.25},
            zoom = 0.3,
            rotation = 1.1,
        },
        INVTYPE_FEET = {
            pos = {0,0,0.3},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_LEGS = {
            pos = {0,0,0.3},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_WRIST = {
            pos = {0.75,0,0.15},
            zoom = 0.3,
            rotation = 1.1,
        },
        INVTYPE_WAIST = {
            pos = {0,0,0.2},
            zoom = 0.8,
            rotation = 0.0,
        },
        INVTYPE_ROBE = {
            pos = {0,0,0.1},
            zoom = 0.45,
            rotation = 0.0,
        },
        INVTYPE_SHOULDER = {
            pos = {-0.1,0,-0.0},
            zoom = 0.65,
            rotation = -1.1,
        },
        INVTYPE_BODY = {
            pos = {0,0,0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_SHIELD = {
            pos = {0.2,0,0.2},
            zoom = 0.45,
            rotation = -1.6,
        },
        INVTYPE_RANGED = {
            pos = {0.2,0,0.2},
            zoom = 0.2,
            rotation = -1.6,
        },
        INVTYPE_CLOAK = {
            pos = {0,0,0.15},
            zoom = 0.65,
            rotation = 2.9,
        },
        INVTYPE_TABARD = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_MAINHAND = {
            pos = {0,0,0.1},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_SECONDARYHAND = {
            pos = {0,0,0.1},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_RANGEDRIGHT = {
            pos = {0,0,0.1},
            zoom = 0.4,
            rotation = 0.6,
        },
        INVTYPE_WEAPONOFFHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_WEAPONMAINHAND = {
            pos = {0,0,0.1},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_2HWEAPON = {
            pos = {0,0,0.0},
            zoom = 0.15,
            rotation = 0.8,
        },
        INVTYPE_WEAPON = {
            pos = {0,0,0.1},
            zoom = 0.45,
            rotation = 0.6,
        },
    },
    NightElf = {
        INVTYPE_CHEST = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HEAD = {
            pos = {0,0,-0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HAND = {
            pos = {0.5,0,0.2},
            zoom = 0.5,
            rotation = 0.9,
        },
        INVTYPE_FEET = {
            pos = {0,0,0.8},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_LEGS = {
            pos = {0,0,0.5},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_WRIST = {
            pos = {0.6,0,0.2},
            zoom = 0.52,
            rotation = 0.9,
        },
        INVTYPE_WAIST = {
            pos = {0,0,0.2},
            zoom = 0.8,
            rotation = 0.0,
        },
        INVTYPE_ROBE = {
            pos = {0,0,0.1},
            zoom = 0.45,
            rotation = 0.0,
        },
        INVTYPE_SHOULDER = {
            pos = {0.4,0,-0.15},
            zoom = 0.55,
            rotation = -0.33,
        },
        INVTYPE_BODY = {
            pos = {0,0,0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_SHIELD = {
            pos = {0.2,0,0.2},
            zoom = 0.45,
            rotation = -1.6,
        },
        INVTYPE_RANGED = {
            pos = {0.2,0,0.2},
            zoom = 0.2,
            rotation = -1.6,
        },
        INVTYPE_CLOAK = {
            pos = {0,0,0.15},
            zoom = 0.65,
            rotation = 2.9,
        },
        INVTYPE_TABARD = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_MAINHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_SECONDARYHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_RANGEDRIGHT = {
            pos = {0,0,0.4},
            zoom = 0.4,
            rotation = 0.6,
        },
        INVTYPE_WEAPONOFFHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_WEAPONMAINHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_2HWEAPON = {
            pos = {0,0,0.0},
            zoom = 0.15,
            rotation = 0.8,
        },
        INVTYPE_WEAPON = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
    },
    Draenei = {
        INVTYPE_CHEST = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HEAD = {
            pos = {0,0,-0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HAND = {
            pos = {0.3,0,0.2},
            zoom = 0.7,
            rotation = 0.9,
        },
        INVTYPE_FEET = {
            pos = {0,0,0.9},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_LEGS = {
            pos = {0,0,0.6},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_WRIST = {
            pos = {0.4,0,0.2},
            zoom = 0.7,
            rotation = 0.9,
        },
        INVTYPE_WAIST = {
            pos = {0,0,0.2},
            zoom = 0.8,
            rotation = 0.0,
        },
        INVTYPE_ROBE = {
            pos = {0,0,0.1},
            zoom = 0.45,
            rotation = 0.0,
        },
        INVTYPE_SHOULDER = {
            pos = {0.3,0,-0.15},
            zoom = 0.56,
            rotation = -0.33,
        },
        INVTYPE_BODY = {
            pos = {0,0,0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_SHIELD = {
            pos = {0.6,0,0.25},
            zoom = 0.6,
            rotation = -1.6,
        },
        INVTYPE_RANGED = {
            pos = {0.2,0,0.2},
            zoom = 0.2,
            rotation = -1.6,
        },
        INVTYPE_CLOAK = {
            pos = {0,0,0.15},
            zoom = 0.65,
            rotation = 2.9,
        },
        INVTYPE_TABARD = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_MAINHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_SECONDARYHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_RANGEDRIGHT = {
            pos = {0,0,0.4},
            zoom = 0.4,
            rotation = 0.6,
        },
        INVTYPE_WEAPONOFFHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_WEAPONMAINHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_2HWEAPON = {
            pos = {0,0,0.0},
            zoom = 0.3,
            rotation = 0.8,
        },
        INVTYPE_WEAPON = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
    },


    Orc = {
        INVTYPE_CHEST = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HEAD = {
            pos = {0,0,-0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HAND = {
            pos = {0.5,0,0.2},
            zoom = 0.5,
            rotation = 0.9,
        },
        INVTYPE_FEET = {
            pos = {0,0,0.8},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_LEGS = {
            pos = {0,0,0.5},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_WRIST = {
            pos = {0.6,0,0.2},
            zoom = 0.52,
            rotation = 0.9,
        },
        INVTYPE_WAIST = {
            pos = {0,0,0.2},
            zoom = 0.8,
            rotation = 0.0,
        },
        INVTYPE_ROBE = {
            pos = {0,0,0.1},
            zoom = 0.45,
            rotation = 0.0,
        },
        INVTYPE_SHOULDER = {
            pos = {0.3,0,-0.15},
            zoom = 0.6,
            rotation = -1.1,
        },
        INVTYPE_BODY = {
            pos = {0,0,0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_SHIELD = {
            pos = {0.2,0,0.2},
            zoom = 0.45,
            rotation = -1.6,
        },
        INVTYPE_RANGED = {
            pos = {0.2,0,0.2},
            zoom = 0.2,
            rotation = -1.6,
        },
        INVTYPE_CLOAK = {
            pos = {0,0,0.15},
            zoom = 0.65,
            rotation = 2.9,
        },
        INVTYPE_TABARD = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_MAINHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_SECONDARYHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_RANGEDRIGHT = {
            pos = {0,0,0.4},
            zoom = 0.4,
            rotation = 0.6,
        },
        INVTYPE_WEAPONOFFHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_WEAPONMAINHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_2HWEAPON = {
            pos = {0,0,0.0},
            zoom = 0.15,
            rotation = 0.8,
        },
        INVTYPE_WEAPON = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
    },
    Scourge = {
        INVTYPE_CHEST = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HEAD = {
            pos = {0,0,-0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HAND = {
            pos = {0,0,0.3},
            zoom = 0.7,
            rotation = -1.0,
        },
        INVTYPE_FEET = {
            pos = {0,0,0.8},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_LEGS = {
            pos = {0,0,0.6},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_WRIST = {
            pos = {0,0,0.3},
            zoom = 0.7,
            rotation = -1.0,
        },
        INVTYPE_WAIST = {
            pos = {0,0,0.2},
            zoom = 0.8,
            rotation = 0.0,
        },
        INVTYPE_ROBE = {
            pos = {0,0,0.1},
            zoom = 0.45,
            rotation = 0.0,
        },
        INVTYPE_SHOULDER = {
            pos = {-0.1,0,-0.1},
            zoom = 0.6,
            rotation = -1.1,
        },
        INVTYPE_BODY = {
            pos = {0,0,0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_SHIELD = {
            pos = {0.2,0,0.2},
            zoom = 0.45,
            rotation = -1.2,
        },
        INVTYPE_RANGED = {
            pos = {0.2,0,0.2},
            zoom = 0.2,
            rotation = -1.6,
        },
        INVTYPE_CLOAK = {
            pos = {0,0,0.15},
            zoom = 0.65,
            rotation = 2.9,
        },
        INVTYPE_TABARD = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_MAINHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_SECONDARYHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_RANGEDRIGHT = {
            pos = {0,0,0.4},
            zoom = 0.4,
            rotation = 0.6,
        },
        INVTYPE_WEAPONOFFHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_WEAPONMAINHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_2HWEAPON = {
            pos = {0,0,0.0},
            zoom = 0.15,
            rotation = 0.8,
        },
        INVTYPE_WEAPON = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
    },
    Troll = {
        INVTYPE_CHEST = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HEAD = {
            pos = {0,0,-0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HAND = {
            pos = {0.75,0,0.25},
            zoom = 0.5,
            rotation = 1.1,
        },
        INVTYPE_FEET = {
            pos = {0,0,0.9},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_LEGS = {
            pos = {0,0,0.6},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_WRIST = {
            pos = {0.75,0,0.15},
            zoom = 0.5,
            rotation = 1.1,
        },
        INVTYPE_WAIST = {
            pos = {0,0,0.5},
            zoom = 0.8,
            rotation = 0.0,
        },
        INVTYPE_ROBE = {
            pos = {0,0,0.1},
            zoom = 0.45,
            rotation = 0.0,
        },
        INVTYPE_SHOULDER = {
            pos = {-0.1,0,-0.0},
            zoom = 0.7,
            rotation = -1.1,
        },
        INVTYPE_BODY = {
            pos = {0,0,0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_SHIELD = {
            pos = {0.2,0,0.2},
            zoom = 0.45,
            rotation = -1.6,
        },
        INVTYPE_RANGED = {
            pos = {0.2,0,0.2},
            zoom = 0.2,
            rotation = -1.6,
        },
        INVTYPE_CLOAK = {
            pos = {0,0,0.15},
            zoom = 0.65,
            rotation = 2.9,
        },
        INVTYPE_TABARD = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_MAINHAND = {
            pos = {0,0,0.3},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_SECONDARYHAND = {
            pos = {0,0,0.1},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_RANGEDRIGHT = {
            pos = {0,0,0.1},
            zoom = 0.4,
            rotation = 0.6,
        },
        INVTYPE_WEAPONOFFHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_WEAPONMAINHAND = {
            pos = {0,0,0.3},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_2HWEAPON = {
            pos = {0,0,0.0},
            zoom = 0.15,
            rotation = 0.8,
        },
        INVTYPE_WEAPON = {
            pos = {0,0,0.3},
            zoom = 0.45,
            rotation = 0.6,
        },
    },
    BloodElf = {
        INVTYPE_CHEST = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HEAD = {
            pos = {0,0,-0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HAND = {
            pos = {0.5,0,0.1},
            zoom = 0.7,
            rotation = 0.9,
        },
        INVTYPE_FEET = {
            pos = {0,0,0.9},
            zoom = 0.75,
            rotation = -0.5,
        },
        INVTYPE_LEGS = {
            pos = {0,0,0.52},
            zoom = 0.75,
            rotation = -0.5,
        },
        INVTYPE_WRIST = {
            pos = {0.5,0,0.0},
            zoom = 0.7,
            rotation = 0.9,
        },
        INVTYPE_WAIST = {
            pos = {0,0,0.2},
            zoom = 0.8,
            rotation = -0.5,
        },
        INVTYPE_ROBE = {
            pos = {0,0,0.1},
            zoom = 0.45,
            rotation = 0.0,
        },
        INVTYPE_SHOULDER = {
            pos = {0.4,0,-0.15},
            zoom = 0.6,
            rotation = 0.5,
        },
        INVTYPE_BODY = {
            pos = {0,0,0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_SHIELD = {
            pos = {0.2,0,0.2},
            zoom = 0.45,
            rotation = -1.2,
        },
        INVTYPE_RANGED = {
            pos = {0.2,0,0.2},
            zoom = 0.2,
            rotation = -1.6,
        },
        INVTYPE_CLOAK = {
            pos = {0,0,0.15},
            zoom = 0.65,
            rotation = 2.9,
        },
        INVTYPE_TABARD = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_MAINHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_SECONDARYHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_RANGEDRIGHT = {
            pos = {0,0,0.4},
            zoom = 0.4,
            rotation = 0.6,
        },
        INVTYPE_WEAPONOFFHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_WEAPONMAINHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_2HWEAPON = {
            pos = {0,0,0.0},
            zoom = 0.15,
            rotation = 0.8,
        },
        INVTYPE_WEAPON = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
    },
    Tauren = {
        INVTYPE_CHEST = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HEAD = {
            pos = {0,0,-0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_HAND = {
            pos = {0.3,0,0.2},
            zoom = 0.6,
            rotation = 0.9,
        },
        INVTYPE_FEET = {
            pos = {0,0,0.7},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_LEGS = {
            pos = {0,0,0.5},
            zoom = 0.75,
            rotation = 0.0,
        },
        INVTYPE_WRIST = {
            pos = {0.4,0,0.2},
            zoom = 0.6,
            rotation = 0.9,
        },
        INVTYPE_WAIST = {
            pos = {0,0,0.2},
            zoom = 0.8,
            rotation = 0.0,
        },
        INVTYPE_ROBE = {
            pos = {0,0,0.1},
            zoom = 0.45,
            rotation = 0.0,
        },
        INVTYPE_SHOULDER = {
            pos = {0.3,0,-0.15},
            zoom = 0.5,
            rotation = -1.1,
        },
        INVTYPE_BODY = {
            pos = {0,0,0.1},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_SHIELD = {
            pos = {0.6,0,0.25},
            zoom = 0.2,
            rotation = -1.6,
        },
        INVTYPE_RANGED = {
            pos = {0.2,0,0.2},
            zoom = 0.2,
            rotation = -1.6,
        },
        INVTYPE_CLOAK = {
            pos = {0,0,0.15},
            zoom = 0.65,
            rotation = 2.9,
        },
        INVTYPE_TABARD = {
            pos = {0,0,0.15},
            zoom = 0.85,
            rotation = 0.0,
        },
        INVTYPE_MAINHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_SECONDARYHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_RANGEDRIGHT = {
            pos = {0,0,0.4},
            zoom = 0.4,
            rotation = 0.6,
        },
        INVTYPE_WEAPONOFFHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = -0.7,
        },
        INVTYPE_WEAPONMAINHAND = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
        INVTYPE_2HWEAPON = {
            pos = {0,0,0.0},
            zoom = 0.3,
            rotation = 0.8,
        },
        INVTYPE_WEAPON = {
            pos = {0,0,0.4},
            zoom = 0.45,
            rotation = 0.6,
        },
    },
}

--look up table to set the mog slotID
local outfitInvSlots = {
["INVTYPE_HEAD"] = 1,
["INVTYPE_SHOULDER"] = 3,
["INVTYPE_BODY"] = 4,
["INVTYPE_CHEST"] = 5,
["INVTYPE_ROBE"] = 5,
["INVTYPE_WAIST"] = 6,
["INVTYPE_LEGS"] = 7,
["INVTYPE_FEET"] = 8,
["INVTYPE_WRIST"] = 9,
["INVTYPE_HAND"] = 10,
["INVTYPE_CLOAK"] = 15,
["INVTYPE_MAINHAND"] = 16,
["INVTYPE_OFFHAND"] = 17,
["INVTYPE_RANGED"] = 16,
["INVTYPE_RANGEDRIGHT"] = 16,
["INVTYPE_TABARD"] = 19,
["INVTYPE_WEAPON"] = 16,
["INVTYPE_2HWEAPON"] = 16,
["INVTYPE_WEAPONMAINHAND"] = 16,
["INVTYPE_WEAPONOFFHAND"] = 17,
["INVTYPE_SHIELD"] = 17,
["INVTYPE_HOLDABLE"] = 17,
}

--used to determine the model position
local equipLocationWeapons = {
    [0] = "INVTYPE_WEAPON",
    [1] = "INVTYPE_2HWEAPON",
    [2] = "INVTYPE_RANGED",
    [3] = "INVTYPE_RANGEDRIGHT",
    [4] = "INVTYPE_WEAPON",
    [5] = "INVTYPE_2HWEAPON",
    [6] = "INVTYPE_2HWEAPON",
    [7] = "INVTYPE_WEAPON",
    [8] = "INVTYPE_2HWEAPON",
    [9] = "INVTYPE_WEAPON",
    [10] = "INVTYPE_2HWEAPON",
    [11] = "INVTYPE_WEAPON",
    [12] = "INVTYPE_WEAPON",
    [13] = "INVTYPE_WEAPON",
    [14] = "INVTYPE_WEAPON",
    [15] = "INVTYPE_WEAPON",
    [16] = "INVTYPE_WEAPON",
    [17] = "INVTYPE_WEAPONOFFHAND",
    [18] = "INVTYPE_RANGED",
    [19] = "INVTYPE_WEAPON",
    [20] = "INVTYPE_WEAPON",
}

local classIdArmorType = {
    [1] = 4, --warrior
    [2] = 4, --paladin
    [3] = 3, --hunter
    [4] = 2, --rogue
    [5] = 1, --priest
    [6] = 4, --dk
    [7] = 3, --shaman
    [8] = 1, --mage
    [9] = 1, --warlocki
    [10] = 2, --monk
    [11] = 2, --druid
    [12] = 2, --dh
}

local spacingNoSmallButton = 2;
local spacingWithSmallButton = 12;
local defaultSectionSpacing = 24;
local shorterSectionSpacing = 19;





FancyPanelsOutfitListItemMixin = {}
function FancyPanelsOutfitListItemMixin:OnLoad()
    self:RegisterForDrag("LeftButton");
    Util.ApplyAtlas(self.iconBorder, "interface/talentframe/talents", "talents-node-square-gray")
end
function FancyPanelsOutfitListItemMixin:SetDataBinding(binding, height)
    local setName, iconFileID, setID, isEquipped, numItems, numEquipped, numInInventory, numLost, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(binding);
    self.label:SetText(setName);
    self.icon:SetTexture(iconFileID);

    self:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT");
        GameTooltip:SetEquipmentSet(setName);
        GameTooltip:Show();
    end)

    self:SetScript("OnClick", function()
        C_EquipmentSet.UseEquipmentSet(setID);
    end)

    self:SetScript("OnDragStart", function()
        C_EquipmentSet.PickupEquipmentSet(setID);
    end)

    self.modify:SetScript("OnClick", function (_, hwButton)
        MenuUtil.CreateContextMenu(self, function(self, rootDescription)
            
            rootDescription:CreateTitle(setName);
            rootDescription:CreateDivider();

            rootDescription:CreateButton(UPDATE, function()
                C_EquipmentSet.SaveEquipmentSet(setID)
            end)
            rootDescription:CreateButton(EQUIPMENT_SET_EDIT, function()
                addon.CallbackRegistry:TriggerEvent(addon.Callbacks.CharacterEquipmentSet_OnEdit, setID, setName, iconFileID);
            end)
            rootDescription:CreateButton(TRANSMOG_OUTFIT_DELETE, function()
                C_EquipmentSet.DeleteEquipmentSet(setID)
                addon.CallbackRegistry:TriggerEvent(addon.Callbacks.CharacterEquipmentSet_OnDeleted);
            end)

        end)
    end)
end

function FancyPanelsOutfitListItemMixin:ResetDataBinding()
    self.label:SetText("");
    self.icon:SetTexture(nil);
end



--glueannouncementpopup-icon-info

FancyPanelCharacterInvSlotMixin = {};

function FancyPanelCharacterInvSlotMixin:OnLoad()
    Util.ApplyAtlas(self.iconBorder, "interface/talentframe/talents", "talents-node-square-gray")
    self:RegisterEvent("UNIT_INVENTORY_CHANGED");

    addon.CallbackRegistry:RegisterCallback(addon.Callbacks.CharacterOptions_OnChanged, self.OnEvent_Private, self)

end

function FancyPanelCharacterInvSlotMixin:OnEnter()
    -- local newItemLink = GetInventoryItemLink("player", self.invSlotId);
    -- self.itemLink = newItemLink;
    -- if (self.itemLink) then
    --     GameTooltip:SetOwner(self, self.tooltipAnchor);
    --     GameTooltip:SetHyperlink(self.itemLink);
    --     GameTooltip:Show();
    -- end

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    local hasItem, hasCooldown, repairCost = GameTooltip:SetInventoryItem("player", self:GetID());

    if (repairCost and (repairCost > 0)) then
        GameTooltip:AddLine(REPAIR_COST, "", 1, 1, 1);
        GameTooltip_AddMoneyLine(GameTooltip, repairCost);
        GameTooltip:Show();
    end
end

function FancyPanelCharacterInvSlotMixin:OnEvent_Private()
    self.suggestedUpgradeLink = nil;

    local newItemLink = GetInventoryItemLink("player", self.invSlotId);
    if ( newItemLink ~= self.itemLink ) then
        self.itemChangedAnim:Play();
    end

    self.itemLink = newItemLink;

    if SavedVars:Get("characterModel.suggestItemUpgrade") == true then
        --self:CheckForUpgrades();
    end

    self:UpdateVisuals();
end

function FancyPanelCharacterInvSlotMixin:SetAllign(allign)
    self.allign = allign;

    if (allign == "left") then
        self.link:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, -4);
        self.link:SetJustifyH("LEFT");
        self.itemModContainer:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 5, 4);
        self.upgradeSuggestionButton:ClearAllPoints();
        self.upgradeSuggestionButton:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", -2, 0);

    elseif (allign == "right") then
        self.link:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, -4);
        self.link:SetJustifyH("RIGHT");
        self.itemModContainer:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", -5, 4)
        self.upgradeSuggestionButton:ClearAllPoints();
        self.upgradeSuggestionButton:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 2, 0);

    end
end

function FancyPanelCharacterInvSlotMixin:OnEvent(event, ...)
    if (event ~= "UNIT_INVENTORY_CHANGED") then
        --return;
    end
    local unit = ...;
    if (unit ~= "player") then
        return;
    end
    self:OnEvent_Private();
end


local function InitMacroButton(parent, menu, item, invSlotId)
    local isab = FancyPanelsMacroButton or CreateFrame("Button", "FancyPanelsMacroButton", UIParent, "InsecureActionButtonTemplate");
    isab:SetHighlightAtlas("groupfinder-highlightbar-blue");
    isab:RegisterForClicks("AnyDown");
    isab:ClearAllPoints();
    isab:SetParent(parent);
    isab:SetPoint("TOPLEFT");
    isab:SetPoint("BOTTOMRIGHT");
    isab:SetAttribute("type", "macro");

    local macro = string.format([[
/use %d %d
/use %d
]], item.bag, item.slot, invSlotId);

    isab:SetAttribute("macrotext1", macro);

    isab:SetFrameLevel(parent:GetFrameLevel() + 1);

    isab:SetScript("OnEnter", function()
        GameTooltip:SetOwner(parent, "ANCHOR_RIGHT");
        if (item.bag and item.slot) then
            GameTooltip:SetBagItem(item.bag, item.slot);
        else
            GameTooltip:SetHyperlink(item.link);
        end
        GameTooltip:Show();
    end);

    isab:SetScript("OnMouseUp", function(_, hwButton)
        menu:Pick(MenuInputContext.MouseButton, hwButton)
        isab:ClearAllPoints();
        isab:SetParent(UIParent);
        isab:SetPoint("RIGHT", UIParent, "LEFT", -10, 0)
    end)
end

function FancyPanelCharacterInvSlotMixin:OnClick()

    if (self.itemLink and IsModifiedClick()) then
        HandleModifiedItemClick(GetInventoryItemLink("player", self:GetID()));
        --HandleModifiedItemClick(self.itemLink);
        return;
    end

    local consumables = Util.GetContainerItems({
        classID = 0,
        subClassID = 8,
        --tooltipScanStringMatch = "^(%d+) Charges$"
    })

    local itemEnhancements = Util.GetContainerItems(nil, addon.TEMP_ITEM_ENHANCEMENTS)

    --DevTools_Dump({consumables});


    local itemsForSlot = Util.GetContainerItemsForInvSlot(self.equipLoc);
    if (#itemsForSlot > 0) or (#consumables > 0) then

        MenuUtil.CreateContextMenu(self, function(_, rootDescription)

            if (#itemsForSlot > 0) then
                if type(self.equipLoc) == "table" then
                    rootDescription:CreateTitle(_G[self.equipLoc[1]]);
                else
                    rootDescription:CreateTitle(_G[self.equipLoc]);
                end
                rootDescription:CreateDivider()
            end

            for _, link in ipairs(itemsForSlot) do
                local itemName = C_Item.GetItemNameByID(link)

                local itemButton = rootDescription:CreateButton(link, function()
                    if ( C_Item.IsEquippableItem(itemName)) then

                        --found a bug using the name, i couldn't equip the mount hyjal rep ring Band of Eternity
                        --using the itemLink seemed to fix the problem
                        C_Item.EquipItemByName(link, self.invSlotId);
                    else
                        --print("failed is equippable", itemName)
                    end
                end)

                if (SavedVars:Get("characterModel.suggestItemUpgrade") == true) and (link == self.suggestedUpgradeLink) then
                    itemButton:AddInitializer(function(button, desc, menu)
                        local icon = button:AttachTexture();
                        icon:SetPoint("LEFT");
                        icon:SetSize(15, 18);
                        icon:SetAtlas("loottoast-arrow-green");

                        button.fontString:SetPoint("LEFT", icon, "RIGHT", 4, 0)
                    end)
                end

                itemButton:SetTooltip(function()
                    GameTooltip:SetHyperlink(link);
                end)

            end

            if (#itemEnhancements > 0) then
                if (#itemsForSlot > 0) then
                    rootDescription:CreateDivider();
                end

                rootDescription:CreateTitle(C_Item.GetItemClassInfo(8));

                for k, enhancement in ipairs(itemEnhancements) do
                    
                    local enhancementButton = rootDescription:CreateButton(enhancement.link, function()
                    
                    end)

                    enhancementButton:HookOnEnter(function(button, description)
                        InitMacroButton(button, description, enhancement, self.invSlotId)
                    end)

                    enhancementButton:SetResponder(function()
                        return MenuResponse.CloseAll;
                    end)
                end

            end

            if (#consumables > 0) then
                if (#itemsForSlot > 0) then
                    rootDescription:CreateDivider();
                end

                rootDescription:CreateTitle(C_Item.GetItemClassInfo(0));

                --attempt to find charges for items like wizard oil
                for k, v in ipairs(consumables) do
                    local charges = Util.ScanTooltip(nil, v.bag, v.slot, "^(%d+) Charges$");
                    if charges then
                        v.numCharges = tonumber(charges);
                    end
                end

                --quickly sort for any items with charges, the menu will use the first item and ignore
                --any matching itemIDs after, so set the lowest charged item first
                table.sort(consumables, function(a, b)
                    if a.numCharges and b.numCharges then
                        return a.numCharges < b.numCharges;
                    else
                        return a.link < b.link;
                    end
                end)

                --local addedItemIDs = {};

                for _, consumable in ipairs(consumables) do

                    --if addedItemIDs[consumable.itemID] == nil then
                        
                        local consumableButton = rootDescription:CreateButton(consumable.link, function()
                        
                        end)

                        -- local function SetTooltip(parent, link)
                        --     GameTooltip:SetOwner(parent, "ANCHOR_RIGHT");
                        --     GameTooltip:SetHyperlink(link);
                        --     GameTooltip:Show();
                        -- end


                        --[[
                            Absolutey up yours Blizzard and this menu system

                            You CANNOT use SetTooltip AND SetOnEnter or HookOnEnter

                            So, to make a very simple in-game behaviour possible (aka to apply an oil, or any other temp enchant) we
                            need a ISAB to make use of a macro (fine).

                            To get it working was less than straight forward, AND its still not possible to target a specific
                            item, players (probably) want to use the item with less charges....

                            So, I had to use a global macro button (ISAB) and layer it above your menu button in its OnEnter to be 
                            able to use the macro aspect of it. 
                            BUT this removed the organic feel of the Blizz Menu button (the highlight texture for example).

                            Anyways, its working for now.
                        
                        ]]
                        consumableButton:HookOnEnter(function(button, description, menu)
                            InitMacroButton(button, description, consumable, self.invSlotId)

--                             local isab = FancyPanelsMacroButton or CreateFrame("Button", "FancyPanelsMacroButton", UIParent, "InsecureActionButtonTemplate");
--                             isab:SetHighlightAtlas("groupfinder-highlightbar-blue");
--                             isab:RegisterForClicks("AnyDown");
--                             isab:ClearAllPoints();
--                             isab:SetParent(button);
--                             isab:SetPoint("TOPLEFT");
--                             isab:SetPoint("BOTTOMRIGHT");
--                             isab:SetAttribute("type", "macro");

--                             local macro = string.format([[
-- /use %d %d
-- /use %d
-- ]], consumable.bag, consumable.slot, self.invSlotId);

--                             isab:SetAttribute("macrotext1", macro);

--                             isab:SetFrameLevel(button:GetFrameLevel() + 1);

--                             isab:SetScript("OnEnter", function()
--                                 SetTooltip(button, consumable.link);
--                             end);

--                             isab:SetScript("OnMouseUp", function(_, hwButton)
--                                 description:Pick(MenuInputContext.MouseButton, hwButton)
--                                 isab:ClearAllPoints();
--                                 isab:SetParent(UIParent);
--                                 isab:SetPoint("RIGHT", UIParent, "LEFT", -10, 0)
--                             end)

                        end)
                        
                        consumableButton:SetResponder(function()
                            return MenuResponse.CloseAll;
                        end)

                        --addedItemIDs[consumable.itemID] = true;

                    --end
                end

            end

        end)
    end

end

local function CompareStats(s1, s2)

    local t = {};

    if (s1 == nil) or (s2 == nil) then
        return t;
    end

    --loop through item1stats and check for a matching stat in item2stats
    for statGlobalString, statValue in pairs(s1) do
        if s2[statGlobalString] then
            local delta = (s2[statGlobalString] - s1[statGlobalString]);
            t[statGlobalString] = delta;
        else
            t[statGlobalString] = -statValue;
        end
    end

    for statGlobalString, statValue in pairs(s2) do
        if t[statGlobalString] == nil then
            t[statGlobalString] = statValue;
        end
    end

    return t;
end

local function SortStatUpgrades(data)

end

function FancyPanelCharacterInvSlotMixin:CheckForUpgrades()
    if self.itemLink then
        local t = {};
        local currentStats = GetItemStats(self.itemLink)
        local itemsForSlot = Util.GetContainerItemsForInvSlot(self.equipLoc);
        
        --need to include the currently equipped item as well
        table.insert(itemsForSlot, self.itemLink);

        if (#itemsForSlot > 0) then
            for _, link in ipairs(itemsForSlot) do
                local stats = GetItemStats(link);
                local delta = CompareStats(currentStats, stats);

                -- if delta["ITEM_MOD_INTELLECT_SHORT"] and (delta["ITEM_MOD_INTELLECT_SHORT"] > 0) then
                --     self.suggestedUpgradeLink = link;
                -- end

                table.insert(t, {
                    link = link,
                    statDelta = delta,
                })
            end
        end

        if (#t > 1) then
            local stat = "ITEM_MOD_INTELLECT_SHORT";

            local safeSort = true;
            for k, v in ipairs(t) do
                if v.statDelta == nil then
                    safeSort = false;
                else
                    if v.statDelta[stat] == nil then
                        safeSort = false;
                    end
                end
            end

            if safeSort == true then
                table.sort(t, function(a, b)
                    return a.statDelta[stat] > b.statDelta[stat];
                end)
            end
        end

        if (#t > 0) then
            self.suggestedUpgradeLink = t[1].link;
        end
    end
end

-- local qualityAtlasMap = {
--     --[1] = "loottoast-itemborder-blue",
--     [2] = "bags-glow--green",
--     [3] = "bags-glow-blue",
--     [4] = "bags-glow-purple",
--     [5] = "bags-glow-orange",
-- }

local qualityBorderMap = {
    --[0] = "Relicforge-Slot-frame",
    [1] = "loottoast-itemborder-artifact",
    [2] = "loottoast-itemborder-green",
    [3] = "loottoast-itemborder-blue",
    [4] = "loottoast-itemborder-purple",
    [5] = "loottoast-itemborder-orange",
}

local desatEnchantTexture = [[Interface\AddOns\FancyPanels\Media\DesaturatedFormula.png]];

function FancyPanelCharacterInvSlotMixin:UpdateVisuals()


    self.link:SetText("");
    self.icon:SetTexture(self.slotIcon);
    self.qualityBorder:Hide();
    self.itemModContainer:Hide();
    self.iconBorder:Show();
    self.upgradeSuggestionButton:Hide();

    self.itemModContainer.mod1:SetNormalTexture(desatEnchantTexture);

    -- if (self.suggestedUpgradeLink ~= nil) then
    --     self.upgradeSuggestionButton:Show();

    --     self.upgradeSuggestionButton:SetScript("OnEnter", function(button)
    --         GameTooltip:SetOwner(button, "ANCHOR_TOPRIGHT");
    --         GameTooltip:SetHyperlink(self.suggestedUpgradeLink);
    --         GameTooltip:Show();
    --     end)

    --     self.upgradeSuggestionButton:SetScript("OnClick", function()
    --         local itemName = C_Item.GetItemNameByID(self.suggestedUpgradeLink)
    --         if ( C_Item.IsEquippableItem(itemName)) then
    --             C_Item.EquipItemByName(itemName, self.invSlotId);
    --         end
    --     end)
    -- end

    for i = 1, 4 do
        self.itemModContainer["mod"..i]:Hide();
    end

    if self.itemLink then
        local icon = select(5, C_Item.GetItemInfoInstant(self.itemLink));
        self.icon:SetTexture(icon);

        if (SavedVars:Get("characterModel.showItemLinks") == true) then
            self.link:SetText(self.itemLink);
        end

        if (SavedVars:Get("characterModel.showItemQuality") == true) then
            local quality = C_Item.GetItemQualityByID(self.itemLink);
            if qualityBorderMap[quality] then
                self.qualityBorder:SetAtlas(qualityBorderMap[quality]);
                self.qualityBorder:Show();
                self.iconBorder:Hide();
            end
        end

        local showEnchant = SavedVars:Get("characterModel.showItemEnchantments");
        local showSockets = SavedVars:Get("characterModel.showGemSockets");

        --print(showEnchant, showSockets)
        self:UpdateItemMods(showEnchant, showSockets);

    end
end

-- local slotsCanBeEnchanted = {
--     [true] = {
--         [2] = false,
--         [6] = false,
--         [13] = false,
--         [14] = false,

--         [1] = true,
--         [3] = true,
--         [4] = true,
--         [5] = true,
--         [7] = true,
--         [8] = true,
--         [9] = true,
--         [10] = true,
--         [11] = true,
--         [12] = true,
--         [15] = true,
--         [16] = true,
--     },
--     [false] = {
--         [2] = false, --neck
--         [6] = false, --tabard
--         [11] = false, --finger0
--         [12] = false, --finger1
--         [13] = false, --trinket0
--         [14] = false, --trinket1

--         [1] = true,
--         [3] = true,
--         [4] = true,
--         [5] = true,
--         [7] = true,
--         [8] = true,
--         [9] = true,
--         [10] = true,
--         [15] = true,
--         [16] = true,
--     },
-- }

-- local enchantingSkillSpells = {
--     [7411] = 333, --apprentice
--     [7412] = 333, --journeyman
--     [7413] = 333, --expert
--     [13920] = 333, --artisan
--     [28029] = 333, --master
-- }
-- local function CanEnchantSlot(slot)
--     local isEnchanter = false;
--     for id, _ in pairs(enchantingSkillSpells) do
--         if (C_SpellBook.IsSpellKnown(id)) then
--             isEnchanter = true;
--             break;
--         end
--     end

--     return slotsCanBeEnchanted[isEnchanter][slot];
-- end

function FancyPanelCharacterInvSlotMixin:UpdateItemMods(showEnchant, showSockets)

    local itemInfo = Util.GetItemModInfo(self.itemLink);
    if itemInfo then

        self.itemModContainer:Show();

        self.itemModContainer:SetWidth(1 + (#itemInfo * 19));

        -- if CanEnchantSlot(self:GetID()) == true then

        -- end

        --this value controls which mod button is positioned first, ignore mod1 if no enchant or hide enchants
        local startIndex = 1;
        if (showEnchant ~= true) then
            startIndex = 2;
        end
        
        if (showEnchant == true) then
            if itemInfo[1] and (itemInfo[1].modType == "enchant") and (itemInfo[1].id) then
                self.itemModContainer.mod1:SetNormalTexture(desatEnchantTexture);
                self.itemModContainer.mod1:Show();
                self.itemModContainer.mod1:SetEnchant(itemInfo[1].id);
            else
                startIndex = 2;
            end
        end

        if (showSockets == true) then
            for i = 2, 4 do
                self.itemModContainer["mod" .. i]:Reset();
                self.itemModContainer["mod" .. i]:SetInvSlotID(self:GetID());
                if itemInfo[i] then
                    if itemInfo[i] then
                        self.itemModContainer["mod" .. i]:SetGem(itemInfo[i]);
                        self.itemModContainer["mod" .. i]:Show();
                    end
                end
            end
        end
        
        local lastButton;
        if self.allign == "right" then
            for i = startIndex, 4 do
                --print(i)
                local button = self.itemModContainer["mod" .. i]
                button:ClearAllPoints();
                if (i == startIndex) then
                    button:SetPoint("RIGHT", self.itemModContainer, "RIGHT", -1, 0);
                    lastButton = button;
                else
                    button:SetPoint("RIGHT", lastButton, "LEFT", -1, 0);
                    lastButton = button;
                end
            end
        else
            for i = startIndex, 4 do
                local button = self.itemModContainer["mod" .. i]
                button:ClearAllPoints();
                if (i == startIndex) then
                    button:SetPoint("LEFT", self.itemModContainer, "LEFT", 1, 0);
                    lastButton = button;
                else
                    button:SetPoint("LEFT", lastButton, "RIGHT", 1, 0);
                    lastButton = button;
                end
            end
        end

    else
        --print("===== NO MODS FOUND ======", self.itemLink);
    end
end











FancyPanelsItemSocketMixin = {};

function FancyPanelsItemSocketMixin:OnLoad()
	-- self:RegisterForDrag("LeftButton");
	-- self:RegisterEvent("SOCKET_INFO_UPDATE");
end

function FancyPanelsItemSocketMixin:SetInvSlotID(invSlotID)
    self.invSlotID = invSlotID;
end

function FancyPanelsItemSocketMixin:SetGem(gem)
    self.itemID = gem.id;
    self.emptySocketTexture = gem.textureFileID;

    if (self.itemID) then
        local icon = select(5, C_Item.GetItemInfoInstant(gem.id))
        self:SetNormalTexture(icon);
    else
        self:SetNormalTexture(gem.textureFileID);
    end
end

function FancyPanelsItemSocketMixin:Reset()
    self.itemID = nil;
    self.enchantID = nil;
    self.invSlotID = nil;
    self.emptySocketTexture = nil;
end

--hijack the template for enchant icon
function FancyPanelsItemSocketMixin:SetEnchant(id)
    self.enchantID = id;
end

-- function FancyPanelsItemSocketMixin:ClickSocketButton()
-- 	StaticPopup_Hide("DELETE_ITEM");
-- 	StaticPopup_Hide("DELETE_QUEST_ITEM");
-- 	StaticPopup_Hide("DELETE_GOOD_ITEM");
-- 	StaticPopup_Hide("DELETE_GOOD_QUEST_ITEM");
-- 	C_ItemSocketInfo.ClickSocketButton(self:GetID());
-- end


local socketFileIDs = {
    EMPTY_SOCKET_BLUE = 136256,
    EMPTY_SOCKET_META = 136257,
    EMPTY_SOCKET_RED = 136258,
    EMPTY_SOCKET_YELLOW = 136259,
    EMPTY_SOCKET_PRISMATIC = 458977,
}

local SocketColourMapAtlas = {
    Purple = string.format("%s %s", 
        CreateSimpleTextureMarkup(socketFileIDs.EMPTY_SOCKET_RED, 18, 18),
        CreateSimpleTextureMarkup(socketFileIDs.EMPTY_SOCKET_BLUE, 18, 18)
    ),
    Green = string.format("%s %s", 
        CreateSimpleTextureMarkup(socketFileIDs.EMPTY_SOCKET_BLUE, 18, 18),
        CreateSimpleTextureMarkup(socketFileIDs.EMPTY_SOCKET_YELLOW, 18, 18)
    ),
    Orange = string.format("%s %s", 
        CreateSimpleTextureMarkup(socketFileIDs.EMPTY_SOCKET_RED, 18, 18),
        CreateSimpleTextureMarkup(socketFileIDs.EMPTY_SOCKET_YELLOW, 18, 18)
    ),
    Red = string.format("%s      ", 
        CreateSimpleTextureMarkup(socketFileIDs.EMPTY_SOCKET_RED, 18, 18)
    ),
    BLue = string.format("%s      ", 
        CreateSimpleTextureMarkup(socketFileIDs.EMPTY_SOCKET_BLUE, 18, 18)
    ),
    Yellow = string.format("%s      ", 
        CreateSimpleTextureMarkup(socketFileIDs.EMPTY_SOCKET_YELLOW, 18, 18)
    ),
    -- Red = CreateSimpleTextureMarkup(socketFileIDs.EMPTY_SOCKET_RED, 18, 18),
    -- Blue = CreateSimpleTextureMarkup(socketFileIDs.EMPTY_SOCKET_BLUE, 18, 18),
    -- Yellow = CreateSimpleTextureMarkup(socketFileIDs.EMPTY_SOCKET_YELLOW, 18, 18),
}
function FancyPanelsItemSocketMixin:OnClick()

    if self.enchantID then
        return;
    end

    local gems = Util.GetContainerItems({
        classID = 3,
    })

    if (#gems > 0) then
        MenuUtil.CreateContextMenu(self, function(_, root)
            root:CreateTitle("Select New Gem");
            root:CreateDivider();

            for _, gem in ipairs(gems) do
                if (gem.isLocked == false) then

                    local _, _, colour = C_Item.GetItemInfoInstant(gem.link)

                    local buttonText = gem.link;
                    if SocketColourMapAtlas[colour] then
                        buttonText = string.format("%s  %s", SocketColourMapAtlas[colour], gem.link);
                    end

                    local gemButton = root:CreateButton(buttonText, function()
                        -- if (IsModifiedClick("EXPANDITEM")) then
                        --     print("EXPAND IF")
                        --     local itemLocation = ItemLocation:CreateFromEquipmentSlot(self.invSlotID);
                        --     if C_Item.DoesItemExist(itemLocation) then
                        --         print("EXISTS IF")
                        --         SocketInventoryItem(self.invSlotID);
                        --     end
                        --     return;
                        -- end

                        -- local parentID = self:GetParent():GetID();
                        -- print(parentID, self.invSlotID);

                        --[[
                                                    C_Container.PickupContainerItem(bag, slot)
                                ClickSocketButton(self:GetID());
                                AcceptSockets()
                                HideUIPanel(ItemSocketingFrame)
                        ]]


                        --SocketInventoryItem(self.invSlotID);
                        --C_Container.PickupContainerItem(gem.bag, gem.slot)
                        --self:OnEnter_Click();

                        --[[
                            So to make this fluid we want to let the user just click a gem from their bags and socket it
                            probably with 1 dialog check/confirm (maybe setup a config to bypass this?)

                            To get going we need to get the ItemSocketingFrame shown and init'd for the InvSlot item
                            maybe also just temp move it off screen?

                            Then apply the new gem and confirm - easy right !!!
                        ]]

                        self:SocketContextMenuButton_OnClick(gem)
                    end)
                    gemButton:SetTooltip(function()
                        GameTooltip:SetHyperlink(gem.link);
                    end)
                end
            end
        end)
    end

end

function FancyPanelsItemSocketMixin:SocketContextMenuButton_OnClick(gem)

    SocketInventoryItem(self.invSlotID);

    ItemSocketingFrame:ClearAllPoints();
    ItemSocketingFrame:SetPoint("RIGHT", UIParent, "LEFT", -10, 0);

    C_Container.PickupContainerItem(gem.bag, gem.slot);
    ClickSocketButton(self:GetID());

    --C_ItemSocketInfo.CloseSocketInfo();
    --local gemColor = C_ItemSocketInfo.GetSocketTypes(self:GetID());
    --print(gemColor)
    local newSocket, newIcon, newMatchesColour = C_ItemSocketInfo.GetNewSocketInfo(self:GetID());
    local existingSocket, oldIcon, oldMatchesColour = C_ItemSocketInfo.GetExistingSocketInfo(self:GetID());
    --DevTools_Dump({ newSocket, existingSocket})

    local confirmChanges = SavedVars:Get("characterModel.confirmSocketChanges");

    if (confirmChanges == true) then
        
        local function SocketGem_OnChanged(icon)
            self:SetNormalTexture(icon);
            self.pendingChangePulse:Play();
        end

        local function SocketGem_OnCancel()
            self.pendingChangePulse:Stop();
            if oldIcon then
                self:SetNormalTexture(oldIcon);
            else
                self:SetNormalTexture(self.emptySocketTexture)
            end
            GameTooltip:Hide();
        end

        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        if ( newSocket ) then
            GameTooltip:SetSocketGem(self:GetID());
            StaticPopup_Show("FANCY_PANELS_CONFIRM_ACCEPT_SOCKETS", 
            nil, 
            nil, 
            { callback = SocketGem_OnCancel }
            );
            --StaticPopup_Hide

            SocketGem_OnChanged(newIcon)
        else
            GameTooltip:SetExistingSocketGem(self:GetID());
        end
        if (newSocket and existingSocket) then
            ShoppingTooltip1:SetOwner(GameTooltip, "ANCHOR_NONE");
            ShoppingTooltip1:ClearAllPoints();
            ShoppingTooltip1:SetPoint("TOPLEFT", "GameTooltip", "TOPRIGHT", 0, -10);
            ShoppingTooltip1:SetExistingSocketGem(self:GetID(), true);
            ShoppingTooltip1:Show();

            StaticPopup_Show("FANCY_PANELS_CONFIRM_ACCEPT_SOCKETS", 
            nil, 
            nil, 
            { callback = SocketGem_OnCancel }
            );

            SocketGem_OnChanged(newIcon)

        end
        GameTooltip:Show();

    else
        C_ItemSocketInfo.AcceptSockets();
        self:SetNormalTexture(newIcon);
        ItemSocketingFrameCloseButton:Click();
    end

end

-- function FancyPanelsItemSocketMixin:OnReceiveDrag()
-- 	self:ClickSocketButton();
-- end

-- function FancyPanelsItemSocketMixin:OnDragStart()
-- 	self:ClickSocketButton();
-- end

function FancyPanelsItemSocketMixin:OnEnter()
    if self.itemID then
        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
        GameTooltip:SetItemByID(self.itemID);
        GameTooltip:Show();
    end
    if self.enchantID and addon.ENCHANT_EFFECT_DATA[self.enchantID] and addon.ENCHANT_EFFECT_DATA[self.enchantID].effect1 then
        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
        --GameTooltip:SetSpellByID(addon.ENCHANT_EFFECT_DATA[self.enchantID].effect1);
        GameTooltip:AddLine(addon.ENCHANT_EFFECT_DATA[self.enchantID].name);
        GameTooltip:Show();
    end
end


function FancyPanelsItemSocketMixin:OnEvent(event, ...)
    -- if (event == "SOCKET_INFO_UPDATE") then
    --     if (GameTooltip:IsOwned(self)) then
    --         self:OnEnter();
    --     end
    -- end
end





local RepTotals = {
    [0] = -21000,
    [1] = -12000,
    [2] = -6000,
    [3] = -3000,
    [4] = 0,
    [5] = 3000,
    [6] = 6000,
    [7] = 12000,
    [8] = 21000,
}

local StandingColours = {
    [1] = CreateColorFromHexString("ffcc0000"),
    [2] = CreateColorFromHexString("ffff0000"),
    [3] = CreateColorFromHexString("fff26000"),
    [4] = CreateColorFromHexString("ffe4e400"),
    [5] = CreateColorFromHexString("ff33ff33"),
    [6] = CreateColorFromHexString("ff5fe65d"),
    [7] = CreateColorFromHexString("ff53e9bc"),
    [8] = CreateColorFromHexString("ff2ee6e6"),
}



FancyPanelsRepDialMixin = {}
function FancyPanelsRepDialMixin:InitRep(rep)

    if addon.Constants.RepIcons[rep.factionID] then
        self:SetIcon(addon.Constants.RepIcons[rep.factionID]);
    else
        self:SetIcon("PhotosensitivityWarning-questbang-icon");
    end

    local r, g, b = 1, 1, 1;
    if StandingColours[rep.standingId] then
        r, g, b = StandingColours[rep.standingId]:GetRGB();
    end
    self:SetColour(r,g,b);

    self:SetValue(rep.currentValue, rep.maxValue, true);

    self.header:SetText(rep.factionName);

    self:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
        GameTooltip:AddDoubleLine(rep.factionName, _G["FACTION_STANDING_LABEL"..rep.standingId], nil, nil, nil, r, g, b);
        GameTooltip:AddLine(" ");
        GameTooltip:AddLine(rep.description, 1,1,1, true);
        GameTooltip:AddLine(" ");

        if not GameTooltip.progressBarPool then
            GameTooltip.progressBarPool = CreateFramePool("FRAME", GameTooltip, "TooltipProgressBarTemplate");
        end

        GameTooltip_AddProgressBar(GameTooltip, RepTotals[rep.standingId - 1], rep.maxValue, rep.currentValue, string.format("%0.1f %%", (rep.currentValue / rep.maxValue) * 100))
        GameTooltip:Show();
    end)

end