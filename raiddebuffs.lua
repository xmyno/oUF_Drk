--[[================================================
	
	Instructions for Setting up oUF_RaidDebuffs
	
===================================================]]

--[[
	Settings and debuff data
	
	You can put these in your layout file, or keep it saparated
]]


local _, ns = ...
local ORD = ns.oUF_RaidDebuffs or oUF_RaidDebuffs

if not ORD then return end


ORD.ShowDispelableDebuff = true
ORD.FilterDispellableDebuff = true
ORD.MatchBySpellName = false -- false: matching by spellID
ORD.SHAMAN_CAN_DECURSE = true


local debuff_data = {
  69065, -- Impaled (Lord Marrowgar)
  71829, -- Dominate Mind (Lady Deathwhisper)
  71822, -- Shadow Resonance (blood council, purple orbs stacks)
  72446, 72444, 72293, 72445, 72256, 72255, -- Mark of the Fallen Champion (Deathbringer Saurfang)
  72385, 72442, 72385, 72441, 72443, -- Boiling Blood (Deathbringer Saurfang)
  70867, 71532, 71473, 71533,  71530, 70950, 70871, 71531, 71525, 70879, 70872, 70949, -- Bite (Blood-Queen Lana'thel)
  70126, -- Frost Beacon (Sindragosa)
  70106, -- Chilled to the bone (Sindragosa, melee debuff)
  69762, -- Unchained Magic (Sindragosa, caster debuff)
  68980, 74325, 74327, 74326, 68980, -- Harvest Soul (Arthas)
  70541, -- Infest (LK)
  --69127, (for testing, Chill of the Throne)
}  

ORD:RegisterDebuffs(debuff_data)

--[[
	Extra stuff
	
	Load debuff data depanding on the zone


local debuff_data = {
	['some place'] = {
		123, 12345
	},
	['other place'] = {
		54321, 321
	}
}

local f = CreateFrame'Frame'
f:SetScript('OnEvent', function(self, event, ...)
	self[event](self, event, ...)
end)


f:RegisterEvent('PLAYER_ENTERING_WORLD')
function f:PLAYER_ENTERING_WORLD()
	ORD:ResetDebuffData()
	
	local zone = GetRealZoneText()
	local zone_data = debuff_data[zone]
	if zone_data then
		ORD:RegisterDebuffs(zone_data)
	end
end]]