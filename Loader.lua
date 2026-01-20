--Game checker
if game.PlaceId ~= 5591597781 then
  print("Не тот ID")
  return
end

local GameType = Workspace.Type
if GameType.Value ~= "Game" then
  print("Не тот тип игры")
  return
end  
loadstring(game:HttpGet("https://raw.githubusercontent.com/Mirmeks-dev/TDS-Autoupgrade/main/TDSUpgrade.lua"))()
  
