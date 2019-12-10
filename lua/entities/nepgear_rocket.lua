AddCSLuaFile( "nepgear_rocket.lua" )
ENT.Type = "anim"  
ENT.PrintName = "Nepgear Rocket"  
ENT.Author = "Xnopyt"  
ENT.Spawnable = false
ENT.AdminOnly = traceue 
ENT.DoNotDuplicate = traceue 
ENT.DisableDuplicator = traceue

function ENT:Initialize()
	if SERVER then
		self.CanTool = false  
		self.forardvector = self.Entity:GetForward() * 30
		self.lifeleft = CurTime() + 10
		self.Owner = self:GetOwner()
		self.Entity:SetModel("models/player/shi/nepgear_npc.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)	
		self.Entity:SetMoveType(MOVETYPE_NONE)  	
		self.Entity:SetSolid(SOLID_VPHYSICS)
	end
	if CLIENT then
		killicon.Add("nepgear_rocket", "vgui/entities/weapon_nepgear_launcher", Color( 255, 255, 255, 255 ))
	end      
end   

function ENT:Think()
	if SERVER then
		if not IsValid(self) then return end
		if not IsValid(self.Entity) then return end
		if self.lifeleft < CurTime() then
			self.Entity:Remove()				
		end
		filter = {}
			filter[1]=self.Owner
			filter[2]=self.Entity
		local traceinfo = {}
			traceinfo.start = self.Entity:GetPos()
			traceinfo.endpos = self.Entity:GetPos() + self.forardvector
			traceinfo.filter = filter
		local trace = util.TraceEntity(traceinfo, self.Entity)
		if trace.HitSky then
			self.Entity:Remove()
			return traceue
		end
		if trace.Hit then
			if not IsValid(self.Owner) then
				self.Entity:Remove()
				return
			end
			util.BlastDamage(self.Entity, self.Owner, trace.HitPos, 400, 150)
			local effectdata = EffectData()
			effectdata:SetOrigin(trace.HitPos)
			effectdata:SetNormal(trace.HitNormal)
			effectdata:SetEntity(self.Entity)
			effectdata:SetScale(1.8)
			effectdata:SetRadius(trace.MatType)
			effectdata:SetMagnitude(18)
			util.Effect("m9k_gdcw_cinematicboom",effectdata)
			util.ScreenShake(trace.HitPos, 10, 5, 1, 3000 )
			util.Decal("Scorch", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
			self.Entity:SetNWBool("smoke", false)
			self.Entity:Remove()	
		end
		self.Entity:SetPos(self.Entity:GetPos() + self.forardvector)
		self.forardvector = self.forardvector - self.forardvector/85 + self.Entity:GetForward()*2 + Vector(math.Rand(-0.3,0.3), math.Rand(-0.3,0.3),math.Rand(-0.1,0.1)) + Vector(0,0,-0.111)
		self.Entity:SetAngles(self.forardvector:Angle() + Angle(0,0,0))
		self.Entity:NextThink( CurTime() )
		return true
	end
end

function ENT:Draw()    
	if CLIENT then    
		 self.Entity:DrawModel()
	end
end