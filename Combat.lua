-- Combat.lua
local Combat = {}
local Config, HoldingAim = nil, false
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")

local lastTp = 0

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

local function getClosest()
    local best, bestDist = nil, Config.Combat.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            local part = char and char:FindFirstChild("Head")
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

-- Функция Телепорт-Ауры
local function tpKill()
    if not Config.Combat.KnifeAura then return end
    if tick() - lastTp < 0.1 then return end -- Задержка, чтобы не спамить
    
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    
    local tool = myChar:FindFirstChildOfClass("Tool")
    local isKnife = tool and string.lower(tool.Name):find("knife")
    
    if isKnife then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                -- Проверяем дистанцию (по умолчанию 20, если в конфиге нет)
                local auraDist = Config.Combat.AuraDist or 20
                
                if hrp and (hrp.Position - myHRP.Position).Magnitude < auraDist then
                    local oldCFrame = myHRP.CFrame
                    
                    -- Телепорт к цели
                    myHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, 1.5) -- встаем вплотную
                    task.wait(0.01) -- микро-задержка для синхронизации
                    
                    -- Бьем
                    if tool then
                        tool:Activate()
                    end
                    if mouse1click then mouse1click() end
                    
                    -- Возвращаемся назад (опционально, чтобы не палиться)
                    task.wait(0.01)
                    myHRP.CFrame = oldCFrame
                    
                    lastTp = tick()
                    break
                end
            end
        end
    end
end

function Combat.Update()
    if not Config.Combat.Aimbot and not Config.Combat.KnifeAura then return end
    tpKill()

    if Config.Combat.Aimbot then
        local target = getClosest()
        if target and HoldingAim then
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
end
return Combat