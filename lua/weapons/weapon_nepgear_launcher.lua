sound.Add( {
	name = "nepugya",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = "weapons/nepgearlauncher/nepugya.wav"
} )
sound.Add( {
	name = "nepgya",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = "weapons/nepgearlauncher/nepgya.wav"
} )
if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/entities/weapon_nepgear_launcher")
end
SWEP.PrintName = "Nepgear Launcher"
SWEP.Author = "Xnopyt"
SWEP.Category = "Billy's Weapons"
SWEP.Instructions = "Launches Muy Hentai!"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/v_pist_satan2.mdl"
SWEP.WorldModel = "models/weapons/w_m29_satan.mdl"
local oldmodel = ""
local PrimaryShootSound = Sound("nepugya")
local SecondaryShootSound = Sound("nepgya")
function SWEP:Deploy()
	oldmodel = self.Owner:GetModel()
	self.Owner:SetModel("models/player/shi/nepgear.mdl")
	return true
end
function SWEP:Holster()
	self.Owner:SetModel(oldmodel)
	return true
end
function SWEP:PrimaryAttack()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:EmitSound(PrimaryShootSound)
	local aim = self.Owner:GetAimVector()
	local side = aim:Cross(Vector(0,0,1))
	local up = side:Cross(aim)
	local pos = (self.Owner:GetShootPos() + side * 6 + up * -5)

	if SERVER then
		local rocket = ents.Create("nepgear_rocket")
		if !rocket:IsValid() then return false end
		rocket:SetAngles(aim:Angle()+Angle(0,0,0))
		rocket:SetPos(pos)
		rocket:SetOwner(self.Owner)
		rocket:Spawn()
		rocket:Activate()
	end
end
function SWEP:SecondaryAttack()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:EmitSound(SecondaryShootSound)
	local aim = self.Owner:GetAimVector()

	if SERVER then
		local ent = ents.Create("npc_nepgear")
		if !ent:IsValid() then return false end
		ent:SetAngles(aim:Angle()+Angle(0,0,0))
		ent:SetPos( self.Owner:EyePos() + ( self.Owner:GetAimVector() * 60 ) - (Vector(0,0,1)*50) )
		ent:Spawn()
		cleanup.Add(self.Owner, "npcs", ent)
		undo.Create("NPC Nepgear")
			undo.AddEntity(ent)
			undo.SetPlayer(self.Owner)
			undo.SetCustomUndoText("Undone Nepgear")
		undo.Finish()
	end
end