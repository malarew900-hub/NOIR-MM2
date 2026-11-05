-- UI.lua
local UI = {}
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

function UI.Init(cfg, esp, combat, farm, movement)
    local Window = Fluent:CreateWindow({
        Title = "NOIR MM2",
        SubTitle = "Optimized Build",
        TabWidth = 140,
        Size = UDim2.fromOffset(500, 400),
        Acrylic = true,
        Theme = "Darker",
        MinimizeKey = Enum.KeyCode.LeftControl
    })

    local Tabs = {
        Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
        Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
        Player = Window:AddTab({ Title = "Player", Icon = "user" }),
        Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    }

    -- Combat
    Tabs.Combat:AddToggle("AimEnable", { Title = "Aimbot", Default = cfg.Combat.Aimbot, Callback = function(v) cfg.Combat.Aimbot = v end })
    Tabs.Combat:AddToggle("SilentEnable", { Title = "Silent Aim", Default = cfg.Combat.SilentAim, Callback = function(v) cfg.Combat.SilentAim = v end })
    Tabs.Combat:AddSlider("FOV", { Title = "FOV", Default = cfg.Combat.FOV, Min = 40, Max = 400, Rounding = 0, Callback = function(v) cfg.Combat.FOV = v end })
    Tabs.Combat:AddToggle("AuraEnable", { Title = "Knife Aura", Default = false, Callback = function(v) cfg.Combat.KnifeAura = v end })
    
    -- Visuals
    Tabs.Visuals:AddToggle("ESPEnable", { Title = "Enable ESP", Default = cfg.ESP.Enabled, Callback = function(v) cfg.ESP.Enabled = v end })
    Tabs.Visuals:AddToggle("BoxESP", { Title = "Box", Default = cfg.ESP.Box, Callback = function(v) cfg.ESP.Box = v end })
    Tabs.Visuals:AddToggle("NameESP", { Title = "Name", Default = cfg.ESP.Name, Callback = function(v) cfg.ESP.Name = v end })
    Tabs.Visuals:AddToggle("DistESP", { Title = "Distance", Default = cfg.ESP.Distance, Callback = function(v) cfg.ESP.Distance = v end })

    -- Player
    Tabs.Player:AddToggle("FlyEnable", { Title = "Fly", Default = cfg.Movement.Fly, Callback = function(v) cfg.Movement.Fly = v end })
    Tabs.Player:AddToggle("NoclipEnable", { Title = "Noclip", Default = cfg.Movement.Noclip, Callback = function(v) cfg.Movement.Noclip = v end })
    Tabs.Player:AddToggle("SpeedEnable", { Title = "Speed", Default = cfg.Movement.Speed, Callback = function(v) cfg.Movement.Speed = v end })
    Tabs.Player:AddSlider("WalkSpeed", { Title = "Walk Speed", Default = cfg.Movement.WalkSpeed, Min = 16, Max = 100, Rounding = 0, Callback = function(v) cfg.Movement.WalkSpeed = v end })

    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    InterfaceManager:SetFolder("NOIR_MM2")
    SaveManager:SetFolder("NOIR_MM2")
    InterfaceManager:BuildInterfaceSection(Tabs.Misc)
    SaveManager:BuildConfigSection(Tabs.Misc)
    Window:SelectTab(1)
    Fluent:Notify({ Title = "NOIR MM2", Content = "Loaded successfully", Duration = 3 })
end
return UI