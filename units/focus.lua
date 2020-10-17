local addon, ns = ...
local cfg = ns.cfg
local core = ns.core
local cast = ns.cast


local create = function(self)
	self.unitType = "focus"
	self:SetSize((cfg.unitframeWidth/2-5)*cfg.unitframeScale, 25*cfg.unitframeScale)
	self:SetPoint("BOTTOMRIGHT", oUF_DrkPlayerFrame, "TOPRIGHT", 0, 7)
	self:RegisterForClicks('AnyUp')

	-- Health
	do
		local s = CreateFrame("StatusBar", nil, self)
		s:SetFrameLevel(1)
		s:SetHeight(self:GetHeight() * 0.76)
		s:SetWidth(self:GetWidth())
		s:SetPoint("TOP", 0, 0)
		s:SetStatusBarTexture(cfg.statusbar_texture)
		s:GetStatusBarTexture():SetHorizTile(true)

		local h = CreateFrame("Frame", nil, s, BackdropTemplateMixin and "BackdropTemplate")
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT", -4, 4)
		h:SetPoint("BOTTOMRIGHT", 4, -10*cfg.unitframeScale) -- TODO: check
		core.createBackdrop(h, 0)

		local b = s:CreateTexture(nil, "BACKGROUND")
		b:SetTexture([[Interface\ChatFrame\ChatFrameBackground]])
		b:SetAllPoints(s)

		self.Health = s
		self.Health.bg = b

		self.Health.frequentUpdates = false
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Health.Smooth = true
	end
	-- Tag Texts
	do
		local name = core.createFontString(self.Health, cfg.font, cfg.fontsize.smallunitframe, "NONE")
		name:SetPoint("LEFT", self.Health, "TOPLEFT", 3, -10)
		name:SetJustifyH("LEFT")
		name.frequentUpdates = true
		local hpval = core.createFontString(self.Health, cfg.font, cfg.fontsize.smallunitframe, "NONE")
		hpval:SetPoint("RIGHT", self.Health, "TOPRIGHT", -3, -10)
		hpval.frequentUpdates = true

		name:SetPoint("RIGHT", hpval, "LEFT", -2, 0)
		self:Tag(name, "[drk:color][name]")
		self:Tag(hpval, "[drk:hp]")
	end
	-- Power
	do
		local s = CreateFrame("StatusBar", nil, self)
		s:SetFrameLevel(1)
		s:SetHeight(self:GetHeight() * 0.2)
		s:SetWidth(self:GetWidth())
	    s:SetStatusBarTexture(cfg.powerbar_texture)
		s:GetStatusBarTexture():SetHorizTile(true)
		s:SetPoint("BOTTOM", self, "BOTTOM", 0, 0)
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
	    self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.colorHealth = true
		self.Power.bg.multiplier = 0.5
	end
	-- Highlight
	core.addHighlight(self)
	-- Castbars
	if cfg.Castbars then
	    local s = CreateFrame("StatusBar", "oUF_DrkCastbar"..self.unitType, self)
		s:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 19, 3)
		s:SetHeight(18)
		s:SetWidth(self:GetWidth() - 19)
	    s:SetStatusBarTexture(cfg.statusbar_texture)
	    s:SetStatusBarColor(0.5, 0.5, 1, 1)
	    s:SetFrameLevel(9)
	    --color
	    s.CastingColor = {0.5, 0.5, 1}
	    s.CompleteColor = {0.5, 1, 0}
	    s.FailColor = {1.0, 0.05, 0}
	    s.ChannelingColor = {0.5, 0.5, 1}
	    s.NotInterruptableColor = {1, 0.2, 0}
	    --helper
	    local h = CreateFrame("Frame", nil, s, BackdropTemplateMixin and "BackdropTemplate")
	    h:SetFrameLevel(0)
	    h:SetPoint("TOPLEFT", -4, 4)
	    h:SetPoint("BOTTOMRIGHT", 4, -4)
	    core.createBackdrop(h, 0)
	    --backdrop
		local b = s:CreateTexture(nil, "BACKGROUND")
	    b:SetTexture(cfg.statusbar_texture)
	    b:SetAllPoints(s)
	    b:SetVertexColor(0.5*0.2, 0.5*0.2, 1*0.2, 0.7)
	    --spark
	    local sp = s:CreateTexture(nil, "OVERLAY")
	    sp:SetBlendMode("ADD")
	    sp:SetAlpha(0.5)
	    sp:SetHeight(s:GetHeight()*2.5)
	    --spell text
	    local txt = core.createFontString(s, cfg.font, cfg.fontsize.smallunitframe, "NONE")
	    txt:SetPoint("LEFT", 4, 0)
	    txt:SetJustifyH("LEFT")
	    --time
	    local t = core.createFontString(s, cfg.font, cfg.fontsize.smallunitframe, "NONE")
	    t:SetPoint("RIGHT", -2, 0)
	    txt:SetPoint("RIGHT", t, "LEFT", -5, 0)
	    --icon
	    local i = s:CreateTexture(nil, "ARTWORK")
		i:SetPoint("RIGHT",s,"LEFT",-1,0)
		i:SetSize(s:GetHeight(),s:GetHeight())
	    i:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	    --helper2 for icon
	    local h2 = CreateFrame("Frame", nil, s, BackdropTemplateMixin and "BackdropTemplate")
	    h2:SetFrameLevel(0)
	    h2:SetPoint("TOPLEFT", i, "TOPLEFT", -4, 4)
	    h2:SetPoint("BOTTOMRIGHT", i,"BOTTOMRIGHT", 4, -4)
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
	-- Info Icons
	do
		local h = CreateFrame("Frame", nil, self)
	    h:SetAllPoints(self)
	    h:SetFrameLevel(10)
		-- Leader, Assist, Master Looter Icon
		local LeaderIndicator = h:CreateTexture(nil, "OVERLAY")
		LeaderIndicator:SetPoint("TOPLEFT", self, 0, 8)
		LeaderIndicator:SetSize(12,12)
		self.LeaderIndicator = LeaderIndicator
		local AssistantIndicator = h:CreateTexture(nil, "OVERLAY")
		AssistantIndicator:SetPoint("TOPLEFT", self, 0, 8)
		AssistantIndicator:SetSize(12,12)
		self.AssistantIndicator = AssistantIndicator
		-- Raid Marks
		local RaidTargetIndicator = h:CreateTexture(nil, "OVERLAY")
		RaidTargetIndicator:SetPoint("CENTER", self, "TOP", 0, 2)
		RaidTargetIndicator:SetSize(20, 20)
		self.RaidTargetIndicator = RaidTargetIndicator
	end
	-- Buffs/Debuffs
	if cfg.focusBuffs or cfg.focusDebuffs then
		local b = CreateFrame("Frame", nil, self)
	    b.size = 20
		b.num = 5
		b.onlyShowPlayer = false
	    b.spacing = 5
	    b:SetHeight(b.size)
	    b:SetWidth(self:GetWidth())
		b:SetPoint("TOPLEFT", self, "TOPRIGHT", 4, 0)
		b.initialAnchor = "TOPLEFT"
		b["growth-x"] = "RIGHT"
		b["growth-y"] = "DOWN"
	    b.PostCreateIcon = core.PostCreateIcon
	    b.PostUpdateIcon = core.PostUpdateIcon
		if cfg.focusBuffs then self.Buffs = b end
		if cfg.focusDebuffs and not cfg.focusBuffs then self.Debuffs = b end
	end
end

oUF:RegisterStyle("drk:focus", create)
oUF:SetActiveStyle("drk:focus")
oUF:Spawn("focus", "oUF_DrkFocusFrame")
