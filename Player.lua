if not shared then
	return warn("No shared, no script.")
end

loadstring("getfenv().LPH_NO_VIRTUALIZE = function(...) return ... end")()
getfenv().PP_SCRAMBLE_NUM = function(...) return ... end
getfenv().PP_SCRAMBLE_STR = function(...) return ... end
getfenv().PP_SCRAMBLE_RE_NUM = function(...) return ... end

---@module Player
local Player = {}

---@module Config
local Config = require("Config")

-- Services.
local playersService = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = playersService.LocalPlayer

function Player.init()
	runService.Heartbeat:Connect(function()
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChild("Humanoid")
		
		if humanoid then
			if Config.Misc.SpeedHack then
				humanoid.WalkSpeed = Config.Misc.SpeedValue
			end
		end
	end)
end

return Player