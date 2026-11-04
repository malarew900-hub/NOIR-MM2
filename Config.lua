---@module Config
local Config = {
	ESP = {
		Enabled = true,
		Boxes = true,
		Names = true,
		Roles = true,
		Distance = true,
		MaxDistance = 1000,
	},
	Visuals = {
		Chams = false,
		Fullbright = false,
	},
	Combat = {
		SilentAim = false,
		FovRadius = 150,
	},
	Misc = {
		AutoFarm = false,
		SpeedHack = false,
		SpeedValue = 16,
	}
}

return Config