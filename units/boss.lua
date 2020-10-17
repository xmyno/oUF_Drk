local addon, ns = ...
local cfg = ns.cfg
local core = ns.core
local cast = ns.cast


local create = function(self)
	self.unitType = "boss"
	self:SetSize(cfg.bossWidth*cfg.unitframeScale, 50*cfg.unitframeScale)

	-- Health
	do
		local s = CreateFrame("StatusBar", nil, self)
		s:SetFrameLevel(1)
		s:SetHeight(30)
		s:SetWidth(self:GetWidth())
		s:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
		s:SetStatusBarTexture(cfg.statusbar_texture)
		s:GetStatusBarTexture():SetHorizTile(true)

		local h = CreateFrame("Frame", nil, s, BackdropTemplateMixin and "BackdropTemplate")
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT", -4, 4)
		h:SetPoint("BOTTOMRIGHT", 4, -4)
		core.createBackdrop(h, 0)

		local b = s:CreateTexture(nil, "BACKGROUND")
		b:SetTexture([[Interface\ChatFrame\ChatFrameBackground]])
		b:SetAllPoints(s)

		self.Health = s
		self.Health.bg = b

		self.Health.colorSmooth = true
		self.Health.frequentUpdates = true
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
		self:Tag(name, "[drk:color][name]")
		self:Tag(hpval, "[drk:hp]")
	end
	-- Power
	do
		local s = CreateFrame("StatusBar", nil, self)
		s:SetFrameLevel(1)
		s:SetHeight(8)
		s:SetWidth(self:GetWidth())
	    s:SetStatusBarTexture(cfg.powerbar_texture)
		s:GetStatusBarTexture():SetHorizTile(true)
		s:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -3)
		s.frequentUpdates = true

		local h = CreateFrame("Frame", nil, s, BackdropTemplateMixin and "BackdropTemplate")
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
		self.Power.colorReaction = true
		self.Power.colorHealth = true
		self.Power.bg.multiplier = 0.2
		self.Power.Smooth = true
	end
	-- Highlight
	core.addHighlight(self)
	-- AltPowerBar
	do
		local s = CreateFrame("StatusBar", nil, self.Power)
		s:SetFrameLevel(1)
		s:SetPoint("BOTTOM", self.Power, "BOTTOM", 0, -7)
		s:SetSize(self:GetWidth()-.5, 3)
		s:SetStatusBarTexture(cfg.powerbar_texture)
		s:GetStatusBarTexture():SetHorizTile(false)
		s:SetStatusBarColor(235/255, 235/255, 235/255)
		self.AlternativePower = s

		local h = CreateFrame("Frame", nil, s, BackdropTemplateMixin and "BackdropTemplate")
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT", -3, 3)
		h:SetPoint("BOTTOMRIGHT", 3, -3)
		core.createBackdrop(h, 1)

	    local b = s:CreateTexture(nil, "BACKGROUND")
	    b:SetTexture(cfg.powerbar_texture)
	    b:SetAllPoints(s)
		b:SetVertexColor(45/255, 45/255, 45/255)
		self.AlternativePower.bg = b
	end
	-- Castbar
	if cfg.Castbars then
	    local s = CreateFrame("StatusBar", "oUF_DrkCastbar"..self.unitType, self)
		s:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 17, -3)
		s:SetHeight(16)
		s:SetWidth(self:GetWidth() - 17)
	    s:SetStatusBarTexture(cfg.statusbar_texture)
	    s:SetStatusBarColor(.5, .5, 1, 1)
	    s:SetFrameLevel(9)
	    --color
	    s.CastingColor = {.5, .5, 1}
	    s.CompleteColor = {0.5, 1, 0}
	    s.FailColor = {1.0, 0.05, 0}
	    s.ChannelingColor = {.5, .5, 1}
	    s.NotInterruptableColor = {1, 0.2, 0}
	    --helper
	    local h = CreateFrame("Frame", nil, s, BackdropTemplateMixin and "BackdropTemplate")
	    h:SetFrameLevel(0)
	    h:SetPoint("TOPLEFT",-4,4)
	    h:SetPoint("BOTTOMRIGHT",4,-4)
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
		i:SetPoint("RIGHT", s, "LEFT", -1, 0)
		i:SetSize(s:GetHeight(), s:GetHeight())
	    i:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	    --helper2 for icon
	    local h2 = CreateFrame("Frame", nil, s, BackdropTemplateMixin and "BackdropTemplate")
	    h2:SetFrameLevel(0)
	    h2:SetPoint("TOPLEFT", i, "TOPLEFT", -4, 4)
	    h2:SetPoint("BOTTOMRIGHT", i, "BOTTOMRIGHT", 4, -4)
	    core.createBackdrop(h2, 0)

	    s.OnUpdate = cast.OnCastbarUpdate
	    s.PostCastStart = cast.PostCastStart
	    s.PostCastStop = cast.PostCastStop
	    s.PostCastFail = cast.PostCastFail

	    self.Castbar = s
	    self.Castbar.Text = txt
	    self.Castbar.Time = t
	    self.Castbar.Icon = i
	    self.Castbar.Spark = sp
	end
	-- Buffs
	do
		local b = CreateFrame("Frame", nil, self)
	    b.size = 20
		b.num = 4
		b.onlyShowPlayer = false
	    b.spacing = 5
	    b:SetHeight(b.size)
	    b:SetWidth(self:GetWidth())
		if cfg.bossSide == "LEFT" then
			b:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 4, 0)
			b.initialAnchor = "TOPLEFT"
			b["growth-x"] = "RIGHT"
		elseif cfg.bossSide == "RIGHT" then
			b:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -4, 0)
			b.initialAnchor = "TOPRIGHT"
			b["growth-x"] = "LEFT"
		end
		b["growth-y"] = "DOWN"
	    b.PostCreateIcon = core.PostCreateIcon
	    b.PostUpdateIcon = core.PostUpdateIcon

	    self.Buffs = b
	end
	do
		local b = CreateFrame("Frame", nil, self)
	    b.size = 20
		b.num = 4
		b.onlyShowPlayer = false
	    b.spacing = 5
	    b:SetHeight(b.size)
	    b:SetWidth(self:GetWidth())
	    if cfg.bossSide == "LEFT" then
			b:SetPoint("BOTTOMLEFT", self.Power, "BOTTOMRIGHT", 4, 0)
			b.initialAnchor = "TOPLEFT"
			b["growth-x"] = "RIGHT"
		elseif cfg.bossSide == "RIGHT" then
			b:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMLEFT", -4, 0)
			b.initialAnchor = "TOPRIGHT"
			b["growth-x"] = "LEFT"
		end
		b["growth-y"] = "DOWN"
	    b.PostCreateIcon = core.PostCreateIcon
	    b.PostUpdateIcon = core.PostUpdateIcon

	    self.Debuffs = b
	end
end

oUF:RegisterStyle('drk:boss', create)
oUF:SetActiveStyle('drk:boss')
local bossX = (cfg.bossSide == "RIGHT") and -cfg.bossX or cfg.bossX
oUF:Spawn("boss1", "oUF_DrkBossFrame1"):SetPoint("TOP"..cfg.bossSide, UIParent, cfg.bossSide, bossX, cfg.bossY)
oUF:Spawn("boss2", "oUF_DrkBossFrame2"):SetPoint("TOP"..cfg.bossSide, UIParent, cfg.bossSide, bossX, cfg.bossY + 75 * (cfg.bossSide == "RIGHT" and -1 or 1))
oUF:Spawn("boss3", "oUF_DrkBossFrame3"):SetPoint("TOP"..cfg.bossSide, UIParent, cfg.bossSide, bossX, cfg.bossY + 150 * (cfg.bossSide == "RIGHT" and -1 or 1))
oUF:Spawn("boss4", "oUF_DrkBossFrame4"):SetPoint("TOP"..cfg.bossSide, UIParent, cfg.bossSide, bossX, cfg.bossY + 225 * (cfg.bossSide == "RIGHT" and -1 or 1))
oUF:Spawn("boss5", "oUF_DrkBossFrame5"):SetPoint("TOP"..cfg.bossSide, UIParent, cfg.bossSide, bossX, cfg.bossY + 300 * (cfg.bossSide == "RIGHT" and -1 or 1))
