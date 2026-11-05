-- Config.lua
local Config = {
    ESP = {
        Enabled = true, Box = true, Name = true, Distance = true,
        Chams = false, RoleESP = true, MaxDist = 2500,
        Colors = { 
            Murderer = Color3.fromRGB(255,55,55), 
            Sheriff = Color3.fromRGB(55,140,255), 
            Innocent = Color3.fromRGB(80,220,120),
            ChamsFill = Color3.fromRGB(255, 255, 255),
            ChamsOutline = Color3.fromRGB(0, 0, 0)
        }
    },
    Combat = { 
        Aimbot = false, SilentAim = false, FOV = 130, Smoothness = 0.14, 
        AimPart = "Head", TargetRole = "Murderer", KnifeAura = false, AuraDist = 20 
    },
    Farm = { Enabled = false, AutoGrabGun = true },
    Movement = { Fly = false, FlySpeed = 70, Noclip = false, Speed = false, WalkSpeed = 26 }
}
return Config