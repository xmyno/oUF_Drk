if select(2, UnitClass("player")) ~= "MONK" then return end

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_MonkHarmonyBar was unable to locate oUF install")

local SPELL_POWER_CHI = SPELL_POWER_CHI
local curMaxPower = 0

local Update = function(self, event, unit, powerType)
	if self.unit ~= unit or (powerType and powerType ~= "CHI") then return end

	local mhb = self.MonkHarmonyBar
	if mhb.PreUpdate then mhb:PreUpdate(unit) end

	local power = UnitPower("player",SPELL_POWER_CHI)
	local maxPower = UnitPowerMax("player",SPELL_POWER_CHI)
	if curMaxPower ~= maxPower then
		if maxPower == 4 then
			mhb[5]:Hide()
			for i = 1,4 do
				mhb[i]:SetWidth(mhb:GetWidth()/4-2)
			end
		elseif maxPower == 5 then
			mhb[5]:Show()
			for i = 1,5 do
				mhb[i]:SetWidth(mhb:GetWidth()/5-2)
			end
		end
		curMaxPower = maxPower
	end

	for i = 1, maxPower do
		if i <= power then
			mhb[i]:Show()
		else
			mhb[i]:Hide()
		end
	end


	if mhb.PostUpdate then
		return mhb:PostUpdate(spec)
	end
end

local Path = function(self, ...)
	return (self.MonkHarmonyBar.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit, "CHI")
end

local function Enable(self)
	local mhb = self.MonkHarmonyBar
	if(mhb) then
		mhb.__owner = self
		mhb.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_POWER", Path)
		self:RegisterEvent("UNIT_DISPLAYPOWER", Path)

		mhb.Visibility = CreateFrame("Frame", nil, mhb)
		mhb.Visibility:RegisterEvent("PLAYER_TALENT_UPDATE", Path)

		for i = 1, 6 do
			local Point = mhb[i]
			if not Point:GetStatusBarTexture() then
				Point:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			end

			Point:SetFrameLevel(mhb:GetFrameLevel() + 1)
			Point:GetStatusBarTexture():SetHorizTile(false)
		end



		return true
	end
end

local function Disable(self)
	local mhb = self.MonkHarmonyBar
	if(mhb) then
		self:UnregisterEvent("UNIT_POWER", Path)
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
		mhb.Visibility:UnregisterEvent("PLAYER_TALENT_UPDATE")
	end
end

oUF:AddElement("MonkHarmonyBar", Path, Enable, Disable)