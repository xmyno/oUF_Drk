local addon, ns = ...
local cfg = ns.cfg
local core = ns.core
local cast = ns.cast
local _, playerClass = UnitClass("player")

local create = function(self)
	self.unitType = "player"
	self:SetSize(cfg.unitframeWidth * cfg.unitframeScale, 50 * cfg.unitframeScale)
	self:SetPoint("TOPRIGHT", UIParent, "BOTTOM", cfg.playerX, cfg.playerY)
	self:RegisterForClicks('AnyUp')
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", cfg.updateSpec)

	-- Health
	do
		local s = CreateFrame("StatusBar", nil, self)
		s:SetFrameLevel(1)
		s:SetHeight(self:GetHeight() * 0.68)
		s:SetWidth(self:GetWidth())
		s:SetPoint("TOP", 0, 0)
		s:SetStatusBarTexture(cfg.statusbar_texture)
		s:GetStatusBarTexture():SetHorizTile(true)

		local h = CreateFrame("Frame", nil, s)
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT", -4, 4)
		h:SetPoint("BOTTOMRIGHT",4,-4)
		core.createBackdrop(h, 0)

		local b = s:CreateTexture(nil, "BACKGROUND")
		b:SetTexture([[Interface\ChatFrame\ChatFrameBackground]])
		b:SetAllPoints(s)

		self.Health = s
		self.Health.bg = b

		self.Health.frequentUpdates = true
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Health.Smooth = true
	end
	-- Tag Texts
	do
		local name = core.createFontString(self.Health, cfg.font, cfg.fontsize.unitframe, "NONE")
		name:SetPoint("LEFT", self.Health, "TOPLEFT", 5, -10)
		name:SetJustifyH("LEFT")
		name.frequentUpdates = true
		local hpval = core.createFontString(self.Health, cfg.font, cfg.fontsize.unitframe, "NONE")
		hpval:SetPoint("RIGHT", self.Health, "TOPRIGHT", -3, -10)
		hpval.frequentUpdates = true
		local powerval = core.createFontString(self.Health, cfg.font, cfg.fontsize.unitframe, "THINOUTLINE")
		powerval:SetPoint("RIGHT", self.Health, "BOTTOMRIGHT", 3, -16)

		name:SetPoint("RIGHT", hpval, "LEFT", -2, 0)
		self:Tag(name, "[drk:color][drk:power]|r[drk:afkdnd]")
		self:Tag(hpval, "[drk:hp]")
	end
	-- Power
	do
		local s = CreateFrame("StatusBar", nil, self)
		s:SetFrameLevel(1)
		s:SetHeight(self:GetHeight() * 0.26)
		s:SetWidth(self:GetWidth())
	    s:SetStatusBarTexture(cfg.powerbar_texture)
		s:GetStatusBarTexture():SetHorizTile(true)
		s:SetPoint("BOTTOM", self, "BOTTOM", 0, 0)
		s.frequentUpdates = true

		local h = CreateFrame("Frame", nil, s)
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT", -4, 4)
		h:SetPoint("BOTTOMRIGHT", 4, -4)
		core.createBackdrop(h, 0)

	    local b = s:CreateTexture(nil, "BACKGROUND")
	    b:SetTexture(cfg.powerbar_texture)
	    b:SetAllPoints(s)

	    self.Power = s
	    self.Power.bg = b
	    self.Power.colorClass = true
		self.Power.bg.multiplier = 0.5
		self.Power.Smooth = true
	end
	-- Highlight
	core.addHighlight(self)
	-- Portrait
	if cfg.showPortraits then
	    local p = CreateFrame("PlayerModel", nil, self)
	    p:SetFrameLevel(4)
	    p:SetHeight(19.8)
	    p:SetWidth(self:GetWidth()-17.55)
	    p:SetPoint("BOTTOM", self, "BOTTOM", 0, 8)
	    --helper
	    local h = CreateFrame("Frame", nil, p)
	    h:SetFrameLevel(3)
	    h:SetPoint("TOPLEFT", -4, 4)
	    h:SetPoint("BOTTOMRIGHT", 5, -5)
	    core.createBackdrop(h, 0)

	    self.Portrait = p
	    -- TODO does this do anything?
	    local hl = self.Portrait:CreateTexture(nil, "OVERLAY")
	    hl:SetAllPoints(self.Portrait)
	    hl:SetTexture(cfg.portrait_texture)
	    hl:SetVertexColor(.5, .5, .5, .8)
	    hl:SetBlendMode("ALPHAKEY")
	    hl:Hide()
	end
	-- AltPowerBar
	if cfg.AltPowerBarPlayer then
		local s = CreateFrame("StatusBar", nil, self.Power) -- TODO attach to health
		s:SetFrameLevel(1)
		s:SetSize(3, self:GetHeight()+0.5)
		s:SetOrientation("VERTICAL")
		s:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 3, 0)
		s:SetStatusBarTexture(cfg.powerbar_texture)
		s:GetStatusBarTexture():SetHorizTile(false)
		s:SetStatusBarColor(235/255, 235/255, 235/255)

		local h = CreateFrame("Frame", nil, s)
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT", -3, 3)
		h:SetPoint("BOTTOMRIGHT", 3, -3)
		core.createBackdrop(h, 1)

	    local b = s:CreateTexture(nil, "BACKGROUND")
	    b:SetTexture(cfg.powerbar_texture)
	    b:SetAllPoints(s)
		b:SetVertexColor(45/255, 45/255, 45/255)

		self.AltPowerBar = s
	    self.AltPowerBar.bg = b
	end
	-- AltPowerBar Text
	do
		local altpphelpframe = CreateFrame("Frame", nil, self)
		if cfg.AltPowerBarPlayer then
			altpphelpframe:SetPoint("LEFT", self.AltPowerBar, "BOTTOMLEFT", 1, 4)
		else
			altpphelpframe:SetPoint("CENTER", PlayerPowerBarAlt, "TOP", 0, -5) -- adds percentage to standard blizzard altPowerBar
		end
		altpphelpframe:SetFrameLevel(7)
		altpphelpframe:SetSize(30, 10)
		local altppbartext = core.createFontString(altpphelpframe, cfg.font, cfg.fontsize.smalltext, "OUTLINE")
		altppbartext:SetPoint("LEFT", altpphelpframe, "LEFT", 0, 0)
		altppbartext:SetJustifyH("LEFT")

		self:Tag(altppbartext, "[drk:altpowerbar]")
	end
	-- HealPrediction
	if cfg.showIncHeals then
		local health = self.Health

		local healing = CreateFrame('StatusBar', nil, health)
		healing:SetPoint('TOPLEFT', health:GetStatusBarTexture(), 'TOPRIGHT')
		healing:SetPoint('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
		healing:SetWidth(self:GetWidth())
		healing:SetStatusBarTexture(cfg.statusbar_texture)
		healing:SetStatusBarColor(0.25, 1, 0.25, 0.5)
		healing:SetFrameLevel(1)

		local absorbs = CreateFrame('StatusBar', nil, health)
		absorbs:SetPoint('TOPLEFT', healing:GetStatusBarTexture(), 'TOPRIGHT')
		absorbs:SetPoint('BOTTOMLEFT', healing:GetStatusBarTexture(), 'BOTTOMRIGHT')
		absorbs:SetWidth(self:GetWidth())
		absorbs:SetStatusBarTexture(cfg.statusbar_texture)
		absorbs:SetStatusBarColor(0.25, 0.8, 1, 0.5)
		absorbs:SetFrameLevel(1)

		self.HealPrediction = {
			healingBar = healing,
			absorbsBar = absorbs,
			Override = core.HealPrediction_Override
		}
	end
	-- Experience
	if cfg.showExperienceBar then
		local Experience = CreateFrame('StatusBar', nil, self)
		Experience:SetPoint('TOPRIGHT', self.Health, 'TOPLEFT', -3, 0)
		Experience:SetWidth(3)
		Experience:SetHeight(self:GetHeight())
		Experience:SetFrameLevel(6)
		Experience:SetStatusBarTexture(cfg.statusbar_texture)
		Experience:SetStatusBarColor(.407, .13, .545)

		Experience:SetOrientation("VERTICAL")
		Experience:GetStatusBarTexture():SetHorizTile(false)
		Experience:GetStatusBarTexture():SetVertTile(true)

		Experience.Rested = CreateFrame('StatusBar', nil, Experience)
		Experience.Rested:SetAllPoints(Experience)
		Experience.Rested:SetStatusBarTexture(cfg.statusbar_texture)
		Experience.Rested:SetStatusBarColor(.117,.55,1)

		Experience.Rested:SetOrientation("VERTICAL")
		Experience.Rested:GetStatusBarTexture():SetHorizTile(false)
		Experience.Rested:GetStatusBarTexture():SetVertTile(true)

		Experience.Rested.bg = Experience.Rested:CreateTexture(nil, 'BACKGROUND')
		Experience.Rested.bg:SetAllPoints(Experience)
		Experience.Rested.bg:SetTexture(cfg.statusbar_texture)
		Experience.Rested.bg:SetVertexColor(0, 0, 0)

		local h = CreateFrame("Frame", nil, Experience.Rested)
		h:SetFrameLevel(5)
		h:SetPoint("TOPLEFT", -3, 3)
		h:SetPoint("BOTTOMRIGHT", 3, -3)
		core.createBackdrop(h, 1)

		Experience.Text = core.createFontString(Experience, cfg.smallfont, cfg.fontsize.smalltext, 'OUTLINE')
		Experience.Text:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMLEFT", -1, 0)
		Experience.Text:SetJustifyH("RIGHT")
		Experience.Text:SetWordWrap(true)

		self:Tag(Experience.Text, "[drk:xp]")
		Experience.Text:SetAlpha(0)

		self.Experience = Experience
	end
	-- ArtifactPower
	if cfg.showArtifactPowerBar then
		local ArtifactPower = CreateFrame('StatusBar', nil, self)
		if UnitLevel('player') == MAX_PLAYER_LEVEL then
			ArtifactPower:SetPoint('TOPRIGHT', self.Health, 'TOPLEFT', -3, 0)
		else
			ArtifactPower:SetPoint('TOPRIGHT', self.Experience, 'TOPLEFT', -3, 0)
		end
		ArtifactPower:SetWidth(3)
		ArtifactPower:SetHeight(self:GetHeight())
		ArtifactPower:SetFrameLevel(6)
		ArtifactPower:SetStatusBarTexture(cfg.statusbar_texture)
		ArtifactPower:GetStatusBarTexture():SetHorizTile(false)
		ArtifactPower:GetStatusBarTexture():SetVertTile(true)
		ArtifactPower:SetOrientation("VERTICAL")
		ArtifactPower:SetStatusBarColor(.9, .8, .5)

		ArtifactPower.bg = ArtifactPower:CreateTexture(nil, 'BACKGROUND')
		ArtifactPower.bg:SetAllPoints(ArtifactPower)
		ArtifactPower.bg:SetTexture(cfg.statusbar_texture)
		ArtifactPower.bg:SetVertexColor(0, 0, 0)

		local h = CreateFrame("Frame", nil, ArtifactPower)
		h:SetFrameLevel(5)
		h:SetPoint("TOPLEFT", -3, 3)
		h:SetPoint("BOTTOMRIGHT", 3, -3)
		core.createBackdrop(h, 1)

		ArtifactPower.Text = core.createFontString(ArtifactPower, cfg.smallfont, cfg.fontsize.smalltext, 'OUTLINE')
		ArtifactPower.Text:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -1, 0)
		ArtifactPower.Text:SetJustifyH("RIGHT")
		ArtifactPower.Text:SetWordWrap(true)
		ArtifactPower.Text:SetAlpha(0)

		ArtifactPower.PostUpdate = function(self, event, isShown)
		    if (not isShown) then return end
	    	self.Text:SetFormattedText(
	    		"%d / %d%s",
	    		self.power,
	    		self.powerForNextTrait,
	    		self.numTraitsLearnable > 0 and "\n  +" .. self.numTraitsLearnable .. " trait" or ""
	    	)
		end

		if not cfg.alwaysShowArtifactXPBar then
			ArtifactPower:SetAlpha(0)
		end

		self.ArtifactPower = ArtifactPower
	end
	-- Buffs and Debuffs
	if cfg.playerAuras then
		BuffFrame:Hide()
		core.addBuffs(self)
		core.addDebuffs(self)
	end
	-- Castbars
	if cfg.Castbars then
	    local s = CreateFrame("StatusBar", "oUF_DrkCastbar"..self.unitType, self)
		if cfg.playerCastBarOnUnitframe and cfg.showPortraits then
			s:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", 21, 0.5)
			s:SetHeight(self.Portrait:GetHeight()+1.5)
			s:SetWidth(self:GetWidth()-37.45)
		else
			s:SetPoint("BOTTOM", UIParent, "BOTTOM", cfg.playerCastBarX, cfg.playerCastBarY)
			s:SetHeight(cfg.playerCastBarHeight)
			s:SetWidth(cfg.playerCastBarWidth)
		end
	    s:SetStatusBarTexture(cfg.statusbar_texture)
	    s:SetStatusBarColor(0.5, 0.5, 1, 1)
	    s:SetFrameLevel(9)
	    --color
	    s.CastingColor = {0.5, 0.5, 1}
	    s.CompleteColor = {0.5, 1, 0}
	    s.FailColor = {1.0, 0.05, 0}
	    s.ChannelingColor = {0.5, 0.5, 1}
	    --helper
	    local h = CreateFrame("Frame", nil, s)
	    h:SetFrameLevel(0)
	    h:SetPoint("TOPLEFT", -4, 4)
	    h:SetPoint("BOTTOMRIGHT", 4, -4)
	    core.createBackdrop(h, 0)
	    --backdrop
	    local b = s:CreateTexture(nil, "BACKGROUND")
	    b:SetTexture(cfg.statusbar_texture)
	    b:SetAllPoints(s)
	    b:SetVertexColor(0.1, 0.1, 0.2, 0.7)
	    --spark
	    local sp = s:CreateTexture(nil, "OVERLAY")
	    sp:SetBlendMode("ADD")
	    sp:SetAlpha(0.5)
	    sp:SetHeight(s:GetHeight()*2.5)
	    --spell text
	    local txt = core.createFontString(s, cfg.font, cfg.fontsize.castbar, "NONE")
	    txt:SetPoint("LEFT", 4, 0)
	    txt:SetJustifyH("LEFT")
	    --time
	    local t = core.createFontString(s, cfg.font, cfg.fontsize.castbar, "NONE")
	    t:SetPoint("RIGHT", -2, 0)
	    txt:SetPoint("RIGHT", t, "LEFT", -5, 0)
	    --icon
	    local i = s:CreateTexture(nil, "ARTWORK")

		if cfg.playerCastBarOnUnitframe then
			i:SetPoint("RIGHT", s, "LEFT", 1, 0)
			i:SetSize(s:GetHeight(),s:GetHeight())
		else
			i:SetPoint("RIGHT", s, "LEFT", -5, 0)
			i:SetSize(s:GetHeight()-1, s:GetHeight()-1)
		end
	    i:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	    --helper2 for icon
	    local h2 = CreateFrame("Frame", nil, s)
	    h2:SetFrameLevel(0)
	    h2:SetPoint("TOPLEFT", i, "TOPLEFT", -4, 4)
	    h2:SetPoint("BOTTOMRIGHT", i,"BOTTOMRIGHT", 4, -4)
	    core.createBackdrop(h2, 0)

		--latency only for player unit
		local z = s:CreateTexture(nil, "OVERLAY")
		z:SetTexture(cfg.statusbar_texture)
		z:SetVertexColor(1, 0, 0, 0.6)
		z:SetPoint("TOPRIGHT")
		z:SetPoint("BOTTOMRIGHT")
		s:SetFrameLevel(10)
		s.SafeZone = z
		--custom latency display
		local l = core.createFontString(s, cfg.font, cfg.fontsize.castbar - 2, "THINOUTLINE")
		l:SetPoint("CENTER", -2, 17)
		l:SetJustifyH("RIGHT")
		l:Hide()
		s.Lag = l
		self:RegisterEvent("UNIT_SPELLCAST_SENT", cast.OnCastSent)

	    s.OnUpdate = cast.OnCastbarUpdate
	    s.PostCastStart = cast.PostCastStart
	    s.PostChannelStart = cast.PostCastStart
	    s.PostCastStop = cast.PostCastStop
	    s.PostChannelStop = cast.PostChannelStop
	    s.PostCastFailed = cast.PostCastFailed
	    s.PostCastInterrupted = cast.PostCastFailed

	    self.Castbar = s
	    self.Castbar.Text = txt
	    self.Castbar.Time = t
	    self.Castbar.Icon = i
	    self.Castbar.Spark = sp
	end
	-- Info Icons
	do
		local h = CreateFrame("Frame", nil, self)
	    h:SetAllPoints(self)
	    h:SetFrameLevel(10)
	    --Combat Icon
		local Combat = h:CreateTexture(nil, "OVERLAY")
		Combat:SetSize(15,15)
		Combat:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
		Combat:SetTexCoord(0.58, 0.90, 0.08, 0.41)
		Combat:SetPoint("BOTTOMRIGHT", 7, -7)
		self.Combat = Combat
		-- PvP Icon
		local PvP = h:CreateTexture(nil, "OVERLAY")
		local faction = PvPCheck
		if faction == "Horde" then
			PvP:SetTexCoord(0.08, 0.58, 0.045, 0.545)
		elseif faction == "Alliance" then
			PvP:SetTexCoord(0.07, 0.58, 0.06, 0.57)
		else
			PvP:SetTexCoord(0.05, 0.605, 0.015, 0.57)
		end
		PvP:SetHeight(14)
		PvP:SetWidth(14)
		PvP:SetPoint("TOPRIGHT", 7, 7)
		self.PvP = PvP
		-- Rest Icon
		local Resting = h:CreateTexture(nil, "OVERLAY")
		Resting:SetSize(15,15)
		Resting:SetPoint("BOTTOMRIGHT", -12, -8)
		Resting:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
		Resting:SetTexCoord(0.09, 0.43, 0.08, 0.42)
		self.Resting = Resting
	    --LFDRole icon
		local LFDRole = h:CreateTexture(nil, "OVERLAY")
		LFDRole:SetSize(15, 15)
		LFDRole:SetAlpha(0.9)
		LFDRole:SetPoint("BOTTOMLEFT", -6, -8)
	    self.LFDRole = LFDRole
		-- Leader, Assist, Master Looter Icon
		local li = h:CreateTexture(nil, "OVERLAY")
		li:SetPoint("TOPLEFT", self, 0, 8)
		li:SetSize(12,12)
		self.Leader = li
		local ai = h:CreateTexture(nil, "OVERLAY")
		ai:SetPoint("TOPLEFT", self, 0, 8)
		ai:SetSize(12,12)
		self.Assistant = ai
		local ml = h:CreateTexture(nil, 'OVERLAY')
		ml:SetSize(10,10)
		ml:SetPoint('LEFT', self.Leader, 'RIGHT')
		self.MasterLooter = ml
		-- Raid Marks
		local ri = h:CreateTexture(nil, "OVERLAY")
		ri:SetPoint("RIGHT", self, "LEFT", 5, 6)
		ri:SetSize(20, 20)
		self.RaidIcon = ri
	end
	-- Class Bars
	do
		local AdditionalPower = CreateFrame("StatusBar", "AdditionalPowerBar", self.Power)
		AdditionalPower:SetHeight(3)
		AdditionalPower:SetWidth(self.Power:GetWidth())
		AdditionalPower:SetPoint("TOP", self.Power, "BOTTOM", 0, -3)
		AdditionalPower:SetFrameLevel(10)
		AdditionalPower:SetStatusBarTexture(cfg.statusbar_texture)
		AdditionalPower:SetStatusBarColor(.117, .55, 1)

		AdditionalPower.bg = AdditionalPower:CreateTexture(nil, "BORDER")
		AdditionalPower.bg:SetTexture(cfg.statusbar_texture)
		AdditionalPower.bg:SetVertexColor(.05, .15, .4)
		AdditionalPower.bg:SetPoint("TOPLEFT", AdditionalPower, "TOPLEFT", 0, 0)
		AdditionalPower.bg:SetPoint("BOTTOMRIGHT", AdditionalPower, "BOTTOMRIGHT", 0, 0)

		local h = CreateFrame("Frame", nil, AdditionalPower)
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT", -4, 4)
		h:SetPoint("BOTTOMRIGHT", 4, -4)
		core.createBackdrop(h, 0)

		self.DruidMana = AdditionalPower
		self.DruidMana.bg = AdditionalPower.bg
	end
	if cfg.showRunebar and playerClass == "DEATHKNIGHT" then
		local Runes = CreateFrame("Frame", nil, self)
		Runes:SetPoint('CENTER', self.Health, 'TOP', 2, 1)
		Runes:SetHeight(5)
		Runes:SetWidth(self.Health:GetWidth()-15)

		for i= 1, 6 do
			Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, self)
			Runes[i]:SetHeight(5)
			Runes[i]:SetWidth((self.Health:GetWidth() / 6)-5)
			Runes[i]:SetStatusBarTexture(cfg.statusbar_texture)
			Runes[i]:SetFrameLevel(11)
			Runes[i]:SetStatusBarColor(0.14, 0.5, 0.6)
			Runes[i].bg = Runes[i]:CreateTexture(nil, "BORDER")
			Runes[i].bg:SetTexture(cfg.statusbar_texture)
			Runes[i].bg:SetPoint("TOPLEFT", Runes[i], "TOPLEFT", 0, 0)
			Runes[i].bg:SetPoint("BOTTOMRIGHT", Runes[i], "BOTTOMRIGHT", 0, 0)
			Runes[i].bg:SetVertexColor(0.07, 0.15, 0.15)

			local h = CreateFrame("Frame", nil, Runes[i])
			h:SetFrameLevel(10)
			h:SetPoint("TOPLEFT",-3,3)
			h:SetPoint("BOTTOMRIGHT",3,-3)
			core.createBackdrop(h,1)

			if (i == 1) then
				Runes[i]:SetPoint('LEFT', Runes, 'LEFT', 1, 0)
			else
				Runes[i]:SetPoint('TOPLEFT', Runes[i-1], 'TOPRIGHT', 2, 0)
			end
		end

		self.Runes = Runes
	end
	if cfg.showHolybar and playerClass == "PALADIN" then
		local PaladinHolyPower = CreateFrame("Frame", nil, self)
		PaladinHolyPower:SetPoint('CENTER', self.Health, 'TOP', 0, 1)
		PaladinHolyPower:SetHeight(5)
		PaladinHolyPower:SetWidth(self.Health:GetWidth() / 2 + 75)

		for i = 1, 5 do
			PaladinHolyPower[i] = CreateFrame("StatusBar", self:GetName().."_Holypower"..i, self)
			PaladinHolyPower[i]:SetHeight(5)
			PaladinHolyPower[i]:SetWidth((PaladinHolyPower:GetWidth() / 5) - 2)
			PaladinHolyPower[i]:SetStatusBarTexture(cfg.statusbar_texture)
			PaladinHolyPower[i]:SetStatusBarColor(.9, .95, .33)
			PaladinHolyPower[i]:SetFrameLevel(11)
			PaladinHolyPower[i].bg = PaladinHolyPower[i]:CreateTexture(nil, "BORDER")
			PaladinHolyPower[i].bg:SetTexture(cfg.statusbar_texture)
			PaladinHolyPower[i].bg:SetPoint("TOPLEFT", PaladinHolyPower[i], "TOPLEFT", 0, 0)
			PaladinHolyPower[i].bg:SetPoint("BOTTOMRIGHT", PaladinHolyPower[i], "BOTTOMRIGHT", 0, 0)
			PaladinHolyPower[i].bg.multiplier = 0.3

			local h = CreateFrame("Frame", nil, PaladinHolyPower[i])
			h:SetFrameLevel(10)
			h:SetPoint("TOPLEFT", -3, 3)
			h:SetPoint("BOTTOMRIGHT", 3, -3)
			core.createBackdrop(h, 1)

			if (i == 1) then
				PaladinHolyPower[i]:SetPoint('LEFT', PaladinHolyPower, 'LEFT', 1, 0)
			else
				PaladinHolyPower[i]:SetPoint('TOPLEFT', PaladinHolyPower[i-1], "TOPRIGHT", 2, 0)
			end
		end

		self.PaladinHolyPower = PaladinHolyPower
	end
	if cfg.showChibar and playerClass == "MONK" then
		local mhb = CreateFrame("Frame", "MonkHarmonyBar", self)
		mhb:SetPoint("CENTER", self.Health, "TOP", 0, 1)
		mhb:SetWidth(self.Health:GetWidth()/2+75)
		mhb:SetHeight(5)
		mhb:SetFrameLevel(10)

		for i = 1, 6 do
			mhb[i] = CreateFrame("StatusBar", "MonkHarmonyBar"..i, mhb)
			mhb[i]:SetHeight(5)
			mhb[i]:SetStatusBarTexture(cfg.statusbar_texture)
			mhb[i]:SetStatusBarColor(.9,.99,.9)
			mhb[i].bg = mhb[i]:CreateTexture(nil,"BORDER")
			mhb[i].bg:SetTexture(cfg.statusbar_texture)
			mhb[i].bg:SetVertexColor(0,0,0)
			mhb[i].bg:SetPoint("TOPLEFT",mhb[i],"TOPLEFT",0,0)
			mhb[i].bg:SetPoint("BOTTOMRIGHT",mhb[i],"BOTTOMRIGHT",0,0)
			mhb[i].bg.multiplier = .3

			local h = CreateFrame("Frame",nil,mhb[i])
			h:SetFrameLevel(mhb:GetFrameLevel())
			h:SetPoint("TOPLEFT",-3,3)
			h:SetPoint("BOTTOMRIGHT",3,-3)
			core.createBackdrop(h,1)

			if i == 1 then
				mhb[i]:SetPoint("LEFT", mhb, "LEFT", 1, 0)
			else
				mhb[i]:SetPoint("LEFT", mhb[i-1], "RIGHT", 2, 0)
			end
		end

		self.MonkHarmonyBar = mhb
	end
	if cfg.showShardbar and playerClass == "WARLOCK" then
		local wsb = CreateFrame("Frame", "WarlockSpecBars", self)
		wsb:SetPoint("CENTER", self.Health, "TOP", -6, 1)
		wsb:SetWidth(self.Health:GetWidth() - 50)
		wsb:SetHeight(5)
		wsb:SetFrameLevel(10)

		for i = 1, 5 do
			wsb[i] = CreateFrame("StatusBar", "WarlockSpecBars"..i, wsb)
			wsb[i]:SetHeight(5)
	        wsb[i]:SetWidth(wsb:GetWidth() / 5)
			wsb[i]:SetStatusBarTexture(cfg.statusbar_texture)
			wsb[i]:SetStatusBarColor(.86,.22,1)
			wsb[i].bg = wsb[i]:CreateTexture(nil,"BORDER")
			wsb[i].bg:SetTexture(cfg.statusbar_texture)
			wsb[i].bg:SetVertexColor(0,0,0)
			wsb[i].bg:SetPoint("TOPLEFT",wsb[i],"TOPLEFT",0,0)
			wsb[i].bg:SetPoint("BOTTOMRIGHT",wsb[i],"BOTTOMRIGHT",0,0)
			wsb[i].bg.multiplier = .3

			local h = CreateFrame("Frame",nil,wsb[i])
			h:SetFrameLevel(10)
			h:SetPoint("TOPLEFT",-3,3)
			h:SetPoint("BOTTOMRIGHT",3,-3)
			core.createBackdrop(h,1)

			if i == 1 then
				wsb[i]:SetPoint("LEFT", wsb, "LEFT", 1, 0)
			else
				wsb[i]:SetPoint("LEFT", wsb[i-1], "RIGHT", 2, 0)
			end
		end

		self.WarlockSpecBars = wsb
	end
	if cfg.showArcaneChargesbar and playerClass == "MAGE" then
		local MageArcaneCharges = CreateFrame("Frame", "ArcaneChargesBar", self)
		MageArcaneCharges:SetPoint("CENTER", self.Health, "TOP", -6, 1)
		MageArcaneCharges:SetWidth(self.Health:GetWidth() - 50)
		MageArcaneCharges:SetHeight(5)
		MageArcaneCharges:SetFrameLevel(10)

		for i = 1, 4 do
			MageArcaneCharges[i] = CreateFrame("StatusBar", "ArcaneChargesBar"..i, MageArcaneCharges)
			MageArcaneCharges[i]:SetHeight(5)
	        MageArcaneCharges[i]:SetWidth(MageArcaneCharges:GetWidth() / 4)
			MageArcaneCharges[i]:SetStatusBarTexture(cfg.statusbar_texture)
			MageArcaneCharges[i]:SetStatusBarColor(.15,.55,.8)
			MageArcaneCharges[i].bg = MageArcaneCharges[i]:CreateTexture(nil,"BORDER")
			MageArcaneCharges[i].bg:SetTexture(cfg.statusbar_texture)
			MageArcaneCharges[i].bg:SetVertexColor(0,0,0)
			MageArcaneCharges[i].bg:SetPoint("TOPLEFT",MageArcaneCharges[i],"TOPLEFT",0,0)
			MageArcaneCharges[i].bg:SetPoint("BOTTOMRIGHT",MageArcaneCharges[i],"BOTTOMRIGHT",0,0)
			MageArcaneCharges[i].bg.multiplier = .3

			local h = CreateFrame("Frame",nil,MageArcaneCharges[i])
			h:SetFrameLevel(10)
			h:SetPoint("TOPLEFT",-3,3)
			h:SetPoint("BOTTOMRIGHT",3,-3)
			core.createBackdrop(h,1)

			if i == 1 then
				MageArcaneCharges[i]:SetPoint("LEFT", MageArcaneCharges, "LEFT", 1, 0)
			else
				MageArcaneCharges[i]:SetPoint("LEFT", MageArcaneCharges[i-1], "RIGHT", 2, 0)
			end
		end

		self.MageArcaneCharges = MageArcaneCharges
	end
    if cfg.showComboPoints then
    	local dcp = CreateFrame("Frame", nil, self)
		dcp:SetPoint('CENTER', self.Health, 'TOP', 0, 1)
		dcp:SetHeight(5)
		dcp:SetWidth(self.Health:GetWidth()/2+75)

		for i= 1, 8 do
			dcp[i] = CreateFrame("StatusBar", self:GetName().."_CPoints"..i, self)
			dcp[i]:SetHeight(5)
			dcp[i]:SetStatusBarTexture(cfg.statusbar_texture)
			dcp[i]:SetFrameLevel(11)
			dcp[i].bg = dcp[i]:CreateTexture(nil, "BORDER")
			dcp[i].bg:SetTexture(cfg.statusbar_texture)
			dcp[i].bg:SetPoint("TOPLEFT", dcp[i], "TOPLEFT", 0, 0)
			dcp[i].bg:SetPoint("BOTTOMRIGHT", dcp[i], "BOTTOMRIGHT", 0, 0)
			dcp[i].bg.multiplier = 0.3

			local h = CreateFrame("Frame", nil, dcp[i])
			h:SetFrameLevel(10)
			h:SetPoint("TOPLEFT", -3, 3)
			h:SetPoint("BOTTOMRIGHT", 3, -3)
			core.createBackdrop(h,1)

			if (i == 1) then
				dcp[i]:SetPoint('LEFT', dcp, 'LEFT', 1, 0)
			else
				dcp[i]:SetPoint('TOPLEFT', dcp[i-1], 'TOPRIGHT', 2, 0)
			end
		end

		dcp[1]:SetStatusBarColor(.3,.9,.3)
		dcp[2]:SetStatusBarColor(.3,.9,.3)
		dcp[3]:SetStatusBarColor(.3,.9,.3)
		dcp[4]:SetStatusBarColor(.9,.9,0)
		dcp[5]:SetStatusBarColor(.9,.3,.3)
		dcp[6]:SetStatusBarColor(.9,.3,.3)
		dcp[7]:SetStatusBarColor(.9,.3,.3)
		dcp[8]:SetStatusBarColor(.9,.3,.3)

		self.DrkCPoints = dcp
	end
end

oUF:RegisterStyle("drk:player", create)
oUF:SetActiveStyle("drk:player")
oUF:Spawn("player", "oUF_DrkPlayerFrame")
