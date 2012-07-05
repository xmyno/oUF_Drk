 local addon, ns = ...
  
  local cfg = ns.cfg
  local lib = ns.lib
  
  oUF.colors.smooth = {255/255,0/255,0/255, 255/255,50/255,50/255, 42/255,48/255,50/255}

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
		lib.gen_hpbar(self)
		lib.gen_hpstrings(self)
		lib.gen_highlight(self)
		lib.gen_ppbar(self)
		lib.gen_portrait(self)
		lib.gen_RaidMark(self)
		
		--lib.gen_altppbar(self) --standart blizzard bar is used.
		lib.gen_altppbartext(self)
		if IsAddOnLoaded("oUF_Experience") then lib.gen_Exp(self) end

		-- Buffs and Debuffs
		if cfg.playerAuras then
			BuffFrame:Hide()
			lib.createBuffs(self)
			lib.createDebuffs(self)
		end
		
		self.Health.frequentUpdates = false
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.2
		self.Power.colorClass = true
		self.Power.bg.multiplier = 0.5
		
		self.Health.Smooth = true
		self.Power.Smooth = true
		
		lib.gen_castbar(self)
		lib.gen_InfoIcons(self)
		lib.addPhaseIcon(self)
		lib.addQuestIcon(self)
		lib.HealPred(self)

		if cfg.showRunebar then lib.genRunes(self) end
		if cfg.showHolybar then lib.genHolyPower(self) end
		if cfg.showHarmonybar then lib.genHarmony(self) end
		if cfg.showShardbar then lib.genShards(self) end
		if cfg.showEclipsebar then lib.addEclipseBar(self) end
		if cfg.showShadoworbsbar then lib.genShadoworbs(self) end

	end,
	
	target = function(self, ...)
	
		self.mystyle = "target"
		
		-- Size and Scale
		self.scale = cfg.ptscale
		self:SetSize(250,50)

		-- Generate Bars
		lib.gen_hpbar(self)
		lib.gen_hpstrings(self)
		lib.gen_highlight(self)
		lib.gen_ppbar(self)
		lib.gen_portrait(self)
		self.Portrait.PostUpdate = lib.PortraitPostUpdate
		lib.gen_RaidMark(self)
		lib.gen_InfoIcons(self)
		lib.addPhaseIcon(self)

		--style specific stuff
		self.Health.frequentUpdates = false
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorHappiness = false
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.colorClass = true
		self.Power.bg.multiplier = 0.5
		
		self.Health.Smooth = true
		self.Power.Smooth = true
		
		lib.gen_castbar(self)
		lib.gen_mirrorcb(self)
		if (cfg.targetBuffs) then lib.createBuffs(self) end
		if (cfg.targetDebuffs) then lib.createDebuffs(self) end
		if (cfg.showRogueCombopoints) then lib.genCPoints(self) end
		lib.HealPred(self)
	end,
	
	focus = function(self, ...)
	
		self.mystyle = "focus"
		
		-- Size and Scale
		self.scale = cfg.miscscale
		self:SetSize(120, 25)
		
		-- Generate Bars
		lib.gen_hpbar(self)
		lib.gen_hpstrings(self)
		lib.gen_highlight(self)
		lib.gen_ppbar(self)
		lib.gen_RaidMark(self)

		--style specific stuff
		self.Health.frequentUpdates = false
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorHappiness = false
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.colorHealth = true
		self.Power.bg.multiplier = 0.5
		
		self.Health.Smooth = true
		
		lib.gen_castbar(self)
		
		if (cfg.focusBuffs or cfg.focusDebuffs) then lib.createFocusAuras(self) end
		
	end,
	
	targettarget = function(self, ...)

		self.mystyle = "tot"
		
		-- Size and Scale
		self.scale = cfg.miscscale
		self:SetSize(120, 25)

		-- Generate Bars
		lib.gen_hpbar(self)
		lib.gen_hpstrings(self)
		lib.gen_highlight(self)
		lib.gen_ppbar(self)
		lib.gen_RaidMark(self)

		--style specific stuff
		self.Health.frequentUpdates = false
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorHappiness = false
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.colorHealth = true
		self.Power.bg.multiplier = 0.5
		
		self.Health.Smooth = true
		
		lib.gen_castbar(self)
		
		if (cfg.totBuffs or cfg.totDebuffs) then lib.createTotAuras(self) end

	end,
	
	focustarget = function(self, ...)
		
		self.mystyle = "focustarget"
		
		-- Size and Scale
		self.scale = cfg.miscscale
		self:SetSize(120, 25)

		-- Generate Bars
		lib.gen_hpbar(self)
		lib.gen_hpstrings(self)
		lib.gen_highlight(self)
		lib.gen_ppbar(self)
		lib.gen_RaidMark(self)
		
		--style specific stuff
		self.Health.frequentUpdates = false
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorHappiness = false
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.colorHealth = true
		self.Power.bg.multiplier = 0.5
		lib.gen_castbar(self)
	
	end,
	
	pet = function(self, ...)
		local _, playerClass = UnitClass("player")
		
		self.mystyle = "pet"
		
		-- Size and Scale
		self.scale = cfg.miscscale
		self:SetSize(120,25)

		-- Generate Bars
		lib.gen_hpbar(self)
		lib.gen_hpstrings(self)
		lib.gen_highlight(self)
		lib.gen_ppbar(self)
		lib.gen_RaidMark(self)
		
		--style specific stuff
		self.Health.frequentUpdates = false
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorHappiness = false
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.colorHealth = true
		self.Power.bg.multiplier = 0.5
		lib.gen_castbar(self)

		-- Hunter Pet Hapiness
		if PlayerClass == "HUNTER" then
			self.Power.colorReaction = false
			self.Power.colorClass = false
			self.Power.colorHappiness = true
		end
		
	end,
	
	raid = function(self, ...)
				
		self.mystyle = "raid"
		
		-- Size and Scale
		self.scale = cfg.raidscale
		self.Range = {
			insideAlpha = 1,
			outsideAlpha = .3,
		}

		-- Generate Bars
		lib.gen_hpbar(self)
		lib.gen_hpstrings(self)
		lib.gen_highlight(self)
		lib.gen_ppbar(self)
		lib.gen_RaidMark(self)
		lib.ReadyCheck(self)

		--style specific stuff
		self.Health.frequentUpdates = true
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Power.colorClass = true
		self.Power.bg.multiplier = 0.5
		lib.gen_InfoIcons(self)
		lib.CreateTargetBorder(self)
		lib.CreateThreatBorder(self)
		lib.HealPred(self)
		self.Health.PostUpdate = lib.PostUpdateRaidFrame
		self:RegisterEvent('PLAYER_TARGET_CHANGED', lib.ChangedTarget)
		self:RegisterEvent('GROUP_ROSTER_UPDATE', lib.ChangedTarget)
		self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", lib.UpdateThreat)
		self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", lib.UpdateThreat)
	end,
}


  
-- The Shared Style Function
local GlobalStyle = function(self, unit, isSingle)

	self.menu = lib.spawnMenu
	self:RegisterForClicks('AnyDown')
	
	-- Call Unit Specific Styles
	if(UnitSpecific[unit]) then
		return UnitSpecific[unit](self)
	end
end

-- The Shared Style Function for Party and Raid
local GroupGlobalStyle = function(self, unit)

	self.menu = lib.spawnMenu
	self:RegisterForClicks('AnyDown')
	
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
	
	lib.gen_hpbar(self)
	self.Health.colorSmooth = true
	self.Health.bg.multiplier = 0.2
	
	lib.gen_ppbar(self)
	self.Power.colorClass = true
	self.Power.colorReaction = true
	self.Power.colorHealth = true
	self.Power.bg.multiplier = 0.2

	lib.gen_hpstrings(self)
	lib.gen_castbar(self)
	lib.gen_altppbar(self)
	
	lib.gen_RaidMark(self)
	
	lib.createBossBuffs(self)
	lib.createBossDebuffs(self)
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