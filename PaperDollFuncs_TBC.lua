

local addonName, addon = ...;

local DefaultEvents = {
	"PLAYER_ENTERING_WORLD",
	"UNIT_MODEL_CHANGED",
	"UNIT_LEVEL",
	"UNIT_RESISTANCES",
	"UNIT_STATS",
	"UNIT_AURA",
	"UNIT_MAXHEALTH",
	"UNIT_DAMAGE",
	"UNIT_RANGEDDAMAGE",
	"PLAYER_DAMAGE_DONE_MODS",
	"UNIT_ATTACK_SPEED",
	"UNIT_ATTACK_POWER",
	"UNIT_RANGED_ATTACK_POWER",
	"UNIT_ATTACK",
	"SKILL_LINES_CHANGED",
	"COMBAT_RATING_UPDATE",
}

local DIVIDER_FADE = CreateColor(0.5,0.5,0.5,0.05)

local function CreateStatFrame(statName)

    local f = CreateFrame("Frame", string.format("%sCharacterStats_%s", addonName, statName));
    for _, event in ipairs(DefaultEvents) do
        f:RegisterEvent(event);
    end

    f:SetScript("OnLeave", function()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    end);

    f:EnableMouse(true);
    f:SetHeight(22);

    f.label = f:CreateFontString(string.format("%sLabel", f:GetName()), "OVERLAY", "GameFontNormal");
    f.label:SetPoint("LEFT");
    f.label:SetJustifyH("LEFT");

    f.statText = f:CreateFontString(string.format("%sStatText", f:GetName()), "OVERLAY", "GameFontWhite");
    f.statText:SetPoint("RIGHT");
    f.statText:SetJustifyH("RIGHT");

    f.divider = f:CreateTexture(nil, "OVERLAY");
    f.divider:SetColorTexture(1,1,1)
    f.divider:SetGradient("HORIZONTAL", GRAY_FONT_COLOR, DIVIDER_FADE);
    f.divider:SetPoint("BOTTOMLEFT");
    f.divider:SetPoint("BOTTOMRIGHT");
    f.divider:SetHeight(1);

    return f;

end

local MeleeFunc = {
    PaperDollFrame_SetDamage,
    PaperDollFrame_SetAttackSpeed,
    PaperDollFrame_SetAttackPower,
    PaperDollFrame_SetRating,
    PaperDollFrame_SetMeleeCritChance,
    PaperDollFrame_SetExpertise,
};

local RangedFunc = {
    PaperDollFrame_SetRangedDamage,
    PaperDollFrame_SetRangedAttackSpeed,
    PaperDollFrame_SetRangedAttackPower,
    PaperDollFrame_SetRating,
    PaperDollFrame_SetRangedCritChance,
};

local SpellFunc = {
    PaperDollFrame_SetSpellBonusDamage;
    PaperDollFrame_SetSpellBonusHealing;
    PaperDollFrame_SetRating;
    PaperDollFrame_SetSpellCritChance;
    PaperDollFrame_SetSpellHaste;
    PaperDollFrame_SetManaRegen;
};

local DefenceFunc = {
    PaperDollFrame_SetArmor;
    PaperDollFrame_SetDefense;
    PaperDollFrame_SetDodge;
    PaperDollFrame_SetParry;
    PaperDollFrame_SetBlock;
    PaperDollFrame_SetResilience;
}

function FancyPanelCharacterFrame_UpdateResistances(frame)
    local resistance;
    local positive;
    local negative;
    local resistanceLevel;
    local base;
    local text = frame.statText;
    
    base, resistance, positive, negative = UnitResistance("player", frame:GetID());
    local petBonus = ComputePetBonus( "PET_BONUS_RES", resistance );

    local resistanceName = getglobal("RESISTANCE" .. (frame:GetID()) .. "_NAME");
    frame.label:SetText(resistanceName);
    frame.tooltip = resistanceName.." "..resistance;

    -- resistances can now be negative. Show Red if negative, Green if positive, white otherwise
    if( abs(negative) > positive ) then
        text:SetText(RED_FONT_COLOR_CODE..resistance..FONT_COLOR_CODE_CLOSE);
    elseif( abs(negative) == positive ) then
        text:SetText(resistance);
    else
        text:SetText(GREEN_FONT_COLOR_CODE..resistance..FONT_COLOR_CODE_CLOSE);
    end

    if ( positive ~= 0 or negative ~= 0 ) then
        -- Otherwise build up the formula
        frame.tooltip = frame.tooltip.. " ( "..HIGHLIGHT_FONT_COLOR_CODE..base;
        if( positive > 0 ) then
            frame.tooltip = frame.tooltip..GREEN_FONT_COLOR_CODE.." +"..positive;
        end
        if( negative < 0 ) then
            frame.tooltip = frame.tooltip.." "..RED_FONT_COLOR_CODE..negative;
        end
        frame.tooltip = frame.tooltip..FONT_COLOR_CODE_CLOSE.." )";
    end
    local unitLevel = UnitLevel("player");
    unitLevel = max(unitLevel, 20);
    local magicResistanceNumber = resistance/unitLevel;
    if ( magicResistanceNumber > 5 ) then
        resistanceLevel = RESISTANCE_EXCELLENT;
    elseif ( magicResistanceNumber > 3.75 ) then
        resistanceLevel = RESISTANCE_VERYGOOD;
    elseif ( magicResistanceNumber > 2.5 ) then
        resistanceLevel = RESISTANCE_GOOD;
    elseif ( magicResistanceNumber > 1.25 ) then
        resistanceLevel = RESISTANCE_FAIR;
    elseif ( magicResistanceNumber > 0 ) then
        resistanceLevel = RESISTANCE_POOR;
    else
        resistanceLevel = RESISTANCE_NONE;
    end
    frame.tooltipSubtext = format(RESISTANCE_TOOLTIP_SUBTEXT, getglobal("RESISTANCE_TYPE"..frame:GetID()), unitLevel, resistanceLevel);
    
    if( petBonus > 0 ) then
        frame.tooltipSubtext = frame.tooltipSubtext .. "\n" .. format(PET_BONUS_TOOLTIP_RESISTANCE, petBonus);
    end
end

local PlayerStats = {

    BaseStatsIter = function()
        local index, count = 0, 5;
        return function()
            index = index + 1;
            if index > count then
                return nil;
            else
                local f = CreateStatFrame(string.format("BaseStat_%d", index));
                local statIndex = index;
                f:SetScript("OnEvent", function()
                    PaperDollFrame_SetStat(f, statIndex);
                end)
                f:SetScript("OnEnter", PaperDollStatTooltip);
                PaperDollFrame_SetStat(f, statIndex);
                return index, f;
            end
        end
    end,

    MeleeStatsIter = function()
        local index, count = 0, 6;
        return function()
            index = index + 1;
            if index > count then
                return;
            else
                local f = CreateStatFrame(string.format("MeleeStat_%d", index));
                local statIndex = index;
                if index == 1 then
                    f:SetScript("OnEnter", CharacterDamageFrame_OnEnter)
                else
                    f:SetScript("OnEnter", PaperDollStatTooltip)
                end
                if (index == 4) then
                    f:SetScript("OnEvent", function()
                        MeleeFunc[statIndex](f, CR_HIT_MELEE)
                    end)
                    MeleeFunc[statIndex](f, CR_HIT_MELEE)
                else
                    f:SetScript("OnEvent", function()
                        MeleeFunc[statIndex](f)
                    end)
                    MeleeFunc[statIndex](f)
                end
                return index, f;
            end
        end
    end,

    RangedStatsIter = function()
        local index, count = 0, 5;
        return function()
            index = index + 1;
            if (index > count) then
                return;
            else
                local f = CreateStatFrame(string.format("RangedStat_%d", index));
                local statIndex = index;
                if index == 1 then
                    f:SetScript("OnEnter", CharacterRangedDamageFrame_OnEnter)
                else
                    f:SetScript("OnEnter", PaperDollStatTooltip)
                end
                if (index == 4) then
                    f:SetScript("OnEvent", function()
                        RangedFunc[statIndex](f, CR_HIT_RANGED)
                    end)
                    RangedFunc[statIndex](f, CR_HIT_RANGED)
                else
                    f:SetScript("OnEvent", function()
                        RangedFunc[statIndex](f)
                    end)
                    RangedFunc[statIndex](f)
                end
                return index, f;
            end
        end
    end,

    SpellStatsIter = function()
        local index, count = 0, 6;
        return function()
            index = index + 1;
            if (index > count) then
                return;
            else
                local f = CreateStatFrame(string.format("SpellStat_%d", index));
                local statIndex = index;
                if index == 1 then
                    f:SetScript("OnEnter", CharacterSpellBonusDamage_OnEnter)
                elseif index == 4 then
                    f:SetScript("OnEnter", CharacterSpellCritChance_OnEnter)
                else
                    f:SetScript("OnEnter", PaperDollStatTooltip)
                end
                if (index == 3) then
                    f:SetScript("OnEvent", function()
                        SpellFunc[statIndex](f, CR_HIT_SPELL)
                    end)
                    SpellFunc[statIndex](f, CR_HIT_SPELL)
                else
                    f:SetScript("OnEvent", function()
                        SpellFunc[statIndex](f)
                    end)
                    SpellFunc[statIndex](f)
                end
                return index, f;
            end
        end
    end,

    DefenceStatsIter = function()
        local index, count = 0, 6;
        return function()
            index = index + 1;
            if index > count then
                return
            else
                local f = CreateStatFrame(string.format("DefenceStat_%d", index));
                local statIndex = index;
                f:SetScript("OnEvent", function()
                    DefenceFunc[statIndex](f)
                end)
                f:SetScript("OnEnter", PaperDollStatTooltip);
                DefenceFunc[statIndex](f)
                return index, f;
            end
        end
    end,

    ResistanceStatsIter = function()
        local index, count = 0, 6;
        return function()
            index = index + 1;
            if index > count then
                return
            else
                local f = CreateStatFrame(string.format("ResistanceStat_%d", index));
                f:SetID(index);
                f:SetScript("OnEvent", function()
                    FancyPanelCharacterFrame_UpdateResistances(f)
                end)
                f:SetScript("OnEnter", PaperDollStatTooltip);
                FancyPanelCharacterFrame_UpdateResistances(f)
                return index, f;
            end
        end
    end,
}



addon.PlayerStats = PlayerStats;