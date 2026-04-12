local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Westbound Mobile Pro V4",
   LoadingTitle = "Bypassing Systems...",
   ConfigurationSaving = {Enabled = false}
})

-- ცვლადები
_G.SilentAim = false
_G.ESP = false
_G.FOV_Radius = 150
local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- FOV წრის ვიზუალი (მუშაობს თუ ექსეკუტორს აქვს Drawing ლიბი)
local FOVCircle = nil
if Drawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Thickness = 1
    FOVCircle.Radius = _G.FOV_Radius
    FOVCircle.Filled = false
end

local MainTab = Window:CreateTab("Combat", 4483362458)

-- 1. Silent Aim & FOV
MainTab:CreateToggle({
   Name = "Silent Aim (In Circle)",
   CurrentValue = false,
   Callback = function(Value) 
      _G.SilentAim = Value 
      if FOVCircle then FOVCircle.Visible = Value end
   end,
})

MainTab:CreateSlider({
   Name = "FOV Radius",
   Range = {50, 500},
   Increment = 10,
   CurrentValue = 150,
   Callback = function(Value) 
      _G.FOV_Radius = Value 
      if FOVCircle then FOVCircle.Radius = Value end
   end,
})

-- 2. Gun Mod (No Recoil & Fast Reload)
MainTab:CreateButton({
   Name = "Buff All Weapons (Recoil/Reload)",
   Callback = function()
       local function Patch(v)
           if v:IsA("Tool") then
               local s = v:FindFirstChild("GunSettings") or v:FindFirstChildOfClass("ModuleScript")
               if s then
                   local m = require(s)
                   m.Recoil = 0
                   m.Spread = 0
                   m.ReloadTime = 0.05
                   if m.ReloadSpeed then m.ReloadSpeed = 10 end
                   Rayfield:Notify({Title = "Success", Content = v.Name .. " Patched!", Duration = 2})
               end
           end
       end
       if Player.Character:FindFirstChildOfClass("Tool") then Patch(Player.Character:FindFirstChildOfClass("Tool")) end
       for _, t in pairs(Player.Backpack:GetChildren()) do Patch(t) end
   end,
})

-- 3. ESP
MainTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Callback = function(Value) _G.ESP = Value end,
})

-- ფუნქცია უახლოესი მტრის საპოვნელად
local function GetClosest()
    local target = nil
    local dist = _G.FOV_Radius
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("Head") then
            local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if vis then
                local m = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if m < dist then
                    target = v
                    dist = m
                end
            end
        end
    end
    return target
end

-- მთავარი ციკლი
RunService.RenderStepped:Connect(function()
    if FOVCircle and FOVCircle.Visible then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end

    if _G.SilentAim then
        local t = GetClosest()
        local tool = Player.Character:FindFirstChildOfClass("Tool")
        if t and tool and tool:FindFirstChild("MousePos") then
            tool.MousePos.Value = t.Character.Head.Position
        end
    end

    if _G.ESP then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not p.Character:FindFirstChild("Highlight") then
                    Instance.new("Highlight", p.Character)
                end
            end
        end
    end
end)
