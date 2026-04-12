-- LUCIFER & KDOM STYLE WESTBOUND ADMIN
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MY PRIVATE ADMIN | Westbound",
   LoadingTitle = "Bypassing Security...",
   ConfigurationSaving = {Enabled = false}
})

-- ცვლადები (Variables)
_G.SilentAim = false
_G.GunMod = false
_G.FOV = 150
local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 🎯 COMBAT TAB
local CombatTab = Window:CreateTab("Combat", 4483362458)

CombatTab:CreateToggle({
   Name = "Silent Aim (Target Nearest)",
   CurrentValue = false,
   Callback = function(Value) _G.SilentAim = Value end,
})

CombatTab:CreateSlider({
   Name = "Aim Radius",
   Range = {50, 800},
   Increment = 10,
   CurrentValue = 150,
   Callback = function(Value) _G.FOV = Value end,
})

CombatTab:CreateButton({
   Name = "Enable Gun Mod (No Recoil/Fast)",
   Callback = function()
       _G.GunMod = true
       Rayfield:Notify({Title = "Admin", Content = "Gun Mod Activated!", Duration = 2})
   end,
})

-- 🏃 MOVEMENT TAB
local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value) Player.Character.Humanoid.WalkSpeed = Value end,
})

-- ⚙️ CORE LOGIC (ეს ნაწილი ამუშავებს ყველაფერს)

-- ფუნქცია უახლოესი მტრის საპოვნელად
local function GetClosest()
    local target = nil
    local dist = _G.FOV
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

-- იარაღის აჩქარება და მოდიფიკაცია
game:GetService("RunService").Heartbeat:Connect(function()
    if _G.GunMod then
        local tool = Player.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("GunSettings") then
            local s = require(tool.GunSettings)
            s.Recoil = 0
            s.Spread = 0
            s.ReloadTime = 0.01
            s.BulletSpeed = 10000 -- ტყვია მომენტალურად ხვდება
        end
    end
end)

-- Silent Aim (Hooking Method - არ ბლოკავს კამერას)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if _G.SilentAim and not checkcaller() and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local t = GetClosest()
        if t then
            if method == "FindPartOnRayWithIgnoreList" then
                args[1] = Ray.new(Camera.CFrame.Position, (t.Character.Head.Position - Camera.CFrame.Position).Unit * 1000)
            elseif method == "Raycast" then
                args[2] = (t.Character.Head.Position - args[1]).Unit * 1000
            end
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)
