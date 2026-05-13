local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("🌵 Westbound PRO (Mindia)", "DarkTheme")

-- --- ცვლადები ---
_G.SilentAim = false
_G.InfAmmo = false
_G.ESP_Enabled = false

-- --- მენიუს ტაბები ---
local Main = Window:NewTab("Main")
local MSec = Main:NewSection("Combat & Farm")

MSec:NewToggle("Silent Aim", "ავტო-გარტყმა", function(state) _G.SilentAim = state end)
MSec:NewToggle("Inf Ammo", "უსასრულო ტყვიები", function(state)
    _G.InfAmmo = state
    spawn(function()
        while _G.InfAmmo do
            local am = game:GetService("Players").LocalPlayer:FindFirstChild("Consumables")
            if am and am:FindFirstChild("PistolAmmo") then
                game:GetService("ReplicatedStorage").GunScripts.Events.UseAmmo:FireServer(am.PistolAmmo)
            end
            task.wait(0.8)
        end
    end)
end)

MSec:NewButton("Rob Safe", "სეიფის გაძარცვა", function()
    game:GetService("ReplicatedStorage").GeneralEvents.Rob:FireServer("Safe", workspace:FindFirstChild("Safe"))
end)

local Play = Window:NewTab("Player")
local PS = Play:NewSection("Settings")
PS:NewSlider("Speed", "სირბილი", 150, 16, function(s) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s end)

-- --- CHAT COMMANDS SYSTEM ---
game.Players.LocalPlayer.Chatted:Connect(function(msg)
    local args = string.split(msg, " ")
    
    -- /speed [რიცხვი]
    if args[1] == "/speed" and args[2] then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(args[2])
    
    -- /rob
    elseif args[1] == "/rob" then
        game:GetService("ReplicatedStorage").GeneralEvents.Rob:FireServer("Safe", workspace:FindFirstChild("Safe"))
    
    -- /aim on/off
    elseif args[1] == "/aim" then
        _G.SilentAim = (args[2] == "on")
    
    -- /reload (სწრაფი გადატენვა)
    elseif args[1] == "/reload" then
        for _, v in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") and v:FindFirstChild("Stats") then
                if v.Stats:FindFirstChild("ReloadTime") then v.Stats.ReloadTime.Value = 0.01 end
                if v.Stats:FindFirstChild("FireRate") then v.Stats.FireRate.Value = 0.05 end
            end
        end

    -- /esp on/off
    elseif args[1] == "/esp" then
        if args[2] == "on" then
            _G.ESP_Enabled = true
            spawn(function()
                while _G.ESP_Enabled do
                    for _, p in pairs(game.Players:GetPlayers()) do
                        if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local hrp = p.Character.HumanoidRootPart
                            if not hrp:FindFirstChild("MindiaESP") then
                                local b = Instance.new("BoxHandleAdornment", hrp)
                                b.Name = "MindiaESP"
                                b.Adornee = hrp
                                b.AlwaysOnTop = true
                                b.Size = Vector3.new(4, 5.5, 1)
                                b.Transparency = 0.5
                                b.Color3 = Color3.new(1, 0, 0)
                            end
                        end
                    end
                    task.wait(2)
                end
            end)
        else
            _G.ESP_Enabled = false
            for _, v in pairs(game.Players:GetPlayers()) do
                if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.HumanoidRootPart:FindFirstChild("MindiaESP") then
                    v.Character.HumanoidRootPart.MindiaESP:Destroy()
                end
            end
        end

    -- /bank (ტელეპორტი)
    elseif args[1] == "/bank" then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(171, 37, -789)
    end
end)

-- --- SILENT AIM LOGIC (Metatable Hook) ---
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if _G.SilentAim and getnamecallmethod() == "FireServer" and self.Name == "GunShot" then
        local target = nil
        local dist = math.huge
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                local d = (game.Players.LocalPlayer.Character.Head.Position - v.Character.Head.Position).magnitude
                if d < dist then target, dist = v, d end
            end
        end
        if target then
            args[1][1].HitPart = target.Character.Head
            args[1][1].HitHum = target.Character.Humanoid
            args[1][1].HitPosition = target.Character.Head.Position
            args[1][1].EndPoint = target.Character.Head.Position
        end
    end
    return old(self, unpack(args))
end)
setreadonly(mt, true)
