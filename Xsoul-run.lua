--!strict

local HttpGet = game.HttpGet
local GameId: number = game.GameId

local Games: {[number]: string} = loadstring(
  HttpGet(game, "https://raw.githubusercontent.com/nuni555/Xsoul-FilesMenu/blob/a51500aa36507e51daef196e18b5a3da65d690d7/Xsoul_menu.lua")
)() :: any

local URL: string? = Games[GameId]
if not URL then return end

loadstring(HttpGet(game, URL))()
