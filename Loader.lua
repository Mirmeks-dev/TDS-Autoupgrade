--Game checker
if game.GameId ~= 1176784616 then 
  return
end

local GameType = Workspace.Type
if GameType.Value ~= "Game" then
  return
end  
loadstring(game:HttpGet("https://raw.githubusercontent.com/Mirmeks-dev/TDS-Autoupgrade/main/TDSUpgrade.lua"))()
  
