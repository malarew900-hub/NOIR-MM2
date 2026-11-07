-- ============================================================================
-- NOIR / MM2 INTERNAL SCRIPT (DRAGGABLE WATERMARK & ADVANCED CHAMS)1part
-- ============================================================================

-- Services.
local playersService = game:GetService("Players")
local runService = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")
local userInputService = game:GetService("UserInputService")

-- State.
local localPlayer = playersService.LocalPlayer
local camera = workspace.CurrentCamera

-- Configuration State
getgenv().NoirConfig = {
    Watermark = {
        Text = "NOIR",
        Transparency = 0.15, -- Настраиваемая прозрачность фона
        ShowName = true,
        ShowFPS = true,
        ShowPing = true,
        ShowInternal = true,
    },
    Chams = {
        Enabled = true,
        Mode = "Glow", -- "Solid", "Glow", "Water", "Neon", "Inversy"
        FillTransparency = 0.3,
        OutlineTransparency = 0.1,
        Rainbow = false,
        InnocentColor = Color3.fromRGB(0, 255, 100),
        SheriffColor = Color3.fromRGB(0, 150, 255),
        MurdererColor = Color3.fromRGB(255, 50, 50),
    }
}

-- ============================================================================
-- PART 1: ROLE DETECTION (Inventory Scan)
-- ============================================================================

local function getPlayerRole(player)
    if player == localPlayer then return "Innocent" end
    local character = player.Character
    if not character then return "Innocent" end
    
    local backpack = player:FindFirstChildOfClass("Backpack")
    
    if character:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then
        return "Murderer"
    elseif character:FindFirstChild("Gun") or character:FindFirstChild("Revolver") or (backpack and (backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver"))) then
        return "Sheriff"
    end
    
    return "Innocent"
end

local function getRoleColor(role)
    if getgenv().NoirConfig.Chams.Rainbow then
        local hue = (tick() * 0.2) % 1
        return Color3.fromHSV(hue, 1, 1)
    end
    
    if role == "Murderer" then
        return getgenv().NoirConfig.Chams.MurdererColor
    elseif role == "Sheriff" then
        return getgenv().NoirConfig.Chams.SheriffColor
    else
        return getgenv().NoirConfig.Chams.InnocentColor
    end
end

-- ============================================================================
-- PART 2: RIGHT-TOP DRAGGABLE WATERMARK (NOIR)
-- ============================================================================

local WatermarkGui = Instance.new("ScreenGui")
WatermarkGui.Name = "NoirWatermarkGui"
WatermarkGui.Parent = coreGui
WatermarkGui.ResetOnSpawn = false

local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Name = "WatermarkFrame"
WatermarkFrame.Parent = WatermarkGui
WatermarkFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
WatermarkFrame.BackgroundTransparency = getgenv().NoirConfig.Watermark.Transparency
WatermarkFrame.BorderColor3 = Color3.fromRGB(45, 45, 45)
-- По умолчанию ставим в правый верхний угол (под чат/панель Roblox)
WatermarkFrame.Position = UDim2.new(1, -260, 0, 15)
WatermarkFrame.Size = UDim2.new(0, 0, 0, 26)
WatermarkFrame.AutomaticSize = Enum.AutomaticSize.X

local WatermarkCorner = Instance.new("UICorner")
WatermarkCorner.CornerRadius = UDim.new(0, 4)
WatermarkCorner.Parent = WatermarkFrame

local WatermarkText = Instance.new("TextLabel")
WatermarkText.Name = "WatermarkText"
WatermarkText.Parent = WatermarkFrame
WatermarkText.BackgroundTransparency = 1
WatermarkText.Position = UDim2.new(0, 8, 0, 0)
WatermarkText.Size = UDim2.new(0, 0, 1, 0)
WatermarkText.AutomaticSize = Enum.AutomaticSize.X
WatermarkText.Font = Enum.Font.Code
WatermarkText.TextColor3 = Color3.fromRGB(240, 240, 240)
WatermarkText.TextSize = 12
WatermarkText.TextXAlignment = Enum.TextXAlignment.Left

-- Логика перетаскивания мышкой (Draggable)
local dragging, dragInput, dragStart, startPos

WatermarkFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = WatermarkFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

WatermarkFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

userInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        WatermarkFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Обновление текста ватермарка, FPS, пинга (выключить нельзя)
local fps, lastTick = 0, tick()
runService.RenderStepped:Connect(function()
    local cfg = getgenv().NoirConfig.Watermark
    WatermarkFrame.BackgroundTransparency = cfg.Transparency
    
    local currentTick = tick()
    fps = math.floor(1 / math.max(currentTick - lastTick, 0.001))
    lastTick = currentTick
    
    local ping = 0
    pcall(function()
        ping = math.floor(localPlayer:GetNetworkPing() * 1000)
    end)
    
    local parts = {cfg.Text}
    if cfg.ShowName then table.insert(parts, localPlayer.Name) end
    if cfg.ShowFPS then table.insert(parts, fps .. "fps") end
    if cfg.ShowPing then table.insert(parts, ping .. "ms") end
    if cfg.ShowInternal then table.insert(parts, "🖥️ internal") end
    
    WatermarkText.Text = table.concat(parts, " | ")
end)

-- ============================================================================
-- ADVANCED CHAMS MODULE (Оптимизированная версия - 12 режимов)
-- ============================================================================

local chamsCache = {}

local function wave(phase, speed)
	return (math.sin(tick() * speed + phase) + 1) * 0.5
end

local MODES = {}

MODES.Solid = function(hl, phase, color)
	hl.FillColor = color
	hl.FillTransparency = 0
	hl.OutlineColor = Color3.new(0, 0, 0)
	hl.OutlineTransparency = 1
end

MODES.Glow = function(hl, phase, color)
	hl.FillColor = color
	hl.FillTransparency = 0.35
	hl.OutlineColor = Color3.new(1, 1, 1)
	hl.OutlineTransparency = 0.05 + wave(phase, 4) * 0.15
end

-- Текучая вода (горизонтальная волна цвета и прозрачности)
MODES.Water = function(hl, phase, color)
	local flow = wave(phase, 3)
	local cross = wave(phase * 0.5, 1.5)
	hl.FillColor = Color3.fromRGB(0, 90, 170):Lerp(Color3.fromRGB(120, 220, 255), flow)
	hl.FillTransparency = 0.15 + cross * 0.35
	hl.OutlineColor = Color3.fromRGB(120, 220, 255)
	hl.OutlineTransparency = 0.1 + (1 - flow) * 0.3
end

MODES.Neon = function(hl, phase, color)
	hl.FillColor = color
	hl.FillTransparency = 0.1
	hl.OutlineColor = color
	hl.OutlineTransparency = 0
end

MODES.Inversy = function(hl, phase, color)
	local pulse = wave(phase, 3)
	hl.FillColor = Color3.new(1, 1, 1):Lerp(color, pulse)
	hl.FillTransparency = pulse * 0.8
	hl.OutlineColor = Color3.new(1, 1, 1)
	hl.OutlineTransparency = pulse
end

MODES.Rainbow = function(hl, phase, color)
	local t = tick() * 0.5 + phase
	hl.FillColor = Color3.fromHSV(t % 1, 1, 1)
	hl.FillTransparency = 0.25
	hl.OutlineColor = Color3.fromHSV((t + 0.5) % 1, 1, 1)
	hl.OutlineTransparency = 0
end

MODES.Lava = function(hl, phase, color)
	local flicker = wave(phase, 8)
	local flow = wave(phase, 2)
	hl.FillColor = Color3.fromRGB(120, 10, 0):Lerp(Color3.fromRGB(255, 180, 0), flow * 0.8 + flicker * 0.2)
	hl.FillTransparency = 0.05 + flicker * 0.2
	hl.OutlineColor = Color3.fromRGB(255, 180, 0)
	hl.OutlineTransparency = 0.1 + (1 - flow) * 0.3
end

MODES.Ice = function(hl, phase, color)
	local shimmer = wave(phase, 4)
	hl.FillColor = Color3.fromRGB(130, 200, 255):Lerp(Color3.fromRGB(230, 250, 255), shimmer)
	hl.FillTransparency = 0.15 + shimmer * 0.3
	hl.OutlineColor = Color3.fromRGB(230, 250, 255)
	hl.OutlineTransparency = 0
end

MODES.Toxic = function(hl, phase, color)
	local pulse = wave(phase, 2.5)
	hl.FillColor = Color3.fromRGB(20, 80, 20):Lerp(Color3.fromRGB(120, 255, 80), pulse)
	hl.FillTransparency = 0.15 + (1 - pulse) * 0.3
	hl.OutlineColor = Color3.fromRGB(120, 255, 80)
	hl.OutlineTransparency = pulse * 0.3
end

MODES.Pulse = function(hl, phase, color)
	local pulse = wave(phase, 3)
	hl.FillColor = color
	hl.FillTransparency = 0.2 + pulse * 0.5
	hl.OutlineColor = color
	hl.OutlineTransparency = 0.1 + pulse * 0.4
end

MODES.Ghost = function(hl, phase, color)
	local pulse = wave(phase, 1.5)
	hl.FillColor = Color3.fromRGB(220, 220, 255)
	hl.FillTransparency = 0.75 + pulse * 0.2
	hl.OutlineColor = Color3.fromRGB(200, 220, 255)
	hl.OutlineTransparency = 0.3 + pulse * 0.5
end

MODES.Holographic = function(hl, phase, color)
	local t = tick() * 0.3 + phase
	local shimmer = wave(phase * 2, 5)
	hl.FillColor = Color3.fromHSV(t % 1, 0.8, 0.8 + shimmer * 0.2)
	hl.FillTransparency = 0.4 + shimmer * 0.3
	hl.OutlineColor = Color3.fromHSV((t + 0.33) % 1, 1, 1)
	hl.OutlineTransparency = 0.1 + (1 - shimmer) * 0.3
end

local function removeChams(player)
	if chamsCache[player] then
		if chamsCache[player].Highlight then
			chamsCache[player].Highlight:Destroy()
		end
		chamsCache[player] = nil
	end
end

local function setupChams(player)
	if player == localPlayer then return end
	local highlight = Instance.new("Highlight")
	highlight.Name = "NoirAdvancedChams"
	highlight.Parent = coreGui
	highlight.Adornee = nil
	highlight.Enabled = false
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	chamsCache[player] = { Highlight = highlight }
end

playersService.PlayerRemoving:Connect(removeChams)
for _, p in ipairs(playersService:GetPlayers()) do setupChams(p) end
playersService.PlayerAdded:Connect(setupChams)

runService.RenderStepped:Connect(function()
	local cfg = getgenv().NoirConfig.Chams
	local render = MODES[cfg.Mode] or MODES.Solid

	for player, data in pairs(chamsCache) do
		local hl = data.Highlight
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if cfg.Enabled and character and humanoid and humanoid.Health > 0 then
			hl.Enabled = true
			hl.Adornee = character
			local roleColor = getRoleColor(getPlayerRole(player))
			local phase = (player.UserId % 100) * 0.1
			render(hl, phase, roleColor)
		else
			hl.Enabled = false
		end
	end
end)
-- ============================================================================
-- PART 4: FLUENT UI MENU INTEGRATION
-- ============================================================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "NOIR / MM2 Internal",
    SubTitle = "Murder Mystery 2",
    TabWidth = 160,
    Size = UDim2.fromOffset(550, 420),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.N
})

local Tabs = {
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Visuals Tab -> Chams Section
local ChamsSection = Tabs.Visuals:AddSection("Advanced Chams Shading")

ChamsSection:AddToggle("ChamsToggle", {
    Title = "Enable Chams",
    Default = getgenv().NoirConfig.Chams.Enabled,
    Callback = function(v)
        getgenv().NoirConfig.Chams.Enabled = v
    end
})

ChamsSection:AddDropdown("ChamsMode", {
    Title = "Chams Effect Mode",
    Values = {"Solid", "Glow", "Water", "Neon", "Inversy"},
    Default = 2,
    Callback = function(v)
        getgenv().NoirConfig.Chams.Mode = v
    end
})

ChamsSection:AddToggle("ChamsRainbow", {
    Title = "Rainbow Roles",
    Default = getgenv().NoirConfig.Chams.Rainbow,
    Callback = function(v)
        getgenv().NoirConfig.Chams.Rainbow = v
    end
})

ChamsSection:AddColorpicker("InnocentColor", {
    Title = "Innocent Color",
    Default = getgenv().NoirConfig.Chams.InnocentColor,
    Callback = function(v)
        getgenv().NoirConfig.Chams.InnocentColor = v
    end
})

ChamsSection:AddColorpicker("SheriffColor", {
    Title = "Sheriff Color",
    Default = getgenv().NoirConfig.Chams.SheriffColor,
    Callback = function(v)
        getgenv().NoirConfig.Chams.SheriffColor = v
    end
})

ChamsSection:AddColorpicker("MurdererColor", {
    Title = "Murderer Color",
    Default = getgenv().NoirConfig.Chams.MurdererColor,
    Callback = function(v)
        getgenv().NoirConfig.Chams.MurdererColor = v
    end
})

-- Settings Tab -> Watermark Configuration
local WMSection = Tabs.Settings:AddSection("Watermark Settings (NOIR)")

WMSection:AddSlider("WMTransparency", {
    Title = "Watermark Transparency",
    Description = "Change background opacity",
    Default = 0.15,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(v)
        getgenv().NoirConfig.Watermark.Transparency = v
    end
})

WMSection:AddToggle("WMName", {
    Title = "Show Player Name",
    Default = getgenv().NoirConfig.Watermark.ShowName,
    Callback = function(v)
        getgenv().NoirConfig.Watermark.ShowName = v
    end
})

WMSection:AddToggle("WMFPS", {
    Title = "Show FPS",
    Default = getgenv().NoirConfig.Watermark.ShowFPS,
    Callback = function(v)
        getgenv().NoirConfig.Watermark.ShowFPS = v
    end
})

WMSection:AddToggle("WMPing", {
    Title = "Show Ping",
    Default = getgenv().NoirConfig.Watermark.ShowPing,
    Callback = function(v)
        getgenv().NoirConfig.Watermark.ShowPing = v
    end
})

Fluent:Notify({
    Title = "NOIR Loaded",
    Content = "Right-top draggable watermark & advanced chams ready!",
    Duration = 4
})
-- ============================================================================
-- NOIR / MM2 INTERNAL SCRIPT - PART 2 (WATERMARK CLICK, NIGHTMODE, LIGHTING, SKY)
-- ============================================================================

-- Services.
local lightingService = game:GetService("Lighting")
local tweenService = game:GetService("TweenService")

-- Расширяем глобальный конфиг новыми секциями
getgenv().NoirConfig.World = {
    NightMode = false,
    DarknessLevel = 0.15, -- От 0 (абсолютная тьма) до 1 (обычный свет)
    
    Lighting = {
        Enabled = true,
        Brightness = 1.2,
        Ambient = Color3.fromRGB(100, 100, 100),
        OutdoorAmbient = Color3.fromRGB(120, 120, 120),
        ClockTime = 14.5, -- Время суток
        FogEnabled = false,
        FogColor = Color3.fromRGB(150, 150, 150),
        FogStart = 0,
        FogEnd = 1000,
    },
    
    Skybox = {
        Mode = "Default", -- "Default", "Color", "Asset ID"
        SkyColor = Color3.fromRGB(20, 20, 35),
        AssetId = "",
    }
}

getgenv().NoirConfig.Themes = {
    CurrentTheme = "Dark",
    CustomAccent = Color3.fromRGB(188, 78, 255),
    CustomBackground = Color3.fromRGB(15, 15, 15),
}



-- ============================================================================
-- NOIR / MM2 INTERNAL SCRIPT - PART 2 (FULL LIGHTING & ADVANCED FOG MODES)
-- ============================================================================

local lightingService = game:GetService("Lighting")
local runService = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")
local userInputService = game:GetService("UserInputService")

getgenv().NoirConfig = getgenv().NoirConfig or {}
getgenv().NoirConfig.World = {
	NightMode = false,
	DarknessIntensity = 0.15,
	
	Lighting = {
		Enabled = true,
		ClockTime = 14.5,
		Brightness = 2,
		ExposureCompensation = 0,
		ShadowSoftness = 0.2,
		GeographicLatitude = 41.733,
		EnvironmentDiffuseScale = 1,
		EnvironmentSpecularScale = 1,
		Ambient = Color3.fromRGB(120, 120, 120),
		OutdoorAmbient = Color3.fromRGB(150, 150, 150),
		ColorShift_Top = Color3.fromRGB(0, 0, 0),
		ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
		
		-- Расширенные настройки тумана
		FogMode = "Disabled", -- "Disabled", "Standard", "Rainbow", "Pulse", "Blood"
		FogStart = 0,
		FogEnd = 1000,
		FogColor = Color3.fromRGB(130, 130, 130),
	},
}

getgenv().NoirConfig.Themes = {
	SelectedTheme = "Dark",
}

-- Гарантируем наличие Atmosphere
local atmosphere = lightingService:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere", lightingService)
-- ============================================================================
-- 2. ОСВЕЩЕНИЕ, НОЧНОЙ РЕЖИМ И РЕЖИМЫ ТУМАНА (RENDER LOOP)
-- ============================================================================
runService.RenderStepped:Connect(function()
	local cfg = getgenv().NoirConfig.World
	
	if cfg.NightMode then
		local intensity = math.clamp(cfg.DarknessIntensity, 0.01, 1)
		
		lightingService.ClockTime = 0
		lightingService.Brightness = intensity * 1.5
		lightingService.ExposureCompensation = -2.5 + (intensity * 2)
		lightingService.ShadowSoftness = 0.5
		
		local colorVal = math.floor(intensity * 100)
		lightingService.Ambient = Color3.fromRGB(math.floor(colorVal * 0.2), math.floor(colorVal * 0.2), colorVal)
		lightingService.OutdoorAmbient = Color3.fromRGB(math.floor(colorVal * 0.3), math.floor(colorVal * 0.3), math.floor(colorVal * 1.2))
		
		lightingService.FogStart = 0
		lightingService.FogEnd = 200 + (intensity * 1500)
		lightingService.FogColor = Color3.fromRGB(10, 10, 30)
		
		atmosphere.Parent = lightingService
		atmosphere.Density = 0.55 - (intensity * 0.3)
		atmosphere.Color = Color3.fromRGB(10, 10, 30)
	elseif cfg.Lighting.Enabled then
		local l = cfg.Lighting
		lightingService.ClockTime = l.ClockTime
		lightingService.Brightness = l.Brightness
		lightingService.ExposureCompensation = l.ExposureCompensation
		lightingService.ShadowSoftness = l.ShadowSoftness
		lightingService.GeographicLatitude = l.GeographicLatitude
		lightingService.EnvironmentDiffuseScale = l.EnvironmentDiffuseScale
		lightingService.EnvironmentSpecularScale = l.EnvironmentSpecularScale
		lightingService.Ambient = l.Ambient
		lightingService.OutdoorAmbient = l.OutdoorAmbient
		lightingService.ColorShift_Top = l.ColorShift_Top
		lightingService.ColorShift_Bottom = l.ColorShift_Bottom
		
		-- Логика режимов тумана
		if l.FogMode == "Disabled" then
			lightingService.FogEnd = 1000000
			atmosphere.Parent = nil
		else
			lightingService.FogStart = l.FogStart
			lightingService.FogEnd = l.FogEnd
			atmosphere.Parent = lightingService
			
			if l.FogMode == "Standard" then
				lightingService.FogColor = l.FogColor
				atmosphere.Color = l.FogColor
				atmosphere.Density = 0.25
			elseif l.FogMode == "Rainbow" then
				local rbColor = Color3.fromHSV((tick() * 0.2) % 1, 1, 1)
				lightingService.FogColor = rbColor
				atmosphere.Color = rbColor
				atmosphere.Density = 0.3
			elseif l.FogMode == "Pulse" then
				local pulseFactor = (math.sin(tick() * 3) + 1) / 2
				local pColor = l.FogColor:Lerp(Color3.new(1, 1, 1), pulseFactor)
				lightingService.FogColor = pColor
				atmosphere.Color = pColor
				atmosphere.Density = 0.2 + (pulseFactor * 0.2)
			elseif l.FogMode == "Blood" then
				local bloodColor = Color3.fromRGB(180, 0, 0)
				lightingService.FogColor = bloodColor
				atmosphere.Color = bloodColor
				atmosphere.Density = 0.4
			end
		end
	end
end)

-- ============================================================================
-- 3. ПОЛНЫЙ НАБОР НАСТРОЕК В МЕНЮ FLUENT
-- ============================================================================
pcall(function()
	if not Window then return end
	
	local WorldTab = Window:AddTab({ Title = "World", Icon = "globe" })
    _G.NoirWorldTab = WorldTab
	
	-- Night Mode Section
	local NightSec = WorldTab:AddSection("Night Mode Engine")
	
	NightSec:AddToggle("NightModeToggle", {
		Title = "Enable Night Mode",
		Default = getgenv().NoirConfig.World.NightMode,
		Callback = function(v)
			getgenv().NoirConfig.World.NightMode = v
		end
	})
	
	NightSec:AddSlider("DarknessIntensitySlider", {
		Title = "Darkness Intensity",
		Default = 0.15,
		Min = 0.01,
		Max = 1,
		Rounding = 2,
		Callback = function(v)
			getgenv().NoirConfig.World.DarknessIntensity = v
		end
	})
	
	-- Full Lighting Editor Section
	local LightSec = WorldTab:AddSection("Full Map Lighting Editor")
	
	LightSec:AddToggle("CustomLightingToggle", {
		Title = "Enable Lighting Overrides",
		Default = getgenv().NoirConfig.World.Lighting.Enabled,
		Callback = function(v)
			getgenv().NoirConfig.World.Lighting.Enabled = v
		end
	})
	
	LightSec:AddSlider("ClockTimeSlider", {
		Title = "Time of Day (ClockTime)",
		Default = 14.5,
		Min = 0,
		Max = 24,
		Rounding = 1,
		Callback = function(v)
			getgenv().NoirConfig.World.Lighting.ClockTime = v
		end
	})
	
	LightSec:AddSlider("BrightnessSlider", {
		Title = "Brightness",
		Default = 2,
		Min = 0,
		Max = 10,
        Rounding = 1,
		Callback = function(v)
			getgenv().NoirConfig.World.Lighting.Brightness = v
		end
	})
	
	LightSec:AddSlider("ExposureSlider", {
		Title = "Exposure Compensation",
		Default = 0,
		Min = -3,
		Max = 3,
		Rounding = 1,
		Callback = function(v)
			getgenv().NoirConfig.World.Lighting.ExposureCompensation = v
		end
	})
	
	LightSec:AddSlider("ShadowSoftnessSlider", {
		Title = "Shadow Softness",
		Default = 0.2,
		Min = 0,
		Max = 1,
		Rounding = 2,
		Callback = function(v)
			getgenv().NoirConfig.World.Lighting.ShadowSoftness = v
		end
	})
	
	LightSec:AddSlider("LatitudeSlider", {
		Title = "Geographic Latitude (Sun Angle)",
		Default = 41.733,
		Min = -90,
		Max = 90,
		Rounding = 1,
		Callback = function(v)
			getgenv().NoirConfig.World.Lighting.GeographicLatitude = v
		end
	})
	
	LightSec:AddColorpicker("AmbientColorPicker", {
		Title = "Indoor Ambient Color",
		Default = getgenv().NoirConfig.World.Lighting.Ambient,
		Callback = function(v)
			getgenv().NoirConfig.World.Lighting.Ambient = v
		end
	})
	
	LightSec:AddColorpicker("OutdoorAmbientColorPicker", {
		Title = "Outdoor Ambient Color",
		Default = getgenv().NoirConfig.World.Lighting.OutdoorAmbient,
		Callback = function(v)
			getgenv().NoirConfig.World.Lighting.OutdoorAmbient = v
		end
	})
	
	LightSec:AddColorpicker("ColorShiftTopPicker", {
		Title = "ColorShift Top",
		Default = getgenv().NoirConfig.World.Lighting.ColorShift_Top,
		Callback = function(v)
			getgenv().NoirConfig.World.Lighting.ColorShift_Top = v
		end
	})
	
	LightSec:AddColorpicker("ColorShiftBottomPicker", {
		Title = "ColorShift Bottom",
		Default = getgenv().NoirConfig.World.Lighting.ColorShift_Bottom,
		Callback = function(v)
			getgenv().NoirConfig.World.Lighting.ColorShift_Bottom = v
		end
	})
	
	-- Advanced Fog Section
	local FogSec = WorldTab:AddSection("Advanced Fog & Atmosphere")
	
	FogSec:AddDropdown("FogModeDropdown", {
		Title = "Fog Atmosphere Mode",
		Values = {"Disabled", "Standard", "Rainbow", "Pulse", "Blood"},
		Default = 1,
		Callback = function(v)
			getgenv().NoirConfig.World.Lighting.FogMode = v
		end
	})
	
	FogSec:AddSlider("FogEndSlider", {
		Title = "Fog Distance (FogEnd)",
		Default = 1000,
		Min = 50,
		Max = 5000,
		Rounding = 0,
		Callback = function(v)
			getgenv().NoirConfig.World.Lighting.FogEnd = v
		end
	})
	
	FogSec:AddColorpicker("FogColorPicker", {
		Title = "Custom Fog Color",
		Default = getgenv().NoirConfig.World.Lighting.FogColor,
		Callback = function(v)
			getgenv().NoirConfig.World.Lighting.FogColor = v
		end
	})
	
	-- Themes Tab
	local ThemesTab = Window:AddTab({ Title = "Themes", Icon = "palette" })
	local ThemeSec = ThemesTab:AddSection("UI Theme Selector")
	
	ThemeSec:AddDropdown("ThemeSelectDropdown", {
		Title = "Interface Theme",
		Values = {"Dark", "Darker", "Light", "Aqua", "Amethyst", "Rose"},
		Default = 1,
		Callback = function(v)
			getgenv().NoirConfig.Themes.SelectedTheme = v
			pcall(function()
				Fluent:SetTheme(v)
			end)
		end
	})
	
	Fluent:Notify({
		Title = "NOIR Module 2 Updated",
		Content = "All lighting options, Fog modes & Keybind [N] loaded!",
		Duration = 4
	})
end)
-- ============================================================================
-- NOIR / MM2 INTERNAL SCRIPT - PART 3 (ANTI-AIM & SAFE MOVEMENT)
-- ============================================================================

local playersService = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local localPlayer = playersService.LocalPlayer
local camera = workspace.CurrentCamera

-- Расширяем конфигурацию
getgenv().NoirConfig = getgenv().NoirConfig or {}
getgenv().NoirConfig.AntiAim = {
    Enabled = false,
    Mode = "Spinbot", -- "HeadAtView", "Spinbot", "Jitter", "Random"
    SpinSpeed = 15,
    JitterIntensity = 45,
}

getgenv().NoirConfig.Movement = {
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    WalkSpeedEnabled = false,
    WalkSpeed = 24, -- Безопасное значение, чтобы не кикало античитом
    JumpPowerEnabled = false,
    JumpPower = 50,
}

-- ============================================================================
-- 1. ANTI-AIM ENGINE (HeadAtView, Spinbot, Jitter, Random)
-- ============================================================================
local antiAimRotation = 0

runService.RenderStepped:Connect(function()
    local aaCfg = getgenv().NoirConfig.AntiAim
    if not aaCfg.Enabled then return end
    
    local character = localPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not (hrp and humanoid) then return end
    
    -- Предотвращаем падение персонажа при манипуляциях с ориентацией
    humanoid.AutoRotate = false
    
    if aaCfg.Mode == "HeadAtView" then
        -- Всегда лицом/головой к камере игрока
        local camLook = camera.CFrame.LookVector
        local targetCFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(camLook.X, 0, camLook.Z))
        hrp.CFrame = targetCFrame
    elseif aaCfg.Mode == "Spinbot" then
        -- Крутилка (Spinbot)
        antiAimRotation = (antiAimRotation + aaCfg.SpinSpeed) % 360
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(antiAimRotation), 0)
    elseif aaCfg.Mode == "Jitter" then
        -- Дрыгалка (Jitter)
        local jitterAngle = math.random(-aaCfg.JitterIntensity, aaCfg.JitterIntensity)
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(jitterAngle), 0)
    elseif aaCfg.Mode == "Random" then
        -- Случайное вращение
        local randomAngle = math.random(-180, 180)
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(randomAngle), 0)
    end
end)

-- Возвращаем AutoRotate обратно при выключении Anti-Aim
local function toggleAntiAimState(state)
    getgenv().NoirConfig.AntiAim.Enabled = state
    if not state and localPlayer.Character then
        local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

-- ============================================================================
-- 2. SAFE MOVEMENT (FLY, NOCLIP, SPEED, JUMP - ANTIBAN / NO-KICK)
-- ============================================================================
local flyBodyVelocity, flyBodyGyro

runService.RenderStepped:Connect(function()
    local mCfg = getgenv().NoirConfig.Movement
    local character = localPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not (hrp and humanoid) then return end
    
    -- Safe WalkSpeed & JumpPower (без резких скачков, чтобы не триггерить античит)
    if mCfg.WalkSpeedEnabled then
        humanoid.WalkSpeed = mCfg.WalkSpeed
    end
    
    if mCfg.JumpPowerEnabled then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = mCfg.JumpPower
    end
    
    -- Noclip (безопасное отключение коллизий)
    if mCfg.Noclip then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Fly Engine (с плавной физикой во избежание телепортационных киков)
    if mCfg.Fly then
        if not flyBodyVelocity then
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBodyVelocity.Velocity = Vector3.zero
            flyBodyVelocity.Parent = hrp
            
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBodyGyro.P = 9000
            flyBodyGyro.Parent = hrp
        end
        
        humanoid.PlatformStand = true
        local camCFrame = camera.CFrame
        local moveDir = Vector3.zero
        
        if userInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCFrame.LookVector end
        if userInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCFrame.LookVector end
        if userInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCFrame.RightVector end
        if userInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCFrame.RightVector end
        if userInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        flyBodyVelocity.Velocity = moveDir * mCfg.FlySpeed
        flyBodyGyro.CFrame = camCFrame
    else
        if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
        if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
        if humanoid.PlatformStand and not mCfg.Fly then
            humanoid.PlatformStand = false
        end
    end
end)

-- ============================================================================
-- 3. ДОБАВЛЕНИЕ ВКЛАДОК В МЕНЮ FLUENT
-- ============================================================================
pcall(function()
    if not Window then return end
    
    -- Вкладка Anti-Aim
    local AntiAimTab = Window:AddTab({ Title = "Anti-Aim", Icon = "shield" })
    local AASec = AntiAimTab:AddSection("Anti-Aim Configurations")
    
    AASec:AddToggle("AIToggle", {
        Title = "Enable Anti-Aim",
        Default = false,
        Callback = function(v)
            toggleAntiAimState(v)
        end
    })
    
    AASec:AddDropdown("AIMode", {
        Title = "Anti-Aim Mode",
        Values = {"HeadAtView", "Spinbot", "Jitter", "Random"},
        Default = 2,
        Callback = function(v)
            getgenv().NoirConfig.AntiAim.Mode = v
        end
    })
    
    AASec:AddSlider("SpinSpeedSlider", {
        Title = "Spinbot Speed",
        Default = 15,
        Min = 1,
        Max = 50,
        Rounding = 0,
        Callback = function(v)
            getgenv().NoirConfig.AntiAim.SpinSpeed = v
        end
    })
    
    AASec:AddSlider("JitterIntensitySlider", {
        Title = "Jitter Intensity",
        Default = 45,
        Min = 5,
        Max = 180,
        Rounding = 0,
        Callback = function(v)
            getgenv().NoirConfig.AntiAim.JitterIntensity = v
        end
    })
    
    -- Вкладка Movement (Безопасный перенос)
    local MoveTab = Window:AddTab({ Title = "Movement", Icon = "move" })
    local MoveSec = MoveTab:AddSection("Safe Movement & Speed (No Kick)")
    
    MoveSec:AddToggle("FlyToggle", {
        Title = "Enable Fly",
        Default = false,
        Callback = function(v)
            getgenv().NoirConfig.Movement.Fly = v
        end
    })
    
    MoveSec:AddSlider("FlySpeedSlider", {
        Title = "Fly Speed",
        Default = 50,
        Min = 10,
        Max = 150,
        Rounding = 0,
        Callback = function(v)
            getgenv().NoirConfig.Movement.FlySpeed = v
        end
    })
    
    MoveSec:AddToggle("NoclipToggle", {
        Title = "Enable Noclip",
        Default = false,
        Callback = function(v)
            getgenv().NoirConfig.Movement.Noclip = v
        end
    })
    
    MoveSec:AddToggle("WSToggle", {
        Title = "Safe WalkSpeed",
        Default = false,
        Callback = function(v)
            getgenv().NoirConfig.Movement.WalkSpeedEnabled = v
        end
    })
    
    MoveSec:AddSlider("WSSlider", {
        Title = "WalkSpeed Value",
        Default = 24,
        Min = 16,
        Max = 40, -- Безопасный предел от киков
        Rounding = 0,
        Callback = function(v)
            getgenv().NoirConfig.Movement.WalkSpeed = v
        end
    })
    
    MoveSec:AddToggle("JPToggle", {
        Title = "Safe JumpPower",
        Default = false,
        Callback = function(v)
            getgenv().NoirConfig.Movement.JumpPowerEnabled = v
        end
    })
    
    MoveSec:AddSlider("JPSlider", {
        Title = "JumpPower Value",
        Default = 50,
        Min = 50,
        Max = 120, -- Безопасный предел от киков
        Rounding = 0,
        Callback = function(v)
            getgenv().NoirConfig.Movement.JumpPower = v
        end
    })
    
    Fluent:Notify({
        Title = "NOIR Part 3 Loaded",
        Content = "Anti-Aim & Safe Movement modules successfully initialized!",
        Duration = 4
    })
end)
-- ============================================================================
-- NOIR / MM2 INTERNAL SCRIPT - PART 4 (FIXED ICON, MENU & DIRECT PARTICLES)
-- ============================================================================

local playersService = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = playersService.LocalPlayer

getgenv().NoirConfig = getgenv().NoirConfig or {}
getgenv().NoirConfig.Particles = {
    Enabled = false,
    Preset = "Soft Dots", -- "Soft Dots", "Neon Sparkles", "Fire Embers", "Stardust", "Custom ID"
    CustomAssetId = "1084991215",
    
    Rate = 60,
    LifetimeMin = 2,
    LifetimeMax = 4,
    Speed = 15,
    Size = 1.2,
    Transparency = 0.1,
    
    StartColor = Color3.fromRGB(255, 255, 255),
    EndColor = Color3.fromRGB(150, 200, 255),
    
    PointLightEnabled = true,
    LightBrightness = 2.0,
    LightRange = 10,
}

local activeEmitter = nil
local activeLight = nil

local function cleanupParticles()
    if activeEmitter then activeEmitter:Destroy() activeEmitter = nil end
    if activeLight then activeLight:Destroy() activeLight = nil end
end

local function updateParticles()
    local pCfg = getgenv().NoirConfig.Particles
    local character = localPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    
    if not pCfg.Enabled or not hrp then
        cleanupParticles()
        return
    end
    
    -- Создаем эмиттер и свет прямо на HumanoidRootPart
    if not activeEmitter or activeEmitter.Parent ~= hrp then
        cleanupParticles()
        
        activeEmitter = Instance.new("ParticleEmitter")
        activeEmitter.Name = "NoirPlayerEmitter"
        activeEmitter.Parent = hrp
        
        activeLight = Instance.new("PointLight")
        activeLight.Name = "NoirPlayerLight"
        activeLight.Parent = hrp
    end
    
    -- Синхронизация параметров
    activeEmitter.Rate = pCfg.Rate
    activeEmitter.Lifetime = NumberRange.new(pCfg.LifetimeMin, pCfg.LifetimeMax)
    activeEmitter.Speed = NumberRange.new(pCfg.Speed * 0.5, pCfg.Speed * 1.5)
    activeEmitter.Size = NumberSequence.new(pCfg.Size)
    activeEmitter.Transparency = NumberSequence.new(pCfg.Transparency)
    activeEmitter.SpreadAngle = Vector2.new(-180, 180) -- Полный круговой разлет
    activeEmitter.EmissionDirection = Enum.NormalId.Top
    
    activeLight.Enabled = pCfg.PointLightEnabled
    activeLight.Brightness = pCfg.LightBrightness
    activeLight.Range = pCfg.LightRange
    activeLight.Color = pCfg.StartColor
    
    -- Спрайты и свойства движения
    local assetId = "rbxassetid://1084991215"
    if pCfg.Preset == "Soft Dots" then
        assetId = "rbxassetid://1084991215"
        activeEmitter.Acceleration = Vector3.new(0, 0, 0)
    elseif pCfg.Preset == "Neon Sparkles" then
        assetId = "rbxassetid://1084993121"
        activeEmitter.Acceleration = Vector3.new(0, 3, 0)
    elseif pCfg.Preset == "Fire Embers" then
        assetId = "rbxassetid://1084993121"
        activeEmitter.Acceleration = Vector3.new(0, 8, 0)
    elseif pCfg.Preset == "Stardust" then
        assetId = "rbxassetid://1084991215"
        activeEmitter.Acceleration = Vector3.new(1, 2, 1)
    elseif pCfg.Preset == "Custom ID" then
        local cleanId = pCfg.CustomAssetId:gsub("%D", "")
        if cleanId ~= "" then assetId = "rbxassetid://" .. cleanId end
        activeEmitter.Acceleration = Vector3.new(0, 0, 0)
    end
    
    activeEmitter.Texture = assetId
    activeEmitter.Color = ColorSequence.new(pCfg.StartColor, pCfg.EndColor)
end

localPlayer.CharacterAdded:Connect(function()
    cleanupParticles()
    task.wait(1)
    if getgenv().NoirConfig.Particles.Enabled then
        updateParticles()
    end
end)

runService.RenderStepped:Connect(function()
    if getgenv().NoirConfig.Particles.Enabled then
        updateParticles()
    end
end)

-- ============================================================================
-- ИНТЕГРАЦИЯ В МЕНЮ FLUENT С ИКОНКОЙ
-- ============================================================================
pcall(function()
    if not Window then return end
    
    -- Иконка "sparkles" из верных системных иконок Fluent
    local ParticlesTab = Window:AddTab({ Title = "Particles", Icon = "flame" })
    
    local MainSec = ParticlesTab:AddSection("Attached Player Particles Engine")
    
    MainSec:AddToggle("ParticlesToggle", {
        Title = "Enable Player Particles",
        Default = getgenv().NoirConfig.Particles.Enabled,
        Callback = function(v)
            getgenv().NoirConfig.Particles.Enabled = v
            updateParticles()
        end
    })
    
    MainSec:AddDropdown("ParticlePresetDropdown", {
        Title = "Particle Sprites",
        Values = {"Soft Dots", "Neon Sparkles", "Fire Embers", "Stardust", "Custom ID"},
        Default = 1,
        Callback = function(v)
            getgenv().NoirConfig.Particles.Preset = v
            updateParticles()
        end
    })
    
    MainSec:AddInput("CustomParticleInput", {
        Title = "Custom Sprite Asset ID",
        Default = "",
        Placeholder = "Enter ID (e.g. 1084991215)",
        Finished = true,
        Callback = function(text)
            getgenv().NoirConfig.Particles.CustomAssetId = text
            getgenv().NoirConfig.Particles.Preset = "Custom ID"
            updateParticles()
        end
    })
    
    local SpeedSec = ParticlesTab:AddSection("Speed, Rate & Size")
    
    SpeedSec:AddSlider("ParticleSpeedSlider", {
        Title = "Particle Movement Speed",
        Default = 15,
        Min = 1,
        Max = 60,
        Rounding = 0,
        Callback = function(v)
            getgenv().NoirConfig.Particles.Speed = v
            updateParticles()
        end
    })
    
    SpeedSec:AddSlider("RateSlider", {
        Title = "Emission Rate (Density)",
        Default = 60,
        Min = 10,
        Max = 250,
        Rounding = 0,
        Callback = function(v)
            getgenv().NoirConfig.Particles.Rate = v
            updateParticles()
        end
    })
    
    SpeedSec:AddSlider("SizeSlider", {
        Title = "Particle Size",
        Default = 1.2,
        Min = 0.2,
        Max = 5,
        Rounding = 1,
        Callback = function(v)
            getgenv().NoirConfig.Particles.Size = v
            updateParticles()
        end
    })
    
    local ColorSec = ParticlesTab:AddSection("Colors & PointLight Glow")
    
    ColorSec:AddColorpicker("StartColorPicker", {
        Title = "Particle Start Color",
        Default = getgenv().NoirConfig.Particles.StartColor,
        Callback = function(v)
            getgenv().NoirConfig.Particles.StartColor = v
            updateParticles()
        end
    })
    
    ColorSec:AddColorpicker("EndColorPicker", {
        Title = "Particle End Color",
        Default = getgenv().NoirConfig.Particles.EndColor,
        Callback = function(v)
            getgenv().NoirConfig.Particles.EndColor = v
            updateParticles()
        end
    })
    
    ColorSec:AddToggle("PointLightToggle", {
        Title = "Enable Dynamic PointLight",
        Default = getgenv().NoirConfig.Particles.PointLightEnabled,
        Callback = function(v)
            getgenv().NoirConfig.Particles.PointLightEnabled = v
            updateParticles()
        end
    })
    
    ColorSec:AddSlider("LightBrightnessSlider", {
        Title = "Light Brightness",
        Default = 2.0,
        Min = 0.1,
        Max = 10,
        Rounding = 1,
        Callback = function(v)
            getgenv().NoirConfig.Particles.LightBrightness = v
            updateParticles()
        end
    })
    
    Fluent:Notify({
        Title = "NOIR Particles Integrated",
        Content = "Tab icon fixed, particles spawning directly from HRP with custom speed!",
        Duration = 4
    })
end)
-- ============================================================================
-- NOIR / MM2 INTERNAL SCRIPT - PART 5 (WORKING MODEL CHANGER VIA GETOBJECTS)
-- ============================================================================

local playersService = game:GetService("Players")
local localPlayer = playersService.LocalPlayer

getgenv().NoirConfig = getgenv().NoirConfig or {}
getgenv().NoirConfig.Models = {
    LocalModelEnabled = false,
    LocalAssetId = "",
    
    OthersModelEnabled = false,
    OthersAssetId = "",
}

-- Очистка ранее примененной кастомной модели
local function removeCustomModel(character)
    if not character then return end
    
    for _, child in ipairs(character:GetChildren()) do
        if child.Name == "NoirCustomModel" then
            child:Destroy()
        end
    end
    
    -- Возвращаем видимость оригинальных частей персонажа
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 0
        elseif part:IsA("Accessory") then
            local handle = part:FindFirstChild("Handle")
            if handle then handle.Transparency = 0 end
        end
    end
end

-- Применение кастомной модели (Model / Bundle ID)
local function applyCustomAssetId(targetPlayer, rawInput)
    local cleanId = tostring(rawInput):gsub("%D", "") -- Жесткая фильтрация: оставляет ТОЛЬКО цифры
    if cleanId == "" then return end
    
    local character = targetPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    
    pcall(function()
        -- Загружаем ассет напрямую через GetObjects (обходит FE блокировки InsertService)
        local objects = game:GetObjects("rbxassetid://" .. cleanId)
        if not objects or #objects == 0 then return end
        
        local downloadedObj = objects[1]
        local customModel = nil
        
        if downloadedObj:IsA("Model") then
            customModel = downloadedObj
        else
            customModel = Instance.new("Model")
            downloadedObj.Parent = customModel
        end
        
        customModel.Name = "NoirCustomModel"
        
        -- Скрываем детали оригинального скина
        removeCustomModel(character)
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
            elseif part:IsA("Accessory") then
                local handle = part:FindFirstChild("Handle")
                if handle then handle.Transparency = 1 end
            end
        end
        
        -- Выравниваем и привариваем модель к HumanoidRootPart
        local primaryPart = customModel.PrimaryPart or customModel:FindFirstChildWhichIsA("BasePart")
        if primaryPart then
            customModel.Parent = character
            primaryPart.CFrame = hrp.CFrame
            
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = hrp
            weld.Part1 = primaryPart
            weld.Parent = primaryPart
            
            -- Отключаем коллизию у новой модели, чтобы персонаж не баговал
            for _, p in ipairs(customModel:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                    p.Massless = true
                end
            end
        end
    end)
end

-- Обновление локального игрока
local function updateLocalModel()
    local mCfg = getgenv().NoirConfig.Models
    if mCfg.LocalModelEnabled and mCfg.LocalAssetId ~= "" then
        applyCustomAssetId(localPlayer, mCfg.LocalAssetId)
    else
        removeCustomModel(localPlayer.Character)
    end
end

-- Обновление остальных игроков
local function updateOthersModels()
    local mCfg = getgenv().NoirConfig.Models
    if not mCfg.OthersModelEnabled or mCfg.OthersAssetId == "" then return end
    
    for _, player in ipairs(playersService:GetPlayers()) do
        if player ~= localPlayer then
            applyCustomAssetId(player, mCfg.OthersAssetId)
        end
    end
end

-- Авто-обновление при респавне
localPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if getgenv().NoirConfig.Models.LocalModelEnabled then
        updateLocalModel()
    end
end)

-- ============================================================================
-- ИНТЕГРАЦИЯ В МЕНЮ FLUENT
-- ============================================================================
pcall(function()
    if not Window then return end
    
    local ModelsTab = Window:AddTab({ Title = "Models", Icon = "user" })
    
    -- Секция для себя
    local LocalSec = ModelsTab:AddSection("Local Custom Model Changer")
    
    LocalSec:AddToggle("LocalModelToggle", {
        Title = "Enable Local Custom Model",
        Default = getgenv().NoirConfig.Models.LocalModelEnabled,
        Callback = function(v)
            getgenv().NoirConfig.Models.LocalModelEnabled = v
            updateLocalModel()
        end
    })
    
    LocalSec:AddInput("LocalModelInput", {
        Title = "Model Asset ID",
        Default = "",
        Placeholder = "Enter digits only...",
        Finished = true,
        Callback = function(text)
            getgenv().NoirConfig.Models.LocalAssetId = text
            updateLocalModel()
        end
    })
    
    -- Секция для других игроков
    local OthersSec = ModelsTab:AddSection("Others Custom Model Changer")
    
    OthersSec:AddToggle("OthersModelToggle", {
        Title = "Enable Others Model",
        Default = getgenv().NoirConfig.Models.OthersModelEnabled,
        Callback = function(v)
            getgenv().NoirConfig.Models.OthersModelEnabled = v
            updateOthersModels()
        end
    })
    
    OthersSec:AddInput("OthersModelInput", {
        Title = "Other Players Model Asset ID",
        Default = "",
        Placeholder = "Enter digits only...",
        Finished = true,
        Callback = function(text)
            getgenv().NoirConfig.Models.OthersAssetId = text
            updateOthersModels()
        end
    })
    
    Fluent:Notify({
        Title = "NOIR Models Module Loaded",
        Content = "Bypassed FE model changer ready!",
        Duration = 4
    })
end)
-- ============================================================================
-- NOIR / MM2 INTERNAL SCRIPT - PART 6 (ULTRA COMPACT CONFIGS)
-- ============================================================================

local httpService = game:GetService("HttpService")

getgenv().NoirConfig = getgenv().NoirConfig or {}
getgenv().NoirConfig.Settings = getgenv().NoirConfig.Settings or {
    CurrentSlot = "Slot1",
    ImportString = "",
    AutoLoad = true,
}

local CONFIG_FOLDER = "NOIR_MM2_Configs"
if isfolder and not isfolder(CONFIG_FOLDER) then
    makefolder(CONFIG_FOLDER)
end

-- Сериализация Color3
local function encodeCustomTypes(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if typeof(v) == "Color3" then
            copy[k] = { __type = "Color3", r = v.R, g = v.G, b = v.B }
        elseif typeof(v) == "table" then
            copy[k] = encodeCustomTypes(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local function decodeCustomTypes(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if typeof(v) == "table" then
            if v.__type == "Color3" then
                copy[k] = Color3.new(v.r, v.g, v.b)
            else
                copy[k] = decodeCustomTypes(v)
            end
        else
            copy[k] = v
        end
    end
    return copy
end

local function saveConfig(slotName)
    if not writefile then return false end
    local success = pcall(function()
        writefile(CONFIG_FOLDER .. "/" .. slotName .. ".json", httpService:JSONEncode(encodeCustomTypes(getgenv().NoirConfig)))
    end)
    return success
end

local function loadConfig(slotName)
    if not readfile or not isfile then return false end
    local fileName = CONFIG_FOLDER .. "/" .. slotName .. ".json"
    if not isfile(fileName) then return false end
    
    local success = pcall(function()
        -- Загружаем данные из файла
        local data = decodeCustomTypes(httpService:JSONDecode(readfile(fileName)))
        getgenv().NoirConfig = data

        -- 🟢 ОБНОВЛЯЕМ UI ЭЛЕМЕНТЫ 🟢
        if Fluent and Fluent.Options then
            -- 1. Инпуты (Текст)
            if Fluent.Options["MapAssetIdInput"] and data.AssetMap then
                Fluent.Options["MapAssetIdInput"]:SetValue(data.AssetMap.PendingID or "")
            end
            if Fluent.Options["DroneAssetIdInput"] and data.Drone then
                Fluent.Options["DroneAssetIdInput"]:SetValue(data.Drone.AssetID or "")
            end
            if Fluent.Options["LocalModelInput"] and data.Models then
                Fluent.Options["LocalModelInput"]:SetValue(data.Models.LocalAssetId or "")
            end
            if Fluent.Options["OthersModelInput"] and data.Models then
                Fluent.Options["OthersModelInput"]:SetValue(data.Models.OthersAssetId or "")
            end
            if Fluent.Options["CustomParticleInput"] and data.Particles then
                Fluent.Options["CustomParticleInput"]:SetValue(data.Particles.CustomAssetId or "")
            end
            if Fluent.Options["ImportConfigInput"] then
                Fluent.Options["ImportConfigInput"]:SetValue("")
            end

            -- 2. Слайдеры
            if Fluent.Options["DroneSpeedSlider"] and data.Drone then
                Fluent.Options["DroneSpeedSlider"]:SetValue(data.Drone.Speed or 80)
            end
            if Fluent.Options["MapHeight"] and data.Map then
                Fluent.Options["MapHeight"]:SetValue(data.Map.Position.Y or 500)
            end
            if Fluent.Options["AssetMapHeight"] and data.AssetMap then
                Fluent.Options["AssetMapHeight"]:SetValue(data.AssetMap.Height or 500)
            end
            if Fluent.Options["FlingDuration"] and data.Fun then
                Fluent.Options["FlingDuration"]:SetValue(data.Fun.FlingDuration or 2.0)
            end
            if Fluent.Options["FovSlider"] and data.Combat then
                Fluent.Options["FovSlider"]:SetValue(data.Combat.FovRadius or 120)
            end
            if Fluent.Options["FlySpeedSlider"] and data.Movement then
                Fluent.Options["FlySpeedSlider"]:SetValue(data.Movement.FlySpeed or 50)
            end
            if Fluent.Options["WSSlider"] and data.Movement then
                Fluent.Options["WSSlider"]:SetValue(data.Movement.WalkSpeed or 24)
            end
            if Fluent.Options["JPSlider"] and data.Movement then
                Fluent.Options["JPSlider"]:SetValue(data.Movement.JumpPower or 50)
            end
            if Fluent.Options["SpinSpeedSlider"] and data.AntiAim then
                Fluent.Options["SpinSpeedSlider"]:SetValue(data.AntiAim.SpinSpeed or 15)
            end
            if Fluent.Options["JitterIntensitySlider"] and data.AntiAim then
                Fluent.Options["JitterIntensitySlider"]:SetValue(data.AntiAim.JitterIntensity or 45)
            end
            if Fluent.Options["ParticleSpeedSlider"] and data.Particles then
                Fluent.Options["ParticleSpeedSlider"]:SetValue(data.Particles.Speed or 15)
            end
            if Fluent.Options["RateSlider"] and data.Particles then
                Fluent.Options["RateSlider"]:SetValue(data.Particles.Rate or 60)
            end
            if Fluent.Options["SizeSlider"] and data.Particles then
                Fluent.Options["SizeSlider"]:SetValue(data.Particles.Size or 1.2)
            end

            -- 3. Тумблеры (Toggles)
            if Fluent.Options["GunsMasterToggle"] and data.Fun then
                Fluent.Options["GunsMasterToggle"]:SetValue(data.Fun.GunsEnabled or false)
            end
            if Fluent.Options["DroneCollisionToggle"] and data.Drone then
                Fluent.Options["DroneCollisionToggle"]:SetValue(data.Drone.CollisionEnabled or false)
            end
            if Fluent.Options["DroneTrailToggle"] and data.Drone then
                Fluent.Options["DroneTrailToggle"]:SetValue(data.Drone.TrailEnabled or true)
            end
            if Fluent.Options["AntiFlingToggle"] and data.AntiFling then
                Fluent.Options["AntiFlingToggle"]:SetValue(data.AntiFling.Enabled or false)
            end
            if Fluent.Options["AimbotToggle"] and data.Combat then
                Fluent.Options["AimbotToggle"]:SetValue(data.Combat.Aimbot or false)
            end
            if Fluent.Options["SilentAimToggle"] and data.Combat then
                Fluent.Options["SilentAimToggle"]:SetValue(data.Combat.SilentAim or false)
            end
            if Fluent.Options["GunWallsToggle"] and data.Combat then
                Fluent.Options["GunWallsToggle"]:SetValue(data.Combat.GunWalls or false)
            end
            if Fluent.Options["KnifeWallsToggle"] and data.Combat then
                Fluent.Options["KnifeWallsToggle"]:SetValue(data.Combat.KnifeWalls or false)
            end
            if Fluent.Options["AIToggle"] and data.AntiAim then
                Fluent.Options["AIToggle"]:SetValue(data.AntiAim.Enabled or false)
            end
            if Fluent.Options["FlyToggle"] and data.Movement then
                Fluent.Options["FlyToggle"]:SetValue(data.Movement.Fly or false)
            end
            if Fluent.Options["NoclipToggle"] and data.Movement then
                Fluent.Options["NoclipToggle"]:SetValue(data.Movement.Noclip or false)
            end
            if Fluent.Options["WSToggle"] and data.Movement then
                Fluent.Options["WSToggle"]:SetValue(data.Movement.WalkSpeedEnabled or false)
            end
            if Fluent.Options["JPToggle"] and data.Movement then
                Fluent.Options["JPToggle"]:SetValue(data.Movement.JumpPowerEnabled or false)
            end
            if Fluent.Options["ParticlesToggle"] and data.Particles then
                Fluent.Options["ParticlesToggle"]:SetValue(data.Particles.Enabled or false)
            end
            if Fluent.Options["ChamsToggle"] and data.Chams then
                Fluent.Options["ChamsToggle"]:SetValue(data.Chams.Enabled or false)
            end

            -- 4. Дропдауны
            if Fluent.Options["WeaponSelect"] and data.Fun then
                Fluent.Options["WeaponSelect"]:SetValue(data.Fun.SelectedWeapon or "AK-47")
            end
            if Fluent.Options["DroneModeSelect"] and data.Drone then
                Fluent.Options["DroneModeSelect"]:SetValue(data.Drone.Mode or "Fling")
            end
            if Fluent.Options["ChamsMode"] and data.Chams then
                Fluent.Options["ChamsMode"]:SetValue(data.Chams.Mode or "Glow")
            end
            if Fluent.Options["AIMode"] and data.AntiAim then
                Fluent.Options["AIMode"]:SetValue(data.AntiAim.Mode or "Spinbot")
            end
            if Fluent.Options["FogModeDropdown"] and data.World then
                Fluent.Options["FogModeDropdown"]:SetValue(data.World.Lighting.FogMode or "Disabled")
            end
            if Fluent.Options["ParticlePresetDropdown"] and data.Particles then
                Fluent.Options["ParticlePresetDropdown"]:SetValue(data.Particles.Preset or "Soft Dots")
            end
            if Fluent.Options["ConfigSlotSelect"] and data.Settings then
                Fluent.Options["ConfigSlotSelect"]:SetValue(data.Settings.CurrentSlot or "Slot1")
            end

            -- 5. Цвета (ColorPickers)
            if Fluent.Options["DroneTrailColor"] and data.Drone then
                Fluent.Options["DroneTrailColor"]:SetValue(data.Drone.TrailColor or Color3.fromRGB(0,255,255))
            end
            if Fluent.Options["InnocentColor"] and data.Chams then
                Fluent.Options["InnocentColor"]:SetValue(data.Chams.InnocentColor or Color3.fromRGB(0,255,100))
            end
            if Fluent.Options["SheriffColor"] and data.Chams then
                Fluent.Options["SheriffColor"]:SetValue(data.Chams.SheriffColor or Color3.fromRGB(0,150,255))
            end
            if Fluent.Options["MurdererColor"] and data.Chams then
                Fluent.Options["MurdererColor"]:SetValue(data.Chams.MurdererColor or Color3.fromRGB(255,50,50))
            end
        end
    end)
    
    return success
end

-- Автозагрузка
if getgenv().NoirConfig.Settings.AutoLoad then
    pcall(function() loadConfig("autosave") end)
end

local function exportConfigToString()
    local success, result = pcall(function()
        return httpService:JSONEncode(encodeCustomTypes(getgenv().NoirConfig))
    end)
    if success and setclipboard then
        setclipboard(result)
        return true
    end
    return false
end

local function importConfigFromString(str)
    if not str or str == "" then return false end
    local success = pcall(function()
        getgenv().NoirConfig = decodeCustomTypes(httpService:JSONDecode(str))
    end)
    return success
end

-- ============================================================================
-- ИНТЕГРАЦИЯ КОМПАКТНОГО МЕНЕДЖЕРА КОНФИГОВ
-- ============================================================================
pcall(function()
    if not Window then return end
    
    local ConfigsTab = Window:AddTab({ Title = "Configs", Icon = "folder" })
    local Sec = ConfigsTab:AddSection("Configuration Management")
    
    Sec:AddDropdown("ConfigSlotSelect", {
        Title = "Active Slot",
        Values = {"Slot1", "Slot2", "Slot3", "Default"},
        Default = 1,
        Callback = function(v)
            getgenv().NoirConfig.Settings.CurrentSlot = v
        end
    })
    
    Sec:AddButton({
        Title = "Save Config",
        Callback = function()
            local slot = getgenv().NoirConfig.Settings.CurrentSlot or "Slot1"
            if saveConfig(slot) then
                Fluent:Notify({ Title = "Saved!", Content = "Config saved to " .. slot, Duration = 2 })
            end
        end
    })
    
    Sec:AddButton({
        Title = "Load Config",
        Callback = function()
            local slot = getgenv().NoirConfig.Settings.CurrentSlot or "Slot1"
            if loadConfig(slot) then
                Fluent:Notify({ Title = "Loaded!", Content = "Config loaded from " .. slot, Duration = 2 })
            else
                Fluent:Notify({ Title = "Error", Content = "File not found", Duration = 2 })
            end
        end
    })
    
    Sec:AddButton({
        Title = "Export to Clipboard",
        Callback = function()
            if exportConfigToString() then
                Fluent:Notify({ Title = "Exported", Content = "Copied to clipboard!", Duration = 2 })
            end
        end
    })
    
    local importInputRef
    importInputRef = Sec:AddInput("ImportConfigInput", {
        Title = "Import String",
        Default = "",
        Placeholder = "Paste JSON...",
        Finished = false,
        Callback = function(text) end
    })
    
    Sec:AddButton({
        Title = "Apply Import",
        Callback = function()
            local str = importInputRef and importInputRef.Value or ""
            if importConfigFromString(str) then
                Fluent:Notify({ Title = "Success", Content = "Config imported!", Duration = 2 })
            else
                Fluent:Notify({ Title = "Error", Content = "Invalid string", Duration = 2 })
            end
        end
    })
    
    Fluent:Notify({
        Title = "Configs Ready",
        Content = "All buttons fitted to screen!",
        Duration = 3
    })
end)
-- ============================================================================
-- NOIR / MM2 INTERNAL SCRIPT - PART 7 (SkidFling Integration)
-- ============================================================================

local players = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer

getgenv().NoirConfig = getgenv().NoirConfig or {}
getgenv().NoirConfig.Fling = getgenv().NoirConfig.Fling or {
    Enabled = false,
    Mode = "All", -- "All", "Murderer", "Sheriff", или имя
    Power = 10000, -- Оставил для совместимости с UI (в SkidFling используется фиксированная скорость)
}

getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight
local flinging = false
local flingConnection = nil

-- ============================================================================
-- ФУНКЦИЯ SKIDFLING (ЖЕСТКИЙ ФЛИНГ)
-- ============================================================================
local function SkidFling(TargetPlayer)
    if flinging or not TargetPlayer then return end
    flinging = true

    local Character = localPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then flinging = false return end
    
    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle
    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessory and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end
    
    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        
        if THumanoid and THumanoid.Sit then
            flinging = false
            return
        end
        
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then flinging = false return end
        
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        
        local SFBasePart = function(BasePart)
            local TimeToWait = 2.0 -- Длительность флинга
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                    end
                end
            until Time + TimeToWait < tick() or not getgenv().NoirConfig.Fling.Enabled
        end
        
        workspace.FallenPartsDestroyHeight = 0/0
        
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        
        if TRootPart then
            SFBasePart(TRootPart)
        elseif THead then
            SFBasePart(THead)
        elseif Handle then
            SFBasePart(Handle)
        end
        
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        
        if getgenv().OldPos then
            local rt0 = tick()
            repeat
                if RootPart and Humanoid and Character then
                    RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                    Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                    Humanoid:ChangeState("GettingUp")
                    for _, part in pairs(Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                        end
                    end
                end
                task.wait()
            until (not RootPart) or (RootPart.Position - getgenv().OldPos.p).Magnitude < 25 or tick() - rt0 > 3
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
    end
    flinging = false
end

-- ============================================================================
-- ЛОГИКА ПОИСКА ЦЕЛИ И ЦИКЛ ФЛИНГА
-- ============================================================================
local function findMM2Target(mode)
    for _, p in ipairs(players:GetPlayers()) do
        if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local backpack = p:FindFirstChild("Backpack")
            local char = p.Character
            local hasKnife = (char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")))
            local hasGun = (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") or (backpack and (backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver"))))
            
            if mode == "Murderer" and hasKnife then
                return p
            elseif mode == "Sheriff" and hasGun and not hasKnife then
                return p
            end
        end
    end
    return nil
end

local function toggleFling(state)
    getgenv().NoirConfig.Fling.Enabled = state
    
    if state then
        if flingConnection then flingConnection:Disconnect() end
        
        flingConnection = runService.Heartbeat:Connect(function()
            if not getgenv().NoirConfig.Fling.Enabled then return end
            if flinging then return end -- Ждем, пока текущий флинг завершится
            
            local mode = getgenv().NoirConfig.Fling.Mode
            local targetPlayer = nil
            
            if mode == "Murderer" or mode == "Sheriff" then
                targetPlayer = findMM2Target(mode)
            elseif mode == "All" then
                local shortestDist = math.huge
                local char = localPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local root = char.HumanoidRootPart
                    for _, p in ipairs(players:GetPlayers()) do
                        if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                            if tHum and tHum.Health > 0 then
                                local dist = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                                if dist < shortestDist then
                                    shortestDist = dist
                                    targetPlayer = p
                                end
                            end
                        end
                    end
                end
            else
                local p = players:FindFirstChild(mode)
                if p and p.Character then targetPlayer = p end
            end
            
            if targetPlayer then
                task.spawn(function()
                    SkidFling(targetPlayer)
                end)
            end
        end)
        
        Fluent:Notify({ Title = "Fling Active", Content = "Targeting: " .. tostring(getgenv().NoirConfig.Fling.Mode), Duration = 2 })
    else
        if flingConnection then
            flingConnection:Disconnect()
            flingConnection = nil
        end
        local char = localPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            char.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
        end
        Fluent:Notify({ Title = "Fling Stopped", Content = "Physics reset", Duration = 2 })
    end
end

-- ============================================================================
-- ИНТЕГРАЦИЯ В МЕНЮ FLUENT
-- ============================================================================
pcall(function()
    if not Window then return end
    
    local FlingTab = Window:AddTab({ Title = "Fling", Icon = "wind" })
    _G.NoirFlingTab = FlingTab -- <--- ДОБАВЬ ЭТУ СТРОКУ
    local FlingSec = FlingTab:AddSection("MM2 Fling Controls")
    
    local dropdownRef
    local function getPlayerNames()
        local list = {"All", "Murderer", "Sheriff"}
        for _, p in ipairs(players:GetPlayers()) do
            if p ~= localPlayer then table.insert(list, p.Name) end
        end
        return list
    end
    
    dropdownRef = FlingSec:AddDropdown("FlingModeSelect", {
        Title = "Target / Role",
        Values = getPlayerNames(),
        Default = 1,
        Callback = function(v)
            getgenv().NoirConfig.Fling.Mode = v
        end
    })
    
    FlingSec:AddButton({
        Title = "Refresh Players & Roles",
        Callback = function()
            if dropdownRef then
                dropdownRef:SetValues(getPlayerNames())
                Fluent:Notify({ Title = "Refreshed", Content = "List updated!", Duration = 2 })
            end
        end
    })
    
    FlingSec:AddToggle("FlingToggle", {
        Title = "Enable Moving-Fling",
        Default = false,
        Callback = function(v)
            toggleFling(v)
        end
    })
    
    FlingSec:AddSlider("FlingPowerSlider", {
        Title = "Fling Force Power",
        Default = 10000,
        Min = 3000,
        Max = 30000,
        Rounding = 0,
        Callback = function(v)
            getgenv().NoirConfig.Fling.Power = v
        end
    })
end)
-- ============================================================================
-- NOIR / MM2 INTERNAL SCRIPT - PART 8 (TELEPORT MODULE WITH FIXED SPAWN)
-- ============================================================================

local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local localPlayer = players.LocalPlayer

getgenv().NoirConfig = getgenv().NoirConfig or {}
getgenv().NoirConfig.Teleport = getgenv().NoirConfig.Teleport or {
    TargetPlayer = "",
}

-- Настоящие координаты спавна
local SPAWN_CFRAME = CFrame.new(540.7277221679688, 461.19525146484375, 48.180877685546875)

-- Безопасный телепорт персонажа
local function safeTeleport(cframe)
    local char = localPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        root.CFrame = cframe + Vector3.new(0, 3, 0) -- Небольшой отступ вверх
    end
end

-- Список игроков
local function getPlayerNames()
    local list = {}
    for _, p in ipairs(players:GetPlayers()) do
        if p ~= localPlayer then
            table.insert(list, p.Name)
        end
    end
    return list
end

-- Поиск роли (Murderer / Sheriff)
local function getRoleCharacter(role)
    for _, p in ipairs(players:GetPlayers()) do
        if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local backpack = p:FindFirstChild("Backpack")
            local char = p.Character
            local hasKnife = (char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")))
            local hasGun = (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") or (backpack and (backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver"))))
            if role == "Murderer" and hasKnife then
                return char
            elseif role == "Sheriff" and hasGun and not hasKnife then
                return char
            end
        end
    end
    return nil
end

-- Поиск выпавшего пистолета
local function getDroppedGun()
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("Tool") and (item.Name == "GunDrop" or item.Name == "Gun") and item:FindFirstChild("Handle") then
            return item.Handle.CFrame
        end
    end
    return nil
end

-- ============================================================================
-- ИНТЕГРАЦИЯ В МЕНЮ FLUENT
-- ============================================================================
pcall(function()
    if not Window then return end
    
    local TpTab = Window:AddTab({ Title = "Teleport", Icon = "map-pin" })
    
    -- Секция 1: Точки на карте
    local WorldSec = TpTab:AddSection("World & Map Teleports")
    
    WorldSec:AddButton({
        Title = "TP to Spawn",
        Callback = function()
            safeTeleport(SPAWN_CFRAME)
            Fluent:Notify({ Title = "Teleported", Content = "Moved to Spawn!", Duration = 2 })
        end
    })
    
    WorldSec:AddButton({
        Title = "TP to Dropped Gun",
        Description = "Teleports to Sheriff's fallen gun",
        Callback = function()
            local gunCFrame = getDroppedGun()
            if gunCFrame then
                safeTeleport(gunCFrame)
                Fluent:Notify({ Title = "Gun Found!", Content = "Teleported to dropped gun!", Duration = 2 })
            else
                Fluent:Notify({ Title = "Not Found", Content = "No dropped gun on map!", Duration = 2 })
            end
        end
    })
    
    -- Секция 2: Телепорт к ролям и игрокам
    local PlayerSec = TpTab:AddSection("Player Teleports")
    
    PlayerSec:AddButton({
        Title = "TP to Murderer",
        Callback = function()
            local targetChar = getRoleCharacter("Murderer")
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                safeTeleport(targetChar.HumanoidRootPart.CFrame)
                Fluent:Notify({ Title = "Teleported", Content = "Teleported to Murderer!", Duration = 2 })
            else
                Fluent:Notify({ Title = "Error", Content = "Murderer not found!", Duration = 2 })
            end
        end
    })
    
    PlayerSec:AddButton({
        Title = "TP to Sheriff",
        Callback = function()
            local targetChar = getRoleCharacter("Sheriff")
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                safeTeleport(targetChar.HumanoidRootPart.CFrame)
                Fluent:Notify({ Title = "Teleported", Content = "Teleported to Sheriff!", Duration = 2 })
            else
                Fluent:Notify({ Title = "Error", Content = "Sheriff not found!", Duration = 2 })
            end
        end
    })
    
    local playerDropdownRef
    playerDropdownRef = PlayerSec:AddDropdown("TpTargetSelect", {
        Title = "Select Player",
        Values = getPlayerNames(),
        Default = 1,
        Callback = function(v)
            getgenv().NoirConfig.Teleport.TargetPlayer = v
        end
    })
    
    PlayerSec:AddButton({
        Title = "Refresh Player List",
        Callback = function()
            if playerDropdownRef then
                playerDropdownRef:SetValues(getPlayerNames())
                Fluent:Notify({ Title = "Refreshed", Content = "Player list updated!", Duration = 2 })
            end
        end
    })
    
    PlayerSec:AddButton({
        Title = "TP to Selected Player",
        Callback = function()
            local targetName = getgenv().NoirConfig.Teleport.TargetPlayer
            local targetPlayer = players:FindFirstChild(targetName)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                safeTeleport(targetPlayer.Character.HumanoidRootPart.CFrame)
                Fluent:Notify({ Title = "Teleported", Content = "TP to " .. targetName, Duration = 2 })
            else
                Fluent:Notify({ Title = "Error", Content = "Player character not loaded!", Duration = 2 })
            end
        end
    })
    
    Fluent:Notify({
        Title = "Teleport Tab Ready",
        Content = "Exact spawn coordinates set!",
        Duration = 3
    })
end)
-- ============================================================================
-- PART 10 (FIXED & MONO PATTERNS): COMBAT, SILENT AIM, CAMERA AIM, WALLS
-- ============================================================================

local playersService = game:GetService("Players")
local runService     = game:GetService("RunService")
local userInput      = game:GetService("UserInputService")
local workspaceSvc   = game:GetService("Workspace")
local coreGui        = game:GetService("CoreGui")
local collectionSvc  = game:GetService("CollectionService")
local guiService     = game:GetService("GuiService")
local replicatedSvc  = game:GetService("ReplicatedStorage")

local localPlayer = playersService.LocalPlayer
local camera      = workspaceSvc.CurrentCamera

getgenv().NoirConfig = getgenv().NoirConfig or {}
getgenv().NoirConfig.Combat = getgenv().NoirConfig.Combat or {
    Aimbot = false,
    SilentAim = false,
    GunWalls = false,
    KnifeWalls = false,
    AutoKillAll = false,
    AutoGrabGun = false,
    AutoShootMurderer = false,
    AutoKillSheriff = false,
    ShowFov = false,
    FovRadius = 120,
}

-- ============================================================================
-- 1. ROLE DETECTION (CRC + CollectionService tags + inventory fallback)
-- ============================================================================
local CRC
pcall(function()
    local modules = replicatedSvc:FindFirstChild("Modules")
    if modules then
        local crc = modules:FindFirstChild("CurrentRoundClient")
        if crc then CRC = require(crc) end
    end
end)

local function roundData(plr)
    return CRC and CRC.PlayerData and CRC.PlayerData[plr.Name]
end

local tagOwners = {}
local function refreshTags()
    for _, tag in ipairs({ "Weapon_Gun", "Weapon_Knife" }) do
        tagOwners[tag] = tagOwners[tag] or {}
        table.clear(tagOwners[tag])
        for _, t in ipairs(collectionSvc:GetTagged(tag)) do
            if t.Parent then tagOwners[tag][t.Parent] = true end
        end
    end
end
refreshTags()

local function playerHasTagged(plr, tag)
    local m = tagOwners[tag]
    if not m then return false end
    local ch = plr.Character
    if ch and m[ch] then return true end
    local bp = plr:FindFirstChildOfClass("Backpack")
    if bp and m[bp] then return true end
    return false
end

local function computeRole(plr)
    local d = roundData(plr)
    local r = d and d.Role
    if r == "Murderer" then return "Murderer" end
    if r == "Sheriff" or r == "Hero" then return r end
    if playerHasTagged(plr, "Weapon_Gun") then return "Sheriff" end
    if playerHasTagged(plr, "Weapon_Knife") then return "Murderer" end
    local ch = plr.Character
    if ch then
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") then
                if t.Name == "Gun" or t.Name == "Revolver" or t:FindFirstChild("Shoot") then return "Sheriff" end
                if t.Name == "Knife" or t:FindFirstChild("Events") then return "Murderer" end
            end
        end
    end
    local bp = plr:FindFirstChildOfClass("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                if t.Name == "Gun" or t.Name == "Revolver" then return "Sheriff" end
                if t.Name == "Knife" then return "Murderer" end
            end
        end
    end
    return r or "Innocent"
end

local function myRole() return computeRole(localPlayer) end
local function isGunRole(r) return r == "Sheriff" or r == "Hero" end

local function isEnemyOf(myrole, role)
    if myrole == "Murderer" then return true end
    if isGunRole(myrole) then return role == "Murderer" end
    return false
end

-- ============================================================================
-- 2. UTILITIES
-- ============================================================================
local function getHRP(ch) return ch and ch:FindFirstChild("HumanoidRootPart") end

local function alive(plr)
    local ch = plr.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    return ch and hum and hum.Health > 0 and getHRP(ch) ~= nil
end

local function findWeapon(n)
    local ch = localPlayer.Character
    local bp = localPlayer:FindFirstChildOfClass("Backpack")
    return (ch and ch:FindFirstChild(n)) or (bp and bp:FindFirstChild(n))
end

local function findGun()
    return findWeapon("Gun") or findWeapon("Revolver")
end

local function equip(tool)
    local ch = localPlayer.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if tool and hum and tool.Parent ~= ch then
        pcall(function() hum:EquipTool(tool) end)
    end
end

local function aimPointFor(ch)
    local part = ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("UpperTorso")
        or ch:FindFirstChild("Torso") or ch:FindFirstChild("Head")
    return part and part.Position
end

local function aimCenter()
    local m = userInput:GetMouseLocation()
    return Vector2.new(m.X, m.Y)
end

local function aimRay()
    local c = aimCenter()
    return camera:ViewportPointToRay(c.X, c.Y)
end

local function canAct()
    local ch = localPlayer.Character
    if not ch or not ch.Parent then return false end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0 and getHRP(ch) ~= nil
end

getgenv().NoirSelfTpAt = -10
local function markSelfTP() getgenv().NoirSelfTpAt = os.clock() end

-- ============================================================================
-- 3. FOV TARGET (NO visibility check - silent aim needs walls too)
-- ============================================================================
local function fovTarget()
    local mr = myRole()
    local center = aimCenter()
    local best, bd
    local cfg = getgenv().NoirConfig and getgenv().NoirConfig.Combat
    local fov = cfg and cfg.FovRadius or 120
    
    for _, p in ipairs(playersService:GetPlayers()) do
        if p ~= localPlayer and alive(p) then
            local pr = computeRole(p)
            if isEnemyOf(mr, pr) or pr == "Murderer" then
                local hrp = getHRP(p.Character)
                if hrp then
                    local v, on = camera:WorldToViewportPoint(hrp.Position)
                    if on and v.Z > 0 then
                        local d = (Vector2.new(v.X, v.Y) - center).Magnitude
                        if d <= fov and (not bd or d < bd) then bd, best = d, p end
                    end
                end
            end
        end
    end
    return best
end

-- ============================================================================
-- 4. WALL AIM (raycast against players only)
-- ============================================================================
local WALL_BACKOFF = 0.6
local function wallAimPos()
    local ray = aimRay()
    local origin, dir = ray.Origin, ray.Direction.Unit
    local far = origin + dir * 300
    local chars = {}
    for _, p in ipairs(playersService:GetPlayers()) do
        if p ~= localPlayer and alive(p) and p.Character then
            chars[#chars + 1] = p.Character
        end
    end
    if #chars == 0 then return nil, far end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = chars
    local hit = workspaceSvc:Raycast(origin, dir * 300, params)
    if hit then return hit.Position, far end
    return nil, far
end

-- ============================================================================
-- 5. DROPPED GUN HELPERS
-- ============================================================================
local function findDroppedGun()
    for _, p in ipairs(collectionSvc:GetTagged("GunDrop")) do
        if p:IsA("BasePart") and p:IsDescendantOf(workspaceSvc) then return p end
    end
    local map = collectionSvc:GetTagged("CurrentMap")[1]
    if map then
        local g = map:FindFirstChild("GunDrop")
        if g and g:IsA("BasePart") then return g end
    end
    for _, d in ipairs(workspaceSvc:GetChildren()) do
        if d:IsA("BasePart") and d.Name == "GunDrop" then return d end
        if d:IsA("Model") then
            local g = d:FindFirstChild("GunDrop")
            if g and g:IsA("BasePart") then return g end
        end
    end
    return nil
end

local function touchGun(h)
    local hrp = getHRP(localPlayer.Character)
    if not (hrp and h and h.Parent) then return false end
    if typeof(firetouchinterest) == "function" then
        pcall(function()
            for _ = 1, 4 do
                firetouchinterest(hrp, h, 0)
                firetouchinterest(hrp, h, 1)
            end
        end)
    end
    return findGun() ~= nil
end

-- ============================================================================
-- 6. SNAP SHOT (Mono's preLock/ride-along/postLock pattern)
-- ============================================================================
local SNAP_HEIGHT   = 5
local GUN_COOLDOWN  = 3.25
local snapAt        = -10
local snapping      = false
local shotLag       = 0.08

local function gunOrigin()
    local ch = localPlayer.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local att = hrp:FindFirstChild("GunRaycastAttachment")
    if att then return att.WorldCFrame end
    return hrp.CFrame
end

local function gunBusy(lead)
    if not findGun() then return false end
    if os.clock() - snapAt < GUN_COOLDOWN - (lead or 0) then return true end
    return false
end

local function snapShot(target)
    if snapping then return false end
    if not target then return false end

    local lagT    = math.clamp(shotLag, 0.03, 0.25)
    local preLock = math.clamp(lagT * 1.5, 0.12, 0.35)
    if gunBusy(preLock) then return false end

    local gun = findGun()
    if not gun then return false end
    local shoot = gun:FindFirstChild("Shoot")
    if not shoot then return false end

    local myHrp = getHRP(localPlayer.Character)
    local tChar = target.Character
    local tHrp  = tChar and getHRP(tChar)
    if not (myHrp and tHrp and canAct()) then return false end

    snapping = true
    local home      = myHrp.CFrame
    local homeVel   = myHrp.AssemblyLinearVelocity
    local myHum     = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
    local homeState = myHum and myHum:GetState() or nil
    local fired     = false

    pcall(function()
        equip(gun)
        local deadline = os.clock() + 0.4
        while os.clock() < deadline do
            local h = getHRP(localPlayer.Character)
            if h and h:FindFirstChild("GunRaycastAttachment") then break end
            runService.Heartbeat:Wait()
        end

        markSelfTP()
        local aim = aimPointFor(tChar)
        if not aim then return end

        local side = home.Position - aim
        side = Vector3.new(side.X, 0, side.Z)
        if side.Magnitude < 0.5 then
            local lv = tHrp.CFrame.LookVector
            side = Vector3.new(lv.X, 0, lv.Z)
        end
        if side.Magnitude < 0.5 then side = Vector3.new(0, 0, 1) end
        side = side.Unit

        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances = { tChar, localPlayer.Character }
        if workspaceSvc:Raycast(aim, side * SNAP_HEIGHT, rp) then side = -side end
        local relOff = side * SNAP_HEIGHT

        local chest = aim
        local function lockOn(dur)
            local t0 = os.clock()
            repeat
                local h  = getHRP(localPlayer.Character)
                local tr = target.Character and getHRP(target.Character)
                if not (h and tr) then return false end
                local nxt = aimPointFor(target.Character)
                if nxt and (nxt - chest).Magnitude > 60 then return false end
                chest = nxt or chest
                h.CFrame = CFrame.new(chest + relOff, chest)
                h.AssemblyLinearVelocity  = Vector3.zero
                h.AssemblyAngularVelocity = Vector3.zero
                markSelfTP()
                runService.Heartbeat:Wait()
            until os.clock() - t0 >= dur
            return true
        end

        if not lockOn(preLock) then return end

        local origin = gunOrigin()
        if origin then
            local tr2 = target.Character and getHRP(target.Character)
            local vel = tr2 and tr2.AssemblyLinearVelocity or Vector3.zero
            shoot:FireServer(origin, CFrame.new(chest + vel * lagT))
            snapAt = os.clock()
            fired = true
            lockOn(math.clamp(lagT * 2, 0.16, 0.5))
        end
    end)

    runService.Heartbeat:Wait()
    markSelfTP()
    local h3 = getHRP(localPlayer.Character)
    if h3 then
        h3.CFrame = home
        h3.AssemblyLinearVelocity  = homeVel
        h3.AssemblyAngularVelocity = Vector3.zero
    end
    local hum3 = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum3 then
        if homeState and homeState ~= Enum.HumanoidStateType.Dead then
            pcall(function() hum3:ChangeState(homeState) end)
        else
            pcall(function() hum3:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
    end
    snapping = false
    return fired
end

-- ============================================================================
-- 7. KNIFE KILL
-- ============================================================================
local KNIFE_PARTS = { "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso", "Head" }
local function knifeKill(ev, targetChar)
    if not (ev and targetChar) then return end
    local ht = ev:FindFirstChild("HandleTouched")
    local ks = ev:FindFirstChild("KnifeStabbed")
    if not ht then return end
    if ks then pcall(function() ks:FireServer() end) end
    for _, pn in ipairs(KNIFE_PARTS) do
        local part = targetChar:FindFirstChild(pn)
        if part then ht:FireServer(part) return end
    end
end

-- Возвращаем глобальную функцию для Part 14 (Дрон)
_G.NoirKnifeKill = function(targetChar)
    local knife = findWeapon("Knife")
    if not knife then return end
    equip(knife)
    local ev = knife:FindFirstChild("Events")
    if ev then
        knifeKill(ev, targetChar)
    end
end

-- ============================================================================
-- 8. FOV CIRCLE GUI
-- ============================================================================
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "NoirFovCircleGui"
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true
fovGui.DisplayOrder = 999
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(fovGui)
    elseif protectgui then protectgui(fovGui) end
end)
fovGui.Parent = coreGui

local fovCircleFrame = Instance.new("Frame")
fovCircleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircleFrame.BackgroundTransparency = 1
fovCircleFrame.BorderSizePixel = 0
fovCircleFrame.Visible = false
fovCircleFrame.Parent = fovGui

local fovCorner = Instance.new("UICorner", fovCircleFrame)
fovCorner.CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircleFrame)
fovStroke.Color = Color3.fromRGB(255, 255, 255)
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0

-- ============================================================================
-- 9. HEARTBEAT: track silent aim & wall aim positions
-- ============================================================================
local silentAimPos, wallSnapPos, wallFarPos, myHrpPos

runService.Heartbeat:Connect(function()
    local cfg = getgenv().NoirConfig and getgenv().NoirConfig.Combat
    if not cfg then return end

    if cfg.SilentAim then
        local t = fovTarget()
        silentAimPos = (t and t.Character and aimPointFor(t.Character)) or nil
    else
        silentAimPos = nil
    end

    if cfg.GunWalls or cfg.KnifeWalls then
        wallSnapPos, wallFarPos = wallAimPos()
    else
        wallSnapPos, wallFarPos = nil, nil
    end

    local h = getHRP(localPlayer.Character)
    myHrpPos = h and h.Position or nil
end)

-- ============================================================================
-- 10. RENDERSTEP: FOV circle + camera aimbot
-- ============================================================================
runService.RenderStepped:Connect(function()
    local cfg = getgenv().NoirConfig and getgenv().NoirConfig.Combat
    if not cfg then return end

    if cfg.ShowFov and (cfg.Aimbot or cfg.SilentAim) then
        local m = userInput:GetMouseLocation()
        local inset = guiService:GetGuiInset()
        fovCircleFrame.Size = UDim2.fromOffset(cfg.FovRadius * 2, cfg.FovRadius * 2)
        fovCircleFrame.Position = UDim2.fromOffset(m.X - inset.X, m.Y - inset.Y)
        fovCircleFrame.Visible = true
    else
        fovCircleFrame.Visible = false
    end

    if cfg.Aimbot then
        local t = fovTarget()
        if t and t.Character then
            local th = t.Character:FindFirstChild("Head") or getHRP(t.Character)
            if th then
                camera.CFrame = camera.CFrame:Lerp(
                    CFrame.new(camera.CFrame.Position, th.Position), 0.45)
            end
        end
    end
end)

-- ============================================================================
-- 11. NAME CALL HOOK: silent aim + walls + snapShot trigger
-- ============================================================================
pcall(function()
    if not hookmetamethod then return end
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and method == "FireServer" then
            local nm = ""
            if typeof(self) == "Instance" then
                nm = self.Name
            end
            
            local cfg = getgenv().NoirConfig and getgenv().NoirConfig.Combat
            if not cfg then return oldNamecall(self, ...) end

            if nm == "Shoot" or nm == "KnifeThrown" then
                if nm == "Shoot" and cfg.SilentAim and not snapping and not gunBusy()
                    and os.clock() - snapAt >= GUN_COOLDOWN and isGunRole(myRole()) then
                    local ft = fovTarget()
                    if ft then
                        task.spawn(function() snapShot(ft) end)
                        return
                    end
                end

                local walls = (nm == "Shoot" and cfg.GunWalls)
                    or (nm == "KnifeThrown" and cfg.KnifeWalls)

                local silent = cfg.SilentAim and silentAimPos
                local wallTarget
                if walls then
                    if nm == "Shoot" then wallTarget = wallSnapPos
                    else wallTarget = wallSnapPos or wallFarPos end
                end

                local retarget = silent or wallTarget
                if retarget then
                    local n = select("#", ...)
                    if n >= 2 then
                        local a = { ... }
                        if typeof(a[2]) == "CFrame" then
                            a[2] = CFrame.new(retarget)
                            if walls and myHrpPos and typeof(a[1]) == "CFrame" then
                                local tp = a[2].Position
                                local d  = tp - myHrpPos
                                d = (d.Magnitude > 0.1) and d.Unit or Vector3.new(0, 0, -1)
                                a[1] = CFrame.new(tp - d * WALL_BACKOFF, tp)
                            end
                            return oldNamecall(self, table.unpack(a, 1, n))
                        end
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end))
end)

-- ============================================================================
-- 12. BACKGROUND LOOP: Auto Kill / Auto Grab Gun / Auto Shoot / Auto Kill Sheriff
-- ============================================================================
task.spawn(function()
    while task.wait(0.1) do
        local cfg = getgenv().NoirConfig and getgenv().NoirConfig.Combat
        if cfg then
            local ch  = localPlayer.Character
            local hrp = getHRP(ch)
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                local role = myRole()

                -- Auto Grab Gun
                if cfg.AutoGrabGun and not findGun() and role ~= "Murderer" then
                    local g = findDroppedGun()
                    if g then
                        local back = hrp.CFrame
                        hrp.CFrame = CFrame.new(g.Position + Vector3.new(0, 2, 0))
                        touchGun(g)
                        task.wait(0.05)
                        hrp.CFrame = back
                    end
                end

                -- Auto Kill All (murderer)
                if cfg.AutoKillAll and role == "Murderer" then
                    local knife = findWeapon("Knife")
                    local ev = knife and knife:FindFirstChild("Events")
                    if ev then
                        equip(knife)
                        for _, p in ipairs(playersService:GetPlayers()) do
                            if p ~= localPlayer and alive(p) then
                                knifeKill(ev, p.Character)
                            end
                        end
                    end
                end

                -- Auto Shoot Murderer (sheriff/hero)
                if cfg.AutoShootMurderer and isGunRole(role) then
                    for _, p in ipairs(playersService:GetPlayers()) do
                        if p ~= localPlayer and alive(p) and computeRole(p) == "Murderer" then
                            snapShot(p)
                            break
                        end
                    end
                end

                -- Auto Kill Sheriff (murderer)
                if cfg.AutoKillSheriff and role == "Murderer" then
                    local knife = findWeapon("Knife")
                    local ev = knife and knife:FindFirstChild("Events")
                    if ev then
                        equip(knife)
                        for _, p in ipairs(playersService:GetPlayers()) do
                            if p ~= localPlayer and alive(p) and isGunRole(computeRole(p)) then
                                knifeKill(ev, p.Character)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================================
-- 13. FLUENT UI (Безопасное подключение)
-- ============================================================================
task.spawn(function()
    -- Ждём до 10 секунд, пока загрузится Part 1 с Window
    local timeout = os.clock() + 10
    while not Window and not _G.Window and os.clock() < timeout do
        task.wait(0.3)
    end
    
    local activeWindow = Window or _G.Window
    if not activeWindow then 
        warn("[NOIR] Combat: Не удалось найти Window. Убедись, что Part 1 запущен!")
        return 
    end

    local CombatTab = activeWindow:AddTab({ Title = "Combat", Icon = "crosshair" })
    local Sec = CombatTab:AddSection("Combat & Aiming")

    Sec:AddToggle("AutoKillAllToggle", {
        Title = "Auto Kill All",
        Default = false,
        Callback = function(v) getgenv().NoirConfig.Combat.AutoKillAll = v end
    })

    Sec:AddToggle("AutoGrabGunToggle", {
        Title = "Auto Grab Gun",
        Default = false,
        Callback = function(v) getgenv().NoirConfig.Combat.AutoGrabGun = v end
    })

    Sec:AddToggle("AutoShootMurdToggle", {
        Title = "Auto Shoot Murderer (Sheriff)",
        Default = false,
        Callback = function(v) getgenv().NoirConfig.Combat.AutoShootMurderer = v end
    })

    Sec:AddToggle("AutoKillSheriffToggle", {
        Title = "Auto Kill Sheriff (Murderer)",
        Default = false,
        Callback = function(v) getgenv().NoirConfig.Combat.AutoKillSheriff = v end
    })

    Sec:AddToggle("AimbotToggle", {
        Title = "Camera Aimbot",
        Default = false,
        Callback = function(v) getgenv().NoirConfig.Combat.Aimbot = v end
    })

    Sec:AddToggle("SilentAimToggle", {
        Title = "Silent Aim",
        Default = false,
        Callback = function(v) getgenv().NoirConfig.Combat.SilentAim = v end
    })

    Sec:AddToggle("GunWallsToggle", {
        Title = "Gun Through Walls",
        Default = false,
        Callback = function(v) getgenv().NoirConfig.Combat.GunWalls = v end
    })

    Sec:AddToggle("KnifeWallsToggle", {
        Title = "Knife Through Walls",
        Default = false,
        Callback = function(v) getgenv().NoirConfig.Combat.KnifeWalls = v end
    })

    Sec:AddToggle("ShowFovToggle", {
        Title = "Show FOV Circle",
        Default = false,
        Callback = function(v) getgenv().NoirConfig.Combat.ShowFov = v end
    })

    Sec:AddSlider("FovSlider", {
        Title = "Aimbot FOV Radius",
        Default = 120,
        Min = 40,
        Max = 400,
        Rounding = 0,
        Callback = function(v) getgenv().NoirConfig.Combat.FovRadius = v end
    })

    if Fluent then
        Fluent:Notify({
            Title = "Combat Fixed",
            Content = "Silent aim, camera aimbot & wall aim now using Mono's proven patterns.",
            Duration = 3
        })
    end
end)
-- ============================================================================
-- PART 11: FUN TAB (Equip-Check, Detailed Models, Working SkidFling)
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================================
-- 🟢 ТВОИ ID (ЕСЛИ ЕСТЬ, ОНИ ЗАГРУЗЯТСЯ ВМЕСТО ВСТРОЕННЫХ МОДЕЛЕЙ) 🟢
-- ============================================================================
local CustomModelIDs = {
    ["AK-47"] = "",            -- Вставь ID (только цифры)
    ["AWM"] = "",              -- Вставь ID
    ["Deagle"] = "",           -- Вставь ID
    ["Bazooka"] = "",          -- Вставь ID
    ["Grenade Launcher"] = ""  -- Вставь ID
}

getgenv().NoirConfig = getgenv().NoirConfig or {}
getgenv().NoirConfig.Fun = getgenv().NoirConfig.Fun or {
    SelectedWeapon = "AK-47",
    FlingDuration = 2.0,
    GunsEnabled = false,
}

getgenv().OldPos = nil
getgenv().FPDH = Workspace.FallenPartsDestroyHeight

-- ============================================================================
-- 1. СИСТЕМА ПАТРОНОВ
-- ============================================================================
local WeaponData = {
    ["AK-47"] = { Clip = 30, MaxClip = 30, Reserve = 90, FireRate = 0.1, Sound = "rbxassetid://285234709", IsAuto = true },
    ["AWM"] = { Clip = 5, MaxClip = 5, Reserve = 20, FireRate = 1.5, Sound = "rbxassetid://10209881", IsAuto = false, Zoom = true },
    ["Deagle"] = { Clip = 7, MaxClip = 7, Reserve = 35, FireRate = 0.4, Sound = "rbxassetid://10209810", IsAuto = false },
    ["Bazooka"] = { Clip = 1, MaxClip = 1, Reserve = 5, FireRate = 3.0, Sound = "rbxassetid://504569837", IsAuto = false },
    ["Grenade Launcher"] = { Clip = 1, MaxClip = 1, Reserve = 5, FireRate = 2.0, Sound = "rbxassetid://10209828", IsAuto = false },
}

local CurrentAmmo = 30
local ReserveAmmo = 90
local isReloading = false
local lastShot = 0
local isAiming = false
local currentTool = nil
local flinging = false

-- ============================================================================
-- 2. HUD
-- ============================================================================
local hudGui = Instance.new("ScreenGui")
hudGui.Name = "NoirFunHUD"
hudGui.ResetOnSpawn = false
hudGui.IgnoreGuiInset = true
hudGui.Enabled = false
hudGui.Parent = game:GetService("CoreGui")

local crosshair = Instance.new("Frame")
crosshair.Size = UDim2.fromOffset(40, 40)
crosshair.Position = UDim2.fromScale(0.5, 0.5)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.BackgroundTransparency = 1
crosshair.Parent = hudGui

local chLines = {}
for i = 1, 4 do
    local line = Instance.new("Frame")
    line.Size = UDim2.fromOffset(2, 8)
    line.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    line.BorderSizePixel = 0
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Parent = crosshair
    table.insert(chLines, line)
end

local function updateCrosshair(spread)
    local offset = 6 + spread
    chLines[1].Position = UDim2.new(0.5, 0, 0.5, -offset)
    chLines[2].Position = UDim2.new(0.5, 0, 0.5, offset)
    chLines[3].Position = UDim2.new(0.5, -offset, 0.5, 0)
    chLines[4].Position = UDim2.new(0.5, offset, 0.5, 0)
end
updateCrosshair(0)

local hitmarkerFrame = Instance.new("Frame")
hitmarkerFrame.Size = UDim2.fromOffset(30, 30)
hitmarkerFrame.Position = UDim2.fromScale(0.5, 0.5)
hitmarkerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
hitmarkerFrame.BackgroundTransparency = 1
hitmarkerFrame.Visible = false
hitmarkerFrame.Parent = hudGui

for i = 1, 4 do
    local line = Instance.new("Frame")
    line.Size = UDim2.fromOffset(2, 10)
    line.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    line.BorderSizePixel = 0
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    if i == 1 then line.Position = UDim2.new(0.5, -8, 0.5, -8) line.Rotation = 45
    elseif i == 2 then line.Position = UDim2.new(0.5, 8, 0.5, -8) line.Rotation = -45
    elseif i == 3 then line.Position = UDim2.new(0.5, -8, 0.5, 8) line.Rotation = -45
    elseif i == 4 then line.Position = UDim2.new(0.5, 8, 0.5, 8) line.Rotation = 45
    end
    line.Parent = hitmarkerFrame
end

local killfeedFrame = Instance.new("Frame")
killfeedFrame.Size = UDim2.fromOffset(350, 250)
killfeedFrame.Position = UDim2.new(1, -370, 0, 80)
killfeedFrame.BackgroundTransparency = 1
killfeedFrame.Parent = hudGui

local killfeedLayout = Instance.new("UIListLayout")
killfeedLayout.Padding = UDim.new(0, 4)
killfeedLayout.VerticalAlignment = Enum.VerticalAlignment.Top
killfeedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
killfeedLayout.Parent = killfeedFrame

local function addKillfeed(killerName, victimName, weaponName)
    local feedEntry = Instance.new("Frame")
    feedEntry.Size = UDim2.fromOffset(0, 26)
    feedEntry.BackgroundColor3 = Color3.fromRGB(20, 15, 15)
    feedEntry.BackgroundTransparency = 0.1
    feedEntry.BorderSizePixel = 0
    feedEntry.Parent = killfeedFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(180, 20, 20)
    stroke.Thickness = 1
    stroke.Parent = feedEntry

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 14
    textLabel.RichText = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Center
    textLabel.Parent = feedEntry

    textLabel.Text = string.format(
        "<font color='#FFFFFF'>%s</font> <font color='#AAAAAA'>[%s]</font> <font color='#FF3333'>☠</font> <font color='#3399FF'>%s</font>",
        killerName, weaponName, victimName
    )

    TweenService:Create(feedEntry, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(280, 26)}):Play()
    
    task.delay(5, function() 
        if feedEntry then 
            local tw = TweenService:Create(feedEntry, TweenInfo.new(0.2), {BackgroundTransparency = 1})
            tw:Play()
            tw.Completed:Connect(function() feedEntry:Destroy() end)
        end 
    end)
end

local ammoFrame = Instance.new("Frame")
ammoFrame.Size = UDim2.fromOffset(180, 60)
ammoFrame.Position = UDim2.new(1, -200, 1, -80)
ammoFrame.BackgroundTransparency = 1
ammoFrame.Parent = hudGui

local weaponNameText = Instance.new("TextLabel")
weaponNameText.Size = UDim2.new(1, 0, 0, 20)
weaponNameText.Position = UDim2.new(0, 0, 0, 0)
weaponNameText.BackgroundTransparency = 1
weaponNameText.Font = Enum.Font.GothamBold
weaponNameText.TextSize = 14
weaponNameText.TextColor3 = Color3.fromRGB(200, 200, 200)
weaponNameText.TextXAlignment = Enum.TextXAlignment.Right
weaponNameText.Text = "WEAPON"
weaponNameText.Parent = ammoFrame

local ammoText = Instance.new("TextLabel")
ammoText.Size = UDim2.new(1, 0, 0, 40)
ammoText.Position = UDim2.new(0, 0, 0, 20)
ammoText.BackgroundTransparency = 1
ammoText.Font = Enum.Font.GothamBlack
ammoText.TextSize = 36
ammoText.TextColor3 = Color3.fromRGB(255, 255, 255)
ammoText.TextXAlignment = Enum.TextXAlignment.Right
ammoText.Text = "0 / 0"
ammoText.RichText = true
ammoText.Parent = ammoFrame

local function updateAmmoHUD()
    local color = CurrentAmmo == 0 and "#FF3333" or "#FFFFFF"
    ammoText.Text = string.format("<font color='%s'>%d</font> <font size='18' color='#888888'>/ %d</font>", color, CurrentAmmo, ReserveAmmo)
end

-- ============================================================================
-- 3. ЭФФЕКТЫ
-- ============================================================================
local function createBulletHole(pos, normal)
    local hole = Instance.new("Part")
    hole.Name = "NoirBulletHole"
    hole.Anchored = true
    hole.CanCollide = false
    hole.CanQuery = false
    hole.CanTouch = false
    hole.Transparency = 0
    hole.Color = Color3.fromRGB(10, 10, 10)
    hole.Material = Enum.Material.SmoothPlastic
    hole.Size = Vector3.new(0.2, 0.2, 0.1)
    hole.CFrame = CFrame.lookAt(pos + normal * 0.01, pos + normal * 2) * CFrame.Angles(0, 0, math.random(-180, 180))
    hole.Parent = Workspace

    local mesh = Instance.new("CylinderMesh")
    mesh.Parent = hole
    hole.Orientation = Vector3.new(90, 0, 0)
    game:GetService("Debris"):AddItem(hole, 10)
end

local function createRealisticImpact(pos, normal, color)
    local sparkPart = Instance.new("Part")
    sparkPart.Size = Vector3.new(0.1, 0.1, 0.1)
    sparkPart.Transparency = 1
    sparkPart.Anchored = true
    sparkPart.CFrame = CFrame.new(pos, pos + normal)
    sparkPart.Parent = Workspace
    
    local spark = Instance.new("ParticleEmitter")
    spark.Texture = "rbxassetid://243728166"
    spark.Rate = 0
    spark.Lifetime = NumberRange.new(0.2, 0.5)
    spark.Speed = NumberRange.new(5, 15)
    spark.SpreadAngle = Vector2.new(180, 180)
    spark.Size = NumberSequence.new(0.5, 0)
    spark.Color = ColorSequence.new(Color3.new(1, 0.8, 0))
    spark.Parent = sparkPart
    spark:Emit(10)
    
    local smokePart = Instance.new("Part")
    smokePart.Size = Vector3.new(0.1, 0.1, 0.1)
    smokePart.Transparency = 1
    smokePart.Anchored = true
    smokePart.CFrame = CFrame.new(pos, pos + normal)
    smokePart.Parent = Workspace
    
    local smoke = Instance.new("ParticleEmitter")
    smoke.Texture = "rbxassetid://243728166"
    smoke.Rate = 0
    smoke.Lifetime = NumberRange.new(0.5, 1)
    smoke.Speed = NumberRange.new(1, 3)
    smoke.SpreadAngle = Vector2.new(45, 45)
    smoke.Size = NumberSequence.new(1, 3)
    smoke.Color = ColorSequence.new(color or Color3.new(0.5, 0.5, 0.5))
    smoke.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
    smoke.Parent = smokePart
    smoke:Emit(5)

    createBulletHole(pos, normal)
    game:GetService("Debris"):AddItem(sparkPart, 1)
    game:GetService("Debris"):AddItem(smokePart, 1.5)
end

local function createRealisticMuzzleFlash(handle)
    local flash = Instance.new("Part")
    flash.Size = Vector3.new(0.5, 0.5, 0.5)
    flash.Transparency = 1
    flash.CanCollide = false
    flash.Anchored = true
    flash.CFrame = handle.CFrame * CFrame.new(0, 0, -1)
    flash.Parent = Workspace
    
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 180, 50)
    light.Brightness = 8
    light.Range = 15
    light.Parent = flash
    TweenService:Create(light, TweenInfo.new(0.1), {Brightness = 0}):Play()
    
    local flashFx = Instance.new("ParticleEmitter")
    flashFx.Texture = "rbxassetid://243728166"
    flashFx.Rate = 0
    flashFx.Lifetime = NumberRange.new(0.05, 0.1)
    flashFx.Speed = NumberRange.new(20)
    flashFx.Size = NumberSequence.new(2, 0)
    flashFx.Color = ColorSequence.new(Color3.new(1, 1, 0.5))
    flashFx.Parent = flash
    flashFx:Emit(3)
    
    local smoke = Instance.new("Smoke")
    smoke.Color = Color3.fromRGB(200, 200, 200)
    smoke.Opacity = 0.3
    smoke.RiseVelocity = 5
    smoke.Size = 2
    smoke.Parent = flash
    game:GetService("Debris"):AddItem(flash, 0.2)
end

-- ============================================================================
-- 4. ГЕНЕРАТОР ДЕТАЛИЗИРОВАННЫХ МОДЕЛЕЙ
-- ============================================================================
local function createWeaponModel(weaponName)
    local tool = Instance.new("Tool")
    tool.Name = weaponName
    tool.RequiresHandle = true
    tool.CanBeDropped = false

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.5, 0.5, 1.5)
    handle.Transparency = 1
    handle.CanCollide = false
    handle.Parent = tool

    -- Проверяем ID
    local customId = CustomModelIDs[weaponName]
    if customId and customId ~= "" then
        local success, model = pcall(function()
            local objects = game:GetObjects("rbxassetid://" .. customId)
            if objects and #objects > 0 then return objects[1] end
        end)
        if success and model then
            model.Parent = tool
            local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
            if primary then
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = handle; weld.Part1 = primary; weld.Parent = handle
                primary.CFrame = handle.CFrame
            end
            return tool
        end
    end

    -- Если ID нет, строим красивую модель сами
    local function addPart(name, class, size, color, material, offset, meshType)
        local p = Instance.new(class)
        p.Name = name
        p.Size = size
        p.Color = color
        p.Material = material or Enum.Material.SmoothPlastic
        p.CanCollide = false
        p.Massless = true
        p.Parent = tool
        
        if meshType then
            local mesh = Instance.new(meshType)
            mesh.Parent = p
        end

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = handle; weld.Part1 = p; weld.Parent = handle
        p.CFrame = handle.CFrame * offset
        return p
    end

    if weaponName == "AK-47" then
        -- Корпус (блок)
        addPart("Receiver", "Part", Vector3.new(0.4, 0.4, 1.6), Color3.fromRGB(30, 30, 30), Enum.Material.Metal, CFrame.new(0, 0, 0))
        -- Ствол (цилиндр)
        local barrel = addPart("Barrel", "Part", Vector3.new(0.15, 1.5, 0.15), Color3.fromRGB(20, 20, 20), Enum.Material.Metal, CFrame.new(0, 0.1, -1.5), "CylinderMesh")
        barrel.Orientation = Vector3.new(90, 0, 0)
        -- Приклад (клин)
        addPart("Stock", "WedgePart", Vector3.new(0.35, 0.4, 1.2), Color3.fromRGB(100, 60, 30), Enum.Material.Wood, CFrame.new(0, -0.1, 1.2) * CFrame.Angles(0, math.rad(180), math.rad(-10)))
        -- Рукоятка (клин)
        addPart("Grip", "WedgePart", Vector3.new(0.2, 0.5, 0.4), Color3.fromRGB(100, 60, 30), Enum.Material.Wood, CFrame.new(0, -0.4, 0.3) * CFrame.Angles(0, math.rad(180), 0))
        -- Магазин (клин)
        addPart("Mag", "WedgePart", Vector3.new(0.3, 0.8, 0.4), Color3.fromRGB(40, 40, 40), Enum.Material.Metal, CFrame.new(0, -0.5, -0.1) * CFrame.Angles(math.rad(20), 0, math.rad(180)))
    elseif weaponName == "AWM" then
        addPart("Body", "Part", Vector3.new(0.35, 0.4, 2.2), Color3.fromRGB(40, 60, 40), Enum.Material.Plastic, CFrame.new(0, 0, 0))
        local barrel = addPart("Barrel", "Part", Vector3.new(0.15, 2, 0.15), Color3.fromRGB(30, 30, 30), Enum.Material.Metal, CFrame.new(0, 0.1, -2), "CylinderMesh")
        barrel.Orientation = Vector3.new(90, 0, 0)
        local scope = addPart("Scope", "Part", Vector3.new(0.2, 0.8, 0.2), Color3.fromRGB(20, 20, 20), Enum.Material.Metal, CFrame.new(0, 0.4, 0), "CylinderMesh")
        scope.Orientation = Vector3.new(90, 0, 0)
        addPart("ScopeLens", "Part", Vector3.new(0.18, 0.05, 0.18), Color3.fromRGB(100, 200, 255), Enum.Material.Glass, CFrame.new(0, 0.4, -0.4), "CylinderMesh").Orientation = Vector3.new(90, 0, 0)
        addPart("Stock", "WedgePart", Vector3.new(0.3, 0.5, 1.2), Color3.fromRGB(40, 60, 40), Enum.Material.Plastic, CFrame.new(0, -0.1, 1.3) * CFrame.Angles(0, math.rad(180), 0))
    elseif weaponName == "Deagle" then
        addPart("Slide", "Part", Vector3.new(0.25, 0.4, 1.3), Color3.fromRGB(180, 180, 180), Enum.Material.Metal, CFrame.new(0, 0.1, 0))
        addPart("Grip", "WedgePart", Vector3.new(0.2, 0.6, 0.4), Color3.fromRGB(40, 40, 40), Enum.Material.Plastic, CFrame.new(0, -0.4, 0.3) * CFrame.Angles(0, math.rad(180), math.rad(-15)))
    elseif weaponName == "Bazooka" or weaponName == "Grenade Launcher" then
        local tube = addPart("Tube", "Part", Vector3.new(0.6, 3.5, 0.6), Color3.fromRGB(60, 80, 60), Enum.Material.Metal, CFrame.new(0, 0, 0), "CylinderMesh")
        tube.Orientation = Vector3.new(90, 0, 0)
        addPart("Warhead", "Part", Vector3.new(0.7, 0.5, 0.7), Color3.fromRGB(200, 50, 50), Enum.Material.Metal, CFrame.new(0, 0, -2), "CylinderMesh").Orientation = Vector3.new(90, 0, 0)
        addPart("Grip", "WedgePart", Vector3.new(0.2, 0.6, 0.3), Color3.fromRGB(20, 20, 20), Enum.Material.Plastic, CFrame.new(0, -0.5, 1) * CFrame.Angles(0, math.rad(180), 0))
        addPart("Sight", "Part", Vector3.new(0.1, 0.3, 0.2), Color3.fromRGB(20, 20, 20), Enum.Material.Metal, CFrame.new(0, 0.5, 0))
    end

    return tool
end

local function equipWeapon(weaponName)
    if currentTool then currentTool:Destroy() end
    for _, child in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if WeaponData[child.Name] then child:Destroy() end
    end
    for _, child in ipairs(LocalPlayer.Character:GetChildren()) do
        if WeaponData[child.Name] then child:Destroy() end
    end
    
    local data = WeaponData[weaponName]
    if not data then return end
    
    CurrentAmmo = data.Clip
    ReserveAmmo = data.Reserve
    updateAmmoHUD()
    
    weaponNameText.Text = string.upper(weaponName)

    local tool = createWeaponModel(weaponName)
    tool.Parent = LocalPlayer.Backpack
    currentTool = tool
end

-- ============================================================================
-- 5. ФЛИНГ (ТОЧНАЯ КОПИЯ ИЗ ТВОЕГО СКРИПТА)
-- ============================================================================
local function SkidFling(TargetPlayer)
    if flinging or not TargetPlayer then return end
    flinging = true

    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then flinging = false return end
    
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")
    
    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        
        if THumanoid and THumanoid.Sit then
            flinging = false
            return
        end
        
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then flinging = false return end
        
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        
        local SFBasePart = function(BasePart)
            local TimeToWait = getgenv().NoirConfig.Fun.FlingDuration or 2.0
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until Time + TimeToWait < tick() or not flinging
        end
        
        Workspace.FallenPartsDestroyHeight = 0/0
        
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        
        if TRootPart then
            SFBasePart(TRootPart)
        elseif THead then
            SFBasePart(THead)
        elseif Handle then
            SFBasePart(Handle)
        end
        
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        
        if getgenv().OldPos then
            local rt0 = tick()
            repeat
                if RootPart and Humanoid and Character then
                    RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                    Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                    Humanoid:ChangeState("GettingUp")
                    for _, part in pairs(Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                        end
                    end
                end
                task.wait()
            until (not RootPart) or (RootPart.Position - getgenv().OldPos.p).Magnitude < 25 or tick() - rt0 > 3
            Workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
    end
    flinging = false
end

-- 👇 ВОТ ЭТА СТРОЧКА 👇
_G.NoirSkidFling = SkidFling

-- ============================================================================
-- 6. СТРЕЛЬБА (С ПРОВЕРКОЙ НА ЭКИПИРОВКУ)
-- ============================================================================
local function reloadWeapon()
    local data = WeaponData[getgenv().NoirConfig.Fun.SelectedWeapon]
    if not data or isReloading then return end
    if CurrentAmmo >= data.MaxClip or ReserveAmmo <= 0 then return end
    
    isReloading = true
    ammoText.Text = "RELOADING..."
    task.wait(1.5)
    
    local needed = data.MaxClip - CurrentAmmo
    local toLoad = math.min(needed, ReserveAmmo)
    CurrentAmmo = CurrentAmmo + toLoad
    ReserveAmmo = ReserveAmmo - toLoad
    
    updateAmmoHUD()
    isReloading = false
end

local function fireWeapon()
    if not getgenv().NoirConfig.Fun.GunsEnabled then return end
    
    -- ❗ ПРОВЕРКА: ОРУЖИЕ ДОЛЖНО БЫТЬ В РУКАХ ❗
    if not currentTool or currentTool.Parent ~= LocalPlayer.Character then
        return 
    end

    local weaponName = getgenv().NoirConfig.Fun.SelectedWeapon
    local data = WeaponData[weaponName]
    
    if not data or isReloading then return end
    if tick() - lastShot < data.FireRate then return end
    if CurrentAmmo <= 0 then return end
    
    lastShot = tick()
    CurrentAmmo = CurrentAmmo - 1
    updateAmmoHUD()

    updateCrosshair(8)
    task.delay(0.15, function() updateCrosshair(0) end)

    local sound = Instance.new("Sound")
    sound.SoundId = data.Sound
    sound.Volume = 1
    sound.Parent = LocalPlayer.Character.HumanoidRootPart
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 1)

    if currentTool then
        createRealisticMuzzleFlash(currentTool.Handle)
    end

    local mouse = LocalPlayer:GetMouse()
    local ray = mouse.UnitRay
    local origin = ray.Origin
    local direction = ray.Direction * 1000
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local result = Workspace:Raycast(origin, direction, rayParams)
    
    if result and result.Instance then
        local hitPart = result.Instance
        local hitChar = hitPart:FindFirstAncestorOfClass("Model")
        local humanoid = hitChar and hitChar:FindFirstChildOfClass("Humanoid")
        
        if not hitChar then
            -- Если пуля попала в шляпу/аксессуар, ищем модель игрока
            local parent = hitPart
            while parent and parent ~= Workspace do
                if parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then
                    hitChar = parent
                    break
                end
                parent = parent.Parent
            end
        end

        local hitColor = hitPart.Color
        createRealisticImpact(result.Position, result.Normal, hitColor)
        
        if hitChar and humanoid and humanoid.Health > 0 and hitChar ~= LocalPlayer.Character then
            local targetPlayer = Players:GetPlayerFromCharacter(hitChar)
            if targetPlayer then
                task.spawn(function() SkidFling(targetPlayer) end)
                hitmarkerFrame.Visible = true
                task.delay(0.1, function() hitmarkerFrame.Visible = false end)
                addKillfeed(LocalPlayer.Name, targetPlayer.Name, weaponName)
            end
        end
    end
end

-- ============================================================================
-- 7. ВВОД
-- ============================================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not getgenv().NoirConfig.Fun.GunsEnabled then return end
    if input.KeyCode == Enum.KeyCode.R then
        reloadWeapon()
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        if getgenv().NoirConfig.Fun.SelectedWeapon == "AWM" then
            isAiming = not isAiming
            TweenService:Create(Camera, TweenInfo.new(0.2), {FieldOfView = isAiming and 30 or 70}):Play()
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not getgenv().NoirConfig.Fun.GunsEnabled then return end
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local weaponName = getgenv().NoirConfig.Fun.SelectedWeapon
        local data = WeaponData[weaponName]
        if data and data.IsAuto then fireWeapon() end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not getgenv().NoirConfig.Fun.GunsEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local weaponName = getgenv().NoirConfig.Fun.SelectedWeapon
        local data = WeaponData[weaponName]
        if data and not data.IsAuto then fireWeapon() end
    end
end)

-- ============================================================================
-- 8. ИНТЕГРАЦИЯ В МЕНЮ
-- ============================================================================
task.spawn(function()
    repeat task.wait(0.3) until Window or _G.Window
    local activeWindow = Window or _G.Window
    
    if activeWindow then
        local FunTab = activeWindow:AddTab({ Title = "Fun", Icon = "gamepad-2" })
        _G.NoirFunTab = FunTab -- <--- ДОБАВЬ ЭТУ СТРОКУ
        local Sec = FunTab:AddSection("CS:GO Style Weapons")
        
        Sec:AddToggle("GunsMasterToggle", {
            Title = "Enable Guns & HUD",
            Default = false,
            Callback = function(v)
                getgenv().NoirConfig.Fun.GunsEnabled = v
                hudGui.Enabled = v
                if v then
                    equipWeapon(getgenv().NoirConfig.Fun.SelectedWeapon)
                else
                    if currentTool then currentTool:Destroy() end
                    for _, child in ipairs(LocalPlayer.Backpack:GetChildren()) do
                        if WeaponData[child.Name] then child:Destroy() end
                    end
                    for _, child in ipairs(LocalPlayer.Character:GetChildren()) do
                        if WeaponData[child.Name] then child:Destroy() end
                    end
                    Camera.FieldOfView = 70
                end
            end
        })

        Sec:AddDropdown("WeaponSelect", {
            Title = "Select Weapon",
            Values = {"AK-47", "AWM", "Deagle", "Bazooka", "Grenade Launcher"},
            Default = 1,
            Callback = function(v)
                getgenv().NoirConfig.Fun.SelectedWeapon = v
                if getgenv().NoirConfig.Fun.GunsEnabled then equipWeapon(v) end
            end
        })
        
        Sec:AddSlider("FlingDuration", {
            Title = "Fling Duration (sec)",
            Default = 2.0,
            Min = 0.5,
            Max = 5,
            Rounding = 1,
            Callback = function(v) getgenv().NoirConfig.Fun.FlingDuration = v end
        })

        Sec:AddButton({
            Title = "Re-equip Weapon",
            Callback = function()
                if getgenv().NoirConfig.Fun.GunsEnabled then equipWeapon(getgenv().NoirConfig.Fun.SelectedWeapon) end
            end
        })
    end
end)
-- ============================================================================
-- PART 12: ANTI-FLING & MAP CHANGER
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

getgenv().NoirConfig = getgenv().NoirConfig or {}
getgenv().NoirConfig.AntiFling = getgenv().NoirConfig.AntiFling or {
    Enabled = false,
}
getgenv().NoirConfig.Map = getgenv().NoirConfig.Map or {
    Name = "NoirCustomMap",
    Position = Vector3.new(0, 500, 0), 
}

-- ============================================================================
-- 1. ANTI-FLING LOGIC
-- ============================================================================
local defaultFPDH = Workspace.FallenPartsDestroyHeight
local lastGoodCFrame = nil

RunService.Stepped:Connect(function()
    if not getgenv().NoirConfig.AntiFling.Enabled then return end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end

    if not lastGoodCFrame then
        lastGoodCFrame = hrp.CFrame
    end

    for _, v in ipairs(hrp:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyGyro") or v:IsA("BodyForce") then
            v:Destroy()
        end
    end

    local vel = hrp.AssemblyLinearVelocity
    local rot = hrp.AssemblyAngularVelocity

    if vel.Magnitude > 100 or rot.Magnitude > 50 then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = lastGoodCFrame
        
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            hum.PlatformStand = false
        end)
    else
        lastGoodCFrame = hrp.CFrame
    end

    if Workspace.FallenPartsDestroyHeight ~= Workspace.FallenPartsDestroyHeight then
        Workspace.FallenPartsDestroyHeight = defaultFPDH
    end
end)

-- ============================================================================
-- 2. MAP CHANGER LOGIC
-- ============================================================================
local function CreateMap()
    local mapName = getgenv().NoirConfig.Map.Name
    local centerPos = getgenv().NoirConfig.Map.Position

    local oldMap = Workspace:FindFirstChild(mapName)
    if oldMap then oldMap:Destroy() end

    local mapFolder = Instance.new("Folder")
    mapFolder.Name = mapName
    mapFolder.Parent = Workspace

    local base = Instance.new("Part")
    base.Name = "Baseplate"
    base.Size = Vector3.new(200, 5, 200)
    base.Position = centerPos
    base.Anchored = true
    base.Material = Enum.Material.Slate
    base.Color = Color3.fromRGB(40, 40, 40)
    base.Parent = mapFolder

    local function makeWall(offset, size)
        local w = Instance.new("Part")
        w.Size = size
        w.Position = centerPos + offset
        w.Anchored = true
        w.Material = Enum.Material.Brick
        w.Color = Color3.fromRGB(80, 80, 80)
        w.Parent = mapFolder
    end

    makeWall(Vector3.new(0, 10, -100), Vector3.new(200, 20, 5))
    makeWall(Vector3.new(0, 10, 100), Vector3.new(200, 20, 5))
    makeWall(Vector3.new(-100, 10, 0), Vector3.new(5, 20, 200))
    makeWall(Vector3.new(100, 10, 0), Vector3.new(5, 20, 200))

    local spawn = Instance.new("SpawnLocation")
    spawn.Position = centerPos + Vector3.new(0, 3, 0)
    spawn.Anchored = true
    spawn.Size = Vector3.new(10, 1, 10)
    spawn.Material = Enum.Material.Neon
    spawn.Color = Color3.fromRGB(0, 150, 255)
    spawn.Parent = mapFolder

    return mapFolder
end

local function TeleportToMap()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local map = Workspace:FindFirstChild(getgenv().NoirConfig.Map.Name)
    if not map then
        map = CreateMap()
    end

    hrp.CFrame = CFrame.new(getgenv().NoirConfig.Map.Position + Vector3.new(0, 8, 0))
    Fluent:Notify({ Title = "Map Changer", Content = "Teleported to custom map!", Duration = 2 })
end

local function RemoveMap()
    local map = Workspace:FindFirstChild(getgenv().NoirConfig.Map.Name)
    if map then
        map:Destroy()
        Fluent:Notify({ Title = "Map Changer", Content = "Map removed.", Duration = 2 })
    end
end

-- ============================================================================
-- 3. ИНТЕГРАЦИЯ В МЕНЮ (БЕЗ СОЗДАНИЯ ВКЛАДОК)
-- ============================================================================
task.wait(1) -- Ждем, пока Part 7 и 11 создадут вкладки

pcall(function()
    -- Берем сохраненные вкладки
    local FlingTab = _G.NoirFlingTab
    local FunTab = _G.NoirFunTab

    -- Добавляем Anti-Fling во вкладку Fling
    if FlingTab then
        local AntiSec = FlingTab:AddSection("Protection")
        
        AntiSec:AddToggle("AntiFlingToggle", {
            Title = "Enable Anti-Fling",
            Default = false,
            Callback = function(v)
                getgenv().NoirConfig.AntiFling.Enabled = v
                if v then
                    lastGoodCFrame = nil
                    Fluent:Notify({ Title = "Anti-Fling", Content = "Protection enabled", Duration = 2 })
                else
                    Fluent:Notify({ Title = "Anti-Fling", Content = "Protection disabled", Duration = 2 })
                end
            end
        })
    end

    -- Добавляем Map Changer во вкладку Fun
    if FunTab then
        local MapSec = FunTab:AddSection("Custom Map Changer")
        
        MapSec:AddButton({
            Title = "Create & Teleport to Map",
            Callback = function()
                CreateMap()
                task.wait(0.2)
                TeleportToMap()
            end
        })

        MapSec:AddButton({
            Title = "Remove Map",
            Callback = function()
                RemoveMap()
            end
        })
        
        MapSec:AddSlider("MapHeight", {
            Title = "Map Height (Y)",
            Default = 500,
            Min = 100,
            Max = 2000,
            Rounding = 0,
            Callback = function(v)
                getgenv().NoirConfig.Map.Position = Vector3.new(0, v, 0)
            end
        })
    end
end)
-- ============================================================================
-- PART 13: ASSET MAP LOADER (Ввод ID карты)
-- ============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

getgenv().NoirConfig = getgenv().NoirConfig or {}
getgenv().NoirConfig.AssetMap = getgenv().NoirConfig.AssetMap or {
    CurrentMapFolder = nil,
    Height = 500, -- Высота, на которую загрузится карта
}

local function clearLoadedMap()
    if getgenv().NoirConfig.AssetMap.CurrentMapFolder then
        getgenv().NoirConfig.AssetMap.CurrentMapFolder:Destroy()
        getgenv().NoirConfig.AssetMap.CurrentMapFolder = nil
        Fluent:Notify({ Title = "Map Loader", Content = "Карта удалена", Duration = 2 })
    end
end

local function loadAssetMap(assetId)
    local cleanId = tostring(assetId):gsub("%D", "")
    if cleanId == "" then
        Fluent:Notify({ Title = "Ошибка", Content = "Введите корректный ID", Duration = 2 })
        return
    end

    clearLoadedMap()

    local success, result = pcall(function()
        -- Загружаем ассет напрямую (обходит блокировки InsertService)
        local objects = game:GetObjects("rbxassetid://" .. cleanId)
        if not objects or #objects == 0 then return nil end
        return objects[1]
    end)

    if not success or not result then
        Fluent:Notify({ Title = "Ошибка", Content = "Не удалось загрузить карту. Возможно, ID неверный или ассет закрыт.", Duration = 4 })
        return
    end

    local mapModel = result
    local mapFolder = Instance.new("Folder")
    mapFolder.Name = "NoirAssetMap_" .. cleanId
    mapFolder.Parent = Workspace
    getgenv().NoirConfig.AssetMap.CurrentMapFolder = mapFolder

    -- Если загрузился просто 1 парт, оборачиваем его в модель
    if mapModel:IsA("BasePart") then
        local newModel = Instance.new("Model")
        mapModel.Parent = newModel
        mapModel = newModel
    end

    mapModel.Parent = mapFolder

    -- Перемещаем и фиксируем все части
    local heightOffset = getgenv().NoirConfig.AssetMap.Height
    local pivot = mapModel:GetPivot() or CFrame.new()
    
    for _, descendant in ipairs(mapModel:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.Anchored = true
            descendant.CanCollide = true
            -- Сдвигаем на нужную высоту
            descendant.CFrame = CFrame.new(0, heightOffset, 0) + (descendant.CFrame.Position - pivot.Position)
        end
    end

    Fluent:Notify({ Title = "Map Loader", Content = "Карта успешно загружена! Телепортация...", Duration = 3 })

    -- Телепортируем игрока на карту
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(Vector3.new(0, heightOffset + 10, 0))
    end
end

-- ============================================================================
-- ИНТЕГРАЦИЯ В МЕНЮ (Обращаемся к вкладке из Part 11)
-- ============================================================================
task.wait(1) -- Ждем инициализации меню

pcall(function()
    local FunTab = _G.NoirFunTab
    if FunTab then
        local AssetMapSec = FunTab:AddSection("Asset Map Loader")
        
        AssetMapSec:AddInput("MapAssetIdInput", {
            Title = "Map Asset ID",
            Default = "",
            Placeholder = "Введите ID модели (только цифры)...",
            Finished = true, -- Вызывается, когда игрок нажимает Enter
            Callback = function(text)
                -- Сохраняем ID, чтобы можно было нажать кнопку
                getgenv().NoirConfig.AssetMap.PendingID = text
            end
        })

        AssetMapSec:AddButton({
            Title = "Load & Teleport to Map",
            Description = "Загружает карту по введенному выше ID",
            Callback = function()
                local id = getgenv().NoirConfig.AssetMap.PendingID
                if id and id ~= "" then
                    loadAssetMap(id)
                else
                    Fluent:Notify({ Title = "Ошибка", Content = "Сначала введите ID в поле выше", Duration = 2 })
                end
            end
        })

        AssetMapSec:AddSlider("AssetMapHeight", {
            Title = "Map Height (Y)",
            Default = 500,
            Min = 100,
            Max = 3000,
            Rounding = 0,
            Callback = function(v)
                getgenv().NoirConfig.AssetMap.Height = v
            end
        })

        AssetMapSec:AddButton({
            Title = "Remove Loaded Map",
            Description = "Удаляет загруженную карту из мира",
            Callback = function()
                clearLoadedMap()
            end
        })
    end
end)
-- ============================================================================
-- PART 14: KAMIKAZE DRONE SYSTEM (Fixed Action Trigger)
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

getgenv().NoirConfig = getgenv().NoirConfig or {}
getgenv().NoirConfig.Drone = getgenv().NoirConfig.Drone or {
    Mode = "Fling",
    Speed = 80,
    AssetID = "", 
    CollisionEnabled = false,
    TrailEnabled = true,
    TrailColor = Color3.fromRGB(0, 255, 255)
}

local DroneActive = false
local DroneModel = nil
local SavedCFrame = nil
local SavedTransparency = {}
local CurrentTrail = nil

local currentPitch = 0
local currentRoll = 0

-- ============================================================================
-- 1. СОЗДАНИЕ МОДЕЛИ (Все части Anchored)
-- ============================================================================
local function createDroneModel()
    local model = Instance.new("Model")
    model.Name = "NoirDrone"
    
    local core = Instance.new("Part")
    core.Name = "Core"
    core.Size = Vector3.new(1, 1, 1)
    core.Transparency = 1
    core.Anchored = true
    core.CanCollide = false
    core.Parent = model
    model.PrimaryPart = core
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        core.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
    end

    local id = tostring(getgenv().NoirConfig.Drone.AssetID):gsub("%D", "")
    local success = false
    
    if id ~= "" then
        local ok, objects = pcall(function()
            return game:GetObjects("rbxassetid://" .. id)
        end)
        
        if ok and objects and #objects > 0 then
            local customModel = objects[1]
            if customModel:IsA("BasePart") then
                local m = Instance.new("Model")
                customModel.Parent = m
                customModel = m
            end
            
            customModel.Parent = model
            
            -- Ставим модель ровно на ядро
            customModel:PivotTo(core.CFrame)
            
            for _, p in ipairs(customModel:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Anchored = true
                    p.CanCollide = getgenv().NoirConfig.Drone.CollisionEnabled
                end
            end
            
            success = true
        end
    end

    if not success then
        local base = Instance.new("Part")
        base.Name = "FallbackBase"
        base.Size = Vector3.new(2, 1, 3)
        base.Color = Color3.fromRGB(0, 255, 255)
        base.Material = Enum.Material.Neon
        base.Anchored = true
        base.CanCollide = getgenv().NoirConfig.Drone.CollisionEnabled
        base.Parent = model
        base.CFrame = core.CFrame
    end

    if getgenv().NoirConfig.Drone.TrailEnabled then
        local a0 = Instance.new("Attachment", core) a0.Position = Vector3.new(0, 0, 1)
        local a1 = Instance.new("Attachment", core) a1.Position = Vector3.new(0, 0, -1)
        local trail = Instance.new("Trail")
        trail.Attachment0 = a0
        trail.Attachment1 = a1
        trail.Lifetime = 0.5
        trail.Color = ColorSequence.new(getgenv().NoirConfig.Drone.TrailColor)
        trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
        trail.Parent = core
        CurrentTrail = trail
    end

    model.Parent = Workspace
    return model
end

-- ============================================================================
-- 2. SIGNAL LOST
-- ============================================================================
local blackoutGui = Instance.new("ScreenGui")
blackoutGui.Name = "NoirDroneBlackout"
blackoutGui.ResetOnSpawn = false
blackoutGui.IgnoreGuiInset = true
blackoutGui.Enabled = false
blackoutGui.Parent = game:GetService("CoreGui")

local blackFrame = Instance.new("Frame")
blackFrame.Size = UDim2.fromScale(1, 1)
blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
blackFrame.BackgroundTransparency = 1
blackFrame.Parent = blackoutGui

local staticLabel = Instance.new("ImageLabel")
staticLabel.Size = UDim2.fromScale(1, 1)
staticLabel.BackgroundTransparency = 1
staticLabel.Image = "rbxassetid://1316325531"
staticLabel.ImageTransparency = 1
staticLabel.ScaleType = Enum.ScaleType.Tile
staticLabel.TileSize = UDim2.new(0, 150, 0, 150)
staticLabel.Parent = blackFrame

local signalLostText = Instance.new("TextLabel")
signalLostText.Size = UDim2.fromScale(1, 1)
signalLostText.BackgroundTransparency = 1
signalLostText.Text = "SIGNAL LOST"
signalLostText.Font = Enum.Font.Code
signalLostText.TextSize = 40
signalLostText.TextColor3 = Color3.fromRGB(255, 50, 50)
signalLostText.TextStrokeTransparency = 0
signalLostText.TextTransparency = 1
signalLostText.Parent = blackFrame

local function playSignalLostEffect()
    blackoutGui.Enabled = true
    TweenService:Create(blackFrame, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
    TweenService:Create(signalLostText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()

    local t0 = tick()
    while tick() - t0 < 2.5 do
        staticLabel.Position = UDim2.fromScale(math.random(-10, 10) / 100, math.random(-10, 10) / 100)
        staticLabel.ImageTransparency = math.random(30, 70) / 100
        signalLostText.TextTransparency = math.random(10, 40) / 100
        
        if math.random(1, 10) == 1 then
            signalLostText.Position = UDim2.fromScale(math.random(-2, 2) / 100, math.random(-2, 2) / 100)
        else
            signalLostText.Position = UDim2.fromScale(0, 0)
        end
        RunService.Heartbeat:Wait()
    end

    TweenService:Create(signalLostText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(staticLabel, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
    TweenService:Create(blackFrame, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
    task.wait(1)
    blackoutGui.Enabled = false
end

-- ============================================================================
-- 3. ЛОГИКА
-- ============================================================================
local function createExplosion(pos)
    local explodePart = Instance.new("Part")
    explodePart.Size = Vector3.new(1, 1, 1)
    explodePart.Transparency = 1
    explodePart.Anchored = true
    explodePart.Position = pos
    explodePart.Parent = Workspace

    local light = Instance.new("PointLight", explodePart)
    light.Color = Color3.fromRGB(255, 100, 0)
    light.Brightness = 10
    light.Range = 30
    TweenService:Create(light, TweenInfo.new(0.5), {Brightness = 0}):Play()

    local emit = Instance.new("ParticleEmitter", explodePart)
    emit.Texture = "rbxassetid://243728166"
    emit.Rate = 0
    emit.Speed = NumberRange.new(20, 50)
    emit.Lifetime = NumberRange.new(0.5, 1)
    emit.Size = NumberSequence.new(5, 0)
    emit.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 50, 0))
    emit:Emit(100)

    game:GetService("Debris"):AddItem(explodePart, 1)
end

-- 🟢 НОВАЯ ФУНКЦИЯ ЗАВЕРШЕНИЯ (Сначала возвращаем игрока, потом флингаем)
local function EndDroneFling(targetPlayer)
    if not DroneActive then return end
    DroneActive = false
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    -- Возвращаем игрока и видимость
    if char and hrp then
        if hum then 
            hum.PlatformStand = false 
            hum.WalkSpeed = 16 
        end
        for part, trans in pairs(SavedTransparency) do
            if part and part.Parent then part.Transparency = trans end
        end
        SavedTransparency = {}
        hrp.Anchored = false
        hrp.CFrame = SavedCFrame
        Camera.CameraSubject = hum
    end

    -- Взрываем дрон
    if DroneModel then
        if DroneModel.PrimaryPart then createExplosion(DroneModel.PrimaryPart.Position) end
        DroneModel:Destroy() 
    end

    -- Проверяем на маньяка
    local isMurderer = false
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if (backpack and backpack:FindFirstChild("Knife")) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife")) then
        isMurderer = true
    end

    -- Запускаем убийство или флинг
    if getgenv().NoirConfig.Drone.Mode == "Murder" and isMurderer and _G.NoirKnifeKill then
        task.spawn(function() _G.NoirKnifeKill(targetPlayer.Character) end)
    else
        if _G.NoirSkidFling then
            task.spawn(function() _G.NoirSkidFling(targetPlayer) end)
        end
    end

    -- Включаем черный экран (он перекроет телепорт и флинг)
    playSignalLostEffect() 
end

local function StopDrone(exploded)
    if not DroneActive then return end
    DroneActive = false
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if exploded then
        if DroneModel and DroneModel.PrimaryPart then createExplosion(DroneModel.PrimaryPart.Position) end
        if DroneModel then DroneModel:Destroy() end
        playSignalLostEffect()
    else
        if DroneModel then DroneModel:Destroy() end
    end

    if char and hrp then
        if hum then 
            hum.PlatformStand = false 
            hum.WalkSpeed = 16 
        end
        for part, trans in pairs(SavedTransparency) do
            if part and part.Parent then part.Transparency = trans end
        end
        SavedTransparency = {}
        hrp.Anchored = false
        hrp.CFrame = SavedCFrame
    end
    
    Camera.CameraSubject = hum
    CurrentTrail = nil
end

local function StartDrone()
    if DroneActive then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end

    DroneActive = true
    SavedCFrame = hrp.CFrame
    
    SavedTransparency = {}
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            SavedTransparency[part] = part.Transparency
            part.Transparency = 1
        end
    end
    hrp.Anchored = true
    hum.PlatformStand = true
    hum.WalkSpeed = 0
    
    DroneModel = createDroneModel()
    currentPitch = 0
    currentRoll = 0
    
    if DroneModel.PrimaryPart then 
        Camera.CameraSubject = DroneModel.PrimaryPart 
    end
    
    Fluent:Notify({ Title = "Drone Launched", Content = "WASD - Управление. Врежься в игрока!", Duration = 3 })
end

-- ============================================================================
-- 4. УПРАВЛЕНИЕ И КОЛЛИЗИЯ
-- ============================================================================
RunService.RenderStepped:Connect(function(dt)
    if not DroneActive or not DroneModel or not DroneModel.PrimaryPart then return end
    
    local core = DroneModel.PrimaryPart
    local camCFrame = Camera.CFrame
    
    local flatLook = Vector3.new(camCFrame.LookVector.X, 0, camCFrame.LookVector.Z).Unit
    local flatRight = Vector3.new(camCFrame.RightVector.X, 0, camCFrame.RightVector.Z).Unit

    if flatLook.Magnitude < 0.1 then flatLook = Vector3.new(0, 0, -1) end
    if flatRight.Magnitude < 0.1 then flatRight = Vector3.new(1, 0, 0) end

    local fwdInput, rightInput, upInput = 0, 0, 0

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then fwdInput = 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then fwdInput = -1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then rightInput = 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then rightInput = -1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then upInput = 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then upInput = -1 end

    if getgenv().NoirConfig.Drone.CollisionEnabled then
        for _, p in ipairs(DroneModel:GetDescendants()) do
            if p:IsA("BasePart") and not p.CanCollide then p.CanCollide = true end
        end
    else
        for _, p in ipairs(DroneModel:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end

    local targetPitch = fwdInput * math.rad(25)
    local targetRoll = rightInput * math.rad(25)
    
    local alpha = math.clamp(dt * 8, 0, 1)
    currentPitch = currentPitch + (targetPitch - currentPitch) * alpha
    currentRoll = currentRoll + (targetRoll - currentRoll) * alpha

    local baseCFrame = CFrame.lookAt(Vector3.zero, flatLook)
    local tiltCFrame = CFrame.Angles(currentPitch, 0, -currentRoll)

    local moveDir = (flatLook * fwdInput + flatRight * rightInput + Vector3.new(0, 1, 0) * upInput)
    local newPos = core.Position
    
    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit
        local speed = getgenv().NoirConfig.Drone.Speed
        local targetPos = core.Position + moveDir * speed * dt
        
        if getgenv().NoirConfig.Drone.CollisionEnabled then
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = {DroneModel, LocalPlayer.Character}
            local result = workspace:Raycast(core.Position, moveDir * speed * dt, rayParams)
            if result then
                targetPos = core.Position
            end
        end
        newPos = targetPos
    end
    
    local finalCFrame = CFrame.new(newPos) * baseCFrame.Rotation * tiltCFrame
    DroneModel:PivotTo(finalCFrame)
    core.CFrame = finalCFrame

    -- Проверка на удар
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
            local tHum = p.Character:FindFirstChildOfClass("Humanoid")
            if tHrp and tHum and tHum.Health > 0 then
                local dist = (core.Position - tHrp.Position).Magnitude
                if dist < 6 then
                    EndDroneFling(p) -- ВЫЗЫВАЕМ НОВУЮ ФУНКЦИЮ
                    break
                end
            end
        end
    end
end)

-- ============================================================================
-- 5. МЕНЮ
-- ============================================================================
task.wait(1)

pcall(function()
    local FunTab = _G.NoirFunTab
    if FunTab then
        local DroneSec = FunTab:AddSection("Kamikaze Drone")

        DroneSec:AddInput("DroneAssetIdInput", {
            Title = "Drone Model ID",
            Default = "",
            Placeholder = "Введите ID модели дрона...",
            Finished = true,
            Callback = function(text)
                getgenv().NoirConfig.Drone.AssetID = text
                Fluent:Notify({ Title = "Drone", Content = "Модель обновлена", Duration = 2 })
            end
        })

        DroneSec:AddToggle("DroneCollisionToggle", {
            Title = "Enable Collision (Walls)",
            Default = false,
            Callback = function(v) getgenv().NoirConfig.Drone.CollisionEnabled = v end
        })

        DroneSec:AddDropdown("DroneModeSelect", {
            Title = "Action Mode",
            Values = {"Fling", "Murder"},
            Default = "Fling",
            Callback = function(v) getgenv().NoirConfig.Drone.Mode = v end
        })

        DroneSec:AddSlider("DroneSpeedSlider", {
            Title = "Drone Speed",
            Default = 80,
            Min = 20,
            Max = 200,
            Rounding = 0,
            Callback = function(v) getgenv().NoirConfig.Drone.Speed = v end
        })

        DroneSec:AddToggle("DroneTrailToggle", {
            Title = "Enable Trail",
            Default = true,
            Callback = function(v)
                getgenv().NoirConfig.Drone.TrailEnabled = v
                if DroneActive and DroneModel and DroneModel.PrimaryPart then
                    if v then
                        local a0 = Instance.new("Attachment", DroneModel.PrimaryPart) a0.Position = Vector3.new(0, 0, 1)
                        local a1 = Instance.new("Attachment", DroneModel.PrimaryPart) a1.Position = Vector3.new(0, 0, -1)
                        local trail = Instance.new("Trail")
                        trail.Attachment0 = a0
                        trail.Attachment1 = a1
                        trail.Lifetime = 0.5
                        trail.Color = ColorSequence.new(getgenv().NoirConfig.Drone.TrailColor)
                        trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
                        trail.Parent = DroneModel.PrimaryPart
                        CurrentTrail = trail
                    else
                        if CurrentTrail then
                            CurrentTrail:Destroy()
                            CurrentTrail = nil
                        end
                    end
                end
            end
        })

        DroneSec:AddColorpicker("DroneTrailColor", {
            Title = "Trail Color",
            Default = getgenv().NoirConfig.Drone.TrailColor,
            Callback = function(v)
                getgenv().NoirConfig.Drone.TrailColor = v
                if CurrentTrail then
                    CurrentTrail.Color = ColorSequence.new(v)
                end
            end
        })

        DroneSec:AddButton({
            Title = "SPAWN DRONE",
            Description = "Стать дроном и взорвать цель",
            Callback = function()
                StartDrone()
            end
        })
        
        DroneSec:AddButton({
            Title = "Recall Drone (Cancel)",
            Description = "Отменить полет и вернуться",
            Callback = function()
                if DroneActive then StopDrone(false) end
            end
        })
    end
end)
-- ============================================================================
-- PART 15: WORLD EFFECTS (Trail & Footstep Particles)
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer

getgenv().NoirConfig = getgenv().NoirConfig or {}
getgenv().NoirConfig.Effects = getgenv().NoirConfig.Effects or {
    Trail = {
        Enabled = false,
        Preset = "Rainbow",
        Lifetime = 0.5,
        WidthScale = 1,
        StartColor = Color3.fromRGB(255, 0, 0),
        EndColor = Color3.fromRGB(0, 0, 255),
    },
    Footsteps = {
        Enabled = false,
        Preset = "Neon",
        Size = 1,
        Color = Color3.fromRGB(0, 255, 255),
    }
}

local CurrentTrail = nil
local TrailAtt0, TrailAtt1 = nil, nil
local stepEmitters = {}
local stepTimer = 0

-- ============================================================================
-- 1. TRAIL LOGIC (Шлейф)
-- ============================================================================
local function destroyTrail()
    if CurrentTrail then CurrentTrail:Destroy() CurrentTrail = nil end
    if TrailAtt0 then TrailAtt0:Destroy() TrailAtt0 = nil end
    if TrailAtt1 then TrailAtt1:Destroy() TrailAtt1 = nil end
end

local function createTrail()
    destroyTrail()
    local cfg = getgenv().NoirConfig.Effects.Trail
    if not cfg.Enabled then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    TrailAtt0 = Instance.new("Attachment")
    TrailAtt0.Position = Vector3.new(0, 1, 0)
    TrailAtt0.Parent = hrp

    TrailAtt1 = Instance.new("Attachment")
    TrailAtt1.Position = Vector3.new(0, -1, 0)
    TrailAtt1.Parent = hrp

    CurrentTrail = Instance.new("Trail")
    CurrentTrail.Attachment0 = TrailAtt0
    CurrentTrail.Attachment1 = TrailAtt1
    CurrentTrail.Lifetime = cfg.Lifetime
    CurrentTrail.WidthScale = NumberSequence.new(cfg.WidthScale)
    CurrentTrail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
    CurrentTrail.Parent = hrp
end

-- ============================================================================
-- 2. FOOTSTEP PARTICLES LOGIC (Эффекты шагов)
-- ============================================================================
local function setupFootstepEmitters()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, e in pairs(stepEmitters) do 
        if e and e.Parent then e.Parent:Destroy() end 
    end
    table.clear(stepEmitters)

    local function createEmitter(offset)
        local att = Instance.new("Attachment")
        att.Position = offset
        att.Parent = hrp
        
        local emitter = Instance.new("ParticleEmitter")
        emitter.Enabled = false
        emitter.Rate = 0
        emitter.Texture = "rbxassetid://243728166"
        emitter.Lifetime = NumberRange.new(0.5, 1)
        emitter.Speed = NumberRange.new(2, 5)
        emitter.SpreadAngle = Vector2.new(180, 180)
        emitter.Size = NumberSequence.new(1, 0)
        emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
        emitter.LightEmission = 1 
        emitter.Parent = att
        table.insert(stepEmitters, emitter)
    end

    createEmitter(Vector3.new(-0.5, -2.5, 0))
    createEmitter(Vector3.new(0.5, -2.5, 0))
end

local function updateFootstepParticles()
    local cfg = getgenv().NoirConfig.Effects.Footsteps
    for _, emitter in pairs(stepEmitters) do
        if not emitter or not emitter.Parent then continue end

        if cfg.Preset == "Rainbow" then
            local hue = (tick() * 0.5) % 1
            emitter.Color = ColorSequence.new(Color3.fromHSV(hue, 1, 1))
            emitter.Texture = "rbxassetid://243728166"
        elseif cfg.Preset == "Fire" then
            emitter.Color = ColorSequence.new(Color3.fromRGB(255, 200, 0), Color3.fromRGB(255, 50, 0))
            emitter.Texture = "rbxassetid://243728166" 
        elseif cfg.Preset == "Water" then
            emitter.Color = ColorSequence.new(Color3.fromRGB(0, 200, 255), Color3.fromRGB(0, 50, 150))
            emitter.Texture = "rbxassetid://243728166"
        elseif cfg.Preset == "Neon" then
            emitter.Color = ColorSequence.new(cfg.Color)
            emitter.Texture = "rbxassetid://243728166"
            emitter.LightEmission = 1
        else
            emitter.Color = ColorSequence.new(cfg.Color)
        end
        
        emitter.Size = NumberSequence.new(cfg.Size * 1.5, 0)
    end
end

-- ============================================================================
-- 3. MAIN RENDER LOOP
-- ============================================================================
RunService.RenderStepped:Connect(function(dt)
    local trailCfg = getgenv().NoirConfig.Effects.Trail
    local stepCfg = getgenv().NoirConfig.Effects.Footsteps

    -- --- Trails ---
    if trailCfg.Enabled then
        if not CurrentTrail or not CurrentTrail.Parent then
            createTrail()
        end
        
        if CurrentTrail then
            CurrentTrail.Lifetime = trailCfg.Lifetime
            CurrentTrail.WidthScale = NumberSequence.new(trailCfg.WidthScale)

            if trailCfg.Preset == "Rainbow" then
                local hue = (tick() * 0.5) % 1
                local c1 = Color3.fromHSV(hue, 1, 1)
                local c2 = Color3.fromHSV((hue + 0.5) % 1, 1, 1)
                CurrentTrail.Color = ColorSequence.new(c1, c2)
            elseif trailCfg.Preset == "Fire" then
                CurrentTrail.Color = ColorSequence.new(Color3.fromRGB(255, 200, 0), Color3.fromRGB(255, 50, 0))
            elseif trailCfg.Preset == "Water" then
                CurrentTrail.Color = ColorSequence.new(Color3.fromRGB(0, 200, 255), Color3.fromRGB(0, 50, 150))
            else
                CurrentTrail.Color = ColorSequence.new(trailCfg.StartColor, trailCfg.EndColor)
            end
        end
    else
        if CurrentTrail then destroyTrail() end
    end

    -- --- Footsteps (Партиклы) ---
    if stepCfg.Enabled then
        if #stepEmitters == 0 then setupFootstepEmitters() end
        
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if hum and hum.Health > 0 and hum.MoveDirection.Magnitude > 0 and hum.FloorMaterial ~= Enum.Material.Air then
            stepTimer = stepTimer + dt
            if stepTimer > 0.3 then
                stepTimer = 0
                for _, emitter in pairs(stepEmitters) do
                    if emitter and emitter.Parent then
                        emitter:Emit(2)
                    end
                end
            end
        end
        updateFootstepParticles()
    else
        if #stepEmitters > 0 then
            for _, e in pairs(stepEmitters) do 
                if e and e.Parent then e.Parent:Destroy() end 
            end
            table.clear(stepEmitters)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if getgenv().NoirConfig.Effects.Trail.Enabled then createTrail() end
    if getgenv().NoirConfig.Effects.Footsteps.Enabled then setupFootstepEmitters() end
end)

-- ============================================================================
-- 4. UI ИНТЕГРАЦИЯ (Во вкладку World)
-- ============================================================================
task.wait(1)

pcall(function()
    local WorldTab = _G.NoirWorldTab
    if WorldTab then
        
        -- === TRAIL SECTION ===
        local TrailSec = WorldTab:AddSection("Player Trail (Шлейф)")
        
        TrailSec:AddToggle("TrailToggle", {
            Title = "Enable Trail",
            Default = false,
            Callback = function(v)
                getgenv().NoirConfig.Effects.Trail.Enabled = v
                if v then createTrail() else destroyTrail() end
            end
        })

        TrailSec:AddDropdown("TrailPreset", {
            Title = "Preset",
            Values = {"Rainbow", "Fire", "Water", "Neon", "Custom"},
            Default = "Rainbow",
            Callback = function(v) getgenv().NoirConfig.Effects.Trail.Preset = v end
        })

        TrailSec:AddSlider("TrailLifetime", {
            Title = "Trail Length",
            Default = 0.5,
            Min = 0.1, Max = 2.0, Rounding = 1,
            Callback = function(v) getgenv().NoirConfig.Effects.Trail.Lifetime = v end
        })

        TrailSec:AddSlider("TrailWidth", {
            Title = "Trail Width",
            Default = 1,
            Min = 0.1, Max = 5, Rounding = 1,
            Callback = function(v) getgenv().NoirConfig.Effects.Trail.WidthScale = v end
        })

        -- 👇 ИСПРАВЛЕНО: маленькая буква 'p' в Colorpicker 👇
        TrailSec:AddColorpicker("TrailColor1", {
            Title = "Start Color (Custom)",
            Default = Color3.fromRGB(255, 0, 0),
            Callback = function(v) getgenv().NoirConfig.Effects.Trail.StartColor = v end
        })

        TrailSec:AddColorpicker("TrailColor2", {
            Title = "End Color (Custom)",
            Default = Color3.fromRGB(0, 0, 255),
            Callback = function(v) getgenv().NoirConfig.Effects.Trail.EndColor = v end
        })

        -- === FOOTSTEPS SECTION ===
        local StepSec = WorldTab:AddSection("Footstep Particles (Партиклы шагов)")
        
        StepSec:AddToggle("StepToggle", {
            Title = "Enable Footstep Particles",
            Default = false,
            Callback = function(v) 
                getgenv().NoirConfig.Effects.Footsteps.Enabled = v 
                if not v then
                    for _, e in pairs(stepEmitters) do 
                        if e and e.Parent then e.Parent:Destroy() end 
                    end
                    table.clear(stepEmitters)
                end
            end
        })

        StepSec:AddDropdown("StepPreset", {
            Title = "Preset",
            Values = {"Rainbow", "Fire", "Water", "Neon", "Custom"},
            Default = "Neon",
            Callback = function(v) getgenv().NoirConfig.Effects.Footsteps.Preset = v end
        })

        StepSec:AddSlider("StepSize", {
            Title = "Particle Size",
            Default = 1,
            Min = 0.5, Max = 3, Rounding = 1,
            Callback = function(v) getgenv().NoirConfig.Effects.Footsteps.Size = v end
        })

        StepSec:AddColorpicker("StepColor", {
            Title = "Custom Particle Color",
            Default = Color3.fromRGB(0, 255, 255),
            Callback = function(v) getgenv().NoirConfig.Effects.Footsteps.Color = v end
        })
        
    end
end)
-- В самом конце Part 1 добавь это:
getgenv().NoirWindow = Window
