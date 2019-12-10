sound.Add( {
	name = "unishootitdown",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = { 100, 100 },
	sound = "weapons/unilauncher/shootitdown.wav"
} )
if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("vgui/entities/weapon_uni_homing_launcher")
end
SWEP.PrintName = "Homing Uni Launcher"
SWEP.Author = "Xnopyt"
SWEP.Category = "Billy's Weapons"
SWEP.Instructions = "It like Uni, but somehow with more aimbot!"
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
SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip			= true
SWEP.ViewModel = "models/weapons/v_p08_luger.mdl"
SWEP.WorldModel = "models/weapons/w_luger_p08.mdl"
local PrimaryShootSound = Sound("unishootitdown")

SWEP.Aimbot = {}
SWEP.Aimbot.Target = nil
SWEP.Aimbot.DeathSequences = {
    ["models/barnacle.mdl"]            = {4,15},
    ["models/antlion_guard.mdl"]    = {44},
    ["models/hunter.mdl"]            = {124,125,126,127,128},
}

function SWEP:Initialize()
	if CLIENT then
		surface.CreateFont( "Arial",
		{
		font = "Arial",
		size = ScreenScale(10),
		weight = 400
		})  
	end
end

function SWEP:GetHeadPos(ent)
    local model = ent:GetModel() or ""
    if model:find("crow") or model:find("seagull") or model:find("pigeon") then
        return ent:LocalToWorld(ent:OBBCenter() + Vector(0,0,-5))
    elseif ent:GetAttachment(ent:LookupAttachment("eyes")) ~= nil then
        return ent:GetAttachment(ent:LookupAttachment("eyes")).Pos
    else
        return ent:LocalToWorld(ent:OBBCenter())
    end
end

function SWEP:Visible(ent)
    local trace = {}
    trace.start = self.Owner:GetShootPos()
    trace.endpos = self:GetHeadPos(ent)
    trace.filter = {self.Owner,ent}
    trace.mask = MASK_SHOT
    local tr = util.TraceLine(trace)
    return tr.Fraction >= 0.99 and true or false
end

function SWEP:Think()
    local ent = self:GetClosestTarget()
	if ent == 0 then
		self.Aimbot.Target = nil
		return
	end
	if self:Visible(ent) then
		self.Aimbot.Target = ent
	else
		self.Aimbot.Target = nil
	end
end

function SWEP:CheckTarget(ent)
    if ent:IsPlayer() then
        if !ent:IsValid() then return false end
        if ent:Health() < 1 then return false end
        if ent == self.Owner then return false end    
        return true
    end
    if ent:IsNPC() then
        if ent:GetMoveType() == 0 then return false end
        if table.HasValue(self.Aimbot.DeathSequences[string.lower(ent:GetModel() or "")] or {},ent:GetSequence()) then return false end
        return true
    end
    return false
end

function SWEP:GetTargets()
    local tbl = {}
    for k,ent in pairs(ents.GetAll()) do
        if self:CheckTarget(ent) == true then
            table.insert(tbl,ent)
        end
    end
    return tbl
end

function SWEP:GetClosestTarget()
    local pos = self.Owner:GetPos()
    local ang = self.Owner:GetAimVector()
    local closest = {0,0}
    for k,ent in pairs(self:GetTargets()) do
        local diff = (ent:GetPos()-pos)
		diff:Normalize()
        diff = diff - ang
        diff = diff:Length()
        diff = math.abs(diff)
        if (diff < closest[2]) or (closest[1] == 0) then
            closest = {ent,diff}
        end
    end
    return closest[1]
end

function SWEP:PrimaryAttack()
	self:EmitSound(PrimaryShootSound)
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	local aim = self.Owner:GetAimVector()
	local side = aim:Cross(Vector(0,0,1))
	local up = side:Cross(aim)
	local pos = (self.Owner:GetShootPos() + side * 6 + up * -5)
	self.Weapon:SetNextPrimaryFire( CurTime() + 1)

	if SERVER then
		local rocket = ents.Create("uni_homing_rocket")
		if self.Aimbot.Target ~= nil then
			rocket:SetVar("target", self.Aimbot.Target)
		end
		if !rocket:IsValid() then return false end
		rocket:SetAngles(aim:Angle()+Angle(0,0,0))
		rocket:SetPos(pos)
		rocket:SetOwner(self.Owner)
		rocket:Spawn()
	end
end

function SWEP:GetCoordiantes(ent)
    local min,max = ent:OBBMins(),ent:OBBMaxs()
    local corners = {
        Vector(min.x,min.y,min.z),
        Vector(min.x,min.y,max.z),
        Vector(min.x,max.y,min.z),
        Vector(min.x,max.y,max.z),
        Vector(max.x,min.y,min.z),
        Vector(max.x,min.y,max.z),
        Vector(max.x,max.y,min.z),
        Vector(max.x,max.y,max.z)
    }

    local minx,miny,maxx,maxy = ScrW() * 2,ScrH() * 2,0,0
    for _,corner in pairs(corners) do
        local screen = ent:LocalToWorld(corner):ToScreen()
        minx,miny = math.min(minx,screen.x),math.min(miny,screen.y)
        maxx,maxy = math.max(maxx,screen.x),math.max(maxy,screen.y)
    end
    return minx,miny,maxx,maxy
end

function SWEP:FixName(ent)
    if ent:IsPlayer() then return ent:Name() end
    if ent:IsNPC() then return ent:GetClass():sub(5,-1) end
    return ""
end

function SWEP:DrawHUD()
    local x,y = ScrW(),ScrH()
    local w,h = x/2,y/2

    local time = CurTime() * -180        

    surface.SetDrawColor(0,255,0,150)

    if self.Aimbot.Target ~= nil then
        local text = "Target locked... ("..self:FixName(self.Aimbot.Target)..")"
        surface.SetFont("Default")
        local size = surface.GetTextSize(text)
        draw.RoundedBox(4,36,y-135,size+10,20,Color(0,0,0,100))
        draw.DrawText(text,"Default",40,y-132,Color(255,255,255,200),TEXT_ALIGN_LEFT)
        local x1,y1,x2,y2 = self:GetCoordiantes(self.Aimbot.Target)
        local edgesize = 8
        surface.SetDrawColor(Color(255,0,0,200))
        
        -- Top left.
        surface.DrawLine(x1,y1,math.min(x1 + edgesize,x2),y1)
        surface.DrawLine(x1,y1,x1,math.min(y1 + edgesize,y2))

        -- Top right.
        surface.DrawLine(x2,y1,math.max(x2 - edgesize,x1),y1)
        surface.DrawLine(x2,y1,x2,math.min(y1 + edgesize,y2))

        -- Bottom left.
        surface.DrawLine(x1,y2,math.min(x1 + edgesize,x2),y2)
        surface.DrawLine(x1,y2,x1,math.max(y2 - edgesize,y1))

        -- Bottom right.
        surface.DrawLine(x2,y2,math.max(x2 - edgesize,x1),y2)
        surface.DrawLine(x2,y2,x2,math.max(y2 - edgesize,y1))
    end
end