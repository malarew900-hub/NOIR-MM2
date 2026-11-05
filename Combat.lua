-- Combat.lua
local Combat = {}
local Config, HoldingAim = nil, false
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

function Combat.Init(cfg)
    Config = cfg
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then HoldingAim = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then HoldingAim = false end
    end)
end

-- Проверка, кто перед нами (чтобы не аимить в невиновных)
local function isTargetValid(plr)
    if plr == LocalPlayer then return false end
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (char and hum and hum.Health > 0) then return false end
    
    -- Если мы Инноцент, бьем только Убийцу
    -- Если мы Шериф, бьем только Убийцу
    -- Если мы Убийца, бьем всех
    local myRole = "Innocent" -- Заглушка, тут можно проверять свою роль
    local targetRole = "Innocent"
    
    -- Ищем роль цели
    local hasKnife, hasGun = false, false
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local n = string.lower(tool.Name)
            if n:find("knife") then hasKnife = true end
            if n:find("gun") or n:find("revolver") then hasGun = true end
        end
    end
    if hasKnife then targetRole = "Murderer" end
    if hasGun then targetRole = "Sheriff" end
    
    if Config.Combat.TargetRole == "Murderer" and targetRole ~= "Murderer" then return false end
    return true
end

local function getClosest()
    local best, bestDist = nil, Config.Combat.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    for _, plr in ipairs(Players:GetPlayers()) do
        if isTargetValid(plr) then
            local char = plr.Character
            local part = char:FindFirstChild(Config.Combat.AimPart) or char:FindFirstChild("Head")
            if part then
                local screen, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local d = (Vector2.new(screen.X, screen.Y) - mousePos).Magnitude
                    if d < bestDist then
                        bestDist = d
                        best = part
                    end
                end
            end
        end
    end
    return best
end

-- Функция для Aura (удар ножом)
local function knifeAura()
    if not Config.Combat.KnifeAura then return end
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    
    local tool = myChar:FindFirstChildOfClass("Tool")
    local isKnife = tool and string.lower(tool.Name):find("knife")
    
    if isKnife then
        for _, plr in ipairs(Players:GetPlayers()) do
            if isTargetValid(plr) then
                local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - myHRP.Position).Magnitude < 12 then
                    -- Имитация удара
                    if tool then
                        tool:Activate()
                    end
                    if mouse1click then mouse1click() end
                    break
                end
            end
        end
    end
end

function Combat.Update()
    if not Config.Combat.Aimbot and not Config.Combat.SilentAim and not Config.Combat.KnifeAura then return end
    
    knifeAura()

    local target = getClosest()
    if target and (HoldingAim or Config.Combat.SilentAim) then
        local screen = Camera:WorldToViewportPoint(target.Position)
        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
        local delta = (Vector2.new(screen.X, screen.Y) - mousePos) * (1 - Config.Combat.Smoothness)
        
        if mousemoverel then
            mousemoverel(delta.X, delta.Y)
        elseif Input and Input.MouseMove then
            Input.MouseMove(delta.X, delta.Y)
        end
    end
end
return Combat