local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🌵 Westbound PRO | Mindia",
   LoadingTitle = "Westbound Admin",
   LoadingSubtitle = "by Mindia",
   ConfigurationSaving = { Enabled = true, FileName = "MindiaConfig" },
   KeySystem = false
})

-- --- ტაბები ---
local CombatTab = Window:CreateTab("Combat", 4483362458)
local FarmTab = Window:CreateTab("Farm", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- --- COMBAT ---
CombatTab:CreateToggle({
   Name = "Silent Aim",
   CurrentValue = false,
   Callback = function(Value) _G.SilentAim = Value end,
})

CombatTab:CreateToggle({
   Name = "Infinite Ammo",
   CurrentValue = false,
   Callback = function(Value)
      _G.InfAmmo = Value
      spawn(function()
         while _G.InfAmmo do
            local am = game:GetService("Players").LocalPlayer:FindFirstChild("Consumables")
            if am and am:FindFirstChild("PistolAmmo") then
               game:GetService("ReplicatedStorage").GunScripts.Events.UseAmmo:FireServer(am.PistolAmmo)
            end
            task.wait(0.8)
         end
      end)
   end,
})

-- --- FARM ---
FarmTab:CreateButton({
   Name = "Rob Safe",
   Callback = function()
      game:GetService("ReplicatedStorage").GeneralEvents.Rob:FireServer("Safe", workspace:FindFirstChild("Safe"))
   end,
})

FarmTab:CreateButton({
   Name = "Instant Reload",
   Callback = function()
      for _, v in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
         if v:IsA("Tool") and v:FindFirstChild("Stats") then
            if v.Stats:FindFirstChild("ReloadTime") then v.Stats.ReloadTime.Value = 0.01 end
            if v.Stats:FindFirstChild("FireRate") then v.Stats.FireRate.Value = 0.05 end
         end
      end
   end,
})

-- --- PLAYER ---
PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 150},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Callback = function(Value) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value end,
})

-- --- SILENT AIM LOGIC ---
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if _G.SilentAim and getnamecallmethod() == "FireServer" and self.Name == "GunShot" then
        local target = nil
        local dist = math.huge
        for _, v in pairs(game.Players.GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                local d = (game.Players.LocalPlayer.Character.Head.Position - v.Character.Head.Position).magnitude
                if d < dist then target, dist = v, d end
            end
        end
        if target then
            args[1][1].HitPart = target.Character.Head
            args[1][1].HitPosition = target.Character.Head.Position
            args[1][1].EndPoint = target.Character.Head.Position
        end
    end
    return old(self, unpack(args))
end)
setreadonly(mt, true)
