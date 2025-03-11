local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local PlayerSpeed = 16
_G.isFullBrightEnabled = false
local IsInstantInteractEnabled = false
local IsRemoveAllGatesEnabled = false
local FieldOfViewVal = 70
local camera = workspace.CurrentCamera
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local InteractThruWallsEnabled = false

local function maintainCamera()
    -- Ensure the camera is in 'Custom' and adjust FOV
    game:GetService("RunService").RenderStepped:Connect(function()
        if camera.CameraType == Enum.CameraType.Scriptable then
            -- Temporarily change the CameraType to 'Custom'
            camera.CameraType = Enum.CameraType.Custom
            
            -- Set the FieldOfView to simulate zooming out (increase the value to zoom out)
            camera.FieldOfView = FieldOfViewVal  -- Adjust this to your desired zoomed-out value
        end
    end)
end

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
    Duration = 10,
    Image = 4483362458,
})

local General = Window:CreateTab("General", "gamepad-2")
local Visuals = Window:CreateTab("Visuals", "eye")
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

        -- Using Debris to safely destroy gates and models
        local DebrisService = game:GetService("Debris")
        for i, v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("Model") and (v.Name == "Gate" or v.Name == "VentGrate" or v.Name == "MovingDoor" or v.Name == "FireplaceBottom") then
                -- Add objects to Debris for automatic removal after a brief time
                v:Destroy() -- Remove the object immediately
                DebrisService:AddItem(v, 0) -- No delay, just remove it from the workspace
            end
        end        
    end,
})

local FOVInp = Visuals:CreateInput({
    Name = "FOV",
    CurrentValue = "70",
    PlaceholderText = "70",
    RemoveTextAfterFocusLost = true,
    Flag = "FOVInput1",
    Callback = function(num)
        if not tonumber(num) then
            warn("not a number")
        else
            FieldOfViewVal = num
            print(FieldOfViewVal)
        end
    end
})

local InteractThruWallsToggle = General:CreateToggle({
    Name = "Interact through walls",
    CurrentValue = false,
    Flag = "ITWToggle",
    Callback = function(bool)
        InteractThruWallsEnabled = bool

        for i, v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.RequiresLineOfSight = false
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

    if InteractThruWallsEnabled == true then
        if des:IsA("ProximityPrompt") then
            des.RequiresLineOfSight = false
        end
    end

    if IsRemoveAllGatesEnabled == true then
        if des:IsA("Model") and (des.Name == "Gate" or des.Name == "VentGrate" or des.Name == "MovingDoor" or des.Name == "FireplaceBottom") then
            -- Use Debris to clean up gates when they are added
            local DebrisService = game:GetService("Debris")
            DebrisService:AddItem(des, 0) -- Immediately remove from workspace
            des:Destroy()
        end        
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    local player = game.Players.LocalPlayer
    
    -- Check if the player and humanoid exist
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = PlayerSpeed
    end
end)

game.Players.LocalPlayer.Character.Humanoid.HealthChanged:Connect(function()
    game.Players.LocalPlayer.Character.Humanoid.Health = game.Players.Character.LocalPlayer.Humanoid.MaxHealth
end)

-- Start monitoring lighting changes
monitorLighting()
maintainCamera()

Rayfield:LoadConfiguration()