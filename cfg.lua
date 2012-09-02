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
	--player
	cfg.playerCastBarOnUnitframe = true
	cfg.playerCastBarX = 0
	cfg.playerCastBarY = 200
	cfg.playerCastBarWidth = 300
	cfg.playerCastBarHeight = 30
	--target
	cfg.targetCastBarOnUnitframe = true
	cfg.targetCastBarX = 0
	cfg.targetCastBarY = 250
	cfg.targetCastBarWidth = 200
	cfg.targetCastBarHeight = 25	
--raid&party frames
	cfg.ShowRaid = true -- show raid frames
	cfg.ShowParty = true -- show party frames (shown as 5man raid)
	cfg.RaidShowSolo = true -- show raid frames even when solo
	cfg.ShowIncHeals = true -- Show incoming heals in player and raid frames
	cfg.ShowTooltips = true -- Show Tooltips on raid frames
	cfg.ShowRoleIcons = false -- Show Role Icons on raid frames
	cfg.Indicators = true -- Show Class Indicators on raid frames (HoT's, buffs etc.)
	cfg.ThreatIndicator = true -- Show Threat Indicator on raid frames
	
	cfg.raidOrientationHorizontal = false
	cfg.raidX = -410
	cfg.raidY = 190
	cfg.raidScale = 1.0
	
	cfg.IndicatorList = {
		["NUMBERS"] = {
			--["DEATHKNIGHT"] 	= ,
			["DRUID"]			= "[Druid:Lifebloom][Druid:Rejuv][Druid:Regrowth]",
			--["HUNTER"]		= missdirect,
			--["MAGE"]			= ,
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
			--["MAGE"]			= ,
			--["MONK"]			= "",
			["PALADIN"]			= "[Paladin:Forbearance][Paladin:Beacon]",
			--["PRIEST"]		= ,
			--["ROGUE"]			= ,
			--["SHAMAN"]		= ,
			--["WARLOCK"]		= darkintent,
			--["WARRIOR"]		= ,
		},
	}

	cfg.DebuffWatchList = {
		debuffs = {
			--## USAGE: ["DEBUFF_NAME"] = PRIORITY, ##--
			--## PRIORITY -> 10: high, 9: medium, 8: low, dispellable debuffs have standard priority of 5. ##--
			--## CATACLYSM ##--
			--Dragon Soul
				--Warlord Zon'ozz
					["103434"] = 9, -- Disrupting Shadows
				--Yor'sahj the Unsleeping
					["103628"] = 9, -- Deep Corruption
				--Hagara the Stormbinder
					["109325"] = 9, -- Frostflake
					["104451"] = 9, -- Ice Tomb
				--Ultraxion
					["105926"] = 9, -- Fading Light
				--Spine of Deathwing
					["109379"] = 8, -- Searing Plasma
					["105490"] = 9, -- Fiery Grip
					["106199"] = 10, -- Blood Corruption: Death
					["106200"] = 10, -- Blood Corruption: Earth
				--Madness of Deathwing
					["108649"] = 9, -- Corrupting Parasite
					["106400"] = 10, -- Impale
					["106444"] = 9, -- Impale (Stacks)
					["106794"] = 9, -- Shrapnel (should be the right one)
					--["106791"] = 9, -- Shrapnel
			--## MISTS OF PANDARIA ##--
			--World Bosses
				--Sha of Anger
					["119622"] = 8, -- Growing Anger
					["119626"] = 9, -- Aggressive Behavior
			--Heart of Fear
				--Imperial Vizier Zor'lok
					["122706"] = 9, -- Noise Cancelling
					["122740"] = 10, -- Convert
				--Blade Lord Ta'yak
					["123474"] = 8, -- Overwhelming Assault
					["123175"] = 9, -- Wind Step
				--Garalon
					["122835"] = 8, ["129815"] = 8, -- Pheromones
					["123081"] = 10, -- Pungency
				--Wind Lord Mel'jarak
					["121885"] = 10, ["129078"] = 10, ["121881"] = 10, -- Amber Prison
					["122055"] = 8, -- Residue
					["122064"] = 9, -- Corrosive Resin
				--Amber-Shaper Un'sok
					["122784"] = 9, ["122370"] = 9, -- Reshape Life
					["121949"] = 10, -- Parasitic Growth
					--["Amber Globule"] = 9,
				--Grand Empress Shek'zeer
					["123707"] = 8, -- Eyes of the Empress
					["124097"] = 8, -- Sticky Resin
					["124862"] = 10, ["124863"] = 10, -- Visions of Demise
			--Mogu'shan Vaults
				--The Stone Guard
					["116281"] = 8, -- Cobalt Mine
					["130395"] = 10, -- Jasper Chains
					["116301"] = 9, -- Living Jade
					["116304"] = 9, -- Living Jasper
					["116199"] = 9, -- Living Cobalt
					["116322"] = 9, -- Living Amethyst
				--Feng the Accursed
					["116942"] = 8, -- Flaming Spear
					["116784"] = 9, -- Wildfire Spark
					["116577"] = 10, ["116576"] = 10, ["116574"] = 10, ["116417"] = 10, -- Arcane Resonance
				--Gara'jal the Spiritbinder
					["117723"] = 8, -- Frail Soul
					["122151"] = 9, -- Voodoo Doll
					["122181"] = 10, -- Conduit to the Spirit Realm
				--The Spirit Kings
					["117708"] = 8, -- Maddening Shout
					["118047"] = 8, ["118048"] = 8, -- Pillage
					["118141"] = 9, -- Pinning Arrow
					["118163"] = 8, -- Robbed Blind
					["117514"] = 9, ["117529"] = 9, ["117506"] = 9,-- Undying Shadows
				--Elegon
					--["117878"] = 8, -- Overcharged
					["117949"] = 9, -- Closed Circuit
					["132222"] = 10, -- Destabilizing Energies
					["132226"] = 10, -- Destabilized
				--Will of the Emperor
					["116829"] = 10, -- Focused Energy
			--Terrace of Endless Spring
				--Protectors of the Endless
					["117436"] = 10, ["131931"] = 10, ["111850"] = 10, -- Lightning Prison
					--[""] = 8, -- Corrupted Essence -- ID MISSING
				--Tsulong
					["122777"] = 8, -- Nightmares
					["123011"] = 10, ["123018"] = 10, -- Terrorize
				--Lei Shi
					["123705"] = 10, -- Scary Fog
					["123121"] = 8, -- Spray
				--Sha of Fear
					--[""] = 8, -- Dread Spray -- ID MISSING
		},
	}
	
	
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
	cfg.spec = GetSpecialization()
end

-----------------------------
-- HANDOVER
-----------------------------

ns.cfg = cfg