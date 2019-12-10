if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/entities/weapon_melon_launcher")
end
SWEP.PrintName = "Melon Launcher"
SWEP.Author = "Xnopyt"
SWEP.Category = "Billy's Weapons"
SWEP.Instructions = "What do you think it does?"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
local ShootSound = Sound("Metal.SawbladeStick")
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.5)
	self:FireMelon()
end
function SWEP:SecondaryAttack()
	self:FireMelon()
end
function SWEP:FireMelon()
	self:EmitSound(ShootSound)
	if CLIENT then return end
	if SERVER then
		local ent = ents.Create("prop_physics")
		if !IsValid(ent) then return end
		ent:SetModel("models/props_junk/watermelon01.mdl")
		ent:SetPos( self.Owner:EyePos() + ( self.Owner:GetAimVector() * 16 ) )
		ent:SetAngles( self.Owner:EyeAngles() )
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if !IsValid(phys) then ent:Remove() return end
		local velocity = self.Owner:GetAimVector() * 100
		velocity = velocity + (VectorRand()*10)
		phys:ApplyForceCenter(velocity)
		cleanup.Add(self.Owner, "props", ent)
		undo.Create("Thrown_Melon")
			undo.AddEntity(ent)
			undo.SetPlayer(self.Owner)
			undo.SetCustomUndoText("Undone Melon")
		undo.Finish()
	end
end