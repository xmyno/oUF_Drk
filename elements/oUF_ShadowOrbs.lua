local parent, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_ShadowOrbs was unable to locate oUF install")

local SPELL_POWER_SHADOW_ORBS = SPELL_POWER_SHADOW_ORBS
local SPEC_PRIEST_SHADOW = SPEC_PRIEST_SHADOW

local maxOrbs = UnitPowerMax('player', SPELL_POWER_SHADOW_ORBS)
local curSpec = GetSpecialization()
local UpdateOnSpellLearned, Update, Visibility, Path, ForceUpdate, Enable, Disable

-- untested, changes shadow orb count to 5 when learning the enhanced shadow orbs perk
function UpdateOnSpellLearned(self, event, spellid, tab)
	if spellid == 157217 then
		self:UnregisterEvent('LEARNED_SPELL_IN_TAB', UpdateOnSpellLearned)

		maxOrbs = UnitPowerMax('player', SPELL_POWER_SHADOW_ORBS)

		orbs = self.PriestShadowOrbs
		for index = 1, maxOrbs do
			orbs[index]:SetWidth(orbs.GetWidth() / maxOrbs - 2)
			orbs[index]:Show()
		end
	end
end

function Update(self, event, unit, powerType)
	if self.unit ~= unit or (powerType and powerType ~= 'SHADOW_ORBS') then return end

	local orbs = self.PriestShadowOrbs
	if orbs.PreUpdate then
		orbs:PreUpdate()
	end

	-- crappy fix for shadow orbs not getting hidden upon changing spec
	-- for some reason UnitPower does not return 0 for the UNIT_POWER event after respeccing
	local numOrbs = curSpec == SPEC_PRIEST_SHADOW and UnitPower('player', SPELL_POWER_SHADOW_ORBS) or 0

	for index = 1, maxOrbs do
		if index <= numOrbs then
			orbs[index]:Show()
		else
			orbs[index]:Hide()
		end
	end

	if orbs.PostUpdate then
		return orbs:PostUpdate(numOrbs)
	end
end

function Visibility(self, event)
	local orbs = self.PriestShadowOrbs
	curSpec = GetSpecialization() -- at least this returns the right spec after switching specs ~~
	if curSpec == SPEC_PRIEST_SHADOW then
		orbs:Show()
	else
		orbs:Hide()
	end
end

function Path(self, ...)
	return (self.PriestShadowOrbs.Override or Update) (self, ...)
end

function ForceUpdate(orbs)
	return Path(orbs.__owner, 'ForceUpdate', orbs.__owner.unit)
end

function Enable(self, unit)
	local orbs = self.PriestShadowOrbs
	if orbs and unit == 'player' then
		orbs.__owner = self
		orbs.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_POWER', Path)
		self:RegisterEvent('UNIT_DISPLAYPOWER', Path)
		self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', Visibility, true)
		self:RegisterEvent('PLAYER_TALENT_UPDATE', Visibility, true)

		-- register spell learn event and change bars to 3 when enhanced shadow perks is not learned
		if IsSpellKnown(157217) == false then
			self:RegisterEvent('LEARNED_SPELL_IN_TAB', UpdateOnSpellLearned)

			for i = 1, maxOrbs do
				orbs[i]:SetWidth(orbs:GetWidth() / 3 - 2)
				orbs[4]:Hide()
				orbs[5]:Hide()
			end
		end

		return true
	end
end

function Disable(self)
	local orbs = self.PriestShadowOrbs
	if orbs then
		self:UnregisterEvent('UNIT_POWER', Path)
		self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)
		self:UnregisterEvent('PLAYER_SPECIALIZATION_CHANGED', Visibility)
		self:UnregisterEvent('PLAYER_TALENT_UPDATE', Visibility)
		self:UnregisterEvent('LEARNED_SPELL_IN_TAB', UpdateOnSpellLearned)
	end

	for index = 1, #orbs do
		orbs[index]:Hide()
	end
end

oUF:AddElement('PriestShadowOrbs', Path, Enable, Disable)
