local addon, ns = ...
local cfg = ns.cfg
local core = ns.core

local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UnitClass = UnitClass
local UnitThreatSituation = UnitThreatSituation

local _, playerClass = UnitClass("player")

-- Create Target Border
local createTargetBorder = function(self)
	local glowBorder = {edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1}
	self.TargetBorder = CreateFrame("Frame", nil, self)
	self.TargetBorder:SetPoint("TOPLEFT", self, "TOPLEFT", -1, 1)
	self.TargetBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 1, -1)
	self.TargetBorder:SetBackdrop(glowBorder)
	self.TargetBorder:SetFrameLevel(4)
	self.TargetBorder:SetBackdropBorderColor(0.95, 0.95, 0.95, 1)
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

	local debuffs = CreateFrame("Frame", nil, self)
	debuffs:SetWidth(14)
	debuffs:SetHeight(14)
	debuffs:SetFrameLevel(7)
	debuffs:SetPoint("LEFT", self, "LEFT", 20, 4)
	debuffs.size = 12

	debuffs.CustomFilter = CustomFilter
	self.raidDebuffs = debuffs
end

local PostUpdateRaidFrame = function(Health, unit, min, max)

	local dc = not UnitIsConnected(unit)
	local dead = UnitIsDead(unit)
	local ghost = UnitIsGhost(unit)
	local inrange = UnitInRange(unit)

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

-- local PostUpdateRaidFramePower = function(Power, unit, min, max)
-- 	local dc = not UnitIsConnected(unit)
-- 	local dead = UnitIsDead(unit)
-- 	local ghost = UnitIsGhost(unit)

-- 	Power:SetAlpha(1)

-- 	if dc or dead or ghost then
-- 		if(dc) then
-- 			Power:SetAlpha(.3)
-- 		elseif(ghost) then
-- 			Power:SetAlpha(.3)
-- 		elseif(dead) then
-- 			Power:SetAlpha(.3)
-- 		end
-- 	end

-- end

local ThreatUpdate = function(self)
	local status = UnitThreatSituation(self.unit)
	if status and status > 1 then
		self.ThreatIndicator:SetAlpha(1)
	else
		self.ThreatIndicator:SetAlpha(0)
	end
end


local create = function(self)
	self.unitType = "raid"
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = .4,
	}
	if cfg.enableRightClickMenu then
		self:RegisterForClicks('AnyUp')
	end

	-- Health
	do
		local s = CreateFrame("StatusBar", nil, self)
		s:SetFrameLevel(1)
		s:SetHeight(14)
		s:SetWidth(self:GetWidth())
		s:SetPoint("TOP", 0, 0)
		s:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
		s:GetStatusBarTexture():SetHorizTile(true)

		local h = CreateFrame("Frame", nil, s)
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 3)
		h:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 3, -3)
		core.createBackdrop(h, 1)

		local b = s:CreateTexture(nil, "BACKGROUND")
		b:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
		b:SetAllPoints(s)

		self.Health = s
		self.Health.bg = b

		self.Health.colorClass = true
		self.Health.colorDisconnected = true
		self.Health.colorClassNPC = true
		self.Health.colorReaction = true
		--self.Health.bg:SetVertexColor(0.4, 0.4, 0.4, 1)
		self.Health.frequentUpdates = true
		self.Health.bg.multiplier = 0.1
		self.Health.Smooth = true
	end
	-- Power
	-- do
	-- 	local s = CreateFrame("StatusBar", nil, self)
	-- 	s:SetFrameLevel(1)
	-- 	s:SetHeight(1)
	-- 	s:SetWidth(self:GetWidth())
	--     s:SetStatusBarTexture(cfg.powerbar_texture)
	-- 	s:GetStatusBarTexture():SetHorizTile(true)
	-- 	s:SetPoint("BOTTOM", self, "BOTTOM", 0, 0)
	-- 	s.frequentUpdates = true

	--     local b = s:CreateTexture(nil, "BACKGROUND")
	--     b:SetTexture(cfg.powerbar_texture)
	--     b:SetAllPoints(s)

	--     self.Power = s
	--     self.Power.bg = b
	--     self.Power.colorPower = true
	-- 	self.Power.bg.multiplier = 0.35
	-- 	self.Power:SetAlpha(0.9)
	-- end
	-- Highlight
	core.addHighlight(self)
	-- Info Icons
	do
		local h = CreateFrame("Frame", nil, self)
	    h:SetAllPoints(self)
	    h:SetFrameLevel(10)

	    --LFDRole icon
		if cfg.showRoleIcons then
			local LFDRole = h:CreateTexture(nil, 'OVERLAY')
			LFDRole:SetSize(10, 10)
			LFDRole:SetPoint('CENTER', self, 'LEFT', 0, 0)
			LFDRole:SetAlpha(1)
			self.LFDRole = LFDRole
	    end
		-- Leader, Assist, Master Looter Icon
		local li = h:CreateTexture(nil, "OVERLAY")
		li:SetPoint("TOPLEFT", self, 2, 7)
		li:SetSize(10, 10)
		self.Leader = li
		local ai = h:CreateTexture(nil, "OVERLAY")
		ai:SetPoint("TOPLEFT", self, 2, 7)
		ai:SetSize(10, 10)
		self.Assistant = ai
		local ml = h:CreateTexture(nil, 'OVERLAY')
		ml:SetSize(9, 9)
		ml:SetPoint('LEFT', self.Leader, 'RIGHT')
		self.MasterLooter = ml
		-- Raid Marks
		local ri = h:CreateTexture(nil, "OVERLAY")
		ri:SetPoint("TOPRIGHT", self, "TOPRIGHT", -28, 6)
		ri:SetSize(11, 11)
		self.RaidIcon = ri
		-- Ready Check
		local rc = h:CreateTexture(nil, "OVERLAY")
		rc:SetSize(12, 12)
		rc:SetPoint("TOPRIGHT", self.Health, "TOPRIGHT", -16, 7)
		self.ReadyCheck = rc
	end
	-- Tag Texts
	do
		local name = core.createFontString(self.Health, cfg.font, cfg.fontsize.unitframe, "OUTLINE")
		name:SetPoint("LEFT", self, "RIGHT", 3, 0)
		name:SetJustifyH("LEFT")
		self.NameText = name
		local hpval = core.createFontString(self.Health, cfg.font, cfg.fontsize.unitframe - 1, "OUTLINE")
		hpval:SetPoint("CENTER", self, "CENTER", 0, 0)
		hpval:SetJustifyH("MIDDLE")
		hpval.frequentUpdates = true

		self:Tag(name, "[drk:color][name][drk:raidafkdnd]")
		self:Tag(hpval, "[drk:raidhp]")
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

		self.HealPrediction = {
			healingBar = healing,
			absorbsBar = absorbs,
			Override = core.HealPrediction_Override
		}
	end
	addRaidDebuffs(self)
	if cfg.showIndicators then
		local numbers = self.Health:CreateFontString(nil, "OVERLAY")
		numbers:ClearAllPoints()
		numbers:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, 0)
		numbers:SetFont(cfg.font, cfg.fontsize.unitframe - 1, "OUTLINE")
		numbers.frequentUpdates = 0.25
		self:Tag(numbers, cfg.IndicatorList["NUMBERS"][playerClass])

		local squares = self.Health:CreateFontString(nil, "OVERLAY")
		squares:ClearAllPoints()
		squares:SetPoint("TOPRIGHT", numbers, "TOPLEFT", 0, 1)
		squares:SetFont(cfg.squarefont, cfg.fontsize.unitframe - 4, "OUTLINE")
		squares.frequentUpdates = 0.25
		self:Tag(squares, cfg.IndicatorList["SQUARE"][playerClass])
	end
	if cfg.showThreatIndicator then
		local threat = self.Health:CreateTexture(nil, "OVERLAY")
		threat:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
		threat:SetPoint("LEFT", self.Health, "RIGHT", 1, 0)
		threat:SetVertexColor(0.8, 0.2, 0)
		threat:SetWidth(1)
		threat:SetHeight(self:GetHeight())
		threat:SetAlpha(0)

		self.ThreatIndicator = threat
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', ThreatUpdate)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', ThreatUpdate)
	end

		--local threat = self.Health:

		-- local threat = self.Health:CreateFontString(nil, "OVERLAY")
		-- threat:ClearAllPoints()
		-- threat:SetPoint("LEFT", self.Health, "LEFT", 2, 0)
		-- threat:SetFont(cfg.squarefont, 6, "OUTLINE")
		-- threat.frequentUpdates = 0.25
		-- self:Tag(threat,"[drk:threat]")


	-- Event Handlers
	self.Health.PostUpdate = PostUpdateRaidFrame
	--self.Power.PostUpdate = PostUpdateRaidFramePower
	self:RegisterEvent('PLAYER_TARGET_CHANGED', onChangedTarget)
	self:RegisterEvent('GROUP_ROSTER_UPDATE', onChangedTarget)


end


if cfg.showRaid and cfg.raidStyle == "BARS" then

	local mode = cfg.raidShowSolo and "custom show;" or "party,raid10,raid25,raid40;"

	oUF:RegisterStyle('drk:raid', create)
	oUF:SetActiveStyle('drk:raid')
	local raid = {}
	for i = 1, 6 do
		local header = oUF:SpawnHeader(
		  "drkGroup"..i,
		  nil,
		  mode,
		  "showRaid",           true,
		  "point",              "TOP",
		  "startingIndex",		1,
		  "yOffset",            -4,
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
			self:SetHeight(14)
			self:SetWidth(125)
		  ]]
		)

		if i == 1 then
			header:SetAttribute("showSolo", true)
			header:SetAttribute("showPlayer", true)
			header:SetAttribute("showParty", true)

			header:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 10, -125)
		else
			header:SetPoint("TOPLEFT", raid[i-1], "BOTTOMLEFT", 0, -8)
		end

		header:SetScale(cfg.raidScale)
		raid[i] = header
	end
end
