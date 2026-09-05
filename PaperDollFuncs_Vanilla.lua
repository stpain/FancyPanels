--[[

    © 2026 Sam Pain. All Rights Reserved.
    
    No part of this work may be reproduced 
    without the prior written permission 
    of the author.

]]

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

local prefix = "FancyPanelsCharacterStats";

local function CreateStatFrame(statName)

    local f = CreateFrame("Frame", string.format("%s_%s", prefix, statName));
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

    --print(f:GetName(), f.statText:GetName());

    return f;

end


--[[
    Blizzard changed the way stats work and get shown between vanilla and TBC
    the addon was first coded using the TBC system which was a massive improvement

    For vanilla I've had to essentially copy and tweek the functions to accept a
    frame like the TBC versions do
]]

local function FancyPanelsCharacterFrame_SetAttackBothHands(frame)
	
    --frame.label:SetText(MELEE_ATTACK);
    frame.label:SetText(COMBAT_RATING_NAME1);

    local mainHandAttackBase, mainHandAttackMod, offBase, offMod, rangedBase, rangedMod = UnitAttackBothHands("player")

    local text = frame.statText
    
    if (offBase == 0) then
        if( mainHandAttackMod == 0 ) then
            text:SetText(mainHandAttackBase);
        else
            local color = RED_FONT_COLOR_CODE;
            if( mainHandAttackMod > 0 ) then
                color = GREEN_FONT_COLOR_CODE;
            end
            text:SetText(color..(mainHandAttackBase + mainHandAttackMod)..FONT_COLOR_CODE_CLOSE);
        end
    else
        local displayText = "";
        if( mainHandAttackMod == 0 ) then
            displayText = mainHandAttackBase;
        else
            local color = RED_FONT_COLOR_CODE;
            if( mainHandAttackMod > 0 ) then
                color = GREEN_FONT_COLOR_CODE;
            end
            displayText = (color..(mainHandAttackBase + mainHandAttackMod)..FONT_COLOR_CODE_CLOSE);
        end
        if( offMod == 0 ) then
            displayText = displayText.." / "..offBase;
        else
            local color = RED_FONT_COLOR_CODE;
            if( offMod > 0 ) then
                color = GREEN_FONT_COLOR_CODE;
            end
            displayText = displayText.." / "..(color..(offBase + offMod)..FONT_COLOR_CODE_CLOSE);
        end
        text:SetText(displayText);
    end

	frame.tooltip = ATTACK_TOOLTIP;
	frame.tooltip2 = ATTACK_TOOLTIP_SUBTEXT;
end

local function FancyPanelsCharacterFrame_SetAttackSpeed(frame)
    local unit = "player";
    local speed, offhandSpeed = UnitAttackSpeed(unit);
    speed = format("%.2f", speed);
    if (offhandSpeed) then
        offhandSpeed = format("%.2f", offhandSpeed);
    end
    local text;
    if (offhandSpeed) then
        text = speed .. " / " .. offhandSpeed;
    else
        text = speed;
    end
    --PaperDollFrame_SetLabelAndText(statFrame, WEAPON_SPEED, text);
    frame.label:SetText(WEAPON_SPEED);
    frame.statText:SetText(text);

    frame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. ATTACK_SPEED .. " " .. text .. FONT_COLOR_CODE_CLOSE;
    --frame.tooltip2 = format(CR_HASTE_RATING_TOOLTIP, GetCombatRating(CR_HASTE_MELEE), GetCombatRatingBonus(CR_HASTE_MELEE));
    frame.tooltip2 = format(CR_HASTE_RATING_TOOLTIP, GetCombatRating(18), GetCombatRatingBonus(18));
end

local function FancyPanelsCharacterFrame_SetDamage(frame)

    local unit = "player";
	local damageText = frame.statText
	local damageFrame = frame

    frame.label:SetText(MELEE_ATTACK)

	local speed, offhandSpeed = UnitAttackSpeed(unit);
	
	local minDamage;
	local maxDamage; 
	local minOffHandDamage;
	local maxOffHandDamage; 
	local physicalBonusPos;
	local physicalBonusNeg;
	local percent;
	minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage(unit);
	local displayMin = max(floor(minDamage),1);
	local displayMax = max(ceil(maxDamage),1);

	if (percent == 0) then
		minDamage = 0;
		maxDamage = 0;
	else
		minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
		maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;
	end

	local baseDamage = (minDamage + maxDamage) * 0.5;
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
	local totalBonus = (fullDamage - baseDamage);
	local damagePerSecond;
	if speed == 0 then
		damagePerSecond = 0;
	else
		damagePerSecond = (max(fullDamage,1) / speed);
	end
	local damageTooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);
	
	local colorPos = "|cff20ff20";
	local colorNeg = "|cffff2020";

	-- epsilon check
	if ( totalBonus < 0.1 and totalBonus > -0.1 ) then
		totalBonus = 0.0;
	end

	if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(displayMin.." - "..displayMax);	
		else
			damageText:SetText(displayMin.."-"..displayMax);
		end
	else
		
		local color;
		if ( totalBonus > 0 ) then
			color = colorPos;
		else
			color = colorNeg;
		end
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(color..displayMin.." - "..displayMax.."|r");	
		else
			damageText:SetText(color..displayMin.."-"..displayMax.."|r");
		end
		if ( physicalBonusPos > 0 ) then
			damageTooltip = damageTooltip..colorPos.." +"..physicalBonusPos.."|r";
		end
		if ( physicalBonusNeg < 0 ) then
			damageTooltip = damageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
		end
		if ( percent > 1 ) then
			damageTooltip = damageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
		elseif ( percent < 1 ) then
			damageTooltip = damageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
		end
		
	end
	damageFrame.damage = damageTooltip;
	damageFrame.attackSpeed = speed;
	damageFrame.dps = damagePerSecond;
	
	-- If there's an offhand speed then add the offhand info to the tooltip
	if ( offhandSpeed ) then
		minOffHandDamage = (minOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;
		maxOffHandDamage = (maxOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;

		local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5;
		local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		local offhandDamagePerSecond;
		if offhandSpeed == 0 then
			offhandDamagePerSecond = 0;
		else
			offhandDamagePerSecond = (max(offhandFullDamage,1) / offhandSpeed);
		end
		local offhandDamageTooltip = max(floor(minOffHandDamage),1).." - "..max(ceil(maxOffHandDamage),1);
		if ( physicalBonusPos > 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." +"..physicalBonusPos.."|r";
		end
		if ( physicalBonusNeg < 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
		end
		if ( percent > 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
		elseif ( percent < 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
		end
		damageFrame.offhandDamage = offhandDamageTooltip;
		damageFrame.offhandAttackSpeed = offhandSpeed;
		damageFrame.offhandDps = offhandDamagePerSecond;
	else
		damageFrame.offhandAttackSpeed = nil;
	end
end

local function FancyPanelsCharacterFrame_SetAttackPower(frame)

    local unit = "player";
	
	local base, posBuff, negBuff = UnitAttackPower(unit);

	local text = frame.statText

    frame.label:SetText(ATTACK_POWER_COLON);

	PaperDollFormatStat(MELEE_ATTACK_POWER, base, posBuff, negBuff, frame, text);
	frame.tooltip2 = format(MELEE_ATTACK_POWER_TOOLTIP, max((base+posBuff+negBuff), 0)/ATTACK_POWER_MAGIC_NUMBER);
end

local function FancyPanelsCharacterFrame_SetMeleeCritChance(frame)
	local critChance = GetCritChance();-- + GetCritChanceFromAgility();
	critChance = format("%.2f%%", critChance);
    frame.statText:SetText(critChance);
    frame.label:SetText(MELEE_CRIT_CHANCE..":");
	frame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..MELEE_CRIT_CHANCE.." "..critChance..FONT_COLOR_CODE_CLOSE;
	frame.tooltip2 = format(CR_CRIT_MELEE_TOOLTIP, GetCombatRating(9), GetCombatRatingBonus(9));
end

local function FancyPanelsCharacterFrame_SetMeleeHitChance(frame)

    --local mainBase, mainMod, offBase, offMod = UnitAttackBothHands("player")

    local hitMod = GetCombatRatingBonus(6) + GetHitModifier()
	hitMod = format("%.2f%%", hitMod);
    frame.statText:SetText(hitMod);
    frame.label:SetText(STAT_HIT_CHANCE..":");
	frame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..STAT_HIT_CHANCE.." "..hitMod..FONT_COLOR_CODE_CLOSE;
	frame.tooltip2 = format(STAT_HIT_MELEE_TOOLTIP, GetCombatRating(9), GetCombatRatingBonus(9));
end










local function FancyPanelsCharacterFrame_SetRangedDamage(frame)

    local unit = "player";
	local damageText = frame.statText
	local damageFrame = frame

    frame.label:SetText(DAMAGE_COLON);

	-- If no ranged attack then set to n/a
	if ( PaperDollFrame.noRanged ) then
		damageText:SetText(NOT_APPLICABLE);
		damageFrame.damage = nil;
		return;
	end

	local rangedAttackSpeed, minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent = UnitRangedDamage(unit);
	local displayMin = max(floor(minDamage),1);
	local displayMax = max(ceil(maxDamage),1);

	minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
	maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;

	local baseDamage = (minDamage + maxDamage) * 0.5;
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
	local totalBonus = (fullDamage - baseDamage);
	local damagePerSecond;
	if (rangedAttackSpeed == 0) then
		-- Egan's Blaster!!!
		damagePerSecond = math.huge;
	else
		damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed);
	end

	local tooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);

	if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(displayMin.." - "..displayMax);	
		else
			damageText:SetText(displayMin.."-"..displayMax);
		end
	else
		local colorPos = "|cff20ff20";
		local colorNeg = "|cffff2020";
		local color;
		if ( totalBonus > 0 ) then
			color = colorPos;
		else
			color = colorNeg;
		end
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
			damageText:SetText(color..displayMin.." - "..displayMax.."|r");	
		else
			damageText:SetText(color..displayMin.."-"..displayMax.."|r");
		end
		if ( physicalBonusPos > 0 ) then
			tooltip = tooltip..colorPos.." +"..physicalBonusPos.."|r";
		end
		if ( physicalBonusNeg < 0 ) then
			tooltip = tooltip..colorNeg.." "..physicalBonusNeg.."|r";
		end
		if ( percent > 1 ) then
			tooltip = tooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
		elseif ( percent < 1 ) then
			tooltip = tooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
		end
		damageFrame.tooltip = tooltip.." "..format(DPS_TEMPLATE, damagePerSecond);
	end
	damageFrame.attackSpeed = rangedAttackSpeed;
	damageFrame.damage = tooltip;
	damageFrame.dps = damagePerSecond;
end

local function FancyPanelsCharacterFrame_SetRangedAttackPower(frame)
	if ( not unit ) then
		unit = "player";
	elseif ( unit == "pet" ) then
		return;
	end
	if ( not prefix ) then
		prefix = "Character";
	end
	
    local text = frame.statText;
    frame.label:SetText(ATTACK_POWER_COLON);
	
	-- If no ranged attack then set to n/a
	if ( PaperDollFrame.noRanged ) then
		text:SetText(NOT_APPLICABLE);
		frame.tooltip = nil;
		return;
	end
	if ( HasWandEquipped() ) then
		text:SetText("--");
		frame.tooltip = nil;
		return;
	end

	local base, posBuff, negBuff = UnitRangedAttackPower(unit);
	PaperDollFormatStat(RANGED_ATTACK_POWER, base, posBuff, negBuff, frame, text);
	frame.tooltip2 = format(RANGED_ATTACK_POWER_TOOLTIP, base/ATTACK_POWER_MAGIC_NUMBER);
end

local function FancyPanelCharacterFrame_SetRangedAttackSpeed(frame)
    local unit = "player";
    local rangedAttackSpeed, minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent = UnitRangedDamage(unit);
    frame.statText:SetText(string.format("%0.2f",rangedAttackSpeed));
    frame.label:SetText(ATTACK_SPEED);
end

local function FancyPanelsCharacterFrame_SetRangedAttack(frame)
	if ( not unit ) then
		unit = "player";
	elseif ( unit == "pet" ) then
		return;
	end
	if ( not prefix ) then
		prefix = "Character";
	end

    frame.label:SetText(RANGED_ATTACK);

	local hasRelic = UnitHasRelicSlot(unit);

	local rangedAttackBase, rangedAttackMod = UnitRangedAttack(unit);
	local text = frame.statText;

	-- If no ranged texture then set stats to n/a
	local rangedTexture = GetInventoryItemTexture("player", 18);
	local oldValue = PaperDollFrame.noRanged;
	if ( rangedTexture and not hasRelic ) then
		PaperDollFrame.noRanged = nil;
	else
		text:SetText(NOT_APPLICABLE);
		PaperDollFrame.noRanged = 1;
		frame.tooltip = nil;
	end
	if ( not rangedTexture or hasRelic ) then
		return;
	end
	
	if( rangedAttackMod == 0 ) then
		text:SetText(rangedAttackBase);
	else
		local color = RED_FONT_COLOR_CODE;
		if( rangedAttackMod > 0 ) then
			color = GREEN_FONT_COLOR_CODE;
		end
		text:SetText(color..(rangedAttackBase + rangedAttackMod)..FONT_COLOR_CODE_CLOSE);
	end

	frame.tooltip = RANGED_ATTACK_TOOLTIP;
	frame.tooltip2 = ATTACK_TOOLTIP_SUBTEXT;
end








local function FancyPanelsCharacterFrame_SetArmor(statFrame, unit)
	if ( not unit ) then
		unit = "player";
	end
	local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor(unit);
	statFrame.label:SetText(ARMOR_COLON);
	local text = statFrame.statText;

	PaperDollFormatStat(ARMOR, base, posBuff, negBuff, statFrame, text);
	local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitLevel(unit));
	local armorReductionText = format("%.2f", armorReduction);
	statFrame.tooltip2 = format(DEFAULT_STATARMOR_TOOLTIP, armorReductionText);
	
	-- if ( unit == "player" ) then
	-- 	local petBonus = ComputePetBonus("PET_BONUS_ARMOR", effectiveArmor );
	-- 	if( petBonus > 0 ) then
	-- 		statFrame.tooltip2 = statFrame.tooltip2 .. "\n" .. format(PET_BONUS_TOOLTIP_ARMOR, petBonus);
	-- 	end
	-- end
end

local function FancyPanelsCharacterFrame_SetDefense(statFrame, unit)
	if ( not unit ) then
		unit = "player";
	end
	if ( not prefix ) then
		prefix = "Character";
	end
	local base, modifier = UnitDefense(unit);
    statFrame.label:SetText(DEFENSE);
	local text = statFrame.statText;
	
	local posBuff = 0;
	local negBuff = 0;
	if ( modifier > 0 ) then
		posBuff = modifier;
	elseif ( modifier < 0 ) then
		negBuff = modifier;
	end
	PaperDollFormatStat(DEFENSE_COLON, base, posBuff, negBuff, statFrame, text);
end

local function FancyPanelsCharacterFrame_SetDodge(statFrame)
    local CR_DODGE = 3;
	local chance = GetDodgeChance();
    statFrame.label:SetText(STAT_DODGE);
    statFrame.statText:SetText(string.format("%0.2f",chance));
	--PaperDollFrame_SetLabelAndText(statFrame, STAT_DODGE, chance, 1);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..getglobal("DODGE_CHANCE").." "..string.format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE));
end

local function FancyPanelsCharacterFrame_SetBlock(statFrame)
    local CR_BLOCK = 5;
	local chance = GetBlockChance();
    statFrame.label:SetText(STAT_BLOCK);
    statFrame.statText:SetText(string.format("%0.2f",chance));
	--PaperDollFrame_SetLabelAndText(statFrame, STAT_BLOCK, chance, 1);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..getglobal("BLOCK_CHANCE").." "..string.format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(CR_BLOCK_TOOLTIP, GetCombatRating(CR_BLOCK), GetCombatRatingBonus(CR_BLOCK), GetShieldBlock());
end

local function FancyPanelsCharacterFrame_SetParry(statFrame)
    local CR_PARRY = 4;
	local chance = GetParryChance();
    statFrame.label:SetText(STAT_PARRY);
    statFrame.statText:SetText(string.format("%0.2f",chance));
	--PaperDollFrame_SetLabelAndText(statFrame, STAT_PARRY, chance, 1);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..getglobal("PARRY_CHANCE").." "..string.format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(CR_PARRY_TOOLTIP, GetCombatRating(CR_PARRY), GetCombatRatingBonus(CR_PARRY));
end

-- function GetDodgeBlockParryChanceFromDefense()
-- 	local base, modifier = UnitDefense("player");
-- 	--local defensePercent = DODGE_PARRY_BLOCK_PERCENT_PER_DEFENSE * modifier;
-- 	local defensePercent = DODGE_PARRY_BLOCK_PERCENT_PER_DEFENSE * ((base + modifier) - (UnitLevel("player")*5));
-- 	defensePercent = max(defensePercent, 0);
-- 	return defensePercent;
-- end




local MAX_SPELL_SCHOOLS = 7;
local function FancyPanelsCharacterFrame_SetSpellBonusDamage(statFrame)
	getglobal(statFrame:GetName().."Label"):SetText(BONUS_DAMAGE..":");
	local text = getglobal(statFrame:GetName().."StatText");
	local holySchool = 2;
	-- Start at 2 to skip physical damage
	local minModifier = GetSpellBonusDamage(holySchool);
	statFrame.bonusDamage = {};
	statFrame.bonusDamage[holySchool] = minModifier;
	local bonusDamage;
	for i=(holySchool+1), MAX_SPELL_SCHOOLS do
		bonusDamage = GetSpellBonusDamage(i);
		minModifier = min(minModifier, bonusDamage);
		statFrame.bonusDamage[i] = bonusDamage;
	end
	text:SetText(minModifier);
	statFrame.minModifier = minModifier;
end

local function FancyPanelsCharacterFrame_SetSpellBonusHealing(statFrame)
	getglobal(statFrame:GetName().."Label"):SetText(BONUS_HEALING..":");
	local text = getglobal(statFrame:GetName().."StatText");
	local bonusHealing = GetSpellBonusHealing();
	text:SetText(bonusHealing);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. BONUS_HEALING .. FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 =format(BONUS_HEALING_TOOLTIP, bonusHealing);
end

local function FancyPanelsCharacterFrame_SetSpellCritChance(statFrame)
	getglobal(statFrame:GetName().."Label"):SetText(SPELL_CRIT_CHANCE..":");
	local text = getglobal(statFrame:GetName().."StatText");
	local holySchool = 2;
	-- Start at 2 to skip physical damage
	local minCrit = GetSpellCritChance(holySchool);
	statFrame.spellCrit = {};
	statFrame.spellCrit[holySchool] = minCrit;
	local spellCrit;
	for i=(holySchool+1), MAX_SPELL_SCHOOLS do
		spellCrit = GetSpellCritChance(i);
		minCrit = min(minCrit, spellCrit);
		statFrame.spellCrit[i] = spellCrit;
	end
	-- Add agility contribution
	--minCrit = minCrit + GetSpellCritChanceFromIntellect();
	minCrit = format("%.2f%%", minCrit);
	text:SetText(minCrit);
	statFrame.minCrit = minCrit;
end

local function FancyPanelsCharacterFrame_SetManaRegen(statFrame)
	getglobal(statFrame:GetName().."Label"):SetText(MANA_REGEN..":");
	local text = getglobal(statFrame:GetName().."StatText");
	if ( not UnitHasMana("player") ) then
		text:SetText(NOT_APPLICABLE);
		statFrame.tooltip = nil;
		return;
	end
	
	local base, casting = GetManaRegen();
	-- All mana regen stats are displayed as mana/5 sec.
	base = floor( base * 5.0 );
	casting = floor( casting * 5.0 );
	text:SetText(base);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. MANA_REGEN .. FONT_COLOR_CODE_CLOSE;
	statFrame.tooltip2 = format(MANA_REGEN_TOOLTIP, base, casting);
end






local MeleeFunc = {
    FancyPanelsCharacterFrame_SetAttackBothHands,
    FancyPanelsCharacterFrame_SetAttackPower,
    FancyPanelsCharacterFrame_SetDamage,
    FancyPanelsCharacterFrame_SetAttackSpeed,
    FancyPanelsCharacterFrame_SetMeleeHitChance,
    FancyPanelsCharacterFrame_SetMeleeCritChance,
    --PaperDollFrame_SetAttackPower,
    --PaperDollFrame_SetRating,
    --PaperDollFrame_SetMeleeCritChance,
    --PaperDollFrame_SetExpertise,
};

local RangedFunc = {
    FancyPanelsCharacterFrame_SetRangedAttack,
    FancyPanelsCharacterFrame_SetRangedAttackPower,
    FancyPanelsCharacterFrame_SetRangedDamage,
    FancyPanelCharacterFrame_SetRangedAttackSpeed,
    --PaperDollFrame_SetRating,
    --PaperDollFrame_SetRangedCritChance,
};

local SpellFunc = {
    FancyPanelsCharacterFrame_SetSpellBonusDamage;
    FancyPanelsCharacterFrame_SetSpellBonusHealing;
    --PaperDollFrame_SetRating;
    FancyPanelsCharacterFrame_SetSpellCritChance;
    --PaperDollFrame_SetSpellHaste;
    FancyPanelsCharacterFrame_SetManaRegen;
};

local DefenceFunc = {
    FancyPanelsCharacterFrame_SetArmor;
    FancyPanelsCharacterFrame_SetDefense;
    FancyPanelsCharacterFrame_SetDodge;
    FancyPanelsCharacterFrame_SetParry;
    FancyPanelsCharacterFrame_SetBlock;
    --PaperDollFrame_SetResilience;
}

function FancyPanelCharacterFrame_UpdateResistances(frame)
    local resistance;
    local positive;
    local negative;
    local resistanceLevel;
    local base;
    local text = frame.statText;
    local petBonus = 0;
    base, resistance, positive, negative = UnitResistance("player", frame:GetID());
    if (WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC) then
        petBonus = ComputePetBonus( "PET_BONUS_RES", resistance );
    end

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

function FancyPanelsCharacterFrame_SetPrimaryStats(frame, i, statName)
	--for i=1, NUM_STATS, 1 do
		local text = frame.statText;
		local stat;
		local effectiveStat;
		local posBuff;
		local negBuff;
		stat, effectiveStat, posBuff, negBuff = UnitStat("player", i);
		
		-- Set the tooltip text
		local tooltipText = HIGHLIGHT_FONT_COLOR_CODE.._G["SPELL_STAT"..i.."_NAME"].." ";

        frame.stat = statName;
        frame.label:SetText(_G[string.format("SPELL_STAT%d_NAME", i)])

		-- Get class specific tooltip for that stat
		local temp, classFileName = UnitClass("player");
		local classStatText = _G[strupper(classFileName).."_"..frame.stat.."_".."TOOLTIP"];
		-- If can't find one use the default
		if ( not classStatText ) then
			classStatText = _G["DEFAULT".."_"..frame.stat.."_".."TOOLTIP"];
		end

		if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
			text:SetText(effectiveStat);
			frame.tooltip = tooltipText..effectiveStat..FONT_COLOR_CODE_CLOSE;
			frame.tooltip2 = classStatText;
		else 
			tooltipText = tooltipText..effectiveStat;
			if ( posBuff > 0 or negBuff < 0 ) then
				tooltipText = tooltipText.." ("..(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
			end
			if ( posBuff > 0 ) then
				tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..posBuff..FONT_COLOR_CODE_CLOSE;
			end
			if ( negBuff < 0 ) then
				tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..negBuff..FONT_COLOR_CODE_CLOSE;
			end
			if ( posBuff > 0 or negBuff < 0 ) then
				tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
			end
			frame.tooltip = tooltipText;
			frame.tooltip2= classStatText;

			-- If there are any negative buffs then show the main number in red even if there are
			-- positive buffs. Otherwise show in green.
			if ( negBuff < 0 ) then
				text:SetText(RED_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE);
			else
				text:SetText(GREEN_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE);
			end
		end
	--end
end







local PlayerStats = {

    BaseStatsIter = function()

        local stats = {
            "STRENGTH",
            "AGILITY",
            "STAMINA",
            "INTELLECT",
            "SPIRIT",
        }

        local index, count = 0, 5;
        return function()
            index = index + 1;
            if index > count then
                return nil;
            else
                local f = CreateStatFrame(stats[index]);
                local statIndex = index;
                f:SetScript("OnEvent", function()
                    --PaperDollFrame_SetStat(f, statIndex);
                    FancyPanelsCharacterFrame_SetPrimaryStats(f, statIndex, stats[statIndex]);
                end)
                f:SetScript("OnEnter", PaperDollStatTooltip);
                --PaperDollFrame_SetStat(f, statIndex);
                FancyPanelsCharacterFrame_SetPrimaryStats(f, statIndex, stats[statIndex]);
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
                local f = CreateStatFrame("DamageFrame");
                local statIndex = index;


                if index == 3 then
                    f:SetScript("OnEnter", CharacterDamageFrame_OnEnter) --_SetDamage func
                else
                    f:SetScript("OnEnter", PaperDollStatTooltip)
                end

                f:SetScript("OnEvent", function()
                    MeleeFunc[statIndex](f);
                end)
                MeleeFunc[statIndex](f);

                return index, f;
            end
        end
    end,

    RangedStatsIter = function()
        local index, count = 0, 4;
        return function()
            index = index + 1;
            if (index > count) then
                return;
            else
                local f = CreateStatFrame(string.format("RangedStat_%d", index));
                local statIndex = index;
                -- if index == 1 then
                --     f:SetScript("OnEnter", CharacterRangedDamageFrame_OnEnter)
                -- else
                --     f:SetScript("OnEnter", PaperDollStatTooltip)
                -- end
                -- if (index == 4) then
                --     f:SetScript("OnEvent", function()
                --         RangedFunc[statIndex](f, CR_HIT_RANGED)
                --     end)
                --     RangedFunc[statIndex](f, CR_HIT_RANGED)
                -- else
                --     f:SetScript("OnEvent", function()
                --         RangedFunc[statIndex](f)
                --     end)
                --     RangedFunc[statIndex](f)
                -- end

                f:SetScript("OnEnter", PaperDollStatTooltip)
                f:SetScript("OnEvent", function()
                    RangedFunc[statIndex](f)
                end)
                RangedFunc[statIndex](f)

                return index, f;
            end
        end
    end,

    SpellStatsIter = function()
        local index, count = 0, 4;
        return function()
            index = index + 1;
            if (index > count) then
                return;
            else
                local f = CreateStatFrame(string.format("SpellStat_%d", index));
                local statIndex = index;
                -- if index == 1 then
                --     f:SetScript("OnEnter", CharacterSpellBonusDamage_OnEnter)
                -- elseif index == 4 then
                --     f:SetScript("OnEnter", CharacterSpellCritChance_OnEnter)
                -- else
                --     f:SetScript("OnEnter", PaperDollStatTooltip)
                -- end
                -- if (index == 3) then
                --     f:SetScript("OnEvent", function()
                --         SpellFunc[statIndex](f, CR_HIT_SPELL)
                --     end)
                --     SpellFunc[statIndex](f, CR_HIT_SPELL)
                -- else
                --     f:SetScript("OnEvent", function()
                --         SpellFunc[statIndex](f)
                --     end)
                --     SpellFunc[statIndex](f)
                -- end

                f:SetScript("OnEnter", PaperDollStatTooltip)
                f:SetScript("OnEvent", function()
                    SpellFunc[statIndex](f)
                end)
                SpellFunc[statIndex](f)

                return index, f;
            end
        end
    end,

    DefenceStatsIter = function()
        local index, count = 0, 5;
        return function()
            index = index + 1;
            if index > count then
                return
            else
                local f = CreateStatFrame(string.format("DefenceStat_%d", index));
                local frameName = f:GetName();
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