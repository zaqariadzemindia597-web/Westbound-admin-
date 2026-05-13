local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- შეტყობინება, რომ სკრიპტი ჩაიტვირთა
Rayfield:Notify({
   Title = "Mindia Admin Loaded",
   Content = "გამოიყენე ჩატი ბრძანებებისთვის!",
   Duration = 5,
   Image = 4483362458,
})

-- --- ცვლადები ---
_G.SilentAim = false
_G.ESP_Enabled = false

-- --- ჩატის ბრძანებების სისტემა ---
game.Players.LocalPlayer.Chatted:Connect(function(msg)
    local args = string.split(msg, " ")
    
    -- 1. Aimbot: /aim on/off
    if args[1] == "/aim" then
        if args[2] == "on" then
            _G.SilentAim = true
            Rayfield:Notify({Title = "Aimbot", Content = "ჩაირთო ✅", Duration = 2})
        else
            _G.SilentAim = false
            Rayfield:Notify({Title = "Aimbot", Content = "გაითიშა ❌", Duration = 2})
        end

    -- 2. ESP: /esp on/off
    elseif args[1] == "/esp" then
        if args[2] == "on" then
            _G.ESP_Enabled = true
            Rayfield:Notify({Title = "ESP", Content = "Wallhack აქტიურია 👁️", Duration = 2})
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
                                b.Transparency = 0.6
                                b.Color3 = Color3.fromRGB(0, 255, 255) -- ციანი ფერი Rayfield-ის სტილში
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
            Rayfield:Notify({Title = "ESP", Content = "გაითიშა ❌", Duration = 2})
        end

    -- 3. სწრაფი გადატენვა: /reload
    elseif args[1] == "/reload" then
        for _, v in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") and v:FindFirstChild("Stats") then
                if v.Stats:FindFirstChild("ReloadTime") then v.Stats.ReloadTime.Value = 0.01 end
                if v.Stats:FindFirstChild("FireRate") then v.Stats.FireRate.Value = 0.05 end
            end
        end
        Rayfield:Notify({Title = "Weapons", Content = "Instant Reload აქტიურია! ⚡", Duration = 2})

    -- 4. სიჩქარე: /speed [ნომერი]
    elseif args[1] == "/speed" and args[2] then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(args[2])
        Rayfield:Notify({Title = "Speed", Content = "სიჩქარე: " .. args[2], Duration = 2})

    -- 5. ბანკის ძარცვა: /rob
    elseif args[1] == "/rob" then
        game:GetService("ReplicatedStorage").GeneralEvents.Rob:FireServer("Safe", workspace:FindFirstChild("Safe"))
        Rayfield:Notify({Title = "Robbery", Content = "სეიფის ძარცვა დაწყებულია! 💰", Duration = 3})

    -- 6. ბანკში ტელეპორტი: /bank
    elseif args[1] == "/bank" then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(171, 37, -789)
    end
end)

-- --- SILENT AIM LOGIC (იგივე რჩება) ---
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
            args[1][1].Hit
                
