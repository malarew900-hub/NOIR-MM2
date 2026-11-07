-- ============================================================================
-- NOIR / MM2 KEY SYSTEM (FINAL LOADER)
-- ============================================================================

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local PART2_URL = "https://raw.githubusercontent.com/malarew900-hub/NOIR-MM2/refs/heads/main/part2.lua"

local FILE_NAME = "Noir_UsedKeys.json"
local SESSION_TIME = 86400 -- 24 часа

-- Функция загрузки Part 2 (которая потом загрузит Part 1)
local function LoadMainScripts()
    getgenv().NoirAuthenticated = true
    
    local success, err = pcall(function()
        loadstring(game:HttpGet(PART2_URL .. "?t=" .. tostring(os.time())))()
    end)
    
    if not success then 
        warn("[NOIR] Ошибка загрузки Part 2: " .. tostring(err)) 
    end
end

-- АВТО-ВХОД
if getgenv().NoirAuthenticated then
    LoadMainScripts()
    return
end

local function loadUsedKeys()
    local keys = {}
    if isfile and isfile(FILE_NAME) then
        local success, result = pcall(function() return HttpService:JSONDecode(readfile(FILE_NAME)) end)
        if success and type(result) == "table" then keys = result end
    end
    return keys
end

local function saveUsedKeys(keys)
    if writefile then pcall(function() writefile(FILE_NAME, HttpService:JSONEncode(keys)) end) end
end

-- Проверяем активный ключ при запуске
local usedKeys = loadUsedKeys()
local currentTime = os.time()

for key, timeUsed in pairs(usedKeys) do
    local timePassed = currentTime - timeUsed
    if timePassed < SESSION_TIME then
        print("[NOIR] Auto-login successful.")
        LoadMainScripts()
        return
    end
end

-- ============================================================================
-- UI KEY SYSTEM
-- ============================================================================
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "NoirKeySystem"
KeyGui.ResetOnSpawn = false
KeyGui.IgnoreGuiInset = true
KeyGui.DisplayOrder = 999
if gethui then KeyGui.Parent = gethui() elseif syn and syn.protect_gui then syn.protect_gui(KeyGui) KeyGui.Parent = CoreGui else KeyGui.Parent = CoreGui end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = KeyGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -130)
MainFrame.Size = UDim2.new(0, 350, 0, 260)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(45, 45, 45)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 20)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBlack
Title.Text = "NOIR"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 32

local SubTitle = Instance.new("TextLabel")
SubTitle.Parent = MainFrame
SubTitle.BackgroundTransparency = 1
SubTitle.Position = UDim2.new(0, 0, 0, 55)
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Font = Enum.Font.Gotham
SubTitle.Text = "Format: NOIR-XXXX-XXXX-XXXX"
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitle.TextSize = 14

local InputFrame = Instance.new("Frame")
InputFrame.Parent = MainFrame
InputFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
InputFrame.Position = UDim2.new(0.5, -140, 0, 100)
InputFrame.Size = UDim2.new(0, 280, 0, 40)

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = InputFrame

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = Color3.fromRGB(60, 60, 60)
InputStroke.Parent = InputFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Parent = InputFrame
KeyInput.BackgroundTransparency = 1
KeyInput.Size = UDim2.new(1, -20, 1, 0)
KeyInput.Position = UDim2.new(0, 10, 0, 0)
KeyInput.Font = Enum.Font.Code
KeyInput.PlaceholderText = "NOIR-0000-0000-0000"
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
KeyInput.TextSize = 16
KeyInput.TextXAlignment = Enum.TextXAlignment.Center
KeyInput.ClearTextOnFocus = false

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Parent = MainFrame
SubmitBtn.BackgroundColor3 = Color3.fromRGB(188, 78, 255)
SubmitBtn.Position = UDim2.new(0.5, -100, 0, 160)
SubmitBtn.Size = UDim2.new(0, 200, 0, 40)
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.Text = "Authenticate"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.TextSize = 14

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = SubmitBtn

local StatusText = Instance.new("TextLabel")
StatusText.Parent = MainFrame
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(0, 0, 0, 205)
StatusText.Size = UDim2.new(1, 0, 0, 40)
StatusText.Font = Enum.Font.Gotham
StatusText.Text = ""
StatusText.TextColor3 = Color3.fromRGB(255, 50, 50)
StatusText.TextSize = 12
StatusText.TextWrapped = true

-- Перетаскивание окна
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ============================================================================
-- ПРОВЕРКА КЛЮЧА
-- ============================================================================
local function ShowStatus(msg, isSuccess)
    StatusText.Text = msg
    StatusText.TextColor3 = isSuccess and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    InputStroke.Color = isSuccess and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    TweenService:Create(InputStroke, TweenInfo.new(1), {Color = Color3.fromRGB(60, 60, 60)}):Play()
end

SubmitBtn.MouseButton1Click:Connect(function()
    local key = string.upper(KeyInput.Text:gsub("%s+", ""))
    
    if key == "" then return ShowStatus("Please enter a key.", false) end
    
    local isValidFormat = string.match(key, "^NOIR%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w$")
    if not isValidFormat then return ShowStatus("Invalid format! Use NOIR-XXXX-XXXX-XXXX", false) end
    
    local usedKeys = loadUsedKeys()
    local currentTime = os.time()
    
    if usedKeys[key] then
        local timePassed = currentTime - usedKeys[key]
        if timePassed < SESSION_TIME then
            local hoursLeft = math.floor((SESSION_TIME - timePassed) / 3600)
            local minsLeft = math.floor(((SESSION_TIME - timePassed) % 3600) / 60)
            return ShowStatus("Key is on 24h cooldown!\nTry again in: " .. hoursLeft .. "h " .. minsLeft .. "m", false)
        end
    end
    
    SubmitBtn.Text = "Checking..."
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    task.wait(0.5)
    
    usedKeys[key] = currentTime
    saveUsedKeys(usedKeys)
    
    SubmitBtn.Text = "Success!"
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    ShowStatus("Authenticated! Loading NOIR...", true)
    
    task.wait(0.5)
    KeyGui:Destroy()
    LoadMainScripts()
end)
