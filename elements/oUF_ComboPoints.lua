local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_ComboPoints was unable to locate oUF install")

local UnitPower = UnitPower
local MAX_COMBO_POINTS = MAX_COMBO_POINTS

local Update = function(self, event, unit, powerType)
    if unit and (unit ~= 'player' and unit ~= 'vehicle') then return end
    if powerType and powerType ~= 'COMBO_POINTS' then return end

    local cpoints = self.DrkCPoints
    if(cpoints.PreUpdate) then
        cpoints:PreUpdate()
    end

    local cp
    if UnitHasVehicleUI('player') and UnitPower('vehicle', 4) >= 1 then
        cp = UnitPower('vehicle', 4)
    else
        cp = UnitPower('player', 4)
    end

    for i=1, MAX_COMBO_POINTS do
        if(i <= cp) then
            cpoints[i]:Show()
        else
            cpoints[i]:Hide()
        end
    end

    if(cpoints.PostUpdate) then
        return cpoints:PostUpdate(cp)
    end
end

local Path = function(self, ...)
    return (self.DrkCPoints.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
    return Path(element.__owner, 'ForceUpdate', element.__owner.unit, nil)
end

local Enable = function(self)
    local cpoints = self.DrkCPoints
    if(cpoints) then
        cpoints.__owner = self
        cpoints.ForceUpdate = ForceUpdate

        self:RegisterEvent('UNIT_POWER_FREQUENT', Path)

        for index = 1, MAX_COMBO_POINTS do
            local cpoint = cpoints[index]
            if(cpoint:IsObjectType'Texture' and not cpoint:GetTexture()) then
                cpoint:SetTexture[[Interface\ComboFrame\ComboPoint]]
                cpoint:SetTexCoord(0, 0.375, 0, 1)
            end
        end

        return true
    end
end

local Disable = function(self)
    local cpoints = self.DrkCPoints
    if(cpoints) then
        self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
    end
end

oUF:AddElement('DrkCPoints', Path, Enable, Disable)
