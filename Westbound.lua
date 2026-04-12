local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Westbound Mobile Ultimate Hub",
   LoadingTitle = "Mobile Systems Loading...",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "Westbound_Mobile_Data",
      FileName = "Config"
   }
})

-- ცვლადები (Global Variables)
_G.SilentAimEnabled = false
_G.ESPEnabled = false
_G.FOV = 150
local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

local MainTab = Window:CreateTab("Main Hacks", 4483362458)

-- 1. Silent Aim & FOV სექცია
MainTab:CreateSection("Combat (Mobile Optimized)")

MainTab:CreateToggle({
   Name = "Silent Aim (Direct Hit)",
   CurrentValue = false,
   Flag = "SAim", 
   Callback = function(Value)
      _G.SilentAimEnabled = Value
   end,
})

MainTab:CreateSlider({
   Name = "Aim Radius (FOV)",
   Range = {50, 800},
   Increment = 10,
   CurrentValue = 150,
   Flag = "FOVSize",
   Callback = function(Value)
      _G.FOV = Value
   end,
})

-- 2. Visuals (ESP) სექცია
MainTab:CreateSection("Visuals")

MainTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "ESP",
   Callback = function(Value)
      _G.ESPEnabled = Value
      if not Value then
          for _, p in pairs(game.Players:GetPlayers()) do
              if p.Character and p.Character:FindFirstChild("Highlight") then
                  p.Character.Highlight:Destroy()
              end
          end
      end
   end,
})

-- 3. Gun Mod სექცია (გამოწორებული და გაძლიერებული)
MainTab:CreateSection("Weapon Modifications")

MainTab:CreateButton({
   Name = "Ultimate Gun Buff (No Recoil + Fast Reload)",
   Callback = function()
       local function PatchGun(v)
           if v:IsA("Tool") then
               local settingsModule = v:FindFirstChild("GunSettings") or v:FindFirstChildOfClass("ModuleScript")
               if settingsModule then
                   local s = require(settingsModule)
                   -- უკუცემა და გაფანტვა
                   s.Recoil = 0
                   s.RecoilControl = 0
                   s.Spread = 0
                   s.MaxSpread = 0
                   s.MinSpread = 0
                   -- გადატენვა და სროლის სისწრაფე
                   s.ReloadTime = 0.05
                   s.FireRate = 0.05
                   if s.ReloadSpeed then s.ReloadSpeed = 10 end
                   if s.AimRecoilReduction then s.AimRecoilReduction = 1 end
                   
                   Rayfield:Notify({Title = "Success", Content = v.Name .. " Modified!", Duration = 2})
               end
           end
       end

       -- ვამოწმებთ ხელში რა გვიჭირავს
       local currentTool = Player.Character:FindFirstChildOfClass("Tool")
       if currentTool then
           PatchGun(currentTool)
       else
           -- ვამოწმებთ ინვენტარს
           for _, v in pairs(Player.Backpack:GetChildren()) do
               PatchGun(v)
           end
           Rayfield:Notify({Title = "Info", Content = "Backpack Weapons Patched!", Duration = 2})
       end
   end,
})

-- მობილურისთვის ოპტიმიზებული
