local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Westbound Ultimate Hub",
   LoadingTitle = "Initializing Systems...",
   LoadingSubtitle = "by Developer",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "Westbound_Data",
      FileName = "MainConfig"
   }
})

-- Global Variables
_G.SilentAimEnabled = false
_G.ESPEnabled = false
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera

local MainTab = Window:CreateTab("Main Cheats", 4483362458)

-- 1. Silent Aim Toggle
MainTab:CreateToggle({
   Name = "Silent Aim (Direct Hit)",
   CurrentValue = false,
   Flag = "SAim", 
   Callback = function(Value)
      _G.SilentAimEnabled = Value
   end,
})

-- 2. ESP Toggle
MainTab:CreateToggle({
   Name = "Player ESP (Wallhack)",
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

-- 3. Gun Mod Button
MainTab:CreateButton({
   Name = "God Gun (No Recoil + Fast Reload)",
   Callback = function()
       local tool = Player.Character:FindFirstChildOfClass("Tool")
       if tool and tool:FindFirstChild("GunSettings") then
           local s = require(tool.GunSettings)
           s.Recoil = 0
           s.Spread = 0
           s.ReloadTime = 0.1
           if s.ReloadSpeed then s.ReloadSpeed = 5 end
           Rayfield:Notify({Title = "Success", Content = "Weapon Overpowered!", Duration = 2})
       else
           Rayfield:Notify({Title = "Error", Content = "Equip a gun first!", Duration = 3})
       end
   end,
})

-- Target Logic
local function GetClosestToMouse()
    local target = nil
    local maxDist = 500 
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if dist < maxDist then
                    target = v
                    maxDist = dist
                end
            end
        end
    end
    return target
end

-- Hooking for Silent Aim
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    if _G.SilentAimEnabled and not checkcaller() then
        if Method == "FindPartOnRayWithIgnoreList" or Method == "Raycast" then
            local Target = GetClosestToMouse()
            if Target and Target.Character and Target.Character:FindFirstChild("Head") then
                local Direction = (Target.Character.Head.Position - Camera.CFrame.Position).Unit * 1000
                if Method == "FindPartOnRayWithIgnoreList" then
                    Args[1] = Ray.new(Camera.CFrame.Position, Direction)
                end
                return OldNamecall(Self, unpack(Args))
            end
        end
    end
    return OldNamecall(Self, ...)
end)

-- ESP Loop
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.ESPEnabled then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not p.Character:FindFirstChild("Highlight") then
                    local h = Instance.new("Highlight", p.Character)
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                end
            end
        end
    end
end)
