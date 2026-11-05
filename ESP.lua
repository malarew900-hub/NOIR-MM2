-- ESP.lua
local ESP = {}
local Config, Cache = nil, {}
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

function ESP.Init(cfg) Config = cfg end

function ESP.Update()
    if not Config.ESP.Enabled then
        for _, v in pairs(Cache) do if v.Remove then v:Remove() end end
        Cache = {}; return
    end

    -- Только игроки, никаких GetDescendants
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == Players.LocalPlayer then continue end
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                -- Логика отрисовки (пока просто заглушка, чтобы проверить стабильность)
                if not Cache[plr] then
                    Cache[plr] = Drawing.new("Text")
                    Cache[plr].Size = 14
                    Cache[plr].Color = Config.ESP.Colors.Innocent
                    Cache[plr].Center = true
                end
                Cache[plr].Text = plr.Name
                Cache[plr].Position = Vector2.new(pos.X, pos.Y)
                Cache[plr].Visible = true
            else
                if Cache[plr] then Cache[plr].Visible = false end
            end
        elseif Cache[plr] then
            Cache[plr].Visible = false
        end
    end
end
return ESP