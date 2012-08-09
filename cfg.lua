-----------------------------
-- INIT
-----------------------------

local addon, ns = ...
local cfg = CreateFrame("Frame")
-----------------------------
-- CONFIG
-----------------------------

--unitframes
	cfg.unitframeWidth = 250
	cfg.unitframeHeight = 50
--player
	cfg.playerX = -180 -- x-coordinate of the player frame
	cfg.playerY = 360 -- y-coordinate of the player frame
--target
	cfg.targetX = 180 -- x-coordinate of the target frame
	cfg.targetY = 360 -- y-coordinate of the target frame
--boss
	cfg.bossX = 15 -- x-coordinate of boss frames
	cfg.bossY = -40 -- y-coordinate is for the first bossframe, additional frames will grow upwards (75px each)
--auras
	cfg.playerAuras = false -- show player buffs and debuffs, disables Blizzard buff bar
	cfg.AltPowerBarPlayer = false --show altpowerbar on player frame, false = blizzard standard
	cfg.targetBuffs = true -- show target buff frame
	cfg.targetDebuffs = true -- show target debuff frame
	cfg.totBuffs = false -- show target-of-target buffs (only one can be active)
	cfg.totDebuffs = true -- show target-of-target debuffs (only one can be active)
	cfg.focusBuffs = false -- show focus buffs (only one can be active)
	cfg.focusDebuffs = true -- show focus debuffs (only one can be active)
--class-specific bars
	cfg.showRunebar = true -- show DK rune bar
	cfg.showHolybar = true -- show Paladin HolyPower bar
	cfg.showEclipsebar = true -- show druid Eclipse bar
	cfg.showShardbar = true -- show Warlock SoulShard bar
	cfg.showHarmonybar = true -- show Monk Harmony bar
	cfg.showShadoworbsbar = true -- show Shadow Priest Shadow Orbs bar
	cfg.showComboPoints = true -- show Rogue Combo Points
--castbar
	cfg.Castbars = true -- use built-in castbars
	cfg.castBarOnUnitframe = true
	cfg.castBarX = 0
	cfg.castBarY = 700
	cfg.castBarWidth = 300
	cfg.castBarHeight = 30
--raid&party frames
	cfg.ShowParty = true -- show party frames (shown as 5man raid)
	cfg.ShowRaid = true -- show raid frames
	cfg.RaidShowSolo = true -- show raid frames even when solo
	cfg.ShowIncHeals = true -- Show incoming heals in player and raid frames
	
	cfg.raidX = -410
	cfg.raidY = 190
	cfg.raidScale = 1.0
	
	cfg.IndicatorList = {
		["NUMBERS"] = {
			--["DEATHKNIGHT"] 	= ,
			["DRUID"]			= "[Druid:Lifebloom][Druid:Rejuv][Druid:Regrowth]",
			--["HUNTER"]		= missdirect,
			--MAGE				= ,
			["MONK"]			= "[Monk:EnvelopingMist][Monk:RenewingMist]",
			--["PALADIN"]		= ,
			["PRIEST"]			= "[Priest:Renew][Priest:PowerWordShield]",
			--["ROGUE"]			= tricks,
			["SHAMAN"]			= "[Shaman:Riptide][Shaman:EarthShield]",
			--["WARLOCK"]		= ,
			["WARRIOR"]			= "[Warrior:Vigilance]",
		},
		["SQUARE"] = {
			--["DEATHKNIGHT"] 	= ,
			--["DRUID"]			= ,
			--["HUNTER"]		= ,
			--MAGE				= ,
			--["MONK"]			= "",
			["PALADIN"]			= "[Paladin:Forbearance][Paladin:Beacon]",
			--["PRIEST"]		= ,
			--["ROGUE"]			= ,
			--["SHAMAN"]		= ,
			--["WARLOCK"]		= darkintent,
			--["WARRIOR"]		= ,
		},
	}
	
	cfg.AuraWatchList = { -- List of all buffs you want to watch on raid frames, sorted by class
		DEATHKNIGHT={
		},
		DRUID={
		},
		HUNTER={
		},
		MAGE={
		},
		MONK={
		},
		PALADIN={
		
		},
		PRIEST={
		},
		ROGUE={
		
		},
		SHAMAN={
			61295, --Riptide
			974, --Earth Shield
		},
		WARLOCK={
		},
		WARRIOR={
			114030, --Vigilance
		},
	}
	cfg.DebuffWatchList = {
		debuffs = {
			--?? USAGE: ["DEBUFF_NAME"] = PRIORITY, ??--
			--?? PRIORITY -> 10: high, 9: medium, 8: low, dispellable debuffs have standard priority of 5. ??--
			
			--## MISTS OF PANDARIA ##--
			--World Bosses
				--Sha of Anger
					--["Strange Aura"] = 10,
					["Growing Anger"] = 8,
					["Aggressive Behavior"] = 9,
			--Heart of Fear
				--Imperial Vizier Zor'lok
					["Noise Cancelling"] = 9,
					["Convert"] = 10,
				--Blade Lord Ta'yak
					["Overwhelming Assault"] = 8,
					["Wind Step"] = 9,
				--Garalon
					["Pheromones"] = 8,
					["Pungency"] = 10,
				--Wind Lord Mel'jarak
					["Amber Prison"] = 10,
					["Residue"] = 9,
					["Corrosive Resin"] = 8,
				--Amber-Shaper Un'sok
					["Reshape Life"] = 9,
					["Parasitic Growth"] = 10,
					["Amber Globule"] = 9,
				--Grand Empress Shek'zeer
					["Eyes of the Empress"] = 8,
					["Sticky Resin"] = 8,
					["Visions of Demise"] = 8,
			--Mogu'shan Vaults
				--The Stone Guard
					["Cobalt Mine"] = 8,
					["Jasper Chains"] = 10,
					["Living Jade"] = 9,
					["Living Jasper"] = 9,
					["Living Cobalt"] = 9,
					["Living Amethyst"] = 9,
				--Feng the Accursed
					["Flaming Spear"] = 8,
					["Wildfire Spark"] = 9,
					["Arcane Resonance"] = 10,
				--Gara'jal the Spiritbinder
					["Frail Soul"] = 8,
					["Voodoo Doll"] = 9,
					["Conduit to the Spirit Realm"] = 10,
				--The Spirit Kings
					["Maddening Shout"] = 8,
					["Pillage"] = 9,
					["Pinning Arrow"] = 9,
					["Robbed Blind"] = 8,
					["Undying Shadows"] = 9,
				--Elegon
					["Overcharged"] = 8,
					["Closed Circuit"] = 9,
				--Will of the Emperor
					["Focused Energy"] = 10,
			--Terrace of Endless Spring
				--Protectors of the Endless
					["Lightning Prison"] = 10,
					["Corrupted Essence"] = 8,
				--Tsulong
					["Nightmares"] = 8,
					["Terrorize"] = 8,
				--Lei Shi
					["Scary Fog"] = 10,
					["Spray"] = 8,
				--Sha of Fear
					["Dread Spray"] = 8,
		},
	}
--cfg.RaidShowAllGroups = false -- show raid groups 6, 7 and 8 (more than 25man raid)
--cfg.RCheckIcon = false -- show raid check icon
--other stuff

	
	
	
--media files
cfg.statusbar_texture = "Interface\\AddOns\\oUF_Drk\\media\\Statusbar"
cfg.powerbar_texture = "Interface\\AddOns\\oUF_Drk\\media\\Aluminium"
cfg.raid_texture = "Interface\\AddOns\\oUF_Drk\\media\\Minimalist"
cfg.highlight_texture = "Interface\\AddOns\\oUF_Drk\\media\\raidbg"
cfg.portrait_texture = "Interface\\AddOns\\oUF_Drk\\media\\portrait"
cfg.backdrop_texture = "Interface\\AddOns\\oUF_Drk\\media\\backdrop"
cfg.backdrop_edge_texture = "Interface\\AddOns\\oUF_Drk\\media\\backdrop_edge"
cfg.debuff_border_texture = "Interface\\AddOns\\oUF_Drk\\media\\iconborder"


cfg.font = "Interface\\AddOns\\oUF_Drk\\media\\BigNoodleTitling.ttf"
cfg.smallfont = "Interface\\AddOns\\oUF_Drk\\media\\semplice.ttf"
cfg.raidfont = "Interface\\AddOns\\oUF_Drk\\media\\vibroceb.ttf"
cfg.squarefont = "Interface\\AddOns\\oUF_Drk\\media\\squares.ttf"

cfg.ptscale = 0.8 -- scale factor for player and target frames
cfg.miscscale = 0.8 -- scale factor for all other frames


cfg.spec = nil
cfg.updateSpec = function()
	local activespec = GetSpecialization()
	if activespec then
		id, name, desc, icon, bg, role = GetSpecializationInfo(activespec)
		spec = name
	end
end

-----------------------------
-- HANDOVER
-----------------------------

ns.cfg = cfg