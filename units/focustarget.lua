local addon, ns = ...
local cfg = ns.cfg
local core = ns.core

local create = function(self)
	self.unitType = "focustarget"
	self:SetSize((cfg.unitframeWidth/2-5)*cfg.unitframeScale, 25*cfg.unitframeScale)
	self:SetPoint("BOTTOMLEFT", oUF_DrkTargetFrame, "TOPLEFT", 0, 7)
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
	-- Info Icons
	do
		local h = CreateFrame("Frame", nil, self, BackdropTemplateMixin and "BackdropTemplate")
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
end

oUF:RegisterStyle("drk:focustarget", create)
oUF:SetActiveStyle("drk:focustarget")
oUF:Spawn("focustarget", "oUF_DrkFocusTargetFrame")
