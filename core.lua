 local addon, ns = ...
  
  local cfg = ns.cfg
  local lib = ns.lib


  -----------------------------
  -- STYLE FUNCTIONS
  -----------------------------

local UnitSpecific = {

	player = function(self, ...)
	
		self.mystyle = "player"
		
		-- Size and Scale
		self.scale = cfg.ptscale
		self:SetSize(250, 50)

		-- Generate Bars
		lib.addHealthBar(self)
		lib.addStrings(self)
		lib.addHighlight(self)
		lib.addPowerBar(self)
		lib.addPortrait(self)
		lib.addRaidMark(self)
		
		if cfg.AltPowerBarPlayer then lib.addAltPowerBar(self) end
		lib.addAltPowerBarString(self)
		if IsAddOnLoaded("oUF_Experience") then lib.addExperienceBar(self) end

		-- Buffs and Debuffs
		if cfg.playerAuras then
			BuffFrame:Hide()
			lib.addBuffs(self)
			lib.addDebuffs(self)
		end
		
		self.colors.smooth = {255/255,0/255,0/255, 255/255,50/255,50/255, 42/255,48/255,50/255}
		self.Health.frequentUpdates = true
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorClass = true
		self.Power.bg.multiplier = 0.5

		self.Health.Smooth = true
		self.Power.Smooth = true
		
		lib.addCastBar(self)
		lib.addInfoIcons(self)
		lib.addPhaseIcon(self)
		lib.addQuestIcon(self)
		lib.addHealPred(self)
		lib.addMirrorCastBar(self)

		if cfg.showRunebar then lib.addRunes(self) end
		if cfg.showHolybar then lib.addHolyPower(self) end
		if cfg.showHarmonybar then lib.addHarmony(self) end
		if cfg.showShardbar then lib.addShards(self) end
		if cfg.showEclipsebar then lib.addEclipseBar(self) end
		if cfg.showShadoworbsbar then lib.addShadoworbs(self) end
		
		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", cfg.updateSpec)
		
	end,
	
	target = function(self, ...)
	
		self.mystyle = "target"
		
		-- Size and Scale
		self.scale = cfg.ptscale
		self:SetSize(250, 50)

		-- Generate Bars
		lib.addHealthBar(self)
		lib.addStrings(self)
		lib.addHighlight(self)
		lib.addPowerBar(self)
		lib.addPortrait(self)

		self.Portrait.PostUpdate = lib.PortraitPostUpdate
		lib.addRaidMark(self)
		lib.addInfoIcons(self)
		lib.addPhaseIcon(self)

		--style specific stuff
		self.colors.smooth = {255/255,0/255,0/255, 255/255,50/255,50/255, 42/255,48/255,50/255}
		self.Health.frequentUpdates = true
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.bg.multiplier = 0.5
		
		self.Health.Smooth = true
		self.Power.Smooth = true
		
		lib.addCastBar(self)
		if cfg.targetBuffs then lib.addBuffs(self) end
		if cfg.targetDebuffs then lib.addDebuffs(self) end
		if cfg.showComboPoints then lib.addCPoints(self) end
		lib.addHealPred(self)
		lib.addAltPowerBar(self)
		lib.addAltPowerBarString(self)
	end,
	
	focus = function(self, ...)
	
		self.mystyle = "focus"
		
		-- Size and Scale
		self.scale = cfg.miscscale
		self:SetSize(120, 25)
		
		-- Generate Bars
		lib.addHealthBar(self)
		lib.addStrings(self)
		lib.addHighlight(self)
		lib.addPowerBar(self)
		lib.addRaidMark(self)

		--style specific stuff
		self.colors.smooth = {255/255,0/255,0/255, 255/255,50/255,50/255, 42/255,48/255,50/255}
		self.Health.frequentUpdates = false
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.colorHealth = true
		self.Power.bg.multiplier = 0.5
		
		self.Health.Smooth = true
		
		lib.addCastBar(self)
		
		if cfg.focusBuffs or cfg.focusDebuffs then lib.addFocusAuras(self) end
		
	end,
	
	targettarget = function(self, ...)

		self.mystyle = "tot"
		
		-- Size and Scale
		self.scale = cfg.miscscale
		self:SetSize(120, 25)

		-- Generate Bars
		lib.addHealthBar(self)
		lib.addStrings(self)
		lib.addHighlight(self)
		lib.addPowerBar(self)
		lib.addRaidMark(self)

		--style specific stuff
		self.colors.smooth = {255/255,0/255,0/255, 255/255,50/255,50/255, 42/255,48/255,50/255}
		self.Health.frequentUpdates = false
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.colorHealth = true
		self.Power.bg.multiplier = 0.5
		
		self.Health.Smooth = true
		
		lib.addCastBar(self)
		
		if cfg.totBuffs or cfg.totDebuffs then lib.addTotAuras(self) end

	end,
	
	focustarget = function(self, ...)
		
		self.mystyle = "focustarget"
		
		-- Size and Scale
		self.scale = cfg.miscscale
		self:SetSize(120, 25)

		-- Generate Bars
		lib.addHealthBar(self)
		lib.addStrings(self)
		lib.addHighlight(self)
		lib.addPowerBar(self)
		lib.addRaidMark(self)

		--style specific stuff
		self.colors.smooth = {255/255,0/255,0/255, 255/255,50/255,50/255, 42/255,48/255,50/255}
		self.Health.frequentUpdates = false
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.colorHealth = true
		self.Power.bg.multiplier = 0.5
		lib.addCastBar(self)
	
	end,
	
	pet = function(self, ...)
		local _, playerClass = UnitClass("player")
		
		self.mystyle = "pet"
		
		-- Size and Scale
		self.scale = cfg.miscscale
		self:SetSize(120, 25)

		-- Generate Bars
		lib.addHealthBar(self)
		lib.addStrings(self)
		lib.addHighlight(self)
		lib.addPowerBar(self)
		lib.addRaidMark(self)
		
		--style specific stuff
		self.colors.smooth = {255/255,0/255,0/255, 255/255,50/255,50/255, 42/255,48/255,50/255}
		self.Health.frequentUpdates = false
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.colorHealth = true
		self.Power.bg.multiplier = 0.5
		lib.addCastBar(self)
		
	end,
	
	raid = function(self, ...)
				
		self.mystyle = "raid"
		
		-- Size and Scale
		self.scale = cfg.raidscale
		self.Range = {
			insideAlpha = 1,
			outsideAlpha = .6,
		}

		-- Generate Bars
		lib.addHealthBar(self)
		lib.addStrings(self)
		lib.addHighlight(self)
		lib.addPowerBar(self)
		lib.addRaidMark(self)
		lib.addReadyCheck(self)
		lib.addResurrectIcon(self)
		

		--style specific stuff
		self.colors.health = { r=.12, g=.12, b=.12, a=1 }
		self.Health.colorHealth = true
		self.Health.bg.multiplier = 0.2
		self.Power.colorClass = true
		self.Power.bg.multiplier = 0.35
		self.Power:SetAlpha(.9)
		
		--lib.addInfoIcons(self)
		lib.CreateTargetBorder(self)
		--lib.CreateThreatBorder(self)
		lib.addHealPred(self)
		--lib.addAuraWatch(self)
		lib.addRaidDebuffs(self)
		self.DrkIndicators = true
		self.Health.PostUpdate = lib.PostUpdateRaidFrame
		self.Power.PostUpdate = lib.PostUpdateRaidFramePower
		self:RegisterEvent('PLAYER_TARGET_CHANGED', lib.ChangedTarget)
		self:RegisterEvent('GROUP_ROSTER_UPDATE', lib.ChangedTarget)
		--self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", lib.UpdateThreat)
		--self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", lib.UpdateThreat)
		
		--lib.updateRaidFramePosition(raid)
		--raid:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', lib.updateRaidFramePosition)
	end,
}


  
-- The Shared Style Function
local GlobalStyle = function(self, unit, isSingle)

	self.menu = lib.spawnMenu
	self:RegisterForClicks('AnyUp')
	
	-- Call Unit Specific Styles
	if(UnitSpecific[unit]) then
		return UnitSpecific[unit](self)
	end
end

-- The Shared Style Function for Party and Raid
local GroupGlobalStyle = function(self, unit)

	self.menu = lib.spawnMenu
	self:RegisterForClicks('AnyUp')
	
	-- Call Unit Specific Styles
	if(UnitSpecific[unit]) then
		return UnitSpecific[unit](self)
	end
end


------------------------------------------------------------------------------
--
-- BOSS FRAMES 
--
------------------------------------------------------------------------------

-- generate the frames
local function CreateUnitFrame(self, unit)
	self:SetSize(250, 50)

	self.mystyle="boss"
	
	lib.addHealthBar(self)
	lib.addStrings(self)
	lib.addPowerBar(self)
	lib.addAltPowerBar(self)
	lib.addAltPowerBarString(self)
	lib.addCastBar(self)
	lib.addRaidMark(self)

	self.Health.colorSmooth = true
	self.Health.bg.multiplier = 0.2
	self.Power.colorClass = true
	self.Power.colorReaction = true
	self.Power.colorHealth = true
	self.Power.bg.multiplier = 0.2
	
	lib.addBossBuffs(self)
	lib.addBossDebuffs(self)
end


  -----------------------------
  -- SPAWN UNITS
  -----------------------------

oUF:RegisterStyle('drk', GlobalStyle)
oUF:RegisterStyle('drkGroup', GroupGlobalStyle)


oUF:Factory(function(self)
	-- Single Frames
	self:SetActiveStyle('drk')

	self:Spawn('player'):SetPoint("TOPRIGHT",UIParent,"BOTTOM", cfg.playerX, cfg.playerY)
	self:Spawn('target'):SetPoint("TOPLEFT",UIParent,"BOTTOM", cfg.targetX, cfg.targetY)

	self:Spawn('targettarget'):SetPoint("BOTTOMRIGHT",oUF_drkTarget,"TOPRIGHT", 0, 7)
	self:Spawn('pet'):SetPoint("BOTTOMLEFT",oUF_drkPlayer,"TOPLEFT", 0, 7)
	self:Spawn('focus'):SetPoint("BOTTOMRIGHT",oUF_drkPlayer,"TOPRIGHT", 0, 7)
	self:Spawn('focustarget'):SetPoint("BOTTOMLEFT",oUF_drkTarget,"TOPLEFT", 0, 7)
	
	local soloraid
	if cfg.RaidShowSolo then
		soloraid = "custom show"
	else
		soloraid = "raid"
	end
		
	self:SetActiveStyle('drkGroup')
	local raid = {}
	for i = 1, 5 do
		local header = oUF:SpawnHeader(
		  "drkGroup"..i,
		  nil,
		  soloraid,
		  "showRaid",           true,
		  "point",              "TOP",
		  "startingIndex",		1,
		  "yOffset",            -5,
		  "xoffset",            8,
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
			header:SetPoint("TOPLEFT",raid[i-1],"TOPRIGHT",4,0)
		end
		header:SetScale(cfg.raidScale)
		raid[i] = header
	end

end)

oUF:RegisterStyle("oUF_BossBars", CreateUnitFrame)

oUF:SetActiveStyle("oUF_BossBars")
local boss1 = oUF:Spawn("boss1", "oUF_Boss1")
boss1:SetPoint("TOPLEFT", UIParent, "LEFT", cfg.bossX, cfg.bossY)
local boss2 = oUF:Spawn("boss2", "oUF_Boss2")
boss2:SetPoint("TOPLEFT", UIParent, "LEFT", cfg.bossX, cfg.bossY+75)
local boss3 = oUF:Spawn("boss3", "oUF_Boss3")
boss3:SetPoint("TOPLEFT", UIParent, "LEFT", cfg.bossX, cfg.bossY+150)
local boss4 = oUF:Spawn("boss4", "oUF_Boss4")
boss4:SetPoint("TOPLEFT", UIParent, "LEFT", cfg.bossX, cfg.bossY+225)


--oUF:DisableBlizzard('party')