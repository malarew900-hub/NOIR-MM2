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

local function getClosest()
    local best, bestDist = nil, Config.Combat.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            local head = char and char:FindFirstChild("Head")
            if head then
                local screen, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local d = (Vector2.new(screen.X, screen.Y) - mousePos).Magnitude
                    if d < bestDist then
                        bestDist = d
                        best = head
                    end
                end
            end
        end
    end
    return best
end

function Combat.Update()
    if not Config.Combat.Aimbot and not Config.Combat.SilentAim then return end
    
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