local addon, ns = ...
local cfg = ns.cfg
local core = ns.core

local _, playerClass = UnitClass("player")

-- Create Target Border
local createTargetBorder = function(self)
	local glowBorder = {edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1}
	self.TargetBorder = CreateFrame("Frame", nil, self, BackdropTemplateMixin and "BackdropTemplate")
	self.TargetBorder:SetPoint("TOPLEFT", self, "TOPLEFT", -2.5, 2.5)
	self.TargetBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 3, -2.5)
	self.TargetBorder:SetBackdrop(glowBorder)
	self.TargetBorder:SetFrameLevel(5)
	self.TargetBorder:SetBackdropBorderColor(.7,.7,.7,.8)
	self.TargetBorder:Hide()
end

-- Raid Frames Target Highlight Border
local onChangedTarget = function(self, event, unit)
	if UnitIsUnit('target', self.unit) then
		self.TargetBorder:Show()
	else
		self.TargetBorder:Hide()
	end
end

local addRaidDebuffs = function(self)
	local raid_debuffs = cfg.DebuffWatchList

	local debuffs = raid_debuffs.debuffs
	local CustomFilter = function(icons, ...)
		local _, icon, _, _, _, _, dtype, _, _, _, _, _, spellID = ...
		local name = tostring(spellID)
		if debuffs[name] then
			icon.priority = debuffs[name]
			return true
		else
			icon.priority = 0
		end
	end

	local debuffs = CreateFrame("Frame", nil, self, BackdropTemplateMixin and "BackdropTemplate")
	debuffs:SetWidth(12)
	debuffs:SetHeight(12)
	debuffs:SetFrameLevel(7)
	debuffs:SetPoint("TOPRIGHT", self, "TOPRIGHT", -4, -4)
	debuffs.size = 12

	debuffs.CustomFilter = CustomFilter
	self.raidDebuffs = debuffs
end

local PostUpdateRaidFrame = function(Health, unit, min, max)

	local dc = not UnitIsConnected(unit)
	local dead = UnitIsDead(unit)
	local ghost = UnitIsGhost(unit)
	local inrange = UnitInRange(unit)

	Health:SetStatusBarColor(0.12, 0.12, 0.12, 1)
	Health:SetAlpha(1)
	Health:SetValue(min)

	if dc or dead or ghost then
		if dc then
			Health:SetAlpha(.225)
		elseif ghost then
			Health:SetValue(0)
		elseif dead then
			Health:SetValue(0)
		end
	else
		Health:SetValue(min)
	end
end

local PostUpdateRaidFramePower = function(Power, unit, min, max)
	local dc = not UnitIsConnected(unit)
	local dead = UnitIsDead(unit)
	local ghost = UnitIsGhost(unit)

	Power:SetAlpha(1)

	if dc or dead or ghost then
		if(dc) then
			Power:SetAlpha(.3)
		elseif(ghost) then
			Power:SetAlpha(.3)
		elseif(dead) then
			Power:SetAlpha(.3)
		end
	end

end


local create = function(self)
	self.unitType = "raid"
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = .6,
	}
	if cfg.enableRightClickMenu then
		self:RegisterForClicks('AnyUp')
	end

	-- Health
	do
		local s = CreateFrame("StatusBar", nil, self)
		s:SetFrameLevel(1)
		s:SetHeight(29)
		s:SetWidth(self:GetWidth())
		s:SetPoint("TOP", 0, 0)
		s:SetStatusBarColor(.12,.12,.12,1)
		s:SetStatusBarTexture(cfg.raid_texture)
		s:GetStatusBarTexture():SetHorizTile(true)

		local h = CreateFrame("Frame", nil, s, BackdropTemplateMixin and "BackdropTemplate")
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT", self, "TOPLEFT", -4, 4)
		h:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4, -4)
		core.createBackdrop(h, 0)

		local b = s:CreateTexture(nil, "BACKGROUND")
		b:SetTexture(cfg.statusbar_texture)
		b:SetAllPoints(s)

		self.Health = s
		self.Health.bg = b

		self.colors.health = { r=.12, g=.12, b=.12, a=1 }
		self.Health.colorHealth = true
		self.Health.bg:SetVertexColor( 0.4, 0.4, 0.4, 1)
		self.Health.frequentUpdates = true
		self.Health.bg.multiplier = 0.1
		self.Health.Smooth = true
	end
	-- Tag Texts
	do
		local name = core.createFontString(self.Health, cfg.raidfont, cfg.fontsize.smallunitframe, "NONE")
		name:SetPoint("LEFT", self.Health, "TOPLEFT", 1, -6)
		name:SetJustifyH("LEFT")
		name.frequentUpdates = true
		local hpval = core.createFontString(self.Health, cfg.font, cfg.fontsize.smallunitframe + 1, "OUTLINE")
		hpval:SetPoint("LEFT", self.Health, "BOTTOMLEFT", 0, 6)
		hpval.frequentUpdates = true

		name:SetPoint("RIGHT", self, "RIGHT", -1, 0)
		self:Tag(name, "[drk:color][name][drk:raidafkdnd]")
		self:Tag(hpval, "[drk:raidhp]")
	end
	-- Power
	do
		local s = CreateFrame("StatusBar", nil, self)
		s:SetFrameLevel(1)
		s:SetHeight(2)
		s:SetWidth(self:GetWidth())
	    s:SetStatusBarTexture(cfg.powerbar_texture)
		s:GetStatusBarTexture():SetHorizTile(true)
		s:SetPoint("BOTTOM", self, "BOTTOM", 0, 0)
		s.frequentUpdates = true

	    local b = s:CreateTexture(nil, "BACKGROUND")
	    b:SetTexture(cfg.powerbar_texture)
	    b:SetAllPoints(s)

	    self.Power = s
	    self.Power.bg = b
	    self.Power.colorClass = true
		self.Power.bg.multiplier = 0.35
		self.Power:SetAlpha(0.9)
	end
	-- Highlight
	core.addHighlight(self)
	-- Info Icons
	do
		local h = CreateFrame("Frame", nil, self, BackdropTemplateMixin and "BackdropTemplate")
	    h:SetAllPoints(self)
	    h:SetFrameLevel(10)

	    --LFDRole icon
		if cfg.showRoleIcons then
			local GroupRoleIndicator = h:CreateTexture(nil, 'OVERLAY')
			GroupRoleIndicator:SetSize(12, 12)
			GroupRoleIndicator:SetPoint('CENTER', self, 'RIGHT', 1, 0)
			GroupRoleIndicator:SetAlpha(cfg.showRoleIconsHoverOnly and 0 or 1)
			self.GroupRoleIndicator = GroupRoleIndicator
	    end
		-- Leader, Assist, Master Looter Icon
		-- local LeaderIndicator = h:CreateTexture(nil, "OVERLAY")
		-- LeaderIndicator:SetPoint("TOPLEFT", self, 0, 8)
		-- LeaderIndicator:SetSize(12,12)
		-- self.LeaderIndicator = LeaderIndicator
		-- local AssistantIndicator = h:CreateTexture(nil, "OVERLAY")
		-- AssistantIndicator:SetPoint("TOPLEFT", self, 0, 8)
		-- AssistantIndicator:SetSize(12,12)
		-- self.AssistantIndicator = AssistantIndicator
		local RaidTargetIndicator = h:CreateTexture(nil, "OVERLAY")
		RaidTargetIndicator:SetPoint("CENTER", self, "TOP", 0, 0)
		RaidTargetIndicator:SetSize(12, 12)
		self.RaidTargetIndicator = RaidTargetIndicator
		-- Ready Check
		local ReadyCheckIndicator = h:CreateTexture(nil, "OVERLAY")
		ReadyCheckIndicator:SetSize(14, 14)
		ReadyCheckIndicator:SetPoint("BOTTOMLEFT", self.Health, "TOPRIGHT", -13, -12)
		self.ReadyCheckIndicator = ReadyCheckIndicator
	end
	createTargetBorder(self)
	-- Heal Prediction
	if cfg.showIncHeals then
		local healing = CreateFrame('StatusBar', nil, self.Health)
		healing:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT')
		healing:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT')
		healing:SetWidth(self:GetWidth())
		healing:SetStatusBarTexture(cfg.statusbar_texture)
		healing:SetStatusBarColor(0.25, 1, 0.25, 0.5)
		healing:SetFrameLevel(1)

		local absorbs = CreateFrame('StatusBar', nil, self.Health)
		absorbs:SetPoint('TOPLEFT', healing:GetStatusBarTexture(), 'TOPRIGHT')
		absorbs:SetPoint('BOTTOMLEFT', healing:GetStatusBarTexture(), 'BOTTOMRIGHT')
		absorbs:SetWidth(self:GetWidth())
		absorbs:SetStatusBarTexture(cfg.statusbar_texture)
		absorbs:SetStatusBarColor(0.25, 0.8, 1, 0.5)
		absorbs:SetFrameLevel(1)

		self.HealthPrediction = {
			healingBar = healing,
			absorbsBar = absorbs,
			Override = core.HealthPrediction_Override
		}
	end
	-- Raid debuffs
	addRaidDebuffs(self)
	-- Raid indicators
	if cfg.showIndicators then
		self.NumbersIndicator = self.Health:CreateFontString(nil,"OVERLAY")
		self.NumbersIndicator:ClearAllPoints()
		self.NumbersIndicator:SetPoint("BOTTOMRIGHT",self.Health,"BOTTOMRIGHT",4,-4)
		self.NumbersIndicator:SetFont(cfg.font, cfg.fontsize.smallunitframe + 1,"THINOUTLINE")
		self.NumbersIndicator.frequentUpdates = .25
		self:Tag(self.NumbersIndicator,cfg.IndicatorList["NUMBERS"][playerClass])

		self.SquareIndicator = self.Health:CreateFontString(nil,"OVERLAY")
		self.SquareIndicator:ClearAllPoints()
		self.SquareIndicator:SetPoint("BOTTOMRIGHT",self.NumbersIndicator,"BOTTOMLEFT",3,1)
		self.SquareIndicator:SetFont(cfg.squarefont, cfg.fontsize.smallunitframe - 2,"THINOUTLINE")
		self.SquareIndicator.frequentUpdates = .25
		self:Tag(self.SquareIndicator,cfg.IndicatorList["SQUARE"][playerClass])
	end
	if cfg.showThreatIndicator then
		self.ThreatIndicator = self.Health:CreateFontString(nil,"OVERLAY")
		self.ThreatIndicator:ClearAllPoints()
		self.ThreatIndicator:SetPoint("LEFT",self.Health,"LEFT",1,0)
		self.ThreatIndicator:SetFont(cfg.squarefont,cfg.fontsize.smalltext - 2,"THINOUTLINE")
		self.ThreatIndicator.frequentUpdates = .25
		self:Tag(self.ThreatIndicator,"[drk:threat]")
	end

	-- Event Handlers
	self.Health.PostUpdate = PostUpdateRaidFrame
	self.Power.PostUpdate = PostUpdateRaidFramePower
	self:RegisterEvent('PLAYER_TARGET_CHANGED', onChangedTarget, true)
	self:RegisterEvent('GROUP_ROSTER_UPDATE', onChangedTarget)
end


if cfg.showRaid and cfg.raidStyle == "RECT" then
	local point = cfg.raidOrientationHorizontal and "LEFT" or "TOP"
	local mode = cfg.raidShowSolo and "custom show;" or "custom [group:party] show; [@raid2, exists] show; hide;"

	oUF:RegisterStyle('drk:raid', create)
	oUF:SetActiveStyle('drk:raid')
	local raid = {}
	for i = 1, 6 do
		local header = oUF:SpawnHeader(
		  "drkGroup"..i,
		  nil,
		  mode,
		  "showRaid",           true,
		  "point",              point,
		  "startingIndex",		1,
		  "yOffset",            -5,
		  "xoffset",            4,
		  "columnSpacing",      7,
		  "groupFilter",        tostring(i),
		  "groupBy",            "GROUP",
		  "groupingOrder",      "1,2,3,4,5,6",
		  "sortMethod",         "NAME",
		  "columnAnchorPoint",  "RIGHT",
		  "maxColumns",         5,
		  "unitsPerColumn",     5,
		  "oUF-initialConfigFunction", [[
			self:SetHeight(32)
			self:SetWidth(77)
		  ]]
		)

		if i == 1 then
			header:SetAttribute("showSolo", true)
			header:SetAttribute("showPlayer", true)
			header:SetAttribute("showParty", true)

			header:SetPoint("TOPRIGHT", UIParent, cfg.raidX, cfg.raidY)
		else
			if cfg.raidOrientationHorizontal then
				header:SetPoint("TOPLEFT",raid[i-1],"BOTTOMLEFT",0,-5)
			else
				header:SetPoint("TOPLEFT",raid[i-1],"TOPRIGHT",4,0)
			end
		end
		header:SetScale(cfg.raidScale)
		raid[i] = header
	end
end
