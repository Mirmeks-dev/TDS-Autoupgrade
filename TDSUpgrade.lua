local TowersFolder = workspace:WaitForChild("Towers")
local count = 1
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "TDS Autoupgrade",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Loading...",
   LoadingSubtitle = "by Mirmeks",
   ShowText = "Rayfield", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local function RenameTowers()
    for _, child in ipairs(TowersFolder:GetChildren()) do
        if type(tonumber(child.Name)) ~= "number" then        
            child.Name = tostring(count)
            count = count + 1
        end
    end
end

-- Первичное переименование
RenameTowers()

-- Обновление в реальном времени
TowersFolder.ChildAdded:Connect(function()
  task.wait(0.1) -- маленькая задержка для стабильности
  RenameTowers()
end)

TowersFolder.ChildRemoved:Connect(function()
  task.wait(0.1)
  RenameTowers()
end)

local MainTab = Window:CreateTab("Main", nil) 
local Toggle = MainTab:CreateToggle({
   Name = "Autoupgrade",
   CurrentValue = false,
   Flag = "ToggleAutoUpgrade", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
       AutoUpgrade = Value       
   end,
})

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
