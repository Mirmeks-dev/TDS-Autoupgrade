if not game:IsLoaded() then game.Loaded:Wait() end

--Rayfield UI stuff
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "TDS Autoupgrade",
   Icon = 0,
   LoadingTitle = "Loading...",
   LoadingSubtitle = "by Mirmeks",
   ShowText = "Rayfield",
   Theme = "Default",

   ToggleUIKeybind = "K",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, 

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, 
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true 
   },

   KeySystem = false, 
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

local MainTab = Window:CreateTab("Main", nil) 
local Toggle = MainTab:CreateToggle({
   Name = "Autoupgrade",
   CurrentValue = false,
   Flag = "ToggleAutoUpgrade",
   Callback = function(Value)
       AutoUpgrade = Value       
   end,
})

local Dropdown = Tab:CreateDropdown({
   Name = "Autoupgrade mode",
   Options = {"Cheapest","Best DPS/$"},
   CurrentOption = {"Cheapest"},
   MultipleOptions = false,
   Flag = "AutoUpgradeMode",
   Callback = function(Options)
         if Options[1] == "Cheapest" then
            CheapestAutoUpgrade = true
         elseif Options[1] == "Best DPS/$" then
            BestDPSAutoUpgrade = true
         end   
   end,
})

--Variable stuff
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local stateReplicators = ReplicatedStorage:WaitForChild("StateReplicators")
local TowerStatsFolder = ReplicatedStorage:WaitForChild("Content"):WaitForChild("Tower")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TowersFolder = workspace:WaitForChild("Towers")
local count = 1

--Rename function
local function RenameTowers()
    for _, child in ipairs(TowersFolder:GetChildren()) do
        if type(tonumber(child.Name)) ~= "number" then        
            child.Name = tostring(count)
            count = count + 1
        end
    end
end

--First rename
RenameTowers()

--Realtime rename
TowersFolder.ChildAdded:Connect(function()
  task.wait(0.1)
  RenameTowers()
end)

TowersFolder.ChildRemoved:Connect(function()
  task.wait(0.1)
  RenameTowers()
end)

--Getting tower names
for _, replicator in ipairs(stateReplicators:GetChildren()) do
    if replicator:GetAttribute("UserId") == player.UserId then
        local equipped = replicator:GetAttribute("EquippedTowers")        
        local cleaned_json = equipped:match("%[.*%]") 
        local ok, decoded = pcall(function()
                return game:GetService("HttpService"):JSONDecode(cleaned_json)
        end)    
        if ok then
            equipped = decoded
        end
    end
end

--Getting towers stats
local function getTowerStats(towerName)
    local towerDataFolder = TowerStatsFolder:FindFirstChild(towerName)
    local statsScript = towerDataFolder:FindFirstChild("Stats")   
    local success, statsModule = pcall(require, statsScript)
    if not success then
        return nil
    end
    return statsModule
end

--DPS Calculation
local function calculateDPS(stats)
    if stats.Damage and stats.Cooldown then
        return stats.Damage / stats.Cooldown
    end
    return 0
end

--DPS Calculation on all levels
local function calculateAllDPS(towerName)
    local statsModule = getTowerStats(towerName)
    local results = {}
    for variationName, variationData in pairs(statsModule.Stats or {}) do
        results[variationName] = {}
        
        --Base stats
        if variationData.Defaults then
            local baseDPS = calculateDPS(variationData.Defaults)
            table.insert(results[variationName], {
                Level = 0,
                Damage = variationData.Defaults.Damage or 0,
                Cooldown = variationData.Defaults.Cooldown or 1,
                DPS = baseDPS
            })
        end
        
        --After upgrade stats
        if variationData.Upgrades then
            local currentStats = variationData.Defaults and table.clone(variationData.Defaults) or {}
            
            for level, upgrade in ipairs(variationData.Upgrades) do
                if upgrade.Stats then
                    for statName, statValue in pairs(upgrade.Stats) do
                        currentStats[statName] = statValue
                    end
                end
                
                if upgrade.Stats and upgrade.Stats.Detections and currentStats.Detections then
                    for detectionType, detectionValue in pairs(upgrade.Stats.Detections) do
                        currentStats.Detections[detectionType] = detectionValue
                    end
                end
                
                local levelDPS = calculateDPS(currentStats)
                table.insert(results[variationName], {
                    Level = level,
                    Damage = currentStats.Damage or 0,
                    Cooldown = currentStats.Cooldown or 1,
                    DPS = levelDPS,
                    Title = upgrade.Title or "Апгрейд " .. level,
                    Cost = upgrade.Cost or 0
                })
            end
        end
    end
    
    return results
end

--Autoupgrade function
task.spawn(function()
    while true do
        task.wait(0.2)
        if AutoUpgrade and CheapestAutoUpgrade then
            for _, tower in ipairs(TowersFolder:GetChildren()) do
                if tonumber(tower.Name) then
                    local args = {
                        "Troops",
                        "Upgrade",
                        "Set",
                        {
                            Troop = tower,
                            Path = 1
                        }
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer(unpack(args))   
                end
            end   
         elseif Autoupgrade and BestDPSAutoUpgrade then
            print("WIP")
         end
    end
end)       
