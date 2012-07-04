-----------------------------
-- INIT
-----------------------------

local addon, ns = ...
local cfg = CreateFrame("Frame")

-----------------------------
-- CONFIG
-----------------------------

--positioning
cfg.playerX = -250 -- x-coordinate of the player frame
cfg.playerY = 424 -- y-coordinate of the player frame
cfg.targetX = 250 -- x-coordinate of the target frame
cfg.targetY = 424 -- y-coordinate of the target frame
cfg.bossX = 15 -- x-coordinate of boss frames
cfg.bossY = -40 -- y-coordinate is for the first bossframe, additional frames will grow upwards (75px each)
--frames
cfg.showplayer = true -- show player frame
cfg.showtarget = true -- show target frame
cfg.showtot = true -- show target of target frame
cfg.showpet = true -- show pet frame
cfg.showfocus = true -- show focus frame
cfg.showfocustarget = true -- show focus target frame
--auras
cfg.playerAuras = true -- show player buffs and debuffs, disables Blizzard buff bar
cfg.targetBuffs = true -- show target buff frame
cfg.targetDebuffs = true -- show target debuff frame
cfg.totBuffs = false -- show target-of-target buffs (only one can be active)
cfg.totDebuffs = true -- show target-of-target debuffs (only one can be active)
cfg.focusBuffs = false -- show focus buffs (only one can be active)
cfg.focusDebuffs = true -- show focus debuffs (only one can be active)
--class-specific bars
cfg.showRunebar = true -- show DK rune bar
cfg.showHolybar = true -- show Paladin HolyPower bar
cfg.showEclipsebar = false -- show druid Eclipse bar
cfg.showShardbar = true -- show Warlock SoulShard bar
cfg.showHarmonybar = true -- show Monk Harmony bar
cfg.showShadoworbsbar = true -- show Shadow Priest Shadow Orbs bar
cfg.showComboPoints = true -- show Rogue Combo Points
--raid&party frames
cfg.ShowParty = false -- show party frames (shown as 5man raid)
cfg.ShowRaid = false -- show raid frames
cfg.RaidShowSolo = false -- show raid frames even when solo
cfg.RaidShowAllGroups = false -- show raid groups 6, 7 and 8 (more than 25man raid)
cfg.RCheckIcon = false -- show raid check icon
--other stuff
cfg.Castbars = true -- use built-in castbars
cfg.ShowIncHeals = true -- Show incoming heals in player and raid frames

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



--##########  DELETE  #############
cfg.showauras = false -- use custom player auras instead of blizzard's default aura frame
-----------------------------
-- HANDOVER
-----------------------------

ns.cfg = cfg
