-----------------------
--| oUF_Drk
--| Drakull 2010
--| Updated by myno
-----------------------
-- Initialize
-----------------------

local addon, ns = ...
local cfg = ns.cfg
local cast = ns.cast
local lib = CreateFrame("Frame")
local _, playerClass = UnitClass("player")


-----------------------
-- Functions
-----------------------

-- Returns val1, val2 or val3 depending on frame
local retVal = function(f, val1, val2, val3)
	if f.mystyle == "player" or f.mystyle == "target" then
		return val1
	elseif f.mystyle == "raid" then
		return val3
	else
		return val2
	end
end

-- Create Backdrop Function
lib.createBackdrop = function(f, size)
	f:SetBackdrop({
		bgFile = cfg.backdrop_texture,
		edgeFile = cfg.backdrop_edge_texture,
		tile = false,
		tileSize = 0,
		edgeSize = 5-size,
		insets = {
			left = 3-size,
			right = 3-size,
			top = 3-size,
			bottom = 3-size,
		}
	});
	f:SetBackdropColor(0,0,0,1)
	f:SetBackdropBorderColor(0,0,0,0.8)
end

-- Create Font Function
lib.gen_fontstring = function(f, name, size, outline)
	local fs = f:CreateFontString(nil, "OVERLAY")
	fs:SetFont(name, size, outline)
	fs:SetShadowColor(0,0,0,0.8)
	fs:SetShadowOffset(1,-1)
	fs:SetWordWrap(false)
	return fs
end

-- Create Health Bar Function
lib.addHealthBar = function(f)
	--statusbar
	local s = CreateFrame("StatusBar", nil, f)
	s:SetFrameLevel(1)
	if f.mystyle=="boss" then
		s:SetHeight(37)
		s:SetWidth(f:GetWidth())
		s:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
		s:SetStatusBarTexture(cfg.statusbar_texture)
	else
		s:SetHeight(retVal(f,f:GetHeight()*.68,f:GetHeight()*.76,29))
		s:SetWidth(f:GetWidth())
		s:SetPoint("TOP",0,0)
		if f.mystyle=="raid" then
			s:SetStatusBarColor(.12,.12,.12,1)
			s:SetStatusBarTexture(cfg.raid_texture)
		else
			s:SetStatusBarTexture(cfg.statusbar_texture)
		end
	end
	s:GetStatusBarTexture():SetHorizTile(true)
	--helper
	local h = CreateFrame("Frame", nil, s)
	h:SetFrameLevel(0)
	h:SetPoint("TOPLEFT",-4,4)
	if f.mystyle == "target" or f.mystyle == "player" or f.mystyle == "boss" then
		h:SetPoint("BOTTOMRIGHT",4,-4)
	elseif f.mystyle == "raid" then
		h:SetPoint("TOPLEFT",f,"TOPLEFT",-4,4)
		h:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT", 3.8, -4)
	else
		h:SetPoint("BOTTOMRIGHT", 4, -10*cfg.unitframeScale)
	end
	lib.createBackdrop(h,0)
	--bg
	local b = s:CreateTexture(nil, "BACKGROUND")
	b:SetTexture(cfg.statusbar_texture)
	b:SetAllPoints(s)
	f.Health = s
	f.Health.bg = b
end

--gen hp strings func
lib.addStrings = function(f)
    --health/name text strings
	local name, hpval, powerval, altppval
	if f.mystyle == "boss" then
		name = lib.gen_fontstring(f.Health, cfg.font, 14, "NONE")
		name:SetPoint("LEFT", f.Health, "TOPLEFT", 3, -10)
		name:SetJustifyH("LEFT")
		hpval = lib.gen_fontstring(f.Health, cfg.font, 14, "NONE")
		hpval:SetPoint("RIGHT", f.Health, "TOPRIGHT", -3, -10)
		altppval = lib.gen_fontstring(f.Health, cfg.font, 12, "THINOUTLINE")
		altppval:SetPoint("RIGHT", f.Health, "BOTTOMRIGHT", 3, -22)

		f:Tag(name,"[drk:nameboss]")
		f:Tag(hpval,"[drk:hpboss]")
		f:Tag(altppval,"[drk:altpowerbar]")

	else
		name = lib.gen_fontstring(f.Health, retVal(f,cfg.font,cfg.font,cfg.raidfont), retVal(f,14,12,12), retVal(f,"NONE","NONE","NONE"))
		name:SetPoint("LEFT", f.Health, "TOPLEFT", retVal(f,5,3,1), retVal(f,-10,-10,-6))
		name:SetJustifyH("LEFT")
		name.frequentUpdates = true
		hpval = lib.gen_fontstring(f.Health, cfg.font, retVal(f,14,12,13), retVal(f,"NONE","NONE","OUTLINE"))
		hpval:SetPoint(retVal(f,"RIGHT","RIGHT","LEFT"), f.Health, retVal(f,"TOPRIGHT","TOPRIGHT","BOTTOMLEFT"), retVal(f,-3,-3,0), retVal(f,-10,-10,6))
		hpval.frequentUpdates = true
		powerval = lib.gen_fontstring(f.Health, cfg.font, 14, "THINOUTLINE")
		powerval:SetPoint("RIGHT", f.Health, "BOTTOMRIGHT", 3, -16)
		if f.mystyle == "raid" then
			name:SetPoint("RIGHT", f, "RIGHT", -1, 0)
			f:Tag(name, "[drk:color][name][drk:raidafkdnd]")
		else
			name:SetPoint("RIGHT", hpval, "LEFT", -2, 0)
			if f.mystyle == "player" then
				f:Tag(name, "[drk:color][drk:power]|r[drk:afkdnd]")
			elseif f.mystyle == "target" then
				f:Tag(name, "[drk:level] [drk:color][name][drk:afkdnd]")
				f:Tag(powerval, "[drk:power]")
			else
				f:Tag(name, "[drk:color][name]")
			end
		end
		f:Tag(hpval, retVal(f,"[drk:hp]","[drk:hp]","[drk:raidhp]"))
	end
end

--gen powerbar func
lib.addPowerBar = function(f)
	--statusbar
	local s = CreateFrame("StatusBar", nil, f)
    s:SetStatusBarTexture(cfg.powerbar_texture)
	s:GetStatusBarTexture():SetHorizTile(true)
	s:SetFrameLevel(1)
	if f.mystyle=="boss" then
		s:SetWidth(250)
		s:SetHeight(8)
		s:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,0)
		s:SetStatusBarColor(165/255, 73/255, 23/255, 1)
	else
		s:SetHeight(retVal(f,f:GetHeight()*.26,f:GetHeight()*.2,2))
		s:SetWidth(f:GetWidth())
		if f.mystyle=="raid" then
			s:SetPoint("BOTTOM",f,"BOTTOM",0,0)
		else
			s:SetPoint("BOTTOM",f,"BOTTOM",0,0)
		end
	end
	s.frequentUpdates = true
    --helper
	if f.mystyle == "target" or f.mystyle == "player" or f.mystyle=="boss" then
		local h = CreateFrame("Frame", nil, s)
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT",-4,4)
		h:SetPoint("BOTTOMRIGHT",4,-4)
		lib.createBackdrop(h,0)

	end
    --bg
    local b = s:CreateTexture(nil, "BACKGROUND")
    b:SetTexture(cfg.powerbar_texture)
    b:SetAllPoints(s)
    f.Power = s
    f.Power.bg = b
end

--gen altpowerbar func
lib.addAltPowerBar = function(f)
	local s = CreateFrame("StatusBar", nil, f.Power)
	s:SetFrameLevel(1)
	if f.mystyle == 'boss' then
		s:SetPoint("BOTTOM", f.Power, "BOTTOM", 0, -7)
		s:SetSize(f:GetWidth()-.5, 3)
	else
		s:SetSize(3,f:GetHeight()+.5)
		s:SetOrientation("VERTICAL")
		if f.mystyle == 'player' then
			s:SetPoint("TOPLEFT", f.Health, "TOPRIGHT", 3, 0)
		else
			s:SetPoint("TOPRIGHT", f.Health, "TOPLEFT", -3, 0)
		end
	end
	s:SetStatusBarTexture(cfg.powerbar_texture)
	s:GetStatusBarTexture():SetHorizTile(false)
	s:SetStatusBarColor(235/255, 235/255, 235/255)
	f.AltPowerBar = s

	local h = CreateFrame("Frame", nil, s)
	h:SetFrameLevel(0)
	h:SetPoint("TOPLEFT",-3,3)
	h:SetPoint("BOTTOMRIGHT",3,-3)
	lib.createBackdrop(h,1)

    local b = s:CreateTexture(nil, "BACKGROUND")
    b:SetTexture(cfg.powerbar_texture)
    b:SetAllPoints(s)
	b:SetVertexColor(45/255, 45/255, 45/255)
    f.AltPowerBar.bg = b
end

--gen altpowerbar strings func
lib.addAltPowerBarString = function(f)
	local altpphelpframe = CreateFrame("Frame",nil,s)
	if f.mystyle == "player" then
		if cfg.AltPowerBarPlayer then
			altpphelpframe:SetPoint("LEFT", f.AltPowerBar, "BOTTOMLEFT", 1, 4)
		else
			altpphelpframe:SetPoint("CENTER", PlayerPowerBarAlt, "TOP", 0, -5) -- adds percentage to standard blizzard altPowerBar
		end
	else
		altpphelpframe:SetPoint("RIGHT", f.AltPowerBar, "BOTTOMRIGHT", 1, 4)
	end
	altpphelpframe:SetFrameLevel(7)
	altpphelpframe:SetSize(30,10)
	local altppbartext
	if f.mystyle == "player" then
		altppbartext = lib.gen_fontstring(altpphelpframe, cfg.font, 8, "OUTLINE")
		altppbartext:SetPoint("LEFT", altpphelpframe, "LEFT", 0, 0)
		altppbartext:SetJustifyH("LEFT")
	else
		altppbartext = lib.gen_fontstring(altpphelpframe, cfg.font, 8, "OUTLINE")
		altppbartext:SetPoint("RIGHT", altpphelpframe, "RIGHT", 0, 0)
		altppbartext:SetJustifyH("RIGHT")
	end
	f:Tag(altppbartext,"[drk:altpowerbar]")
end

--gen portrait func
lib.addPortrait = function(f)
    local p = CreateFrame("PlayerModel", nil, f)
    p:SetFrameLevel(4)
    p:SetHeight(19.8)
    p:SetWidth(f:GetWidth()-17.55)
    p:SetPoint("BOTTOM", f, "BOTTOM", 0, 8)
    --helper
    local h = CreateFrame("Frame", nil, p)
    h:SetFrameLevel(3)
    h:SetPoint("TOPLEFT",-4,4)
    h:SetPoint("BOTTOMRIGHT",5,-5)
    lib.createBackdrop(h,0)

    f.Portrait = p

    local hl = f.Portrait:CreateTexture(nil, "OVERLAY")
    hl:SetAllPoints(f.Portrait)
    hl:SetTexture(cfg.portrait_texture)
    hl:SetVertexColor(.5,.5,.5,.8)
    hl:SetBlendMode("ALPHAKEY")
    hl:Hide()
end

-- Create Icons Function (Combat, PvP, Resting, LFDRole, Leader, Assist, Master Looter, Phase, Quest, Raid Mark, Ressurect)
lib.addInfoIcons = function(f)
    local h = CreateFrame("Frame",nil,f)
    h:SetAllPoints(f)
    h:SetFrameLevel(10)
    --Combat Icon
	if f.mystyle=="player" then
		f.Combat = h:CreateTexture(nil, 'OVERLAY')
		f.Combat:SetSize(15,15)
		f.Combat:SetTexture('Interface\\CharacterFrame\\UI-StateIcon')
		f.Combat:SetTexCoord(0.58, 0.90, 0.08, 0.41)
		f.Combat:SetPoint('BOTTOMRIGHT', 7, -7)
	elseif f.mystyle == "target" then
        local combat = CreateFrame("Frame", nil, h)
        combat:SetSize(15, 15)
        combat:SetPoint("BOTTOMRIGHT", 7, -7)
        f.CombatIcon = combat

        local combaticon = combat:CreateTexture(nil, "ARTWORK")
        combaticon:SetAllPoints(true)
        combaticon:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
        combaticon:SetTexCoord(0.58, 0.9, 0.08, 0.41)
        combat.icon = combaticon

        combat.__owner = f
        combat:SetScript("OnUpdate", function(self)
            local unit = self.__owner.unit
            if unit and UnitAffectingCombat(unit) then
                self.icon:Show()
            else
                self.icon:Hide()
            end
        end)
    end
	-- PvP Icon
	f.PvP = h:CreateTexture(nil, "OVERLAY")
	local faction = PvPCheck
	if faction == "Horde" then
		f.PvP:SetTexCoord(0.08, 0.58, 0.045, 0.545)
	elseif faction == "Alliance" then
		f.PvP:SetTexCoord(0.07, 0.58, 0.06, 0.57)
	else
		f.PvP:SetTexCoord(0.05, 0.605, 0.015, 0.57)
	end
	if f.mystyle == 'player' then
		f.PvP:SetHeight(14)
		f.PvP:SetWidth(14)
		f.PvP:SetPoint("TOPRIGHT", 7, 7)
	elseif f.mystyle == 'target' then
		f.PvP:SetHeight(12)
		f.PvP:SetWidth(12)
		f.PvP:SetPoint("TOPRIGHT", 6, 6)
	end
	-- Rest Icon
    if f.mystyle == 'player' then
		f.Resting = h:CreateTexture(nil, 'OVERLAY')
		f.Resting:SetSize(15,15)
		f.Resting:SetPoint('BOTTOMRIGHT', -12, -8)
		f.Resting:SetTexture('Interface\\CharacterFrame\\UI-StateIcon')
		f.Resting:SetTexCoord(0.09, 0.43, 0.08, 0.42)
	end
    --LFDRole icon
	if f.mystyle == 'player' or f.mystyle == 'target' then
		f.LFDRole = h:CreateTexture(nil, 'OVERLAY')
		f.LFDRole:SetSize(15,15)
		f.LFDRole:SetAlpha(0.9)
		f.LFDRole:SetPoint('BOTTOMLEFT', -6, -8)
    elseif cfg.showRoleIcons and f.mystyle == 'raid' then
		f.LFDRole = h:CreateTexture(nil, 'OVERLAY')
		f.LFDRole:SetSize(12,12)
		f.LFDRole:SetPoint('CENTER', f, 'RIGHT', 1, 0)
		f.LFDRole:SetAlpha(0)
    end
	-- Leader, Assist, Master Looter Icon
	if f.mystyle ~= 'raid' then
		li = h:CreateTexture(nil, "OVERLAY")
		li:SetPoint("TOPLEFT", f, 0, 8)
		li:SetSize(12,12)
		f.Leader = li
		ai = h:CreateTexture(nil, "OVERLAY")
		ai:SetPoint("TOPLEFT", f, 0, 8)
		ai:SetSize(12,12)
		f.Assistant = ai
		local ml = h:CreateTexture(nil, 'OVERLAY')
		ml:SetSize(10,10)
		ml:SetPoint('LEFT', f.Leader, 'RIGHT')
		f.MasterLooter = ml
	end
	-- Phase Icon
	if f.mystyle == 'target' then
		picon = h:CreateTexture(nil, 'OVERLAY')
		picon:SetPoint('TOPRIGHT', f, 'TOPRIGHT', 8, 8)
		picon:SetSize(16, 16)
		f.PhaseIcon = picon
	end
	-- Quest Icon
	--[[
	if f.mystyle == 'target' then
		qicon = self.Health:CreateTexture(nil, 'OVERLAY')
		qicon:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 8)
		qicon:SetSize(16, 16)
		f.QuestIcon = qicon
	end
	]]
	-- Raid Marks
	ri = h:CreateTexture(nil,'OVERLAY')
	if f.mystyle == 'player' or f.mystyle == 'target' then
		ri:SetPoint("RIGHT", f, "LEFT", 5, 6)
	elseif f.mystyle == 'raid' then
		ri:SetPoint("CENTER", f, "TOP",0,0)
	else
		ri:SetPoint("CENTER", f, "TOP", 0, 2)
	end
	local size = retVal(f, 20, 18, 12)
	ri:SetSize(size, size)
	f.RaidIcon = ri
	-- Ressurect Icon
	if f.mystyle == 'raid' then
		rezicon = h:CreateTexture(nil,'OVERLAY')
		rezicon:SetPoint('CENTER',f,'CENTER',0,-3)
		rezicon:SetSize(16,16)
		f.ResurrectIcon = rezicon
	end
	-- Ready Check Icon
	if f.mystyle == 'raid' then
		rc = f.Health:CreateTexture(nil, "OVERLAY")
		rc:SetSize(14, 14)
		rc:SetPoint("BOTTOMLEFT", f.Health, "TOPRIGHT", -13, -12)
		f.ReadyCheck = rc
	end
end


-- Create Target Border
function lib.CreateTargetBorder(self)
	local glowBorder = {edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1}
	self.TargetBorder = CreateFrame("Frame", nil, self)
	self.TargetBorder:SetPoint("TOPLEFT", self, "TOPLEFT", -2.5, 2.5)
	self.TargetBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 3, -2.5)
	self.TargetBorder:SetBackdrop(glowBorder)
	self.TargetBorder:SetFrameLevel(5)
	self.TargetBorder:SetBackdropBorderColor(.7,.7,.7,.8)
	self.TargetBorder:Hide()
end

-- Raid Frames Target Highlight Border
function lib.ChangedTarget(self, event, unit)
	if UnitIsUnit('target', self.unit) then
		self.TargetBorder:Show()
	else
		self.TargetBorder:Hide()
	end
end


-- Create Raid Threat Status Border
--function lib.CreateThreatBorder(self)
--	local glowBorder = {edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 2}
--	self.Thtborder = CreateFrame("Frame", nil, self)
--	self.Thtborder:SetPoint("TOPLEFT", self, "TOPLEFT", -2, 2)
--	self.Thtborder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 2, -2)
--	self.Thtborder:SetBackdrop(glowBorder)
--	self.Thtborder:SetFrameLevel(4)
--	self.Thtborder:Hide()
--end

-- Raid Frames Threat Highlight
--function lib.UpdateThreat(self, event, unit)
--	if (self.unit ~= unit) then return end
--
--	local status = UnitThreatSituation(unit)
--	unit = unit or self.unit
--	if status and status > 1 then
--		local r, g, b = GetThreatStatusColor(status)
--		self.Thtborder:Show()
--		self.Thtborder:SetBackdropBorderColor(r, g, b, 1)
--	else
--		self.Thtborder:SetBackdropBorderColor(r, g, b, 0)
--		self.Thtborder:Hide()
--	end
--end


--gen castbar
lib.addCastBar = function(f)
	if not cfg.Castbars then return end
    local s = CreateFrame("StatusBar", "oUF_DrkCastbar"..f.mystyle, f)
	if f.mystyle == "player" then
		if cfg.playerCastBarOnUnitframe and cfg.showPortraits then
			s:SetPoint("TOPLEFT",f.Portrait,"TOPLEFT",21,.5)
			s:SetHeight(f.Portrait:GetHeight()+1.5)
			s:SetWidth(f:GetWidth()-37.45)
		else
			s:SetPoint("BOTTOM",UIParent,"BOTTOM",cfg.playerCastBarX,cfg.playerCastBarY)
			s:SetHeight(cfg.playerCastBarHeight)
			s:SetWidth(cfg.playerCastBarWidth)
		end
    elseif f.mystyle == "target" then
		if cfg.targetCastBarOnUnitframe and cfg.showPortraits then
			s:SetPoint("TOPLEFT",f.Portrait,"TOPLEFT",21,.5)
			s:SetHeight(f.Portrait:GetHeight()+1.5)
			s:SetWidth(f:GetWidth()-37.45)
		else
			s:SetPoint("BOTTOM",UIParent,"BOTTOM",cfg.targetCastBarX,cfg.targetCastBarY)
			s:SetHeight(cfg.targetCastBarHeight)
			s:SetWidth(cfg.targetCastBarWidth)
		end
	elseif f.mystyle=="boss" then
		s:SetPoint("TOP",f.Power,"TOP",13,0)
		s:SetHeight(20)
		s:SetWidth(f:GetWidth()-26)
   else
		s:SetPoint("TOPRIGHT",f,"TOPRIGHT",-.5,26)
		s:SetHeight(18)
		s:SetWidth(f:GetWidth()-23.5)
    end
    s:SetStatusBarTexture(cfg.statusbar_texture)
    s:SetStatusBarColor(.5, .5, 1,1)
    s:SetFrameLevel(9)
    --color
    s.CastingColor = {.5, .5, 1}
    s.CompleteColor = {0.5, 1, 0}
    s.FailColor = {1.0, 0.05, 0}
    s.ChannelingColor = {.5, .5, 1}
    --helper
    local h = CreateFrame("Frame", nil, s)
    h:SetFrameLevel(0)
    h:SetPoint("TOPLEFT",-4,4)
    h:SetPoint("BOTTOMRIGHT",4,-4)
    lib.createBackdrop(h,0)
    --backdrop
    if f.mystyle~="player" or f.mystyle~="target" then
	local b = s:CreateTexture(nil, "BACKGROUND")
    b:SetTexture(cfg.statusbar_texture)
    b:SetAllPoints(s)
    b:SetVertexColor(.5*0.2,.5*0.2,1*0.2,0.7)
	end
    --spark
    sp = s:CreateTexture(nil, "OVERLAY")
    sp:SetBlendMode("ADD")
    sp:SetAlpha(0.5)
    sp:SetHeight(s:GetHeight()*2.5)
    --spell text
    local txt = lib.gen_fontstring(s, cfg.font, 12, "NONE")
    txt:SetPoint("LEFT", 4, 0)
    txt:SetJustifyH("LEFT")
    --time
    local t = lib.gen_fontstring(s, cfg.font, 12, "NONE")
    t:SetPoint("RIGHT", -2, 0)
    txt:SetPoint("RIGHT", t, "LEFT", -5, 0)
    --icon
    local i = s:CreateTexture(nil, "ARTWORK")

	if ((f.mystyle=='player' and cfg.playerCastBarOnUnitframe) or (f.mystyle=='target' and cfg.targetCastBarOnUnitframe)) then
		i:SetPoint("RIGHT", s, "LEFT", 1, 0)
		i:SetSize(s:GetHeight(),s:GetHeight())
	elseif (f.mystyle=='player' or f.mystyle=='target') then
		i:SetPoint("RIGHT",s,"LEFT",-5,0)
		i:SetSize(s:GetHeight()-1,s:GetHeight()-1)
	else
		i:SetPoint("RIGHT",s,"LEFT",-4,0)
		i:SetSize(s:GetHeight(),s:GetHeight())
	end
    i:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    --helper2 for icon
    local h2 = CreateFrame("Frame", nil, s)
    h2:SetFrameLevel(0)
    h2:SetPoint("TOPLEFT",i,"TOPLEFT",-4,4)
    h2:SetPoint("BOTTOMRIGHT",i,"BOTTOMRIGHT",4,-4)
    lib.createBackdrop(h2,0)
    if f.mystyle == "player" then
		--latency only for player unit
		local z = s:CreateTexture(nil,"OVERLAY")
		z:SetTexture(cfg.statusbar_texture)
		z:SetVertexColor(1,0,0,.6)
		z:SetPoint("TOPRIGHT")
		z:SetPoint("BOTTOMRIGHT")
		s:SetFrameLevel(10)
		s.SafeZone = z
		--custom latency display
		local l = lib.gen_fontstring(s, cfg.font, 10, "THINOUTLINE")
		l:SetPoint("CENTER", -2, 17)
		l:SetJustifyH("RIGHT")
		l:Hide()
		s.Lag = l
		f:RegisterEvent("UNIT_SPELLCAST_SENT", cast.OnCastSent)
    end
    s.OnUpdate = cast.OnCastbarUpdate
    s.PostCastStart = cast.PostCastStart
    s.PostChannelStart = cast.PostCastStart
    s.PostCastStop = cast.PostCastStop
    s.PostChannelStop = cast.PostChannelStop
    s.PostCastFailed = cast.PostCastFailed
    s.PostCastInterrupted = cast.PostCastFailed

    f.Castbar = s
    f.Castbar.Text = txt
    f.Castbar.Time = t
    f.Castbar.Icon = i
    f.Castbar.Spark = sp
  end

-- mirror castbar!
lib.addMirrorCastBar = function(f)
	for _, bar in pairs({'MirrorTimer1','MirrorTimer2','MirrorTimer3',}) do
		--for i, region in pairs({_G[bar]:GetRegions()}) do
		--	if (region.GetTexture and region:GetTexture() == 'SolidTexture') then
		--	  region:Hide()
		--	end
		--end
		_G[bar..'Border']:Hide()
		_G[bar]:SetParent(UIParent)
		_G[bar]:SetScale(1)
		_G[bar]:SetHeight(16)
		_G[bar]:SetWidth(280)
		_G[bar]:SetBackdropColor(.1,.1,.1)
		_G[bar..'Background'] = _G[bar]:CreateTexture(bar..'Background', 'BACKGROUND', _G[bar])
		_G[bar..'Background']:SetTexture(cfg.statusbar_texture)
		_G[bar..'Background']:SetAllPoints(bar)
		_G[bar..'Background']:SetVertexColor(.15,.15,.15,.75)
		_G[bar..'Text']:SetFont(cfg.font, 14)
		_G[bar..'Text']:ClearAllPoints()
		_G[bar..'Text']:SetPoint('CENTER', MirrorTimer1StatusBar, 0, 1)
		_G[bar..'StatusBar']:SetAllPoints(_G[bar])

		--glowing borders
		local h = CreateFrame("Frame", nil, _G[bar])
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT",-5,5)
		h:SetPoint("BOTTOMRIGHT",5,-5)
		lib.createBackdrop(h,0)
	end
end


-- Post Create Icon Function
local myPostCreateIcon = function(self, button)
	self.showDebuffType = true
	self.disableCooldown = true
	button.cd.noOCC = true
	button.cd.noCooldownCount = true

	button.icon:SetTexCoord(.04, .96, .04, .96)
	button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
	button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
	button.overlay:SetTexture(border)
	button.overlay:SetTexCoord(0,1,0,1)
	button.overlay.Hide = function(self) self:SetVertexColor(0.3, 0.3, 0.3) end


	button.time = lib.gen_fontstring(button, cfg.smallfont, 8, "OUTLINE")
	button.time:SetPoint("BOTTOMLEFT", button, -2, -2)
	button.time:SetJustifyH('CENTER')
	button.time:SetVertexColor(1,1,1)

	button.count = lib.gen_fontstring(button, cfg.smallfont, 8, "OUTLINE")
	button.count:ClearAllPoints()
	button.count:SetPoint("TOPRIGHT", button, 2, 2)
	button.count:SetVertexColor(1,1,1)

	--helper
	local h = CreateFrame("Frame", nil, button)
	h:SetFrameLevel(0)
	h:SetPoint("TOPLEFT",-5,5)
	h:SetPoint("BOTTOMRIGHT",5,-5)
	lib.createBackdrop(h,0)
end

-- Post Update Icon Function
local myPostUpdateIcon = function(self, unit, icon, index, offset, filter, isDebuff)

	local _, _, _, _, _, duration, expirationTime, unitCaster, _ = UnitAura(unit, index, icon.filter)

	if duration and duration > 0 then
		icon.time:Show()
		icon.timeLeft = expirationTime
		icon:SetScript("OnUpdate", CreateBuffTimer)
	else
		icon.time:Hide()
		icon.timeLeft = math.huge
		icon:SetScript("OnUpdate", nil)
	end

	-- Desaturate non-Player Debuffs
	if(unit == "target") then
		if(icon.filter == "HARMFUL") then
			if (unitCaster == 'player' or unitCaster == 'vehicle') then
				icon.icon:SetDesaturated(nil)
			elseif(not UnitPlayerControlled(unit)) then -- If Unit is Player Controlled don't desaturate debuffs
				icon:SetBackdropColor(0, 0, 0)
				icon.overlay:SetVertexColor(0.3, 0.3, 0.3)
				icon.icon:SetDesaturated(1)
			end
		end
	end

	-- Right Click Cancel Buff/Debuff
	icon:SetScript('OnMouseUp', function(self, mouseButton)
		if mouseButton == 'RightButton' then
			CancelUnitBuff('player', index)
		end
	end)

	icon.first = true
end

local FormatTime = function(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", floor(s/day + 0.5)), s % day
	elseif s >= hour then
		return format("%dh", floor(s/hour + 0.5)), s % hour
	elseif s >= minute then
		if s <= minute * 5 then
			return format("%d:%02d", floor(s/60), s % minute), s - floor(s)
		end
		return format("%dm", floor(s/minute + 0.5)), s % minute
	elseif s >= minute / 12 then
		return floor(s + 0.5), (s * 100 - floor(s * 100))/100
	end
	return format("%.1f", s), (s * 100 - floor(s * 100))/100
end

-- Create Buff/Debuff Timer Function
function CreateBuffTimer(self, elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = FormatTime(self.timeLeft)
					self.time:SetText(time)
				if self.timeLeft < 5 then
					self.time:SetTextColor(1, 0.5, 0.5)
				else
					self.time:SetTextColor(.7, .7, .7)
				end
			else
				self.time:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end

lib.addBuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 20
    b.num = 20
    b.spacing = 5
    b.onlyShowPlayer = false
    b:SetHeight(b.size*2)
    b:SetWidth(f:GetWidth())
	if f.mystyle == "player" then
		b:SetPoint("TOPRIGHT", f, "TOPLEFT", -5, -1)
		b.initialAnchor = "TOPRIGHT"
		b["growth-x"] = "LEFT"
		b["growth-y"] = "DOWN"
	else
		b:SetPoint("TOPLEFT", f, "TOPRIGHT", 5, -1)
		b.initialAnchor = "TOPLEFT"
		b["growth-x"] = "RIGHT"
		b["growth-y"] = "DOWN"
	end
	b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon

    f.Buffs = b
end

lib.addDebuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 20
	b.num = 10
	b.onlyShowPlayer = false
    b.spacing = 5
    b:SetHeight(b.size)
    b:SetWidth(f:GetWidth())

	b:SetPoint("TOPLEFT", f.Power, "BOTTOMLEFT", .5, -5)
    b.initialAnchor = "TOPLEFT"
    b["growth-x"] = "RIGHT"
    b["growth-y"] = "DOWN"
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon
	b:SetFrameLevel(1)

    f.Debuffs = b
end

lib.addTotAuras = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 20
	b.num = 5
	b.onlyShowPlayer = false
    b.spacing = 5
    b:SetHeight(b.size)
    b:SetWidth(f:GetWidth())
	b:SetPoint("TOPLEFT", f, "TOPRIGHT", 5, -1)
	b.initialAnchor = "TOPLEFT"
	b["growth-x"] = "RIGHT"
	b["growth-y"] = "DOWN"
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon
	if (cfg.totBuffs) then f.Buffs = b end
	if (cfg.totDebuffs and not cfg.totBuffs) then f.Debuffs = b end
end

lib.addFocusAuras = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 20
	b.num = 5
	b.onlyShowPlayer = false
    b.spacing = 5
    b:SetHeight(b.size)
    b:SetWidth(f:GetWidth())
	b:SetPoint("TOPLEFT", f, "TOPRIGHT", 5, -1)
	b.initialAnchor = "TOPLEFT"
	b["growth-x"] = "RIGHT"
	b["growth-y"] = "DOWN"
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon
	if (cfg.focusBuffs) then f.Buffs = b end
	if (cfg.focusDebuffs and not cfg.focusBuffs) then f.Debuffs = b end
end

lib.addBossBuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 20
	b.num = 4
	b.onlyShowPlayer = false
    b.spacing = 5
    b:SetHeight(b.size)
    b:SetWidth(f:GetWidth())
	b:SetPoint("TOPLEFT", f, "TOPRIGHT", 5, -1)
	b.initialAnchor = "TOPLEFT"
	b["growth-x"] = "RIGHT"
	b["growth-y"] = "DOWN"
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon

    f.Buffs = b
end

lib.addBossDebuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 20
	b.num = 4
	b.onlyShowPlayer = false
    b.spacing = 5
    b:SetHeight(b.size)
    b:SetWidth(f:GetWidth())
	b:SetPoint("BOTTOMLEFT", f, "BOTTOMRIGHT", 5, 1)
	b.initialAnchor = "TOPLEFT"
	b["growth-x"] = "RIGHT"
	b["growth-y"] = "DOWN"
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon

    f.Debuffs = b
end

--[[lib.addRaidDebuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 12
	b.num = 3
	b.onlyShowPlayer = false
    b.spacing = 3
    b:SetHeight(b.size)
    b:SetWidth(f:GetWidth())
	b:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 3, 3)
	b.initialAnchor = "TOPLEFT"
	b["growth-x"] = "RIGHT"
	b["growth-y"] = "DOWN"
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon

    f.Debuffs = b
end
]]


-- portrait update
lib.PortraitPostUpdate = function(element, unit)
	if not UnitExists(unit) or not UnitIsConnected(unit) or not UnitIsVisible(unit) then
		element:Hide()
	else
		element:Show()
		--element:SetPortraitZoom(1)
	end
end

-- raid post update
lib.PostUpdateRaidFrame = function(Health, unit, min, max)

	local dc = not UnitIsConnected(unit)
	local dead = UnitIsDead(unit)
	local ghost = UnitIsGhost(unit)
	local inrange = UnitInRange(unit)

	Health:SetStatusBarColor(.12,.12,.12,1)
	Health:SetAlpha(1)
	Health:SetValue(min)

	if dc or dead or ghost then
		if dc then
			Health:SetAlpha(.225)
		elseif ghost then
			--Health:SetStatusBarColor(.03,.03,.03,1)
			Health:SetValue(0)
		elseif dead then
			--Health:SetStatusBarColor(.03,.03,.03,1)
			Health:SetValue(0)
		end
	else
		Health:SetValue(min)
		if(unit == 'vehicle') then
			Health:SetStatusBarColor(.12,.12,.12,1)
		end
	end
end

lib.PostUpdateRaidFramePower = function(Power, unit, min, max)
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

lib.addAdditionalPower = function(self)
	local AdditionalPower = CreateFrame("StatusBar", "AdditionalPowerBar", self.Power)
	AdditionalPower:SetHeight(3)
	AdditionalPower:SetWidth(self.Power:GetWidth())
	AdditionalPower:SetPoint("TOP", self.Power, "BOTTOM", 0, -3)
	AdditionalPower:SetFrameLevel(10)
	AdditionalPower:SetStatusBarTexture(cfg.statusbar_texture)
	AdditionalPower:SetStatusBarColor(.117, .55, 1)
	
	AdditionalPower.bg = AdditionalPower:CreateTexture(nil, "BORDER")
	AdditionalPower.bg:SetTexture(cfg.statusbar_texture)
	AdditionalPower.bg:SetVertexColor(.05, .15, .4)
	AdditionalPower.bg:SetPoint("TOPLEFT", AdditionalPower, "TOPLEFT", 0, 0)
	AdditionalPower.bg:SetPoint("BOTTOMRIGHT", AdditionalPower, "BOTTOMRIGHT", 0, 0)

	local h = CreateFrame("Frame", nil, AdditionalPower)
	h:SetFrameLevel(0)
	h:SetPoint("TOPLEFT", -4, 4)
	h:SetPoint("BOTTOMRIGHT", 4, -4)
	lib.createBackdrop(h, 0)

	self.DruidMana = AdditionalPower
	self.DruidMana.bg = AdditionalPower.bg
end

lib.addHarmony = function(self)
	if playerClass ~= "MONK" then return end

	local mhb = CreateFrame("Frame", "MonkHarmonyBar", self)
	mhb:SetPoint("CENTER", self.Health, "TOP", 0, 1)
	mhb:SetWidth(self.Health:GetWidth()/2+75)
	mhb:SetHeight(5)
	mhb:SetFrameLevel(10)

	for i = 1, 6 do
		mhb[i] = CreateFrame("StatusBar", "MonkHarmonyBar"..i, mhb)
		mhb[i]:SetHeight(5)
		mhb[i]:SetStatusBarTexture(cfg.statusbar_texture)
		mhb[i]:SetStatusBarColor(.9,.99,.9)
		mhb[i].bg = mhb[i]:CreateTexture(nil,"BORDER")
		mhb[i].bg:SetTexture(cfg.statusbar_texture)
		mhb[i].bg:SetVertexColor(0,0,0)
		mhb[i].bg:SetPoint("TOPLEFT",mhb[i],"TOPLEFT",0,0)
		mhb[i].bg:SetPoint("BOTTOMRIGHT",mhb[i],"BOTTOMRIGHT",0,0)
		mhb[i].bg.multiplier = .3

		local h = CreateFrame("Frame",nil,mhb[i])
		h:SetFrameLevel(mhb:GetFrameLevel())
		h:SetPoint("TOPLEFT",-3,3)
		h:SetPoint("BOTTOMRIGHT",3,-3)
		lib.createBackdrop(h,1)

		if i == 1 then
			mhb[i]:SetPoint("LEFT", mhb, "LEFT", 1, 0)
		else
			mhb[i]:SetPoint("LEFT", mhb[i-1], "RIGHT", 2, 0)
		end
	end

	self.MonkHarmonyBar = mhb
end

-- SoulShard bar
lib.addShards = function(self)

	if playerClass ~= "WARLOCK" then return end

	local wsb = CreateFrame("Frame", "WarlockSpecBars", self)
	wsb:SetPoint("CENTER", self.Health, "TOP", -6, 1)
	wsb:SetWidth(self.Health:GetWidth() - 50)
	wsb:SetHeight(5)
	wsb:SetFrameLevel(10)

	for i = 1, 5 do
		wsb[i] = CreateFrame("StatusBar", "WarlockSpecBars"..i, wsb)
		wsb[i]:SetHeight(5)
        wsb[i]:SetWidth(wsb:GetWidth() / 5)
		wsb[i]:SetStatusBarTexture(cfg.statusbar_texture)
		wsb[i]:SetStatusBarColor(.86,.22,1)
		wsb[i].bg = wsb[i]:CreateTexture(nil,"BORDER")
		wsb[i].bg:SetTexture(cfg.statusbar_texture)
		wsb[i].bg:SetVertexColor(0,0,0)
		wsb[i].bg:SetPoint("TOPLEFT",wsb[i],"TOPLEFT",0,0)
		wsb[i].bg:SetPoint("BOTTOMRIGHT",wsb[i],"BOTTOMRIGHT",0,0)
		wsb[i].bg.multiplier = .3

		local h = CreateFrame("Frame",nil,wsb[i])
		h:SetFrameLevel(10)
		h:SetPoint("TOPLEFT",-3,3)
		h:SetPoint("BOTTOMRIGHT",3,-3)
		lib.createBackdrop(h,1)

		if i == 1 then
			wsb[i]:SetPoint("LEFT", wsb, "LEFT", 1, 0)
		else
			wsb[i]:SetPoint("LEFT", wsb[i-1], "RIGHT", 2, 0)
		end
	end

	self.WarlockSpecBars = wsb
end

-- Arcane Charges (Arcane Mage)
lib.addArcaneCharges = function(self)

	if playerClass ~= "MAGE" then return end

	local MageArcaneCharges = CreateFrame("Frame", "ArcaneChargesBar", self)
	MageArcaneCharges:SetPoint("CENTER", self.Health, "TOP", -6, 1)
	MageArcaneCharges:SetWidth(self.Health:GetWidth() - 50)
	MageArcaneCharges:SetHeight(5)
	MageArcaneCharges:SetFrameLevel(10)

	for i = 1, 4 do
		MageArcaneCharges[i] = CreateFrame("StatusBar", "ArcaneChargesBar"..i, MageArcaneCharges)
		MageArcaneCharges[i]:SetHeight(5)
        MageArcaneCharges[i]:SetWidth(MageArcaneCharges:GetWidth() / 4)
		MageArcaneCharges[i]:SetStatusBarTexture(cfg.statusbar_texture)
		MageArcaneCharges[i]:SetStatusBarColor(.15,.55,.8)
		MageArcaneCharges[i].bg = MageArcaneCharges[i]:CreateTexture(nil,"BORDER")
		MageArcaneCharges[i].bg:SetTexture(cfg.statusbar_texture)
		MageArcaneCharges[i].bg:SetVertexColor(0,0,0)
		MageArcaneCharges[i].bg:SetPoint("TOPLEFT",MageArcaneCharges[i],"TOPLEFT",0,0)
		MageArcaneCharges[i].bg:SetPoint("BOTTOMRIGHT",MageArcaneCharges[i],"BOTTOMRIGHT",0,0)
		MageArcaneCharges[i].bg.multiplier = .3

		local h = CreateFrame("Frame",nil,MageArcaneCharges[i])
		h:SetFrameLevel(10)
		h:SetPoint("TOPLEFT",-3,3)
		h:SetPoint("BOTTOMRIGHT",3,-3)
		lib.createBackdrop(h,1)

		if i == 1 then
			MageArcaneCharges[i]:SetPoint("LEFT", MageArcaneCharges, "LEFT", 1, 0)
		else
			MageArcaneCharges[i]:SetPoint("LEFT", MageArcaneCharges[i-1], "RIGHT", 2, 0)
		end
	end

	self.MageArcaneCharges = MageArcaneCharges
end

-- HolyPowerbar
lib.addHolyPower = function(self)
	if playerClass ~= "PALADIN" then return end

	local PaladinHolyPower = CreateFrame("Frame", nil, self)
	PaladinHolyPower:SetPoint('CENTER', self.Health, 'TOP', 0, 1)
	PaladinHolyPower:SetHeight(5)
	PaladinHolyPower:SetWidth(self.Health:GetWidth() / 2 + 75)

	for i = 1, 5 do
		PaladinHolyPower[i] = CreateFrame("StatusBar", self:GetName().."_Holypower"..i, self)
		PaladinHolyPower[i]:SetHeight(5)
		PaladinHolyPower[i]:SetWidth((PaladinHolyPower:GetWidth() / 5) - 2)
		PaladinHolyPower[i]:SetStatusBarTexture(cfg.statusbar_texture)
		PaladinHolyPower[i]:SetStatusBarColor(.9, .95, .33)
		PaladinHolyPower[i]:SetFrameLevel(11)
		PaladinHolyPower[i].bg = PaladinHolyPower[i]:CreateTexture(nil, "BORDER")
		PaladinHolyPower[i].bg:SetTexture(cfg.statusbar_texture)
		PaladinHolyPower[i].bg:SetPoint("TOPLEFT", PaladinHolyPower[i], "TOPLEFT", 0, 0)
		PaladinHolyPower[i].bg:SetPoint("BOTTOMRIGHT", PaladinHolyPower[i], "BOTTOMRIGHT", 0, 0)
		PaladinHolyPower[i].bg.multiplier = 0.3

		local h = CreateFrame("Frame", nil, PaladinHolyPower[i])
		h:SetFrameLevel(10)
		h:SetPoint("TOPLEFT", -3, 3)
		h:SetPoint("BOTTOMRIGHT", 3, -3)
		lib.createBackdrop(h, 1)

		if (i == 1) then
			PaladinHolyPower[i]:SetPoint('LEFT', PaladinHolyPower, 'LEFT', 1, 0)
		else
			PaladinHolyPower[i]:SetPoint('TOPLEFT', PaladinHolyPower[i-1], "TOPRIGHT", 2, 0)
		end
	end

	self.PaladinHolyPower = PaladinHolyPower
end

-- runebar
lib.addRunes = function(self)
	if playerClass ~= "DEATHKNIGHT" then return end

	local Runes = CreateFrame("Frame", nil, self)
	Runes:SetPoint('CENTER', self.Health, 'TOP', 2, 1)
	Runes:SetHeight(5)
	Runes:SetWidth(self.Health:GetWidth()-15)

	for i= 1, 6 do
		Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, self)
		Runes[i]:SetHeight(5)
		Runes[i]:SetWidth((self.Health:GetWidth() / 6)-5)
		Runes[i]:SetStatusBarTexture(cfg.statusbar_texture)
		Runes[i]:SetFrameLevel(11)
		Runes[i]:SetStatusBarColor(0.14, 0.5, 0.6)
		Runes[i].bg = Runes[i]:CreateTexture(nil, "BORDER")
		Runes[i].bg:SetTexture(cfg.statusbar_texture)
		Runes[i].bg:SetPoint("TOPLEFT", Runes[i], "TOPLEFT", 0, 0)
		Runes[i].bg:SetPoint("BOTTOMRIGHT", Runes[i], "BOTTOMRIGHT", 0, 0)
		Runes[i].bg:SetVertexColor(0.07, 0.15, 0.15)

		local h = CreateFrame("Frame", nil, Runes[i])
		h:SetFrameLevel(10)
		h:SetPoint("TOPLEFT",-3,3)
		h:SetPoint("BOTTOMRIGHT",3,-3)
		lib.createBackdrop(h,1)

		if (i == 1) then
			Runes[i]:SetPoint('LEFT', Runes, 'LEFT', 1, 0)
		else
			Runes[i]:SetPoint('TOPLEFT', Runes[i-1], 'TOPRIGHT', 2, 0)
		end
	end

	self.Runes = Runes
end

-- combo points
lib.addCPoints = function(self)
	local dcp = CreateFrame("Frame", nil, self)
	dcp:SetPoint('CENTER', self.Health, 'TOP', 0, 1)
	dcp:SetHeight(5)
	dcp:SetWidth(self.Health:GetWidth()/2+75)

	for i= 1, 8 do
		dcp[i] = CreateFrame("StatusBar", self:GetName().."_CPoints"..i, self)
		dcp[i]:SetHeight(5)
		dcp[i]:SetStatusBarTexture(cfg.statusbar_texture)
		dcp[i]:SetFrameLevel(11)
		dcp[i].bg = dcp[i]:CreateTexture(nil, "BORDER")
		dcp[i].bg:SetTexture(cfg.statusbar_texture)
		dcp[i].bg:SetPoint("TOPLEFT", dcp[i], "TOPLEFT", 0, 0)
		dcp[i].bg:SetPoint("BOTTOMRIGHT", dcp[i], "BOTTOMRIGHT", 0, 0)
		dcp[i].bg.multiplier = 0.3

		local h = CreateFrame("Frame", nil, dcp[i])
		h:SetFrameLevel(10)
		h:SetPoint("TOPLEFT",-3,3)
		h:SetPoint("BOTTOMRIGHT",3,-3)
		lib.createBackdrop(h,1)

		if (i == 1) then
			dcp[i]:SetPoint('LEFT', dcp, 'LEFT', 1, 0)
		else
			dcp[i]:SetPoint('TOPLEFT', dcp[i-1], 'TOPRIGHT', 2, 0)
		end
	end

	dcp[1]:SetStatusBarColor(.3,.9,.3)
	dcp[2]:SetStatusBarColor(.3,.9,.3)
	dcp[3]:SetStatusBarColor(.3,.9,.3)
	dcp[4]:SetStatusBarColor(.9,.9,0)
	dcp[5]:SetStatusBarColor(.9,.3,.3)
	dcp[6]:SetStatusBarColor(.9,.3,.3)
	dcp[7]:SetStatusBarColor(.9,.3,.3)
	dcp[8]:SetStatusBarColor(.9,.3,.3)

	self.DrkCPoints = dcp
end


-- Heal Prediction
lib.HealPrediction_Override = function(self, event, unit)
	local element = self.HealPrediction
	local parent = self.Health


	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	if maxHealth == 0 or UnitIsDeadOrGhost(unit) then
		element.healingBar:Hide()
		element.absorbsBar:Hide()
		return
	end

	local missing = maxHealth - health

	local healing = UnitGetIncomingHeals(unit) or 0

	if (healing / maxHealth) >= 0.01 and missing > 0 then
		local bar = element.healingBar
		bar:Show()
		bar:SetMinMaxValues(0, maxHealth)
		if healing > missing then
			bar:SetValue(missing)
			missing = 0
		else
			bar:SetValue(healing)
			missing = missing - healing
		end
		parent = bar
	else
		element.healingBar:Hide()
	end

	local absorbs = UnitGetTotalAbsorbs(unit) or 0
	if (absorbs / maxHealth) >= 0.01 and missing > 0 then
		local bar = element.absorbsBar
		bar:Show()
		bar:SetPoint("TOPLEFT", parent:GetStatusBarTexture(), "TOPRIGHT")
		bar:SetPoint("BOTTOMLEFT", parent:GetStatusBarTexture(), "BOTTOMRIGHT")
		bar:SetMinMaxValues(0, maxHealth)
		if absorbs > missing then
			bar:SetValue(missing)
		else
			bar:SetValue(absorbs)
		end
	else
		element.absorbsBar:Hide()
	end
end

lib.addHealPred = function(self)
	if not cfg.showIncHeals then return end

	local health = self.Health

	local healing = CreateFrame('StatusBar', nil, health)
	healing:SetPoint('TOPLEFT', health:GetStatusBarTexture(), 'TOPRIGHT')
	healing:SetPoint('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
	healing:SetWidth(self:GetWidth())
	healing:SetStatusBarTexture(cfg.statusbar_texture)
	healing:SetStatusBarColor(0.25, 1, 0.25, 0.5)
	healing:SetFrameLevel(1)

	local absorbs = CreateFrame('StatusBar', nil, health)
	absorbs:SetPoint('TOPLEFT', healing:GetStatusBarTexture(), 'TOPRIGHT')
	absorbs:SetPoint('BOTTOMLEFT', healing:GetStatusBarTexture(), 'BOTTOMRIGHT')
	absorbs:SetWidth(self:GetWidth())
	absorbs:SetStatusBarTexture(cfg.statusbar_texture)
	absorbs:SetStatusBarColor(0.25, 0.8, 1, 0.5)
	absorbs:SetFrameLevel(1)

	self.HealPrediction = {
		healingBar = healing,
		absorbsBar = absorbs,
		Override = lib.HealPrediction_Override
	}
end


-- Plugins -------------------------------------------

lib.addRaidDebuffs = function(self)
	local raid_debuffs = cfg.DebuffWatchList

	local debuffs = raid_debuffs.debuffs
	local CustomFilter = function(icons, ...)
		local _, icon, _, _, _, _, dtype, _, _, _, _, _, spellID = ...
		name = tostring(spellID)
		if debuffs[name] then
			icon.priority = debuffs[name]
			return true
		else
			icon.priority = 0
		end
	end


	local debuffs = CreateFrame("Frame", nil, self)
	debuffs:SetWidth(12)
	debuffs:SetHeight(12)
	debuffs:SetFrameLevel(7)
	debuffs:SetPoint("TOPRIGHT", self, "TOPRIGHT", -4, -4)
	debuffs.size = 12

	debuffs.CustomFilter = CustomFilter
	self.raidDebuffs = debuffs

end

lib.addExperienceBar = function(self)
	local Experience = CreateFrame('StatusBar', nil, self)

	Experience:SetPoint('TOPRIGHT', self.Health, 'TOPLEFT', -3, 0)
	Experience:SetWidth(3)
	Experience:SetHeight(self:GetHeight())
	Experience:SetFrameLevel(6)
	Experience:SetStatusBarTexture(cfg.statusbar_texture)
	Experience:SetStatusBarColor(.407, .13, .545)

	Experience:SetOrientation("VERTICAL")
	Experience:GetStatusBarTexture():SetHorizTile(false)
	Experience:GetStatusBarTexture():SetVertTile(true)

	Experience.Rested = CreateFrame('StatusBar', nil, Experience)
	Experience.Rested:SetAllPoints(Experience)
	Experience.Rested:SetStatusBarTexture(cfg.statusbar_texture)
	Experience.Rested:SetStatusBarColor(.117,.55,1)

	Experience.Rested.bg = Experience.Rested:CreateTexture(nil, 'BACKGROUND')
	Experience.Rested.bg:SetAllPoints(Experience)
	Experience.Rested.bg:SetTexture(cfg.statusbar_texture)
	Experience.Rested.bg:SetVertexColor(0, 0, 0)

	local h = CreateFrame("Frame", nil, Experience.Rested)
	h:SetFrameLevel(5)
	h:SetPoint("TOPLEFT", -3, 3)
	h:SetPoint("BOTTOMRIGHT", 3, -3)
		local backdrop_tab = {
			bgFile = cfg.backdrop_texture,
			edgeFile = cfg.backdrop_edge_texture,
			tile = false,
			tileSize = 0,
			edgeSize = 4,
			insets = {
			  left = 2,
			  right = 2,
			  top = 2,
			  bottom = 2,
			},
		  }
	h:SetBackdrop(backdrop_tab);
	h:SetBackdropColor(0,0,0,1)
	h:SetBackdropBorderColor(0,0,0,0.8)

	Experience.Text = lib.gen_fontstring(Experience, cfg.smallfont, 8, 'OUTLINE')
	Experience.Text:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMLEFT", -1, 0)
	Experience.Text:SetJustifyH("RIGHT")
	Experience.Text:SetWordWrap(true)

	self:Tag(Experience.Text, "[drk:xp]")
	Experience.Text:SetAlpha(0)

	self.Experience = Experience
end

lib.addArtifactPowerBar = function(self)
	local ArtifactPower = CreateFrame('StatusBar', nil, self)
	if UnitLevel('player') == MAX_PLAYER_LEVEL then
		ArtifactPower:SetPoint('TOPRIGHT', self.Health, 'TOPLEFT', -3, 0)
	else
		ArtifactPower:SetPoint('TOPRIGHT', self.Experience, 'TOPLEFT', -3, 0)
	end
	ArtifactPower:SetWidth(3)
	ArtifactPower:SetHeight(self:GetHeight())
	ArtifactPower:SetFrameLevel(6)
	ArtifactPower:SetStatusBarTexture(cfg.statusbar_texture)
	ArtifactPower:GetStatusBarTexture():SetHorizTile(false)
	ArtifactPower:GetStatusBarTexture():SetVertTile(true)
	ArtifactPower:SetOrientation("VERTICAL")
	ArtifactPower:SetStatusBarColor(.9, .8, .5)

	ArtifactPower.bg = ArtifactPower:CreateTexture(nil, 'BACKGROUND')
	ArtifactPower.bg:SetAllPoints(ArtifactPower)
	ArtifactPower.bg:SetTexture(cfg.statusbar_texture)
	ArtifactPower.bg:SetVertexColor(0, 0, 0)

	local h = CreateFrame("Frame", nil, ArtifactPower)
	h:SetFrameLevel(5)
	h:SetPoint("TOPLEFT", -3, 3)
	h:SetPoint("BOTTOMRIGHT", 3, -3)
	lib.createBackdrop(h, 1)

	ArtifactPower.Text = lib.gen_fontstring(ArtifactPower, cfg.smallfont, 8, 'OUTLINE')
	ArtifactPower.Text:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -1, 0)
	ArtifactPower.Text:SetJustifyH("RIGHT")
	ArtifactPower.Text:SetWordWrap(true)
	ArtifactPower.Text:SetAlpha(0)

	ArtifactPower.PostUpdate = function(self, event, isShown)
	    if (not isShown) then return end
    	self.Text:SetFormattedText(
    		"%d / %d%s",
    		self.power,
    		self.powerForNextTrait,
    		self.numTraitsLearnable > 0 and "\n  +" .. self.numTraitsLearnable .. " trait" or ""
    	)
	end

	if not cfg.alwaysShowArtifactXPBar then
		ArtifactPower:SetAlpha(0)
	end

	self.ArtifactPower = ArtifactPower
end

--gen hilight texture
lib.addHighlight = function(f)
    local OnEnter = function(f)
		UnitFrame_OnEnter(f)
		f.Highlight:Show()
		if f.Experience ~= nil then
			f.Experience.Text:SetAlpha(0.9)
		end
		if f.ArtifactPower ~= nil then
			if not cfg.alwaysShowArtifactXPBar then
				f.ArtifactPower:SetAlpha(1)
			end
			f.ArtifactPower.Text:SetAlpha(1)
		end
		if f.mystyle == "raid" then
			if not cfg.showTooltips then GameTooltip:Hide() end
			if cfg.showRoleIcons then f.LFDRole:SetAlpha(1) end
		end
    end
    local OnLeave = function(f)
		UnitFrame_OnLeave(f)
		f.Highlight:Hide()
		if f.Experience ~= nil then
			f.Experience.Text:SetAlpha(0)
		end
		if f.ArtifactPower ~= nil then
			if not cfg.alwaysShowArtifactXPBar then
				f.ArtifactPower:SetAlpha(0)
			end
			f.ArtifactPower.Text:SetAlpha(0)
		end
		if f.mystyle == "raid" then
			if cfg.showRoleIcons then f.LFDRole:SetAlpha(0) end
		end
    end
    f:SetScript("OnEnter", OnEnter)
    f:SetScript("OnLeave", OnLeave)
    local hl = f.Health:CreateTexture(nil, "OVERLAY")
    hl:SetAllPoints(f.Health)
    hl:SetTexture(cfg.highlight_texture)
    hl:SetVertexColor(.5,.5,.5,.1)
    hl:SetBlendMode("ADD")
    hl:Hide()
    f.Highlight = hl
end


-----------------------------
-- HANDOVER
-----------------------------

--hand the lib to the namespace for further usage...this is awesome because you can reuse functions in any of your layout files
ns.lib = lib
