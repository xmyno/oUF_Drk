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
	
	cfg.Castbars = true -- use built-in castbars
	cfg.ShowIncHeals = true -- Show incoming heals in player and raid frames
--raid&party frames NYI
	cfg.ShowParty = true -- show party frames (shown as 5man raid)  -- NYI
	cfg.ShowRaid = true -- show raid frames
	cfg.RaidShowSolo = true -- show raid frames even when solo
	
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
		},
		WARLOCK={
		},
		WARRIOR={
			6673, --Battle Shout
			18499,
			85730,
		},
	}
	cfg.DebuffWatchList = {
		debuffs = {
			["Strange Aura"] = 5,
		},
	}
--cfg.RaidShowAllGroups = false -- show raid groups 6, 7 and 8 (more than 25man raid)
--cfg.RCheckIcon = false -- show raid check icon
--other stuff

	
	
	
--media files
cfg.statusbar_texture = "Interface\\AddOns\\oUF_Drk\\media\\Statusbar"
cfg.powerbar_texture = "Interface\\AddOns\\oUF_Drk\\media\\Aluminium"
cfg.backdrop_texture = "Interface\\AddOns\\oUF_Drk\\media\\backdrop"
cfg.highlight_texture = "Interface\\AddOns\\oUF_Drk\\media\\raidbg"
cfg.portrait_texture = "Interface\\AddOns\\oUF_Drk\\media\\portrait"
cfg.backdrop_edge_texture = "Interface\\AddOns\\oUF_Drk\\media\\backdrop_edge"

cfg.font = "Interface\\AddOns\\oUF_Drk\\media\\BigNoodleTitling.ttf"
cfg.smallfont = "Interface\\AddOns\\oUF_Drk\\media\\semplice.ttf"

cfg.ptscale = 0.8 -- scale factor for player and target frames
cfg.raidscale = 1 -- scale factor for raid frames
cfg.miscscale = 0.8 -- scale factor for all other frames


-----------------------------
-- HANDOVER
-----------------------------

ns.cfg = cfg