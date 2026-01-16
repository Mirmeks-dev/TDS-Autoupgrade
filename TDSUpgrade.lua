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

local TowersFolder = workspace:WaitForChild("Towers")
local count = 1
local function RenameTowers()
    for _, child in ipairs(TowersFolder:GetChildren()) do
        if type(tonumber(child.Name)) ~= "number" then        
            child.Name = tostring(count)
            count = count + 1
        end
    end
end

-- First rename
RenameTowers()

-- Realtime rename
TowersFolder.ChildAdded:Connect(function()
  task.wait(0.1)
  RenameTowers()
end)

TowersFolder.ChildRemoved:Connect(function()
  task.wait(0.1)
  RenameTowers()
end)

--Autoupgrade function
task.spawn(function()
    while true do
        task.wait(0.2)
        if AutoUpgrade then
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
        end
    end
end)       
