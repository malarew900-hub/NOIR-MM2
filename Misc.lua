if not shared then
	return warn("No shared, no script.")
end

loadstring("getfenv().LPH_NO_VIRTUALIZE = function(...) return ... end")()
getfenv().PP_SCRAMBLE_NUM = function(...) return ... end
getfenv().PP_SCRAMBLE_STR = function(...) return ... end
getfenv().PP_SCRAMBLE_RE_NUM = function(...) return ... end

---@module Misc
local Misc = {}

---@module Config
local Config = require("Config")

-- Services.
local runService = game:GetService("RunService")
local workspace = workspace
local localPlayer = game:GetService("Players").LocalPlayer

function Misc.init()
	runService.Heartbeat:Connect(function()
		if not Config.Misc.AutoFarm then return end
		
		local character = localPlayer.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		-- Поиск монет на карте MM2 (обычно лежат в контейнере CoinContainer)
		local coinContainer = workspace:FindFirstChild("CoinContainer") or workspace:FindFirstChild("Coins")
		if coinContainer then
			for _, coin in ipairs(coinContainer:GetChildren()) do
				local coinPart = coin:IsA("BasePart") and coin or coin:FindFirstChild("CoinVisual") or coin:FindFirstChildWhichIsA("BasePart")
				if coinPart then
					-- Телепортация к монете для сбора
					hrp.CFrame = coinPart.CFrame
					task.wait(0.1)
					break
				end
			end
		end
	end)
end

return Misc