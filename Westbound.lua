local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
-- BloodTheme-ის ნაცვლად გამოვიყენოთ "DarkTheme" და მცირე ზომის ფანჯარა
local Window = Library.CreateLib("🌵 Westbound Mobile", "DarkTheme")

-- ფუნქციების სექციები უფრო პატარა სათაურებით
local Combat = Window:NewTab("Combat")
local CSec = Combat:NewSection("Shooting")

_G.SilentAim = false
CSec:NewToggle("Silent Aim", "ავტო-მიზანი", function(state)
    _G.SilentAim = state
end)

_G.InfAmmo = false
CSec:NewToggle("Inf Ammo", "ტყვიები", function(state)
    _G.InfAmmo = state
    spawn(function()
        while _G.InfAmmo do
            local am = game:GetService("Players").LocalPlayer:FindFirstChild("Consumables")
            if am and am:FindFirstChild("PistolAmmo") then
                game:GetService("ReplicatedStorage").GunScripts.Events.UseAmmo:FireServer(am.PistolAmmo)
            end
            task.wait(0.8) -- ოდნავ მეტი პაუზა ტელეფონისთვის
        end
    end)
end)

local Farm = Window:NewTab("Farm")
local FSec = Farm:NewSection("Robbery")

FSec:NewButton("Rob Safe", "სეიფის გაძარცვა", function()
    game:GetService("ReplicatedStorage").GeneralEvents.Rob:FireServer("Safe", workspace:FindFirstChild("Safe"))
end)

local Play = Window:NewTab("Player")
local PS = Play:NewSection("Move")

PS:NewSlider("Speed", "სირბილი", 100, 16, function(s)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
end)

-- --- SILENT AIM LOGIC (იგივე რჩება) ---
local function getCl()
    local cp, sd = nil, math.huge
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
            local dist = (game.Players.LocalPlayer.Character.Head.Position - v.Character.Head.Position).magnitude
            if dist < sd then cp, sd = v, dist end
        end
    end
    return cp
end

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if _G.SilentAim and getnamecallmethod() == "FireServer" and self.Name == "GunShot" then
        local t = getCl()
        if t then
            args[1][1].HitPart = t.Character.Head
            args[1][1].HitHum = t.Character.Humanoid
            args[1][1].HitPosition = t.Character.Head.Position
            args[1][1].EndPoint = t.Character.Head.Position
            args[1][1].RootPosition = t.Character.HumanoidRootPart.Position
        end
    end
    return old(self, unpack(args))
end)
setreadonly(mt, true)
