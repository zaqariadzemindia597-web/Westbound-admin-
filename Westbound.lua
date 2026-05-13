local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🌵 Westbound PRO | Mindia",
   LoadingTitle = "Westbound Admin",
   LoadingSubtitle = "by Mindia",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Player = game.Players.LocalPlayer

-- ტაბები
local CombatTab = Window:CreateTab("Combat", 4483362458)
local ESPTab = Window:CreateTab("Visuals", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- COMBAT
CombatTab:CreateToggle({
   Name = "Silent Aim",
   CurrentValue = false,
   Callback = function(Value) _G.SilentAim = Value end,
})

CombatTab:CreateButton({
   Name = "Fix Weapon/Reload",
   Callback = function()
      for _, v in pairs(Player.Backpack:GetChildren()) do
         if v:IsA("Tool") and v:FindFirstChild("Stats") then
            v.Stats.ReloadTime.Value = 0.1
            v.Stats.FireRate.Value = 0.1
         end
      end
      Rayfield:Notify({Title = "Weapons", Content = "იარაღი გამოსწორდა!", Duration = 2})
   end,
})

-- ESP (Visuals)
ESPTab:CreateToggle({
   Name = "Enable ESP (Wallhack)",
   CurrentValue = false,
   Callback = function(Value)
      _G.ESP_Enabled = Value
      if Value then
         spawn(function()
            while _G.ESP_Enabled do
               for _, p in pairs(game.Players:GetPlayers()) do
                  if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                     local hrp = p.Character.HumanoidRootPart
                     if not hrp:FindFirstChild("MindiaESP") then
                        local b = Instance.new("BoxHandleAdornment", hrp)
                        b.Name = "MindiaESP"
                        b.Adornee = hrp
                        b.AlwaysOnTop = true
                        b.Size = Vector3.new(4, 5.5, 1)
                        b.Transparency = 0.5
                        b.Color3 = Color3.fromRGB(255, 0, 0)
                     end
                  end
               end
               task.wait(1)
            end
         end)
      else
         for _, v in pairs(game.Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.HumanoidRootPart:FindFirstChild("MindiaESP") then
               v.Character.HumanoidRootPart.MindiaESP:Destroy()
            end
         end
      end
   end,
})

-- PLAYER
PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 150},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value) Player.Character.Humanoid.WalkSpeed = Value end,
})

-- SILENT AIM LOGIC
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if _G.SilentAim and getnamecallmethod() == "FireServer" and self.Name == "GunShot" then
        local target, dist = nil, math.huge
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                local d = (Player.Character.Head.Position - v.Character.Head.Position).Magnitude
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
