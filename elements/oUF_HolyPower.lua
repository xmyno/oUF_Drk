if(select(2, UnitClass('player')) ~= 'PALADIN') then return end

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_HolyPower was unable to locate oUF install")

local SPELL_POWER_HOLY_POWER = SPELL_POWER_HOLY_POWER
local MAX_HOLY_POWER = MAX_HOLY_POWER

local updateOnLevelUp = function(self, event, newlevel, ...)
	local hp = self.PaladinHolyPower
	if newlevel == 85 then
		self:UnregisterEvent('PLAYER_LEVEL_UP')
		for i=1,5 do
			hp[i]:SetWidth(hp:GetWidth()/5-2)
		end
		hp[4]:Show()
		hp[5]:Show()
	end
end

local Update = function(self, event, unit, powerType)
	if(self.unit ~= unit or (powerType and powerType ~= 'HOLY_POWER')) then return end

	local hp = self.PaladinHolyPower
	if(hp.PreUpdate) then hp:PreUpdate() end

	local num = UnitPower('player', SPELL_POWER_HOLY_POWER)
	local maxHolyPower = UnitPowerMax('player', SPELL_POWER_HOLY_POWER)
	for i = 1, maxHolyPower do
		if(i <= num) then
			hp[i]:Show()
		else
			hp[i]:Hide()
		end
	end

	if(hp.PostUpdate) then
		return hp:PostUpdate(num)
	end
end

local Path = function(self, ...)
	return (self.PaladinHolyPower.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit, 'HOLY_POWER')
end

local function Enable(self)
	local hp = self.PaladinHolyPower
	if(hp) then
		hp.__owner = self
		hp.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_POWER', Path)
		if UnitLevel("player") < 85 then
			self:RegisterEvent('PLAYER_LEVEL_UP', updateOnLevelUp)
			for i=1,3 do
				hp[i]:SetWidth(hp:GetWidth()/3-2)
			end
			hp[4]:Hide()
			hp[5]:Hide()
		end

		return true
	end
end

local function Disable(self)
	local hp = self.PaladinHolyPower
	if(hp) then
		self:UnregisterEvent('UNIT_POWER', Path)
	end
end

oUF:AddElement('PaladinHolyPower', Path, Enable, Disable)
