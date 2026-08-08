

local name, addon = ...;

local Util = addon.Util;




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

    Util.ApplyAtlas(self.Backplate, "spellbookelements", "spellbook-item-backplate")
    Util.ApplyAtlas(self.Button.Border, "spellbookelements", "spellbook-item-iconframe")
    Util.ApplyAtlas(self.Button.IconHighlight, "interface/talentframe/talents", "talents-node-square-greenglow")

    addon.CallbackRegistry:RegisterCallback(addon.Callbacks.SpellbookClickToCast_OnToggle, self.SpellbookClickToCast_OnToggle, self)

    self.Button:SetScript("OnMouseDown", function(_, hwButtonPressed)
        if (self.captureEnabled == false) and self.spell and IsShiftKeyDown() then
            PickupSpell(self.spell:GetSpellID());
        end
    end)
    
    self.Button:SetScript("OnLeave", function(_, hwButtonPressed)
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

    self.Button:SetScript("OnEnter", function(_, hwButtonPressed)
        if self.captureEnabled then
            --if FancyPanelsCliqueKeyGrabber:IsShown() == false then
                FancyPanelsCliqueKeyGrabber:SetID(self:GetID());
                FancyPanelsCliqueKeyGrabber:ClearAllPoints();
                FancyPanelsCliqueKeyGrabber:SetParent(self.Button);
                FancyPanelsCliqueKeyGrabber:SetPoint("CENTER", self.Button, "CENTER", 0, 0);
                FancyPanelsCliqueKeyGrabber:SetSize(40, 40)
                
                Clique_RegisterQuickbindButtonScripts(FancyPanelsCliqueKeyGrabber);

                FancyPanelsCliqueKeyGrabber:Show();

                self:OnEnter();
                --print("Setup CaptureButton");
            --end
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












FancyPanelsSpecPanelMixin = {}
function FancyPanelsSpecPanelMixin:SetSpec(info)
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