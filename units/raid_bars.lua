local addon, ns = ...
local cfg = ns.cfg
local core = ns.core

local UnitClass, GetInstanceInfo, DIFFICULTY_PRIMARYRAID_MYTHIC
    = UnitClass, GetInstanceInfo, DIFFICULTY_PRIMARYRAID_MYTHIC

local _, playerClass = UnitClass("player")
local raid, n, max

-- Create Target Border
local CreateTargetBorder = function(self)
	local backdrop = {edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1}
	local targetBorder = CreateFrame("Frame", nil, self, BackdropTemplateMixin and "BackdropTemplate")
	targetBorder:SetPoint("TOPLEFT", self, "TOPLEFT", -2, 2)
	targetBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 2, -2)
	targetBorder:SetBackdrop(backdrop)
	targetBorder:SetFrameLevel(5)
	targetBorder:SetBackdropBorderColor(0.95, 0.95, 0.95, 1)
	targetBorder:Hide()
	self.TargetBorder = targetBorder
end

local CreateResInfoBorder = function(self)
	local backdrop = {edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1}
	local resInfoBorder = CreateFrame("Frame", nil, self, BackdropTemplateMixin and "BackdropTemplate")
	resInfoBorder:SetPoint("TOPLEFT", self, "TOPLEFT", -2, 2)
	resInfoBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 2, -2)
	resInfoBorder:SetBackdrop(backdrop)
	resInfoBorder:SetFrameLevel(4)
	resInfoBorder:SetBackdropBorderColor(0.85, 0.65, 0.12, 1)
	resInfoBorder:Hide()
	self.ResInfo = resInfoBorder
end

-- Raid Frames Target Highlight Border
local OnChangedTarget = function(self, event)
	if UnitIsUnit('target', self.unit) then
		self.TargetBorder:Show()
	else
		self.TargetBorder:Hide()
	end
end

local UpdateLayout = function()
	if InCombatLockdown() then return end

	if (select(3, GetInstanceInfo())) == DIFFICULTY_PRIMARYRAID_MYTHIC then
		raid[5]:SetAlpha(0)
		raid[6]:SetAlpha(0)
		max = 20
	else
		raid[5]:SetAlpha(1)
		raid[6]:SetAlpha(1)
		max = 30
	end

	n = math.min(GetNumGroupMembers(), max)
	for i, header in next, raid do
		if i == 1 then
			local offset, anchor
			if cfg.raidGrowth == "UP" then
				offset = n * 19 + cfg.raidOffsetY
				anchor = "TOPLEFT"
			elseif cfg.raidGrowth == "HOVER" then
				offset = n * 15 + cfg.raidOffsetY
				anchor = "LEFT"
			elseif cfg.raidGrowth == "DOWN" then
				offset = cfg.raidOffsetY
				anchor = "TOPLEFT"
			end
			header:SetPoint("TOPLEFT", UIParent, anchor, 10, offset)
		else
			header:SetPoint("TOPLEFT", raid[i-1], "BOTTOMLEFT", 0, -10)
		end
	end
end

local AddRaidDebuffs = function(self)
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
	debuffs:SetWidth(16)
	debuffs:SetHeight(16)
	debuffs:SetFrameLevel(7)
	debuffs:SetPoint("RIGHT", self, "RIGHT", -35, 4)
	debuffs.size = 16

	debuffs.CustomFilter = CustomFilter
	self.raidDebuffs = debuffs
end

local PostUpdateRaidFrame = function(Health, unit, min, max)

	local dc = not UnitIsConnected(unit)
	local dead = UnitIsDead(unit)
	local ghost = UnitIsGhost(unit)

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


local create = function(self)
	self.unitType = "raid"
	self.Range = {
		insideAlpha = .9,
		outsideAlpha = .2,
	}
	if cfg.enableRightClickMenu then
		self:RegisterForClicks('AnyUp')
	end

	-- Health
	do
		local s = CreateFrame("StatusBar", nil, self)
		s:SetFrameLevel(1)
		s:SetHeight(15)
		s:SetWidth(self:GetWidth())
		s:SetPoint("TOP", 0, 0)
		s:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
		s:GetStatusBarTexture():SetHorizTile(true)

		local h = CreateFrame("Frame", nil, s, BackdropTemplateMixin and "BackdropTemplate")
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
	-- Highlight
	core.addHighlight(self)
	-- Info Icons
	do
		local h = CreateFrame("Frame", nil, self)
	    h:SetAllPoints(self)
	    h:SetFrameLevel(10)

	    --LFDRole icon
		if cfg.showRoleIcons then
			local GroupRoleIndicator = h:CreateTexture(nil, 'OVERLAY')
			GroupRoleIndicator:SetSize(10, 10)
			GroupRoleIndicator:SetPoint('CENTER', self, 'LEFT', 0, -6)
			GroupRoleIndicator:SetAlpha(cfg.showRoleIconsHoverOnly and 0 or 1)
			self.GroupRoleIndicator = GroupRoleIndicator
	    end
		-- Leader, Assist, Master Looter Icon
		local LeaderIndicator = h:CreateTexture(nil, "OVERLAY")
		LeaderIndicator:SetPoint("TOPLEFT", self, 2, 5)
		LeaderIndicator:SetSize(11, 11)
		self.LeaderIndicator = LeaderIndicator
		local AssistantIndicator = h:CreateTexture(nil, "OVERLAY")
		AssistantIndicator:SetPoint("TOPLEFT", self, 2, 5)
		AssistantIndicator:SetSize(11, 11)
		self.AssistantIndicator = AssistantIndicator
		-- Raid Marks
		local RaidTargetIndicator = h:CreateTexture(nil, "OVERLAY")
		RaidTargetIndicator:SetPoint("TOP", self, "TOP", -30, 5)
		RaidTargetIndicator:SetSize(13, 13)
		self.RaidTargetIndicator = RaidTargetIndicator
		-- Ready Check
		local ReadyCheckIndicator = h:CreateTexture(nil, "OVERLAY")
		ReadyCheckIndicator:SetSize(12, 12)
		ReadyCheckIndicator:SetPoint("RIGHT", self.Health, "RIGHT", 4, 0)
		self.ReadyCheckIndicator = ReadyCheckIndicator
	end
	-- Tag Texts
	do
		local name = core.createFontString(self.Health, cfg.font, cfg.fontsize.unitframe, "OUTLINE")
		name:SetPoint("LEFT", self, "RIGHT", 3, 0)
		name:SetJustifyH("LEFT")
		self:Tag(name, "[drk:name+threat][drk:raidafkdnd]")

		local hpval = core.createFontString(self.Health, cfg.font, cfg.fontsize.unitframe, "OUTLINE")
		hpval:SetPoint("CENTER", self, "CENTER", 0, 0)
		hpval:SetJustifyH("MIDDLE")
		hpval.frequentUpdates = true
		self:Tag(hpval, "[drk:raidhp]")
	end
	CreateTargetBorder(self)
	CreateResInfoBorder(self)
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
		absorbs:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT')
		absorbs:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT')
		absorbs:SetWidth(self:GetWidth())
		absorbs:SetStatusBarTexture(cfg.statusbar_texture)
		absorbs:SetStatusBarColor(0.25, 0.8, 1, 0.5)
		absorbs:SetFrameLevel(1)

		self.HealthPrediction = {
			frequentUpdates = true,
			healingBar = healing,
			absorbsBar = absorbs,
			Override = core.HealthPrediction_Override
		}
	end
	AddRaidDebuffs(self)
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

	-- Event Handlers
	self.Health.PostUpdate = PostUpdateRaidFrame
	self:RegisterEvent("PLAYER_TARGET_CHANGED", OnChangedTarget, true)
	self:RegisterEvent("GROUP_ROSTER_UPDATE", function(self, event)
		OnChangedTarget(self, event)
		UpdateLayout()
	end)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", UpdateLayout, true)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateLayout)

end


if cfg.showRaid and cfg.raidStyle == "BARS" then

	local mode = cfg.raidShowSolo and "custom show;" or "custom [group:party] show; [@raid2, exists] show; hide;"

	oUF:RegisterStyle('drk:raid', create)
	oUF:SetActiveStyle('drk:raid')
	raid = {}
	for i = 1, 6 do
		local header = oUF:SpawnHeader(
		  "drkGroup"..i,
		  nil,
		  mode,
		  "showRaid",           true,
		  "point",              "TOP",
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
			self:SetHeight(15)
			self:SetWidth(150)
		  ]]
		)

		if i == 1 then
			header:SetAttribute("showSolo", true)
			header:SetAttribute("showPlayer", true)
			header:SetAttribute("showParty", true)
		end

		header:SetScale(cfg.raidScale)
		header:SetFrameStrata("LOW")
		raid[i] = header
	end

	UpdateLayout()
end
