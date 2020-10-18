local addon, ns = ...

local cfg = ns.cfg
local cast = ns.cast
local core = CreateFrame("Frame")
local _, playerClass = UnitClass("player")


-----------------------
-- General
-----------------------

oUF.colors.smooth = {
	1, 0, 0, --low health
	1, .196, .196, --half health
	.165, .188, .196 --max health
}
oUF:DisableBlizzard('party')

function core.createBackdrop(f, size)
	f:SetBackdrop({
		bgFile = cfg.backdrop_texture,
		edgeFile = cfg.backdrop_edge_texture,
		tile = false,
		tileSize = 0,
		edgeSize = 5-size,
		insets = {
			left = 3-size,
			right = 3-size,
			top = 3-size,
			bottom = 3-size,
		}
	})
	f:SetBackdropColor(0, 0, 0, 1)
	f:SetBackdropBorderColor(0, 0, 0, 0.8)
end

function core.createFontString(f, name, size, outline)
	local fs = f:CreateFontString(nil, "OVERLAY")
	fs:SetFont(name, size, outline)
	fs:SetShadowColor(0, 0, 0, 0.8)
	fs:SetShadowOffset(1, -1)
	fs:SetWordWrap(false)
	return fs
end

function core.addHighlight(f)
    local OnEnter = function(f)
		UnitFrame_OnEnter(f)
		f.Highlight:Show()
		if f.Experience ~= nil then
			f.Experience.Text:SetAlpha(0.9)
		end
		if f.ArtifactPower ~= nil then
			if not cfg.alwaysShowArtifactXPBar then
				f.ArtifactPower:SetAlpha(1)
			end
			f.ArtifactPower.Text:SetAlpha(1)
		end
		if f.unitType == "raid" then
			if not cfg.showTooltips then GameTooltip:Hide() end
			if cfg.showRoleIcons and cfg.showRoleIconsHoverOnly then f.GroupRoleIndicator:SetAlpha(1) end
		end
    end
    local OnLeave = function(f)
		UnitFrame_OnLeave(f)
		f.Highlight:Hide()
		if f.Experience ~= nil then
			f.Experience.Text:SetAlpha(0)
		end
		if f.ArtifactPower ~= nil then
			if not cfg.alwaysShowArtifactXPBar then
				f.ArtifactPower:SetAlpha(0)
			end
			f.ArtifactPower.Text:SetAlpha(0)
		end
		if f.unitType == "raid" then
			if cfg.showRoleIcons and cfg.showRoleIconsHoverOnly then f.GroupRoleIndicator:SetAlpha(0) end
		end
    end
    f:SetScript("OnEnter", OnEnter)
    f:SetScript("OnLeave", OnLeave)

    local hl = f.Health:CreateTexture(nil, "OVERLAY")
    hl:SetAllPoints(f.Health)
    hl:SetTexture(cfg.highlight_texture)
    hl:SetVertexColor(0.5, 0.5, 0.5, 0.1)
    hl:SetBlendMode("ADD")
    hl:Hide()
    f.Highlight = hl
end

function core.HealthPrediction_Override(self, event, unit)
	if self.unit ~= unit then return end

	local element = self.HealthPrediction
	local parent = self.Health

	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	if maxHealth == 0 or UnitIsDeadOrGhost(unit) then
		element.healingBar:Hide()
		element.absorbsBar:Hide()
		return
	end

	local missing = maxHealth - health
	local healing = UnitGetIncomingHeals(unit) or 0

	if (healing / maxHealth) >= 0.01 and missing > 0 then
		local bar = element.healingBar
		bar:Show()
		bar:SetMinMaxValues(0, maxHealth)
		if healing > missing then
			bar:SetValue(missing)
			missing = 0
		else
			bar:SetValue(healing)
			missing = missing - healing
		end
		parent = bar
	else
		element.healingBar:Hide()
	end

	local absorbs = UnitGetTotalAbsorbs(unit) or 0
	if (absorbs / maxHealth) >= 0.01 and missing > 0 then
		local bar = element.absorbsBar
		bar:Show()
		bar:SetPoint("TOPLEFT", parent:GetStatusBarTexture(), "TOPRIGHT")
		bar:SetPoint("BOTTOMLEFT", parent:GetStatusBarTexture(), "BOTTOMRIGHT")
		bar:SetMinMaxValues(0, maxHealth)
		if absorbs > missing then
			bar:SetValue(missing)
		else
			bar:SetValue(absorbs)
		end
	else
		element.absorbsBar:Hide()
	end
end


-----------------------
-- Buffs & Debuffs
-----------------------

function core.formatTime(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", floor(s/day + 0.5)), s % day
	elseif s >= hour then
		return format("%dh", floor(s/hour + 0.5)), s % hour
	elseif s >= minute then
		if s <= minute * 5 then
			return format("%d:%02d", floor(s/60), s % minute), s - floor(s)
		end
		return format("%dm", floor(s/minute + 0.5)), s % minute
	elseif s >= minute / 12 then
		return floor(s + 0.5), (s * 100 - floor(s * 100))/100
	end
	return format("%.1f", s), (s * 100 - floor(s * 100))/100
end

function core.createBuffTimer(self, elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = core.formatTime(self.timeLeft)
					self.time:SetText(time)
				if self.timeLeft < 5 then
					self.time:SetTextColor(1, 0.5, 0.5)
				else
					self.time:SetTextColor(.7, .7, .7)
				end
			else
				self.time:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end

function core.PostCreateIcon(self, button)
	self.showDebuffType = false
	self.disableCooldown = true

	Mixin(button, BackdropTemplateMixin or {})

	button.cd.noOCC = true
	button.cd.noCooldownCount = true

	button.icon:SetTexCoord(.04, .96, .04, .96)
	button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
	button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)

	button.time = core.createFontString(button, cfg.smallfont, cfg.fontsize.auras, "OUTLINE")
	button.time:SetPoint("BOTTOMLEFT", button, -2, -2)
	button.time:SetJustifyH('CENTER')
	button.time:SetVertexColor(1,1,1)

	button.count = core.createFontString(button, cfg.smallfont, cfg.fontsize.auras, "OUTLINE")
	button.count:ClearAllPoints()
	button.count:SetPoint("TOPRIGHT", button, 2, 2)
	button.count:SetVertexColor(1,1,1)

	button.overlay:Hide()

	local border = button:CreateTexture(nil, "OVERLAY")
	border:SetTexture(cfg.debuff_border_texture)
	border:SetPoint("TOPLEFT", -1, 1)
	border:SetPoint("BOTTOMRIGHT", 1, -1)
	border:Hide()
	button.border = border

	--helper
	local h = CreateFrame("Frame", nil, button, BackdropTemplateMixin and "BackdropTemplate")
	h:SetFrameLevel(0)
	h:SetPoint("TOPLEFT",-4,4)
	h:SetPoint("BOTTOMRIGHT",4,-4)
	core.createBackdrop(h,0)
end

function core.PostUpdateIcon(self, unit, icon, index, offset, filter, isDebuff)

	local _, _, _, dispelType, duration, expirationTime, unitCaster, _ = UnitAura(unit, index, icon.filter)

	if duration and duration > 0 then
		icon.time:Show()
		icon.timeLeft = expirationTime
		icon:SetScript("OnUpdate", core.createBuffTimer)
	else
		icon.time:Hide()
		icon.timeLeft = math.huge
		icon:SetScript("OnUpdate", nil)
	end

	if unit == "target" then
		-- Hide/show and color border depending on type for buffs
		if dispelType then
			local color = DebuffTypeColor[dispelType] or nil
			if color then
				icon.border:Show()
				icon.border:SetVertexColor(color.r, color.g, color.b)
			end
		else
			icon.border:Hide()
		end
		-- Desaturate non-Player Debuffs
		if icon.filter == "HARMFUL" then
			if (unitCaster == 'player' or unitCaster == 'vehicle') then
				icon.icon:SetDesaturated(nil)
			elseif(not UnitPlayerControlled(unit)) then -- If Unit is Player Controlled don't desaturate debuffs
				icon:SetBackdropColor(0, 0, 0)
				icon.icon:SetDesaturated(1)
			end
		end
	end

	-- Right Click Cancel Buff/Debuff
	icon:SetScript('OnMouseUp', function(self, mouseButton)
		if mouseButton == 'RightButton' then
			CancelUnitBuff('player', index)
		end
	end)

	icon.first = true
end

function core.addBuffs(f)
    local b = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate")
    b.size = 20
    b.num = 20
    b.spacing = 5
    b.onlyShowPlayer = false
    b:SetHeight(b.size*2)
    b:SetWidth(f:GetWidth())
	if f.unitType == "player" then
		b:SetPoint("TOPRIGHT", f, "TOPLEFT", -4, 0)
		b.initialAnchor = "TOPRIGHT"
		b["growth-x"] = "LEFT"
		b["growth-y"] = "DOWN"
	else
		b:SetPoint("TOPLEFT", f, "TOPRIGHT", 4, 0)
		b.initialAnchor = "TOPLEFT"
		b["growth-x"] = "RIGHT"
		b["growth-y"] = "DOWN"
	end
	b.PostCreateIcon = core.PostCreateIcon
    b.PostUpdateIcon = core.PostUpdateIcon

    f.Buffs = b
end

function core.addDebuffs(f)
    local b = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate")
    b.size = 20
	b.num = 10
	b.onlyShowPlayer = false
    b.spacing = 5
    b:SetHeight(b.size)
    b:SetWidth(f:GetWidth())

	b:SetPoint("TOPLEFT", f.Power, "BOTTOMLEFT", 0, -4)
    b.initialAnchor = "TOPLEFT"
    b["growth-x"] = "RIGHT"
    b["growth-y"] = "DOWN"
    b.PostCreateIcon = core.PostCreateIcon
    b.PostUpdateIcon = core.PostUpdateIcon
	b:SetFrameLevel(1)

    f.Debuffs = b
end


-----------------------
-- Mirror Bar
-----------------------

do
	for _, bar in pairs({'MirrorTimer1','MirrorTimer2','MirrorTimer3',}) do
		--for i, region in pairs({_G[bar]:GetRegions()}) do
		--	if (region.GetTexture and region:GetTexture() == 'SolidTexture') then
		--	  region:Hide()
		--	end
		--end
		_G[bar..'Border']:Hide()
		Mixin(_G[bar], BackdropTemplateMixin or {})
		_G[bar]:SetParent(UIParent)
		_G[bar]:SetScale(1)
		_G[bar]:SetHeight(16)
		_G[bar]:SetWidth(280)
		_G[bar]:SetBackdropColor(0.1, 0.1, 0.1)
		_G[bar..'Background'] = _G[bar]:CreateTexture(bar..'Background', 'BACKGROUND', _G[bar])
		_G[bar..'Background']:SetTexture(cfg.statusbar_texture)
		_G[bar..'Background']:SetAllPoints(bar)
		_G[bar..'Background']:SetVertexColor(0.15, 0.15, 0.15, 0.75)
		_G[bar..'Text']:SetFont(cfg.font, 14)
		_G[bar..'Text']:ClearAllPoints()
		_G[bar..'Text']:SetPoint('CENTER', MirrorTimer1StatusBar, 0, 1)
		_G[bar..'StatusBar']:SetAllPoints(_G[bar])

		--glowing borders
		local h = CreateFrame("Frame", nil, _G[bar], BackdropTemplateMixin and "BackdropTemplate")
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT", -3, 3)
		h:SetPoint("BOTTOMRIGHT", 3, -3)
		core.createBackdrop(h, 0)
	end
end

ns.core = core
