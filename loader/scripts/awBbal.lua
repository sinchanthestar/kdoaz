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
                    "[AIKOWARE]: stop skidding brochacho 😹"
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
getgenv().AutoParryV2 = false
getgenv().AutoSpamV2 = false
getgenv().AutoJumpV2 = false
getgenv().PlayerFocusV2 = false
getgenv().LobbyAPV2 = false
getgenv().AnimationFixV2 = false
getgenv().DirectionV2 = "Camera"
getgenv().AutoCurveV2 = false
getgenv().AntiCurveV2 = false
getgenv().InfinityDetectionV2 = true
getgenv().SlashOfFuryDetectionV2 = true
getgenv().PhantomDetectionV2 = false
getgenv().DeathSlashDetectionV2 = true
getgenv().TimeHoleDetectionV2 = true
getgenv().AutoTelekinesisV2 = true
getgenv().AutoBlockSpamsV2 = true
getgenv().AntiBlockSpamsV2 = true
getgenv().AnimationFixV2 = false
getgenv().CooldownProtectionV2 = true
getgenv().AutoAbilityV2 = true
getgenv().RandomAccuracyV2 = false
getgenv().LobbyRandomAccuracyV2 = false
getgenv().ESPEnabled = false
getgenv().ESPShowBox = false
getgenv().ESPShowName = false
getgenv().ESPShowHealth = false
getgenv().ESPShowTracer = false
getgenv().ESPShowDistance = false
getgenv().ESPBoxType = "2D"
getgenv().AntiAFKEnabled = false
getgenv().AntiLagEnabled = false
getgenv().NightModeEnabled = false
getgenv().RemoveFogEnabled = false
getgenv().FPSUnlockEnabled = true
getgenv().AutoAbilityDelayV2 = 2.8

local SpeedMultiplierV2 = 1.1
local LobbySpeedMultiplierV2 = 1.1
local ParryThresholdV2 = 2.5
local ParriedV2 = false
local LobbyParriedV2 = false
local PhantomV2 = false
local InfinityV2 = false
local ParriesV2 = 0
local ConnectionsV2 = {}

local Window = AIKO:Window({
    Title = "Aikoware |",
    Footer = "made by @aoki!",
    Version = 1,
})

local ESPLines = {
    Enabled = false,
    ShowBox = false,
    ShowName = false,
    ShowHealth = false,
    ShowTracer = false,
    ShowDistance = false,
    BoxType = "2D",
    Objects = {}
}

local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESPLines.Objects[player] then return end
    
    local ESPObject = {
        Player = player,
        Drawings = {}
    }
    
    if ESPLines.ShowBox then
        ESPObject.Drawings.Box = Drawing.new("Square")
        ESPObject.Drawings.Box.Visible = false
        ESPObject.Drawings.Box.Color = Color3.new(1, 1, 1)
        ESPObject.Drawings.Box.Thickness = 2
        ESPObject.Drawings.Box.Filled = false
    end
    
    if ESPLines.ShowName then
        ESPObject.Drawings.Name = Drawing.new("Text")
        ESPObject.Drawings.Name.Visible = false
        ESPObject.Drawings.Name.Color = Color3.new(1, 1, 1)
        ESPObject.Drawings.Name.Center = true
        ESPObject.Drawings.Name.Outline = true
        ESPObject.Drawings.Name.Size = 16
    end
    
    if ESPLines.ShowHealth then
        ESPObject.Drawings.Health = Drawing.new("Text")
        ESPObject.Drawings.Health.Visible = false
        ESPObject.Drawings.Health.Color = Color3.new(0, 1, 0)
        ESPObject.Drawings.Health.Center = true
        ESPObject.Drawings.Health.Outline = true
        ESPObject.Drawings.Health.Size = 14
    end
    
    if ESPLines.ShowTracer then
        ESPObject.Drawings.Tracer = Drawing.new("Line")
        ESPObject.Drawings.Tracer.Visible = false
        ESPObject.Drawings.Tracer.Color = Color3.new(1, 1, 1)
        ESPObject.Drawings.Tracer.Thickness = 1
    end
    
    if ESPLines.ShowDistance then
        ESPObject.Drawings.Distance = Drawing.new("Text")
        ESPObject.Drawings.Distance.Visible = false
        ESPObject.Drawings.Distance.Color = Color3.new(1, 1, 1)
        ESPObject.Drawings.Distance.Center = true
        ESPObject.Drawings.Distance.Outline = true
        ESPObject.Drawings.Distance.Size = 14
    end
    
    ESPLines.Objects[player] = ESPObject
end

local function RemoveESP(player)
    local ESPObject = ESPLines.Objects[player]
    if not ESPObject then return end
    
    for _, drawing in pairs(ESPObject.Drawings) do
        drawing:Remove()
    end
    
    ESPLines.Objects[player] = nil
end

local function UpdateESP()
    if not ESPLines.Enabled then
        for player, _ in pairs(ESPLines.Objects) do
            for _, drawing in pairs(ESPLines.Objects[player].Drawings) do
                drawing.Visible = false
            end
        end
        return
    end
    
    local camera = workspace.CurrentCamera
    local viewportSize = camera.ViewportSize
    
    for player, espObject in pairs(ESPLines.Objects) do
        local character = player.Character
        local drawings = espObject.Drawings
        
        if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
            local hrp = character.HumanoidRootPart
            local humanoid = character.Humanoid
            local head = character:FindFirstChild("Head")
            
            if humanoid.Health > 0 then
                local rootPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 2
                    
                    if drawings.Box then
                        drawings.Box.Size = Vector2.new(width, height)
                        drawings.Box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height / 2)
                        drawings.Box.Visible = true
                    end
                    
                    if drawings.Name then
                        drawings.Name.Text = player.Name
                        drawings.Name.Position = Vector2.new(rootPos.X, headPos.Y - 20)
                        drawings.Name.Visible = true
                    end
                    
                    if drawings.Health then
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        drawings.Health.Text = tostring(math.floor(humanoid.Health))
                        drawings.Health.Position = Vector2.new(rootPos.X, legPos.Y + 5)
                        drawings.Health.Color = Color3.new(1 - healthPercent, healthPercent, 0)
                        drawings.Health.Visible = true
                    end
                    
                    if drawings.Tracer then
                        drawings.Tracer.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                        drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                        drawings.Tracer.Visible = true
                    end
                    
                    if drawings.Distance then
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                        drawings.Distance.Text = tostring(math.floor(distance)) .. "m"
                        drawings.Distance.Position = Vector2.new(rootPos.X, rootPos.Y)
                        drawings.Distance.Visible = true
                    end
                else
                    for _, drawing in pairs(drawings) do
                        drawing.Visible = false
                    end
                end
            else
                for _, drawing in pairs(drawings) do
                    drawing.Visible = false
                end
            end
        else
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

for _, player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end

local function AddVIPTag()
    local Players = game:GetService("Players")
    local TextChatService = game:GetService("TextChatService")
    local StarterGui = game:GetService("StarterGui")
    
    local localPlayer = Players.LocalPlayer
    local vipTag = "<font color='#FFFF00'>[VIP]</font> " .. localPlayer.Name
    
    local function addLegacyChatTag()
        local function onChatted(msg)
            local message = vipTag .. ": " .. msg
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = message,
                Color = Color3.new(1, 1, 1),
                Font = Enum.Font.SourceSansBold,
                TextSize = 18
            })
        end
        localPlayer.Chatted:Connect(onChatted)
    end
    
    local function addTextChatTag()
        local function onIncomingMessage(message)
            if message.TextSource then
                local sender = Players:GetPlayerByUserId(message.TextSource.UserId)
                if sender and sender == localPlayer then
                    message.PrefixText = vipTag
                end
            end
        end
        TextChatService.OnIncomingMessage = onIncomingMessage
    end
    
    if TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService then
        addLegacyChatTag()
    else
        addTextChatTag()
    end
end

local function GetClosestPlayerV2()
    local closest, distance = nil, math.huge
    local aliveFolder = workspace:FindFirstChild("Alive")
    if not aliveFolder then return nil end
    
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return nil end
    
    for _, v in pairs(aliveFolder:GetChildren()) do
        if v ~= localChar and v:FindFirstChild("HumanoidRootPart") then
            local d = (v.HumanoidRootPart.Position - localChar.HumanoidRootPart.Position).Magnitude
            if d < distance then
                closest = v
                distance = d
            end
        end
    end
    return closest
end

local function GetBallV2()
    local ballsFolder = workspace:FindFirstChild("Balls")
    if not ballsFolder then return nil end
    
    for _, ball in pairs(ballsFolder:GetChildren()) do
        if ball:GetAttribute("realBall") then
            return ball
        end
    end
    return nil
end

local function GetDirectionV2()
    local localChar = LocalPlayer.Character
    local hrp = localChar and localChar:FindFirstChild("HumanoidRootPart")
    
    if getgenv().AntiCurveV2 then
        return (Camera.CFrame * CFrame.new(0, 0, -500)).Position
    elseif getgenv().AutoCurveV2 then
        local target = GetClosestPlayerV2()
        if target and target:FindFirstChild("HumanoidRootPart") and hrp then
            local d = (target.HumanoidRootPart.Position - hrp.Position)
            return d.Unit + Vector3.new(0, math.sin(tick() * 5) * 0.2, 0)
        end
    elseif getgenv().DirectionV2 == "Camera" then
        return Camera.CFrame.LookVector
    elseif getgenv().DirectionV2 == "Mouse" then
        local mouse = LocalPlayer:GetMouse()
        if hrp then
            return (mouse.Hit.Position - hrp.Position).Unit
        end
    elseif getgenv().DirectionV2 == "Players" then
        local target = GetClosestPlayerV2()
        if target and target:FindFirstChild("HumanoidRootPart") and hrp then
            return (target.HumanoidRootPart.Position - hrp.Position).Unit
        end
    elseif getgenv().DirectionV2 == "Normal" then
        return Vector3.new(0, 0, -1)
    elseif getgenv().DirectionV2 == "Up" then
        return Vector3.new(0, 1, 0)
    elseif getgenv().DirectionV2 == "Down" then
        return Vector3.new(0, -1, 0)
    elseif getgenv().DirectionV2 == "Left" then
        return -Camera.CFrame.RightVector
    elseif getgenv().DirectionV2 == "Right" then
        return Camera.CFrame.RightVector
    elseif getgenv().DirectionV2 == "Behind" then
        return -Camera.CFrame.LookVector
    elseif getgenv().DirectionV2 == "Random" then
        return Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)).Unit
    elseif getgenv().DirectionV2 == "FrontLeft" then
        return (Camera.CFrame.LookVector - Camera.CFrame.RightVector).Unit
    elseif getgenv().DirectionV2 == "FrontRight" then
        return (Camera.CFrame.LookVector + Camera.CFrame.RightVector).Unit
    elseif getgenv().DirectionV2 == "BackLeft" then
        return (-Camera.CFrame.LookVector - Camera.CFrame.RightVector).Unit
    elseif getgenv().DirectionV2 == "BackRight" then
        return (-Camera.CFrame.LookVector + Camera.CFrame.RightVector).Unit
    elseif getgenv().DirectionV2 == "SkywardSpiral" then
        return (Camera.CFrame.LookVector + Vector3.new(0, math.sin(tick() * 5), 0)).Unit
    elseif getgenv().DirectionV2 == "Zigzag" then
        return (Camera.CFrame.LookVector + Camera.CFrame.RightVector * math.sin(tick() * 10)).Unit
    elseif getgenv().DirectionV2 == "Spin" then
        local angle = math.rad(tick() * 360 % 360)
        return Vector3.new(math.cos(angle), 0, math.sin(angle)).Unit
    elseif getgenv().DirectionV2 == "Bounce" then
        return (Camera.CFrame.LookVector + Vector3.new(0, math.abs(math.sin(tick() * 5)) * 2, 0)).Unit
    elseif getgenv().DirectionV2 == "Wave" then
        return (Camera.CFrame.LookVector + Vector3.new(math.sin(tick() * 5), 0, 0)).Unit
    elseif getgenv().DirectionV2 == "Orbit" then
        local angle = tick() * 2
        return (Camera.CFrame.LookVector + Vector3.new(math.cos(angle), 0, math.sin(angle))).Unit
    elseif getgenv().DirectionV2 == "Chaos" then
        return (Camera.CFrame.LookVector + Vector3.new(math.random(-100, 100)/100, math.random(-100, 100)/100, math.random(-100, 100)/100)).Unit
    elseif getgenv().DirectionV2 == "TargetFeet" then
        local t = GetClosestPlayerV2()
        if t and hrp then
            local part = t:FindFirstChild("LeftFoot") or t:FindFirstChild("HumanoidRootPart")
            if part then
                return (part.Position - hrp.Position).Unit
            end
        end
    elseif getgenv().DirectionV2 == "TargetHead" then
        local t = GetClosestPlayerV2()
        if t and hrp then
            local part = t:FindFirstChild("Head")
            if part then
                return (part.Position - hrp.Position).Unit
            end
        end
    elseif getgenv().DirectionV2 == "DiagonalUp" then
        return (Camera.CFrame.LookVector + Vector3.new(0.5, 0.5, 0)).Unit
    elseif getgenv().DirectionV2 == "DiagonalDown" then
        return (Camera.CFrame.LookVector + Vector3.new(-0.5, -0.5, 0)).Unit
    elseif getgenv().DirectionV2 == "FlipReverse" then
        return (Camera.CFrame.LookVector * -1).Unit
    elseif getgenv().DirectionV2 == "CurveLeft" then
        return (Camera.CFrame.LookVector + -Camera.CFrame.RightVector * 0.5).Unit
    elseif getgenv().DirectionV2 == "CurveRight" then
        return (Camera.CFrame.LookVector + Camera.CFrame.RightVector * 0.5).Unit
    elseif getgenv().DirectionV2 == "Whirlwind" then
        local angle = math.rad(tick() * 720 % 360)
        return (Camera.CFrame.LookVector + Vector3.new(math.cos(angle), math.sin(angle), 0)).Unit
    elseif getgenv().DirectionV2 == "TeleportStyle" then
        return Vector3.new(0, 100, 0)
    elseif getgenv().DirectionV2 == "SlideAngle" then
        return (Camera.CFrame.LookVector + Vector3.new(1, -0.2, 0)).Unit
    elseif getgenv().DirectionV2 == "Drift" then
        return (Camera.CFrame.LookVector + Camera.CFrame.RightVector * math.cos(tick() * 2)).Unit
    elseif getgenv().DirectionV2 == "RandomTarget" then
        local candidates = {}
        for _, v in pairs(workspace.Alive:GetChildren()) do
            if v ~= localChar and v:FindFirstChild("HumanoidRootPart") then
                local screenPos, isOnScreen = Camera:WorldToScreenPoint(v.HumanoidRootPart.Position)
                if isOnScreen then
                    table.insert(candidates, v)
                end
            end
        end
        if #candidates > 0 then
            local pick = candidates[math.random(1, #candidates)]
            if hrp then
                return (pick.HumanoidRootPart.Position - hrp.Position).Unit
            end
        end
    end
    return Camera.CFrame.LookVector
end

local function ParryV2()
    for _, connection in pairs(getconnections(PlayerGui.Hotbar.Block.Activated)) do
        connection:Fire()
    end
end

local function AutoAbilityV2()
    local abilityCD = PlayerGui.Hotbar.Ability.UIGradient
    if abilityCD.Offset.Y == 0.6 then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Abilities") then
            local abilities = char.Abilities
            if abilities["Raging Deflection"].Enabled or abilities["Rapture"].Enabled or 
               abilities["Calming Deflection"].Enabled or abilities["Aerodynamic Slash"].Enabled or 
               abilities["Fracture"].Enabled or abilities["Death Slash"].Enabled then
                game:GetService("ReplicatedStorage").Remotes.AbilityButtonPress:Fire()
                task.spawn(function()
                    task.wait(getgenv().AutoAbilityDelayV2 or 2.8)
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DeathSlashShootActivation"):FireServer(true)
                end)
                return true
            end
        end
    end
    return false
end

local function CooldownProtectionV2()
    local parryCD = PlayerGui.Hotbar.Block.UIGradient
    if parryCD.Offset.Y < 0.4 then
        game:GetService("ReplicatedStorage").Remotes.AbilityButtonPress:Fire()
        return true
    end
    return false
end

local Tabs = {
    Info = Window:AddTab({ Name = "Info", Icon = "info" }),
    Autoparry = Window:AddTab({ Name = "Parry", Icon = "shield" }),
    Spam = Window:AddTab({ Name = "Spam", Icon = "" }),
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

local AutoparrySection1 = Tabs.Autoparry:AddSection("Auto Parry")

local autoparryConnection

AutoparrySection1:AddToggle({
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

local AutoparrySection = Tabs.Autoparry:AddSection("Auto Parry V2")

local autoparryV2Connection

AutoparrySection:AddToggle({
    Title = "Auto Parry V2",
    Default = false,
    Callback = function(enabled)
        getgenv().AutoParryV2 = enabled
        
        if enabled then
            if autoparryV2Connection then
                autoparryV2Connection:Disconnect()
            end
            
            autoparryV2Connection = RunService.PreRender:Connect(function()
                if not getgenv().AutoParryV2 then return end
                
                local ball = GetBallV2()
                if not ball then return end
                
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") or char.Parent.Name == "Dead" then return end
                
                local zoomies = ball:FindFirstChild("zoomies")
                if not zoomies then return end
                
                ball:GetAttributeChangedSignal("target"):Once(function()
                    ParriedV2 = false
                end)
                
                if ParriedV2 then return end
                
                local ballTarget = ball:GetAttribute("target")
                if ballTarget ~= tostring(LocalPlayer) then return end
                
                local velocity = zoomies.VectorVelocity
                local speed = velocity.Magnitude
                local distance = (char.HumanoidRootPart.Position - ball.Position).Magnitude
                local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 10
                
                local cappedSpeedDiff = math.min(math.max(speed - 9.5, 0), 650)
                local speedDivisorBase = 2.4 + cappedSpeedDiff * 0.002
                
                local effectiveMultiplier = SpeedMultiplierV2
                if getgenv().RandomAccuracyV2 then
                    if speed < 200 then
                        effectiveMultiplier = 0.7 + (math.random(40, 100) - 1) * (0.35 / 99)
                    else
                        effectiveMultiplier = 0.7 + (math.random(1, 100) - 1) * (0.35 / 99)
                    end
                end
                
                local speedDivisor = speedDivisorBase * effectiveMultiplier
                local parryAccuracy = ping + math.max(speed / speedDivisor, 9.5)
                
                if PhantomV2 and char:FindFirstChild("ParryHighlight") and getgenv().PhantomDetectionV2 then
                    return
                end
                
                if getgenv().InfinityDetectionV2 and InfinityV2 then
                    return
                end
                
                if ball:FindFirstChild("ComboCounter") and getgenv().SlashOfFuryDetectionV2 then
                    return
                end
                
                if ball:FindFirstChild("AeroDynamicSlashVFX") and getgenv().DeathSlashDetectionV2 then
                    return
                end
                
                if Runtime:FindFirstChild("Tornado") and getgenv().TimeHoleDetectionV2 then
                    return
                end
                
                if distance <= parryAccuracy then
                    if getgenv().AutoAbilityV2 and AutoAbilityV2() then
                        return
                    end
                    
                    if getgenv().CooldownProtectionV2 and CooldownProtectionV2() then
                        return
                    end
                    
                    ParryV2()
                    ParriedV2 = true
                    
                    local lastParry = tick()
                    repeat
                        RunService.PreSimulation:Wait()
                    until (tick() - lastParry) >= 1 or not ParriedV2
                    ParriedV2 = false
                end
            end)
        else
            if autoparryV2Connection then
                autoparryV2Connection:Disconnect()
                autoparryV2Connection = nil
            end
        end
    end
})

AutoparrySection:AddToggle({
    Title = "Random Accuracy",
    Default = false,
    Callback = function(enabled)
        getgenv().RandomAccuracyV2 = enabled
    end
})

AutoparrySection:AddDropdown({
    Title = "Direction",
    Options = {
        'Camera', 'Mouse', 'Players', 'Normal',
        'Up', 'Down', 'Left', 'Right', 'Behind',
        'Random', 'FrontLeft', 'FrontRight', 'BackLeft',
        'BackRight', 'SkywardSpiral', 'Zigzag', 'Spin',
        'Bounce', 'Wave', 'Orbit', 'Chaos', 'TargetFeet',
        'TargetHead', 'DiagonalUp', 'DiagonalDown',
        'FlipReverse', 'CurveLeft', 'CurveRight',
        'Whirlwind', 'TeleportStyle', 'SlideAngle', 'Drift',
        'RandomTarget'
    },
    Default = 'Camera',
    Callback = function(value)
        getgenv().DirectionV2 = value
    end
})

AutoparrySection:AddSlider({
    Title = "Parry Distance",
    Min = 30,
    Max = 100,
    Default = 30,
    Callback = function(value)
        SpeedMultiplierV2 = 0.7 + (value - 1) * (0.35 / 99)
    end
})

AutoparrySection:AddDivider()
AutoparrySection:AddSubSection("Ability Detection")
AutoparrySection:AddDivider()

AutoparrySection:AddToggle({
    Title = "Infinity Detection",
    Default = false,
    Callback = function(enabled)
        getgenv().InfinityDetectionV2 = enabled
    end
})

AutoparrySection:AddToggle({
    Title = "Slash of Fury Detection",
    Default = false,
    Callback = function(enabled)
        getgenv().SlashOfFuryDetectionV2 = enabled
    end
})

AutoparrySection:AddToggle({
    Title = "Phantom Detection",
    Default = false,
    Callback = function(enabled)
        getgenv().PhantomDetectionV2 = enabled
    end
})

AutoparrySection:AddToggle({
    Title = "Death Slash Detection",
    Default = false,
    Callback = function(enabled)
        getgenv().DeathSlashDetectionV2 = enabled
    end
})

AutoparrySection:AddToggle({
    Title = "Time Hole Detection",
    Default = false,
    Callback = function(enabled)
        getgenv().TimeHoleDetectionV2 = enabled
    end
})

AutoparrySection:AddToggle({
    Title = "Auto Block Telekinesis",
    Default = false,
    Callback = function(enabled)
        getgenv().AutoTelekinesisV2 = enabled
    end
})

AutoparrySection:AddToggle({
    Title = "Auto Block Spams",
    Default = false,
    Callback = function(enabled)
        getgenv().AutoBlockSpamsV2 = enabled
    end
})

AutoparrySection:AddToggle({
    Title = "Anti Block Spams",
    Default = false,
    Callback = function(enabled)
        getgenv().AntiBlockSpamsV2 = enabled
    end
})

AutoparrySection:AddToggle({
    Title = "Cooldown Protection",
    Default = false,
    Callback = function(enabled)
        getgenv().CooldownProtectionV2 = enabled
    end
})

AutoparrySection:AddDivider()

AutoparrySection:AddToggle({
    Title = "Auto Use Ability",
    Default = false,
    Callback = function(enabled)
        getgenv().AutoAbilityV2 = enabled
    end
})

AutoparrySection:AddInput({
    Title = "Ability Delay",
    Default = "2.8",
    Callback = function(value)
        local numValue = tonumber(value)
        if numValue and numValue >= 0 then
            getgenv().AutoAbilityDelayV2 = numValue
        end
    end
})

AutoparrySection:AddDivider()

AutoparrySection:AddToggle({
    Title = "Auto Curve",
    Default = false,
    Callback = function(enabled)
        getgenv().AutoCurveV2 = enabled
    end
})

AutoparrySection:AddToggle({
    Title = "Anti Curve",
    Default = false,
    Callback = function(enabled)
        getgenv().AntiCurveV2 = enabled
    end
})

local lobbyparry = Tabs.Autoparry:AddSection("Lobby Auto Parry")

local lobbyParryV2Connection

lobbyparry:AddToggle({
    Title = "Lobby Auto Parry",
    Default = false,
    Callback = function(enabled)
        getgenv().LobbyAPV2 = enabled
        
        if enabled then
            if lobbyParryV2Connection then
                lobbyParryV2Connection:Disconnect()
            end
            
            lobbyParryV2Connection = RunService.Heartbeat:Connect(function()
                if not getgenv().LobbyAPV2 then return end
                
                local trainingBalls = workspace:FindFirstChild("TrainingBalls")
                if not trainingBalls then return end
                
                local ball
                for _, v in pairs(trainingBalls:GetChildren()) do
                    if v:GetAttribute("realBall") then
                        ball = v
                        break
                    end
                end
                
                if not ball then return end
                
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                
                local zoomies = ball:FindFirstChild("zoomies")
                if not zoomies then return end
                
                ball:GetAttributeChangedSignal("target"):Once(function()
                    LobbyParriedV2 = false
                end)
                
                if LobbyParriedV2 then return end
                
                local ballTarget = ball:GetAttribute("target")
                if ballTarget ~= tostring(LocalPlayer) then return end
                
                local velocity = zoomies.VectorVelocity
                local speed = velocity.Magnitude
                local distance = (char.HumanoidRootPart.Position - ball.Position).Magnitude
                local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 10
                
                local cappedSpeedDiff = math.min(math.max(speed - 9.5, 0), 650)
                local speedDivisorBase = 2.4 + cappedSpeedDiff * 0.002
                
                local effectiveMultiplier = LobbySpeedMultiplierV2
                if getgenv().LobbyRandomAccuracyV2 then
                    effectiveMultiplier = 0.7 + (math.random(1, 100) - 1) * (0.35 / 99)
                end
                
                local speedDivisor = speedDivisorBase * effectiveMultiplier
                local parryAccuracy = ping + math.max(speed / speedDivisor, 9.5)
                
                if distance <= parryAccuracy then
                    ParryV2()
                    LobbyParriedV2 = true
                    
                    local lastParry = tick()
                    repeat
                        RunService.PreSimulation:Wait()
                    until (tick() - lastParry) >= 1 or not LobbyParriedV2
                    LobbyParriedV2 = false
                end
            end)
        else
            if lobbyParryV2Connection then
                lobbyParryV2Connection:Disconnect()
                lobbyParryV2Connection = nil
            end
        end
    end
})

local SpamSection = Tabs.Spam:AddSection("Spam")

SpamSection:AddToggle({
    Title = "Auto Spam",
    Content = "For V2 Only",
    Default = false,
    Callback = function(enabled)
        getgenv().AutoSpamV2 = enabled
    end
})

SpamSection:AddToggle({
    Title = "Animation Fix",
    Default = false,
    Callback = function(enabled)
        getgenv().AnimationFixV2 = enabled
        
        if enabled then
            if ConnectionsV2['Animation Fix'] then
                ConnectionsV2['Animation Fix']:Disconnect()
            end
            
            ConnectionsV2['Animation Fix'] = RunService.PreRender:Connect(function()
                if not getgenv().AnimationFixV2 then return end
                
                local ball = GetBallV2()
                if not ball then return end
                
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") or char.Parent.Name == "Dead" then return end
                
                local zoomies = ball:FindFirstChild("zoomies")
                if not zoomies then return end
                
                local closest = GetClosestPlayerV2()
                if not closest then return end
                
                local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 10
                local velocity = zoomies.VectorVelocity
                local speed = velocity.Magnitude
                local distance = (char.HumanoidRootPart.Position - ball.Position).Magnitude
                
                local ballTarget = ball:GetAttribute("target")
                if ballTarget ~= tostring(LocalPlayer) then return end
                
                local targetDistance = (closest.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                
                local cappedSpeedDiff = math.min(math.max(speed - 9.5, 0), 650)
                local speedDivisorBase = 2.4 + cappedSpeedDiff * 0.002
                local speedDivisor = speedDivisorBase * SpeedMultiplierV2
                local spamAccuracy = ping + math.max(speed / speedDivisor, 9.5)
                
                if targetDistance > spamAccuracy or distance > spamAccuracy then return end
                
                local pulsed = char:GetAttribute("Pulsed")
                if pulsed then return end
                
                if ballTarget == tostring(LocalPlayer) and targetDistance > 30 and distance > 30 then return end
                
                if distance <= spamAccuracy and ParriesV2 > ParryThresholdV2 then
                    ParryV2()
                end
            end)
        else
            if ConnectionsV2['Animation Fix'] then
                ConnectionsV2['Animation Fix']:Disconnect()
                ConnectionsV2['Animation Fix'] = nil
            end
        end
    end
})

SpamSection:AddSlider({
    Title = "Spam Power",
    Min = 1,
    Max = 5,
    Default = 2.5,
    Callback = function(value)
        ParryThresholdV2 = value
    end
})

SpamSection:AddDivider()

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

                local MinimizeButton = Instance.new("TextButton", ManualSpamFrame)
                MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
                MinimizeButton.Position = UDim2.new(1, -25, 0, 5)
                MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 0, 100)
                MinimizeButton.BorderSizePixel = 0
                MinimizeButton.Font = Enum.Font.GothamBold
                MinimizeButton.Text = "-"
                MinimizeButton.TextYAlignment = Enum.TextYAlignment.Center
                MinimizeButton.TextColor3 = Color3.fromRGB(200, 120, 255)
                MinimizeButton.TextSize = 14
                MinimizeButton.ZIndex = 2

                local MinBtnCorner = Instance.new("UICorner", MinimizeButton)
                MinBtnCorner.CornerRadius = UDim.new(0, 4)

                local MinBtnStroke = Instance.new("UIStroke", MinimizeButton)
                MinBtnStroke.Color = Color3.fromRGB(120, 50, 200)
                MinBtnStroke.Thickness = 1
                MinBtnStroke.Transparency = 0.5

                ManualSpamButton = Instance.new("TextButton", ManualSpamFrame)
                ManualSpamButton.Name = "ContentFrame"
                ManualSpamButton.Size = UDim2.new(1, -35, 1, -10)
                ManualSpamButton.Position = UDim2.new(0, 10, 0, 5)
                ManualSpamButton.BackgroundTransparency = 1
                ManualSpamButton.Font = Enum.Font.Gotham
                ManualSpamButton.TextColor3 = Color3.fromRGB(200, 120, 255)
                ManualSpamButton.TextSize = 20
                ManualSpamButton.Text = "SPAM: OFF"
                ManualSpamButton.TextStrokeTransparency = 0.5
                ManualSpamButton.Active = false

                local isMinimized = false
                local originalSize = ManualSpamFrame.Size

                MinimizeButton.MouseButton1Click:Connect(function()
                    isMinimized = not isMinimized

                    if isMinimized then
                        TweenService:Create(ManualSpamFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                            Size = UDim2.new(0, 50, 0, 30)
                        }):Play()
                        MinimizeButton.Text = "+"
                        MinimizeButton.TextYAlignment = Enum.TextYAlignment.Center
                        ManualSpamButton.Visible = false
                    else
                        TweenService:Create(ManualSpamFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                            Size = originalSize
                        }):Play()
                        MinimizeButton.Text = "-"
                        MinimizeButton.TextYAlignment = Enum.TextYAlignment.Center
                        ManualSpamButton.Visible = true
                    end
                end)

                MinimizeButton.MouseEnter:Connect(function()
                    TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(80, 0, 120)
                    }):Play()
                end)

                MinimizeButton.MouseLeave:Connect(function()
                    TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(60, 0, 100)
                    }):Play()
                end)

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
                                task.wait()
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
    Title = "Player Focus",
    Content = "Similar to Aimbot",
    Default = false,
    Callback = function(enabled)
        getgenv().PlayerFocusV2 = enabled
    end
})

PlayerSection2:AddDivider()

local PlayerModsFrame
local PlayerModsToggles = {}
local PlayerModsConnections = {}

PlayerSection2:AddToggle({
    Title = "Player Modifications",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if not PlayerModsFrame then
                local ScreenGui = Instance.new("ScreenGui")
                ScreenGui.Name = "PlayerModificationsGUI"
                ScreenGui.ResetOnSpawn = false
                ScreenGui.Parent = CoreGui

                PlayerModsFrame = Instance.new("Frame", ScreenGui)
                PlayerModsFrame.Size = UDim2.new(0, 280, 0, 420)
                PlayerModsFrame.Position = UDim2.new(0.5, -140, 0.5, -210)
                PlayerModsFrame.BackgroundColor3 = Color3.fromRGB(45, 0, 80)
                PlayerModsFrame.BackgroundTransparency = 0.2
                PlayerModsFrame.BorderSizePixel = 0
                PlayerModsFrame.Active = true
                PlayerModsFrame.Draggable = true

                local UICorner = Instance.new("UICorner", PlayerModsFrame)
                UICorner.CornerRadius = UDim.new(0, 12)

                local UIStroke = Instance.new("UIStroke", PlayerModsFrame)
                UIStroke.Color = Color3.fromRGB(120, 50, 200)
                UIStroke.Thickness = 2
                UIStroke.Transparency = 0.5

                local UIGradient = Instance.new("UIGradient", PlayerModsFrame)
                UIGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 0, 100)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 0, 60))
                })
                UIGradient.Rotation = 45

                local TitleBar = Instance.new("Frame", PlayerModsFrame)
                TitleBar.Size = UDim2.new(1, 0, 0, 40)
                TitleBar.BackgroundTransparency = 1

                local Title = Instance.new("TextLabel", TitleBar)
                Title.Size = UDim2.new(1, -50, 1, 0)
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.BackgroundTransparency = 1
                Title.Font = Enum.Font.GothamMedium
                Title.Text = "Aikoware | Modifications"
                Title.TextColor3 = Color3.fromRGB(200, 120, 255)
                Title.TextSize = 16
                Title.TextStrokeTransparency = 0.5
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local MinimizeButton = Instance.new("TextButton", TitleBar)
                MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
                MinimizeButton.Position = UDim2.new(1, -35, 0, 5)
                MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 0, 100)
                MinimizeButton.BorderSizePixel = 0
                MinimizeButton.Font = Enum.Font.GothamBold
                MinimizeButton.Text = "-"
                MinimizeButton.TextColor3 = Color3.fromRGB(200, 120, 255)
                MinimizeButton.TextSize = 24
                MinimizeButton.TextYAlignment = Enum.TextYAlignment.Center

                local MinBtnCorner = Instance.new("UICorner", MinimizeButton)
                MinBtnCorner.CornerRadius = UDim.new(0, 6)

                local MinBtnStroke = Instance.new("UIStroke", MinimizeButton)
                MinBtnStroke.Color = Color3.fromRGB(120, 50, 200)
                MinBtnStroke.Thickness = 1
                MinBtnStroke.Transparency = 0.5

                local ScrollFrame = Instance.new("ScrollingFrame", PlayerModsFrame)
                ScrollFrame.Name = "ContentFrame"
                ScrollFrame.Size = UDim2.new(1, -20, 1, -50)
                ScrollFrame.Position = UDim2.new(0, 10, 0, 45)
                ScrollFrame.BackgroundTransparency = 1
                ScrollFrame.BorderSizePixel = 0
                ScrollFrame.ScrollBarThickness = 4
                ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
                ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 50, 200)

                local UIListLayout = Instance.new("UIListLayout", ScrollFrame)
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.Padding = UDim.new(0, 8)

                local isMinimized = false
                local originalSize = PlayerModsFrame.Size

                MinimizeButton.MouseButton1Click:Connect(function()
                    isMinimized = not isMinimized

                    if isMinimized then
                        TweenService:Create(PlayerModsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                            Size = UDim2.new(0, 280, 0, 45)
                        }):Play()
                        MinimizeButton.Text = "+"
                        ScrollFrame.Visible = false
                    else
                        TweenService:Create(PlayerModsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
                            Size = originalSize
                        }):Play()
                        MinimizeButton.Text = "-"
                        ScrollFrame.Visible = true
                    end
                end)

                MinimizeButton.MouseEnter:Connect(function()
                    TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(80, 0, 120)
                    }):Play()
                end)

                MinimizeButton.MouseLeave:Connect(function()
                    TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(60, 0, 100)
                    }):Play()
                end)

                -- Initialize PlayerModsConnections if not exists
                if not PlayerModsConnections then
                    PlayerModsConnections = {}
                end

                local function createToggle(name, yPos, callback)
                    local ToggleFrame = Instance.new("Frame", ScrollFrame)
                    ToggleFrame.Size = UDim2.new(1, -10, 0, 30)
                    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 0, 50)
                    ToggleFrame.BackgroundTransparency = 0.3
                    ToggleFrame.BorderSizePixel = 0

                    local ToggleCorner = Instance.new("UICorner", ToggleFrame)
                    ToggleCorner.CornerRadius = UDim.new(0, 8)

                    local ToggleLabel = Instance.new("TextLabel", ToggleFrame)
                    ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
                    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
                    ToggleLabel.BackgroundTransparency = 1
                    ToggleLabel.Font = Enum.Font.Gotham
                    ToggleLabel.Text = name
                    ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                    ToggleLabel.TextSize = 13
                    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                    ToggleLabel.TextStrokeTransparency = 0.8

                    local ToggleButton = Instance.new("TextButton", ToggleFrame)
                    ToggleButton.Size = UDim2.new(0, 35, 0, 20)
                    ToggleButton.Position = UDim2.new(1, -40, 0.5, -10)
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
                    ToggleButton.Text = ""
                    ToggleButton.BorderSizePixel = 0

                    local ButtonCorner = Instance.new("UICorner", ToggleButton)
                    ButtonCorner.CornerRadius = UDim.new(1, 0)

                    local ToggleIndicator = Instance.new("Frame", ToggleButton)
                    ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
                    ToggleIndicator.Position = UDim2.new(0, 2, 0.5, -8)
                    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                    ToggleIndicator.BorderSizePixel = 0

                    local IndicatorCorner = Instance.new("UICorner", ToggleIndicator)
                    IndicatorCorner.CornerRadius = UDim.new(1, 0)

                    local isEnabled = false

                    ToggleButton.MouseButton1Click:Connect(function()
                        isEnabled = not isEnabled

                        if isEnabled then
                            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 150, 80)}):Play()
                            TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
                        else
                            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 0, 0)}):Play()
                            TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
                        end

                        callback(isEnabled)
                    end)

                    return ToggleFrame, function() return isEnabled end
                end

                local function createSlider(name, min, max, default, callback)
                    local SliderFrame = Instance.new("Frame", ScrollFrame)
                    SliderFrame.Size = UDim2.new(1, -10, 0, 50)
                    SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 0, 50)
                    SliderFrame.BackgroundTransparency = 0.3
                    SliderFrame.BorderSizePixel = 0

                    local SliderCorner = Instance.new("UICorner", SliderFrame)
                    SliderCorner.CornerRadius = UDim.new(0, 8)

                    local SliderLabel = Instance.new("TextLabel", SliderFrame)
                    SliderLabel.Size = UDim2.new(1, -20, 0, 20)
                    SliderLabel.Position = UDim2.new(0, 10, 0, 5)
                    SliderLabel.BackgroundTransparency = 1
                    SliderLabel.Font = Enum.Font.Gotham
                    SliderLabel.Text = name .. ": " .. default
                    SliderLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                    SliderLabel.TextSize = 13
                    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SliderLabel.TextStrokeTransparency = 0.8

                    local SliderBar = Instance.new("Frame", SliderFrame)
                    SliderBar.Size = UDim2.new(1, -20, 0, 6)
                    SliderBar.Position = UDim2.new(0, 10, 1, -15)
                    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 0, 80)
                    SliderBar.BorderSizePixel = 0

                    local BarCorner = Instance.new("UICorner", SliderBar)
                    BarCorner.CornerRadius = UDim.new(1, 0)

                    local SliderFill = Instance.new("Frame", SliderBar)
                    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                    SliderFill.BackgroundColor3 = Color3.fromRGB(120, 50, 200)
                    SliderFill.BorderSizePixel = 0

                    local FillCorner = Instance.new("UICorner", SliderFill)
                    FillCorner.CornerRadius = UDim.new(1, 0)

                    local dragging = false

                    SliderBar.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                        end
                    end)

                    SliderBar.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            local pos = (input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
                            pos = math.clamp(pos, 0, 1)
                            local value = math.floor(min + (max - min) * pos)

                            SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                            SliderLabel.Text = name .. ": " .. value
                            callback(value)
                        end
                    end)

                    return SliderFrame
                end

                -- Infinite Jump Toggle
                createToggle("Infinite Jump", 0, function(enabled)
                    getgenv().InfiniteJumpEnabled = enabled

                    if enabled then
                        if PlayerModsConnections.InfiniteJump then
                            PlayerModsConnections.InfiniteJump:Disconnect()
                        end
                        PlayerModsConnections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
                            if getgenv().InfiniteJumpEnabled then
                                local char = LocalPlayer.Character
                                if char and char:FindFirstChild("Humanoid") then
                                    char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                end
                            end
                        end)
                    else
                        if PlayerModsConnections.InfiniteJump then
                            PlayerModsConnections.InfiniteJump:Disconnect()
                            PlayerModsConnections.InfiniteJump = nil
                        end
                    end
                end)

                -- Auto Jump Toggle
                createToggle("Auto Jump", 1, function(enabled)
                    getgenv().AutoJumpV2 = enabled
                end)

                -- Spin Toggle
                createToggle("Spin", 2, function(enabled)
                    getgenv().SpinbotEnabled = enabled

                    if enabled then
                        if PlayerModsConnections.Spin then
                            PlayerModsConnections.Spin:Disconnect()
                        end
                        getgenv().spinAngle = 0
                        PlayerModsConnections.Spin = RunService.Heartbeat:Connect(function()
                            if getgenv().SpinbotEnabled then
                                local char = LocalPlayer.Character
                                if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                                    char.Humanoid.AutoRotate = false
                                    getgenv().spinAngle = (getgenv().spinAngle + (getgenv().CustomSpinSpeed or 5)) % 360
                                    char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position) * CFrame.Angles(0, math.rad(getgenv().spinAngle), 0)
                                end
                            end
                        end)
                    else
                        if PlayerModsConnections.Spin then
                            PlayerModsConnections.Spin:Disconnect()
                            PlayerModsConnections.Spin = nil
                        end
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") then
                            char.Humanoid.AutoRotate = true
                        end
                    end
                end)

                -- Spin Speed Slider
                createSlider("Spin Speed", 1, 50, 5, function(value)
                    getgenv().CustomSpinSpeed = value
                end)

                -- Walk Speed Toggle
                createToggle("Walk Speed", 4, function(enabled)
                    getgenv().WalkspeedEnabled = enabled

                    if enabled then
                        if PlayerModsConnections.WalkSpeed then
                            PlayerModsConnections.WalkSpeed:Disconnect()
                        end
                        PlayerModsConnections.WalkSpeed = RunService.Heartbeat:Connect(function()
                            if getgenv().WalkspeedEnabled then
                                local char = LocalPlayer.Character
                                if char and char:FindFirstChild("Humanoid") then
                                    char.Humanoid.WalkSpeed = getgenv().CustomWalkSpeed or 36
                                end
                            end
                        end)
                    else
                        if PlayerModsConnections.WalkSpeed then
                            PlayerModsConnections.WalkSpeed:Disconnect()
                            PlayerModsConnections.WalkSpeed = nil
                        end
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") then
                            char.Humanoid.WalkSpeed = 16
                        end
                    end
                end)

                -- Walk Speed Slider
                createSlider("Walk Speed", 16, 500, 36, function(value)
                    getgenv().CustomWalkSpeed = value
                end)

                -- Jump Power Toggle
                createToggle("Jump Power", 6, function(enabled)
                    getgenv().JumpPowerEnabled = enabled

                    if enabled then
                        if PlayerModsConnections.JumpPower then
                            PlayerModsConnections.JumpPower:Disconnect()
                        end
                        PlayerModsConnections.JumpPower = RunService.Heartbeat:Connect(function()
                            if getgenv().JumpPowerEnabled then
                                local char = LocalPlayer.Character
                                if char and char:FindFirstChild("Humanoid") then
                                    if char.Humanoid.UseJumpPower then
                                        char.Humanoid.JumpPower = getgenv().CustomJumpPower or 50
                                    else
                                        char.Humanoid.JumpHeight = getgenv().CustomJumpHeight or 7.2
                                    end
                                end
                            end
                        end)
                    else
                        if PlayerModsConnections.JumpPower then
                            PlayerModsConnections.JumpPower:Disconnect()
                            PlayerModsConnections.JumpPower = nil
                        end
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") then
                            if char.Humanoid.UseJumpPower then
                                char.Humanoid.JumpPower = 50
                            else
                                char.Humanoid.JumpHeight = 7.2
                            end
                        end
                    end
                end)

                -- Jump Power Slider
                createSlider("Jump Power", 50, 200, 50, function(value)
                    getgenv().CustomJumpPower = value
                    getgenv().CustomJumpHeight = value * 0.144
                end)

                -- Gravity Toggle
                createToggle("Gravity", 8, function(enabled)
                    getgenv().GravityEnabled = enabled

                    if enabled then
                        if PlayerModsConnections.Gravity then
                            PlayerModsConnections.Gravity:Disconnect()
                        end
                        PlayerModsConnections.Gravity = RunService.Heartbeat:Connect(function()
                            if getgenv().GravityEnabled then
                                workspace.Gravity = getgenv().CustomGravity or 196.2
                            end
                        end)
                    else
                        if PlayerModsConnections.Gravity then
                            PlayerModsConnections.Gravity:Disconnect()
                            PlayerModsConnections.Gravity = nil
                        end
                        workspace.Gravity = 196.2
                    end
                end)

                -- Gravity Slider
                createSlider("Gravity", 0, 400, 196, function(value)
                    getgenv().CustomGravity = value
                end)

                -- Hip Height Toggle
                createToggle("Hip Height", 10, function(enabled)
                    getgenv().HipHeightEnabled = enabled

                    if enabled then
                        if PlayerModsConnections.HipHeight then
                            PlayerModsConnections.HipHeight:Disconnect()
                        end
                        PlayerModsConnections.HipHeight = RunService.Heartbeat:Connect(function()
                            if getgenv().HipHeightEnabled then
                                local char = LocalPlayer.Character
                                if char and char:FindFirstChild("Humanoid") then
                                    char.Humanoid.HipHeight = getgenv().CustomHipHeight or 0
                                end
                            end
                        end)
                    else
                        if PlayerModsConnections.HipHeight then
                            PlayerModsConnections.HipHeight:Disconnect()
                            PlayerModsConnections.HipHeight = nil
                        end
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") then
                            char.Humanoid.HipHeight = 0
                        end
                    end
                end)
                
                -- Hip Height Slider
                createSlider("Hip Height", -5, 20, 0, function(value)
                    getgenv().CustomHipHeight = value
                end)
            end

            PlayerModsFrame.Visible = true
        else
            if PlayerModsFrame then
                PlayerModsFrame.Visible = false
            end

            -- Disconnect all connections
            if PlayerModsConnections then
                for _, connection in pairs(PlayerModsConnections) do
                    if connection then
                        connection:Disconnect()
                    end
                end
                PlayerModsConnections = {}
            end

            -- Reset all flags
            getgenv().InfiniteJumpEnabled = false
            getgenv().SpinbotEnabled = false
            getgenv().WalkspeedEnabled = false
            getgenv().JumpPowerEnabled = false
            getgenv().GravityEnabled = false
            getgenv().HipHeightEnabled = false
            
            -- Reset character properties
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16
                    humanoid.AutoRotate = true
                    humanoid.HipHeight = 0
                    if humanoid.UseJumpPower then
                        humanoid.JumpPower = 50
                    else
                        humanoid.JumpHeight = 7.2
                    end
                end
            end
            workspace.Gravity = 196.2
        end
    end
})

local VisualsSection = Tabs.Visuals:AddSection("Display")

local PingFrame
local PingText
local PingUpdateLoop

VisualsSection:AddToggle({
    Title = "Show Ping",
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
                PingText.Font = Enum.Font.Gotham
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

local StatsFrame
local StatsUpdateLoop
local SessionStartTime = tick()

VisualsSection:AddToggle({
    Title = "Show Player Stats",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if not StatsFrame then
                local ScreenGui = Instance.new("ScreenGui")
                ScreenGui.Name = "StatsDisplay"
                ScreenGui.ResetOnSpawn = false
                ScreenGui.Parent = CoreGui

                StatsFrame = Instance.new("Frame", ScreenGui)
                StatsFrame.Size = UDim2.new(0, 200, 0, 150)
                StatsFrame.Position = UDim2.new(0, 20, 0.3, -90)
                StatsFrame.BackgroundColor3 = Color3.fromRGB(20, 10, 35)
                StatsFrame.BackgroundTransparency = 0.15
                StatsFrame.BorderSizePixel = 0
                StatsFrame.Active = true

                local UICorner = Instance.new("UICorner", StatsFrame)
                UICorner.CornerRadius = UDim.new(0, 12)

                local UIStroke = Instance.new("UIStroke", StatsFrame)
                UIStroke.Color = Color3.fromRGB(138, 43, 226)
                UIStroke.Thickness = 2
                UIStroke.Transparency = 0.5

                local UIGradient = Instance.new("UIGradient", StatsFrame)
                UIGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 20, 60)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 10, 40))
                })
                UIGradient.Rotation = 135

                local Title = Instance.new("TextLabel", StatsFrame)
                Title.Size = UDim2.new(1, -20, 0, 30)
                Title.Position = UDim2.new(0, 10, 0, 8)
                Title.BackgroundTransparency = 1
                Title.Font = Enum.Font.GothamMedium
                Title.Text = "Aikoware | Player Stats"
                Title.TextColor3 = Color3.fromRGB(138, 43, 226)
                Title.TextSize = 16
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.TextStrokeTransparency = 0.5

                local Divider = Instance.new("Frame", StatsFrame)
                Divider.Size = UDim2.new(1, -20, 0, 2)
                Divider.Position = UDim2.new(0, 10, 0, 40)
                Divider.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
                Divider.BackgroundTransparency = 0.7
                Divider.BorderSizePixel = 0

                local DividerCorner = Instance.new("UICorner", Divider)
                DividerCorner.CornerRadius = UDim.new(1, 0)

                local StatsContainer = Instance.new("Frame", StatsFrame)
                StatsContainer.Size = UDim2.new(1, -20, 1, -50)
                StatsContainer.Position = UDim2.new(0, 10, 0, 48)
                StatsContainer.BackgroundTransparency = 1

                local function createStatLabel(text, yPos)
                    local StatLabel = Instance.new("TextLabel", StatsContainer)
                    StatLabel.Size = UDim2.new(1, 0, 0, 24)
                    StatLabel.Position = UDim2.new(0, 0, 0, yPos)
                    StatLabel.BackgroundTransparency = 1
                    StatLabel.Font = Enum.Font.Gotham
                    StatLabel.Text = text
                    StatLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                    StatLabel.TextSize = 13
                    StatLabel.TextXAlignment = Enum.TextXAlignment.Left
                    StatLabel.TextStrokeTransparency = 0.8
                    return StatLabel
                end

                local WinsLabel = createStatLabel("Wins: 0", 0)
                local ElimsLabel = createStatLabel("Elims: 0", 26)
                local PlaytimeLabel = createStatLabel("Playtime: 0s", 52)
                local WLRatioLabel = createStatLabel("W/E Ratio: 0.00", 78)

                local dragging = false
                local dragStart, startPos

                StatsFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragStart = input.Position
                        startPos = StatsFrame.Position
                    end
                end)

                StatsFrame.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local delta = input.Position - dragStart
                        StatsFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    end
                end)

                local function updateStats()
                    task.spawn(function()
                        pcall(function()
                            local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                            if not leaderstats then
                                WinsLabel.Text = "Wins: Loading..."
                                ElimsLabel.Text = "Eliminations: Loading..."
                                PlaytimeLabel.Text = "Server Playtime: 0s"
                                WLRatioLabel.Text = "W/E Ratio: Loading..."
                                return
                            end

                            local wins = leaderstats:FindFirstChild("Wins")
                            local elims = leaderstats:FindFirstChild("Elims")

                            if wins then
                                WinsLabel.Text = "Wins: " .. tostring(wins.Value)
                            else
                                WinsLabel.Text = "Wins: N/A"
                            end
                            
                            if elims then
                                ElimsLabel.Text = "Eliminations: " .. tostring(elims.Value)
                            else
                                ElimsLabel.Text = "Eliminations: N/A"
                            end

                            local sessionTime = tick() - SessionStartTime
                            local hours = math.floor(sessionTime / 3600)
                            local minutes = math.floor((sessionTime % 3600) / 60)
                            local seconds = math.floor(sessionTime % 60)
                            
                            if hours > 0 then
                                PlaytimeLabel.Text = string.format("Server Playtime: %dh %dm", hours, minutes)
                            elseif minutes > 0 then
                                PlaytimeLabel.Text = string.format("Server Playtime: %dm %ds", minutes, seconds)
                            else
                                PlaytimeLabel.Text = string.format("Server Playtime: %ds", seconds)
                            end

                            if wins and elims then
                                if elims.Value > 0 then
                                    local ratio = wins.Value / elims.Value
                                    WLRatioLabel.Text = string.format("W/E Ratio: %.2f", ratio)
                                elseif wins.Value > 0 then
                                    WLRatioLabel.Text = "W/E Ratio: "
                                else
                                    WLRatioLabel.Text = "W/E Ratio: 0.00"
                                end
                            else
                                WLRatioLabel.Text = "W/E Ratio: N/A"
                            end
                        end)
                    end)
                end

                updateStats()

                task.spawn(function()
                    LocalPlayer:WaitForChild("leaderstats", 10)
                    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                    if leaderstats then
                        for _, stat in pairs(leaderstats:GetChildren()) do
                            if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                                stat.Changed:Connect(updateStats)
                            end
                        end
                        updateStats()
                    end
                end)

                LocalPlayer.ChildAdded:Connect(function(child)
                    if child.Name == "leaderstats" then
                        task.wait(0.1)
                        for _, stat in pairs(child:GetChildren()) do
                            if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                                stat.Changed:Connect(updateStats)
                            end
                        end
                        updateStats()
                    end
                end)

                StatsUpdateLoop = task.spawn(function()
                    while task.wait(1) do
                        if not StatsFrame or not StatsFrame.Visible then break end
                        updateStats()
                    end
                end)
            end

            StatsFrame.Visible = true
        else
            if StatsFrame then
                StatsFrame.Visible = false
            end
            if StatsUpdateLoop then
                task.cancel(StatsUpdateLoop)
                StatsUpdateLoop = nil
            end
        end
    end
})

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

VisualsSection:AddToggle({
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
                CurrentSpeedText.Font = Enum.Font.Gotham
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

local ESPSection = Tabs.Visuals:AddSection("ESP")

ESPSection:AddToggle({
    Title = "ESP 2D Box",
    Default = false,
    Callback = function(enabled)
        ESPLines.Enabled = enabled or ESPLines.ShowName or ESPLines.ShowHealth or ESPLines.ShowTracer or ESPLines.ShowDistance
        ESPLines.ShowBox = enabled
        getgenv().ESPEnabled = ESPLines.Enabled
        getgenv().ESPShowBox = enabled
        for player, _ in pairs(ESPLines.Objects) do
            RemoveESP(player)
            CreateESP(player)
        end
    end
})

ESPSection:AddToggle({
    Title = "ESP Player Name",
    Default = false,
    Callback = function(enabled)
        ESPLines.Enabled = enabled or ESPLines.ShowBox or ESPLines.ShowHealth or ESPLines.ShowTracer or ESPLines.ShowDistance
        ESPLines.ShowName = enabled
        getgenv().ESPEnabled = ESPLines.Enabled
        getgenv().ESPShowName = enabled
        for player, _ in pairs(ESPLines.Objects) do
            RemoveESP(player)
            CreateESP(player)
        end
    end
})

ESPSection:AddToggle({
    Title = "ESP Player Health",
    Default = false,
    Callback = function(enabled)
        ESPLines.Enabled = enabled or ESPLines.ShowBox or ESPLines.ShowName or ESPLines.ShowTracer or ESPLines.ShowDistance
        ESPLines.ShowHealth = enabled
        getgenv().ESPEnabled = ESPLines.Enabled
        getgenv().ESPShowHealth = enabled
        for player, _ in pairs(ESPLines.Objects) do
            RemoveESP(player)
            CreateESP(player)
        end
    end
})

ESPSection:AddToggle({
    Title = "ESP Tracer",
    Default = false,
    Callback = function(enabled)
        ESPLines.Enabled = enabled or ESPLines.ShowBox or ESPLines.ShowName or ESPLines.ShowHealth or ESPLines.ShowDistance
        ESPLines.ShowTracer = enabled
        getgenv().ESPEnabled = ESPLines.Enabled
        getgenv().ESPShowTracer = enabled
        for player, _ in pairs(ESPLines.Objects) do
            RemoveESP(player)
            CreateESP(player)
        end
    end
})

ESPSection:AddToggle({
    Title = "ESP Distance",
    Default = false,
    Callback = function(enabled)
        ESPLines.Enabled = enabled or ESPLines.ShowBox or ESPLines.ShowName or ESPLines.ShowHealth or ESPLines.ShowTracer
        ESPLines.ShowDistance = enabled
        getgenv().ESPEnabled = ESPLines.Enabled
        getgenv().ESPShowDistance = enabled
        for player, _ in pairs(ESPLines.Objects) do
            RemoveESP(player)
            CreateESP(player)
        end
    end
})

local adminESPEnabled = false

ESPSection:AddToggle({
    Title = "ESP Admin",
    Default = false,
    Callback = function(enabled)
        adminESPEnabled = enabled
        
        local targetNames = {"Admin", "Owner"}
        
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
            label.Font = Enum.Font.GothamMedium
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

local ability_esp = {
    __config = {
        gui_name = "AbilityESPGui",
        gui_size = UDim2.new(0, 200, 0, 40),
        studs_offset = Vector3.new(0, 3.2, 0),
        text_color = Color3.fromRGB(255, 255, 255),
        stroke_color = Color3.fromRGB(0, 0, 0),
        font = Enum.Font.GothamMedium,
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
    if not player or not player.Parent then
        return false
    end
    
    if not label or not label.Parent then
        return false
    end
    
    local character = player.Character
    if not character or not character.Parent then
        return false
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return false
    end
    
    if humanoid.Health <= 0 then
        pcall(function()
            if label then
                label.Visible = false
            end
        end)
        return false
    end
    
    pcall(function()
        if ability_esp.__state.active and label then
            label.Visible = true
            local ability_name = player:GetAttribute("EquippedAbility")
            if ability_name and ability_name ~= "" then
                label.Text = "Ability: " .. ability_name
            else
                label.Text = ""
            end
        else
            if label then
                label.Visible = false
            end
        end
    end)
    
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
            pcall(function()
                if ability_esp.__state.players[player] then
                    if ability_esp.__state.players[player].billboard then
                        ability_esp.__state.players[player].billboard:Destroy()
                    end
                    ability_esp.__state.players[player].label = nil
                    ability_esp.__state.players[player].billboard = nil
                    ability_esp.__state.players[player].character = nil
                end
            end)
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
    pcall(function()
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
    end)
end

function ability_esp.update_loop()
    while ability_esp.__state.active do
        task.wait(ability_esp.__config.update_rate)
        
        local players_to_remove = {}
        
        for player, player_data in pairs(ability_esp.__state.players) do
            pcall(function()
                if not player or not player.Parent then
                    table.insert(players_to_remove, player)
                    return
                end
                
                local character = player.Character
                if not character or not character.Parent or not character:FindFirstChild("Humanoid") then
                    if player_data.billboard then
                        player_data.billboard:Destroy()
                        player_data.billboard = nil
                        player_data.label = nil
                    end
                    return
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
                    ability_esp.update_label(player, player_data.label)
                end
            end)
        end
        
        for _, player in ipairs(players_to_remove) do
            pcall(function()
                if ability_esp.__state.players[player] then
                    if ability_esp.__state.players[player].billboard then
                        ability_esp.__state.players[player].billboard:Destroy()
                    end
                    ability_esp.__state.players[player] = nil
                end
            end)
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
    
    pcall(function()
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
    end)
end

ESPSection:AddToggle({
    Title = 'ESP Player Ability',
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
        { id = "92076037937225", name = "FAH" },
    { id = "96664488756631", name = "" },
    { id = "116957716755028", name = "Leave me alone" },
    { id = "8643750815", name = "GET OVER HERE" },
    { id = "93779555057888", name = "HEHEHE HA" },
    { id = "84233173598772", name = "Head Shot" },
    { id = "8097518145", name = "Lesgo" },
    { id = "936447863", name = "DC_15X" },
    { id = "8679627751", name = "Neverlose" },
    { id = "8766809464", name = "Minecraft" },
    { id = "8458185621", name = "MinecraftHit2" },
    { id = "8255306220", name = "Teamfortress Bonk" },
    { id = "2868331684", name = "Teamfortress Bell" },
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

local MiscSection2 = Tabs.Misc:AddSection("VIP Tag")

MiscSection2:AddButton({
    Title = "Get VIP Tag",
    Callback = function()
        AddVIPTag()
        AIKO:MakeNotify({
            Title = "Aikoware",
            Description = "VIP Tag",
            Content = "You have received the VIP badge.",
            Delay = 3
        })
    end
})

spawn(function()
    while task.wait() do
        if getgenv().AutoJumpV2 then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    if humanoid:GetState() == Enum.HumanoidStateType.Freefall or humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                        task.wait(0.1)
                    else
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        task.wait(0.3)
                    end
                end
            end
        end
    end
end)

spawn(function()
    while task.wait() do
        if getgenv().PlayerFocusV2 then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char.Parent.Name ~= "Dead" then
                    local closest = GetClosestPlayerV2()
                    if closest and closest:FindFirstChild("Head") then
                        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, closest.Head.Position)
                    end
                end
            end)
        end
    end
end)

ReplicatedStorage.Remotes.InfinityBall.OnClientEvent:Connect(function(a, b)
    InfinityV2 = b and true or false
end)

game:GetService("ReplicatedStorage").Remotes.Phantom.OnClientEvent:Connect(function(a, b)
    if b.Name == tostring(LocalPlayer) then
        PhantomV2 = true
    else
        PhantomV2 = false
    end
end)

workspace.Balls.ChildRemoved:Connect(function()
    ParriesV2 = 0
    ParriedV2 = false
    PhantomV2 = false
end)

ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent:Connect(function()
    if ParriesV2 > 0 then
        ParriesV2 = ParriesV2 - 1
    end
end)

local UtilitySection = Tabs.Misc:AddSection("Utility")

local afkRunning = false
local afkToggle = false

local function startAntiAFK()
    if afkRunning then return end
    afkRunning = true

    task.spawn(function()
        while afkToggle do
            for i = 900, 1, -1 do
                if not afkToggle then break end
                task.wait(1)
            end
            if not afkToggle then break end
            for j = 1, 5 do
                local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                task.wait(0.5)
            end
        end
        afkRunning = false
    end)
end

UtilitySection:AddToggle({
    Title = "Anti AFK",
    Default = false,
    Callback = function(enabled)
        afkToggle = enabled
        getgenv().AntiAFKEnabled = enabled
        if enabled then
            startAntiAFK()
        end
    end
})

local originalMaterials = {}
local originalDecalsTextures = {}

UtilitySection:AddToggle({
    Title = "Anti Lag",
    Default = false,
    Callback = function(enabled)
        getgenv().AntiLagEnabled = enabled
        if enabled then
            for _, O in ipairs(workspace:GetDescendants()) do
                if O:IsA("BasePart") and not (O:FindFirstAncestorWhichIsA("Model") and O:FindFirstAncestorWhichIsA("Model"):FindFirstChild("Humanoid")) then
                    originalMaterials[O] = O.Material
                    O.Material = Enum.Material.SmoothPlastic
                    O.Reflectance = 0
                elseif O:IsA("Decal") or O:IsA("Texture") then
                    table.insert(originalDecalsTextures, {Object = O, Parent = O.Parent})
                    O.Parent = nil
                elseif O:IsA("ParticleEmitter") or O:IsA("Smoke") or O:IsA("Fire") or O:IsA("Sparkles") then
                    O.Enabled = false
                end
            end
            workspace.DescendantAdded:Connect(function(O)
                if getgenv().AntiLagEnabled then
                    task.defer(function()
                        if O:IsA("BasePart") and not (O:FindFirstAncestorWhichIsA("Model") and O:FindFirstAncestorWhichIsA("Model"):FindFirstChild("Humanoid")) then
                            originalMaterials[O] = O.Material
                            O.Material = Enum.Material.SmoothPlastic
                            O.Reflectance = 0
                        elseif O:IsA("Decal") or O:IsA("Texture") then
                            table.insert(originalDecalsTextures, {Object = O, Parent = O.Parent})
                            O.Parent = nil
                        elseif O:IsA("ParticleEmitter") or O:IsA("Smoke") or O:IsA("Fire") or O:IsA("Sparkles") then
                            O.Enabled = false
                        end
                    end)
                end
            end)
        else
            for O, material in pairs(originalMaterials) do
                if O and O:IsA("BasePart") then
                    O.Material = material
                end
            end
            for _, data in pairs(originalDecalsTextures) do
                if data.Object and data.Parent then
                    data.Object.Parent = data.Parent
                end
            end
            originalMaterials = {}
            originalDecalsTextures = {}
        end
    end
})

task.defer(function()
    while task.wait(1) do
        if getgenv().NightModeEnabled then
            game:GetService("TweenService"):Create(game:GetService("Lighting"), TweenInfo.new(3), {ClockTime = 3.9}):Play()
        else
            game:GetService("TweenService"):Create(game:GetService("Lighting"), TweenInfo.new(3), {ClockTime = 13.5}):Play()
        end
    end
end)

local Lighting = game:GetService("Lighting")
local originalFogEnd = Lighting.FogEnd
local originalFogStart = Lighting.FogStart
local originalFogColor = Lighting.FogColor

local function applyFogSettings()
    if getgenv().RemoveFogEnabled then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
    else
        Lighting.FogEnd = originalFogEnd
        Lighting.FogStart = originalFogStart
        Lighting.FogColor = originalFogColor
    end
end

Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
    if getgenv().RemoveFogEnabled and Lighting.FogEnd ~= 100000 then
        Lighting.FogEnd = 100000
    end
end)

Lighting:GetPropertyChangedSignal("FogStart"):Connect(function()
    if getgenv().RemoveFogEnabled and Lighting.FogStart ~= 100000 then
        Lighting.FogStart = 100000
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applyFogSettings()
end)

UtilitySection:AddToggle({
    Title = "Remove Fog",
    Default = false,
    Callback = function(enabled)
        getgenv().RemoveFogEnabled = enabled
        applyFogSettings()
    end
})

local nightModeConnection

task.defer(function()
    while task.wait(0.5) do
        if getgenv().NightModeEnabled then
            local currentTime = Lighting.ClockTime
            if currentTime > 6 and currentTime < 18 then
                Lighting.ClockTime = 3.9
            end
        end
    end
end)

Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
    if getgenv().NightModeEnabled then
        local currentTime = Lighting.ClockTime
        if currentTime > 6 and currentTime < 18 then
            Lighting.ClockTime = 3.9
        end
    end
end)

UtilitySection:AddToggle({
    Title = "Night Mode",
    Default = false,
    Callback = function(enabled)
        getgenv().NightModeEnabled = enabled
        if enabled then
            Lighting.ClockTime = 3.9
        else
            Lighting.ClockTime = 13.5
        end
    end
})

UtilitySection:AddToggle({
    Title = "FPS Unlock",
    Default = true,
    Callback = function(enabled)
        getgenv().FPSUnlockEnabled = enabled
        if enabled then
            setfpscap(999)
        else
            setfpscap(60)
        end
    end
})

UtilitySection:AddSlider({
    Title = "FPS Cap",
    Min = 60,
    Max = 999,
    Default = 999,
    Callback = function(value)
        if getgenv().FPSUnlockEnabled then
            setfpscap(value)
        end
    end
})

local originalName = "AikowareGUI"
local currentName = originalName

UtilitySection:AddToggle({
    Title = "Bypass Limits",
    Default = true,
    Callback = function(enabled)
        getgenv().BypassLimitsEnabled = enabled
    end
})

UtilitySection:AddToggle({
    Title = "Anti Detection",
    Default = true,
    Callback = function(enabled)
        if enabled then
            local target = CoreGui:FindFirstChild(originalName)
            if target then
                local newName = "\\" .. game:GetService("HttpService"):GenerateGUID(false):gsub("-", ""):sub(1, 12)
                target.Name = newName
                currentName = newName
            end
        else
            local target = CoreGui:FindFirstChild(currentName)
            if target then
                target.Name = originalName
                currentName = originalName
            end
        end
    end
})

AIKO:MakeNotify({
    Title = "Aikoware",
    Description = "Script Loaded",
    Content = "Game: Blade Ball",
    Delay = 4
})
