-- ESP.lua
local ESP = {}
local Config, Cache = nil, {}
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

function ESP.Init(cfg) Config = cfg end

function ESP.Update()
    if not Config.ESP.Enabled then
        for _, v in pairs(Cache) do 
            for _, obj in pairs(v) do if obj.Remove then obj:Remove() end end
        end
        Cache = {}; return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == Players.LocalPlayer then continue end
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        
        if hrp and head then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local dist = (hrp.Position - Camera.CFrame.Position).Magnitude
            
            if onScreen then
                if not Cache[plr] then
                    Cache[plr] = {
                        Box = Drawing.new("Square"),
                        Name = Drawing.new("Text"),
                        Dist = Drawing.new("Text")
                    }
                    Cache[plr].Box.Thickness = 1
                    Cache[plr].Box.Filled = false
                    Cache[plr].Box.Color = Config.ESP.Colors.Innocent
                    Cache[plr].Name.Size = 14
                    Cache[plr].Name.Center = true
                    Cache[plr].Name.Outline = true
                    Cache[plr].Dist.Size = 12
                    Cache[plr].Dist.Center = true
                    Cache[plr].Dist.Outline = true
                end
                
                local c = Cache[plr]
                local height = math.abs(headPos.Y - pos.Y) * 1.5
                local width = height * 0.6
                
                if Config.ESP.Box then
                    c.Box.Visible = true
                    c.Box.Size = Vector2.new(width, height)
                    c.Box.Position = Vector2.new(pos.X - width/2, headPos.Y)
                else c.Box.Visible = false end
                
                if Config.ESP.Name then
                    c.Name.Visible = true
                    c.Name.Text = plr.Name
                    c.Name.Position = Vector2.new(pos.X, headPos.Y - 15)
                else c.Name.Visible = false end
                
                if Config.ESP.Distance then
                    c.Dist.Visible = true
                    c.Dist.Text = string.format("%.0fm", dist)
                    c.Dist.Position = Vector2.new(pos.X, pos.Y + height/2 + 5)
                else c.Dist.Visible = false end
            else
                if Cache[plr] then
                    Cache[plr].Box.Visible = false
                    Cache[plr].Name.Visible = false
                    Cache[plr].Dist.Visible = false
                end
            end
        end
    end
end
return ESP