local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Westbound Mobile FIXED",
   LoadingTitle = "Bypassing Systems...",
   ConfigurationSaving = {Enabled = false}
})

_G.SilentAim = false
_G.ESP = false
_G.FOV = 200

local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local MainTab = Window:CreateTab("Main", 4483362458)

-- 1. SILENT AIM (ახალი მეთოდი)
MainTab:CreateToggle({
   Name = "Silent Aim",
   CurrentValue = false,
   Callback = function(Value) _G.SilentAim = Value end,
})

-- 2. ESP
MainTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Callback = function(Value) _G.ESP = Value end,
})

-- 3. GUN MOD (Force Update)
MainTab:CreateButton({
   Name = "Fix Gun (No Recoil/Fast Reload)",
   Callback = function()
       local function Patch(tool)
           if tool:IsA("Tool") then
               -- ვეძებთ პარამეტრებს პირდაპირ იარაღის სკრიპტებში
               for _, v in pairs(tool:GetDescendants()) do
                   if v:IsA("NumberValue") or v:IsA("IntValue") then
                       if v.Name:find("Recoil") or v.Name:find("Spread") then
                           v.Value = 0
                       elseif v.Name:find("Reload") then
                           v.Value = 0.1
                       end
                   end
               end
           end
       end
       
       if Player.Character:FindFirstChildOfClass("Tool") then
           Patch(Player.Character:FindFirstChildOfClass("Tool"))
       end
       for _, tool in pairs(Player.Backpack:GetChildren()) do
           Patch(tool)
       end
       Rayfield:Notify({Title = "Applied", Content = "Gun values forced to 0", Duration = 2})
   end,
})

-- სამიზნის პოვნის ლოგიკა
local function GetClosest()
    local target = nil
    local dist = _G.FOV
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("Head") then
            local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
            if vis then
                local m = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if m < dist then
                    target = v
                    dist = m
                end
            end
        end
    end
    return target
end

-- მთავარი ციკლი (Loop)
RunService.RenderStepped:Connect(function()
    -- Silent Aim (ეკრანის გატოკების გარეშე დამიზნება სროლისას)
    if _G.SilentAim then
        local t = GetClosest()
        if t and Player.Character:FindFirstChildOfClass("Tool") then
            -- ეს ცვლის მაუსის სამიზნეს პირდაპირ სერვერისთვის
            local tool = Player.Character:FindFirstChildOfClass("Tool")
            if tool:FindFirstChild("MousePos") then
                tool.MousePos.Value = t.Character.Head.Position
            end
        end
    end

    -- ESP
    if _G.ESP then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not p.Character:FindFirstChild("Highlight") then
                    Instance.new("Highlight", p.Character)
                end
            else
                if p.Character and p.Character:FindFirstChild("Highlight") then
                    p.Character.Highlight:Destroy()
                end
            end
        end
    end
end)
