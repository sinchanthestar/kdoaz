local blockedKeywords = {
    "octo", "simplespy", "hydroxide", "remotespy", "remotesniffer", 
    "spyremote", "logremote", "remotelistener", "remotelogger", 
    "remotedetector", "remotemonitor", "remotedebug", "universalspy"
}

local oldLoadstring
oldLoadstring = hookfunction(loadstring, function(src)
    if type(src) == "string" then
        local lower = src:lower()
        for _, keyword in pairs(blockedKeywords) do
            if lower:find(keyword) then
                game:GetService("Players").LocalPlayer:Kick(
                    "[AIKOWARE]: stop skidding brochacho 😹"
                )
                return function() end
            end
        end
    end
    return oldLoadstring(src)
end)

local AIKO = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/src/Library.lua"))()

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local Stats = game:GetService('Stats')
local Debris = game:GetService('Debris')
local CoreGui = game:GetService('CoreGui')
local Runtime = workspace:FindFirstChild("Runtime") or workspace:WaitForChild("Runtime", 10)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Alive = workspace:FindFirstChild("Alive")

getgenv().skinChangerEnabled = false
getgenv().swordModel = ""
getgenv().swordAnimations = ""
getgenv().swordFX = ""
getgenv().originalSword = nil
getgenv().autoparry = false

local Window = AIKO:Window({
    Title = "Aikoware |",
    Footer = "made by @aoki!",
    Version = 1,
})

local Tabs = {
    Info = Window:AddTab({ Name = "Info", Icon = "info" }),
    Autoparry = Window:AddTab({ Name = "Parry", Icon = "shield" }),
    Player = Window:AddTab({ Name = "Player", Icon = "user" }),
    Visuals = Window:AddTab({ Name = "Visual", Icon = "eye" }),
    Misc = Window:AddTab({ Name = "Misc", Icon = "settings" }),
}

local InfoSection = Tabs.Info:AddSection("Support", true)

InfoSection:AddParagraph({
    Title = "Note",
    Content = "The script for this game is still in beta, so expect some bugs.",
    Icon = "idea",
})

B
InfoSection:AddButton({
    Title = "Rejoin",
    SubTitle = "Server Hop",
    Callback = function()
        aiko("Rejoining server...")
        task.wait(1)
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end,
    SubCallback = function()
        aiko("Finding new server...")
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Servers = Http:JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" ..
            game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, v in pairs(Servers.data) do
            if v.playing < v.maxPlayers then
                TPS:TeleportToPlaceInstance(game.PlaceId, v.id, game.Players.LocalPlayer)
                return
            end
        end
        aiko("No available servers found.")
    end
})

InfoSection:AddParagraph({
    Title = "Discord",
    Content = "Join our discord for more updates and information!",
    Icon = "discord",
    ButtonText = "Copy Server Link",
    ButtonCallback = function()
        local link = "https://discord.gg/JccfFGpDNV"
        if setclipboard then
            setclipboard(link)
            AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "Successfully Copied!",
                Content = "Discord Link Copied",
                Delay = 3
            })
        end
    end
})

local AutoparrySection = Tabs.Autoparry:AddSection("Auto Parry")

local autoparryConnection

AutoparrySection:AddToggle({
    Title = "Auto Parry",
    Default = false,
    Callback = function(enabled)
        getgenv().autoparry = enabled

        if enabled then
            local HelperModule = loadstring(game:HttpGet('https://raw.githubusercontent.com/TripleScript/TripleHub/main/helper_.lua'))()
            local hasParried = false

            if autoparryConnection then
                autoparryConnection:Disconnect()
            end

            autoparryConnection = RunService.PreRender:Connect(function()
                if not getgenv().autoparry then return end
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                
                local targetBall = HelperModule.FindTargetBall()

                if targetBall then
                    local ballVelocity = targetBall.AssemblyLinearVelocity

                    if targetBall:FindFirstChild('zoomies') then
                        ballVelocity = targetBall.zoomies.VectorVelocity
                    end

                    local ballPosition = targetBall.Position
                    local directionToPlayer = (LocalPlayer.Character.HumanoidRootPart.Position - ballPosition).Unit
                    local distanceToPlayer = LocalPlayer:DistanceFromCharacter(ballPosition)
                    local dotProduct = directionToPlayer:Dot(ballVelocity.Unit)
                    local velocityMagnitude = ballVelocity.Magnitude

                    if dotProduct > 0 then
                        local timeToReach = (distanceToPlayer - 5) / velocityMagnitude

                        if HelperModule.IsPlayerTarget(targetBall) and (timeToReach <= 0.55 and not hasParried) then
                            for _, connection in pairs(getconnections(PlayerGui.Hotbar.Block.Activated)) do
                                connection:Fire()
                            end
                            hasParried = true
                        end
                    else
                        hasParried = false
                    end
                end
            end)
        else
            if autoparryConnection then
                autoparryConnection:Disconnect()
                autoparryConnection = nil
            end
        end
    end
})

local SpamSection = Tabs.Autoparry:AddSection("Manual Spam")

local ManualSpamFrame
local ManualSpamButton
local spamConnection = nil
local isSpamming = false

SpamSection:AddToggle({
    Title = "Manual Spam",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if not ManualSpamFrame then
                local ScreenGui = Instance.new("ScreenGui")
                ScreenGui.Name = "ManualSpamGUI"
                ScreenGui.ResetOnSpawn = false
                ScreenGui.Parent = CoreGui

                ManualSpamFrame = Instance.new("Frame", ScreenGui)
                ManualSpamFrame.Size = UDim2.new(0, 180, 0, 50)
                ManualSpamFrame.Position = UDim2.new(0.5, -90, 0.8, 0)
                ManualSpamFrame.BackgroundColor3 = Color3.fromRGB(45, 0, 80)
                ManualSpamFrame.BackgroundTransparency = 0.2
                ManualSpamFrame.BorderSizePixel = 0
                ManualSpamFrame.Active = true
                ManualSpamFrame.Draggable = true

                local UICorner = Instance.new("UICorner", ManualSpamFrame)
                UICorner.CornerRadius = UDim.new(0, 12)

                local UIStroke = Instance.new("UIStroke", ManualSpamFrame)
                UIStroke.Color = Color3.fromRGB(120, 50, 200)
                UIStroke.Thickness = 2
                UIStroke.Transparency = 0.5

                local UIGradient = Instance.new("UIGradient", ManualSpamFrame)
                UIGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 0, 100)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 0, 60))
                })
                UIGradient.Rotation = 45

                ManualSpamButton = Instance.new("TextButton", ManualSpamFrame)
                ManualSpamButton.Size = UDim2.new(1, -20, 1, -10)
                ManualSpamButton.Position = UDim2.new(0, 10, 0, 5)
                ManualSpamButton.BackgroundTransparency = 1
                ManualSpamButton.Font = Enum.Font.Ubuntu
                ManualSpamButton.TextColor3 = Color3.fromRGB(200, 120, 255)
                ManualSpamButton.TextSize = 20
                ManualSpamButton.Text = "SPAM: OFF"
                ManualSpamButton.TextStrokeTransparency = 0.5
                ManualSpamButton.Active = false

                ManualSpamButton.MouseButton1Click:Connect(function()
                    isSpamming = not isSpamming
                    
                    if isSpamming then
                        ManualSpamButton.Text = "SPAM: ON"
                        ManualSpamButton.TextColor3 = Color3.fromRGB(100, 255, 150)
                        UIStroke.Color = Color3.fromRGB(50, 200, 120)
                        UIGradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 100, 60)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 60, 30))
                        })
                        
                        if spamConnection then
                            spamConnection:Disconnect()
                        end
                        
                        spamConnection = RunService.Heartbeat:Connect(function()
                            if isSpamming then
                                for _, connection in pairs(getconnections(PlayerGui.Hotbar.Block.Activated)) do
                                    connection:Fire()
                                end
                                task.wait(0.01)
                            end
                        end)
                    else
                        ManualSpamButton.Text = "SPAM: OFF"
                        ManualSpamButton.TextColor3 = Color3.fromRGB(200, 120, 255)
                        UIStroke.Color = Color3.fromRGB(120, 50, 200)
                        UIGradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 0, 100)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 0, 60))
                        })
                        
                        if spamConnection then
                            spamConnection:Disconnect()
                            spamConnection = nil
                        end
                    end
                end)
            end

            ManualSpamFrame.Visible = true
        else
            if ManualSpamFrame then
                ManualSpamFrame.Visible = false
            end
            isSpamming = false
            if ManualSpamButton then
                ManualSpamButton.Text = "SPAM: OFF"
                ManualSpamButton.TextColor3 = Color3.fromRGB(200, 120, 255)
            end
            if spamConnection then
                spamConnection:Disconnect()
                spamConnection = nil
            end
        end
    end
})

local PlayerSection = Tabs.Player:AddSection("Avatar Changer")

local __flags = {}

local function __apparence(__name)
    local s, e = pcall(function()
        local __id = Players:GetUserIdFromNameAsync(__name)
        return Players:GetHumanoidDescriptionFromUserId(__id)
    end)

    if not s then
        return nil
    end

    return e
end

local function __set(__name, __char)
    if not __name or __name == '' then
        return
    end
    
    local __hum = __char and __char:WaitForChild('Humanoid', 5)

    if not __hum then
        return
    end

    local __desc = __apparence(__name)
    
    if not __desc then
        return
    end

    LocalPlayer:ClearCharacterAppearance()
    __hum:ApplyDescriptionClientServer(__desc)
end

PlayerSection:AddToggle({
    Title = 'Change Avatar',
    Default = false,
    Callback = function(val)
        __flags['Skin Changer'] = val

        if val then
            local __char = LocalPlayer.Character

            if __char and __flags['name'] then
                __set(__flags['name'], __char)
            end

            __flags['loop'] = LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(.75)
                if __flags['name'] then
                    __set(__flags['name'], char)
                end
            end)
        else
            if __flags['loop'] then
                __flags['loop']:Disconnect()
                __flags['loop'] = nil

                local __char = LocalPlayer.Character

                if __char then
                    __set(LocalPlayer.Name, __char)
                end
            end
        end
    end
})

PlayerSection:AddInput({
    Title = "Username",
    Content = "Enter Target Player",
    Default = "",
    Callback = function(val)
        __flags['name'] = val
        
        if __flags['Skin Changer'] and val ~= '' then
            local __char = LocalPlayer.Character
            if __char then
                __set(val, __char)
            end
        end
    end
})

local PlayerSection2 = Tabs.Player:AddSection("LocalPlayer")

PlayerSection2:AddToggle({
    Title = "FOV",
    Default = false,
    Callback = function(value)
        getgenv().CameraEnabled = value
        local Camera = workspace.CurrentCamera
        
        if value then
            getgenv().CameraFOV = getgenv().CameraFOV or 70
            Camera.FieldOfView = getgenv().CameraFOV
            
            if not getgenv().FOVLoop then
                getgenv().FOVLoop = RunService.RenderStepped:Connect(function()
                    if getgenv().CameraEnabled then
                        Camera.FieldOfView = getgenv().CameraFOV
                    end
                end)
            end
        else
            Camera.FieldOfView = 70
            
            if getgenv().FOVLoop then
                getgenv().FOVLoop:Disconnect()
                getgenv().FOVLoop = nil
            end
        end
    end
})

PlayerSection2:AddSlider({
    Title = "FOV Value",
    Min = 50,
    Max = 120,
    Default = 70,
    Callback = function(value)
        getgenv().CameraFOV = value
        if getgenv().CameraEnabled then
            workspace.CurrentCamera.FieldOfView = value
        end
    end
})

PlayerSection2:AddDivider()

PlayerSection2:AddToggle({
    Title = "Enable Player Modifications",
    Default = false,
    Callback = function(value)
        getgenv().CharacterModifierEnabled = value
        
        if value then
            if not getgenv().CharacterConnection then
                getgenv().OriginalValues = {}
                getgenv().spinAngle = 0
                
                getgenv().CharacterConnection = RunService.Heartbeat:Connect(function()
                    local char = LocalPlayer.Character
                    if not char then return end
                    
                    local humanoid = char:FindFirstChild("Humanoid")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    
                    if humanoid then
                        if not getgenv().OriginalValues.WalkSpeed then
                            getgenv().OriginalValues.WalkSpeed = humanoid.WalkSpeed
                            getgenv().OriginalValues.JumpPower = humanoid.JumpPower
                            getgenv().OriginalValues.JumpHeight = humanoid.JumpHeight
                            getgenv().OriginalValues.HipHeight = humanoid.HipHeight
                            getgenv().OriginalValues.AutoRotate = humanoid.AutoRotate
                        end
                        
                        if getgenv().WalkspeedEnabled then
                            humanoid.WalkSpeed = getgenv().CustomWalkSpeed or 36
                        end
                        
                        if getgenv().JumpPowerEnabled then
                            if humanoid.UseJumpPower then
                                humanoid.JumpPower = getgenv().CustomJumpPower or 50
                            else
                                humanoid.JumpHeight = getgenv().CustomJumpHeight or 7.2
                            end
                        end
                        
                        if getgenv().HipHeightEnabled then
                            humanoid.HipHeight = getgenv().CustomHipHeight or 0
                        end
                        
                        if getgenv().SpinbotEnabled and root then
                            humanoid.AutoRotate = false
                            getgenv().spinAngle = (getgenv().spinAngle + (getgenv().CustomSpinSpeed or 5)) % 360
                            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(getgenv().spinAngle), 0)
                        end
                    end
                    
                    if getgenv().GravityEnabled and getgenv().CustomGravity then
                        workspace.Gravity = getgenv().CustomGravity
                    end
                end)
            end
        else
            if getgenv().CharacterConnection then
                getgenv().CharacterConnection:Disconnect()
                getgenv().CharacterConnection = nil
                
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") and getgenv().OriginalValues then
                    local humanoid = char.Humanoid
                    humanoid.WalkSpeed = getgenv().OriginalValues.WalkSpeed or 16
                    if humanoid.UseJumpPower then
                        humanoid.JumpPower = getgenv().OriginalValues.JumpPower or 50
                    else
                        humanoid.JumpHeight = getgenv().OriginalValues.JumpHeight or 7.2
                    end
                    humanoid.HipHeight = getgenv().OriginalValues.HipHeight or 0
                    humanoid.AutoRotate = getgenv().OriginalValues.AutoRotate or true
                end
                
                workspace.Gravity = 196.2
                
                if getgenv().InfiniteJumpConnection then
                    getgenv().InfiniteJumpConnection:Disconnect()
                    getgenv().InfiniteJumpConnection = nil
                end
            end
        end
    end
})

PlayerSection2:AddSubSection("Modifications")

PlayerSection2:AddToggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(value)
        getgenv().InfiniteJumpEnabled = value
        
        if value and getgenv().CharacterModifierEnabled then
            if not getgenv().InfiniteJumpConnection then
                getgenv().InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                    if getgenv().InfiniteJumpEnabled and getgenv().CharacterModifierEnabled then
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") then
                            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end)
            end
        else
            if getgenv().InfiniteJumpConnection then
                getgenv().InfiniteJumpConnection:Disconnect()
                getgenv().InfiniteJumpConnection = nil
            end
        end
    end
})

PlayerSection2:AddToggle({
    Title = "Spin",
    Default = false,
    Callback = function(value)
        getgenv().SpinbotEnabled = value
    end
})

PlayerSection2:AddSlider({
    Title = "Spin Speed",
    Min = 1,
    Max = 50,
    Default = 5,
    Callback = function(value)
        getgenv().CustomSpinSpeed = value
    end
})

PlayerSection2:AddToggle({
    Title = "Walk Speed",
    Default = false,
    Callback = function(value)
        getgenv().WalkspeedEnabled = value
    end
})

PlayerSection2:AddSlider({
    Title = "Walk Speed Value",
    Min = 16,
    Max = 500,
    Default = 36,
    Callback = function(value)
        getgenv().CustomWalkSpeed = value
    end
})

PlayerSection2:AddToggle({
    Title = "Jump Power",
    Default = false,
    Callback = function(value)
        getgenv().JumpPowerEnabled = value
    end
})

PlayerSection2:AddSlider({
    Title = "Jump Power Value",
    Min = 50,
    Max = 200,
    Default = 50,
    Callback = function(value)
        getgenv().CustomJumpPower = value
        getgenv().CustomJumpHeight = value * 0.144
    end
})

PlayerSection2:AddToggle({
    Title = "Gravity",
    Default = false,
    Callback = function(value)
        getgenv().GravityEnabled = value
        if not value then
            workspace.Gravity = 196.2
        end
    end
})

PlayerSection2:AddSlider({
    Title = "Gravity Value",
    Min = 0,
    Max = 400,
    Default = 196,
    Callback = function(value)
        getgenv().CustomGravity = value
    end
})

PlayerSection2:AddToggle({
    Title = "Hip Height",
    Default = false,
    Callback = function(value)
        getgenv().HipHeightEnabled = value
    end
})

PlayerSection2:AddSlider({
    Title = "Hip Height Value",
    Min = -5,
    Max = 20,
    Default = 0,
    Callback = function(value)
        getgenv().CustomHipHeight = value
    end
})

local VisualsSection = Tabs.Visuals:AddSection("Display")

local PingFrame
local PingText
local PingUpdateLoop

VisualsSection:AddToggle({
    Title = "Show Ping Display",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if not PingFrame then
                local ScreenGui = Instance.new("ScreenGui")
                ScreenGui.Name = "PingDisplay"
                ScreenGui.ResetOnSpawn = false
                ScreenGui.Parent = CoreGui

                PingFrame = Instance.new("Frame", ScreenGui)
                PingFrame.Size = UDim2.new(0, 140, 0, 40)
                PingFrame.Position = UDim2.new(0, 20, 0.5, -20)
                PingFrame.BackgroundColor3 = Color3.fromRGB(45, 0, 80)
                PingFrame.BackgroundTransparency = 0.2
                PingFrame.BorderSizePixel = 0
                PingFrame.Active = true

                local UICorner = Instance.new("UICorner", PingFrame)
                UICorner.CornerRadius = UDim.new(0, 10)

                local UIStroke = Instance.new("UIStroke", PingFrame)
                UIStroke.Color = Color3.fromRGB(120, 50, 200)
                UIStroke.Thickness = 2
                UIStroke.Transparency = 0.5

                local UIGradient = Instance.new("UIGradient", PingFrame)
                UIGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 0, 100)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 0, 60))
                })
                UIGradient.Rotation = 45

                PingText = Instance.new("TextLabel", PingFrame)
                PingText.Size = UDim2.new(1, -10, 1, -10)
                PingText.Position = UDim2.new(0, 5, 0, 5)
                PingText.BackgroundTransparency = 1
                PingText.TextScaled = true
                PingText.Font = Enum.Font.Ubuntu
                PingText.TextColor3 = Color3.fromRGB(200, 120, 255)
                PingText.Text = "Ping: 0ms"
                PingText.TextStrokeTransparency = 0.5

                local dragging = false
                local dragStart, startPos

                PingFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 
                    or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragStart = input.Position
                        startPos = PingFrame.Position
                    end
                end)

                PingFrame.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 
                    or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement 
                    or input.UserInputType == Enum.UserInputType.Touch) then
                        local delta = input.Position - dragStart
                        PingFrame.Position = UDim2.new(
                            startPos.X.Scale,
                            startPos.X.Offset + delta.X,
                            startPos.Y.Scale,
                            startPos.Y.Offset + delta.Y
                        )
                    end
                end)
            end

            PingFrame.Visible = true

            PingUpdateLoop = task.spawn(function()
                while task.wait(0.5) do
                    if not PingFrame or not PingFrame.Visible then break end
                    pcall(function()
                        local pingString = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
                        local pingNumber = pingString:match("%d+")
                        PingText.Text = "Ping: " .. (pingNumber or "0") .. "ms"
                    end)
                end
            end)
        else
            if PingFrame then
                PingFrame.Visible = false
            end
            if PingUpdateLoop then
                task.cancel(PingUpdateLoop)
                PingUpdateLoop = nil
            end
        end
    end
})

local BallVelocitySection = Tabs.Visuals:AddSection("Ball Velocity")

local BallVelocityFrame
local CurrentSpeedText
local PeakSpeedText
local BallVelocityUpdateLoop
local peakVelocity = 0
local lastBallId = nil

local function GetBall()
    local balls = workspace:FindFirstChild('Balls')
    if not balls then return nil end
    
    for _, ball in pairs(balls:GetChildren()) do
        if ball:GetAttribute('realBall') then
            return ball
        end
    end
    return nil
end

BallVelocitySection:AddToggle({
    Title = "Ball Velocity",
    Content = "Show Ball Speed",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if not BallVelocityFrame then
                local ScreenGui = Instance.new("ScreenGui")
                ScreenGui.Name = "BallVelocityDisplay"
                ScreenGui.ResetOnSpawn = false
                ScreenGui.Parent = CoreGui

                BallVelocityFrame = Instance.new("Frame", ScreenGui)
                BallVelocityFrame.Size = UDim2.new(0, 180, 0, 70)
                BallVelocityFrame.Position = UDim2.new(0, 20, 0.6, -20)
                BallVelocityFrame.BackgroundColor3 = Color3.fromRGB(45, 0, 80)
                BallVelocityFrame.BackgroundTransparency = 0.2
                BallVelocityFrame.BorderSizePixel = 0
                BallVelocityFrame.Active = true

                local UICorner = Instance.new("UICorner", BallVelocityFrame)
                UICorner.CornerRadius = UDim.new(0, 10)

                local UIStroke = Instance.new("UIStroke", BallVelocityFrame)
                UIStroke.Color = Color3.fromRGB(120, 50, 200)
                UIStroke.Thickness = 2
                UIStroke.Transparency = 0.5

                local UIGradient = Instance.new("UIGradient", BallVelocityFrame)
                UIGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 0, 100)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 0, 60))
                })
                UIGradient.Rotation = 45

                CurrentSpeedText = Instance.new("TextLabel", BallVelocityFrame)
                CurrentSpeedText.Size = UDim2.new(1, -20, 0, 30)
                CurrentSpeedText.Position = UDim2.new(0, 10, 0, 5)
                CurrentSpeedText.BackgroundTransparency = 1
                CurrentSpeedText.Font = Enum.Font.Ubuntu
                CurrentSpeedText.TextColor3 = Color3.fromRGB(200, 120, 255)
                CurrentSpeedText.TextSize = 16
                CurrentSpeedText.Text = "Speed: 0"
                CurrentSpeedText.TextStrokeTransparency = 0.5
                CurrentSpeedText.TextXAlignment = Enum.TextXAlignment.Left

                PeakSpeedText = Instance.new("TextLabel", BallVelocityFrame)
                PeakSpeedText.Size = UDim2.new(1, -20, 0, 30)
                PeakSpeedText.Position = UDim2.new(0, 10, 0, 35)
                PeakSpeedText.BackgroundTransparency = 1
                PeakSpeedText.Font = Enum.Font.Ubuntu
                PeakSpeedText.TextColor3 = Color3.fromRGB(255, 100, 150)
                PeakSpeedText.TextSize = 16
                PeakSpeedText.Text = "Peak: 0"
                PeakSpeedText.TextStrokeTransparency = 0.5
                PeakSpeedText.TextXAlignment = Enum.TextXAlignment.Left

                local dragging = false
                local dragStart, startPos

                BallVelocityFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 
                    or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragStart = input.Position
                        startPos = BallVelocityFrame.Position
                    end
                end)

                BallVelocityFrame.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 
                    or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement 
                    or input.UserInputType == Enum.UserInputType.Touch) then
                        local delta = input.Position - dragStart
                        BallVelocityFrame.Position = UDim2.new(
                            startPos.X.Scale,
                            startPos.X.Offset + delta.X,
                            startPos.Y.Scale,
                            startPos.Y.Offset + delta.Y
                        )
                    end
                end)
            end

            BallVelocityFrame.Visible = true

            BallVelocityUpdateLoop = task.spawn(function()
                while task.wait(0.1) do
                    if not BallVelocityFrame or not BallVelocityFrame.Visible then break end
                    
                    local ball = GetBall()
                    if not ball then
                        CurrentSpeedText.Text = "Speed: 0"
                        continue
                    end
                    
                    local ballId = ball:GetFullName()
                    if ballId ~= lastBallId then
                        peakVelocity = 0
                        lastBallId = ballId
                    end
                    
                    local zoomies = ball:FindFirstChild('zoomies')
                    if not zoomies then
                        CurrentSpeedText.Text = "Speed: 0"
                        continue
                    end
                    
                    local velocity = zoomies.VectorVelocity
                    local speed = velocity.Magnitude
                    
                    if speed > peakVelocity then
                        peakVelocity = speed
                    end
                    
                    CurrentSpeedText.Text = string.format("Speed: %.1f", speed)
                    PeakSpeedText.Text = string.format("Peak: %.1f", peakVelocity)
                    
                    if speed > 500 then
                        CurrentSpeedText.TextColor3 = Color3.fromRGB(255, 50, 50)
                    elseif speed > 300 then
                        CurrentSpeedText.TextColor3 = Color3.fromRGB(255, 165, 0)
                    else
                        CurrentSpeedText.TextColor3 = Color3.fromRGB(200, 120, 255)
                    end
                end
            end)
        else
            if BallVelocityFrame then
                BallVelocityFrame.Visible = false
            end
            if BallVelocityUpdateLoop then
                task.cancel(BallVelocityUpdateLoop)
                BallVelocityUpdateLoop = nil
            end
            peakVelocity = 0
            lastBallId = nil
        end
    end
})

local adminESPEnabled = false

VisualsSection:AddToggle({
    Title = "Admin ESP",
    Default = false,
    Callback = function(enabled)
        adminESPEnabled = enabled
        
        local targetNames = {"A&B Hub Admin", "A&B Hub Owner"}
        
        local function createESP(head, labelText)
            if head:FindFirstChild("AdminESP") then return end

            local billboard = Instance.new("BillboardGui")
            billboard.Name = "AdminESP"
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 100, 0, 30)
            billboard.Adornee = head
            billboard.StudsOffset = Vector3.new(0, 5, 0)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextScaled = true
            label.Font = Enum.Font.GothamBold
            label.TextColor3 = Color3.fromRGB(186, 85, 211)
            label.Text = labelText
            label.Parent = billboard

            billboard.Parent = head
        end

        local function removeESP(head)
            local esp = head:FindFirstChild("AdminESP")
            if esp then
                esp:Destroy()
            end
        end

        local function applyOnPlayer(plr)
            local isAdmin = false
            local labelText = ""
            
            for _, targetName in ipairs(targetNames) do
                if plr.Name == targetName then
                    isAdmin = true
                    labelText = targetName
                    break
                end
            end
            
            if not isAdmin then return end

            plr.CharacterAdded:Connect(function(char)
                if adminESPEnabled then
                    local head = char:WaitForChild("Head", 5)
                    if head then
                        createESP(head, labelText)
                    end
                end
            end)

            if plr.Character and plr.Character:FindFirstChild("Head") then
                if adminESPEnabled then
                    createESP(plr.Character.Head, labelText)
                else
                    removeESP(plr.Character.Head)
                end
            end
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            applyOnPlayer(plr)
        end

        Players.PlayerAdded:Connect(applyOnPlayer)

        if not enabled then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("Head") then
                    removeESP(plr.Character.Head)
                end
            end
        end
    end
})

local AbilityESPSection = Tabs.Visuals:AddSection("Player + Ability ESP")

local ability_esp = {
    __config = {
        gui_name = "AbilityESPGui",
        gui_size = UDim2.new(0, 200, 0, 40),
        studs_offset = Vector3.new(0, 3.2, 0),
        text_color = Color3.fromRGB(255, 255, 255),
        stroke_color = Color3.fromRGB(0, 0, 0),
        font = Enum.Font.GothamBold,
        text_size = 14,
        update_rate = 1/30
    },
    
    __state = {
        active = false,
        players = {},
        update_task = nil,
        connections = {}
    }
}

function ability_esp.create_billboard(player)
    local character = player.Character
    if not character or not character.Parent then 
        return nil
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return nil
    end
    
    local head = character:FindFirstChild("Head")
    if not head then
        return nil
    end
    
    local existing = head:FindFirstChild(ability_esp.__config.gui_name)
    if existing then
        existing:Destroy()
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = ability_esp.__config.gui_name
    billboard.Adornee = head
    billboard.Size = ability_esp.__config.gui_size
    billboard.StudsOffset = ability_esp.__config.studs_offset
    billboard.AlwaysOnTop = true
    billboard.Parent = head
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = ability_esp.__config.text_color
    label.TextStrokeColor3 = ability_esp.__config.stroke_color
    label.TextStrokeTransparency = 0.5
    label.Font = ability_esp.__config.font
    label.TextSize = ability_esp.__config.text_size
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = billboard
    
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    
    return label, billboard
end

function ability_esp.update_label(player, label)
    if not player or not player.Parent or not label or not label.Parent then
        return false
    end
    
    local character = player.Character
    if not character or not character.Parent or not character:FindFirstChild("Humanoid") then
        return false
    end
    
    if ability_esp.__state.active then
        label.Visible = true
        local ability_name = player:GetAttribute("EquippedAbility")
        label.Text = ability_name and 
            (player.DisplayName .. " [" .. ability_name .. "]") or 
            player.DisplayName
    else
        label.Visible = false
    end
    
    return true
end

function ability_esp.setup_character(player)
    if not ability_esp.__state.active then
        return
    end
    
    task.wait(0.1)
    
    local character = player.Character
    if not character or not character.Parent or not character:FindFirstChild("Humanoid") then
        return
    end
    
    local label, billboard = ability_esp.create_billboard(player)
    if not label then
        return
    end
    
    if not ability_esp.__state.players[player] then
        ability_esp.__state.players[player] = {}
    end
    
    ability_esp.__state.players[player].label = label
    ability_esp.__state.players[player].billboard = billboard
    ability_esp.__state.players[player].character = character
    
    local char_connection = character.AncestryChanged:Connect(function()
        if not character.Parent then
            if ability_esp.__state.players[player] then
                if ability_esp.__state.players[player].billboard then
                    ability_esp.__state.players[player].billboard:Destroy()
                end
                ability_esp.__state.players[player].label = nil
                ability_esp.__state.players[player].billboard = nil
                ability_esp.__state.players[player].character = nil
            end
        end
    end)
    
    if not ability_esp.__state.connections[player] then
        ability_esp.__state.connections[player] = {}
    end
    
    ability_esp.__state.connections[player].char_removing = char_connection
end

function ability_esp.add_player(player)
    if player == LocalPlayer then
        return
    end
    
    if ability_esp.__state.players[player] then
        ability_esp.remove_player(player)
    end
    
    if not ability_esp.__state.connections[player] then
        ability_esp.__state.connections[player] = {}
    end
    
    local char_added_connection = player.CharacterAdded:Connect(function()
        ability_esp.setup_character(player)
    end)
    
    ability_esp.__state.connections[player].char_added = char_added_connection
    
    if player.Character then
        task.spawn(function()
            ability_esp.setup_character(player)
        end)
    end
end

function ability_esp.remove_player(player)
    if ability_esp.__state.connections and ability_esp.__state.connections[player] then
        for _, connection in pairs(ability_esp.__state.connections[player]) do
            if connection and connection.Connected then
                connection:Disconnect()
            end
        end
        ability_esp.__state.connections[player] = nil
    end
    
    local player_data = ability_esp.__state.players[player]
    if player_data then
        if player_data.billboard then
            player_data.billboard:Destroy()
        end
        ability_esp.__state.players[player] = nil
    end
end

function ability_esp.update_loop()
    while ability_esp.__state.active do
        task.wait(ability_esp.__config.update_rate)
        
        local players_to_remove = {}
        
        for player, player_data in pairs(ability_esp.__state.players) do
            if not player or not player.Parent then
                table.insert(players_to_remove, player)
                continue
            end
            
            local character = player.Character
            if not character or not character.Parent or not character:FindFirstChild("Humanoid") then
                if player_data.billboard then
                    player_data.billboard:Destroy()
                    player_data.billboard = nil
                    player_data.label = nil
                end
                continue
            end
            
            if not player_data.billboard or not player_data.label then
                local label, billboard = ability_esp.create_billboard(player)
                if label then
                    player_data.label = label
                    player_data.billboard = billboard
                    player_data.character = character
                end
            end
            
            if player_data.label then
                local success = ability_esp.update_label(player, player_data.label)
                if not success then
                    local label, billboard = ability_esp.create_billboard(player)
                    if label then
                        player_data.label = label
                        player_data.billboard = billboard
                        player_data.character = character
                    end
                end
            end
        end
        
        for _, player in ipairs(players_to_remove) do
            if ability_esp.__state.players[player] then
                if ability_esp.__state.players[player].billboard then
                    ability_esp.__state.players[player].billboard:Destroy()
                end
                ability_esp.__state.players[player] = nil
            end
        end
    end
end

function ability_esp.start()
    if ability_esp.__state.active then
        return
    end
    
    ability_esp.__state.active = true
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ability_esp.add_player(player)
        end
    end
    
    ability_esp.__state.connections.player_added = Players.PlayerAdded:Connect(function(player)
        if ability_esp.__state.active and player ~= LocalPlayer then
            task.wait(1)
            ability_esp.add_player(player)
        end
    end)
    
    ability_esp.__state.update_task = task.spawn(function()
        ability_esp.update_loop()
    end)
end

function ability_esp.stop()
    if not ability_esp.__state.active then
        return
    end
    
    ability_esp.__state.active = false
    
    if ability_esp.__state.update_task then
        task.cancel(ability_esp.__state.update_task)
        ability_esp.__state.update_task = nil
    end
    
    if ability_esp.__state.connections then
        for player, connections in pairs(ability_esp.__state.connections) do
            if type(connections) == "table" then
                for _, connection in pairs(connections) do
                    if connection and connection.Connected then
                        connection:Disconnect()
                    end
                end
            elseif connections and connections.Connected then
                connections:Disconnect()
            end
        end
        
        ability_esp.__state.connections = {}
    end
    
    for player in pairs(ability_esp.__state.players) do
        ability_esp.remove_player(player)
    end
end

AbilityESPSection:AddToggle({
    Title = 'Player + Ability ESP',
    Default = false,
    Callback = function(value)
        if value then
            ability_esp.start()
        else
            ability_esp.stop()
        end
    end
})

local TrailSection = Tabs.Visuals:AddSection("Ball Trail")

local PlasmaTrails = {
    Active = false,
    Enabled = false,
    TrailAttachments = {},
    NumTrails = 8,
    TrailColor = Color3.fromRGB(0, 255, 255)
}

local last_ball = nil
local last_ball_id = nil

local function GetTrailBall()
    local balls = workspace:FindFirstChild('Balls')
    if not balls then return nil end
    
    for _, ball in pairs(balls:GetChildren()) do
        if ball:IsA("BasePart") or ball:IsA("MeshPart") then
            if not ball:GetAttribute('realBall') then
                ball.CanCollide = false
                return ball
            end
        end
    end
    return nil
end

local function create_trails(ball)
    if not ball or not ball.Parent then return end
    if PlasmaTrails.Active then return end
    
    PlasmaTrails.Active = true
    PlasmaTrails.TrailAttachments = {}
    
    for _, child in ipairs(ball:GetChildren()) do
        if child.Name:find("PlasmaTrail_") or child.Name:find("PlasmaAttachment") then
            child:Destroy()
        end
    end
    
    for i = 1, PlasmaTrails.NumTrails do
        local trailData = {}
        trailData.attachment0 = Instance.new("Attachment")
        trailData.attachment0.Parent = ball
        
        trailData.attachment1 = Instance.new("Attachment")
        trailData.attachment1.Parent = ball
        trailData.attachment1.Position = Vector3.new(0, -0.6, 0)
        
        trailData.trail = Instance.new("Trail")
        trailData.trail.Name = "PlasmaTrail_" .. i
        trailData.trail.Lifetime = 0.6
        trailData.trail.MinLength = 0
        trailData.trail.FaceCamera = true
        trailData.trail.LightEmission = 1
        trailData.trail.Texture = "rbxassetid://5029929719"
        trailData.trail.TextureMode = Enum.TextureMode.Stretch
        trailData.trail.Enabled = true
        trailData.trail.Attachment0 = trailData.attachment0
        trailData.trail.Attachment1 = trailData.attachment1
        trailData.trail.Parent = ball
        
        local base_color = PlasmaTrails.TrailColor
        trailData.trail.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, base_color),
            ColorSequenceKeypoint.new(0.5, Color3.new(
                math.min(base_color.R * 1.3, 1),
                math.min(base_color.G * 1.3, 1),
                math.min(base_color.B * 1.3, 1)
            )),
            ColorSequenceKeypoint.new(1, base_color)
        })
        
        trailData.trail.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(0.3, 0),
            NumberSequenceKeypoint.new(0.7, 0.3),
            NumberSequenceKeypoint.new(1, 1)
        })
        
        trailData.trail.WidthScale = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.1),
            NumberSequenceKeypoint.new(0.3, 0.25),
            NumberSequenceKeypoint.new(0.7, 0.15),
            NumberSequenceKeypoint.new(1, 0.02)
        })
        
        local angle = (i / PlasmaTrails.NumTrails) * math.pi * 2
        local radius = math.random(150, 250) / 100
        local height = math.random(-150, 150) / 100
        
        trailData.baseAngle = angle
        trailData.angle = 0
        trailData.speed = math.random(15, 30) / 10
        trailData.spiralSpeed = math.random(25, 45) / 10
        trailData.radiusMultiplier = math.random(80, 130) / 100
        trailData.pulseOffset = math.random() * math.pi * 2
        trailData.baseRadius = radius
        trailData.baseHeight = height
        trailData.chaosSpeed = math.random(10, 20) / 10
        trailData.lastUpdate = 0
        
        table.insert(PlasmaTrails.TrailAttachments, trailData)
    end
end

local function animate_trails(ball, delta_time)
    if not PlasmaTrails.Active or not ball then return end
    
    local time = tick()
    
    for _, trail_data in ipairs(PlasmaTrails.TrailAttachments) do
        if time - trail_data.lastUpdate > 0.016 then
            trail_data.angle = trail_data.angle + trail_data.speed * delta_time
            
            local spiral_angle = trail_data.angle * trail_data.spiralSpeed
            local pulse = math.sin(time * 4 + trail_data.pulseOffset) * 0.4 + 1
            local twist = math.sin(trail_data.angle * 3) * 0.7
            local chaos = math.sin(time * trail_data.chaosSpeed + trail_data.pulseOffset) * 0.5
            
            local radius1 = trail_data.baseRadius * trail_data.radiusMultiplier * pulse
            local radius2 = trail_data.baseRadius * 1.3 * trail_data.radiusMultiplier * pulse
            
            local spiral_offset1 = Vector3.new(
                math.cos(spiral_angle) * 0.6,
                math.sin(spiral_angle * 2) * 0.6,
                math.sin(spiral_angle) * 0.6
            )
            
            local spiral_offset2 = Vector3.new(
                math.sin(spiral_angle * 1.3) * 0.5,
                math.cos(spiral_angle * 1.7) * 0.5,
                math.cos(spiral_angle * 1.1) * 0.5
            )
            
            trail_data.attachment0.Position = Vector3.new(
                math.cos(trail_data.baseAngle + trail_data.angle) * radius1,
                trail_data.baseHeight + math.sin((trail_data.baseAngle + trail_data.angle) * 3) * 0.8 + twist + chaos,
                math.sin(trail_data.baseAngle + trail_data.angle) * radius1
            ) + spiral_offset1
            
            trail_data.attachment1.Position = Vector3.new(
                math.cos(trail_data.baseAngle + trail_data.angle + math.pi * 0.7) * radius2,
                -trail_data.baseHeight + math.cos((trail_data.baseAngle + trail_data.angle) * 2.5) * 0.8 - twist - chaos,
                math.sin(trail_data.baseAngle + trail_data.angle + math.pi * 0.7) * radius2
            ) + spiral_offset2
            
            local brightness = (math.sin(time * 5 + trail_data.pulseOffset) * 0.4 + 0.6)
            trail_data.trail.LightEmission = brightness
            
            trail_data.lastUpdate = time
        end
    end
end

local function cleanup_trails(ball)
    for _, trail_data in ipairs(PlasmaTrails.TrailAttachments) do
        if trail_data and trail_data.trail then
            trail_data.trail:Destroy()
        end
        if trail_data and trail_data.attachment0 then
            trail_data.attachment0:Destroy()
        end
        if trail_data and trail_data.attachment1 then
            trail_data.attachment1:Destroy()
        end
    end
    
    PlasmaTrails.Active = false
    PlasmaTrails.TrailAttachments = {}
    
    if ball and ball.Parent then
        for _, child in ipairs(ball:GetChildren()) do
            if child.Name:find("PlasmaTrail_") or child.Name:find("PlasmaAttachment") then
                child:Destroy()
            end
        end
    end
end

RunService.Heartbeat:Connect(function(delta_time)
    if PlasmaTrails.Enabled then
        local ball = GetTrailBall()
        
        if ball then
            local ball_id = ball:GetFullName()
            
            if not last_ball or ball_id ~= last_ball_id then
                if last_ball then
                    cleanup_trails(last_ball)
                end
                
                create_trails(ball)
                last_ball = ball
                last_ball_id = ball_id
            end
            
            if PlasmaTrails.Active then
                animate_trails(ball, delta_time)
            end
        else
            if last_ball then
                cleanup_trails(last_ball)
                last_ball = nil
                last_ball_id = nil
            end
        end
    else
        if last_ball then
            cleanup_trails(last_ball)
            last_ball = nil
            last_ball_id = nil
        end
    end
end)

TrailSection:AddToggle({
    Title = 'Ball Trail',
    Content = 'Add Trail to Ball',
    Default = false,
    Callback = function(value)
        PlasmaTrails.Enabled = value
        if not value and last_ball then
            cleanup_trails(last_ball)
            last_ball = nil
            last_ball_id = nil
        end
    end
})

TrailSection:AddSlider({
    Title = "Trail Count",
    Min = 2,
    Max = 16,
    Default = 8,
    Callback = function(value)
        PlasmaTrails.NumTrails = value
        if last_ball then
            cleanup_trails(last_ball)
            if PlasmaTrails.Enabled then
                create_trails(last_ball)
            end
        end
    end
})

TrailSection:AddToggle({
    Title = "Rainbow Trail",
    Default = false,
    Callback = function(value)
        if value then
            if _G.RainbowTrailLoop then return end
            _G.rainbowTrailSpeed = _G.rainbowTrailSpeed or 0.4
            _G.RainbowTrailLoop = RunService.Heartbeat:Connect(function(delta)
                local now = tick()
                if not _G.lastTrailRainbowUpdate or now - _G.lastTrailRainbowUpdate > 0.1 then
                    local t = os.clock()
                    local speed = _G.rainbowTrailSpeed or 0.4
                    local hue = (t * speed) % 1
                    PlasmaTrails.TrailColor = Color3.fromHSV(hue, 1, 1)
                    
                    local ball = GetTrailBall()
                    if ball and PlasmaTrails.Active then
                        for _, trail_data in ipairs(PlasmaTrails.TrailAttachments) do
                            if trail_data.trail then
                                local base_color = PlasmaTrails.TrailColor
                                trail_data.trail.Color = ColorSequence.new({
                                    ColorSequenceKeypoint.new(0, base_color),
                                    ColorSequenceKeypoint.new(0.5, Color3.new(
                                        math.min(base_color.R * 1.3, 1),
                                        math.min(base_color.G * 1.3, 1),
                                        math.min(base_color.B * 1.3, 1)
                                    )),
                                    ColorSequenceKeypoint.new(1, base_color)
                                })
                            end
                        end
                    end
                    _G.lastTrailRainbowUpdate = now
                end
            end)
        else
            if _G.RainbowTrailLoop then
                _G.RainbowTrailLoop:Disconnect()
                _G.RainbowTrailLoop = nil
                _G.lastTrailRainbowUpdate = nil
            end
        end
    end
})

TrailSection:AddSlider({
    Title = "Rainbow Speed",
    Min = 0.1,
    Max = 5,
    Default = 0.4,
    Callback = function(value)
        _G.rainbowTrailSpeed = value
    end
})

local MiscSection = Tabs.Misc:AddSection("Skin Changer")

local swordInstancesInstance = ReplicatedStorage:WaitForChild("Shared",9e9):WaitForChild("ReplicatedInstances",9e9):WaitForChild("Swords",9e9)
local swordInstances = require(swordInstancesInstance)

local swordsController

task.spawn(function()
    while task.wait() and (not swordsController) do
        for i,v in getconnections(ReplicatedStorage.Remotes.FireSwordInfo.OnClientEvent) do
            if v.Function and islclosure(v.Function) then
                local upvalues = getupvalues(v.Function)
                if #upvalues == 1 and type(upvalues[1]) == "table" then
                    swordsController = upvalues[1]
                    break
                end
            end
        end
    end
end)

function getSlashName(swordName)
    if not swordName or swordName == "" then return "SlashEffect" end
    local slashName = swordInstances:GetSword(swordName)
    return (slashName and slashName.SlashName) or "SlashEffect"
end

function setSword()
    if not getgenv().swordModel or getgenv().swordModel == "" then return end
    
    pcall(function()
        setupvalue(rawget(swordInstances,"EquipSwordTo"),3,false)
        swordInstances:EquipSwordTo(LocalPlayer.Character, getgenv().swordModel)
    end)
    
    task.wait(0.1)
    
    if swordsController and getgenv().swordAnimations and getgenv().swordAnimations ~= "" then
        pcall(function()
            swordsController:SetSword(getgenv().swordAnimations)
        end)
    end
end

local playParryFunc
local parrySuccessAllConnection

task.spawn(function()
    while task.wait() and not parrySuccessAllConnection do
        for i,v in getconnections(ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent) do
            if v.Function and getinfo(v.Function).name == "parrySuccessAll" then
                parrySuccessAllConnection = v
                playParryFunc = v.Function
                v:Disable()
                break
            end
        end
    end
end)

local parrySuccessClientConnection
task.spawn(function()
    while task.wait() and not parrySuccessClientConnection do
        for i,v in getconnections(ReplicatedStorage.Remotes.ParrySuccessClient.Event) do
            if v.Function and getinfo(v.Function).name == "parrySuccessAll" then
                parrySuccessClientConnection = v
                v:Disable()
                break
            end
        end
    end
end)

ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function(...)
    if playParryFunc then
        setthreadidentity(2)
        local args = {...}
        if tostring(args[4]) ~= LocalPlayer.Name then
        elseif getgenv().swordFX and getgenv().swordFX ~= "" then
            args[1] = getSlashName(getgenv().swordFX)
            args[3] = getgenv().swordFX
        end
        return playParryFunc(unpack(args))
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 10)
    task.wait(1)
    if getgenv().swordModel and getgenv().swordModel ~= "" then
        setSword()
    end
end)

task.spawn(function()
    while task.wait(1) do
        if getgenv().swordModel and getgenv().swordModel ~= "" then
            local char = LocalPlayer.Character
            if char then
                if LocalPlayer:GetAttribute("CurrentlyEquippedSword") ~= getgenv().swordModel then
                    setSword()
                end
                if not char:FindFirstChild(getgenv().swordModel) then
                    setSword()
                end
                for _,v in char:GetChildren() do
                    if v:IsA("Model") and v.Name ~= getgenv().swordModel then
                        v:Destroy()
                    end
                end
            end
        end
    end
end)

local tempSwordName = ""

MiscSection:AddInput({
    Title = "Skin Name",
    Default = "",
    Callback = function(value)
        tempSwordName = value
    end
})

MiscSection:AddButton({
    Title = "Apply Skin",
    Callback = function()
        if tempSwordName ~= "" then
            getgenv().swordModel = tempSwordName
            getgenv().swordAnimations = tempSwordName
            getgenv().swordFX = tempSwordName
            
            setSword()
            
            AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "Skin Applied",
                Content = "Sword: " .. tempSwordName,
                Delay = 3
            })
        else
            AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "Error",
                Content = "Please enter a skin name",
                Delay = 3
            })
        end
    end
})

local KillSoundSection = Tabs.Misc:AddSection("Kill Sound")

local KillSoundSystem = {
    Sounds = {
        { id = "92076037937225", name = "FAH", length = 4 },
        { id = "96664488756631", name = "Im Very Angry 😡", length = 4 },
        { id = "116957716755028", name = "Leave me alone 🙏", length = 4 },
        { id = "8643750815", name = "GET OVER HERE", length = 4 },
        { id = "93779555057888", name = "HEHEHE HA", length = 4 },
        { id = "84233173598772", name = "Head Shot", length = 4 },
        { id = "8097518145", name = "Lesgo", length = 4 }
    },
    
    __state = {
        enabled = false,
        selected_sound = "92076037937225",
        last_kill_time = 0,
        kill_cooldown = 0.3,
        current_sound = nil
    },
    
    __connections = {}
}

function KillSoundSystem.stop()
    if KillSoundSystem.__state.current_sound then
        pcall(function()
            KillSoundSystem.__state.current_sound:Stop()
            KillSoundSystem.__state.current_sound:Destroy()
        end)
        KillSoundSystem.__state.current_sound = nil
    end
end

function KillSoundSystem.play(position)
    KillSoundSystem.stop()

    local data
    for _, s in ipairs(KillSoundSystem.Sounds) do
        if s.id == KillSoundSystem.__state.selected_sound then
            data = s
            break
        end
    end
    if not data then return end

    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(0.1, 0.1, 0.1)
    part.Position = position
    part.Parent = workspace

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. data.id
    sound.Volume = 0.7
    sound.RollOffMode = Enum.RollOffMode.Linear
    sound.MaxDistance = 500
    sound.Parent = part

    KillSoundSystem.__state.current_sound = sound
    sound:Play()

    Debris:AddItem(part, data.length + 0.5)
end

function KillSoundSystem.onKill(character)
    if not KillSoundSystem.__state.enabled then return end

    local now = tick()
    if now - KillSoundSystem.__state.last_kill_time < KillSoundSystem.__state.kill_cooldown then
        return
    end
    KillSoundSystem.__state.last_kill_time = now

    local pos = character.PrimaryPart
        and character.PrimaryPart.Position
        or workspace.CurrentCamera.CFrame.Position

    KillSoundSystem.play(pos)
end

function KillSoundSystem.hookPlayer(player)
    local function onChar(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.Died:Connect(function()
                if player ~= LocalPlayer then
                    KillSoundSystem.onKill(char)
                end
            end)
        end
    end

    if player.Character then
        onChar(player.Character)
    end
    player.CharacterAdded:Connect(onChar)
end

function KillSoundSystem.enable()
    for _, p in ipairs(Players:GetPlayers()) do
        KillSoundSystem.hookPlayer(p)
    end

    KillSoundSystem.__connections.playerAdded =
        Players.PlayerAdded:Connect(function(p)
            KillSoundSystem.hookPlayer(p)
        end)
end

function KillSoundSystem.disable()
    KillSoundSystem.stop()
    for _, c in pairs(KillSoundSystem.__connections) do
        pcall(function() c:Disconnect() end)
    end
    KillSoundSystem.__connections = {}
end

KillSoundSection:AddToggle({
    Title = "Kill Sound",
    Content = "Play Sound on Kill",
    Default = false,
    Callback = function(enabled)
        KillSoundSystem.__state.enabled = enabled
        if enabled then
            KillSoundSystem.enable()
        else
            KillSoundSystem.disable()
        end
    end
})

local sound_options = {}
for _, s in ipairs(KillSoundSystem.Sounds) do
    table.insert(sound_options, s.name)
end

KillSoundSection:AddDropdown({
    Title = "Select Sound",
    Options = sound_options,
    Default = "FAH",
    Callback = function(value)
        for _, s in ipairs(KillSoundSystem.Sounds) do
            if s.name == value then
                KillSoundSystem.__state.selected_sound = s.id
                break
            end
        end
    end
})

local PlayerSection3 = Tabs.Misc:AddSection("Emotes")

local animation_system = {
    storage = {},
    current = nil,
    track = nil
}

function animation_system.load_animations()
    local emotes_folder = ReplicatedStorage.Misc.Emotes
    
    for _, animation in pairs(emotes_folder:GetChildren()) do
        if animation:IsA("Animation") and animation:GetAttribute("EmoteName") then
            local emote_name = animation:GetAttribute("EmoteName")
            animation_system.storage[emote_name] = animation
        end
    end
end

function animation_system.get_emotes_list()
    local emotes_list = {}
    
    for emote_name in pairs(animation_system.storage) do
        table.insert(emotes_list, emote_name)
    end
    
    table.sort(emotes_list)
    return emotes_list
end

function animation_system.play(emote_name)
    local animation_data = animation_system.storage[emote_name]
    
    if not animation_data or not LocalPlayer.Character then
        return false
    end
    
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
    if not humanoid then
        return false
    end
    
    local animator = humanoid:FindFirstChildOfClass('Animator')
    if not animator then
        return false
    end
    
    if animation_system.track then
        animation_system.track:Stop()
        animation_system.track:Destroy()
    end
    
    animation_system.track = animator:LoadAnimation(animation_data)
    animation_system.track:Play()
    animation_system.current = emote_name
    
    return true
end

function animation_system.stop()
    if animation_system.track then
        animation_system.track:Stop()
        animation_system.track:Destroy()
        animation_system.track = nil
    end
    animation_system.current = nil
end

function animation_system.start()
    if not System.__properties.__connections.animations then
        System.__properties.__connections.animations = RunService.Heartbeat:Connect(function()
            if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then
                return
            end
            
            local speed = LocalPlayer.Character.PrimaryPart.AssemblyLinearVelocity.Magnitude
            
            if speed > 30 and getgenv().AutoStopEmotes then
                if animation_system.track and animation_system.track.IsPlaying then
                    animation_system.track:Stop()
                end
            else
                if animation_system.current and (not animation_system.track or not animation_system.track.IsPlaying) then
                    animation_system.play(animation_system.current)
                end
            end
        end)
    end
end

function animation_system.cleanup()
    animation_system.stop()
    
    if System.__properties.__connections.animations then
        System.__properties.__connections.animations:Disconnect()
        System.__properties.__connections.animations = nil
    end
end

animation_system.load_animations()
local emotes_data = animation_system.get_emotes_list()
local selected_animation = emotes_data[1]

PlayerSection3:AddToggle({
    Title = "Enable Emote",
    Default = false,
    Callback = function(value)
        getgenv().EmotesEnabled = value
        
        if value then
            animation_system.start()
            
            if selected_animation then
                animation_system.play(selected_animation)
            end
        else
            animation_system.cleanup()
        end
    end
})

PlayerSection3:AddToggle({
    Title = "Auto Stop Emote",
    Default = false,
    Callback = function(value)
        getgenv().AutoStopEmotes = value
    end
})

PlayerSection3:AddDropdown({
    Title = "Select Emote",
    Options = emotes_data,
    Default = selected_animation,
    Callback = function(value)
        selected_animation = value
        
        if getgenv().EmotesEnabled then
            animation_system.play(value)
        end
    end
})

AIKO:MakeNotify({
    Title = "Aikoware",
    Description = "Script Loaded",
    Content = "Game: Blade Ball",
    Delay = 4
})
