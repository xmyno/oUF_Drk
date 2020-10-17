local addon, ns = ...
local cfg = ns.cfg
local core = ns.core
local cast = ns.cast
local _, playerClass = UnitClass("player")

local create = function(self)
    self.unitType = "player"
    self:SetSize(cfg.unitframeWidth * cfg.unitframeScale, 50 * cfg.unitframeScale)
    self:SetPoint("TOPRIGHT", UIParent, "BOTTOM", cfg.playerX, cfg.playerY)
    self:RegisterForClicks('AnyUp')
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", cfg.updateSpec)

    -- Health
    do
        local s = CreateFrame("StatusBar", nil, self)
        s:SetFrameLevel(1)
        s:SetHeight(self:GetHeight() * 0.68)
        s:SetWidth(self:GetWidth())
        s:SetPoint("TOP", 0, 0)
        s:SetStatusBarTexture(cfg.statusbar_texture)
        s:GetStatusBarTexture():SetHorizTile(true)

        local h = CreateFrame("Frame", nil, s, BackdropTemplateMixin and "BackdropTemplate")
        h:SetFrameLevel(0)
        h:SetPoint("TOPLEFT", -4, 4)
        h:SetPoint("BOTTOMRIGHT",4,-4)
        core.createBackdrop(h, 0)

        local b = s:CreateTexture(nil, "BACKGROUND")
        b:SetTexture([[Interface\ChatFrame\ChatFrameBackground]])
        b:SetAllPoints(s)

        self.Health = s
        self.Health.bg = b

        self.Health.FrequentUpdates = true
        self.Health.colorSmooth = true
        self.Health.bg.multiplier = 0.3
        self.Health.Smooth = true
    end
    -- Tag Texts
    do
        local name = core.createFontString(self.Health, cfg.font, cfg.fontsize.unitframe, "NONE")
        name:SetPoint("LEFT", self.Health, "TOPLEFT", 5, -10)
        name:SetJustifyH("LEFT")
        name.frequentUpdates = true
        local hpval = core.createFontString(self.Health, cfg.font, cfg.fontsize.unitframe, "NONE")
        hpval:SetPoint("RIGHT", self.Health, "TOPRIGHT", -3, -10)
        hpval.frequentUpdates = true
        local powerval = core.createFontString(self.Health, cfg.font, cfg.fontsize.unitframe, "THINOUTLINE")
        powerval:SetPoint("RIGHT", self.Health, "BOTTOMRIGHT", 3, -16)

        name:SetPoint("RIGHT", hpval, "LEFT", -2, 0)
        self:Tag(name, "[drk:color][drk:power]|r[drk:afkdnd]")
        self:Tag(hpval, "[drk:hp]")
    end
    -- Power
    do
        local s = CreateFrame("StatusBar", nil, self)
        s:SetFrameLevel(1)
        s:SetHeight(self:GetHeight() * 0.26)
        s:SetWidth(self:GetWidth())
        s:SetStatusBarTexture(cfg.powerbar_texture)
        s:GetStatusBarTexture():SetHorizTile(true)
        s:SetPoint("BOTTOM", self, "BOTTOM", 0, 0)
        s.frequentUpdates = true

        local h = CreateFrame("Frame", nil, s, BackdropTemplateMixin and "BackdropTemplate" )
        h:SetFrameLevel(0)
        h:SetPoint("TOPLEFT", -4, 4)
        h:SetPoint("BOTTOMRIGHT", 4, -4)
        core.createBackdrop(h, 0)

        local b = s:CreateTexture(nil, "BACKGROUND")
        b:SetTexture(cfg.powerbar_texture)
        b:SetAllPoints(s)

        self.Power = s
        self.Power.bg = b
        self.Power.colorClass = true
        self.Power.bg.multiplier = 0.5
        self.Power.Smooth = true
    end
    -- Highlight
    core.addHighlight(self)
    -- Portrait
    if cfg.showPortraits then
        local p = CreateFrame("PlayerModel", nil, self)
        p:SetFrameLevel(4)
        p:SetHeight(19.8)
        p:SetWidth(self:GetWidth()-17.55)
        p:SetPoint("BOTTOM", self, "BOTTOM", 0, 8)
        --helper
        local h = CreateFrame("Frame", nil, p, BackdropTemplateMixin and "BackdropTemplate")
        h:SetFrameLevel(3)
        h:SetPoint("TOPLEFT", -4, 4)
        h:SetPoint("BOTTOMRIGHT", 5, -5)
        core.createBackdrop(h, 0)

        self.Portrait = p
        -- TODO does this do anything?
        local hl = self.Portrait:CreateTexture(nil, "OVERLAY")
        hl:SetAllPoints(self.Portrait)
        hl:SetTexture(cfg.portrait_texture)
        hl:SetVertexColor(.5, .5, .5, .8)
        hl:SetBlendMode("ALPHAKEY")
        hl:Hide()
    end
    -- AltPowerBar
    if cfg.AltPowerBarPlayer then
        local s = CreateFrame("StatusBar", nil, self.Power) -- TODO attach to health
        s:SetFrameLevel(1)
        s:SetSize(3, self:GetHeight()+0.5)
        s:SetOrientation("VERTICAL")
        s:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 3, 0)
        s:SetStatusBarTexture(cfg.powerbar_texture)
        s:GetStatusBarTexture():SetHorizTile(false)
        s:SetStatusBarColor(235/255, 235/255, 235/255)

        local h = CreateFrame("Frame", nil, s, BackdropTemplateMixin and "BackdropTemplate")
        h:SetFrameLevel(0)
        h:SetPoint("TOPLEFT", -3, 3)
        h:SetPoint("BOTTOMRIGHT", 3, -3)
        core.createBackdrop(h, 1)

        local b = s:CreateTexture(nil, "BACKGROUND")
        b:SetTexture(cfg.powerbar_texture)
        b:SetAllPoints(s)
        b:SetVertexColor(45/255, 45/255, 45/255)

        self.AlternativePower = s
        self.AlternativePower.bg = b
    end
    -- AltPowerBar Text
    do
        local altpphelpframe = CreateFrame("Frame", nil, self, BackdropTemplateMixin and "BackdropTemplate")
        if cfg.AltPowerBarPlayer then
            altpphelpframe:SetPoint("LEFT", self.AltPowerBar, "BOTTOMLEFT", 1, 4)
        else
            altpphelpframe:SetPoint("CENTER", PlayerPowerBarAlt, "TOP", 0, -5) -- adds percentage to standard blizzard altPowerBar
        end
        altpphelpframe:SetFrameLevel(7)
        altpphelpframe:SetSize(30, 10)
        local altppbartext = core.createFontString(altpphelpframe, cfg.font, cfg.fontsize.smalltext, "OUTLINE")
        altppbartext:SetPoint("LEFT", altpphelpframe, "LEFT", 0, 0)
        altppbartext:SetJustifyH("LEFT")

        self:Tag(altppbartext, "[drk:altpowerbar]")
    end
    -- HealPrediction
    if cfg.showIncHeals then
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

        self.HealthPrediction = {
            healingBar = healing,
            absorbsBar = absorbs,
            Override = core.HealthPrediction_Override
        }
    end
    -- Experience
    if cfg.showExperienceBar then
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

        Experience.Rested:SetOrientation("VERTICAL")
        Experience.Rested:GetStatusBarTexture():SetHorizTile(false)
        Experience.Rested:GetStatusBarTexture():SetVertTile(true)

        Experience.Rested.bg = Experience.Rested:CreateTexture(nil, 'BACKGROUND')
        Experience.Rested.bg:SetAllPoints(Experience)
        Experience.Rested.bg:SetTexture(cfg.statusbar_texture)
        Experience.Rested.bg:SetVertexColor(0, 0, 0)

        local h = CreateFrame("Frame", nil, Experience.Rested, BackdropTemplateMixin and "BackdropTemplate")
        h:SetFrameLevel(5)
        h:SetPoint("TOPLEFT", -3, 3)
        h:SetPoint("BOTTOMRIGHT", 3, -3)
        core.createBackdrop(h, 1)

        Experience.Text = core.createFontString(Experience, cfg.smallfont, cfg.fontsize.smalltext, 'OUTLINE')
        Experience.Text:SetPoint("BOTTOMRIGHT", Experience, "BOTTOMLEFT", -4, 0)
        Experience.Text:SetJustifyH("RIGHT")
        Experience.Text:SetWordWrap(true)

        self:Tag(Experience.Text, "[drk:xp]")
        Experience.Text:SetAlpha(0)

        self.Experience = Experience
    end
    -- ArtifactPower
    if cfg.showArtifactPowerBar then
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

        local h = CreateFrame("Frame", nil, ArtifactPower, BackdropTemplateMixin and "BackdropTemplate")
        h:SetFrameLevel(5)
        h:SetPoint("TOPLEFT", -3, 3)
        h:SetPoint("BOTTOMRIGHT", 3, -3)
        core.createBackdrop(h, 1)

        ArtifactPower.Text = core.createFontString(ArtifactPower, cfg.smallfont, cfg.fontsize.smalltext, 'OUTLINE')
        ArtifactPower.Text:SetPoint("TOPRIGHT", ArtifactPower, "TOPLEFT", -1, 0)
        ArtifactPower.Text:SetJustifyH("RIGHT")
        ArtifactPower.Text:SetWordWrap(true)
        ArtifactPower.Text:SetAlpha(0)

        self:Tag(ArtifactPower.Text, "[drk:artifactpower]")

        if not cfg.alwaysShowArtifactXPBar then
            ArtifactPower:SetAlpha(0)
        end

        self.ArtifactPower = ArtifactPower
    end
    -- Buffs and Debuffs
    if cfg.playerAuras then
        BuffFrame:Hide()
        core.addBuffs(self)
        core.addDebuffs(self)
    end
    -- Castbars
    if cfg.Castbars then
        local s = CreateFrame("StatusBar", "oUF_DrkCastbar"..self.unitType, self)
        if cfg.playerCastBarOnUnitframe and cfg.showPortraits then
            s:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", 21, 0.5)
            s:SetHeight(self.Portrait:GetHeight()+1.5)
            s:SetWidth(self:GetWidth()-37.45)
        else
            s:SetPoint("BOTTOM", UIParent, "BOTTOM", cfg.playerCastBarX, cfg.playerCastBarY)
            s:SetHeight(cfg.playerCastBarHeight)
            s:SetWidth(cfg.playerCastBarWidth)
        end
        s:SetStatusBarTexture(cfg.statusbar_texture)
        s:SetStatusBarColor(0.5, 0.5, 1, 1)
        s:SetFrameLevel(9)
        --color
        s.CastingColor = {0.5, 0.5, 1}
        s.CompleteColor = {0.5, 1, 0}
        s.FailColor = {1.0, 0.05, 0}
        s.ChannelingColor = {0.5, 0.5, 1}
        s.NotInterruptableColor = {1, 0.2, 0}
        --helper
        local h = CreateFrame("Frame", nil, s, BackdropTemplateMixin and "BackdropTemplate")
        h:SetFrameLevel(0)
        h:SetPoint("TOPLEFT", -4, 4)
        h:SetPoint("BOTTOMRIGHT", 4, -4)
        core.createBackdrop(h, 0)
        --backdrop
        local b = s:CreateTexture(nil, "BACKGROUND")
        b:SetTexture(cfg.statusbar_texture)
        b:SetAllPoints(s)
        b:SetVertexColor(0.1, 0.1, 0.2, 0.7)
        --spark
        local sp = s:CreateTexture(nil, "OVERLAY")
        sp:SetBlendMode("ADD")
        sp:SetAlpha(0.5)
        sp:SetHeight(s:GetHeight()*2.5)
        --spell text
        local txt = core.createFontString(s, cfg.font, cfg.fontsize.castbar, "NONE")
        txt:SetPoint("LEFT", 4, 0)
        txt:SetJustifyH("LEFT")
        --time
        local t = core.createFontString(s, cfg.font, cfg.fontsize.castbar, "NONE")
        t:SetPoint("RIGHT", -2, 0)
        txt:SetPoint("RIGHT", t, "LEFT", -5, 0)
        --icon
        local i = s:CreateTexture(nil, "ARTWORK")

        if cfg.playerCastBarOnUnitframe then
            i:SetPoint("RIGHT", s, "LEFT", 1, 0)
            i:SetSize(s:GetHeight(),s:GetHeight())
        else
            i:SetPoint("RIGHT", s, "LEFT", -5, 0)
            i:SetSize(s:GetHeight()-1, s:GetHeight()-1)
        end
        i:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        --helper2 for icon
        local h2 = CreateFrame("Frame", nil, s, BackdropTemplateMixin and "BackdropTemplate")
        h2:SetFrameLevel(0)
        h2:SetPoint("TOPLEFT", i, "TOPLEFT", -4, 4)
        h2:SetPoint("BOTTOMRIGHT", i,"BOTTOMRIGHT", 4, -4)
        core.createBackdrop(h2, 0)

        --latency only for player unit
        local z = s:CreateTexture(nil, "OVERLAY")
        z:SetTexture(cfg.statusbar_texture)
        z:SetVertexColor(1, 0, 0, 0.6)
        z:SetPoint("TOPRIGHT")
        z:SetPoint("BOTTOMRIGHT")
        s:SetFrameLevel(10)
        s.SafeZone = z
        --custom latency display
        local l = core.createFontString(s, cfg.font, cfg.fontsize.castbar - 2, "THINOUTLINE")
        l:SetPoint("CENTER", -2, 17)
        l:SetJustifyH("RIGHT")
        l:Hide()
        s.Lag = l

        s.OnUpdate = cast.OnCastbarUpdate
        s.PostCastStart = cast.PostCastStart
        s.PostCastStop = cast.PostCastStop
        s.PostCastFail = cast.PostCastFail

        self.Castbar = s
        self.Castbar.Text = txt
        self.Castbar.Time = t
        self.Castbar.Icon = i
        self.Castbar.Spark = sp
    end
    -- Info Icons
    do
        local h = CreateFrame("Frame", nil, self, BackdropTemplateMixin and "BackdropTemplate")
        h:SetAllPoints(self)
        h:SetFrameLevel(10)
        --Combat Icon
        local CombatIndicator = h:CreateTexture(nil, "OVERLAY")
        CombatIndicator:SetSize(15,15)
        CombatIndicator:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
        CombatIndicator:SetTexCoord(0.58, 0.90, 0.08, 0.41)
        CombatIndicator:SetPoint("BOTTOMRIGHT", 7, -7)
        self.CombatIndicator = CombatIndicator
        -- PvP Icon
        local PvPIndicator = h:CreateTexture(nil, "OVERLAY")
        PvPIndicator:SetHeight(12)
        PvPIndicator:SetWidth(12)
        PvPIndicator:SetPoint("TOPRIGHT", 6, 6)
        self.PvPIndicator = PvPIndicator
        -- Rest Icon
        local RestingIndicator = h:CreateTexture(nil, "OVERLAY")
        RestingIndicator:SetSize(15,15)
        RestingIndicator:SetPoint("BOTTOMRIGHT", -12, -8)
        RestingIndicator:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
        RestingIndicator:SetTexCoord(0.09, 0.43, 0.08, 0.42)
        self.RestingIndicator = RestingIndicator
        --LFDRole icon
        local GroupRoleIndicator = h:CreateTexture(nil, "OVERLAY")
        GroupRoleIndicator:SetSize(15, 15)
        GroupRoleIndicator:SetAlpha(0.9)
        GroupRoleIndicator:SetPoint("BOTTOMLEFT", -6, -8)
        self.GroupRoleIndicator = GroupRoleIndicator
        -- Leader, Assist, Master Looter Icon
        local LeaderIndicator = h:CreateTexture(nil, "OVERLAY")
        LeaderIndicator:SetPoint("TOPLEFT", self, 0, 8)
        LeaderIndicator:SetSize(12,12)
        self.LeaderIndicator = LeaderIndicator
        local AssistantIndicator = h:CreateTexture(nil, "OVERLAY")
        AssistantIndicator:SetPoint("TOPLEFT", self, 0, 8)
        AssistantIndicator:SetSize(12,12)
        self.AssistantIndicator = AssistantIndicator
        -- Raid Marks
        local RaidTargetIndicator = h:CreateTexture(nil, "OVERLAY")
        RaidTargetIndicator:SetPoint("RIGHT", self, "LEFT", 5, 6)
        RaidTargetIndicator:SetSize(20, 20)
        self.RaidTargetIndicator = RaidTargetIndicator
    end
    -- Class Bars
    do
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

        local h = CreateFrame("Frame", nil, AdditionalPower, BackdropTemplateMixin and "BackdropTemplate")
        h:SetFrameLevel(0)
        h:SetPoint("TOPLEFT", -4, 4)
        h:SetPoint("BOTTOMRIGHT", 4, -4)
        core.createBackdrop(h, 0)

        self.AdditionalPower = AdditionalPower
        self.AdditionalPower.bg = AdditionalPower.bg
    end
    do
        local maxPower, color
        if playerClass == "MAGE" then
            maxPower = 4
            color = {0.15, 0.55, 0.8}
        elseif playerClass == "MONK" then
            maxPower = 6
            color = {0.9, 0.99, 0.9}
        elseif playerClass == "PALADIN" then
            maxPower = 5
            color = {0.9, 0.95, 0.33}
        elseif playerClass == "WARLOCK" then
            maxPower = 5
            color = {0.86, 0.22, 1}
        end

        if maxPower ~= nil then
            local ClassPower = CreateFrame("Frame", nil, self, BackdropTemplateMixin and "BackdropTemplate")
            ClassPower:SetPoint('CENTER', self.Health, 'TOP', 0, 1)
            ClassPower:SetHeight(5)
            ClassPower:SetWidth(self.Health:GetWidth() / 2 + 75)
            ClassPower:SetFrameLevel(10)

            for i = 1, maxPower do
                ClassPower[i] = CreateFrame("StatusBar", self:GetName()..playerClass..i, self)
                ClassPower[i]:SetHeight(5)
                ClassPower[i]:SetWidth((ClassPower:GetWidth() / maxPower) - 2)
                ClassPower[i]:SetStatusBarTexture(cfg.statusbar_texture)
                ClassPower[i]:SetStatusBarColor(color[1], color[2], color[3])
                ClassPower[i]:SetFrameLevel(11)

                local h = CreateFrame("Frame", nil, ClassPower[i], BackdropTemplateMixin and "BackdropTemplate")
                h:SetFrameLevel(10)
                h:SetPoint("TOPLEFT", -3, 3)
                h:SetPoint("BOTTOMRIGHT", 3, -3)
                core.createBackdrop(h, 1)

                if (i == 1) then
                    ClassPower[i]:SetPoint('LEFT', ClassPower, 'LEFT', 1, 0)
                else
                    ClassPower[i]:SetPoint('TOPLEFT', ClassPower[i-1], "TOPRIGHT", 1, 0)
                end
            end

            self.ClassPower = ClassPower
        end
    end
    if cfg.showRunebar and playerClass == "DEATHKNIGHT" then
        local Runes = CreateFrame("Frame", nil, self, BackdropTemplateMixin and "BackdropTemplate")
        Runes:SetPoint('CENTER', self.Health, 'TOP', 2, 1)
        Runes:SetHeight(5)
        Runes:SetWidth(self.Health:GetWidth()-15)

        for i= 1, 6 do
            Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, self)
            Runes[i]:SetHeight(5)
            Runes[i]:SetWidth((self.Health:GetWidth() / 6)-5)
            Runes[i]:SetStatusBarTexture(cfg.statusbar_texture)
            Runes[i]:SetFrameLevel(11)
            Runes[i]:SetStatusBarColor(70/255, 180/255, 210/255)
            Runes[i].bg = Runes[i]:CreateTexture(nil, "BORDER")
            Runes[i].bg:SetTexture(cfg.statusbar_texture)
            Runes[i].bg:SetPoint("TOPLEFT", Runes[i], "TOPLEFT", 0, 0)
            Runes[i].bg:SetPoint("BOTTOMRIGHT", Runes[i], "BOTTOMRIGHT", 0, 0)
            Runes[i].bg.multiplier = 0.2

            local h = CreateFrame("Frame", nil, Runes[i], BackdropTemplateMixin and "BackdropTemplate")
            h:SetFrameLevel(10)
            h:SetPoint("TOPLEFT",-3,3)
            h:SetPoint("BOTTOMRIGHT",3,-3)
            core.createBackdrop(h,1)

            if (i == 1) then
                Runes[i]:SetPoint('LEFT', Runes, 'LEFT', 1, 0)
            else
                Runes[i]:SetPoint('TOPLEFT', Runes[i-1], 'TOPRIGHT', 1, 0)
            end
        end

        self.Runes = Runes
    end
    if cfg.showComboPoints then
        local dcp = CreateFrame("Frame", nil, self, BackdropTemplateMixin and "BackdropTemplate")
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

            local h = CreateFrame("Frame", nil, dcp[i], BackdropTemplateMixin and "BackdropTemplate")
            h:SetFrameLevel(10)
            h:SetPoint("TOPLEFT", -3, 3)
            h:SetPoint("BOTTOMRIGHT", 3, -3)
            core.createBackdrop(h,1)

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
end

oUF:RegisterStyle("drk:player", create)
oUF:SetActiveStyle("drk:player")
oUF:Spawn("player", "oUF_DrkPlayerFrame")
