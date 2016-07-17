if select(2, UnitClass("player")) ~= "MAGE" then return end

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_ArcaneCharges was unable to locate oUF install")

local SPELL_POWER_ARCANE_CHARGES = SPELL_POWER_ARCANE_CHARGES

local Update = function(self, event, unit, powerType)
	if self.unit ~= unit or (powerType and powerType ~= "ARCANE_CHARGES") then return end

	local acb = self.MageArcaneCharges
	if acb.PreUpdate then acb:PreUpdate(unit) end

	local power = UnitPower("player", SPELL_POWER_ARCANE_CHARGES)
	for i = 1, 4 do
		if i <= power then
			acb[i]:Show()
		else
			acb[i]:Hide()
		end
	end


	if acb.PostUpdate then
		return acb:PostUpdate(spec)
	end
end

local Visibility = function(self, event)
	local acb = self.MageArcaneCharges
	if GetSpecialization() == SPEC_MAGE_ARCANE then
		acb:Show()
	else
		acb:Hide()
	end
end

local Path = function(self, ...)
	return (self.MageArcaneCharges.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit, "ARCANE_CHARGES")
end

local function Enable(self)
	local acb = self.MageArcaneCharges
	if(acb) then
		acb.__owner = self
		acb.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_POWER", Path)
		self:RegisterEvent("UNIT_DISPLAYPOWER", Path)
		self:RegisterEvent("PLAYER_TALENT_UPDATE", Visibility)

		for i = 1, 4 do
			local Point = acb[i]
			if not Point:GetStatusBarTexture() then
				Point:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			end

			Point:SetFrameLevel(acb:GetFrameLevel() + 1)
			Point:GetStatusBarTexture():SetHorizTile(false)
		end



		return true
	end
end

local function Disable(self)
	if self.MageArcaneCharges then
		self:UnregisterEvent("UNIT_POWER", Path)
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", Visibility)
	end
end

oUF:AddElement("MageArcaneCharges", Path, Enable, Disable)