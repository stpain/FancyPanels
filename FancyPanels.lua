--[[

    © 2026 Sam Pain. All Rights Reserved.

    No part of this work may be reproduced 
    without the prior written permission 
    of the author.

]]



--[[
    spec tab is to show info about the class specs
    talent tab is character talents live view
    template tab is to view edit any talent tree/class

        --if blizzard updates the API
    --https://warcraft.wiki.gg/wiki/API_C_SpellBook.GetSpellBookItemInfo
    
    --current API
    --https://warcraft.wiki.gg/wiki/API_GetSpellBookItemInfo

    -- local spellFunc = {
    --     SPELL = GetSpellInfo,
    --     FUTURESPELL = GetSpellInfo,
    --     FLYOUT = GetFlyoutInfo,
    -- }
]]

local addonName, addon = ...;

local Util = addon.Util;
local SavedVars = addon.SavedVars;

local L = addon.Constants.Locales[GetLocale()]

local TALENT_BUTTONS = {};

local NUM_SPECIALIZATIONS = 3;

local NUM_TALENT_ROWS = 7;
if WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
    NUM_TALENT_ROWS = 9;
end
if WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then
    NUM_TALENT_ROWS = 11;
end


FancyPanelsMixin = {}

function FancyPanelsMixin:OnLoad()

    FancyPanelsPortrait:SetAtlas("newplayerchat-chaticon-newcomer");

    C_AddOns.LoadAddOn("Blizzard_TalentUI");
    ShowUIPanel(PlayerTalentFrame);
    HideUIPanel(PlayerTalentFrame);

    self:RegisterForDrag("LeftButton");

    self:RegisterEvent("PREVIEW_TALENT_POINTS_CHANGED");
    self:RegisterEvent("PREVIEW_PET_TALENT_POINTS_CHANGED");
    self:RegisterEvent("PLAYER_TALENT_UPDATE");
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
    self:RegisterEvent("CONFIRM_TALENT_WIPE");
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("PLAYER_LEVEL_UP");
    self:RegisterEvent("SPELLS_CHANGED");
    self:RegisterEvent("CHARACTER_POINTS_CHANGED");
    self:RegisterEvent("EQUIPMENT_SWAP_FINISHED");

    self:RegisterEvent("UNIT_HEALTH");
    self:RegisterEvent("UNIT_MAXHEALTH");
    self:RegisterEvent("UNIT_POWER_UPDATE");
   
    --NineSliceUtil.ApplyLayout(self, addon.Constants.NineSliceLayouts.ParentBorder)
    --NineSliceUtil.ApplyLayout(self.talentTreesParent.petTalentParent, addon.Constants.NineSliceLayouts.ParentBorder)

    self.specializationsParent.background:SetTexture("Interface/AddOns/FancyPanels/Media/Talents/Specialization.png");

    local atlasInfo = addon.Constants.Atlas["interface/talentframe/specialization"]["spec-background"];
    self.specializationsParent.background:SetTexCoord(atlasInfo[3],atlasInfo[4],atlasInfo[5],atlasInfo[6]);


    --[[
        Set the main parent UI tabs
    ]]
    self.tab1:SetText(SPECIALIZATION);
    self.tab2:SetText(TALENTS);
    self.tab3:SetText(SPELLBOOK);
    self.tab4:SetText(CHARACTER);
    self.tab5:SetText(NEW);
    
    PanelTemplates_SetNumTabs(self, #self.tabs);
    PanelTemplates_SetTab(self, 1);

    for _, tab in ipairs(self.tabs) do
        tab:SetScript("OnClick", function()
            self:SetView(tab:GetID());
        end)
    end


    --[[
        Set the spellbook top tabs
    ]]
    for i = 1, 6 do
        local tab = self.spellbook["tab"..i];
        tab:SetScript("OnClick", function()
            self:SpellbookTab_OnSelected(i);
        end)
    end

    --[[
        Create the spellbook spell item frame pool
    ]]
    local function SpellButton_ResetFunc(pool, f)
        f:ClearSpell();
        f:ClearAllPoints();
    end
    self.spellButtonPool = CreateFramePool("Button", self.spellbook, "FancyPanelsSpellbookSpellItem", SpellButton_ResetFunc);


    --[[
        Clique input grabber button
    ]]
    local captureButton = CreateFrame("Button", "FancyPanelsCliqueKeyGrabber", UIParent);
    captureButton:RegisterForClicks("AnyDown");
    captureButton:EnableMouseWheel(true);
    captureButton:EnableMouse(true);
    captureButton:SetPoint("TOPLEFT");
    captureButton:SetScript("OnLeave", function(button)
        Clique_UnregisterQuickbindButtonScripts(button)
        FancyPanelsCliqueKeyGrabber:SetID(0);
        FancyPanelsCliqueKeyGrabber:ClearAllPoints();
        FancyPanelsCliqueKeyGrabber:SetParent(UIParent);
        FancyPanelsCliqueKeyGrabber:SetPoint("TOPLEFT");
        FancyPanelsCliqueKeyGrabber:SetSize(1,1);
        FancyPanelsCliqueKeyGrabber:Hide();
    end)

    self.spellbook.toggleClickToCast:SetScript("OnClick", function(checkButton)
        addon.CallbackRegistry:TriggerEvent(addon.Callbacks.SpellbookClickToCast_OnToggle, checkButton:GetChecked());
    end)


    --[[
        Set the character top tab
    ]]
    local characterTabs = {"Stats", "Equipment", SKILLS, REPUTATION}
    for i = 1, 4 do
        self.character.tabContainer["tab"..i].Text:SetText(characterTabs[i])
        self.character.tabContainer["tab"..i]:SetScript("OnClick", function()
            self:CharacterTab_OnSelected(i);
        end)
    end


    --force talent preview enabled
    --SetCVar("previewTalentsOption", true)


    --[[
        The UI was built while playing in TBC and so used TBC sized trees as a basis
        for era we want to adjust the positions so they look a little more centrally placed
    ]]
    if (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) then

        self.talentTreesParent.talentTab1:ClearAllPoints();
        self.talentTreesParent.talentTab1:SetPoint("TOPLEFT", 65, -100);
        self.talentTreesParent.talentTab1:SetPoint("BOTTOMLEFT", 65, 100);

        local width = 260;
        self.talentTreesParent.talentTab1:SetWidth(width);
        self.talentTreesParent.talentTab2:SetWidth(width);
        self.talentTreesParent.talentTab3:SetWidth(width);
    end


    --init the talent trees, the template they inherit allows them to be modified 
    for k, v in ipairs({"talentTab1", "talentTab2", "talentTab3"}) do

        self.talentTreesParent[v]:InitFramePool("Button", "FancyPanelsTalentIconTemplate")
        self.talentTreesParent[v]:SetFixedColumnCount(4)
        self.talentTreesParent[v].ScrollBar:Hide()
        self.talentTreesParent[v].ScrollBar:HookScript("OnShow", function(sb)
            sb:Hide()
        end)

        for row = 1, NUM_TALENT_ROWS do
            for col = 1, 4 do
                self.talentTreesParent[v]:Insert({
                    rowId = row,
                    colId = col,
                })
            end
        end

        self:IterTalentTreeFrames(k, function(f)
            local row, col = f.rowId, f.colId;
            if not TALENT_BUTTONS[k] then
                TALENT_BUTTONS[k] = {}
            end
            if not TALENT_BUTTONS[k][row] then
                TALENT_BUTTONS[k][row] = {}
            end
            TALENT_BUTTONS[k][row][col] = f;
        end)
    end

    self:SetScripts_TalentTrees();
    self:SetScripts_Character();


    --[[
        News
    ]]
    -- local version = C_AddOns.GetAddOnMetadata(addonName, "Version");
    -- local log = addon.changeLog[version];
    -- if log then
        local text = "";
        for _, entry in ipairs(addon.changeLog) do
            local versionText = string.format("|cffffffff[version %s]|r", entry.version)
            if (text == "") then
                text = versionText;
            else
                text = string.format("%s\n\n%s", text, versionText);
            end

            for _, change in ipairs(entry.log) do
                text = string.format("%s\n    %s", text, change);
            end
        end
        self.news.changeLog:SetText(text);
    --end

    self.news.nuke:SetScript("OnClick", function()
        SavedVars:Init(true);
    end)

    addon.CallbackRegistry:RegisterCallback(addon.Callbacks.CharacterEquipmentSet_OnDeleted, self.CharacterEquipmentSet_OnDeleted, self);
    addon.CallbackRegistry:RegisterCallback(addon.Callbacks.CharacterEquipmentSet_OnEdit, self.CharacterEquipmentSet_OnEdit, self);
end

function FancyPanelsMixin:SetView(tabID)
    for k, view in ipairs(self.views) do
        view:Hide()
    end
    self.views[tabID]:Show()
    PanelTemplates_SetTab(self, tabID);
end

function FancyPanelsMixin:OnEvent(event, ...)
    if self[event] then
        self[event](self, ...)
    end
end

function FancyPanelsMixin:OnShow()
    local isPreviewTalentsEnabled = C_CVar.GetCVar("previewTalentsOption");
    self.talentTreesParent.togglePreviewTalents:SetChecked(isPreviewTalentsEnabled)
    self:TogglePreviewTalentPoints(isPreviewTalentsEnabled);
end





--[[
    Events:
]]
function FancyPanelsMixin:PLAYER_LEVEL_UP(...)
    local level, healthDelta, powerDelta, numNewTalents, numNewPvpTalentSlots, strengthDelta, agilityDelta, staminaDelta, intellectDelta = ...;
end

function FancyPanelsMixin:CHARACTER_POINTS_CHANGED(...)
    local pointsChanged = ...;
    self:UpdateSpecializationInfo();
    self:UpdateTalentTrees();
end

function FancyPanelsMixin:PLAYER_ENTERING_WORLD(...)
    local isInitialLogin, isReload = ...;

    if isInitialLogin or isReload then

        SavedVars:Init();

        local _, class, classID = UnitClass("player");
        self:InitializeClass(classID);
        self:SpellbookTab_OnSelected(1);
        self:CharacterTab_OnSelected(1);
        self:CreateMinimapButton();

        self:Character_InitModel();
        self:Character_InitStats();
        self:Character_InitInvSlots();

        self:UpdateOutfitList();

    end
end

function FancyPanelsMixin:ACTIVE_TALENT_GROUP_CHANGED(...)
    self:UpdateSpecializationInfo();
    self:UpdateTalentTrees();
end

function FancyPanelsMixin:SPELLS_CHANGED()
    self:UpdateSpecializationInfo();
    self:LoadSpellsForTab(self.spellbook.selectedTab or 1);
end

function FancyPanelsMixin:PLAYER_TALENT_UPDATE(...)
    self:UpdateSpecializationInfo();
    self:UpdateTalentTrees();
end

function FancyPanelsMixin:PREVIEW_PET_TALENT_POINTS_CHANGED(...)
    -- local talentIndex, tabID, activeTalentGroup, delta = ...;
end

function FancyPanelsMixin:PREVIEW_TALENT_POINTS_CHANGED(...)
    
    local talentIndex, tabID, activeTalentGroup, delta = ...;

    local isInspect, isPet = false, false;
    --local specGroup = C_SpecializationInfo.GetActiveSpecGroup(isInspect, isPet)
    local id, name, description, icon, role, primaryStat, pointsSpent, background, previewPointsSpent, isUnlocked = C_SpecializationInfo.GetSpecializationInfo(tabID, isInspect, isPet, nil, nil, activeTalentGroup);

    local isPreviewTalentsEnabled = C_CVar.GetCVar("previewTalentsOption");
    if (isPreviewTalentsEnabled == true) or (isPreviewTalentsEnabled == "1") then
        self:SetTalentInfoText(string.format("%d Points Available", GetNumTalentPoints() - previewPointsSpent));
    else
        self:UpdateSpecializationInfo();
    end
    self:UpdateTalentTrees();
end

function FancyPanelsMixin:EQUIPMENT_SWAP_FINISHED(...)
    local result, setID = ...;
    self:UpdateCharacterModel();
end

local function GetUnitHealthFormatted(unit)
    local hp, maxHp = UnitHealth(unit), UnitHealthMax(unit);
    return string.format("%d / %d", hp, maxHp);
end
function FancyPanelsMixin:UNIT_HEALTH(...)
    local unit = ...;
    if unit ~= "player" then
        return;
    end
    self.character.tabContainer.stats.health:SetText(GetUnitHealthFormatted(unit));
end
function FancyPanelsMixin:UNIT_MAXHEALTH(...)
    local unit = ...;
    if unit ~= "player" then
        return;
    end
    self.character.tabContainer.stats.health:SetText(GetUnitHealthFormatted(unit));
end

local function UpdateUnitPower(unit, parentFrame)
    local powerTypeEnum, powerTypeToken, rgbX, rgbY, rgbZ = UnitPowerType(unit);
    local power, maxPower = UnitPower(unit), UnitPowerMax(unit, powerTypeEnum);
    parentFrame.power:SetText(string.format("%d / %d", power, maxPower));
    parentFrame.powerLabel:SetText(_G[powerTypeToken]);
    -- local rgb = GetPowerBarColor(powerTypeEnum);
    -- parentFrame.powerLabel:SetTextColor(rgb.r, rgb.g, rgb.b, 1);
end
function FancyPanelsMixin:UNIT_POWER_UPDATE(...)
    local unit, powerTypeString = ...;
    if unit ~= "player" then
        return;
    end
    UpdateUnitPower(unit, self.character.tabContainer.stats)
end









--[[
    Set scripts
]]
function FancyPanelsMixin:SetScripts_TalentTrees()

    local function SpecButton_OnEnter(button, spec)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
        GameTooltip:AddLine(TALENT_SPEC_PRIMARY);
        if ( TalentUIUtil.IsSpecActive(spec) ) then
            -- add text to indicate that this spec is active
            GameTooltip:AddLine(TALENT_ACTIVE_SPEC_STATUS, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
        else
            GameTooltip:AddLine(VOICE_CHAT_CHANNEL_INACTIVE_TOOLTIP_INSTRUCTIONS, 1,1,1);
        end
        GameTooltip:Show()
    end

    self.talentTreesParent.spec1:SetSizeRatio(44)
    self.talentTreesParent.spec1:SetScript("OnEnter", function(button)
        SpecButton_OnEnter(button, "spec1")
    end)
    self.talentTreesParent.spec1:SetScript("OnMouseDown", function()
        local activeTalentGroup = C_SpecializationInfo.GetActiveSpecGroup(false, false)
        if activeTalentGroup ~= 1 then
            C_SpecializationInfo.SetActiveSpecGroup(1)
        end
    end)
    self.talentTreesParent.spec2:SetSizeRatio(44)
    self.talentTreesParent.spec2:SetScript("OnEnter", function(button)
        SpecButton_OnEnter(button, "spec2")
    end)
    self.talentTreesParent.spec2:SetScript("OnMouseDown", function()
        local activeTalentGroup = C_SpecializationInfo.GetActiveSpecGroup(false, false)
        if activeTalentGroup ~= 2 then
            C_SpecializationInfo.SetActiveSpecGroup(2)
        end
    end)

    self.talentTreesParent.resetTalents:SetScript("OnEnter", function()
        -- GameTooltip:SetOwner(self.talentTreesParent.resetTalents, "ANCHOR_RIGHT");
        -- GameTooltip:SetText(TALENT_TOOLTIP_RESETTALENTGROUP);
    end)
    self.talentTreesParent.resetTalents:SetScript("OnClick", function()
        local isInspect, isPet = false, false;
        local talentGroup = C_SpecializationInfo.GetActiveSpecGroup(false, isPet);
        ResetGroupPreviewTalentPoints(isPet, talentGroup);
    end)

    self.talentTreesParent.learnTalents:SetScript("OnEnter", function()
        -- GameTooltip:SetOwner(self.talentTreesParent.learnTalents, "ANCHOR_RIGHT");
        -- GameTooltip:SetText(TALENT_TOOLTIP_LEARNTALENTGROUP);
    end)
    self.talentTreesParent.learnTalents:SetScript("OnClick", function()
        StaticPopup_Show("FANCY_PANELS_CONFIRM_LEARN_PREVIEW_TALENTS", nil, nil, { isPet = false, });
    end)

    self.talentTreesParent.togglePreviewTalents:SetScript("OnClick", function(cb)
        local isChecked = cb:GetChecked();
        self:TogglePreviewTalentPoints(isChecked, true)
    end)
end

function FancyPanelsMixin:SetScripts_Character()
    self.character.newOutfit.text:SetText(TRANSMOG_OUTFIT_NEW)
    self.character.newOutfit:SetScript("OnClick", function()

        local iconSelector = self.character.iconSelector;
        iconSelector.mode = IconSelectorPopupFrameModes.New;

        Util.PrepareIconPicker(iconSelector);

        iconSelector:ClearAllPoints();
        iconSelector:SetPoint("BOTTOM", self.character.newOutfit, "TOP", 0, 10);
        iconSelector:SetFrameLevel(self.character.model:GetFrameLevel() + 1);
        iconSelector:Show();
        iconSelector:Raise();

        iconSelector.BorderBox.OkayButton:SetScript("OnClick", function()
            local iconTexture = iconSelector.BorderBox.SelectedIconArea.SelectedIconButton:GetIconTexture();
	        local text = iconSelector.BorderBox.IconSelectorEditBox:GetText();

            --IconSelectorPopupFrameTemplateMixin.OkayButton_OnClick(self);
            iconSelector.BorderBox.IconSelectorEditBox:SetText("");
            iconSelector.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(nil);
            iconSelector:Hide();

            if (iconSelector.mode == IconSelectorPopupFrameModes.New) and (C_EquipmentSet.GetNumEquipmentSets() < MAX_EQUIPMENT_SETS_PER_PLAYER) then
                C_EquipmentSet.CreateEquipmentSet(text, iconTexture);
                self:UpdateOutfitList();
            end

        end)
    end)


    local function IsSelected(key)
        key = "characterModel."..key;
        return SavedVars:Get(key);
    end
    local function SetSelected(key)
        key = "characterModel."..key;
        local currentValue = SavedVars:Get(key);
        --print("currentValue", currentValue);
        SavedVars:Set(key, not currentValue);
        --print("newValue", not currentValue);

        --DevTools_Dump({SavedVars.db})
    end

    local characterModelOptions = {
        { key = "showItemLinks", text = "Show Item Links", },
        { key = "showItemQuality", text = "Show Item Quality Borders", },
        { key = "showItemEnchantments", text = "Show Item Enchantments", },
        --{ key = "suggestItemUpgrade", text = "Suggest Item Upgrades", tooltipText = "Shows a green upgrade arrow next to an item in the inventory slot context menu." },
    }

    local socketOptions = {
        { key = "showGemSockets", text = "Show Gem Sockets", },
        { 
            key = "confirmSocketChanges", 
            text = "Confirm Socket Changes.", 
            tooltipTitle = "Confirm Socket Changes", 
            tooltipText = "\nEnabled\n|cffffffffPromts you to confirm changes to gem sockets.|r\n\nDisabled\n|cffffffffGems will be socketed immediately, any existing gems will be destroyed.|r", 
        },
    }

    self.character.modelOptions:SetScript("OnClick", function(button)
        MenuUtil.CreateContextMenu(button, function(_, rootDescription)
            rootDescription:CreateTitle(OPTIONS);
            rootDescription:CreateDivider();

            for i, option in ipairs(characterModelOptions) do

                local checkbox = rootDescription:CreateCheckbox(option.text, IsSelected, SetSelected, option.key)

                if (option.tooltipTitle or option.tooltipText) then
                    checkbox:SetTooltip(function(_, tooltip)
                        if (option.tooltipTitle) then
                            GameTooltip:AddLine(option.tooltipTitle);
                        end
                        if (option.tooltipText) then
                            GameTooltip:AddLine(option.tooltipText, nil, nil, nil, true);
                        end
                        GameTooltip:Show();
                    end)
                end

            end

            if (WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC) then
                rootDescription:CreateDivider();
                rootDescription:CreateTitle("Gem Sockets");

                for j, option in ipairs(socketOptions) do
                    local checkbox = rootDescription:CreateCheckbox(option.text, IsSelected, SetSelected, option.key)
                    if (option.tooltipTitle or option.tooltipText) then
                        checkbox:SetTooltip(function(_, tooltip)
                            if (option.tooltipTitle) then
                                GameTooltip:AddLine(option.tooltipTitle);
                            end
                            if (option.tooltipText) then
                                GameTooltip:AddLine(option.tooltipText, nil, nil, nil, true);
                            end
                            GameTooltip:Show();
                        end)
                    end
                end
            end

        end)
    end)
end





--[[
    Helper Funcs:
]]
function FancyPanelsMixin:CreateMinimapButton()
    
    local ldb = LibStub("LibDataBroker-1.1")

    if not self.minimapButton then
        self.minimapButtonDataObject = ldb:NewDataObject('FancyPanelsMinimapButton', {
            type = "launcher",
            icon = 132222,
            OnClick = function(_, button)
                self:SetShown(not self:IsVisible())
            end,

        })
        self.minimapButton = LibStub("LibDBIcon-1.0")
        self.minimapButton:Register('FancyPanelsMinimapButton', self.minimapButtonDataObject, {})
    end

    _G['LibDBIcon10_FancyPanelsMinimapButton'].icon:SetAtlas("newplayerchat-chaticon-newcomer")

    _G['LibDBIcon10_FancyPanelsMinimapButton']:SetScript("OnEnter", function(s)
        GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
        GameTooltip_AddColoredLine(GameTooltip, addonName, BLUE_FONT_COLOR);
        GameTooltip:Show()
    end)
    _G['LibDBIcon10_FancyPanelsMinimapButton']:SetScript("OnLeave", function(s)
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end)

end

function FancyPanelsMixin:TogglePreviewTalentPoints(enabled, setCvar)

    --C_CVar.SetCVar("previewTalentsOption", enabled);
    if (setCvar == true) then
        SetCVar("previewTalentsOption", enabled)
    end

    self.talentTreesParent.learnTalents:SetShown(enabled);
    self.talentTreesParent.resetTalents:SetShown(enabled);

    self.talentTreesParent.spec1:ClearAllPoints();

    if (enabled == true) or (enabled == "1") then
        self.talentTreesParent.spec1:SetPoint("BOTTOMRIGHT", -255, 10);
    else
        self.talentTreesParent.spec1:SetPoint("BOTTOMRIGHT", -90, 10);
    end

end

function FancyPanelsMixin:SetTalentInfoText(text, fadeDelay)
    self.talentTreesParent.importInfoFadeOut:Stop()
    self.talentTreesParent.importInfo:SetAlpha(1.0)
    self.talentTreesParent.importInfo:SetText(text)
    if type(fadeDelay) == "number" then
        self.talentTreesParent.importInfoFadeOut.alpha:SetStartDelay(fadeDelay)
        self.talentTreesParent.importInfoFadeOut:Play()
    end
end

function FancyPanelsMixin:IterAllTalentFrames(func)
    for k, v in ipairs({"talentTab1", "talentTab2", "talentTab3"}) do
        for _, frame in ipairs(self.talentTreesParent[v]:GetFrames()) do
            func(frame)
        end
    end
end

function FancyPanelsMixin:FindTalentFromAddress(tabID, row, col)
    for _, frame in ipairs(self.talentTreesParent["talentTab"..tabID]:GetFrames()) do
        if frame.rowId == row and frame.colId == col then
            return frame;
        end
    end
end

function FancyPanelsMixin:IterTalentTreeFrames(tabID, func)
    for _, frame in ipairs(self.talentTreesParent["talentTab"..tabID]:GetFrames()) do
        func(frame)
    end
end





--[[
    UI Funcs:
]]
function FancyPanelsMixin:InitializeClass(classID)

    local activeSpecGroup = C_SpecializationInfo.GetActiveSpecGroup(false, false);

    self.classSpecInfo = Util.GetClassData(classID);

    local specPanel = self.specializationsParent;

    local tree, points = 0, 0;

    for i = 1, NUM_SPECIALIZATIONS do
        specPanel.specs[i]:SetWidth(specPanel:GetWidth() / NUM_SPECIALIZATIONS)
        specPanel.specs[i]:SetSpec(self.classSpecInfo[i])

        local role1, role2 = Util.GetTabRole(classID, i);
        specPanel.specs[i]:SetRole(role1, role2)

        if i > 1 then
            specPanel.specs[i]:ShowDivider()
        end

        local id, name, description, icon, role, primaryStat, pointsSpent, background, previewPointsSpent, isUnlocked = C_SpecializationInfo.GetSpecializationInfo(i, false, false, nil, nil, activeSpecGroup);
        if pointsSpent > points then
            points = pointsSpent
            tree = i
        end
        
        local headerText = string.format("%s |cffFFD200%d", name, pointsSpent);
        self.talentTreesParent["talentTab"..i].header:SetText(headerText);

        --hide any selected artwork/highlighting
        specPanel.specs[i]:SetSelected()
    end

    if (points > 0) then
        specPanel.specs[tree]:SetSelected(true)
        local spec = self.classSpecInfo[tree];
        self.talentTreesParent.background:SetTexture(spec.backgroundFilePath)
        self.talentTreesParent.background:SetTexCoord(spec.backgroundAtlas[1], spec.backgroundAtlas[2], spec.backgroundAtlas[3], spec.backgroundAtlas[4])

    else
        local spec = self.classSpecInfo[1];
        self.talentTreesParent.background:SetTexture(spec.backgroundFilePath)
        self.talentTreesParent.background:SetTexCoord(spec.backgroundAtlas[1], spec.backgroundAtlas[2], spec.backgroundAtlas[3], spec.backgroundAtlas[4])

    end

    self:UpdateSpecializationInfo();
    self:UpdateTalentTrees();
end

function FancyPanelsMixin:UpdateSpecializationInfo()

    if not self.classSpecInfo then
        return;
    end

    -- updates spellbook tabs as the player might have learned new spells that open up new tabs
    for i = 1, 4 do
        local name = GetSpellTabInfo(i);
        if name then
            self.spellbook["tab"..i].Text:SetText(name)
            self.spellbook["tab"..i]:Show()
        end
    end

    local numPetSpells, petType = HasPetSpells();

    if numPetSpells and (numPetSpells > 0) then
        local classFileName = select(2, UnitClass("player"));
        if (classFileName == "HUNTER") or (classFileName == "WARLOCK") then
            self.spellbook.tab5:Show();
        end
    end

    --we're only getting class data for the player here
    local inspect, isPet = false, false;
    local playerLevel = UnitLevel("player");
    local activeSpecGroup = C_SpecializationInfo.GetActiveSpecGroup(false, false);

    local groupData = {
        [1] = {
            points = 0,
            totalPoints = 0,
            isActive = false,
            icon = 0,
            tree = 1,
        },
        [2] = {
            points = 0,
            totalPoints = 0,
            isActive = false,
            icon = 0,
            tree = 1,
        },
    };

    for specGroup = 1, 2 do
        if specGroup == activeSpecGroup then
            groupData[specGroup].isActive = true;
        end
        for i = 1, NUM_SPECIALIZATIONS do
            local id, name, description, icon, role, primaryStat, pointsSpent, background, previewPointsSpent, isUnlocked = C_SpecializationInfo.GetSpecializationInfo(i, inspect, isPet, nil, nil, specGroup);
            if pointsSpent > groupData[specGroup].points then
                groupData[specGroup].points = pointsSpent;
                groupData[specGroup].icon = icon;
                groupData[specGroup].tree = i;
            end
            groupData[specGroup].totalPoints = groupData[specGroup].totalPoints + pointsSpent;

            if (groupData[specGroup].isActive == true) then
                local headerText = string.format("%s |cffFFD200%d", name, pointsSpent);
                self.talentTreesParent["talentTab"..i].header:SetText(headerText);
            end
        end
    end

    --this clears old layoutInfo 
    for i = 1, NUM_SPECIALIZATIONS do
        self.specializationsParent.specs[i]:SetSelected()
    end

    if (groupData[activeSpecGroup].points > 0) then
        self.specializationsParent.specs[groupData[activeSpecGroup].tree]:SetSelected(true)
        local spec = self.classSpecInfo[groupData[activeSpecGroup].tree];
        self.talentTreesParent.background:SetTexture(spec.backgroundFilePath)
        self.talentTreesParent.background:SetTexCoord(spec.backgroundAtlas[1], spec.backgroundAtlas[2], spec.backgroundAtlas[3], spec.backgroundAtlas[4])
    end

    if (GetNumTalentGroups() == 2) then
        self.talentTreesParent.spec1:Show();
        self.talentTreesParent.spec2:Show();

        self.talentTreesParent.spec1.border:SetAtlas("charactercreate-ring-metallight")
        self.talentTreesParent.spec2.border:SetAtlas("charactercreate-ring-metallight")

        if ( TalentUIUtil.IsSpecActive("spec1") ) then
            FancyPanelsPortrait:SetTexture(groupData[1].icon);
            self.talentTreesParent.spec1.border:SetAtlas("charactercreate-ring-select")
        else
            FancyPanelsPortrait:SetTexture(groupData[2].icon);
            self.talentTreesParent.spec2.border:SetAtlas("charactercreate-ring-select")
        end

        self.talentTreesParent.spec1.icon:SetTexture(groupData[1].icon)
        self.talentTreesParent.spec2.icon:SetTexture(groupData[2].icon)
        

    else

        FancyPanelsPortrait:SetTexture(groupData[1].icon);
        self.talentTreesParent.spec1:Hide();
        self.talentTreesParent.spec2:Hide();

    end

    --DevTools_Dump({groupData})

    if (GetNumTalentPoints() - groupData[activeSpecGroup].totalPoints) > 0 then
        self:SetTalentInfoText(string.format("%d Points Available", GetNumTalentPoints() - groupData[activeSpecGroup].totalPoints))
    else
        if GetNextTalentLevel() then
            self:SetTalentInfoText(NEXT_TALENT_LEVEL:format(GetNextTalentLevel()))
        end
    end


end

function FancyPanelsMixin:UpdateTalentTrees()

    local activeSpecGroup = C_SpecializationInfo.GetActiveSpecGroup(false, false);

    self:IterAllTalentFrames(function(f) f:Hide() end)

    for tab = 1, 3 do

        --rip data from the blizz Ui
        PanelTemplates_SetTab(PlayerTalentFrame, tab)
        local talentButtons = {PlayerTalentFrameScrollChildFrame:GetChildren()}
        for _, frame in ipairs(talentButtons) do
            local talentInfoQuery = {};
            local talentIndex = frame:GetID();
            talentInfoQuery.specializationIndex = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
            talentInfoQuery.talentIndex = talentIndex;
            talentInfoQuery.isInspect = false;
            talentInfoQuery.isPet = false;
            talentInfoQuery.groupIndex = activeSpecGroup; -- PlayerTalentFrame.talentGroup;
            local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery);

            if talentInfo then
                TALENT_BUTTONS[tab][talentInfo.tier][talentInfo.column]:SetTalent(talentInfo, talentIndex, tab);
            end

        end
    end

    for tabID = 1, 3 do
        self:IterTalentTreeFrames(tabID, function(f)

            if f.tabIndex and f.talentIndex then
                local tier, column, isLearnable = GetTalentPrereqs(f.tabIndex, f.talentIndex, false, false, activeSpecGroup)

                if tier and column then
                    local talent = self:FindTalentFromAddress(tabID, tier, column)

                    if talent.talentInfo.rank == talent.talentInfo.maxRank then
                        f.line:SetColorTexture(0.9,0.8,0.0)
                    else
                        f.line:SetColorTexture(0.5,0.5,0.5)
                    end

                    f.line:SetStartPoint("CENTER", f);
                    f.line:SetEndPoint("CENTER", talent);
                    f.line:Show()

                end

            end
        end)
    end
end

function FancyPanelsMixin:LoadPetSpells(pageIndex)

    self.spellbook.selectedTab = 5;

    local numPetSpells, petType = HasPetSpells();

    self.spellbook.tabHeader.Text:SetText(_G[petType]);

    self.spellbook.nextPage:SetScript("OnClick", nil);
    self.spellbook.previousPage:SetScript("OnClick", nil);

    if not pageIndex then
        pageIndex = 0;
    end

    local cvar = GetCVar("ShowAllSpellRanks");
    SetCVar("ShowAllSpellRanks", true);

    self.spellButtonPool:ReleaseAll();

    if (numPetSpells == nil) then
        return;
    end

    local maxSpellsPage1 = 18;
    local maxSpellsPage2 = 23;
    local offsetLeft, offsetTop = 33, -180;
    local lastButton;
    local buttons = {};
    local startIndex = pageIndex * (maxSpellsPage1 + maxSpellsPage2 - 1);
    --local _, _, offset, numSlots = GetSpellTabInfo(tabIndex)


    -- using a 0 index for pages as we use the pageIndex to calculate the startIndex for spells
    -- for page 1 we need to add 0 
    local numPages = math.floor(numPetSpells / (maxSpellsPage1 + maxSpellsPage2));

    self.spellbook.nextPage:SetScript("OnClick", function()
        pageIndex = pageIndex + 1;
        if pageIndex > numPages then
            pageIndex = numPages;
        end
        self:LoadPetSpells(pageIndex);
    end)

    self.spellbook.previousPage:SetScript("OnClick", function()
        pageIndex = pageIndex - 1;
        if pageIndex < 0 then
            pageIndex = 0;
        end
        self:LoadPetSpells(pageIndex)
    end)
    
    for i = (startIndex + 1), numPetSpells do

        local spellType, id = GetSpellBookItemInfo(i, BOOKTYPE_PET)
        local spellID = bit.band(0xFFFFFF, id)
        -- not sure what the non-spell IDs are
        --local spellName = spellID > 100 and GetSpellInfo(spellID) or GetSpellBookItemName(i, BOOKTYPE_PET)
        --local hasActionButton = C_ActionBar.HasPetActionButtons(id)
        --print(i, spellType, id, spellID, spellName, hasActionButton)


        local spellButton = self.spellButtonPool:Acquire();
        spellButton.captureEnabled = self.spellbook.toggleClickToCast:GetChecked();

        spellButton:SetID(spellID); --set the frameID as the spellID
        spellButton:InitSpell(); --update the frmes texts and icon
        spellButton:Show();

        table.insert(buttons, spellButton);

        if #buttons == 1 then
            spellButton:SetPoint("TOPLEFT", offsetLeft, offsetTop);
            lastButton = spellButton;

        elseif (#buttons == (maxSpellsPage1 + 1)) then
            spellButton:SetPoint("TOPLEFT", 670, offsetTop)
            lastButton = spellButton;

        elseif (#buttons == (maxSpellsPage1 + maxSpellsPage2)) then
            return;

        else
            if ((#buttons - 1) % 3) == 0 then
                lastButton = buttons[#buttons - 3];
                spellButton:SetPoint("TOP", lastButton, "BOTTOM", 0, -1);
                lastButton = spellButton;

            else
                spellButton:SetPoint("LEFT", lastButton, "RIGHT", 1, 0);
                lastButton = spellButton;

            end
        end

    end

    SetCVar("ShowAllSpellRanks", cvar);
end

function FancyPanelsMixin:LoadSpellsForTab(tabIndex, pageIndex)

    if (tabIndex == 5) then
        self:LoadPetSpells();
        return;
    end

    if (tabIndex == 6) then
        return;
    end

    self.spellbook.selectedTab = tabIndex;

    local name = GetSpellTabInfo(tabIndex);
    self.spellbook.tabHeader.Text:SetText(name)

    self.spellbook.nextPage:SetScript("OnClick", nil);
    self.spellbook.previousPage:SetScript("OnClick", nil);

    if not pageIndex then
        pageIndex = 0;
    end

    local cvar = GetCVar("ShowAllSpellRanks");
    SetCVar("ShowAllSpellRanks", true);

    self.spellButtonPool:ReleaseAll();

    local maxSpellsPage1 = 18;
    local maxSpellsPage2 = 23;
    local offsetLeft, offsetTop = 33, -180;
    local lastButton;
    local buttons = {};
    local startIndex = pageIndex * (maxSpellsPage1 + maxSpellsPage2 - 1);
    local _, _, offset, numSlots = GetSpellTabInfo(tabIndex)


    -- using a 0 index for pages as we use the pageIndex to calculate the startIndex for spells
    -- for page 1 we need to add 0 
    local numPages = math.floor((offset + numSlots) / (maxSpellsPage1 + maxSpellsPage2));

    self.spellbook.nextPage:SetScript("OnClick", function()
        pageIndex = pageIndex + 1;
        if pageIndex > numPages then
            pageIndex = numPages;
        end
        self:LoadSpellsForTab(tabIndex, pageIndex);
    end)

    self.spellbook.previousPage:SetScript("OnClick", function()
        pageIndex = pageIndex - 1;
        if pageIndex < 0 then
            pageIndex = 0;
        end
        self:LoadSpellsForTab(tabIndex, pageIndex)
    end)

    for j = (offset + 1 + startIndex), (offset + numSlots) do

        local spellType, id = GetSpellBookItemInfo(j, BOOKTYPE_SPELL)
        
        --local spellName = spellFunc[spellType](id)
        --print(spellName, j)

        local spellButton = self.spellButtonPool:Acquire();
        spellButton.captureEnabled = self.spellbook.toggleClickToCast:GetChecked();

        spellButton:SetID(id); --set the frameID as the spellID
        spellButton:InitSpell(); --update the frmes texts and icon
        spellButton:Show();

        table.insert(buttons, spellButton)

        --print(j, (maxSpellsPage1 + maxSpellsPage2), #buttons, pageIndex)

        if #buttons == 1 then
            spellButton:SetPoint("TOPLEFT", offsetLeft, offsetTop);
            lastButton = spellButton;

        elseif (#buttons == (maxSpellsPage1 + 1)) then
            spellButton:SetPoint("TOPLEFT", 670, offsetTop)
            lastButton = spellButton;

        elseif (#buttons == (maxSpellsPage1 + maxSpellsPage2)) then
            return;

        else
            if ((#buttons - 1) % 3) == 0 then
                lastButton = buttons[#buttons - 3];
                spellButton:SetPoint("TOP", lastButton, "BOTTOM", 0, -1);
                lastButton = spellButton;

            else
                spellButton:SetPoint("LEFT", lastButton, "RIGHT", 1, 0);
                lastButton = spellButton;

            end
        end

    end

    SetCVar("ShowAllSpellRanks", cvar);
end

function FancyPanelsMixin:SpellbookTab_OnSelected(index)
    for i = 1, 5 do
        local tab = self.spellbook["tab"..i];
        tab:SetNormalAtlas("GarrLanding-TopTabUnselected")
        tab:SetHeight(30)
    end
    self.spellbook["tab"..index]:SetNormalAtlas("GarrLanding-TopTabSelected");
    self.spellbook["tab"..index]:SetHeight(36);
    self:LoadSpellsForTab(index)
end








local CharacterTabsMenu = {
    "Character_ShowStats",
    "Character_ShowEquipment",
    "Character_ShowSkills",
    "Character_ShowReputations",
}
function FancyPanelsMixin:CharacterTab_OnSelected(tabID)

    for _, frame in ipairs(self.character.tabContainer.views) do
        frame:Hide();
    end
    for _, button in ipairs(self.character.tabContainer.tabs) do
        button:SetNormalAtlas("GarrLanding-TopTabUnselected")
        button:SetHeight(30);
    end
    self.character.tabContainer["tab"..tabID]:SetNormalAtlas("GarrLanding-TopTabSelected");
    self.character.tabContainer["tab" .. tabID]:SetHeight(36);
    self[CharacterTabsMenu[tabID]](self)
end

function FancyPanelsMixin:UpdateCharacterModel()
    self.character.class:SetText(string.format("%s %d %s", LEVEL, UnitLevel("player"), UnitClass("player")));
    
    --[[
        There is a better way to do this
    ]]
    C_Timer.After(1, function()
        self.character.model:SetUnit("player");
    end)
end

function FancyPanelsMixin:Character_InitModel()

    self.character.name:SetText(RAID_CLASS_COLORS[select(2, UnitClass("player"))]:WrapTextInColorCode(UnitName("player")));
    self.character.class:SetText(string.format("%s %d %s", LEVEL, UnitLevel("player"), UnitClass("player")));
    self.character.model:SetUnit("player");

    self.character:RegisterEvent("UNIT_INVENTORY_CHANGED");
    self.character:RegisterEvent("UNIT_MODEL_CHANGED");
    self.character:SetScript("OnEvent", function()
        self.character.model:SetUnit("player");
    end)

    --local _, raceInfo = UnitRace("player");
    local _, classFile = UnitClass("player");

    self.character.model.background:SetAtlas(string.format("dressingroom-background-%s", classFile:lower()));
    --self.character.model.background:SetAtlas(string.format("transmog-background-race-%s", raceInfo:lower()));

    --FancyPanelCharacterInvSlotTemplate
end

function FancyPanelsMixin:Character_InitStats()

    self.character.tabContainer.stats.health:SetText(GetUnitHealthFormatted("player"));
    UpdateUnitPower("player", self.character.tabContainer.stats)

    local lastframe;
    for _, f in addon.PlayerStats.BaseStatsIter() do
        f:SetParent(self.character.tabContainer.stats.baseStats);
        if not lastframe then
            f:SetPoint("TOPLEFT");
            f:SetPoint("TOPRIGHT");
            lastframe = f;
        else
            f:SetPoint("TOPLEFT", lastframe, "BOTTOMLEFT");
            f:SetPoint("TOPRIGHT", lastframe, "BOTTOMRIGHT");
            lastframe = f;
        end
    end

    lastframe = nil;
    for _, f in addon.PlayerStats.MeleeStatsIter() do
        f:SetParent(self.character.tabContainer.stats.melee);
        if not lastframe then
            f:SetPoint("TOPLEFT");
            f:SetPoint("TOPRIGHT");
            lastframe = f;
        else
            f:SetPoint("TOPLEFT", lastframe, "BOTTOMLEFT");
            f:SetPoint("TOPRIGHT", lastframe, "BOTTOMRIGHT");
            lastframe = f;
        end
    end

    if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
        return;
    end

    lastframe = nil;
    for _, f in addon.PlayerStats.RangedStatsIter() do
        f:SetParent(self.character.tabContainer.stats.ranged);
        if not lastframe then
            f:SetPoint("TOPLEFT");
            f:SetPoint("TOPRIGHT");
            lastframe = f;
        else
            f:SetPoint("TOPLEFT", lastframe, "BOTTOMLEFT");
            f:SetPoint("TOPRIGHT", lastframe, "BOTTOMRIGHT");
            lastframe = f;
        end
    end

    lastframe = nil;
    for _, f in addon.PlayerStats.SpellStatsIter() do
        f:SetParent(self.character.tabContainer.stats.spell);
        if not lastframe then
            f:SetPoint("TOPLEFT");
            f:SetPoint("TOPRIGHT");
            lastframe = f;
        else
            f:SetPoint("TOPLEFT", lastframe, "BOTTOMLEFT");
            f:SetPoint("TOPRIGHT", lastframe, "BOTTOMRIGHT");
            lastframe = f;
        end
    end

    lastframe = nil;
    for _, f in addon.PlayerStats.DefenceStatsIter() do
        f:SetParent(self.character.tabContainer.stats.defence);
        if not lastframe then
            f:SetPoint("TOPLEFT");
            f:SetPoint("TOPRIGHT");
            lastframe = f;
        else
            f:SetPoint("TOPLEFT", lastframe, "BOTTOMLEFT");
            f:SetPoint("TOPRIGHT", lastframe, "BOTTOMRIGHT");
            lastframe = f;
        end
    end

    lastframe = nil;
    for _, f in addon.PlayerStats.ResistanceStatsIter() do
        f:SetParent(self.character.tabContainer.stats.resistance);
        if not lastframe then
            f:SetPoint("TOPLEFT");
            f:SetPoint("TOPRIGHT");
            lastframe = f;
        else
            f:SetPoint("TOPLEFT", lastframe, "BOTTOMLEFT");
            f:SetPoint("TOPRIGHT", lastframe, "BOTTOMRIGHT");
            lastframe = f;
        end
    end

end

function FancyPanelsMixin:Character_ShowStats()
    self.character.tabContainer.stats:Show();
end

local function ModelFunc(self)
    self:FreezeAnimation(0, 0, 0);
	local x, y, z = self:TransformCameraSpaceToModelSpace(CreateVector3D(0, 0, -0.25)):GetXYZ();
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
end

function FancyPanelsMixin:Character_ShowEquipment()

    self.character.tabContainer.equipment:Show();

    if 1 == 1 then
        return;
    end
    
    --get the model position data for item slot
    local modelSetup = addon.modelRaceOffsets.NightElf.INVTYPE_SHOULDER;

    -- model:SetUseTransmogSkin(true);
    -- model:SetUseTransmogChoices(false);

    --pick a random item
    local itemIDs = {
        30055,
        30055,
        21869,
        32575,
        32575,
        30127,
    }

    for k, model in ipairs(self.character.tabContainer.equipment.models) do
        ModelFunc(model);
        model:SetUnit("player");
        model:Undress();
        model:SetRotation(modelSetup.rotation);
        model:SetPosition(modelSetup.pos[1], modelSetup.pos[2], modelSetup.pos[3]);
        model:SetPortraitZoom(modelSetup.zoom);

        --model:TryOn(string.format("item:%d", 10001));
        model:TryOn(string.format("item:%d", itemIDs[k]));

        model:HookScript("OnEnter", function()
            GameTooltip:SetOwner(model, "ANCHOR_TOPRIGHT");
            GameTooltip:SetItemByID(itemIDs[k]);
            GameTooltip:Show();
        end)
    end

end

function FancyPanelsMixin:Character_ShowSkills()

end

function FancyPanelsMixin:Character_ShowReputations()

    local repPanel = self.character.tabContainer.reputations;
    local currentHeader = repPanel.headerLabel:GetText();

    local pad = 5;
    local spacing = 30;
    local view = CreateScrollBoxListGridView(4, pad, pad, pad, pad, spacing, spacing);

    local function RepInitializer(dial, data)
        dial:InitRep(data)
    end

    view:SetElementInitializer("FancyPanelsRepDialTemplate", RepInitializer)

    ScrollUtil.InitScrollBoxWithScrollBar(repPanel.scrollBox, repPanel.scrollBar, view);


    --[[
                    rep = {
                    factionID = factionID,
                    standingId = standingId,
                    currentValue = currentValue,
                    maxValue = barMaxValue,
                }
    ]]

    local function LoadReps(reps)
        local dataProvider = CreateDataProvider(reps);
        view:SetDataProvider(dataProvider, false);
    end

    repPanel.headerDropDown:SetScript("OnClick", function(button)
        local reps = Util.GetAllCurrentReputations();

        if (reps) then
            MenuUtil.CreateContextMenu(button, function(_, root)
                
                for header, data in pairs(reps) do
                    root:CreateButton(header, function()
                        LoadReps(data);
                        repPanel.headerLabel:SetText(header);
                    end)
                end
            end)
        end
    end)

    if currentHeader ~= "" then
        local reps = Util.GetAllCurrentReputations();
        if reps[currentHeader] then
            LoadReps(reps[currentHeader])
        end
    end

    self.character.tabContainer.reputations:Show();
end


function FancyPanelsMixin:CharacterEquipmentSet_OnDeleted()
    self:UpdateOutfitList();
end


function FancyPanelsMixin:CharacterEquipmentSet_OnEdit(setID, setName, iconFileID)
    
    local iconSelector = self.character.iconSelector;
    iconSelector.mode = IconSelectorPopupFrameModes.Edit;

    Util.PrepareIconPicker(iconSelector);

    iconSelector.BorderBox.IconSelectorEditBox:SetText(setName);
    iconSelector.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(iconFileID);

    iconSelector:ClearAllPoints();
    iconSelector:SetPoint("TOPLEFT", self.character.outfitList, "TOPRIGHT", 10, 0);
    iconSelector:SetFrameLevel(self.character.model:GetFrameLevel() + 1);
    iconSelector:Show();
    iconSelector:Raise();

    iconSelector.BorderBox.OkayButton:SetScript("OnClick", function()
        local iconTexture = iconSelector.BorderBox.SelectedIconArea.SelectedIconButton:GetIconTexture();
        local text = iconSelector.BorderBox.IconSelectorEditBox:GetText();

        iconSelector.BorderBox.IconSelectorEditBox:SetText("");
        iconSelector.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(nil);
        iconSelector:Hide();

        if (iconSelector.mode == IconSelectorPopupFrameModes.Edit) then
            C_EquipmentSet.ModifyEquipmentSet(setID, text, iconTexture);
            self:UpdateOutfitList();
        end

    end)
end

function FancyPanelsMixin:UpdateOutfitList()
    local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs();
    local dp = CreateDataProvider(equipmentSetIDs);
    self.character.outfitList.scrollView:SetDataProvider(dp);
end

function FancyPanelsMixin:Character_InitInvSlots()


    --https://warcraft.wiki.gg/wiki/InventorySlotID
    local function InitInvSlotButton(button, equipLoc, invSlotInfo, tooltipAnchor)

        local invSlotId, textureName, checkRelic = GetInventorySlotInfo(invSlotInfo.slot);
        button.invSlotId = invSlotId;
        button.equipLoc = equipLoc;
        button.slotIcon = invSlotInfo.icon;

        button:SetID(invSlotId);

        --set icon on init
        button.itemLink = GetInventoryItemLink("player", button.invSlotId);
        button:UpdateVisuals();

        button:SetScript("OnEnter", function(b)
            if b.itemLink then
                GameTooltip:SetOwner(b, tooltipAnchor);
                GameTooltip:SetHyperlink(b.itemLink);
                GameTooltip:Show();
            end
        end)
    end


    --[[
        add slots here
    ]]
    local lastButton;
    for k, invSlot in ipairs(addon.Constants.InvSlotLayouts.Left) do

        local slotButton = CreateFrame("Button", nil, self.character.model, "FancyPanelCharacterInvSlotTemplate");
        slotButton:SetFrameLevel(self.character.model:GetFrameLevel() + 1);
        if (lastButton == nil) then
            slotButton:SetPoint("TOPLEFT", 24, -110);
        else
            slotButton:SetPoint("TOP", lastButton, "BOTTOM", 0, -17);
        end
        lastButton = slotButton;

        slotButton:SetAllign("left");

        local info = addon.Constants.InventorySlots[k]
        slotButton.backgroundIcon:SetTexture(info.icon);

        if (k == 5) then
            InitInvSlotButton(slotButton, {"INVTYPE_CHEST", "INVTYPE_ROBE"}, info, "TOPRIGHT");
        else
            InitInvSlotButton(slotButton, invSlot, info, "TOPRIGHT");
        end


    end
    lastButton = nil;
    for k, invSlot in ipairs(addon.Constants.InvSlotLayouts.Right) do

        local slotButton = CreateFrame("Button", nil, self.character.model, "FancyPanelCharacterInvSlotTemplate");
        slotButton:SetFrameLevel(self.character.model:GetFrameLevel() + 1);
        if (lastButton == nil) then
            slotButton:SetPoint("TOPRIGHT", -24, -110);
        else
            slotButton:SetPoint("TOP", lastButton, "BOTTOM", 0, -17);
        end
        lastButton = slotButton;

        slotButton:SetAllign("right");

        local info = addon.Constants.InventorySlots[k+8]
        slotButton.backgroundIcon:SetTexture(info.icon);

        InitInvSlotButton(slotButton, invSlot, info, "TOPLEFT");

    end

    local rangedSlot = CreateFrame("Button", nil, self.character.model, "FancyPanelCharacterInvSlotTemplate");
    rangedSlot:SetFrameLevel(self.character.model:GetFrameLevel() + 1);
    rangedSlot:SetPoint("BOTTOM", self.character.model, "BOTTOM", 0, 25);
    rangedSlot.backgroundIcon:SetTexture(addon.Constants.InventorySlots[19].icon);
    rangedSlot:SetAllign("right");

    InitInvSlotButton(
        rangedSlot,
        {
            "INVTYPE_RANGED",
            "INVTYPE_RANGEDRIGHT",
            "INVTYPE_RELIC",
        },
        addon.Constants.InventorySlots[19],
        "TOPLEFT"
    );

    local offHandSlot = CreateFrame("Button", nil, self.character.model, "FancyPanelCharacterInvSlotTemplate");
    offHandSlot:SetFrameLevel(self.character.model:GetFrameLevel() + 1);
    offHandSlot:SetPoint("BOTTOMLEFT", self.character.model, "BOTTOM", 9, 75);
    offHandSlot.backgroundIcon:SetTexture(addon.Constants.InventorySlots[18].icon);
    offHandSlot:SetAllign("left");

    InitInvSlotButton(
        offHandSlot,
        {
            "INVTYPE_WEAPONOFFHAND",
            "INVTYPE_WEAPON",
            "INVTYPE_SHIELD",
            "INVTYPE_HOLDABLE",
        },
        addon.Constants.InventorySlots[18],
        "TOPLEFT"
    );

    local mainHandSlot = CreateFrame("Button", nil, self.character.model, "FancyPanelCharacterInvSlotTemplate");
    mainHandSlot:SetFrameLevel(self.character.model:GetFrameLevel() + 1);
    mainHandSlot:SetPoint("BOTTOMRIGHT", self.character.model, "BOTTOM", -9, 75);
    mainHandSlot.backgroundIcon:SetTexture(addon.Constants.InventorySlots[17].icon);
    mainHandSlot:SetAllign("right");

    InitInvSlotButton(
        mainHandSlot,
        {
            "INVTYPE_WEAPONMAINHAND",
            "INVTYPE_WEAPON",
            "INVTYPE_2HWEAPON",
        },
        addon.Constants.InventorySlots[17],
        "TOPLEFT"
    );
    

    
    

    -- local relicSlot = CreateFrame("Button", nil, self.character.model, "FancyPanelCharacterInvSlotTemplate");
    -- relicSlot:SetFrameLevel(self.character.model:GetFrameLevel() + 1);
    -- relicSlot:SetPoint("LEFT", rangedSlot, "RIGHT", 12, 0);
    -- InitInvSlotButton(relicSlot, addon.Constants.InventorySlots[20].slot, "TOPLEFT");
    -- relicSlot.backgroundIcon:SetTexture(addon.Constants.InventorySlots[20].icon);

end





































































































---When the player clicks a talent we want to check if the player is actively recording talents, if so add this talent to the record
---@param name string talent name
---@param talent table talent data
function FancyPanelsMixin:Talent_OnMouseDown(name, talent)

    -- local tabIndex, talentIndex, maxRank = talent.tabIndex, talent.talentIndex, #talent.talentSpellIDs

    -- if self.talentRecord then
    --     local numAdded = 0;
    --     for k, v in ipairs(self.talentRecord) do
    --         if v.tabIndex == tabIndex and v.talentIndex == talentIndex then
    --             numAdded = numAdded + 1;
    --         end
    --     end
    --     if numAdded < maxRank then
    --         table.insert(self.talentRecord, {
    --             tabIndex = tabIndex,
    --             talentIndex = talentIndex,
    --         })

    --         self:UpdateTalentRecordText(string.format("Point %d - %s Rank %d", #self.talentRecord, name, numAdded + 1))
    --         --addon.CallbackRegistry:TriggerEvent(addon.Callbacks.Talent_OnTalentRecordTalentAdded, tabIndex, talentIndex, numAdded + 1, maxRank)

    --         --self:UpdateTalentTrees()
    --     end
    -- end
end


function FancyPanelsMixin:Talent_OnTalentRecordSelectionChanged(record)
    -- self.db.account.profiles[addon.thisCharacter].currentTalentRecording = record;
    -- self:OptionsPanel_OnTalentRecordSettingChanged()
end

--[[
    for a talent record to be applied the current talent point spending needs to be checked and
    match the talent record
    the important part is that the talents in the record upto the current point spent amount matches
]]
function FancyPanelsMixin:CheckTalentRecordCompatability(record, isPet)
    
    -- local numTalentPoints = GetNumTalentPoints()
    -- local activeTalentGroup = C_SpecializationInfo.GetActiveSpecGroup(false, isPet)
    -- local unspentPoints = GetUnspentTalentPoints(false, isPet, activeTalentGroup)
    -- local pointsMatch = true;
    -- local spentPoints = numTalentPoints - unspentPoints;
    -- --print(spentPoints)
    -- if spentPoints > 0 then

    --     local currentTalents = {}
    --     for i = 1, spentPoints do
    --         local talent = record.record[i]
    --         if talent then
    --             local name, iconTexture, row, col, rank, maxRank, isExceptional, available = GetTalentInfo(talent.tabIndex, talent.talentIndex, false, isPet)
    --             --print(name, rank)
    --             if not currentTalents[name] then
    --                 currentTalents[name] = {
    --                     actual = rank,
    --                     record = 1,
    --                 }
    --             else
    --                 currentTalents[name].record = currentTalents[name].record + 1;
    --             end
    --         end
    --     end

    --     --DevTools_Dump(currentTalents)

    --     --[[
    --         check if the current talent point spend matches the talent record
    --     ]]
    --     for k, v in pairs(currentTalents) do
    --         if v.actual ~= v.record then
    --             pointsMatch = false;
    --         end
    --     end
    -- end
    -- return pointsMatch, spentPoints, unspentPoints;
end


--[[
    this is quite the function, the idea is to test if a talent record can eb applied with the players current talent point spend
]]
function FancyPanelsMixin:OptionsPanel_OnTalentRecordSettingChanged()

    -- local record = self.db.account.profiles[addon.thisCharacter].currentTalentRecording;

    -- local panel = self.options;
    -- if panel.autoLearnTalentRecording.active:GetChecked() then

    --     if self.db.account.profiles[addon.thisCharacter].currentTalentRecording and self.db.account.profiles[addon.thisCharacter].currentTalentRecording.name then
            
    --         panel.autoLearnTalentRecording.recordingDropdown:SetText(record.name)

    --         local tabID = record.record[1].tabIndex

    --         --print(string.format("%s has %d talent points recorded", record.name, #record.record))

    --         local t = {}
    --         for k, talent in ipairs(record.record) do
    --             local name, iconTexture, row, col, rank, maxRank, isExceptional, available = GetTalentInfo(talent.tabIndex, talent.talentIndex)
    --             table.insert(t, {
    --                 label = string.format("%d %s", k, name),
    --                 icon = iconTexture,
    --             })
    --         end
    --         panel.autoLearnTalentRecording.recordListview.scrollView:SetDataProvider(CreateDataProvider(t))

    --         local pointsMatch, spentPoints, unspentPoints = self:CheckTalentRecordCompatability(record, false)


    --         --[[

    --             possible scenario

    --             player has unspent points and record is a match > show popup and spend points
    --             player has unspent points and record is not a match > provide info and disable
    --             player has unspent points and record has less points recorded > provide info

    --             player has no available points and record is not a match > inform not match
    --             player has no available points and record is a match > show next talent info

    --         ]]


    --         if (unspentPoints > 0) then
                
    --             if pointsMatch then

    --                 if (spentPoints < #record.record) then
    --                     local nextTalent = record.record[spentPoints + 1]
    --                     local nextTalentName, iconTexture, row, col, rank, maxRank, isExceptional, available = GetTalentInfo(nextTalent.tabIndex, nextTalent.talentIndex)
    --                     panel.autoLearnTalentRecording.active.label:SetText(string.format("%s is active, next talent %s", record.name, nextTalentName))

    --                     StaticPopup_Show("FancyPanelsConfirmTalentRecordTalentSpendDialog", "You have unspent talent points, would you like to apply the selected talent record?", nil, {
    --                     accept = function()
    --                         self:Specialization_OnSelected(self.classSpecInfo[tabID])
    --                         self:SetView(2)
    --                         for i = spentPoints + 1, unspentPoints do
    --                             local talent = record.record[i]
    --                             if talent then
    --                                 local name, iconTexture, row, col, rank, maxRank, isExceptional, available = GetTalentInfo(talent.tabIndex, talent.talentIndex)
    --                                 AddPreviewTalentPoints(talent.tabIndex, talent.talentIndex, 1, false, activeTalentGroup);
    --                             end
    --                         end
    --                     end,
    --                     alt = function()
    --                         -- local numTalentToLearn = (#record.record - spentPoints)
    --                         -- local iter = spentPoints + 1

    --                         -- print(string.format("Learning %d talents, starting at %d", numTalentToLearn, spentPoints+1))

    --                         -- C_Timer.NewTicker(0.5, function()
    --                         --     local talent = record.record[iter]
    --                         --     if talent then
    --                         --         local name, iconTexture, row, col, rank, maxRank, isExceptional, available = GetTalentInfo(talent.tabIndex, talent.talentIndex)
    --                         --         print(name)
    --                         --         LearnTalent(talent.tabIndex, talent.talentIndex, false, activeTalentGroup);
    --                         --     end
    --                         --     iter = iter + 1;
    --                         -- end, numTalentToLearn)
    --                         -- self:SetView(2)

    --                         self:Specialization_OnSelected(self.classSpecInfo[tabID])
    --                         self:SetView(2)

    --                         --bit of a cheat but just apply the preview then confirm 
    --                         for i = spentPoints + 1, unspentPoints do
    --                             local talent = record.record[i]
    --                             if talent then
    --                                 --local name, iconTexture, row, col, rank, maxRank, isExceptional, available = GetTalentInfo(talent.tabIndex, talent.talentIndex)
    --                                 AddPreviewTalentPoints(talent.tabIndex, talent.talentIndex, 1, false, activeTalentGroup);
    --                             end
    --                         end
    --                         C_Timer.After(0.1, function()
    --                             PlayerTalentFrameLearnButton_OnClick()
    --                             StaticPopup1Button1:Click()
    --                             --print("remove this comment and learn talents")
    --                         end)
    --                     end,
    --                     cancel = function()
    --                         panel.autoLearnTalentRecording.active:SetChecked(false)
    --                         self.db.account.profiles[addon.thisCharacter].hasActiveTalentRecording = false
    --                         panel.autoLearnTalentRecording.active.label:SetText(ADDON_DISABLED)
    --                     end,
    --                     })
    --                 else
    --                     panel.autoLearnTalentRecording.active.label:SetText("All talent record points have been spent!")
    --                 end
    --             else
    --                 panel.autoLearnTalentRecording.active.label:SetText(string.format("Unable to apply talent record %d, point spend doesn't match.", record.name))
    --             end
    --         else

    --             if pointsMatch then
    --                 local nextTalent = record.record[spentPoints + 1]
    --                 local nextTalentName, iconTexture, row, col, rank, maxRank, isExceptional, available = GetTalentInfo(nextTalent.tabIndex, nextTalent.talentIndex)
    --                 panel.autoLearnTalentRecording.active.label:SetText(string.format("%s is active, %s, next talent is %s", record.name, NEXT_TALENT_LEVEL:format(GetNextTalentLevel()), nextTalentName))
    --             else
    --                 panel.autoLearnTalentRecording.active.label:SetText(string.format("Unable to apply talent record %s, point spend doesn't match.", record.name))
    --             end
    --         end

    --     else
    --         panel.autoLearnTalentRecording.active.label:SetText("No talent record active, select from the drop down")
    --     end
    -- else
    --     panel.autoLearnTalentRecording.active.label:SetText("")
    -- end
end



function FancyPanelsMixin:SetupTalentRecorder()

    if 1 == 1 then
        return;
    end
    
    local panel = self.talentTreesParent.talentRecorderParent;

    for k, button in ipairs(panel.controls) do
        button:SetScript("OnLeave", function()
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        end)
    end

    panel.record:RegisterForClicks("AnyDown")
    panel.restart:RegisterForClicks("AnyDown")

    panel.record:SetScript("OnEnter", function(s)
        GameTooltip:SetOwner(s, "ANCHOR_RIGHT");
        GameTooltip:SetText(L.TALENT_RECORDER_START)
        GameTooltip:Show()
    end)
    panel.record:SetScript("OnClick", function()
        addon.CallbackRegistry:TriggerEvent(addon.Callbacks.Talent_OnTalentRecording, true)
        self.talentRecord = {}
        self.talentRecordPrimaryTreeIndex = self.talentTreesParent.primaryTree.treeIndex;
        self:UpdateTalentRecordText("Recording...")

        panel.recordingAnim:Play()
        self.talentTreesParent.learnTalents:Disable()
        PlayerTalentFrameLearnButton:Disable()
        FancyPanelsFrameLearnButtonTutorialText:SetText(L.RECORD_TALENTS_HELPTIP)
    end)

    panel.restart:SetScript("OnEnter", function(s)
        GameTooltip:SetOwner(s, "ANCHOR_RIGHT");
        GameTooltip:SetText(L.TALENT_RECORDER_RESTART)
        GameTooltip:Show()
    end)
    panel.restart:SetScript("OnClick", function()
        self.talentRecord = {}
        self.talentRecordPrimaryTreeIndex = self.talentTreesParent.primaryTree.treeIndex;
        self:UpdateTalentRecordText("Record reset")

        self.talentTreesParent.learnTalents:Disable()
        PlayerTalentFrameLearnButton:Disable()
        FancyPanelsFrameLearnButtonTutorialText:SetText(L.RECORD_TALENTS_HELPTIP)
    end)

    panel.confirm:SetScript("OnEnter", function(s)
        GameTooltip:SetOwner(s, "ANCHOR_RIGHT");
        GameTooltip:SetText(L.TALENT_RECORDER_CONFIRM)
        GameTooltip:Show()
    end)
    panel.confirm:SetScript("OnClick", function()
        StaticPopup_Show("FancyPanelsSaveLoadoutDialog", "Name", nil, {
            callback = function(n)
                local _, _, class = UnitClass("player")
                local isPet = self.talentTreesParent.petTalentParent:IsVisible() and true or false
                table.insert(self.db.account.talentRecordings, {
                    name = n,
                    class = class,
                    record = self.talentRecord,
                    isPet = isPet,
                    primaryTree = self.talentRecordPrimaryTreeIndex or 1;
                })
                addon.CallbackRegistry:TriggerEvent(addon.Callbacks.Talent_OnTalentRecording, false)
                self:IterAllTalentFrames(function(f)
                    f.Update(f)
                end)
                panel.recordingAnim:Stop()
                panel:Hide()
                self.talentRecord = nil
                self.talentTreesParent.learnTalents:Enable()
                PlayerTalentFrameLearnButton:Enable()
                FancyPanelsFrameLearnButtonTutorialText:SetText(TALENT_TREE_PREVIEW_TUTORIAL)
                PlayerTalentFrameResetButton_OnClick()
                self:UpdateSpecializationTab()
                self:UpdateTalentTrees()
                self:UpdatePetTalentTree()
            end
        })
    end)

    panel.cancel:SetScript("OnEnter", function(s)
        GameTooltip:SetOwner(s, "ANCHOR_RIGHT");
        GameTooltip:SetText(L.TALENT_RECORDER_CANCEL)
        GameTooltip:Show()
    end)
    panel.cancel:SetScript("OnClick", function()
        addon.CallbackRegistry:TriggerEvent(addon.Callbacks.Talent_OnTalentRecording, false)
        self:IterAllTalentFrames(function(f)
            f.Update(f)
        end)
        panel.recordingAnim:Stop()
        panel:Hide()
        self.talentTreesParent.learnTalents:Enable()
        PlayerTalentFrameLearnButton:Enable()
        FancyPanelsFrameLearnButtonTutorialText:SetText(TALENT_TREE_PREVIEW_TUTORIAL)
        self:UpdateTalentTrees()
    end)
end

function FancyPanelsMixin:UpdateTalentRecordText(text)
    self.talentTreesParent.talentRecorderParent.text:SetText(text)
end



function FancyPanelsMixin:ToggleHunterPetTalents(showPet)
    
    -- if showPet then
    --     self.talentTreesParent.primaryTree:Hide()
    --     self.talentTreesParent.secondaryTree1:Hide()
    --     self.talentTreesParent.secondaryTree2:Hide()
    --     self.talentTreesParent.helptip:Hide()

    --     self.talentTreesParent.petTalentParent:Show()


    --     PlayerTalentFrameTab2:Click()

    -- else
    --     self.talentTreesParent.primaryTree:Show()
    --     self.talentTreesParent.secondaryTree1:Show()
    --     self.talentTreesParent.secondaryTree2:Show()
    --     self.talentTreesParent.helptip:Show()

    --     self.talentTreesParent.petTalentParent:Hide()

    --     PlayerTalentFrameTab1:Click()

    -- end
end


function FancyPanelsMixin:ApplyNextTalentRecording()
    
end




function FancyPanelsMixin:Init()


    -- local _, class = UnitClass("player")
    -- if class == "HUNTER" then
    --     self.talentTreesParent.petSpec:SetSizeRatio(36)
    --     self.talentTreesParent.playerSpec:SetSizeRatio(36)
    --     SetPortraitTexture(self.talentTreesParent.petSpec.icon, "pet")
    --     SetPortraitTexture(self.talentTreesParent.playerSpec.icon, "player")

    --     self.talentTreesParent.petSpec:SetScript("OnMouseDown", function()
    --         self:ToggleHunterPetTalents(true)
    --     end)
    --     self.talentTreesParent.playerSpec:SetScript("OnMouseDown", function()
    --         self:ToggleHunterPetTalents()
    --     end)

    --     self.talentTreesParent.petTalentParent.talentTree:SetWidth(300)
    --     self.talentTreesParent.petTalentParent.talentTree:InitFramePool("Frame", "FancyPanelsTalentIconTemplate")
    --     self.talentTreesParent.petTalentParent.talentTree:SetFixedColumnCount(4)
    --     self.talentTreesParent.petTalentParent.talentTree.ScrollBar:Hide()
    --     self.talentTreesParent.petTalentParent.talentTree.ScrollBar:HookScript("OnShow", function()
    --         self.talentTreesParent.petTalentParent.talentTree.ScrollBar:Hide()
    --     end)

    --     C_Timer.After(0.1, function()
    --         for row = 1, 7 do
    --             for col = 1, 4 do
    --                 self.talentTreesParent.petTalentParent.talentTree:Insert({
    --                     rowId = row,
    --                     colId = col,
    --                 })
    --             end
    --         end
    --     end)

    --     self.talentTreesParent.petTalentParent:SetScript("OnShow", function()
    --         self:BuildPetTalentTree()
    --         self.talentTreesParent.petTalentParent.model:SetUnit("pet")
    --     end)

    --     -- self.talentTreesParent.petTalentParent.model.ControlFrame.OnLoad(self.talentTreesParent.petTalentParent.model.ControlFrame)
    --     --self.talentTreesParent.petTalentParent.model.ControlFrame:SetModelScene(self.talentTreesParent.petTalentParent.model);

    --     --DevTools_Dump({self.talentTreesParent.petTalentParent.model.ControlFrame.zoomOutButton})

    --     --self.talentTreesParent.petTalentParent.model.petSlotID = 0
    --     --self.talentTreesParent.petTalentParent.model:SetCameraOrientationByYawPitchRoll(1.57, 1.57, 3.14)
    --     self.talentTreesParent.petTalentParent.model:HookScript("OnMouseDown", function(model, button)
    --         if button == "LeftButton" then
    --             model.rotating = true
    --             model.rotateStartCursorX = GetCursorPosition()

    --         else

    --             -- local PET_STABLE_MODEL_SCENE_ID = 718;
    --             -- model.petSlotID = model.petSlotID + 1;
    --             -- if model.petSlotID > 5 then
    --             --     model.petSlotID = 0;
    --             -- end

    --             --local forceSceneChange = true;
    --             --model:TransitionToModelSceneID(PET_STABLE_MODEL_SCENE_ID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, forceSceneChange);
    --             --local creatureDisplayID = C_PlayerInfo.GetPetStableCreatureDisplayInfoID(model.petSlotID);

    --             -- if creatureDisplayID then

    --             --     local actor = model:GetActorAtIndex(1);
    --             --     if actor then
    --             --         actor:SetModelByCreatureDisplayID(creatureDisplayID);
    --             --     else
    --             --         local actor = model:CreateActor()
    --             --         actor:SetModelByCreatureDisplayID(creatureDisplayID);

    --             --         -- these args don't match the wiki
    --             --         --zoom + moves actor away, x + moves actor left, y + moves actor up
    --             --         actor:SetPosition(6, 0, -0.5)
    --             --         actor:SetPitch(3.14) --this is a forward roll
    --             --         actor:SetRoll(3.14) --this is a barrel roll
    --             --         actor:SetYaw(1.57) --this rotates

    --             --     end
    --             -- end

    --             --model:TransitionToModelSceneID(PET_STABLE_MODEL_SCENE_ID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, forceSceneChange);
    --         end
    --     end)
    
    --     self.talentTreesParent.petTalentParent.model:HookScript("OnMouseUp", function(model, button)
    --         if button == "LeftButton" then
    --             model.rotating = false
    --         end
    --     end)
    
    --     self.talentTreesParent.petTalentParent.model:HookScript("OnUpdate", function(model)
    --         if ( model.rotating ) then
    --             local x = GetCursorPosition();
    --             local diff = (x - model.rotateStartCursorX) * MODELFRAME_DRAG_ROTATION_CONSTANT;
    --             model.rotateStartCursorX = GetCursorPosition();
    --             model.yaw = (model.yaw or 1) + diff;
    --             -- model.pitch = (model.pitch or 1) + diff;
    --             -- model.roll = (model.roll or 1) + diff;
    --             if ( model.yaw < 0 ) then
    --                 model.yaw = model.yaw + (2 * PI);
    --             end
    --             if ( model.yaw > (2 * PI) ) then
    --                 model.yaw = model.yaw - (2 * PI);
    --             end
    --             -- if ( model.roll < 0 ) then
    --             --     model.roll = model.roll + (2 * PI);
    --             -- end
    --             -- if ( model.roll > (2 * PI) ) then
    --             --     model.roll = model.roll - (2 * PI);
    --             -- end
    --             -- if ( model.pitch < 0 ) then
    --             --     model.pitch = model.pitch + (2 * PI);
    --             -- end
    --             -- if ( model.pitch > (2 * PI) ) then
    --             --     model.pitch = model.pitch - (2 * PI);
    --             -- end
    --             model:SetRotation(model.yaw, false);
    --             --model:SetCameraOrientationByYawPitchRoll(model.yaw, 0,0)
    --             -- local actor = model:GetActorAtIndex(1);
    --             -- if actor then
    --             --     actor:SetYaw(model.yaw, false);
    --             -- end
    --         end
    --     end)



    --     self.talentTreesParent.petTalentParent.model:SetUnit("pet")

    -- else
    --     self.talentTreesParent.petSpec:Hide()
    --     self.talentTreesParent.playerSpec:Hide()
    -- end

end





function FancyPanelsMixin:CheckImportString(dataString)

    local source;
    local class, talents
    --https://www.wowhead.com/cata/talent-calc/paladin/003-32023023122100121231-002
    if string.find(dataString, "www.wowhead.com", nil, true) then
        source = "wowhead";
        local _, _, _, expansion, _, _class, _talents = strsplit("/", dataString)
        class = _class:upper()
        talents = _talents
    end

    if source and class and talents then
        local pointsSpent = self:GetTalentPointsFromDataString(talents)
        local pointString = string.format("%d-%d-%d", pointsSpent[1].points, pointsSpent[2].points, pointsSpent[3].points)
        self:SetTalentInfoText(BLUE_FONT_COLOR:WrapTextInColorCode(string.format("Talent Data from %s for %s [%s]", source, class, pointString)), 10)
    end
end

function FancyPanelsMixin:InitializeTalentTabDropdown()

    local _, classString, classID = UnitClass("player")

    local loadoutMenu = {}
    for k, v in ipairs(self.db.account.talentLoadouts) do
        if not loadoutMenu[v.class] then
            loadoutMenu[v.class] = {}
        end
        table.insert(loadoutMenu[v.class], v)
    end

    local classLoadoutMenu = {
        {
            text = UnitClass("player"),
            isTitle = true,
            notCheckable = true,
        }
    }
    for _classID, loadouts in pairs(loadoutMenu) do
        if _classID == classID then
            for k, v in ipairs(loadouts) do
                table.insert(classLoadoutMenu, {
                    text = v.name,
                    notCheckable = true,
                    func = function()
                        self:OnLoadoutSelected(v)
                    end,
                })
            end
        end
    end

    local starterBuilds = addon.Constants.StarterBuilds[classString]
    local starterMenu = {}
    if classString == "DRUID" then
        for k, v in ipairs(starterBuilds) do
            local id, name;
            if k == 2 then
                name = "Cat"
            elseif k == 3 then
                name = "Bear"
            elseif k == 4 then
                name = "Restoration"
            else
                id, name = GetTalentTabInfo(k)
            end
            table.insert(starterMenu, {
                text = name,
                notCheckable = true,
                func = function()
                    local source, class, talents = self:ImportTalentString(v)
                    self:OnLoadoutSelected({
                        class = class,
                        loadout = talents,
                        forceTabSelection = true,
                    })
                end
            })
        end
    else
        for k, v in ipairs(starterBuilds) do
            local id, name = GetTalentTabInfo(k)
            table.insert(starterMenu, {
                text = name,
                notCheckable = true,
                func = function()
                    local source, class, talents = self:ImportTalentString(v)
                    self:OnLoadoutSelected({
                        class = class,
                        loadout = talents,
                        forceTabSelection = true,
                    })
                end
            })
        end
    end

    local menu = {
        {
            text = string.format("%s %s", CreateAtlasMarkup("newplayerchat-chaticon-newcomer", 18, 18), L.STARTER_BUILD),
            notCheckable = true,
            hasArrow = true,
            menuList = starterMenu,
        },
        {
            text = string.format("%s %s", CreateAtlasMarkup("communities-icon-addgroupplus", 18, 18), L.SAVE_TALENTS),
            notCheckable = true,
            func = function()
                self:SaveTalentPreviewLoadout()
            end,
        },
        -- {
        --     text = "Export",
        --     notCheckable = true,
        --     func = function()
                
        --     end,
        -- },
        {
            text = string.format("%s %s", CreateAtlasMarkup("MovieRecordingIcon", 18, 18), L.RECORD_TALENTS),
            notCheckable = true,
            func = function()
                self.talentTreesParent.talentRecorderParent:Show()
            end,
        },
        {
            text = L.APPLY_TALENT_LOADOUT,
            hasArrow = true,
            notCheckable = true,
            menuList = classLoadoutMenu,
        },
    }



    UIDropDownMenu_SetWidth(self.talentTreesParent.talentLoadoutDropdown, 140)
    UIDropDownMenu_Initialize(self.talentTreesParent.talentLoadoutDropdown, function()

    end)

    --     for k, v in ipairs(menu) do
    --         local info = UIDropDownMenu_CreateInfo()
    --         if level == 1 then
    --             if k == 1 then
    --                 info.text = string.format("%s %s", CreateAtlasMarkup("communities-icon-addgroupplus"), v.text)
    --             else
    --                 info.text = v.text
    --             end
    --             info.notCheckable = true
    --             if v.func then
    --                 info.func = v.func
    --             end
    --             if k == 3 then
    --                 info.hasArrow = true
    --                 info.menuList = classLoadoutMenu
    --             end

    --             UIDropDownMenu_AddButton(info)
    --         else

    --             UIDropDownMenu_AddButton(info, level)
    --         end

    --         UIDropDownMenu_AddButton(info)
    --     end
    -- end)

    FancyPanelsTalentLoadoutDropdownButton:SetScript("OnClick", function()
        EasyMenu(menu, self.talentTreesParent.talentLoadoutDropdown, self.talentTreesParent.talentLoadoutDropdown, 10, 10, "NONE", 3)
    end)


    --self.talentTreesParent.talentLoadoutDropdown:SetMenu(menu)
end

function FancyPanelsMixin:OnLoadoutSelected(data)
    local tabID, loadout = self:ConvertTalentStringToInternalTable(data.loadout)
    self:AttemptPreviewTalentLoadout(data.class, tabID, loadout, data.isPet or true, data.forceTabSelection)
end


---Attempt to apply the talent loadout to the current activeSpecGroup
---@param class number checks the talent loadout against the current character class
---@param tabID number check the selected spec against the talent loadout spec
---@param loadout table a table of talent points that is looped and fed into the Blizz AddPreviewTalentPoints api
function FancyPanelsMixin:AttemptPreviewTalentLoadout(class, tabID, loadout, isPet, forceTabSelect)

    if forceTabSelect then
        self:SetView(2)
        self:Specialization_OnSelected(self.classSpecInfo[tabID])
    end

    if loadout and (class == select(3, UnitClass("player"))) and self.selectedSpecInfo and (self.selectedSpecInfo.tabID == tabID) then

        PlayerTalentFrameResetButton_OnClick()
        self:SetView(2)

        self:Specialization_OnSelected(self.classSpecInfo[tabID])

        local activeTalentGroup = C_SpecializationInfo.GetActiveSpecGroup(false, false)


        --[[
            this needs to be implemented properly so any loadout gets applied correctly
        ]]
        -- local loadoutOrdered = {}
        -- for k, v in ipairs(loadout) do
        --     local tier, column, isLearnable = GetTalentPrereqs(v.tabIndex, v.talentIndex, false, isPet, activeTalentGroup)

        --     if tier and column then
        --         local talent = self:FindTalentFromAddress(tabID, tier, column)
        --         local _name, _, row, col, _rank, _maxRank, isExceptional, available, unKnown, isActive, y, talentID = GetTalentInfo(talent.tabIndex, talent.talentIndex)
                
        --         for i = 1, _maxRank do
        --             table.insert(loadoutOrdered, {
        --                 tabIndex = talent.tabIndex,
        --                 talentIndex = talent.talentIndex,
        --             })
        --         end

        --     else
        --         table.insert(loadoutOrdered, v)

        --     end
        -- end

        --local loadoutOrdered;
        if class == 6 then
            local firstNecroPointIndex;
            local runeTapIndex;
            for k, v in ipairs(loadout) do
                if v.tabIndex == 1 and v.talentIndex == 6 then
                    if not firstNecroPointIndex then
                        firstNecroPointIndex = k
                    end
                end
                if v.tabIndex == 1 and v.talentIndex == 4 then
                    if not runeTapIndex then
                        runeTapIndex = k
                    end
                end
            end
            if type(firstNecroPointIndex) == "number" and type(runeTapIndex) == "number" then

                --print("moving talents to allow for pre req ordering")

                --as the loadout elements are { tabIndex = n, talentIndex = n, } we can just move the rune tap entry into the first necro entry
                Util.tableSwap(loadout, firstNecroPointIndex, runeTapIndex)
            end

        elseif class == 8 then

            --arcane leftwards pre req
            local firstArcaneFlowsPointIndex;
            local presenceMindIndex;
            for k, v in ipairs(loadout) do
                if v.tabIndex == 1 and v.talentIndex == 11 then
                    if not firstArcaneFlowsPointIndex then
                        firstArcaneFlowsPointIndex = k
                    end
                end
                if v.tabIndex == 1 and v.talentIndex == 6 then
                    if not presenceMindIndex then
                        presenceMindIndex = k
                    end
                end
            end
            if type(firstArcaneFlowsPointIndex) == "number" and type(presenceMindIndex) == "number" then
                Util.tableSwap(loadout, firstArcaneFlowsPointIndex, presenceMindIndex)
            end


            --frost leftwards pre req
            local firstShatBarrierPointIndex;
            local iceBarrierIndex;
            for k, v in ipairs(loadout) do
                if v.tabIndex == 3 and v.talentIndex == 8 then
                    if not firstShatBarrierPointIndex then
                        firstShatBarrierPointIndex = k
                    end
                end
                if v.tabIndex == 3 and v.talentIndex == 9 then
                    if not iceBarrierIndex then
                        iceBarrierIndex = k
                    end
                end
            end
            if type(firstShatBarrierPointIndex) == "number" and type(iceBarrierIndex) == "number" then
                Util.tableSwap(loadout, firstShatBarrierPointIndex, iceBarrierIndex)
            end


        end


        local i = 1;
        C_Timer.NewTicker(0.015, function()
            local talent = loadout[i]
            --local _name, _, row, col, _rank, _maxRank, isExceptional, available, unKnown, isActive, y, talentID = GetTalentInfo(talent.tabIndex, talent.talentIndex)
            --print(i, _name)
            AddPreviewTalentPoints(talent.tabIndex, talent.talentIndex, 1, false, activeTalentGroup);
            i = i + 1;
        end, #loadout)

    else

        --add more fail reasons in time
        self:SetTalentInfoText(RED_FONT_COLOR:WrapTextInColorCode(string.format("That loadout isn't compatible"), 6))
    end
    
end

---Create a talent data string using the wowhead hyphen format
function FancyPanelsMixin:SaveTalentPreviewLoadout()

    local trees = {
        [1] = "",
        [2] = "",
        [3] = "",
    }
    local treeIndex = 0
    -- self:IterTalentTreesOrdered(function(f)
    --     if f.rowId == 1 and f.colId == 1 then
    --         treeIndex = treeIndex + 1
    --     end
    --     if f.talentIndex then
    --         trees[treeIndex] = string.format("%s%s", trees[treeIndex], f.previewRank or 0)
    --     end
    -- end)
    local s = string.format("%s-%s-%s", trees[1], trees[2], trees[3])

    StaticPopup_Show("FancyPanelsSaveLoadoutDialog", "Name", nil, {
        callback = function(name)
            local _, _, class = UnitClass("player")
            table.insert(self.db.account.talentLoadouts, {
                name = name,
                class = class,
                loadout = s,
            })
            self:InitializeTalentTabDropdown()
        end
    })

end

---Takes a string and looks for valid class and talent data
---@param dataString string import containing data
function FancyPanelsMixin:ImportTalentString(dataString)
    
    local source;
    local class, talents
    --https://www.wowhead.com/cata/talent-calc/paladin/003-32023023122100121231-002
    if string.find(dataString, "www.wowhead.com", nil, true) then
        source = "wowhead";
        local _, _, _, expansion, _, _class, _talents = strsplit("/", dataString)
        
        if _class == "death-knight" then
            _class = "deathknight"
        end

        class = _class:upper()
        talents = _talents
    end

    for i = 1, 12 do
        local _, c, id = GetClassInfo(i)
        if c == class then
            class = id
        end
    end

    if source and (type(class) == "number") and talents then
        return source, class, talents;
    end

end



---Parse a talent data string and return tab point spend data
---@param dataString string talent point data string
---@return table tab point spend - not sorted
function FancyPanelsMixin:GetTalentPointsFromDataString(dataString)

    local tabs = {strsplit("-", dataString)}

    --Cata requires 31 points to be spent in a primary tree before spending elsewhere
    --we need to know which tree to target first
    local pointsSpent = {
        { id = 1, points = 0 },
        { id = 2, points = 0 },
        { id = 3, points = 0 },
    }

    --loop the data and add the points spent per tree
    --then apply a simple sort allowing us to access the tree in the correct order
    for k, tab in ipairs(tabs) do
        if tab and (#tab > 0) then
            local tbl = {string.byte(tab, 1, #tab)}
            for i = 1, #tbl do
                local c = tonumber(string.char(tbl[i]))
                if c then
                    pointsSpent[k].points = pointsSpent[k].points + c
                end
            end
        end
    end

    return pointsSpent;
end


---Create a table of talent points in col > row order that uses correct main spec
---@param dataString string talent data string
---@return number tabID of main spec
---@return table talents talents in point spent order assuming l-r t-b ordering of tree
function FancyPanelsMixin:ConvertTalentStringToInternalTable(dataString)

    if dataString then
        
        --wowhead uses a hyphen to split tree data
        local tabs = {strsplit("-", dataString)}

        --Cata requires 31 points to be spent in a primary tree before spending elsewhere
        --we need to know which tree to target first
        local pointsSpent = self:GetTalentPointsFromDataString(dataString)
        table.sort(pointsSpent, function(a, b)
            return a.points > b.points
        end)

        --not sure a timer is truely required but it shouldn't hurt to use
        local queue = {}

        --[[
            due to the UI of the addon the trees are not always ordered left to right as per the Blizzard UI
            
            to combat this requires some work as we need to pair the talent data with a treeIndex and talentIndex
            for the api to apply the preview

            loop the addon trees using the points spent sort table
            loop the tree talents and insert into the queue
        ]]
        for i, tab in ipairs(pointsSpent) do
            for _, v in ipairs({"talentTab1", "talentTab2", "talentTab3"}) do

                if self.talentTreesParent[v].treeIndex == tab.id then

                    local j = 1;
                    local talentString = tabs[tab.id]
                    if talentString then
                        for k, talent in ipairs(self.talentTreesParent[v]:GetFrames()) do
                            if talent.talentIndex then

                                local _name, _, row, col, _rank, _maxRank, isExceptional, available, unKnown, isActive, y, talentID = GetTalentInfo(tab.id, talent.talentIndex)
                                local rank = tonumber(string.sub(talentString, j,j))
                                if rank and rank > 0 then
                                    for x = 1, rank do
                                        table.insert(queue, {
                                            tabIndex = tab.id,
                                            talentIndex = talent.talentIndex,
                                        })

                                        -- if tab.id == 1 then
                                        --     print(j, _name, rank)
                                        --     print(tab.id, talent.rowId, talent.colId, rank, j)

                                        -- end


                                    end
                                end

                                j = j + 1;
                            end
                        end
                    end
                end
            end
        end

        return pointsSpent[1].id, queue


        -- local i = 1;
        -- C_Timer.NewTicker(0.01, function()
        --     local talent = queue[i]
        --     AddPreviewTalentPoints(queue[i].tabIndex, queue[i].talentIndex, 1, false, activeTalentGroup);
        --     i = i + 1;
        -- end, #queue)
    end
end


---Load the characters class spec data into the spec tab, this is done once for the players live talents/specs
---@param classID any

function FancyPanelsMixin:Specialization_OnSelected(info)

    self.selectedSpecInfo = info

    --keep the Blizzard UI updated
    -- local parent = _G["PlayerTalentFramePanel"..info.tabID]
    -- PlayerTalentFrameTalents.summariesShownWhenPrimary = false;
    -- if ( GetCVarBool("previewTalentsOption") ) then
    --     SetPreviewPrimaryTalentTree(parent.talentTree, parent.talentGroup);
    -- else
    --     SetPrimaryTalentTree(parent.talentTree);
    -- end
    
    self:SetView(2)

    self.talentTreesParent.background:SetTexture(info.backgroundFilePath)
    self.talentTreesParent.background:SetTexCoord(info.backgroundAtlas[1],info.backgroundAtlas[2],info.backgroundAtlas[3],info.backgroundAtlas[4])

    local j = 1;
    for i = 1, 3 do
        -- local id, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(i)

        -- if id == info.specID then
        --     self.talentTreesParent.primaryTree.treeIndex = i
        --     self:BuildTalentTree(self.talentTreesParent.primaryTree, info.specID, true)
        -- else
        --     self.talentTreesParent["secondaryTree"..j].treeIndex = i
        --     self:BuildTalentTree(self.talentTreesParent["secondaryTree"..j], id, true)
        --     j = j + 1;
        -- end

        self.talentTreesParent["talentTab"..i].treeIndex = i;

    end

    -- self:UpdateTalentTrees()
    -- self:UpdatePetTalentTree()
end



function FancyPanelsMixin:UpdatePetTalentTree()

    --this needs to go elsewhere really
    if UnitName("pet") then
        self.talentTreesParent.petTalentParent.petName:SetText(string.format("%s %s %s", UnitName("pet"), LEVEL, UnitLevel("pet")))
    end
    
    local activeTalentGroup = C_SpecializationInfo.GetActiveSpecGroup(false, true)

    local tree = self.talentTreesParent.petTalentParent.talentTree

    local id, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(1, false, true, activeTalentGroup)

    if not name then
        return
    end

    local points = ( GetCVarBool("previewTalentsOption") == true ) and (pointsSpent + previewPointsSpent) or pointsSpent

    if isUnlocked then
        tree.header:SetText(string.format("%s\n%d %s", name, points, "Points spent"):upper())
    else
        tree.header:SetText(string.format("%s %s", name, CreateAtlasMarkup(addon.Constants.AtlasShortcuts.Padlock, 20, 24, 0, -18)))
    end

    local lastRowOpen = math.ceil(points / 5)

    if points % 5 == 0 then
        lastRowOpen = lastRowOpen + 1;
    end

    local unlockOffset = math.ceil(points / 5)
    if unlockOffset > 7 then
        unlockOffset = 7
    end
    if points % 5 == 0 then
        unlockOffset = unlockOffset + 1;
    end
    local rowHeight = tree:GetHeight() / 6

    tree.rowLockIcon:ClearAllPoints()
    tree.rowLockIcon:SetPoint("BOTTOMRIGHT", tree, "TOPLEFT", 0, (unlockOffset * -rowHeight))

    if unlockOffset < 7 then
        local spendText = "Spend %d\nto unlock"
        tree.pointsInfo:SetText(string.format(spendText, (unlockOffset * 5) - points))

        tree.rowLockIcon:Show()
        tree.pointsInfo:Show()

    else
        tree.rowLockIcon:Hide()
        tree.pointsInfo:Hide()
    end

    for _, frame in ipairs(tree:GetFrames()) do
        if (frame.rowId <= lastRowOpen) and frame.talentIndex then
            frame.icon:SetDesaturation(0)
        else
            frame.icon:SetDesaturation(1)
        end
    end
end


---Loop the talent trees and update the ui elements
function FancyPanelsMixin:UpdateTalentTrees_Old()

    if 1 == 1 then
        return
    end
    --local primaryTree = GetPreviewPrimaryTalentTree(false, false, spec.talentGroup) or GetPrimaryTalentTree(false, false, spec.talentGroup);

    --HasPetUI()
    --PlayerSpecTab_OnClick

    --self.talentTreesParent.helptip:Hide() NEXT_TALENT_LEVEL, GetNextTalentLevel()

    --self.talentTreesParent.helptip:SetText(string.format("%s\n%d %s %s", TALENT_TREE_LOCKED_TOOLTIP, GetNumTalentPoints(), BONUS_TALENTS, AVAILABLE))

    --GetUnspentTalentPoints(inspec, pet, group)
    --GetNumTalentPoints() --get available points

    --local id, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(self.talentTree, self.inspect, self.pet, self.talentGroup);



    local activeTalentGroup = C_SpecializationInfo.GetActiveSpecGroup(false, false)

    for i = 1, 2 do
        local tabID = GetPreviewPrimaryTalentTree(false, false, i) or GetPrimaryTalentTree(false, false, i)
        if tabID then
            local id, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(tabID, false, false, i)
            if icon then
                self.talentTreesParent["spec"..i].icon:SetTexture(icon)
            end
        else
            self.talentTreesParent["spec"..i].icon:SetTexture(134400)
        end
        self.talentTreesParent["spec"..i].border:SetAtlas("charactercreate-ring-metallight")
    end

    self.talentTreesParent["spec"..activeTalentGroup].border:SetAtlas("charactercreate-ring-select")

    local treePoints = {0,0,0}
    local treeLastRowOpen = {1,1,1}
    local hasSpentPoints = false

    for k, line in ipairs(self.talentArrowLinesPool) do
        line:ClearAllPoints()
        line:Hide()
    end

    local lineIter = 1;

    for k, v in ipairs({"talentTab1", "talentTab2", "talentTab3"}) do

        local tree = self.talentTreesParent[v]

        if tree.treeIndex then

            local id, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(tree.treeIndex, false, false, activeTalentGroup);

            if (previewPointsSpent > 0) and hasSpentPoints == false then
                hasSpentPoints = true
            end

            local points = ( GetCVarBool("previewTalentsOption") == true ) and (pointsSpent + previewPointsSpent) or pointsSpent

            treePoints[k] = points

            if isUnlocked then
                tree.header:SetText(string.format("%s\n%d %s", name, points, "Points spent"):upper())
            else
                tree.header:SetText(string.format("%s %s", name, CreateAtlasMarkup(addon.Constants.AtlasShortcuts.Padlock, 20, 24, 0, -18)))
            end

            local lastRowOpen = math.ceil(points / 5)

            if points % 5 == 0 then
                lastRowOpen = lastRowOpen + 1;
            end

            treeLastRowOpen[tree.treeIndex] = lastRowOpen
               
            if k == 1 then

                local unlockOffset = math.ceil(points / 5)
                if unlockOffset > 7 then
                    unlockOffset = 7
                end
                if points % 5 == 0 then
                    unlockOffset = unlockOffset + 1;
                end
                local rowHeight = tree:GetHeight() / 7
    
                tree.rowLockIcon:ClearAllPoints()
                tree.rowLockIcon:SetPoint("BOTTOMRIGHT", tree, "TOPLEFT", 0, (unlockOffset * -rowHeight))

                if unlockOffset < 7 then
                    local spendText = "Spend %d\nto unlock"
                    tree.pointsInfo:SetText(string.format(spendText, (unlockOffset * 5) - points))

                    tree.rowLockIcon:Show()
                    tree.pointsInfo:Show()

                else
                    tree.rowLockIcon:Hide()
                    tree.pointsInfo:Hide()
                end

                for _, frame in ipairs(tree:GetFrames()) do
                    if (frame.rowId <= lastRowOpen) and frame.talentIndex then
                        frame.icon:SetDesaturation(0)
                    else
                        frame.icon:SetDesaturation(1)
                    end
                end

            else
                if treePoints[1] > 30 then
                    for _, frame in ipairs(tree:GetFrames()) do
                        --frame:EnableMouse(true)
                        if (frame.rowId <= lastRowOpen) and frame.talentIndex then
                            frame.icon:SetDesaturation(0)
                        else
                            frame.icon:SetDesaturation(1)
                        end
                    end
                else
                    for _, frame in ipairs(tree:GetFrames()) do
                        --frame:EnableMouse(false)
                        frame.icon:SetDesaturation(1)
                    end
                end

            end

        end

    end

    FancyPanelsFrameLearnButtonTutorial:Hide()

    if hasSpentPoints then
        FancyPanelsFrameLearnButtonTutorial:Show()
    else
        if type(self.talentRecord) == "table" then
            FancyPanelsFrameLearnButtonTutorial:Show()
        else
            FancyPanelsFrameLearnButtonTutorial:Hide()
        end
    end

    if treePoints[1] > 30 then

        self.talentTreesParent.secondaryTree1.isUnlocked = true
        self.talentTreesParent.secondaryTree2.isUnlocked = true

        local pointsSpent = treePoints[1] + treePoints[2] + treePoints[3]

        if (GetNumTalentPoints() - pointsSpent) > 0 then
            self.talentTreesParent.helptip:SetText(string.format("%d Points Available", GetNumTalentPoints() - pointsSpent))

        else
            if GetNextTalentLevel() then
                self.talentTreesParent.helptip:SetText(NEXT_TALENT_LEVEL:format(GetNextTalentLevel()))
            end
        end


    else
        self.talentTreesParent.helptip:SetText(TALENT_TREE_LOCKED_TOOLTIP)

        self.talentTreesParent.secondaryTree1.isUnlocked = false
        self.talentTreesParent.secondaryTree2.isUnlocked = false
    end

    --this seems a bit much and should be incorporated into the above logic

    --[[
        it seems that using the above logic will cause the line to show hide as per row unlocking
        this is somewhat ok but i feel showing the relation permanently is better
    ]]
    for tabID = 1, 3 do
        self:IterTalentTreeFrames(tabID, function(f)

            if f.tabIndex and f.talentIndex then
                local tier, column, isLearnable = GetTalentPrereqs(f.tabIndex, f.talentIndex, false, false, activeTalentGroup)

                if tier and column then
                    --print(name, "has pre req")
                    local talent = self:FindTalentFromAddress(tabID, tier, column)
                    local _name, iconTexture, row, col, _rank, _maxRank, isExceptional, available, unKnown, isActive, y, talentID = GetTalentInfo(talent.tabIndex, talent.talentIndex)
                    
                    if ( GetCVarBool("previewTalentsOption") == true ) then
                        _rank = talent.previewRank
                    end
                    

                    if not self.talentArrowLinesPool[lineIter] then
                        local line = f:CreateLine(nil, "BACKGROUND", nil, -5)
                        line:SetThickness(6)
                        line:SetColorTexture(0.5, 0.5, 0.5)
                        self.talentArrowLinesPool[lineIter] = line
                    end

                    if _rank < _maxRank then
                        f.icon:SetDesaturation(1)
                        self.talentArrowLinesPool[lineIter]:SetColorTexture(0.5, 0.5, 0.5)
                    else
                        if treeLastRowOpen[tabID] >= f.rowId then
                            self.talentArrowLinesPool[lineIter]:SetColorTexture(0.9,0.8,0.0)
                            f.icon:SetDesaturation(0)
                        else
                            self.talentArrowLinesPool[lineIter]:SetColorTexture(0.5, 0.5, 0.5)
                            f.icon:SetDesaturation(1)
                        end
                    end

                    self.talentArrowLinesPool[lineIter]:SetParent(f)
                    self.talentArrowLinesPool[lineIter]:SetStartPoint("CENTER", talent, 0, 0)
                    self.talentArrowLinesPool[lineIter]:SetEndPoint("CENTER", f, 0, 0)
                    self.talentArrowLinesPool[lineIter]:Show()

                    lineIter = lineIter + 1
                end

            end
        end)
    end


end

---Build the talent tree for a specified talent tree ID
---@param tree frame the gridview tree to populate
---@param specID number the talent tab ID
---@param isPlayer any true if player to set talent indexes otherwise a valid classID
function FancyPanelsMixin:BuildTalentTree(tree, specID, isPlayer)

    local classID;
    if isPlayer == true then
        classID = select(3, UnitClass("player"))
    else
        if type(isPlayer) == "number" then
            classID = isPlayer
        end
    end

    if not classID then
        return
    end

    local activeTalentGroup = C_SpecializationInfo.GetActiveSpecGroup(false, false)

    for k, frame in ipairs(tree:GetFrames()) do
        frame:ClearTalent()

        local row, col = frame.rowId, frame.colId
        if addon.Constants.TalentTrees[classID] and addon.Constants.TalentTrees[classID][specID] and addon.Constants.TalentTrees[classID][specID][row] and addon.Constants.TalentTrees[classID][specID][row][col] then
            
            if isPlayer then
                --frame:SetTalentIndex(addon.Constants.TalentTrees[classID][specID][row][col])
                frame:SetTalentIndex(addon.Constants.TalentTrees[classID][specID][row][col], false, row, col, activeTalentGroup, specID)
            else
                frame:SetBaseTalent(addon.Constants.TalentTrees[classID][specID][row][col])
            end
        end

        -- if not isUnlocked then
        --     frame:EnableMouse(false)
        -- end
    end


end



function FancyPanelsMixin:BuildPetTalentTree()

    local activeTalentGroup = C_SpecializationInfo.GetActiveSpecGroup(false, true)

    local specID, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(1, false, true, activeTalentGroup);

    for k, frame in ipairs(self.talentTreesParent.petTalentParent.talentTree:GetFrames()) do
        frame:ClearTalent()

        local row, col = frame.rowId, frame.colId
        row = tostring(row)
        col = tostring(col)

        if addon.Constants.PetTalents and addon.Constants.PetTalents[specID] and addon.Constants.PetTalents[specID][row] and addon.Constants.PetTalents[specID][row][col] then
            
            frame:SetTalentIndex(addon.Constants.PetTalents[specID][row][col], true)
        end

    end
end





















--[[
    This systhem could almost be used to power the UI rather than using the massive data table
    However, the talent index is only used to learn talents and so only really applies to the players active talent set.
]]
function FancyPanelsMixin:MapClassTalentIndexes()
    
    self.talentIndexMap = {}
    for tabIndex = 1, GetNumTalentTabs() do
        local specID = GetTalentTabInfo(tabIndex)
        for talentIndex = 1, GetNumTalents(tabIndex) do
            local _, _, row, col = GetTalentInfo(tabIndex, talentIndex)

            if not self.talentIndexMap[specID] then
                self.talentIndexMap[specID] = {}
            end
            if not self.talentIndexMap[specID][row] then
                self.talentIndexMap[specID][row] = {}
            end
            self.talentIndexMap[specID][row][col] = {
                tabIndex = tabIndex,
                talentIndex = talentIndex,
            }

        end
    end

end

function FancyPanelsMixin:CreateClassData()

    --print("pet stuff")
    if MT_ACCOUNT then
    
        local id, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(1, false, true, 1);

        if not MT_ACCOUNT.petTalents then
            MT_ACCOUNT.petTalents = {}
        end

        if id then
            if not MT_ACCOUNT.petTalents[id] then
                MT_ACCOUNT.petTalents[id] = {}
            end

            for talentIndex = 1, GetNumTalents(1, false, true) do

                -- 411 cunning "" 132168 0 HunterPetCunning 0 true
                -- 410 ferocity "" 132143 0 HunterPetFerocity 0 true
                -- 409 tenacity "" 132183 0 HunterPetTenacity 0 true


                local name, icon, row, col, rank, maxRank, isExceptional, available, x, y, z, talentID = GetTalentInfo(1, talentIndex, false, true, 1)

                row = tostring(row)
                col = tostring(col)

                local spells = {}
                for k, v in ipairs(addon.rawPetTalentData) do
                    if v[1] == talentID then
                        for i = 13, 15 do
                            if v[i] > 0 then
                                table.insert(spells, v[i])
                            end
                        end
                    end
                end

                if name then
                    if not MT_ACCOUNT.petTalents[id][row] then
                        MT_ACCOUNT.petTalents[id][row] = {}
                    end

                    MT_ACCOUNT.petTalents[id][row][col] = {
                        tabIndex = 1,
                        talentIndex = talentIndex,
                        talentSpellIDs = spells,
                    }
                end

            end
        end

    end

end













