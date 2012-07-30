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
		if (type(r) == 'table') then
			if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
		end
		return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
	end
end

tags.Events["drk:perhp"] = 'UNIT_HEALTH UNIT_MAXHEALTH'
tags.Methods["drk:perhp"] = function(u)
	local m = UnitHealthMax(u)
	if(m == 0) then
		return 0
	else
		return math.floor((UnitHealth(u)/m*100+.05)*10)/10
	end
end

tags.Events["drk:hp"] = 'UNIT_HEALTH UNIT_MAXHEALTH'
tags.Methods["drk:hp"] = function(u)
	if UnitIsDead(u) or UnitIsGhost(u) or not UnitIsConnected(u) then
		return _TAGS["drk:DDG"](u)
	else
		local per = _TAGS["drk:perhp"](u).."%" or 0
		local min, max = UnitHealth(u), UnitHealthMax(u)
		if u == "player" or u == "target" then
			if min~=max then 
				return "|cFFFFAAAA"..SVal(min).."|r/"..SVal(max).." | "..per
			else
				return SVal(max).." | "..per
			end
		else
			return per
		end
	end
end

tags.Events["drk:raidhp"] = 'UNIT_HEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
tags.Methods["drk:raidhp"] = function(u) 
  if UnitIsDead(u) or UnitIsGhost(u) or not UnitIsConnected(u) then
    return _TAGS["drk:DDG"](u)
  else
	
	local missinghp = SVal(_TAGS["missinghp"](u)) or ""
	if missinghp ~= "" then
		return "-"..missinghp
	else
		return ""
	end
  end
end

tags.Events["drk:color"] = 'UNIT_REACTION UNIT_HEALTH UNIT_HAPPINESS'
tags.Methods["drk:color"] = function(u, r)
	local _, class = UnitClass(u)
	local reaction = UnitReaction(u, "player")
	
	if UnitIsDead(u) or UnitIsGhost(u) or not UnitIsConnected(u) then
		return "|cffA0A0A0"
	elseif (UnitIsTapped(u) and not UnitIsTappedByPlayer(u)) then
		return hex(oUF.colors.tapped)
	elseif (u == "pet") then
		return hex(oUF.colors.class[class])
	elseif (UnitIsPlayer(u)) then
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
tags.Methods["drk:power"]  = function(u) 
	local min, max = UnitPower(u), UnitPowerMax(u)
	if min~=max then 
		return SVal(min).."/"..SVal(max)
	else
		return SVal(max)
	end
end

tags.Events["my:power"] = 'UNIT_MAXPOWER UNIT_POWER'
tags.Methods["my:power"] = function(unit)
	local curpp, maxpp = UnitPower(unit), UnitPowerMax(unit);
	local playerClass, englishClass = UnitClass(unit);

	if(maxpp == 0) then
		return ""
	else
		if (englishClass == "WARRIOR") then
			return curpp
		elseif (englishClass == "DEATHKNIGHT" or englishClass == "ROGUE" or englishClass == "HUNTER") then
			return curpp .. ' /' .. maxpp
		else
			return SVal(curpp) .. " /" .. SVal(maxpp) .. " | " .. math.floor(curpp/maxpp*100+0.5) .. "%"
		end
	end
end;


-- ComboPoints
tags.Events["myComboPoints"] = 'UNIT_COMBO_POINTS PLAYER_TARGET_CHANGED'
tags.Methods["myComboPoints"] = function(unit)
	local cp, str		
	if(UnitExists'vehicle') then
		cp = GetComboPoints('vehicle', 'target')
	else
		cp = GetComboPoints('player', 'target')
	end

	if (cp == 1) then
		str = string.format("|cff69e80c%d|r",cp)
	elseif cp == 2 then
		str = string.format("|cffb2e80c%d|r",cp)
	elseif cp == 3 then
		str = string.format("|cffffd800%d|r",cp) 
	elseif cp == 4 then
		str = string.format("|cffffba00%d|r",cp) 
	elseif cp == 5 then
		str = string.format("|cfff10b0b%d|r",cp)
	end
	
	return str
end

-- Deadly Poison Tracker
tags.Events["myDeadlyPoison"] = 'UNIT_COMBO_POINTS PLAYER_TARGET_CHANGED UNIT_AURA'
tags.Methods["myDeadlyPoison"] = function(unit)

	local Spell = "Deadly Poison" or GetSpellInfo(43233)
	local ct = hasUnitDebuff(unit, Spell)
	local cp = GetComboPoints('player', 'target')
	
	if cp > 0 then
		if (not ct) then
			str = ""
		elseif (ct == 1) then
			str = string.format("|cffc1e79f%d|r",ct)
		elseif ct == 2 then
			str = string.format("|cfface678%d|r",ct)
		elseif ct == 3 then
			str = string.format("|cff9de65c%d|r",ct) 
		elseif ct == 4 then
			str = string.format("|cff8be739%d|r",ct) 
		elseif ct == 5 then
			str = string.format("|cff90ff00%d|r",ct)
		end
	else
		str = ""
	end
	
	return str
end

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
		return curxp.."/"..maxxp.." | "..perxp.."% ("..rested.."% RXP)"
	else
		return curxp.."/"..maxxp.." | "..perxp.."%"
	end
end

tags.Events["drk:level"] = 'UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED'
tags.Methods["drk:level"] = function(unit)
	
	local c = UnitClassification(unit)
	local l = UnitLevel(unit)
	local d = GetQuestDifficultyColor(l)
	
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
	
	return str
end

tags.Events["Drk:AltPowerBar"] = 'UNIT_POWER'
tags.Methods["Drk:AltPowerBar"] = function(unit)
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
