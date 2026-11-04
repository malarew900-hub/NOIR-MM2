if not shared then
	return warn("No shared, no script.")
end

loadstring("getfenv().LPH_NO_VIRTUALIZE = function(...) return ... end")()
getfenv().PP_SCRAMBLE_NUM = function(...) return ... end
getfenv().PP_SCRAMBLE_STR = function(...) return ... end
getfenv().PP_SCRAMBLE_RE_NUM = function(...) return ... end

---@module World
local World = {}

---@module Config
local Config = require("Config")

-- Services.
local lighting = game:GetService("Lighting")
local runService = game:GetService("RunService")

-- State.
local originalBrightness = lighting.Brightness
local originalClockTime = lighting.ClockTime
local originalFogEnd = lighting.FogEnd
local originalGlobalShadows = lighting.GlobalShadows

function World.init()
	runService.RenderStepped:Connect(function()
		if Config.Visuals.Fullbright then
			lighting.Brightness = 2
			lighting.ClockTime = 14
			lighting.FogEnd = 100000
			lighting.GlobalShadows = false
		else
			lighting.Brightness = originalBrightness
			lighting.ClockTime = originalClockTime
			lighting.FogEnd = originalFogEnd
			lighting.GlobalShadows = originalGlobalShadows
		end
	end)
end

return World