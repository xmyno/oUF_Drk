local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_WarlockSpecBars was unable to locate oUF install")

if select(2, UnitClass("player")) ~= "WARLOCK" then return end

local SPELL_POWER_SOUL_SHARDS = SPELL_POWER_SOUL_SHARDS
-- local LATEST_SPEC = 0

local Visibility, Update, Path, ForceUpdate, Enable, Disable

local Colors = {
	[1] = {109/255, 51/255, 188/255, 1},
	[2] = {139/255, 51/255, 188/255, 1},
	[3] = {179/255, 51/255, 188/255, 1},
	[4] = {209/255, 51/255, 188/255, 1},
	[5] = {209/255, 51/255, 188/255, 1},
}

function Update(self, event, unit, powerType)
	if(self.unit ~= unit or (powerType and powerType ~= "SOUL_SHARDS")) then return end

	local wsb = self.WarlockSpecBars
	if wsb.PreUpdate then wsb:PreUpdate(unit) end

	local numShards = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
	local maxShards = UnitPowerMax("player", SPELL_POWER_SOUL_SHARDS)

	for i = 1, #wsb do
		if i > numShards then
			wsb[i]:SetAlpha(0)
		else
			wsb[i]:SetAlpha(1)
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
			wsb:Hide()
		end

		return
	end

	self:RegisterEvent("UNIT_POWER", Path)
	self:RegisterEvent("UNIT_DISPLAYPOWER", Path)

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

		for i = 1, #wsb do
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