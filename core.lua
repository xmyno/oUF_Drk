local addon, ns = ...

local cfg = ns.cfg
local lib = ns.lib

oUF.colors.smooth = {
	1, 0, 0, --low health
	1, .196, .196, --half health
	.165, .188, .196 --max health
}

-----------------------
-- Style Functions
-----------------------

local UnitSpecific = {

	player = function(self, ...)

		self.mystyle = "player"

		-- Size and Scale
		self:SetSize(cfg.unitframeWidth*cfg.unitframeScale, 50*cfg.unitframeScale)

		-- Generate Bars
		lib.addHealthBar(self)
		lib.addStrings(self)
		lib.addHighlight(self)
		lib.addPowerBar(self)
		lib.addPortrait(self)

		if cfg.AltPowerBarPlayer then lib.addAltPowerBar(self) end
		lib.addAltPowerBarString(self)
		if IsAddOnLoaded("oUF_Experience") then lib.addExperienceBar(self) end
		if IsAddOnLoaded("oUF_ArtifactPower") then lib.addArtifactPowerBar(self) end

		-- Buffs and Debuffs
		if cfg.playerAuras then
			BuffFrame:Hide()
			lib.addBuffs(self)
			lib.addDebuffs(self)
		end

		self.Health.frequentUpdates = true
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorClass = true
		self.Power.bg.multiplier = 0.5

		-- oUF_Smooth
		self.Health.Smooth = true
		self.Power.Smooth = true

		-- Elements
		lib.addCastBar(self)
		lib.addInfoIcons(self)
		lib.addHealPred(self)
		lib.addMirrorCastBar(self)

		-- Class Bars
		lib.addAdditionalPower(self)
		if cfg.showRunebar then lib.addRunes(self) end
		if cfg.showHolybar then lib.addHolyPower(self) end
		if cfg.showHarmonybar then lib.addHarmony(self) end
		if cfg.showShardbar then lib.addShards(self) end
		if cfg.showArcaneChargesbar then lib.addArcaneCharges(self) end
        if cfg.showComboPoints then lib.addCPoints(self) end

		-- Event Handlers
		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", cfg.updateSpec)

	end,

	target = function(self, ...)

		self.mystyle = "target"

		-- Size and Scale
		self:SetSize(cfg.unitframeWidth*cfg.unitframeScale, 50*cfg.unitframeScale)

		-- Generate Bars
		lib.addHealthBar(self)
		lib.addStrings(self)
		lib.addHighlight(self)
		lib.addPowerBar(self)
		lib.addPortrait(self)

		-- Bar Style
		self.Health.frequentUpdates = true
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.bg.multiplier = 0.5

		-- oUF_Smooth
		self.Health.Smooth = true
		self.Power.Smooth = true

		-- Elements
		lib.addInfoIcons(self)
		lib.addCastBar(self)
		if cfg.targetBuffs then lib.addBuffs(self) end
		if cfg.targetDebuffs then lib.addDebuffs(self) end
		lib.addHealPred(self)
		lib.addAltPowerBar(self)
		lib.addAltPowerBarString(self)
	end,

	focus = function(self, ...)

		self.mystyle = "focus"

		-- Size and Scale
		self:SetSize((cfg.unitframeWidth/2-5)*cfg.unitframeScale, 25*cfg.unitframeScale)

		-- Generate Bars
		lib.addHealthBar(self)
		lib.addStrings(self)
		lib.addHighlight(self)
		lib.addPowerBar(self)

		-- Bar Style
		self.Health.frequentUpdates = false
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.colorHealth = true
		self.Power.bg.multiplier = 0.5

		-- oUF_Smooth
		self.Health.Smooth = true

		-- Elements
		lib.addInfoIcons(self)
		lib.addCastBar(self)
		if cfg.focusBuffs or cfg.focusDebuffs then lib.addFocusAuras(self) end

	end,

	targettarget = function(self, ...)

		self.mystyle = "tot"

		-- Size and Scale
		self:SetSize((cfg.unitframeWidth/2-5)*cfg.unitframeScale, 25*cfg.unitframeScale)

		-- Generate Bars
		lib.addHealthBar(self)
		lib.addStrings(self)
		lib.addHighlight(self)
		lib.addPowerBar(self)

		-- Bar Style
		self.Health.frequentUpdates = false
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.colorHealth = true
		self.Power.bg.multiplier = 0.5

		-- oUF_Smooth
		self.Health.Smooth = true

		-- Elements
		lib.addInfoIcons(self)
		lib.addCastBar(self)
		if cfg.totBuffs or cfg.totDebuffs then lib.addTotAuras(self) end

	end,

	focustarget = function(self, ...)

		self.mystyle = "focustarget"

		-- Size and Scale
		self:SetSize((cfg.unitframeWidth/2-5)*cfg.unitframeScale, 25*cfg.unitframeScale)

		-- Generate Bars
		lib.addHealthBar(self)
		lib.addStrings(self)
		lib.addHighlight(self)
		lib.addPowerBar(self)

		-- Bar Style
		self.Health.frequentUpdates = false
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.colorHealth = true
		self.Power.bg.multiplier = 0.5

		--Elements
		lib.addInfoIcons(self)
		lib.addCastBar(self)

	end,

	pet = function(self, ...)

		self.mystyle = "pet"

		-- Size and Scale
		self:SetSize((cfg.unitframeWidth/2-5)*cfg.unitframeScale, 25*cfg.unitframeScale)

		-- Generate Bars
		lib.addHealthBar(self)
		lib.addStrings(self)
		lib.addHighlight(self)
		lib.addPowerBar(self)

		-- Bar Style
		self.Health.frequentUpdates = false
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.colorHealth = true
		self.Power.bg.multiplier = 0.5

		-- Elements
		lib.addInfoIcons(self)
		lib.addCastBar(self)

	end,

	raid = function(self, ...)

		self.mystyle = "raid"

		-- Range Check
		self.Range = {
			insideAlpha = 1,
			outsideAlpha = .6,
		}

		-- Generate Bars
		lib.addHealthBar(self)
		lib.addStrings(self)
		lib.addHighlight(self)
		lib.addPowerBar(self)

		-- Bar Style
		self.colors.health = { r=.12, g=.12, b=.12, a=1 }
		self.Health.colorHealth = true
		self.Health.bg:SetVertexColor(.4,.4,.4,1)
		self.Health.frequentUpdates = true
		self.Power.colorClass = true
		self.Power.bg.multiplier = .35
		self.Power:SetAlpha(.9)

		-- Elements
		lib.addInfoIcons(self)
		lib.CreateTargetBorder(self)
		lib.addHealPred(self)
		lib.addRaidDebuffs(self)
		self.DrkIndicators = cfg.showIndicators and true or false
		self.showThreatIndicator = cfg.showThreatIndicator and true or false

		-- Event Handlers
		self.Health.PostUpdate = lib.PostUpdateRaidFrame
		self.Power.PostUpdate = lib.PostUpdateRaidFramePower
		self:RegisterEvent('PLAYER_TARGET_CHANGED', lib.ChangedTarget)
		self:RegisterEvent('GROUP_ROSTER_UPDATE', lib.ChangedTarget)
		--self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", lib.UpdateThreat)
		--self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", lib.UpdateThreat)
	end,
}


-----------------------
-- Register Styles
-----------------------

-- Global Style
local GlobalStyle = function(self, unit, isSingle)
	self:RegisterForClicks('AnyUp')

	-- Call Unit Specific Styles
	if (UnitSpecific[unit]) then
		return UnitSpecific[unit](self)
	end
end

-- Raid Style
local RaidStyle = function(self, unit)
	if (cfg.enableRightClickMenu) then
		self:RegisterForClicks('AnyUp')
	end

	-- Call Unit Specific Styles
	if (UnitSpecific[unit]) then
		return UnitSpecific[unit](self)
	end
end

-- Boss Style
local BossStyle = function(self, unit)
	self.mystyle="boss"

	-- Size and Scale
	self:SetSize(cfg.unitframeWidth*cfg.unitframeScale, 50*cfg.unitframeScale)

	-- Generate Bars
	lib.addHealthBar(self)
	lib.addStrings(self)
	lib.addPowerBar(self)
	lib.addAltPowerBar(self)
	--lib.addAltPowerBarString(self)

	-- Bar Style
	self.Health.colorSmooth = true
	self.Health.frequentUpdates = true
	self.Health.bg.multiplier = 0.2
	self.Power.colorClass = true
	self.Power.colorReaction = true
	self.Power.colorHealth = true
	self.Power.bg.multiplier = 0.2

	-- Elements
	lib.addInfoIcons(self)
	lib.addCastBar(self)
	lib.addBossBuffs(self)
	lib.addBossDebuffs(self)
end


-----------------------
-- Spawn Frames
-----------------------

oUF:RegisterStyle('drkGlobal', GlobalStyle)
oUF:RegisterStyle('drkRaid', RaidStyle)
oUF:RegisterStyle('drkBoss', BossStyle)

oUF:Factory(function(self)
	-- Single Frames
	self:SetActiveStyle('drkGlobal')

	self:Spawn('player'):SetPoint("TOPRIGHT",UIParent,"BOTTOM", cfg.playerX, cfg.playerY)
	self:Spawn('target'):SetPoint("TOPLEFT",UIParent,"BOTTOM", cfg.targetX, cfg.targetY)

	self:Spawn('targettarget'):SetPoint("BOTTOMRIGHT",oUF_drkGlobalTarget,"TOPRIGHT", 0, 7)
	self:Spawn('pet'):SetPoint("BOTTOMLEFT",oUF_drkGlobalPlayer,"TOPLEFT", 0, 7)
	self:Spawn('focus'):SetPoint("BOTTOMRIGHT",oUF_drkGlobalPlayer,"TOPRIGHT", 0, 7)
	self:Spawn('focustarget'):SetPoint("BOTTOMLEFT",oUF_drkGlobalTarget,"TOPLEFT", 0, 7)

	-- Raid Frames
	if cfg.showRaid then
		local point = cfg.raidOrientationHorizontal and "LEFT" or "TOP"
		local soloraid = cfg.raidShowSolo and "custom show;" or "party,raid10,raid25,raid40;"

		self:SetActiveStyle('drkRaid')
		local raid = {}
		for i = 1, 5 do
			local header = oUF:SpawnHeader(
			  "drkGroup"..i,
			  nil,
			  soloraid,
			  "showRaid",           true,
			  "point",              point,
			  "startingIndex",		1,
			  "yOffset",            -5,
			  "xoffset",            4,
			  "columnSpacing",      7,
			  "groupFilter",        tostring(i),
			  "groupBy",            "GROUP",
			  "groupingOrder",      "1,2,3,4,5",
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
				header:SetPoint("TOPLEFT",UIParent,"BOTTOMRIGHT",cfg.raidX,cfg.raidY)
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
end)

-- Boss Frames
oUF:SetActiveStyle('drkBoss')
local boss1 = oUF:Spawn("boss1", "oUF_Boss1")
boss1:SetPoint("TOPLEFT", UIParent, "LEFT", cfg.bossX, cfg.bossY)
local boss2 = oUF:Spawn("boss2", "oUF_Boss2")
boss2:SetPoint("TOPLEFT", UIParent, "LEFT", cfg.bossX, cfg.bossY+75)
local boss3 = oUF:Spawn("boss3", "oUF_Boss3")
boss3:SetPoint("TOPLEFT", UIParent, "LEFT", cfg.bossX, cfg.bossY+150)
local boss4 = oUF:Spawn("boss4", "oUF_Boss4")
boss4:SetPoint("TOPLEFT", UIParent, "LEFT", cfg.bossX, cfg.bossY+225)
local boss5 = oUF:Spawn("boss5", "oUF_Boss5")
boss5:SetPoint("TOPLEFT", UIParent, "LEFT", cfg.bossX, cfg.bossY+300)


oUF:DisableBlizzard('party')