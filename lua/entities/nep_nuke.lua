AddCSLuaFile("nep_nuke.lua")
ENT.Type = "anim"     
ENT.PrintName = "Nep Nuke"  
ENT.Author = "Xnopyt"  
ENT.Purpose = "It's a nep, but it go boom!"  
ENT.Instructions = "NEPU NEPU NEPU NEPU NEPU" 
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.DoNotDuplicate = true 
ENT.DisableDuplicator = true

function ENT:Initialize() 
	if SERVER then
		self.CanTool = false 
		self.downvector = self.Entity:GetUp() * 90
		self.lifeleft = CurTime() + 5
		self.Owner = self.Entity.Owner
		self.Entity:SetModel("models/rtbmodels/neptunia/neptune.mdl")
		self.Entity:SetModelScale(50,0)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_NONE)
		self.Entity:SetSolid(SOLID_VPHYSICS)
	end
	if CLIENT then
		self.Entity:SetRenderAngles(Angle(0,0,0))
	end
end

function ENT:Think()
	if SERVER then
		if not IsValid(self) then return end
		if not IsValid(self.Entity) then return end	
		if self.lifeleft < CurTime() then
			if not IsValid(self.Owner) then
				self.Entity:Remove()
				return
			end
			local nuke = ents.Create("nep_nuke_explode")
			nuke:SetPos( self.Entity:GetPos() )
			nuke:SetOwner(self.Owner)
			nuke:Spawn()
			nuke:Activate()
			self.Entity:Remove()				
		end
		filter = {self.Owner, self.Entity}
		local trace = {}
			trace.start = self.Entity:GetPos()
			trace.endpos = self.Entity:GetPos() + self.downvector
			trace.filter = filter
		local tr = util.TraceLine(trace)
		if tr.HitSky then
			if not IsValid(self.Owner) then
				self.Entity:Remove()
				return
			end			
			local nuke = ents.Create("nep_nuke_explode")
			nuke:SetPos( self.Entity:GetPos() )
			nuke:SetOwner(self.Entity.Owner)
			nuke.Owner = self.Entity.Owner
			nuke:Spawn()
			nuke:Activate()
			self.Entity:Remove()
			self.Entity:SetNWBool("smoke", false)
		end
		if tr.Hit then
			if not IsValid(self.Owner) then
				self.Entity:Remove()
				return
			end	
			local nuke = ents.Create("nep_nuke_explode")
			nuke:SetPos( self.Entity:GetPos() )
			nuke:SetOwner(self.Entity.Owner)
			nuke.Owner = self.Entity.Owner
			nuke:Spawn()
			nuke:Activate()
			self.Entity:Remove()
			self.Entity:SetNWBool("smoke", false)
		end
		self.Entity:SetPos(self.Entity:GetPos() + self.downvector)
		self.downvector = self.downvector - self.downvector/85 + self.Entity:GetUp()*2
		self.Entity:SetAngles(self.downvector:Angle() + Angle(90,0,0))
		self.Entity:NextThink( CurTime() )
		return true
	end
end

function ENT:Draw()
	if CLIENT then
		self.Entity:DrawModel()
	end
end 