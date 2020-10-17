local _, ns = ...
local cfg = ns.cfg
local lib = ns.lib
local oUF = ns.oUF or oUF

local playerClass = select(2,UnitClass("player"))
local candispell = {
	Magic = {
		PRIEST = { [1] = true, [2] = true, },
		SHAMAN = { [3] = true, },
		PALADIN = { [1] = true, },
		DRUID = { [4] = true, },
		MONK = { [2] = true, },
	},
	Curse = {
		PRIEST = { },
		SHAMAN = { [1] = true, [2] = true, [3] = true, },
		PALADIN = { },
		DRUID = { [1] = true, [2] = true, [3] = true, [4] = true, },
		MONK = { },
	},
	Disease = {
		PRIEST = { [1] = true, [2] = true, [3] = true, },
		SHAMAN = { },
		PALADIN = { [1] = true, [2] = true, [3] = true, },
		DRUID = { },
		MONK = { [1] = true, [2] = true, [3] = true, },
	},
	Poison = {
		PRIEST = { },
		SHAMAN = { },
		PALADIN = { [1] = true, [2] = true, [3] = true, },
		DRUID = { [1] = true, [2] = true, [3] = true, [4] = true, },
		MONK = { [1] = true, [2] = true, [3] = true, },
	}
}

local backdrop_tab = {
	bgFile = cfg.backdrop_texture,
	edgeFile = cfg.backdrop_edge_texture,
	tile = false,
	tileSize = 0,
	edgeSize = 4,
	insets = {
		left = 2,
		right = 2,
		top = 2,
		bottom = 2,
	},
}
local gen_backdrop = function(f,r,g,b)
	f:SetBackdrop(backdrop_tab);
	f:SetBackdropColor(r,g,b,1)
	f:SetBackdropBorderColor(r,g,b,0.8)
end

local createAuraIcon = function(debuffs)
	local button = CreateFrame("Button", nil, debuffs)
	button:EnableMouse(false)
	button:SetFrameLevel(8)

	button:SetSize(debuffs.size, debuffs.size)

	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetPoint("TOPLEFT", button)
	icon:SetPoint("BOTTOMRIGHT", button)
	icon:SetTexCoord(.05, .95, .05, .95)

	local cd = CreateFrame("Cooldown", nil, button)
	cd:SetReverse(true)
	cd:SetFrameLevel(9)
	cd:SetPoint("TOPLEFT", button)
	cd:SetPoint("BOTTOMRIGHT", button)

	local border = CreateFrame("Frame", nil, button, BackdropTemplateMixin and "BackdropTemplate")
	border:SetFrameLevel(7)
	border:SetPoint("TOPLEFT", -4, 3)
	border:SetPoint("BOTTOMRIGHT", 4, -4)
	gen_backdrop(border,0,0,0)

	local count = button:CreateFontString(nil, "OVERLAY")
	count:SetFont(cfg.smallfont,9,"OUTLINE")
	count:SetShadowColor(0,0,0,0.8)
	count:SetShadowOffset(1,-1)
	count:SetPoint("LEFT", button, "BOTTOM", 0, 4)

	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetTexture(cfg.debuff_border_texture)
	overlay:SetPoint("TOPLEFT", -1.3, 1)
	overlay:SetPoint("BOTTOMRIGHT", 1.3, -1)
	button.overlay = overlay

	button:SetPoint("BOTTOMLEFT", debuffs, "BOTTOMLEFT")

	button.parent = debuffs
	button.icon = icon
	button.count = count
	button.cd = cd
	button.cddone = false
	button:Hide()

	debuffs.button = button
end

local updateDebuff = function(icon, texture, count, dtype, duration, timeLeft)
	local color = DebuffTypeColor[dtype] or {r = 0.8, g = 0.2, b = 0}
	if color == nil then
		icon.overlay:SetVertexColor(0,0,0)
	else
		icon.overlay:SetVertexColor(color.r,color.g,color.b)
	end
	icon.overlay:Show()

	icon.icon:SetTexture(texture)
	icon.count:SetText((count > 1 and count))
end

local updateIcon = function(unit, debuffs)
	local cur
	local hide = true
	local index = 1
	while true do
		local name, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID = UnitAura(unit, index, 'HARMFUL')
		if not name then break end

		local icon = debuffs.button
		local show = debuffs.CustomFilter(debuffs, unit, icon, name, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID)

		if not show then
			if dtype and candispell[dtype] and candispell[dtype][playerClass] and candispell[dtype][playerClass][cfg.spec] then
				show = true
				icon.priority = 5
			end
		end

		if(show) then
			if not cur then
				cur = icon.priority
				updateDebuff(icon, texture, count, dtype, duration, timeLeft)
				if icon.timeLeft == nil then
					icon.timeLeft = timeLeft
					icon.cd:SetCooldown(GetTime(),duration)
				elseif timeLeft>icon.timeLeft then
					icon.timeLeft = timeLeft
					icon.cd:SetCooldown(GetTime(),duration)
				end
			else
				if icon.priority > cur then
					updateDebuff(icon, texture, count, dtype, duration, timeLeft)
					if icon.timeLeft == nil then
						icon.timeLeft = timeLeft
						icon.cd:SetCooldown(GetTime(),duration)
					elseif timeLeft>icon.timeLeft then
						icon.timeLeft = timeLeft
						icon.cd:SetCooldown(GetTime(),duration)
					end
				end
			end

			icon:Show()
			hide = false
		end

		index = index + 1
	end
	if hide then
		debuffs.button:Hide()
		debuffs.button.cddone = false
	end
end

local Update = function(self, event, unit)
	if(self.unit ~= unit) then return end

	local debuffs = self.raidDebuffs
	if(debuffs) then
		updateIcon(unit, debuffs)
	end
end

local Enable = function(self)
	if(self.raidDebuffs) then
		createAuraIcon(self.raidDebuffs)
		cfg.updateSpec()
		self:RegisterEvent("UNIT_AURA", Update)
		return true
	end
end

local Disable = function(self)
	if(self.raidDebuffs) then
		self:UnregisterEvent("UNIT_AURA", Update)
		--self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	end
end

oUF:AddElement('raidDebuffs', Update, Enable, Disable)
