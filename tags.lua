local addon, ns = ...
local cfg = ns.cfg

local tags = oUF.Tags

local SVal = function(val)
	if val then
		if (val >= 1e6) then
			return ("%.1fm"):format(val / 1e6)
		elseif (val >= 1e3) then
			return ("%.1fk"):format(val / 1e3)
		else
			return ("%d"):format(val)
		end
	end
end

local function hex(r, g, b)
	if r then
		if (type(r) == "table") then
			if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
		end
		return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
	end
end

tags.Events["drk:perhp"] = 'UNIT_HEALTH UNIT_MAXHEALTH'
tags.Methods["drk:perhp"] = function(u)
	local m = UnitHealthMax(u)
	if(m == 0) then
		return 0
	else
		return ("%s%%"):format(math.floor((UnitHealth(u)/m*100+.05)*10)/10)
	end
end

tags.Events["drk:hp"] = 'UNIT_HEALTH UNIT_MAXHEALTH'
tags.Methods["drk:hp"] = function(u)
	local ddg = _TAGS["drk:DDG"](u)

	if ddg then
		return ddg
	else
		local per = _TAGS["drk:perhp"](u) or 0
		local min, max = UnitHealth(u), UnitHealthMax(u)
		if u == "player" or u == "target" then
			if min~=max then
				return ("|cffffaaaa%s|r/%s | %s"):format(SVal(min), SVal(max), per)
			else
				return ("%s | %s"):format(SVal(max), per)
			end
		else
			return per
		end
	end
end
-- fix for boss bar update
tags.Events["drk:hpboss"] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_TARGETABLE_CHANGED'
tags.Methods["drk:hpboss"] = function(u)
	local ddg = _TAGS["drk:DDG"](u)

	if ddg then
		return ddg
	else
		local per = _TAGS["drk:perhp"](u) or 0
		local min, max = UnitHealth(u), UnitHealthMax(u)
		if u == "player" or u == "target" then
			if min~=max then
				return ("|cffffaaaa%s|r/%s | %s"):format(SVal(min), SVal(max), per)
			else
				return ("%s | %s"):format(SVal(max), per)
			end
		else
			return per
		end
	end
end

tags.Events["drk:nameboss"] = 'UNIT_NAME_UPDATE UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_TARGETABLE_CHANGED'
tags.Methods["drk:nameboss"] = function(u, r)
	return UnitName(r or u)
end
--end fix for boss bar update
tags.Events["drk:raidhp"] = 'UNIT_HEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
tags.Methods["drk:raidhp"] = function(u)
	local ddg = _TAGS["drk:DDG"](u)

	if ddg then
		return ddg
	else
		local missinghp = SVal(_TAGS["missinghp"](u)) or ""
		if missinghp ~= "" then
			return ("-%s"):format(missinghp)
		else
			return ""
		end
	end
end

tags.Events["drk:color"] = 'UNIT_REACTION UNIT_HEALTH UNIT_HAPPINESS'
tags.Methods["drk:color"] = function(u)
	local _, class = UnitClass(u)
	local reaction = UnitReaction(u, "player")

	if UnitIsDead(u) or UnitIsGhost(u) or not UnitIsConnected(u) then
		return "|cffA0A0A0"
	elseif UnitIsTapDenied(u) then
		return hex(oUF.colors.tapped)
	elseif u == "pet" then
		return hex(oUF.colors.class[class])
	elseif UnitIsPlayer(u) then
		return hex(oUF.colors.class[class])
	elseif reaction then
		return hex(oUF.colors.reaction[reaction])
	else
		return hex(1, 1, 1)
	end
end

tags.Events["drk:afkdnd"] = 'PLAYER_FLAGS_CHANGED'
tags.Methods["drk:afkdnd"] = function(unit)
	return UnitIsAFK(unit) and "|cffCFCFCF <afk>|r" or UnitIsDND(unit) and "|cffCFCFCF <dnd>|r" or ""
end

tags.Events["drk:raidafkdnd"] = 'PLAYER_FLAGS_CHANGED'
tags.Methods["drk:raidafkdnd"] = function(unit)
	return UnitIsAFK(unit) and "|cffCFCFCF AFK|r" or UnitIsDND(unit) and "|cffCFCFCF DND|r" or ""
end

tags.Events["drk:DDG"] = 'UNIT_HEALTH'
tags.Methods["drk:DDG"] = function(u)
	if UnitIsDead(u) then
		return "|cffCFCFCF Dead|r"
	elseif UnitIsGhost(u) then
		return "|cffCFCFCF Ghost|r"
	elseif not UnitIsConnected(u) then
		return "|cffCFCFCF Off|r"
	end
end

tags.Events["drk:power"] = 'UNIT_MAXPOWER UNIT_POWER'
tags.Methods["drk:power"] = function(unit)
	local curpp, maxpp = UnitPower(unit), UnitPowerMax(unit);
	local playerClass, englishClass = UnitClass(unit);

	if(maxpp == 0) then
		return ""
	else
		if (englishClass == "WARRIOR") then
			return curpp
		elseif (englishClass == "DEATHKNIGHT" or englishClass == "ROGUE" or englishClass == "HUNTER") then
			return ("%s/%s"):format(curpp, maxpp)
		else
			return ("%s/%s | %s%%"):format(SVal(curpp), SVal(maxpp), math.floor(curpp/maxpp*100+0.5))
		end
	end
end;

tags.Events["drk:xp"] = 'PLAYER_XP_UPDATE PLAYER_LEVEL_UP UNIT_PET_EXPERIENCE UPDATE_EXHAUSTION'
tags.Methods["drk:xp"] = function(unit)
	local curxp,maxxp,perxp
	if(unit == "pet") then
		curxp,maxxp = GetPetExperience()
	else
		curxp = UnitXP(unit)
		maxxp = UnitXPMax(unit)
	end
	if maxxp and maxxp == 0 then return end
	perxp = math.floor((curxp / maxxp * 100 + 0.05)*10)/10
	local rested = GetXPExhaustion()
	if(rested and rested > 0) then
		rested = math.floor((rested / UnitXPMax(unit) * 100 + 0.05)*10)/10
		return ("%s/%s | %s%% (%s%% RXP)"):format(curxp, maxxp, perxp, rested)
	else
		return ("%s/%s | %s%%"):format(curxp, maxxp, perxp)
	end
end

tags.Events["drk:level"] = 'UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED'
tags.Methods["drk:level"] = function(unit)

	local c = UnitClassification(unit)
	local l = UnitLevel(unit)
	local d = GetQuestDifficultyColor(l)
	local q = UnitIsQuestBoss(unit)

	local str = l

	if l <= 0 then l = "??" end

	if c == "worldboss" then
		str = string.format("|cff%02x%02x%02xBoss|r",250,20,0)
	elseif c == "eliterare" then
		str = string.format("|cff%02x%02x%02x%s|r|cff0080FFR|r+",d.r*255,d.g*255,d.b*255,l)
	elseif c == "elite" then
		str = string.format("|cff%02x%02x%02x%s|r+",d.r*255,d.g*255,d.b*255,l)
	elseif c == "rare" then
		str = string.format("|cff%02x%02x%02x%s|r|cff0080FFR|r",d.r*255,d.g*255,d.b*255,l)
	else
		if not UnitIsConnected(unit) then
			str = "??"
		else
			if UnitIsPlayer(unit) then
				str = string.format("|cff%02x%02x%02x%s",d.r*255,d.g*255,d.b*255,l)
			elseif UnitPlayerControlled(unit) then
				str = string.format("|cff%02x%02x%02x%s",d.r*255,d.g*255,d.b*255,l)
			else
				str = string.format("|cff%02x%02x%02x%s",d.r*255,d.g*255,d.b*255,l)
			end
		end
	end

	if q then
		str = string.format("%s|cffffd700Q|r", str)
	end

	return str
end

tags.Events["drk:altpowerbar"] = 'UNIT_POWER UNIT_MAXPOWER UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE PLAYER_TARGET_CHANGED'
tags.Methods["drk:altpowerbar"] = function(unit)
	local ALTERNATE_POWER_INDEX = ALTERNATE_POWER_INDEX
	local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
	local max = UnitPowerMax(unit, ALTERNATE_POWER_INDEX)
	if(max > 0 and not UnitIsDeadOrGhost(unit)) then
		if (cur == 0 or cur < 0) then
			return "0%"
		else
			return ("%s%%"):format(math.floor(cur/max*100+.5))
		end
	else
		return ""
	end
end


---------------------------
-- Class Buff Indicators --
---------------------------

local UnitAura, GetTime = UnitAura, GetTime

local RIPTIDE = GetSpellInfo(61295)
tags.Events["Shaman:Riptide"] = 'UNIT_AURA'
tags.Methods["Shaman:Riptide"] = function(unit)
	local _, _, _, _, _, _, expirationTime, source = UnitAura(unit, RIPTIDE)
	if source and source == "player" then
		return format("|cff0099cc%.0f|r ", expirationTime - GetTime())
	end
end

local POWER_WORD_SHIELD = GetSpellInfo(17)
local WEAKENED_SOUL = GetSpellInfo(6788)
tags.Events["Priest:PowerWordShield"] = 'UNIT_AURA'
tags.Methods["Priest:PowerWordShield"] = function(unit)

	local _, _, _, _, _, _, expirationTime = UnitAura(unit, POWER_WORD_SHIELD)
	if expirationTime then
		return format("|cffffcc00%.0f|r ", expirationTime - GetTime())
	else
		local _, _, _, _, _, _, expirationTime = UnitDebuff(unit, WEAKENED_SOUL)
		if expirationTime then
			return format("|cffaa0000%.0f|r ", expirationTime - GetTime())
		end
	end
end

local CLARITY_OF_WILL = GetSpellInfo(152118)
tags.Events["Priest:ClarityOfWill"] = 'UNIT_AURA'
tags.Methods["Priest:ClarityOfWill"] = function(unit)

	local _, _, _, _, _, _, expirationTime = UnitAura(unit, CLARITY_OF_WILL)
	if expirationTime then
		return format("|cff33cc00%.0f|r ", expirationTime - GetTime())
	end
end

local ATONEMENT = GetSpellInfo(214206)
tags.Events["Priest:Atonement"] = 'UNIT_AURA'
tags.Methods["Priest:Atonement"] = function(unit)
	local _, _, _, _, _, _, expirationTime, source = UnitAura(unit, ATONEMENT)
	if expirationTime then
		return format("|cff268ccc%.0f|r ", expirationTime - GetTime())
	end
end

local RENEW = GetSpellInfo(139)
tags.Events["Priest:Renew"] = 'UNIT_AURA'
tags.Methods["Priest:Renew"] = function(unit)
	local _, _, _, _, _, _, expirationTime, source = UnitAura(unit, RENEW)
	if source and source == "player" then
		return format("|cff33cc00%.0f|r ", expirationTime - GetTime())
	end
end

local INNERVATE = GetSpellInfo(29166)
tags.Events["Druid:Innervate"] = 'UNIT_AURA'
tags.Methods["Druid:Innervate"] = function(unit)
	local _, _, _, _, _, _, expirationTime, source = UnitAura(unit, INNERVATE)
	if expirationTime then
		return format("|cff268ccc%.0f|r ", expirationTime - GetTime())
	end
end

local IRONBARK = GetSpellInfo(102342)
tags.Events["Druid:Ironbark"] = 'UNIT_AURA'
tags.Methods["Druid:Ironbark"] = function(unit)
	local _, _, _, _, _, _, expirationTime, source = UnitAura(unit, IRONBARK)
	if expirationTime then
		return format("|cffa52a2a%.0f|r ", expirationTime - GetTime())
	end
end

local LIFEBLOOM = GetSpellInfo(33763)
tags.Events["Druid:Lifebloom"] = 'UNIT_AURA'
tags.Methods["Druid:Lifebloom"] = function(unit)
	local _, _, _, stacks, _, _, expirationTime, source = UnitAura(unit, LIFEBLOOM)
	if source and source == "player" then
		return format("|cffffcc00%.0f|r ", expirationTime - GetTime())
	end
end

local REJUVENATION = GetSpellInfo(774)
tags.Events["Druid:Rejuv"] = 'UNIT_AURA'
tags.Methods["Druid:Rejuv"] = function(unit)
	local _, _, _, _, _, _, expirationTime, source = UnitAura(unit, REJUVENATION)
	if source and source == "player" then
		return format("|cffd814ff%.0f|r ", expirationTime - GetTime())
	end
end

local GERMINATION = GetSpellInfo(155777)
tags.Events["Druid:Germination"] = 'UNIT_AURA'
tags.Methods["Druid:Germination"] = function(unit)
    local _, _, _, _, _, _, expirationTime, source = UnitAura(unit, GERMINATION)
    if source and source == "player" then
        return format("|cffd814ff%.0f|r ", expirationTime - GetTime())
    end
end

local REGROWTH = GetSpellInfo(8936)
tags.Events["Druid:Regrowth"] = 'UNIT_AURA'
tags.Methods["Druid:Regrowth"] = function(unit)
	local _, _, _, _, _, _, expirationTime, source = UnitAura(unit, REGROWTH)
	if source == "player" then
		return format("|cff33cc00%.0f|r ", expirationTime - GetTime())
	end
end

local WILD_GROWTH = GetSpellInfo(48438)
tags.Events["Druid:WildGrowth"] = 'UNIT_AURA'
tags.Methods["Druid:WildGrowth"] = function(unit)
    if UnitBuff(unit, WILD_GROWTH) then
        return "|cff33cc00M|r "
    end
end

local BEACON = GetSpellInfo(53563)
tags.Events["Paladin:Beacon"] = 'UNIT_AURA'
tags.Methods["Paladin:Beacon"] = function(unit)
	local _, _, _, _, _, _, _, source = UnitAura(unit, BEACON)
	if source then
		if source == "player" then
			return "|cffffff33M|r "
		else
			return "|cffffcc00M|r "
		end
	end
end

local FORBEARANCE = GetSpellInfo(25771)
tags.Events["Paladin:Forbearance"] = 'UNIT_AURA'
tags.Methods["Paladin:Forbearance"] = function(unit)
	if UnitDebuff(unit, FORBEARANCE) then
		return "|cffaa0000M|r "
	end
end

local ENVELOPING_MIST = GetSpellInfo(124682)
tags.Events["Monk:EnvelopingMist"] = 'UNIT_AURA'
tags.Methods["Monk:EnvelopingMist"] = function(unit)
	local _, _, _, _, _, _, expirationTime, source = UnitAura(unit, ENVELOPING_MIST)
	if source and source == "player" then
		return format("|cff33cc00%.0f|r ", expirationTime - GetTime())
	end
end

local RENEWING_MIST = GetSpellInfo(119611)
tags.Events["Monk:RenewingMist"] = 'UNIT_AURA'
tags.Methods["Monk:RenewingMist"] = function(unit)
	local _, _, _, _, _, _, expirationTime, source = UnitAura(unit, RENEWING_MIST)
	if source and source == "player" then
		return format("|cff0099cc%.0f|r ", expirationTime - GetTime())
	end
end

tags.Events["drk:threat"] = 'UNIT_THREAT_LIST_UPDATE UNIT_THREAT_SITUATION_UPDATE'
tags.Methods["drk:threat"] = function(unit)
	local status = UnitThreatSituation(unit)
	if status and status > 1 then
		return "|cffff1100M|r"
	end
end