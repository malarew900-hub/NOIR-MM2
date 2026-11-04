if not shared then
	return warn("No shared, no script.")
end

loadstring("getfenv().LPH_NO_VIRTUALIZE = function(...) return ... end")()
getfenv().PP_SCRAMBLE_NUM = function(...) return ... end
getfenv().PP_SCRAMBLE_STR = function(...) return ... end
getfenv().PP_SCRAMBLE_RE_NUM = function(...) return ... end

---@module Main
local Main = {}

---@module Config
local Config = require("Config")
---@module ESP
local ESP = require("ESP")
---@module Player
local Player = require("Player")
---@module World
local World = require("World")
---@module Misc
local Misc = require("Misc")

if shared.NOIR_MM2 then
	-- Очистка предыдущего инстанса при перезапуске
	pcall(function()
		shared.NOIR_MM2 = nil
	end)
end

local function onInitializeError(error)
	warn("Failed to initialize NOIR-MM2.")
	warn(error)
	warn(debug.traceback())
end

local function initializeScript()
	ESP.init()
	Player.init()
	World.init()
	Misc.init()
	
	print("NOIR-MM2 successfully loaded!")
end

shared.NOIR_MM2 = Main

-- Безопасный запуск с обработкой ошибок
xpcall(initializeScript, onInitializeError)

return Main