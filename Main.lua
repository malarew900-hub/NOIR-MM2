-- Main.lua
local BaseURL = "https://raw.githubusercontent.com/malarew900-hub/NOIR-MM2/main/"

local Config = loadstring(game:HttpGet(BaseURL .. "Config.lua"))()
local ESP = loadstring(game:HttpGet(BaseURL .. "ESP.lua"))()
local Combat = loadstring(game:HttpGet(BaseURL .. "Combat.lua"))()
local Farm = loadstring(game:HttpGet(BaseURL .. "Farm.lua"))()
local Movement = loadstring(game:HttpGet(BaseURL .. "Movement.lua"))()
local UI = loadstring(game:HttpGet(BaseURL .. "UI.lua"))()

-- Инициализация
ESP.Init(Config)
Combat.Init(Config)
Farm.Init(Config)
Movement.Init(Config)
UI.Init(Config, ESP, Combat, Farm, Movement)

-- Основной цикл (только визуал и движение — 60 FPS)
game:GetService("RunService").RenderStepped:Connect(function()
    ESP.Update()
    Combat.Update()
    Movement.Update()
end)

-- Тяжелые задачи (фарм) — в отдельном потоке с задержкой
task.spawn(function()
    while task.wait(0.5) do -- Обновляем раз в 0.5 сек, чтобы не лагало
        Farm.Update()
    end
end)