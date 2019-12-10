if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/entities/weapon_nep_nuke")
end
SWEP.PrintName = "Nep Nuke Launch Unit"
SWEP.Author = "Xnopyt"
SWEP.Category = "Billy's Weapons"
SWEP.Instructions = "Summons the Nep Nuke!"
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

if util.IsValidModel("models/weapons/v_c4.mdl") then
    SWEP.ModelC4 = true
    SWEP.ViewModel = "models/weapons/v_c4.mdl"
    SWEP.WorldModel = "models/weapons/w_c4.mdl"
else
    SWEP.ModelC4 = false
    SWEP.ViewModel = "models/weapons/v_toolgun.mdl"
    SWEP.WorldModel = "models/weapons/w_toolgun.mdl"
end

function SWEP:Initialize()
    if self.ModelC4 then
        self:SetWeaponHoldType("slam")
    else
        self:SetWeaponHoldType("pistol")
    end
    self.nextfire = 0
end

function SWEP:Think()
    if self.nextfire ~= 0 then
        if self.nextfire < CurTime() then
            self.nextfire = 0
        end
    end
end

function SWEP:PrimaryAttack()
    if self.nextfire ~= 0 then
        if self:GetOwner():IsPlayer() then
            self:GetOwner():ChatPrint("Nep Nuke is unavalible for " .. math.floor(self.nextfire-CurTime()) .. " Seconds!")
        end
        return
    end
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    timer.Simple(2,function()
        self:SendWeaponAnim(ACT_VM_IDLE)
    end)
    timer.Simple( 3, function()
	    local eyetrace = self.Owner:GetEyeTrace()
        local vPos = self:FindInitialPos(eyetrace.HitPos)
	    nuke = ents.Create("nep_nuke")
	    nuke:SetOwner(self.Owner)
	    nuke.Owner = self.Owner
	    nuke:SetPos(vPos)
	    nuke:SetAngles(Angle(180,0,0))
	    nuke:Spawn()
        nuke:Activate()
    end)
    self.nextfire = (CurTime() + 10)
end

function SWEP:FindInitialPos(vStart)
    local td = {}
        td.start = vStart+Vector(0,0,-32)
        td.endpos = vStart
        td.endpos.z = 16384
        td.mask = MASK_NPCWORLDSTATIC
        td.filter = {}
    local bContinue = true
    local nCount=0
    local tr = {}
    local vPos = nil

    while bContinue && td.start.z <= td.endpos.z do
        nCount = nCount + 1
        tr = util.TraceLine(td)
        if tr.HitSky then
            vPos = tr.HitPos
            bContinue = false
        elseif !tr.Hit then
            td.start = tr.HitPos - Vector(0,0,64)
        elseif tr.HitWorld then
            td.start = tr.HitPos + Vector(0,0,64)
        elseif(IsValid(tr.Entity)) then
            table.insert(td.filter, tr.Entity)
        end
        if nCount>128 then break end
    end
    return (vPos - (Vector(0,0,5000)))
end

if CLIENT then
    function SWEP:ViewModelDrawn()
        local GlowMat = CreateMaterial("AsmLedGlow","UnlitGeneric",{
            ["$basetexture"] = "sprites/light_glow01",
            ["$vertexcolor"] = "1",
            ["$vertexalpha"] = "1",
            ["$additive"] = "1",
        })
        local ent = self.Owner:GetViewModel()
        local pos,ang,offset,res,height,z
        if ent:GetModel() == "models/weapons/v_c4.mdl" then
            pos,ang = ent:GetBonePosition(ent:LookupBone("v_weapon.c4"))
            offset = Vector(-1.8,2.7,1.4)
            offset:Rotate(ang)
            ang:RotateAroundAxis(ang:Forward(),-90)
            ang:RotateAroundAxis(ang:Up(),180)
            res = 0.03
            height = 53
            z = 16
        else
            pos,ang = ent:GetBonePosition(ent:LookupBone("Python"))
            offset = Vector(1.04,2.8,-0.1)
            offset:Rotate(ang)
            ang:RotateAroundAxis(ang:Forward(),43.86)
            ang:RotateAroundAxis(ang:Up(),1)
            ang:RotateAroundAxis(ang:Right(),180)
            res = 0.0234
            height = 94
            z = 32
        end
        pos = pos + offset
        cam.Start3D2D(pos,ang,res)
            surface.SetDrawColor(4,32,4,255)
            surface.DrawRect(0,0,96,height)
            draw.SimpleText("Nep Nuke","AsmScreenFont",48,z,Color(80,192,64,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            draw.SimpleText("Launch Unit","AsmScreenFont",48,z+16,Color(80,192,64,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            cam.End3D2D()
    end
end