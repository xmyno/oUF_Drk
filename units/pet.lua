local addon, ns = ...
local cfg = ns.cfg
local core = ns.core
local cast = ns.cast

local create = function(self)
	self.unitType = "pet"
	self:SetSize((cfg.unitframeWidth/2-5)*cfg.unitframeScale, 25*cfg.unitframeScale)
	self:SetPoint("BOTTOMLEFT",oUF_DrkPlayerFrame,"TOPLEFT", 0, 7)
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
end

oUF:RegisterStyle("drk:pet", create)
oUF:SetActiveStyle("drk:pet")
oUF:Spawn("pet", "oUF_DrkPetFrame")
