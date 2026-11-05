-- ESP.lua
local ESP = {}
local Config, Cache, ChamCache = nil, {}, {}
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

function ESP.Init(cfg) Config = cfg end

-- Определяем роль (ищем нож/пушку в бэкпаке и руках)
local function getRole(plr)
    local char = plr.Character
    if not char then return "Innocent" end
    local hasKnife, hasGun = false, false
    
    -- Проверка в руках
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local n = string.lower(tool.Name)
            if n:find("knife") then hasKnife = true end
            if n:find("gun") or n:find("revolver") then hasGun = true end
        end
    end
    -- Проверка в бэкпаке
    local bp = plr:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local n = string.lower(tool.Name)
                if n:find("knife") then hasKnife = true end
                if n:find("gun") or n:find("revolver") then hasGun = true end
            end
        end
    end

    if hasKnife then return "Murderer" end
    if hasGun then return "Sheriff" end
    return "Innocent"
end

function ESP.Update()
    if not Config.ESP.Enabled then
        for _, v in pairs(Cache) do 
            for _, obj in pairs(v) do if obj.Remove then obj:Remove() end end
        end
        Cache = {}
        for _, h in pairs(ChamCache) do if h then h:Destroy() end end
        ChamCache = {}
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        
        if hrp and head then
            local role = getRole(plr)
            local roleColor = Config.ESP.Colors[role] or Config.ESP.Colors.Innocent
            
            -- Логика Chams (Highlight)
            if Config.ESP.Chams then
                if not ChamCache[plr] then
                    local h = Instance.new("Highlight")
                    h.Parent = char
                    h.Adornee = char
                    h.FillColor = Config.ESP.Colors.ChamsFill
                    h.OutlineColor = roleColor -- Обводка цветом роли
                    h.FillTransparency = 0.5
                    ChamCache[plr] = h
                else
                    ChamCache[plr].OutlineColor = roleColor
                end
            elseif ChamCache[plr] then
                ChamCache[plr]:Destroy()
                ChamCache[plr] = nil
            end

            -- Логика ESP (2D)
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local dist = (hrp.Position - Camera.CFrame.Position).Magnitude
            
            if onScreen and dist <= Config.ESP.MaxDist then
                if not Cache[plr] then
                    Cache[plr] = {
                        Box = Drawing.new("Square"),
                        Name = Drawing.new("Text"),
                        Dist = Drawing.new("Text"),
                        Role = Drawing.new("Text")
                    }
                    for _, obj in pairs(Cache[plr]) do
                        if obj.ClassName == "Square" then
                            obj.Thickness = 1
                            obj.Filled = false
                        else
                            obj.Size = 14
                            obj.Center = true
                            obj.Outline = true
                        end
                    end
                end
                
                local c = Cache[plr]
                local height = math.abs(headPos.Y - pos.Y) * 1.5
                local width = height * 0.6
                
                -- Цвета
                c.Box.Color = roleColor
                c.Name.Color = roleColor
                c.Dist.Color = Color3.new(1,1,1)
                c.Role.Color = roleColor

                if Config.ESP.Box then
                    c.Box.Visible = true
                    c.Box.Size = Vector2.new(width, height)
                    c.Box.Position = Vector2.new(pos.X - width/2, headPos.Y)
                else c.Box.Visible = false end
                
                if Config.ESP.Name then
                    c.Name.Visible = true
                    c.Name.Text = plr.Name
                    c.Name.Position = Vector2.new(pos.X, headPos.Y - 25)
                else c.Name.Visible = false end

                if Config.ESP.RoleESP then
                    c.Role.Visible = true
                    c.Role.Text = "[" .. role .. "]"
                    c.Role.Position = Vector2.new(pos.X, headPos.Y - 12)
                else c.Role.Visible = false end
                
                if Config.ESP.Distance then
                    c.Dist.Visible = true
                    c.Dist.Text = string.format("%.0fm", dist)
                    c.Dist.Position = Vector2.new(pos.X, pos.Y + height/2 + 5)
                else c.Dist.Visible = false end
            else
                if Cache[plr] then
                    for _, obj in pairs(Cache[plr]) do obj.Visible = false end
                end
            end
        elseif Cache[plr] then
            for _, obj in pairs(Cache[plr]) do obj.Visible = false end
        end
    end
    
    -- Очистка чамсов у мертвых/вышедших
    for plr, h in pairs(ChamCache) do
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
            h:Destroy()
            ChamCache[plr] = nil
        end
    end
end
return ESP