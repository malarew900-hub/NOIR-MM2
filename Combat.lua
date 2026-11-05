-- Combat.lua
local Combat = {}
local Config, HoldingAim = nil, false
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
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
    if not Config or not Config.Combat then return nil end
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

local function tpKill()
    if not Config or not Config.Combat or not Config.Combat.KnifeAura then return end
    if tick() - lastTp < 0.15 then return end
    
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    
    local tool = myChar:FindFirstChildOfClass("Tool")
    local isKnife = tool and string.lower(tool.Name):find("knife")
    
    if isKnife then
        local auraDist = Config.Combat.AuraDist or 20
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - myHRP.Position).Magnitude < auraDist then
                    local oldCFrame = myHRP.CFrame
                    
                    -- Телепорт
                    myHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, 1.5)
                    task.wait(0.02) 
                    
                    -- Удар
                    if tool then pcall(function() tool:Activate() end) end
                    if mouse1click then pcall(mouse1click) end
                    
                    -- Возврат
                    task.wait(0.02)
                    myHRP.CFrame = oldCFrame
                    
                    lastTp = tick()
                    break
                end
            end
        end
    end
end

function Combat.Update()
    if not Config or not Config.Combat then return end
    tpKill()

    if Config.Combat.Aimbot then
        local target = getClosest()
        if target and HoldingAim then
            local screen = Camera:WorldToViewportPoint(target.Position)
            local mousePos = Vector2.new(Mouse.X, Mouse.Y)
            local delta = (Vector2.new(screen.X, screen.Y) - mousePos) * (1 - Config.Combat.Smoothness)
            
            if mousemoverel then
                pcall(mousemoverel, delta.X, delta.Y)
            elseif Input and Input.MouseMove then
                pcall(Input.MouseMove, delta.X, delta.Y)
            end
        end
    end
end
return Combat