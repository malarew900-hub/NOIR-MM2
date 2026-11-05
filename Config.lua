-- Config.lua
local Config = {
    ESP = {
        Enabled = true, Box = true, Name = true, Distance = true,
        MaxDist = 2500,
        Colors = { Murderer = Color3.fromRGB(255,55,55), Sheriff = Color3.fromRGB(55,140,255), Innocent = Color3.fromRGB(80,220,120) }
    },
    Combat = { Aimbot = false, SilentAim = false, FOV = 130, Smoothness = 0.14, AimPart = "Head", TargetRole = "Murderer" },
    Farm = { Enabled = false, AutoGrabGun = true },
    Movement = { Fly = false, FlySpeed = 70, Noclip = false, Speed = false, WalkSpeed = 26 }
}
return Config