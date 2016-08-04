local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_ComboPoints was unable to locate oUF install")

local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax
local MAX_COMBO_POINTS = MAX_COMBO_POINTS
local cur, max, oldMax;

local Update = function(self, event, unit, powerType)
    if unit and (unit ~= 'player' and unit ~= 'vehicle') then return end
    if powerType and powerType ~= 'COMBO_POINTS' then return end

    local cpoints = self.DrkCPoints
    if(cpoints.PreUpdate) then
        cpoints:PreUpdate()
    end

    if UnitHasVehicleUI('player') and UnitPower('vehicle', 4) >= 1 then
        cur = UnitPower('vehicle', 4)
        max = MAX_COMBO_POINTS
    else
        cur = UnitPower('player', 4)
        max = UnitPowerMax('player', 4)
    end

    if not oldMax or max ~= oldMax then
        local width = cpoints:GetWidth()
        for i = 1, max do
            cpoints[i]:SetWidth(width / max - 2)
        end
        if oldMax and max < oldMax then
            for i = max + 1, oldMax do
                cpoints[i]:Hide()
            end
        end
        oldMax = max
    end

    for i = 1, max do
        if i <= cur then
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
        self:RegisterEvent('UNIT_MAXPOWER', Path)

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
        self:UnregisterEvent('UNIT_MAXPOWER', Path)
    end
end

oUF:AddElement('DrkCPoints', Path, Enable, Disable)
