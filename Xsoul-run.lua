--!strict

local HttpGet = game.HttpGet
local GameId: number = game.GameId

local Games: {[number]: string} = loadstring(
  HttpGet(game, "https://raw.githubusercontent.com/nuni555/Xsoul-FilesMenu/refs/heads/main/Xsoul_menu.lua?token=GHSAT0AAAAAAD776ZSCKNWS3OI62KMIWCAI2RQCY5A")
)() :: any

local URL: string? = Games[GameId]
if not URL then return end

loadstring(HttpGet(game, URL))()
