local addon, ns = ...
local utils = CreateFrame("Frame")

local UnitBuff, UnitDebuff = UnitBuff, UnitDebuff

function utils.UnitBuff(unit, spellId)
	for i = 1, 40 do
		local _, _, _, _, _, _, _, _, _, id = UnitBuff(unit, i)
		if not id then return end
		if (spellId == id) then return UnitBuff(unit, i) end
	end
end

function utils.UnitDebuff(unit, spellId)
	for i = 1, 40 do
		local _, _, _, _, _, _, _, _, _, id = UnitDebuff(unit, i)
		if not id then return end
		if (spellId == id) then return UnitDebuff(unit, i) end
	end
end

ns.utils = utils
