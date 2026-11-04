if not shared then
	return warn("No shared, no script.")
end

loadstring("getfenv().LPH_NO_VIRTUALIZE = function(...) return ... end")()
getfenv().PP_SCRAMBLE_NUM = function(...) return ... end
getfenv().PP_SCRAMBLE_STR = function(...) return ... end
getfenv().PP_SCRAMBLE_RE_NUM = function(...) return ... end

---@module ESP
local ESP = {}

---@module Config
local Config = require("Config")

-- Services.
local playersService = game:GetService("Players")
local runService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local localPlayer = playersService.LocalPlayer

local espCache = {}

local function createESP(player)
	local box = Drawing.new("Square")
	box.Visible = false
	box.Thickness = 1
	box.Filled = false

	local name = Drawing.new("Text")
	name.Visible = false
	name.Size = 14
	name.Center = true

	espCache[player] = {box = box, name = name}

	player.AncestryChanged:Connect(function(_, parent)
		if not parent then
			box:Remove()
			name:Remove()
			espCache[player] = nil
		end
	end)
end

function ESP.init()
	for _, player in ipairs(playersService:GetPlayers()) do
		if player ~= localPlayer then
			createESP(player)
		end
	end

	playersService.PlayerAdded:Connect(function(player)
		if player ~= localPlayer then
			createESP(player)
		end
	end)

	playersService.PlayerRemoving:Connect(function(player)
		if espCache[player] then
			espCache[player].box:Remove()
			espCache[player].name:Remove()
			espCache[player] = nil
		end
	end)

	runService.RenderStepped:Connect(function()
		if not Config.ESP.Enabled then
			for _, visuals in pairs(espCache) do
				visuals.box.Visible = false
				visuals.name.Visible = false
			end
			return
		end

		for player, visuals in pairs(espCache) do
			local character = player.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChild("Humanoid")

			if hrp and humanoid and humanoid.Health > 0 then
				local vector, onScreen = currentCamera:WorldToViewportPoint(hrp.Position)
				if onScreen then
					local color = Color3.fromRGB(0, 255, 0)
					if character:FindFirstChild("Knife") or (player.Backpack and player.Backpack:FindFirstChild("Knife")) then
						color = Color3.fromRGB(255, 0, 0)
					elseif character:FindFirstChild("Gun") or (player.Backpack and player.Backpack:FindFirstChild("Gun")) then
						color = Color3.fromRGB(0, 0, 255)
					end

					visuals.box.Color = color
					visuals.name.Color = color
					visuals.box.Visible = Config.ESP.Boxes
					visuals.name.Visible = Config.ESP.Names

					visuals.box.Size = Vector2.new(2000 / vector.Z, 3000 / vector.Z)
					visuals.box.Position = Vector2.new(vector.X - visuals.box.Size.X / 2, vector.Y - visuals.box.Size.Y / 2)

					visuals.name.Text = player.Name
					visuals.name.Position = Vector2.new(vector.X, visuals.box.Position.Y - 18)
				else
					visuals.box.Visible = false
					visuals.name.Visible = false
				end
			else
				visuals.box.Visible = false
				visuals.name.Visible = false
			end
		end
	end)
end

return ESP