

local name, addon = ...;

local talentFilePath = "Interface/AddOns/FancyPanels/Media/Talents";
local talentFilePrefix = "TalentsClassBackground";


local specThumbnails = {
["deathknightblood"] = { 306, 186, 0.00048828125, 0.14990234375, 0.00048828125, 0.09130859375, false, false },
["deathknightfrost"] = { 306, 186, 0.15087890625, 0.30029296875, 0.00048828125, 0.09130859375, false, false },
["deathknightunholy"] = { 306, 186, 0.30126953125, 0.45068359375, 0.00048828125, 0.09130859375, false, false },
["druidbalance"] = { 306, 186, 0.75244140625, 0.90185546875, 0.00048828125, 0.09130859375, false, false },
["druidferalcombat"] = { 306, 186, 0.00048828125, 0.14990234375, 0.09228515625, 0.18310546875, false, false },
["druidguardian"] = { 306, 186, 0.15087890625, 0.30029296875, 0.09228515625, 0.18310546875, false, false },
["druidrestoration"] = { 306, 186, 0.30126953125, 0.45068359375, 0.09228515625, 0.18310546875, false, false },
["hunterbeastmastery"] = { 306, 186, 0.75244140625, 0.90185546875, 0.09228515625, 0.18310546875, false, false },
["huntermarksmanship"] = { 306, 186, 0.00048828125, 0.14990234375, 0.18408203125, 0.27490234375, false, false },
["huntersurvival"] = { 306, 186, 0.15087890625, 0.30029296875, 0.18408203125, 0.27490234375, false, false },
["magearcane"] = { 306, 186, 0.30126953125, 0.45068359375, 0.18408203125, 0.27490234375, false, false },
["magefire"] = { 306, 186, 0.45166015625, 0.60107421875, 0.18408203125, 0.27490234375, false, false },
["magefrost"] = { 306, 186, 0.60205078125, 0.75146484375, 0.18408203125, 0.27490234375, false, false },
["monkbrewmaster"] = { 306, 186, 0.75244140625, 0.90185546875, 0.18408203125, 0.27490234375, false, false },
["monkmistweaver"] = { 306, 186, 0.00048828125, 0.14990234375, 0.27587890625, 0.36669921875, false, false },
["monkwindwalker"] = { 306, 186, 0.15087890625, 0.30029296875, 0.27587890625, 0.36669921875, false, false },
["paladinholy"] = { 306, 186, 0.30126953125, 0.45068359375, 0.27587890625, 0.36669921875, false, false },
["paladinprotection"] = { 306, 186, 0.45166015625, 0.60107421875, 0.27587890625, 0.36669921875, false, false },
["paladincombat"] = { 306, 186, 0.60205078125, 0.75146484375, 0.27587890625, 0.36669921875, false, false },
["priestdiscipline"] = { 306, 186, 0.75244140625, 0.90185546875, 0.27587890625, 0.36669921875, false, false },
["priestholy"] = { 306, 186, 0.00048828125, 0.14990234375, 0.36767578125, 0.45849609375, false, false },
["priestshadow"] = { 306, 186, 0.15087890625, 0.30029296875, 0.36767578125, 0.45849609375, false, false },
["rogueassassination"] = { 306, 186, 0.30126953125, 0.45068359375, 0.36767578125, 0.45849609375, false, false },
["roguecombat"] = { 306, 186, 0.45166015625, 0.60107421875, 0.36767578125, 0.45849609375, false, false },
["roguesubtlety"] = { 306, 186, 0.60205078125, 0.75146484375, 0.36767578125, 0.45849609375, false, false },
["shamanelementalcombat"] = { 306, 186, 0.75244140625, 0.90185546875, 0.36767578125, 0.45849609375, false, false },
["shamanenhancement"] = { 306, 186, 0.00048828125, 0.14990234375, 0.45947265625, 0.55029296875, false, false },
["shamanrestoration"] = { 306, 186, 0.00048828125, 0.14990234375, 0.55126953125, 0.64208984375, false, false },
["warlockcurses"] = { 306, 186, 0.00048828125, 0.14990234375, 0.64306640625, 0.73388671875, false, false },
["warlocksummoning"] = { 306, 186, 0.00048828125, 0.14990234375, 0.73486328125, 0.82568359375, false, false },
["warlockdestruction"] = { 306, 186, 0.00048828125, 0.14990234375, 0.82666015625, 0.91748046875, false, false },
["warriorarms"] = { 306, 186, 0.15087890625, 0.30029296875, 0.45947265625, 0.55029296875, false, false },
["warriorfury"] = { 306, 186, 0.30126953125, 0.45068359375, 0.45947265625, 0.55029296875, false, false },
["warriorprotection"] = { 306, 186, 0.45166015625, 0.60107421875, 0.45947265625, 0.55029296875, false, false },
}

local Util = {}

function Util.tableSwap(tbl, i, j)
    tbl[i], tbl[j] = tbl[j], tbl[i]
end

function Util.tableMoveUp(tbl, i)
    Util.tableSwap(tbl, i, i - 1)
end

function Util.tableMoveDown(tbl, i)
    Util.tableSwap(tbl, i, i + 1)
end

function Util.GetAvailableTalentPointsForLevel(level)
    return ((level -10) / 2) +1;
end

function Util.GetSpecDesc(classID, tabID)

    if (classID == 11) and (tabID == 2) then
        return string.format("%s\n\n%s", "Takes on the form of a great cat to deal damage with bleeds and bites.", "Takes on the form of a mighty bear to absorb damage and protect allies.");
    elseif (classID == 11) and (tabID == 3) then
        return "Uses heal-over-time Nature spells to keep allies alive.";
    end

    tabID = tabID - 1;
    for k, v in ipairs(addon.specInfo) do
        if (v.classID == classID) and (v.tabIndex == tabID) then
            return v.description
        end
    end
end

local roles = {
    [0] = "TANK",
    [1] = "HEALER",
    [2] = "DAMAGER",
}
function Util.GetTabRole(classID, tabID)

    --print("ClassRole:", classID, tabID);

    if (classID == 11) and (tabID == 2) then
        return "TANK", "DAMAGER";
    elseif (classID == 11) and (tabID == 3) then
        return "HEALER";
    end

    tabID = tabID - 1;
    for k, v in ipairs(addon.specInfo) do
        if (v.classID == classID) and (v.tabIndex == tabID) then
            --print("Role:", v.roleID, roles[v.roleID], v.name, v.tabIndex, tabID)
            return roles[v.roleID];
        end
    end
end

function Util.GetClassData(classID)

    -- ShowUIPanel(PlayerTalentFrame);
    -- HideUIPanel(PlayerTalentFrame);

    local class;
    if classID == 6 then
        class = "DeathKnight";
    else
        class = select(2, GetClassInfo(classID))
        class = class:lower():gsub("^%l", string.upper)
    end

    local bg1 = tostring(talentFilePath.."/"..talentFilePrefix..class.."1.png");
    local bg2 = tostring(talentFilePath.."/"..talentFilePrefix..class.."2.png");

    local specs = {}

    if classID == 11 then

        specs = {
            {
                backgroundFilePath = bg1,
                backgroundAtlas = {0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875},
            },
            {
                backgroundFilePath = bg1,
                backgroundAtlas = {0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875},
            },
            -- {
            --     backgroundFilePath = bg2,
            --     backgroundAtlas = {0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875},
            -- },
            {
                backgroundFilePath = bg2,
                backgroundAtlas = {0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875},
            },
        }

        for i = 1, 3 do
            --local id, name, desc, fileID, x, classSpec, y = GetTalentTabInfo(i)
            local id, name, description, icon, role, primaryStat, pointsSpent, background, previewPointsSpent, isUnlocked = C_SpecializationInfo.GetSpecializationInfo(i, false, false, nil, nil, 1);
            local atlas = specThumbnails[background:lower()]

            specs[i].tabID = i;
            specs[i].specID = id;

            specs[i].thumbnailAtlas = {atlas[3], atlas[4], atlas[5], atlas[6],}
            specs[i].description = Util.GetSpecDesc(classID, i)
            specs[i].name = name;

            specs[i].sampleTalents = Util.GetClassSampleTalents(classID, id)

            -- specs[i].majorBonuses = {GetMajorTalentTreeBonuses(i)}
            -- specs[i].minorBonuses = {GetMinorTalentTreeBonuses(i)}
            -- for k, v in ipairs({GetTalentTreeMasterySpells(i)}) do
            --     table.insert(specs[i].minorBonuses, v)
            -- end
            --DevTools_Dump({GetTalentTreeEarlySpells(i)})

        end

    else

        specs = {
            {
                backgroundFilePath = bg1,
                backgroundAtlas = {0.00048828125, 0.78759765625, 0.00048828125, 0.37841796875},
            },
            {
                backgroundFilePath = bg1,
                backgroundAtlas = {0.00048828125, 0.78759765625, 0.37939453125, 0.75732421875},
            },
            {
                backgroundFilePath = bg2,
                backgroundAtlas = {0.00048828125, 0.78759765625, 0.0009765625, 0.7568359375},
            },
        }

        for i = 1, 3 do
            --local id, name, desc, fileID, x, classSpec, y = GetTalentTabInfo(i)
            local id, name, description, icon, role, primaryStat, pointsSpent, background, previewPointsSpent, isUnlocked = C_SpecializationInfo.GetSpecializationInfo(i, false, false, nil, nil, 1);
            local atlas = specThumbnails[background:lower()]

            specs[i].tabID = i;
            specs[i].specID = id;

            specs[i].thumbnailAtlas = {atlas[3], atlas[4], atlas[5], atlas[6],}
            specs[i].description = Util.GetSpecDesc(classID, i)
            specs[i].name = name;

            -- specs[i].majorBonuses = {GetMajorTalentTreeBonuses(i)}
            -- specs[i].minorBonuses = {GetMinorTalentTreeBonuses(i)}
            -- for k, v in ipairs({GetTalentTreeMasterySpells(i)}) do
            --     table.insert(specs[i].minorBonuses, v)
            -- end

            specs[i].sampleTalents = Util.GetClassSampleTalents(classID, id) -- Util.GetTalentData(classID, id, 6, 1);
            --DevTools_Dump({specs[i].sampleTalent})

        end

    end

    return specs;
end


function Util.GetClassSampleTalents(classID, specID)

    local sampleTalents = {};

    --most classes have a worthy talent in rows 6/8 col 2 but not all!
    local sample1Col, sample2Col = 1, 1;
    local sample1Row, sample2Row = 6, 8;

    local sample1, sample2;

    if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then

        sample1Row, sample2Row = 4, 6; --adjust for smaller trees

        if (classID == 7) and (specID == 262) then
            sample1Col = 2; --shaman natures swiftness
        end

        sample1 = Util.GetTalentData(classID, specID, sample1Row, sample1Col);
        sample2 = Util.GetTalentData(classID, specID, sample2Row, sample2Col);
        
    elseif WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then

        if (classID == 7) and (specID == 263) then
            sample1Col = 2; --stormstrike is better than dual weild
        end

        if (classID == 9) and (specID == 302) then
            sample1Row = 4; -- siphon life better than Contagion ?
        end

        if (classID == 2) and (specID == 381) then
            sample1Row = 5; -- paladin ret vengeance
        end

        sample1 = Util.GetTalentData(classID, specID, sample1Row, sample1Col);
        sample2 = Util.GetTalentData(classID, specID, sample2Row, sample2Col);

    end

    table.insert(sampleTalents, sample1);
    table.insert(sampleTalents, sample2);

    return sampleTalents;
end


function Util.GetTalentDataByID(id)
    for k, v in ipairs(addon.TALENT_DATA) do
        if v[1] == id then
            return v;
        end
    end
end

function Util.GetTalentData(classID, tabID, row, col)
    for k, v in ipairs(addon.TALENT_DATA) do
        if (v[6] == classID) and (v[5] == tabID) and (v[2] == row) and (v[4] == col) then
            return v;
        end
    end
end

function Util.GetSpecializations()
    local ret = {};
    for tabIndex = 1, 3 do
        local id, name, description, icon, _, _, pointsSpent, background, previewPointsSpent, isUnlocked = C_SpecializationInfo.GetSpecializationInfo(tabIndex, false, false, nil, nil, 1);
        table.insert(ret, {
            id = id,
            name = name,
            icon = icon,
            background = background,
        })
    end
    return ret;
end

function Util.GetSpecializationInfo()

    local specInfo = {
        tabData = {},
        spec1 = {},
        spec2 = {},
    };
    
    local spec1Icon, spec2Icon;

    local inspect, isPet = false, false;

    local points = 0;
    for tabIndex = 1, 3 do
        local id, name, description, icon, _, _, pointsSpent, background, previewPointsSpent, isUnlocked = C_SpecializationInfo.GetSpecializationInfo(tabIndex, inspect, isPet, nil, nil, 1);
        if (pointsSpent > points) then
            points = pointsSpent;
            spec1Icon = icon;
        end

        specInfo.tabData[tabIndex] = {

        }
    end

    local points = 0;
    for tabIndex = 1, 3 do
        local id, name, description, icon, _, _, pointsSpent, background, previewPointsSpent, isUnlocked = C_SpecializationInfo.GetSpecializationInfo(tabIndex, inspect, isPet, nil, nil, 2);
        if (pointsSpent > points) then
            points = pointsSpent;
            spec2Icon = icon;
        end
        self.talentTreesParent.spec2.icon:SetTexture(spec2Icon)
    end

    if ( TalentUIUtil.IsSpecActive("spec1") ) then
        FancyPanelsPortrait:SetTexture(spec1Icon);
    else
        FancyPanelsPortrait:SetTexture(spec2Icon);
    end

end

function Util.GetAtlas(file, atlas)
    if addon.Constants.Atlas[file] and addon.Constants.Atlas[file][atlas] then
        return addon.Constants.Atlas[file][atlas];
    end
end

function Util.ApplyAtlas(texture, atlasFile, atlasName)
    if addon.Constants.Atlas[atlasFile] and addon.Constants.Atlas[atlasFile][atlasName] then
        local atlas = addon.Constants.Atlas[atlasFile][atlasName];
        texture:SetTexCoord(atlas[1], atlas[2], atlas[3], atlas[4])

        --print("ApplyAtlas", atlasFile, atlasName)
    end
end

function Util.GetClassSpells(classID)
    local ret = {};
    for k, v in ipairs(addon.SPELL_DATA) do
        if (v.classID == classID) then
            table.insert(ret, v.spellID);
        end
    end
    return ret;
end




function Util.TrimNumber(num)
    if type(num) == 'number' then
        local trimmed = string.format("%.1f", num)
        return tonumber(trimmed)
    else
        return 1
    end
end

function Util.PrepareIconPicker(iconPicker)
    IconSelectorPopupFrameTemplateMixin.OnShow(iconPicker);

    iconPicker.BorderBox.EditBoxHeaderText:SetText(GEARSETS_POPUP_TEXT);

    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
    iconPicker.BorderBox.IconSelectorEditBox:SetFocus();
    iconPicker.iconDataProvider = CreateAndInitFromMixin(IconDataProviderMixin);
    iconPicker:SetIconFilter(IconSelectorPopupFrameIconFilterTypes.All);
    Util.IconPicker_Update(iconPicker)
    iconPicker.BorderBox.IconSelectorEditBox:OnTextChanged();

    local function OnIconSelected(_selectionIndex, icon)
        iconPicker.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(icon);

        -- Index is not yet set, but we know if an icon in IconSelector was selected it was in the list, so set directly.
        iconPicker.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(ICON_SELECTION_CLICK);
        iconPicker.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetFontObject(GameFontHighlightSmall);
    end
    iconPicker.IconSelector:SetSelectedCallback(OnIconSelected);
end

function Util.IconPicker_Update(frame)
    if frame.mode == IconSelectorPopupFrameModes.New then
        frame.BorderBox.IconSelectorEditBox:SetText("");

        local initialIndex = 1;
        frame.IconSelector:SetSelectedIndex(initialIndex);
        frame.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(frame:GetIconByIndex(initialIndex));
    elseif frame.mode == IconSelectorPopupFrameModes.Edit and frame.outfitData then
        frame.BorderBox.IconSelectorEditBox:SetText(frame.outfitData.name);
        frame.BorderBox.IconSelectorEditBox:HighlightText();

        frame.IconSelector:SetSelectedIndex(frame:GetIndexOfIcon(frame.outfitData.icon));
        frame.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(frame.outfitData.icon);
    end

    local getSelection = GenerateClosure(frame.GetIconByIndex, frame);
    local getNumSelections = GenerateClosure(frame.GetNumIcons, frame);
    frame.IconSelector:SetSelectionsDataProvider(getSelection, getNumSelections);
    frame.IconSelector:ScrollToSelectedIndex();

    frame:SetSelectedIconText();
end




local spellSchools = {
    [2] = 'Holy',
    [3] = 'Fire',
    [4] = 'Nature',
    [5] = 'Frost',
    [6] = 'Shadow',
    [7] = 'Arcane',
}
local statIDs = {
    [1] = 'Strength',
    [2] = 'Agility',
    [3] = 'Stamina',
    [4] = 'Intellect',
    [5] = 'Spirit',
}
function Util.GetPaperDollStats()

    --[[
        the sub table keys (melee[this key]) should be capitalised as they are used in a locale lookup
    ]]
    local stats = {
        attributes = {},
        defence = {},
        melee = {},
        ranged = {},
        spell = {},
    }

    local numSkills = GetNumSkillLines();
    local skillIndex = 0;
    local currentHeader = nil;

    for i = 1, numSkills do
        local skillName = select(1, GetSkillLineInfo(i));
        local isHeader = select(2, GetSkillLineInfo(i));

        if isHeader ~= nil and isHeader then
            currentHeader = skillName;
        else
            if (currentHeader == "Weapon Skills" and skillName == 'Defense') then
                skillIndex = i;
                break;
            end
        end
    end

    -- local baseDef, modDef;
    -- if (skillIndex > 0) then
    --     baseDef = select(4, GetSkillLineInfo(skillIndex));
    --     modDef = select(6, GetSkillLineInfo(skillIndex));
    -- else
    --     baseDef, modDef = UnitDefense('player')
    -- end

    -- local posBuff = 0;
    -- local negBuff = 0;
    -- if ( modDef > 0 ) then
    --     posBuff = modDef;
    -- elseif ( modDef < 0 ) then
    --     negBuff = modDef;
    -- end
    -- stats.defence.defence = {
    --     base = Util.TrimNumber(baseDef),
    --     mod = Util.TrimNumber(modDef),
    -- }


    local baseDef, modDef = UnitDefense('player')
    stats.defence.Defence = (baseDef + modDef)

    local baseArmor, effectiveArmor, armr, posBuff, negBuff = UnitArmor('player');
    stats.defence.Armor = Util.TrimNumber(baseArmor)
    stats.defence.Block = Util.TrimNumber(GetBlockChance());
    stats.defence.Parry = Util.TrimNumber(GetParryChance());
    stats.defence.ShieldBlock = Util.TrimNumber(GetShieldBlock());
    stats.defence.Dodge = Util.TrimNumber(GetDodgeChance());

    -- stats.defence.tooltips = {

    -- }

    --local expertise, offhandExpertise, rangedExpertise = GetExpertise();
    --local base, casting = GetManaRegen();
    stats.spell.SpellHit = 0 -- Util.TrimNumber(GetCombatRatingBonus(CR_HIT_SPELL) + GetSpellHitModifier());
    stats.melee.MeleeHit = 0 --Util.TrimNumber(GetCombatRatingBonus(CR_HIT_MELEE) + GetHitModifier());
    stats.ranged.RangedHit = 0 -- Util.TrimNumber(GetCombatRatingBonus(CR_HIT_RANGED));

    stats.ranged.RangedCrit = Util.TrimNumber(GetRangedCritChance());
    stats.melee.MeleeCrit = Util.TrimNumber(GetCritChance());

    stats.spell.Haste = Util.TrimNumber(GetHaste());
    stats.melee.Haste = Util.TrimNumber(GetMeleeHaste());
    stats.ranged.Haste = Util.TrimNumber(GetRangedHaste());

    local base, casting = GetManaRegen()
    stats.spell.Mana = base and Util.TrimNumber(base*5) or 0;
    stats.spell.ManaCombat = casting and Util.TrimNumber(casting*5) or 0;

    local maxCrit, critSchool = 0, "-";
    local maxDamage, dmgSchool = 0, "-";

    stats.spell.tooltips = {
        damage = {},
        crit = {},
    }

    for id, school in pairs(spellSchools) do

        local spellDamage = GetSpellBonusDamage(id)
        if spellDamage > maxDamage then
            maxDamage = spellDamage
            dmgSchool = spellSchools[id]
        end
        local spellCrit = GetSpellCritChance(id)
        if spellCrit > maxCrit then
            maxCrit = spellCrit
            critSchool = spellSchools[id]
        end

        table.insert(stats.spell.tooltips.damage, {
            name = spellSchools[id],
            val = Util.TrimNumber(spellDamage)
        })
        table.insert(stats.spell.tooltips.crit, {
            name = spellSchools[id],
            val = Util.TrimNumber(spellCrit)
        })

    end
    stats.spell.SpellCrit = Util.TrimNumber(maxCrit)
    stats.spell.SpellCritSchool = critSchool
    stats.spell.SpellDamage = Util.TrimNumber(maxDamage)
    stats.spell.SpellDamageSchool  = dmgSchool

    stats.spell.HealingBonus = Util.TrimNumber(GetSpellBonusHealing());

    local lowDmg, hiDmg, offlowDmg, offhiDmg, posBuff, negBuff, percentmod = UnitDamage("player");
    local mainSpeed, offSpeed = UnitAttackSpeed("player");
    local mlow = (lowDmg + posBuff + negBuff) * percentmod
    local mhigh = (hiDmg + posBuff + negBuff) * percentmod
    local olow = (offlowDmg + posBuff + negBuff) * percentmod
    local ohigh = (offhiDmg + posBuff + negBuff) * percentmod
    if mainSpeed < 1 then mainSpeed = 1 end
    if mlow < 1 then mlow = 1 end
    if mhigh < 1 then mhigh = 1 end
    if olow < 1 then olow = 1 end
    if ohigh < 1 then ohigh = 1 end

    if offSpeed then
        if offSpeed < 1 then 
            offSpeed = 1
        end
        stats.melee.MeleeDmgOH = Util.TrimNumber((olow + ohigh) / 2.0)
        stats.melee.MeleeDpsOH = Util.TrimNumber(((olow + ohigh) / 2.0) / offSpeed)
    else
        --offSpeed = 1
        stats.melee.MeleeDmgOH = Util.TrimNumber(0)
        stats.melee.MeleeDpsOH = Util.TrimNumber(0)
    end
    stats.melee.MeleeDmgMH = Util.TrimNumber((mlow + mhigh) / 2.0)
    stats.melee.MeleeDpsMH = Util.TrimNumber(((mlow + mhigh) / 2.0) / mainSpeed)

    local speed, lowDmg, hiDmg, posBuff, negBuff, percent = UnitRangedDamage("player");
    local low = (lowDmg + posBuff + negBuff) * percent
    local high = (hiDmg + posBuff + negBuff) * percent
    if speed < 1 then speed = 1 end
    if low < 1 then low = 1 end
    if high < 1 then high = 1 end
    local dmg = (low + high) / 2.0
    stats.ranged.RangedDmg = Util.TrimNumber(dmg)
    stats.ranged.RangedDps = Util.TrimNumber(dmg/speed)

    local base, posBuff, negBuff = UnitAttackPower('player')
    stats.melee.AttackPower = Util.TrimNumber(base + posBuff + negBuff)

    for k, stat in ipairs(statIDs) do
        local baseStat, effectiveStat, pos, neg = UnitStat("player", k);
        table.insert(stats.attributes, {
            id = k,
            name = stat,
            val = Util.TrimNumber(baseStat),
        })
    end

    return stats;
end

local resistanceIDs = {
    [0] = "Physical",
    [1] = "Holy",
    [2] = "Fire",
    [3] = "Nature",
    [4] = "Frost",
    [5] = "Shadow",
    [6] = "Arcane",
}
function Util.GetPlayerResistances()
    local res = {}
    for i = 0, 6 do
        local base, total, bonus, minus = UnitResistance("player", i)

        table.insert(res, {
            name = resistanceIDs[i],
            base = base,
            total = total,
            bonus = bonus,
            minus = minus,
        })

    end
    return res;
end





















addon.Util = Util;