AddCSLuaFile("uni_homing_rocket.lua")
ENT.Type = "anim"  
ENT.PrintName = "Homing Uni Missile"  
ENT.Author = "Xnopyt"  
ENT.Spawnable = false
ENT.AdminOnly = false 
ENT.DoNotDuplicate = true 
ENT.DisableDuplicator = true

function ENT:GetHitPos(ent)
    local model = ent:GetModel() or ""
    if model:find("crow") or model:find("seagull") or model:find("pigeon") then
        return ent:LocalToWorld(ent:OBBCenter() + Vector(0,0,-5))
	elseif ent:LookupBone("ValveBiped.Bip01_R_Calf") and ent:LookupBone("ValveBiped.Bip01_L_Calf") then
		local leftlegpos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_L_Calf"))
		local rightlegpos = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_R_Calf"))
		return LerpVector(0.5, leftlegpos, rightlegpos)
    elseif ent:GetAttachment(ent:LookupAttachment("eyes")) ~= nil then
        return ent:GetAttachment(ent:LookupAttachment("eyes")).Pos - Vector(0,0,30)
    else
        return ent:LocalToWorld(ent:OBBCenter())
    end
end

function ENT:Initialize()
	if SERVER then
		self.forwardvector = self.Entity:GetForward()
		self.lifetime = CurTime() + 15
		self.Owner = self:GetOwner()
		self.Entity:SetModel("models/rtbmodels/neptunia/uni.mdl")
		self.Entity:SetModelScale(1,0)
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_NONE ) 	
		self.Entity:SetSolid( SOLID_VPHYSICS )
		self.Entity:Activate()
	end
	
	if CLIENT then
		killicon.Add( "uni_homing_rocket", "vgui/entities/killicons/weapon_uni_launcher_killicon", Color( 255, 255, 255, 255 ) )
	end
end

function ENT:Think()
	if SERVER then
		if !IsValid(self.target) then
			self.target = nil
		end
		if self.lifetime < CurTime() then self.Entity:Remove() end
		local filter = {}
			filter[1] = self.Owner
			filter[2] = self.Entity
		local trackinfo = {}
			trackinfo.start = self.Entity:GetPos()
			trackinfo.endpos = self.Entity:GetPos() + self.forwardvector
			trackinfo.filter = filter
		local trace = util.TraceEntity(trackinfo, self.Entity)
		if trace.HitSky then
			self.Entity:Remove()
			return true
		end
		if trace.Hit then
			if not IsValid(self.Owner) then
				self.Entity:Remove()
				return
			end
			util.BlastDamage(self.Entity, self.Owner, trace.HitPos, 200, 400)
			local effectdata = EffectData()
			effectdata:SetOrigin(trace.HitPos)
			effectdata:SetNormal(trace.HitNormal)
			effectdata:SetEntity(self.Entity)
			effectdata:SetScale(0.6)
			effectdata:SetRadius(trace.MatType)
			effectdata:SetMagnitude(18)
			util.Effect( "m9k_gdcw_cinematicboom", effectdata )
			util.ScreenShake(trace.HitPos, 10, 5, 1, 3000 )
			util.Decal("Scorch", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
			self.Entity:SetNWBool("smoke", false)
			self.Entity:Remove()	
		end
		if self.target == nil then
			self.Entity:SetAngles(self.forwardvector:Angle() + Angle(0,0,0))
		else
			self.Entity:SetAngles((self:GetHitPos(self.target) - self.Entity:GetPos()):Angle())
		end
		self.Entity:SetPos(self.Entity:GetPos() + self.forwardvector - Vector(0,0,1))
		self.forwardvector = self.forwardvector + self.Entity:GetForward()*2
		self.Entity:NextThink( CurTime() )
		return true
	end
end

function ENT:Draw()
	if CLIENT then
		self.Entity:DrawModel()
	end
end