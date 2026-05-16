--// Wemb99NIGHTS v4 - Full Neon Pink/Cyan //--
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

Rayfield:LoadCustomTheme({
    Accent = Color3.fromRGB(255, 20, 147),
    Outline = Color3.fromRGB(0, 255, 255),
    Background = Color3.fromRGB(10, 10, 18),
    TextColor = Color3.fromRGB(255, 255, 255),
    Topbar = Color3.fromRGB(20, 20, 35),
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({
    Name = "Wemb99NIGHTS",
    LoadingTitle = "Wemb99NIGHTS",
    LoadingSubtitle = "by Wemb",
    ConfigurationSaving = {Enabled = true, FolderName = "Wemb99NIGHTS"},
})

-- States
local AimbotEnabled = false
local AutoTreeFarmEnabled = false
local AutoDaysEnabled = false
local KillAuraEnabled = false
local BringItemsEnabled = false
local GodModeEnabled = false
local AutoEatEnabled = false
local InfiniteStaminaEnabled = false
local flying = false
local flySpeed = 60
local currentWalkSpeed = 16

--=========================--
-- Helpers
--=========================--
local function mouse1click()
    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
    VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
end

-- Chat Command
LocalPlayer.Chatted:Connect(function(msg)
    local args = string.split(msg:lower(), " ")
    if args[1] == ";fly" then
        flying = not flying
        flySpeed = tonumber(args[2]) or 60
        Rayfield:Notify({Title="Fly", Content = flying and "ON | Speed "..flySpeed or "OFF", Duration=3})
    end
end)

--=========================--
-- Core Features
--=========================--

-- God Mode
task.spawn(function()
    while true do
        if GodModeEnabled then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.Health = hum.MaxHealth end
        end
        task.wait(0.3)
    end
end)

-- Kill Aura
task.spawn(function()
    while true do
        if KillAuraEnabled then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, npc in pairs(workspace:GetDescendants()) do
                    local hrp = npc:FindFirstChild("HumanoidRootPart")
                    local hum = npc:FindFirstChild("Humanoid")
                    if hrp and hum and (hrp.Position - root.Position).Magnitude <= 25 then
                        hum.Health = 0
                    end
                end
            end
        end
        task.wait(0.15)
    end
end)

-- Bring Items
task.spawn(function()
    while true do
        if BringItemsEnabled then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:find("Log") or obj.Name:find("Scrap") or obj.Name:find("Wood") or obj.Name:find("Coal")) then
                        if (obj.Position - hrp.Position).Magnitude < 70 then
                            obj.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
                        end
                    end
                end
            end
        end
        task.wait(0.25)
    end
end)

-- Auto Eat
task.spawn(function()
    while true do
        if AutoEatEnabled then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum and hum.Health < 85 then
                -- Try pressing E (common eat key)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
        end
        task.wait(4)
    end
end)

-- Infinite Stamina
task.spawn(function()
    while true do
        if InfiniteStaminaEnabled then
            local char = LocalPlayer.Character
            if char then
                -- Most survival games store stamina in Humanoid or a value
                local stamina = char:FindFirstChild("Stamina") or char:FindFirstChild("SprintStamina")
                if stamina then stamina.Value = 100 end
            end
        end
        task.wait(0.5)
    end
end)

-- Auto Tree Farm (Auto Cut)
local badTrees = {}
task.spawn(function()
    while true do
        if AutoTreeFarmEnabled then
            local trees = {}
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "Trunk" and obj.Parent and obj.Parent.Name == "Small Tree" and not badTrees[obj:GetFullName()] then
                    table.insert(trees, obj)
                end
            end
            table.sort(trees, function(a,b)
                return (a.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < (b.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            end)

            for _, trunk in ipairs(trees) do
                if not AutoTreeFarmEnabled then break end
                LocalPlayer.Character:PivotTo(trunk.CFrame + Vector3.new(0,3,0))
                task.wait(0.2)
                local start = tick()
                while AutoTreeFarmEnabled and trunk.Parent do
                    mouse1click()
                    task.wait(0.18)
                    if tick() - start > 10 then badTrees[trunk:GetFullName()] = true break end
                end
                task.wait(0.3)
            end
        end
        task.wait(1)
    end
end)

-- Fly
local flyConnection
local function updateFly()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if flying then
        local bg = Instance.new("BodyGyro", hrp) bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
        local bv = Instance.new("BodyVelocity", hrp) bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        flyConnection = RunService.RenderStepped:Connect(function()
            local move = Vector3.zero
            local cf = camera.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += cf.UpVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= cf.UpVector end
            bv.Velocity = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.zero
            bg.CFrame = cf
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        for _,v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
        end
    end
end

--=========================--
-- TABS
--=========================--
local Home = Window:CreateTab("🏠 Home", 4483362458)
local Farm = Window:CreateTab("🌲 Farming", 4483362458)
local Combat = Window:CreateTab("⚔ Combat", 4483362458)
local Visuals = Window:CreateTab("👁 Visuals", 4483362458)
local Misc = Window:CreateTab("⚙ Misc", 4483362458)

-- Home
Home:CreateToggle({Name = "Auto Days", Callback = function(v) AutoDaysEnabled = v end})
Home:CreateButton({Name = "Force Skip Night", Callback = function() Lighting.ClockTime = 6 end})
Home:CreateButton({Name = "Skip 50 Nights", Callback = function() for i=1,50 do Lighting.ClockTime = 6 task.wait(0.1) end end})

-- Farming
Farm:CreateToggle({Name = "Auto Cut Trees", Callback = function(v) AutoTreeFarmEnabled = v end})
Farm:CreateToggle({Name = "Bring Items (Logs/Scrap)", Callback = function(v) BringItemsEnabled = v end})
Farm:CreateToggle({Name = "Auto Eat", Callback = function(v) AutoEatEnabled = v end})

-- Combat
Combat:CreateToggle({Name = "Kill Aura (25 studs)", Callback = function(v) KillAuraEnabled = v end})
Combat:CreateToggle({Name = "Aimbot (Hold Right Click)", Callback = function(v) AimbotEnabled = v end})
Combat:CreateToggle({Name = "God Mode", Callback = function(v) GodModeEnabled = v end})
Combat:CreateToggle({Name = "Infinite Stamina", Callback = function(v) InfiniteStaminaEnabled = v end})

-- Visuals
Visuals:CreateToggle({Name = "Item ESP", Callback = function(v) end}) -- you can expand later
Visuals:CreateToggle({Name = "NPC ESP", Callback = function(v) end})

-- Misc
Misc:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 120},
    Increment = 2,
    CurrentValue = 16,
    Callback = function(v)
        currentWalkSpeed = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
})

Misc:CreateButton({Name = "TP to Campfire", Callback = function() LocalPlayer.Character:PivotTo(CFrame.new(0,10,0)) end})
Misc:CreateButton({Name = "TP to Grinder", Callback = function() LocalPlayer.Character:PivotTo(CFrame.new(16.1,4,-4.6)) end})
Misc:CreateToggle({Name = "No Fog", Callback = function(v)
    if v then Lighting.FogStart = 999999 Lighting.FogEnd = 1000000
    else Lighting.FogStart = 0 Lighting.FogEnd = 100000 end
end})

Rayfield:Notify({
    Title = "Wemb99NIGHTS v4 LOADED",
    Content = "Auto Eat + Infinite Stamina + Speed Slider added\nUse ;fly <speed> in chat",
    Duration = 8
})
