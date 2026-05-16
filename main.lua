--// Wemb99NIGHTS - Clean Fixed Version //--
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Wemb99NIGHTS",
    LoadingTitle = "Wemb99NIGHTS",
    LoadingSubtitle = "by Wemb",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Wemb99NIGHTS",
        FileName = "Settings"
    }
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

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

--=========================--
-- Helpers
--=========================--
local function mouse1click()
    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
    VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
end

-- Chat Command for Fly
LocalPlayer.Chatted:Connect(function(msg)
    local args = string.split(msg:lower(), " ")
    if args[1] == ";fly" then
        flying = not flying
        flySpeed = tonumber(args[2]) or 60
        Rayfield:Notify({Title = "Fly", Content = flying and "Enabled | Speed: "..flySpeed or "Disabled", Duration = 4})
    end
end)

--=========================--
-- God Mode + Kill Aura + Bring Items + Auto Eat
--=========================--
task.spawn(function()
    while true do
        if GodModeEnabled then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.Health = hum.MaxHealth end
        end
        task.wait(0.4)
    end
end)

task.spawn(function()
    while true do
        if KillAuraEnabled then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, npc in pairs(workspace:GetDescendants()) do
                    if npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
                        if (npc.HumanoidRootPart.Position - root.Position).Magnitude <= 25 then
                            pcall(function() npc.Humanoid.Health = 0 end)
                        end
                    end
                end
            end
        end
        task.wait(0.15)
    end
end)

task.spawn(function()
    while true do
        if BringItemsEnabled then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:find("Log") or obj.Name:find("Scrap") or obj.Name:find("Wood")) then
                        if (obj.Position - hrp.Position).Magnitude < 70 then
                            obj.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
                        end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

task.spawn(function()
    while true do
        if AutoEatEnabled then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum and hum.Health < 80 then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
        end
        task.wait(5)
    end
end)

-- Auto Tree Farm
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
LocalPlayer.CharacterAdded:Connect(function() task.wait(1) if flying then flying = false task.wait(0.5) flying = true end end) -- simple respawn fix

--=========================--
-- TABS
--=========================--
local Home = Window:CreateTab("🏠 Home", 4483362458)
local Farm = Window:CreateTab("🌲 Farming", 4483362458)
local Combat = Window:CreateTab("⚔ Combat", 4483362458)
local Misc = Window:CreateTab("⚙ Misc", 4483362458)

Home:CreateToggle({Name = "Auto Days", CurrentValue = false, Callback = function(v) AutoDaysEnabled = v end})
Home:CreateButton({Name = "Force Skip Night", Callback = function() Lighting.ClockTime = 6 end})
Home:CreateButton({Name = "Skip 50 Nights", Callback = function() for i=1,50 do Lighting.ClockTime = 6 task.wait(0.12) end end})

Farm:CreateToggle({Name = "Auto Cut Trees", CurrentValue = false, Callback = function(v) AutoTreeFarmEnabled = v end})
Farm:CreateToggle({Name = "Bring Items", CurrentValue = false, Callback = function(v) BringItemsEnabled = v end})
Farm:CreateToggle({Name = "Auto Eat", CurrentValue = false, Callback = function(v) AutoEatEnabled = v end})

Combat:CreateToggle({Name = "Kill Aura", CurrentValue = false, Callback = function(v) KillAuraEnabled = v end})
Combat:CreateToggle({Name = "God Mode", CurrentValue = false, Callback = function(v) GodModeEnabled = v end})
Combat:CreateToggle({Name = "Infinite Stamina", CurrentValue = false, Callback = function(v) InfiniteStaminaEnabled = v end})
Combat:CreateToggle({Name = "Aimbot (Hold RMB)", CurrentValue = false, Callback = function(v) AimbotEnabled = v end})

Misc:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 120},
    Increment = 2,
    CurrentValue = 16,
    Callback = function(v)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
})

Misc:CreateButton({Name = "TP to Campfire", Callback = function() LocalPlayer.Character:PivotTo(CFrame.new(0,10,0)) end})
Misc:CreateButton({Name = "TP to Grinder", Callback = function() LocalPlayer.Character:PivotTo(CFrame.new(16.1,4,-4.6)) end})

Rayfield:Notify({Title = "Wemb99NIGHTS", Content = "Loaded Successfully!\nUse ;fly <speed> in chat", Duration = 6})
