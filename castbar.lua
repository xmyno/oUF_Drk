  local addon, ns = ...
  local cfg = ns.cfg
  local cast = CreateFrame("Frame")

  -----------------------------
  -- FUNCTIONS
  -----------------------------
  -- special thanks to Allez for coming up with this solution
local channelingTicks = {
	-- druid
	[GetSpellInfo(740)] = 4, -- Tranquility
	-- priest
    [GetSpellInfo(15407)] = 4, -- Mind Flay
	[GetSpellInfo(47540)] = 3, -- Penance
	-- mage
	[GetSpellInfo(5143)] = 5, -- arcane missiles
	[GetSpellInfo(12051)] = 3, -- evocation
    -- monk
    [GetSpellInfo(115175)] = 8, -- soothing mist
    [GetSpellInfo(113656)] = 5, -- fists of fury
}

local ticks = {}

local function updateSafeZone(self)
	local safeZone = self.SafeZone
	local width = self:GetWidth()
	local _, _, _, ms = GetNetStats()

	local safeZoneRatio = (ms / 1e3) / self.max
	if(safeZoneRatio > 1) then
		safeZoneRatio = 1
	end

	safeZone:SetWidth(width * safeZoneRatio)
end

cast.setBarTicks = function(castBar, ticknum)
	if ticknum and ticknum > 0 then
		local delta = castBar:GetWidth() / ticknum
		for k = 1, ticknum do
			if not ticks[k] then
				ticks[k] = castBar:CreateTexture(nil, 'OVERLAY')
				ticks[k]:SetTexture(cfg.statusbar_texture)
				ticks[k]:SetVertexColor(0.8, 0.6, 0.6)
				ticks[k]:SetWidth(1)
				ticks[k]:SetHeight(castBar:GetHeight())
			end
			ticks[k]:ClearAllPoints()
			ticks[k]:SetPoint("CENTER", castBar, "LEFT", delta * k, 0 )
			ticks[k]:Show()
		end
	else
		for k, v in pairs(ticks) do
			v:Hide()
		end
	end
end

cast.OnCastbarUpdate = function(self, elapsed)
	local currentTime = GetTime()
	if self.casting or self.channeling then
		local parent = self:GetParent()
		local duration = self.casting and self.duration + elapsed or self.duration - elapsed
		if (self.casting and duration >= self.max) or (self.channeling and duration <= 0) then
			self.casting = nil
			self.channeling = nil
			return
		end
		if parent.unit == 'player' then
			if self.delay ~= 0 then
				self.Time:SetFormattedText('%.1f | |cffff0000%.1f|r', duration, self.casting and self.max + self.delay or self.max - self.delay)
			else
				self.Time:SetFormattedText('%.1f | %.1f', duration, self.max)
				if self.SafeZone and self.SafeZone.timeDiff then
					self.Lag:SetFormattedText("%d ms", self.SafeZone.timeDiff * 1000)
				end
			end
		else
			self.Time:SetFormattedText('%.1f | %.1f', duration, self.casting and self.max + self.delay or self.max - self.delay)
		end
		self.duration = duration
		self:SetValue(duration)
		self.Spark:SetPoint('CENTER', self:GetStatusBarTexture(), 'LEFT', (duration / self.max) * self:GetWidth(), 0)
	else
		self.Spark:Hide()
		local alpha = self:GetAlpha() - 0.02
		if alpha > 0 then
			self:SetAlpha(alpha)
		else
			self.fadeOut = nil
			self:Hide()
		end
	end
end

cast.PostCastStart = function(self, unit, name, rank, text)
	local pcolor = {1, .5, .5}
	local interruptcb = {.5, .5, 1}
	self:SetAlpha(1.0)
	self.Spark:Show()
	self:SetStatusBarColor(unpack(self.notInterruptible and self.NotInterruptableColor or
		(self.casting and self.CastingColor or self.ChannelingColor)))
	if unit == "player" then
		local sf = self.SafeZone
		if sf then
			sf:ClearAllPoints()
			sf:SetPoint(self:GetReverseFill() and 'LEFT' or 'RIGHT')
			sf:SetPoint('TOP')
			sf:SetPoint('BOTTOM')
			updateSafeZone(self)
		end

		if self.casting then
			cast.setBarTicks(self, 0)
		else
			local spell = UnitChannelInfo(unit)
			self.channelingTicks = channelingTicks[spell] or 0
			cast.setBarTicks(self, self.channelingTicks)
		end
	end
end

cast.PostCastStop = function(self, unit, name, rank, castid)
	if not self.fadeOut then
		self:SetStatusBarColor(unpack(self.CompleteColor))
		self.fadeOut = true
	end
	self:SetValue(self.max)
	self:Show()
end

cast.PostCastFail = function(self, event, unit, name, rank, castid)
	self:SetStatusBarColor(unpack(self.FailColor))
	self:SetValue(self.max)
	if not self.fadeOut then
		self.fadeOut = true
	end
	self:Show()
end

--hand the lib to the namespace for further usage
ns.cast = cast
