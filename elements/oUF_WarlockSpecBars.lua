local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_WarlockSpecBars was unable to locate oUF install")

if select(2, UnitClass("player")) ~= "WARLOCK" then return end

local MAX_POWER_PER_EMBER = MAX_POWER_PER_EMBER
local SPELL_POWER_DEMONIC_FURY = SPELL_POWER_DEMONIC_FURY
local SPELL_POWER_BURNING_EMBERS = SPELL_POWER_BURNING_EMBERS
local SPELL_POWER_SOUL_SHARDS = SPELL_POWER_SOUL_SHARDS
local SPEC_WARLOCK_DESTRUCTION = SPEC_WARLOCK_DESTRUCTION
local SPEC_WARLOCK_AFFLICTION = SPEC_WARLOCK_AFFLICTION
local SPEC_WARLOCK_DEMONOLOGY = SPEC_WARLOCK_DEMONOLOGY
local LATEST_SPEC = 0

local Visibility, Update, Path, ForceUpdate, Enable, Disable

local Colors = {
	[1] = {109/255, 51/255, 188/255, 1},
	[2] = {139/255, 51/255, 188/255, 1},
	[3] = {179/255, 51/255, 188/255, 1},
	[4] = {209/255, 51/255, 188/255, 1},
}

function Update(self, event, unit, powerType)
	if(self.unit ~= unit or (powerType and powerType ~= "BURNING_EMBERS" and powerType ~= "SOUL_SHARDS" and powerType ~= "DEMONIC_FURY")) then return end

	local wsb = self.WarlockSpecBars
	if wsb.PreUpdate then wsb:PreUpdate(unit) end

	local spec = GetSpecialization()

	if spec then
		if (spec == SPEC_WARLOCK_DESTRUCTION) then
			local maxPower = UnitPowerMax("player", SPELL_POWER_BURNING_EMBERS, true)
			local power = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true)
			local numBars = floor(power / MAX_POWER_PER_EMBER)

			local rest = power
			for i = 1, #wsb do
				if i > numBars and rest <= 0 then
					wsb[i]:Hide()
				else
					wsb[i]:Show()
					wsb[i]:SetMinMaxValues(0, MAX_POWER_PER_EMBER)
					wsb[i]:SetValue(rest)
					rest = rest - MAX_POWER_PER_EMBER
				end
			end
		elseif ( spec == SPEC_WARLOCK_AFFLICTION ) then
			local numShards = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
			local maxShards = UnitPowerMax("player", SPELL_POWER_SOUL_SHARDS)

			for i = 1, #wsb do
				if i > numShards then
					wsb[i]:SetAlpha(0)
				else
					wsb[i]:SetAlpha(1)
				end
			end
		elseif spec == SPEC_WARLOCK_DEMONOLOGY then
			local power = UnitPower("player", SPELL_POWER_DEMONIC_FURY)
			local maxPower = UnitPowerMax("player", SPELL_POWER_DEMONIC_FURY)

			wsb[1]:SetMinMaxValues(0, maxPower)
			wsb[1]:SetValue(power)
		end
	end

	if wsb.PostUpdate then
		return wsb:PostUpdate(spec)
	end
end

function Visibility(self, event)
	local wsb = self.WarlockSpecBars
	local widthSpecBar = wsb:GetWidth()

	if UnitHasVehicleUI("player") then
		self:UnregisterEvent("UNIT_POWER", Path)
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)

		for i = 1, #wsb do
			wsb[i]:Hide()
		end
		if wsb.Hide then
			wsb.Hide()
		end

		return
	end

	local spec = GetSpecialization()
	if spec then
		if wsb.Show then
			wsb:Show()
		end

		if LATEST_SPEC ~= spec then
			for i = 1, #wsb do
				local max = select(2, wsb[i]:GetMinMaxValues())
				if spec == SPEC_WARLOCK_AFFLICTION then
					wsb[i]:SetValue(max)
				else
					wsb[i]:SetValue(0)
				end
			end
		end

		if spec == SPEC_WARLOCK_DESTRUCTION or spec == SPEC_WARLOCK_AFFLICTION then

			wsb[1]:SetWidth(widthSpecBar / #wsb)
			for i = 1, #wsb do
				wsb[i]:Show()
			end

		elseif spec == SPEC_WARLOCK_DEMONOLOGY then

			wsb[2]:Hide()
			wsb[3]:Hide()
			wsb[4]:Hide()
			wsb[1]:SetWidth(widthSpecBar)

		end
	else
		if wsb.Hide then
			wsb:Hide()
		end
	end

	self:RegisterEvent("UNIT_POWER", Path)
	self:RegisterEvent("UNIT_DISPLAYPOWER", Path)

	LATEST_SPEC = spec

	Update(self, "Visibility", "player")
end

function Path(self, ...)
	return (self.WarlockSpecBars.Override or Update) (self, ...)
end

function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

function Enable(self)
	local wsb = self.WarlockSpecBars
	if wsb and self.unit == "player" then
		wsb.__owner = self
		wsb.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_ENTERING_VEHICLE", Visibility)
		self:RegisterEvent("UNIT_EXITED_VEHICLE", Visibility)

		self:RegisterEvent("PLAYER_TALENT_UPDATE", Visibility)

		for i = 1, 4 do
			local element = wsb[i]
			if not element:GetStatusBarTexture() then
				element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end

			element:SetStatusBarColor(unpack(Colors[i]))
			element:SetFrameLevel(wsb:GetFrameLevel() + 1)
			element:GetStatusBarTexture():SetHorizTile(false)
		end

		Visibility(self, "Enable")
		return true
	end
end

function Disable(self)
	local wsb = self.WarlockSpecBars
	if wsb then
		self:UnregisterEvent("UNIT_POWER", Path)
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)

		self:UnregisterEvent("PLAYER_TALENT_UPDATE", Visibility)
		self:UnregisterEvent("UNIT_ENTERING_VEHICLE", Visibility)
		self:UnregisterEvent("UNIT_EXITED_VEHICLE", Visibility)

		for i = 1, #wsb do
			wsb[i].Hide()
		end
		if wsb.Hide then
			wsb.Hide()
		end
	end
end

oUF:AddElement("WarlockSpecBars", Path, Enable, Disable)