--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2016 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
	https://github.com/Phanx/oUF_Phanx
------------------------------------------------------------------------
	Element to display incoming resurrections on oUF frames.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.
------------------------------------------------------------------------
	Usage:

	frame.ResInfo = frame.Health:CreateFontString(nil, "OVERLAY")
	frame.ResInfo:SetPoint("CENTER")
----------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "ResInfo element requires oUF")

local LibResInfo = LibStub("LibResInfo-1.0", true)
assert(LibResInfo, "ResInfo element requires LibResInfo-1.0")

local Update, Path, ForceUpdate, Enable, Disable

function HideOnResAccept(self, event, unit)
	if self.unit ~= unit then return end
	if UnitHealth(unit) > 0 then
		self:Hide()
		self:UnregisterEvent("UNIT_HEALTH")
	end
end

function Update(self, event, unit)
	if unit ~= self.unit then return end
	local element = self.ResInfo

	if element.PreUpdate then
		element:PreUpdate(unit)
	end

	local status, endTime, casterUnit, casterGUID = LibResInfo:UnitHasIncomingRes(unit)
	if status then
		element:Show()
		element:RegisterEvent("UNIT_HEALTH", HideOnResAccept)
	else
		element:Hide()
		element:UnregisterEvent("UNIT_HEALTH")
	end

	if element.PostUpdate then
		element:PostUpdate(unit, status)
	end
end

function Path(self, ...)
	return (self.ResInfo.Override or Update)(self, ...)
end

function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

function Enable(self)
	local element = self.ResInfo
	if not element then return end

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	element:Show()

	return true
end

function Disable(self)
	local element = self.ResInfo
	if not element then return end

	element:Hide()
end

oUF:AddElement("ResInfo", Update, Enable, Disable)

------------------------------------------------------------------------

local function Callback(event, unit, guid)
	for i = 1, #oUF.objects do
		local frame = oUF.objects[i]
		if frame.unit and frame.ResInfo then
			Update(frame, event, frame.unit)
		end
	end
end

LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_ResCastStarted", Callback)
LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_ResCastCancelled", Callback)
LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_ResCastFinished", Callback)
LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_ResPending", Callback)
LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_ResUsed", Callback)
LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_ResExpired", Callback)
-- LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_MassResStarted", Callback)
-- LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_MassResCancelled", Callback)
-- LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_MassResFinished", Callback)
-- LibResInfo.RegisterCallback("oUF_ResInfo", "LibResInfo_UnitUpdate", Callback)
