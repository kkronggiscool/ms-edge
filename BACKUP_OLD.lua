local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local PlayerSpeed = 16
_G.isFullBrightEnabled = false
local IsInstantInteractEnabled = false
local IsRemoveAllGatesEnabled = false

local Window = Rayfield:CreateWindow({
    Name = "msedge",
    Icon = 0,
    LoadingTitle = "msedge",
    LoadingSubtitle = "microsoft edge, a script hub",
    Theme = "Default",

    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,

    ConfigurationSaving = {
        Enabled = true,
        FolderName = "msedge",
        FileName = "msedge",
    },

    keySystem = false,
})

local normalLightingSettings = {}

local function saveLightingSettings()
    local lighting = game:GetService("Lighting")
    normalLightingSettings = {
        Brightness = lighting.Brightness,
        ClockTime = lighting.ClockTime,
        FogEnd = lighting.FogEnd,
        GlobalShadows = lighting.GlobalShadows,
        Ambient = lighting.Ambient
    }
end

local function restoreLighting()
    local lighting = game:GetService("Lighting")
    if normalLightingSettings.Brightness then
        lighting.Brightness = normalLightingSettings.Brightness
        lighting.ClockTime = normalLightingSettings.ClockTime
        lighting.FogEnd = normalLightingSettings.FogEnd
        lighting.GlobalShadows = normalLightingSettings.GlobalShadows
        lighting.Ambient = normalLightingSettings.Ambient
    end
end

local function applyFullBright()
    local lighting = game:GetService("Lighting")
    lighting.Brightness = 1
    lighting.ClockTime = 12
    lighting.FogEnd = 786543
    lighting.GlobalShadows = false
    lighting.Ambient = Color3.fromRGB(178, 178, 178)
end

local function monitorLighting()
    local lighting = game:GetService("Lighting")
    
    -- Monitor all relevant lighting properties
    lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
        if _G.isFullBrightEnabled and lighting.Brightness ~= 1 then
            applyFullBright()
        end
    end)

    lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
        if _G.isFullBrightEnabled and lighting.ClockTime ~= 12 then
            applyFullBright()
        end
    end)

    lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
        if _G.isFullBrightEnabled and lighting.FogEnd ~= 786543 then
            applyFullBright()
        end
    end)

    lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
        if _G.isFullBrightEnabled and lighting.GlobalShadows ~= false then
            applyFullBright()
        end
    end)

    lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
        if _G.isFullBrightEnabled and lighting.Ambient ~= Color3.fromRGB(178, 178, 178) then
            applyFullBright()
        end
    end)
end

local function toggleFullBright(enabled)
    if enabled then
        saveLightingSettings()
        applyFullBright()
    else
        restoreLighting()
    end
end

Rayfield:Notify({
    Title = "Window loaded",
    Content = "Main window has been loaded successfully",
    Duration = 3,
    Image = 4483362458,
})

local General = Window:CreateTab("General", "gamepad-2")
local SpeedSlider = General:CreateSlider({
    Name = "Speed",
    Range = {0, 100},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "SpeedSlider1",
    Callback = function(Speed)
        PlayerSpeed = Speed
    end,
})

local FullbrightToggle = General:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "FbToggle",
    Callback = function(bool)
        _G.isFullBrightEnabled = bool
        toggleFullBright(_G.isFullBrightEnabled)
    end,
})

local InstantInteractToggle = General:CreateToggle({
    Name = "Instant Interact",
    CurrentValue = false,
    Flag = "ITToggle",
    Callback = function(bool)
        IsInstantInteractEnabled = bool

        for i, v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.HoldDuration = 0
            end
        end
    end,
})

local RemoveGatesToggle = General:CreateToggle({
    Name = "Remove Gates",
    CurrentValue = false,
    Flag = "RGToggle",
    Callback = function(bool)
        IsRemoveAllGatesEnabled = bool

        for i, v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("Model") and (v.Name == "Gate" or v.Name == "VentGate" or v.Name == "FireplaceBottom") then
                v:Destroy()
            end
        end        
    end,
})

game.Workspace.DescendantAdded:Connect(function(des)
    if IsInstantInteractEnabled == true then
        if des:IsA("ProximityPrompt") then
            des.HoldDuration = 0
        end
    end

    if IsRemoveAllGatesEnabled == true then
        if des:IsA("Model") and (des.Name == "Gate" or des.Name == "VentGate" or des.Name == "FireplaceBottom") then
            des:Destroy()
        end        
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = PlayerSpeed
    end
end)

game.Players.LocalPlayer.Character.Humanoid.HealthChanged:Connect(function()
    game.Players.LocalPlayer.Character.Humanoid.Health = game.Players.Character.LocalPlayer.Humanoid.MaxHealth
end)

-- Start monitoring lighting changes
monitorLighting()
