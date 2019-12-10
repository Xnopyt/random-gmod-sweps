AddCSLuaFile()

ENT.Base            = "base_nextbot"
ENT.Spawnable       = false
ENT.NoCollide		= false
ENT.StepHeight		= 30

function ENT:Initialize()
	if SERVER then
		self:SetName("Nepgear")
		self:SetSolidMask(MASK_NPCSOLID_BRUSHONLY)
	end
	self:SetModel( "models/player/shi/nepgear_npc.mdl" )
	self.TriedToOpen = false
	self.LastPos = {self:GetPos()}
	self:SetHealth( 100 )
	
end

function ENT:RunBehaviour()
    while true do
		self:StartActivity( ACT_WALK )
		self.loco:SetDesiredSpeed( 200 )
		self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 400 )
		self:StartActivity( ACT_IDLE )
		coroutine.wait( 2 )
		coroutine.yield()
	end
end

function ENT:IsNPC()
	return true
end

list.Set( "NPC", "npc_nepgear", { 
	Name = "Nepgear NPC",
	Class = "npc_nepgear",
	Category = "Billy's NPCs"
} )