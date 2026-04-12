local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- პარამეტრები
_G.FullSilentAim = false
_G.ESP = false
_G.GunMod = false
_G.Radius = 1000 -- მანძილი, რა მანძილზეც მუშაობს "ავტო-მოხვედრა"

-- შეტყობინება ჩატში
game.StarterGui:SetCore("ChatMakeSystemMessage", {
    Text = "[LUCIFER ADMIN]: Commands: .aimbot, .esp, .gunmode";
    Color = Color3.fromRGB(255, 0, 0);
    Font = Enum.Font.SourceSansBold;
})

-- ფუნქცია უახლოესი მოთამაშის საპოვნელად (კამერის მიუხედავად)
local function GetClosestToPlayer()
    local target = nil
    local shortestDistance = _G.Radius

    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("Head") then
            local distance = (Player.Character.HumanoidRootPart.Position - v.Character.Head.Position).Magnitude
            if distance < shortestDistance then
                target = v
                shortestDistance = distance
            end
        end
    end
    return target
end

-- ჩატის ბრძანებები
Player.Chatted:Connect(function(msg)
    local cmd = msg:lower()
    if cmd == ".aimbot" then
        _G.FullSilentAim = not _G.FullSilentAim
        print("Aimbot status: " .. tostring(_G.FullSilentAim))
    elseif cmd == ".esp" then
        _G.ESP = not _G.ESP
    elseif cmd == ".gunmode" or cmd == ".gun mode" then
        _G.GunMod = true
        local function Patch(v)
            if v:IsA("Tool") then
                local s = v:FindFirstChild("GunSettings") or v:FindFirstChildOfClass("ModuleScript")
                if s then
                    local m = require(s)
                    m.Recoil = 0
                    m.Spread = 0
                    m.ReloadTime = 0
                    m.BulletSpeed = 10000 -- ტყვია მომენტალურად ხვდება
                end
            end
        end
        for _, t in pairs(Player.Backpack:GetChildren()) do Patch(t) end
        if Player.Character:FindFirstChildOfClass("Tool") then Patch(Player.Character:FindFirstChildOfClass("Tool")) end
    end
end)

-- მთავარი "ჯადოსნური" ფუნქცია (Hooking)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- თუ ჩართულია FullSilentAim, საერთოდ არ ვაქცევთ ყურადღებას საით ისვრი
    if _G.FullSilentAim and not checkcaller() and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local t = GetClosestToPlayer()
        if t and t.Character and t.Character:FindFirstChild("Head") then
            local head = t.Character.Head
            
            -- აქ ხდება გადაწერა: სადაც არ უნდა ისროლო, სერვერს ვეუბნებით რომ მტრის თავს ვესროლეთ
            if method == "FindPartOnRayWithIgnoreList" then
                args[1] = Ray.new(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 1000)
            elseif method == "Raycast" then
                args[2] = (head.Position - args[1]).Unit * 1000
            end
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

-- ESP Loop
RunService.RenderStepped:Connect(function()
    if _G.ESP then
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
