
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

local AIKO = loadstring(game:HttpGet("https://raw.githubusercontent.com/sinchanthestar/kdoaz/refs/heads/main/src/Library.lua"))()

local Window = AIKO:Window({
    Title   = "Aikoware |",
    Footer  = "made by @aoki!",              
    Version = 1,
})

local function notify(title, description, content, delay)
    AIKO:MakeNotify({
        Title = title or "Aikoware",
        Description = description or "",
        Content = content or "",
        Delay = delay or 3
    })
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService"),
    RS = game:GetService("ReplicatedStorage"),
    VIM = game:GetService("VirtualInputManager"),
    TeleportService = game:GetService("TeleportService")
}

local Player = Services.Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local Camera = workspace.CurrentCamera

@@ -70,93 +79,132 @@ local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")
local equipRemote = net:WaitForChild("RE/EquipToolFromHotbar")
local REFavoriteItem = net:WaitForChild("RE/FavoriteItem")
local InitiateTrade = net:WaitForChild("RF/InitiateTrade")
local SellAllItems = net:WaitForChild("RF/SellAllItems")
local REObtainedNewFishNotification = net:WaitForChild("RE/ObtainedNewFishNotification")

local NetFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

local NetIndex = ReplicatedStorage.Packages._Index and ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"]
if NetIndex then
    NetIndex = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
end

local ChargeFishingRod = NetFolder:WaitForChild("RF/ChargeFishingRod")
local RequestFishingMinigame = NetFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local FishingCompleted = NetFolder:WaitForChild("RE/FishingCompleted")
local EquipToolFromHotbar = NetFolder:WaitForChild("RE/EquipToolFromHotbar")
local SellAllItems = NetFolder:WaitForChild("RF/SellAllItems")
local CancelFishingInputs = NetFolder:WaitForChild("RF/CancelFishingInputs")
local ActivateEnchantingAltar = NetFolder:WaitForChild("RE/ActivateEnchantingAltar")
local UpdateOxygen = NetFolder:WaitForChild("URE/UpdateOxygen")
local FishingController = require(ReplicatedStorage.Controllers.FishingController)
local REFavoriteItem = NetFolder:WaitForChild("RE/FavoriteItem")

local function getHotbarSlotIndexByName(pattern)
    local backpackGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("Backpack")
    if not backpackGui then return nil end

    local display = backpackGui:FindFirstChild("Display")
    if not display then return nil end

    for index, child in ipairs(display:GetChildren()) do
        local inner = child:FindFirstChild("Inner")
        local tags = inner and inner:FindFirstChild("Tags")
        local itemName = tags and tags:FindFirstChild("ItemName")

        if itemName and typeof(itemName.Text) == "string" then
            local name = itemName.Text:lower()
            if name:find(pattern:lower()) then
                return index
            end
        end
    end

    return nil
end

local function equipToolByName(pattern)
    local slot = getHotbarSlotIndexByName(pattern)
    if slot then
        pcall(function()
            EquipToolFromHotbar:FireServer(slot)
        end)
        return true
    end
    return false
end

UserInputService.JumpRequest:Connect(function()
    local shouldJump = _G.InfiniteJump and (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
    if shouldJump then
        shouldJump:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local Replion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Replion"))
local Data = Replion.Client:WaitReplion("Data", LocalPlayer)

local lockPositionState = {
    enabled = false,
    position = nil
}

local playerAddedConnection
local characterConnections = {}

local Home = Window:AddTab({
    Name = "Home",
    Icon = "info"
})

local Fishing = Window:AddTab({
    Name = "Fishing",
    Icon = "rbxassetid://100067447000453"
})

local Shop = Window:AddTab({
    Name = "Shop",
    Icon = "piggy-bank"
})

local Favo = Window:AddTab({
    Name = "Auto Favorite",
    Icon = "heart"
})

local Teleport = Window:AddTab({
    Name = "Teleport",
    Icon = "map-pin"
})

local Boat = Window:AddTab({
    Name = "Boat",
    Icon = "ship"
})

local Trade = Window:AddTab({
    Name = "Trade",
    Icon = "repeat"
})

local Webhook = Window:AddTab({
    Name = "Webhook",
    Icon = "rbxassetid://137601480983962"
})

local Misc = Window:AddTab({
    Name = "Misc",
    Icon = "snowflake"
})

local dcsec = Home:AddSection("Support", true)

dcsec:AddParagraph({
    Title = "Discord",
    Content = "Join our discord for more information.",
    Icon = "discord",
    ButtonText = "Copy Server Link",
    ButtonCallback = function()
        local link = "https://discord.gg/JccfFGpDNV"
        if setclipboard then
@@ -212,50 +260,53 @@ local autoRECON = srv:AddToggle({
    end
})

function RejoinServer()
    local TeleportService = game:GetService("TeleportService")
    local Player = game:GetService("Players").LocalPlayer
    TeleportService:Teleport(game.PlaceId, Player)
end

srv:AddButton({
    Title = "Rejoin Server",
    Content = "Teleport back to the same game",
    Callback = function()
        task.wait(0.5)
        local TeleportService = game:GetService("TeleportService")
        local Player = game:GetService("Players").LocalPlayer
        TeleportService:Teleport(game.PlaceId, Player)
    end
})

local fsh = Fishing:AddSection("Legit (Auto Perfect)")

local MouseReleaseCallback = nil
local LegitShakeDelay = 0.05
local DefaultLegitDelay = 0.1
local LegitCastDelay = 0.2
local LegitWaitDelay = 0.2
local AutoEquipRodEnabled = false

_G.FishMiniData = _G.FishMiniData or {}

local InputControl = require(ReplicatedStorage.Modules.InputControl)
local OldRegisterMouseReleased = InputControl.RegisterMouseReleased

function InputControl.RegisterMouseReleased(self, param2, callback)
    MouseReleaseCallback = callback
    return OldRegisterMouseReleased(self, param2, callback)
end

function castWithBarRelease()
    local PlayerGui = LocalPlayer.PlayerGui
    local Camera = workspace.CurrentCamera
    local CenterPosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    pcall(function()
        CancelFishingInputs:InvokeServer()
    end)

    pcall(function()
        FishingController:RequestChargeFishingRod(CenterPosition, false)
    end)

    local ChargeBar = PlayerGui:WaitForChild("Charge"):WaitForChild("Main"):WaitForChild("CanvasGroup"):WaitForChild("Bar")
@@ -274,59 +325,65 @@ function castWithBarRelease()
    end

    if MouseReleaseCallback then
        pcall(MouseReleaseCallback)
    end
end

function StartLegitFishing(enabled)
    FishingController._autoLoop = enabled
    FishingController._autoShake = enabled

    if enabled then
        task.spawn(function()
            pcall(function()
                EquipToolFromHotbar:FireServer(1)
            end)
            task.wait(0.5)
        end)

        task.spawn(function()
            local UserId = tostring(LocalPlayer.UserId)
            local CosmeticFolder = workspace:WaitForChild("CosmeticFolder")

            while FishingController._autoLoop do
                if not CosmeticFolder:FindFirstChild(UserId) then
                    if AutoEquipRodEnabled then
                        pcall(function()
                            EquipToolFromHotbar:FireServer(1)
                        end)
                    end
                    task.wait(LegitCastDelay)
                    castWithBarRelease()
                    task.wait(0.2)
                    task.wait(LegitWaitDelay)
                end

                while CosmeticFolder:FindFirstChild(UserId) and FishingController._autoLoop do
                    task.wait(0.2)
                    task.wait(LegitWaitDelay)
                end

                task.wait(0.2)
                task.wait(LegitWaitDelay)
            end
        end)

        local ClickEffect = LocalPlayer.PlayerGui:FindFirstChild("!!! Click Effect")
        if ClickEffect then
            ClickEffect.Enabled = false
        end

        task.spawn(function()
            while FishingController._autoShake do
                pcall(function()
                    FishingController:RequestFishingMinigameClick()
                end)
                task.wait(LegitShakeDelay)
            end
        end)
    else
        local ClickEffect = LocalPlayer.PlayerGui:FindFirstChild("!!! Click Effect")
        if ClickEffect then
            ClickEffect.Enabled = true
        end
    end
end

fsh:AddToggle({
@@ -335,100 +392,172 @@ fsh:AddToggle({
    Default = false,
    Callback = function(enabled)
        if enabled then
            task.spawn(function()
                pcall(function()
                    EquipToolFromHotbar:FireServer(1)
                end)
                task.wait(0.3)
                StartLegitFishing(enabled)
            end)
        else
            StartLegitFishing(enabled)
        end

        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local fishingGui = playerGui:WaitForChild("Fishing"):WaitForChild("Main")

        if enabled then
            fishingGui.Visible = false
        else
            fishingGui.Visible = true
        end
    end
})

fsh:AddInput({
    Title = "Cast Delay",
    Placeholder = "0.2",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0 then
            LegitCastDelay = num
        end
    end
})

fsh:AddInput({
    Title = "Wait Delay",
    Placeholder = "0.2",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0 then
            LegitWaitDelay = num
        end
    end
})

fsh:AddToggle({
    Title = "Auto Equip Rod",
    Content = "",
    Default = false,
    Callback = function(enabled)
        AutoEquipRodEnabled = enabled
        if enabled then
            equipToolByName("rod")
        end
    end
})

fsh:AddToggle({
    Title = "Fishing Panel",
    Content = "Show/Hide fishing UI.",
    Default = true,
    Callback = function(enabled)
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        local fishingGui = playerGui and playerGui:FindFirstChild("Fishing")
        if fishingGui and fishingGui:FindFirstChild("Main") then
            fishingGui.Main.Visible = enabled
        end
    end
})

fsh:AddToggle({
    Title = "Remove Fishing Animations",
    Content = "",
    Default = false,
    Callback = function(state)
        setGameAnimationsEnabled(state)
    end
})

fsh:AddButton({
    Title = "Manual Fix Stuck",
    Content = "",
    Callback = function()
        StartLegitFishing(false)

        AIKO:MakeNotify({
            Title = "Aikoware",
            Description = "| Manual Fix Stuck",
            Content = "Stuck Fixed",
            Delay = 2
        })
    end
})

fsh:AddButton({
    Title = "Fix Rod",
    Content = "Cancel inputs and re-equip rod.",
    Callback = function()
        pcall(function()
            CancelFishingInputs:InvokeServer()
        end)
        task.wait(0.2)
        equipToolByName("rod")
        notify("Aikoware", "| Fix Rod", "Rod refreshed", 2)
    end
})

local fin = Fishing:AddSection("Instant")

local InstantFishEnabled = false
local InstantDelayComplete = 0.1
_G.FishMiniData = _G.FishMiniData or {}

local MiniEvent = net:WaitForChild("RE/FishingMinigameChanged")
if MiniEvent then
    if _G._MiniEventConn then
        _G._MiniEventConn:Disconnect()
    end

    _G._MiniEventConn = MiniEvent.OnClientEvent:Connect(function(param1, param2)
        if param1 and param2 then
            _G.FishMiniData = param2
        end
    end)
end

local function StartInstantFishing(enabled)
    InstantFishEnabled = enabled

    if enabled then
        task.spawn(function()
            pcall(function()
                EquipToolFromHotbar:FireServer(1)
            end)
            task.wait(0.5)
        end)

        task.spawn(function()
            task.wait(0.5)

            while InstantFishEnabled do
                pcall(function()
                    if AutoEquipRodEnabled then
                        EquipToolFromHotbar:FireServer(1)
                    end
                    local success, _, rodGUID = pcall(function()
                        return ChargeFishingRod:InvokeServer(workspace:GetServerTimeNow())
                    end)

                    if success and typeof(rodGUID) == "number" then
                        local ProgressValue = -1
                        local SuccessRate = 0.999

                        task.wait(0.3)

                        pcall(function()
                            RequestFishingMinigame:InvokeServer(ProgressValue, SuccessRate, rodGUID)
                        end)

                        local WaitStart = tick()
                        repeat
                            task.wait()
                        until _G.FishMiniData and _G.FishMiniData.LastShift or tick() - WaitStart > 1

                        task.wait(InstantDelayComplete)

                        pcall(function()
                            FishingCompleted:FireServer()
                        end)

@@ -464,89 +593,101 @@ fin:AddToggle({
                EquipToolFromHotbar:FireServer(1)
            end)
            task.wait(0.5)
            StartInstantFishing(true)
        else
            StartInstantFishing(false)
        end
    end
})

fin:AddInput({
    Title = "Complete Delay",
    Placeholder = "0.1",
    Callback = function(value)
        local delay = tonumber(value)
        if delay and delay >= 0 then
            InstantDelayComplete = delay
        end
    end
})

local bts = Fishing:AddSection("Blatant")

_G.FishingDelay = _G.FishingDelay or 1.1
_G.Reel = _G.Reel or 1.9
_G.ResetDelay = _G.ResetDelay or 0.2
_G.FBlatant = _G.FBlatant or false

function FastestFishing()
    task.spawn(function()
        pcall(function()
            CancelFishingInputs:InvokeServer()
        end)

        local serverTime = workspace:GetServerTimeNow()

        pcall(function()
            ChargeFishingRod:InvokeServer(serverTime)
        end)

        pcall(function()
            RequestFishingMinigame:InvokeServer(-1, 0.999)
        end)

        task.wait(_G.FishingDelay)

        pcall(function()
            FishingCompleted:FireServer()
        end)

        task.wait(_G.ResetDelay)

        pcall(function()
            CancelFishingInputs:InvokeServer()
        end)
    end)
end

function StartBlatantFishing()
    _G.FBlatant = true

    pcall(function()
        EquipToolFromHotbar:FireServer(1)
    end)

    LocalPlayer:SetAttribute("Loading", nil)

    task.spawn(function()
        task.wait(0.5) -- Wait for rod to equip

        while _G.FBlatant do
            if AutoEquipRodEnabled then
                pcall(function()
                    EquipToolFromHotbar:FireServer(1)
                end)
            end
            FastestFishing()
            task.wait(_G.Reel)
        end
    end)
end

function StopBlatantFishing()
    _G.FBlatant = false
    LocalPlayer:SetAttribute("Loading", false)
end

function RecoveryFishing()
    task.spawn(function()
        pcall(function()
            CancelFishingInputs:InvokeServer()
        end)

        LocalPlayer:SetAttribute("Loading", nil)
        task.wait(0.05)
        LocalPlayer:SetAttribute("Loading", false)
    end)
end

function SetFishingDelay(delay)
    local num = tonumber(delay)
@@ -569,50 +710,61 @@ bts:AddToggle({
    Callback = function(enabled)
        if enabled then
            StartBlatantFishing()
        else
            StopBlatantFishing()
        end
    end
})

bts:AddInput({
    Title = "Fishing Delay",
    Placeholder = "1.1",
    Callback = function(value)
        SetFishingDelay(value)
    end
})

bts:AddInput({
    Title = "Reel Delay",
    Placeholder = "1.9",
    Callback = function(value)
        SetReelDelay(value)
    end
})

bts:AddInput({
    Title = "Reset Delay",
    Placeholder = "0.2",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0 then
            _G.ResetDelay = num
        end
    end
})

bts:AddButton({
    Title = "Manual Fix Stuck",
    Callback = function()
        RecoveryFishing()
        AIKO:MakeNotify({
            Title = "Aikoware",
            Description = "| Manual Fix",
            Content = "Stuck Fixed",
            Delay = 2
        })
    end
})

local blatv2 = Fishing:AddSection("Blatant V2")

local BlatantV2 = {}
BlatantV2.Active = false
BlatantV2.Settings = {
    ChargeDelay = 0.007,
    CompleteDelay = 0.001,
    CancelDelay = 0.001
}

-- Blatant V2 Remote References
local RE_EquipToolFromHotbar = GetRemote("RE/EquipToolFromHotbar")
local RF_ChargeFishingRod = GetRemote("RF/ChargeFishingRod")
local RF_RequestFishingMinigameStarted = GetRemote("RF/RequestFishingMinigameStarted")
local RE_FishingCompleted = GetRemote("RF/CatchFishCompleted")
local RF_CancelFishingInputs = GetRemote("RF/CancelFishingInputs")
local RF_UpdateAutoFishingState = GetRemote("RF/UpdateAutoFishingState")

-- Blatant V2 Functions
local function StartBlatantV2Fishing()
    task.spawn(function()
        pcall(function()
            RF_CancelFishingInputs:InvokeServer()
        end)

        task.wait(BlatantV2.Settings.ChargeDelay)

        local serverTime = workspace:GetServerTimeNow()
        pcall(function()
            RF_ChargeFishingRod:InvokeServer(serverTime)
        end)

        pcall(function()
            RF_RequestFishingMinigameStarted:InvokeServer(-1, 0.999)
        end)

        task.wait(BlatantV2.Settings.CompleteDelay)

        pcall(function()
            RE_FishingCompleted:FireServer()
        end)

        task.wait(BlatantV2.Settings.CancelDelay)

        pcall(function()
            RF_CancelFishingInputs:InvokeServer()
        end)
    end)
end

local function ToggleBlatantV2(enabled)
    BlatantV2.Active = enabled

    if enabled then
        pcall(function()
            RE_EquipToolFromHotbar:FireServer(1)
        end)

        task.spawn(function()
            task.wait(0.5)
            while BlatantV2.Active do
                if AutoEquipRodEnabled then
                    pcall(function()
                        RE_EquipToolFromHotbar:FireServer(1)
                    end)
                end

                if RF_UpdateAutoFishingState then
                    pcall(function()
                        RF_UpdateAutoFishingState:InvokeServer(true)
                    end)
                end

                StartBlatantV2Fishing()
                task.wait(1.5)
            end

            if RF_UpdateAutoFishingState then
                pcall(function()
                    RF_UpdateAutoFishingState:InvokeServer(false)
                end)
            end
        end)
    end
end

-- Blatant V2 UI Controls
blatv2:AddToggle({
    Title = "Enable Blatant V2",
    Content = "Ultra-fast fishing using new remotes",
    Default = false,
    Callback = function(enabled)
        ToggleBlatantV2(enabled)
    end
})

blatv2:AddInput({
    Title = "Charge Delay",
    Placeholder = "0.007",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0 then
            BlatantV2.Settings.ChargeDelay = num
        end
    end
})

blatv2:AddInput({
    Title = "Complete Delay",
    Placeholder = "0.001",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0 then
            BlatantV2.Settings.CompleteDelay = num
        end
    end
})

blatv2:AddInput({
    Title = "Cancel Delay",
    Placeholder = "0.001",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0 then
            BlatantV2.Settings.CancelDelay = num
        end
    end
})

blatv2:AddButton({
    Title = "Manual Stop",
    Content = "Stop Blatant V2 fishing",
    Callback = function()
        ToggleBlatantV2(false)
        pcall(function()
            RF_CancelFishingInputs:InvokeServer()
        end)
        notify("Aikoware", "| Blatant V2", "Fishing stopped", 2)
    end
})

@@ -732,50 +884,104 @@ ench:AddToggle({
            task.wait(3)

            local slot5 = LocalPlayer.PlayerGui.Backpack.Display:GetChildren()[10]
            local itemName = slot5 and slot5:FindFirstChild("Inner") and slot5.Inner:FindFirstChild("Tags") and slot5.Inner.Tags:FindFirstChild("ItemName")

            if itemName and itemName.Text:lower():find("enchant") then
                local originalPosition = hrp.Position
                task.wait(1)
                hrp.CFrame = CFrame.new(enchantPosition + Vector3.new(0, 5, 0))
                task.wait(1.2)

                pcall(function()
                    EquipToolFromHotbar:FireServer(5)
                    task.wait(0.5)
                    ActivateEnchantingAltar:FireServer()
                    task.wait(7)
                end)

                task.wait(0.9)
                hrp.CFrame = CFrame.new(originalPosition + Vector3.new(0, 3, 0))
            end
        end
    end
})

local doubleEnchant = Fishing:AddSection("Double Enchant")

local doubleEnchantEnabled = false

local function runDoubleEnchant()
    local rodSlot = getHotbarSlotIndexByName("rod")
    if not rodSlot then
        notify("Aikoware", "| Double Enchant", "Rod not found", 2)
        return
    end

    for _ = 1, 2 do
        pcall(function()
            EquipToolFromHotbar:FireServer(rodSlot)
        end)
        task.wait(0.5)
        pcall(function()
            ActivateEnchantingAltar:FireServer()
        end)
        task.wait(1)
    end
end

doubleEnchant:AddToggle({
    Title = "Enable Double Enchant",
    Content = "",
    Default = false,
    Callback = function(enabled)
        doubleEnchantEnabled = enabled
    end
})

doubleEnchant:AddButton({
    Title = "Get Enchant Stones",
    Content = "Auto equip enchant stones if available.",
    Callback = function()
        if not equipToolByName("enchant") then
            notify("Aikoware", "| Enchant", "Enchant stone not found", 2)
        end
    end
})

doubleEnchant:AddButton({
    Title = "Double Enchant Rod",
    Content = "",
    Callback = function()
        if doubleEnchantEnabled then
            runDoubleEnchant()
        else
            notify("Aikoware", "| Double Enchant", "Enable the toggle first", 2)
        end
    end
})

local ntf = Fishing:AddSection("Auto Fish Misc")

local function ToggleCaughtNotifications(visible)
    local notificationGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Small Notification")
    if notificationGui then
        local display = notificationGui:FindFirstChild("Display")
        if display then
            for _, child in ipairs(display:GetChildren()) do
                if child:IsA("GuiObject") then
                    child.Visible = visible
                end
            end
        end
    end
end

local noNOTIF = ntf:AddToggle({
    Title = "Disable Fish Notification",
    Content = "",
    Default = false,
    Callback = function(enabled)
        ToggleCaughtNotifications(not enabled)
    end
})

@@ -797,87 +1003,197 @@ local function setGameAnimationsEnabled(state)
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0) end)
            end

            local conn = animator.AnimationPlayed:Connect(function(track)
                task.defer(function()
                    pcall(function() track:Stop(0) end)
                end)
            end)
            table.insert(stopAnimConnections, conn)
        end
    end
end

local noANIMS = ntf:AddToggle({
    Title = "Disable Animations",
    Content = "",
    Default = false,
    Callback = function(state)
        setGameAnimationsEnabled(state)
    end
})

local originalCFrame = nil
local freezeConnection = nil
local safeZoneConnection = nil
local safeZonePart = nil
local safeZoneHeight = 10
local safeZoneEnabled = false
local walkOnWaterConnection = nil
local walkOnWaterPart = nil
local walkOnWaterEnabled = false

local freezeCHAR = ntf:AddToggle({
    Title = "Freeze Character",
    Content = "",
    Default = false,
    Callback = function(enabled)
        _G.FreezeCharacter = enabled

        if enabled then
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")

            if hrp then
                originalCFrame = hrp.CFrame

                if freezeConnection then
                    freezeConnection:Disconnect()
                    freezeConnection = nil
                end

                freezeConnection = RunService.Heartbeat:Connect(function()
                    if _G.FreezeCharacter and hrp and hrp.Parent then
                        hrp.CFrame = originalCFrame
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end
                end)
            end
        else
            if freezeConnection then
                freezeConnection:Disconnect()
                freezeConnection = nil
            end
        end
    end
})

local safety = Misc:AddSection("Safety Zone")

local function updateSafeZone()
    if not safeZoneEnabled then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not safeZonePart then
        safeZonePart = Instance.new("Part")
        safeZonePart.Name = "Aikoware_SafeZone"
        safeZonePart.Anchored = true
        safeZonePart.CanCollide = true
        safeZonePart.Transparency = 0.5
        safeZonePart.Material = Enum.Material.ForceField
        safeZonePart.Color = Color3.fromRGB(60, 170, 255)
        safeZonePart.Parent = Workspace
    end

    safeZonePart.Size = Vector3.new(18, safeZoneHeight, 18)
    safeZonePart.CFrame = hrp.CFrame + Vector3.new(0, (safeZoneHeight / 2) - 2, 0)
end

safety:AddToggle({
    Title = "Create Safe Zone",
    Content = "",
    Default = false,
    Callback = function(enabled)
        safeZoneEnabled = enabled
        if enabled then
            if safeZoneConnection then
                safeZoneConnection:Disconnect()
            end
            safeZoneConnection = RunService.Heartbeat:Connect(updateSafeZone)
            updateSafeZone()
        else
            if safeZoneConnection then
                safeZoneConnection:Disconnect()
                safeZoneConnection = nil
            end
            if safeZonePart then
                safeZonePart:Destroy()
                safeZonePart = nil
            end
        end
    end
})

safety:AddInput({
    Title = "Safe Zone Height",
    Placeholder = "10",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            safeZoneHeight = num
            updateSafeZone()
        end
    end
})

local function updateWalkOnWater()
    if not walkOnWaterEnabled then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not walkOnWaterPart then
        walkOnWaterPart = Instance.new("Part")
        walkOnWaterPart.Name = "Aikoware_WaterWalk"
        walkOnWaterPart.Size = Vector3.new(15, 1, 15)
        walkOnWaterPart.Anchored = true
        walkOnWaterPart.CanCollide = true
        walkOnWaterPart.Transparency = 1
        walkOnWaterPart.Parent = Workspace
    end

    local waterLevel = -1.8
    walkOnWaterPart.Position = Vector3.new(hrp.Position.X, waterLevel, hrp.Position.Z)
end

safety:AddToggle({
    Title = "Walk On Water",
    Content = "",
    Default = false,
    Callback = function(enabled)
        walkOnWaterEnabled = enabled
        if enabled then
            if walkOnWaterConnection then
                walkOnWaterConnection:Disconnect()
            end
            walkOnWaterConnection = RunService.Heartbeat:Connect(updateWalkOnWater)
            updateWalkOnWater()
        else
            if walkOnWaterConnection then
                walkOnWaterConnection:Disconnect()
                walkOnWaterConnection = nil
            end
            if walkOnWaterPart then
                walkOnWaterPart:Destroy()
                walkOnWaterPart = nil
            end
        end
    end
})

local rds = Shop:AddSection("Rod Shop")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RFPurchaseFishingRod = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseFishingRod"]

local rods = {
    ["Luck Rod"] = 79,
    ["Carbon Rod"] = 76,
    ["Grass Rod"] = 85,
    ["Demascus Rod"] = 77,
    ["Ice Rod"] = 78,
    ["Lucky Rod"] = 4,
    ["Midnight Rod"] = 80,
    ["Steampunk Rod"] = 6,
    ["Chrome Rod"] = 7,
    ["Astral Rod"] = 5,
    ["Ares Rod"] = 126,
    ["Angler Rod"] = 168
}

local rodNames = {
    "Luck Rod", "Carbon Rod", "Grass Rod", "Demascus Rod",
    "Ice Rod", "Lucky Rod", "Midnight Rod", "Steampunk Rod",
    "Chrome Rod", "Astral Rod", "Ares Rod", "Angler Rod"
}
@@ -931,50 +1247,64 @@ rds:AddButton({
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Rod Purchase", 
                    Content = "Purchased " .. selectedRod, 
                    Delay = 3
                })
            else
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Rod Purchase Error", 
                    Content = tostring(err), 
                    Delay = 5
                })
            end
        else
                AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "| Error", 
                Content = "Invalid rod selection", 
                Delay = 3
            })
        end
    end
})

rds:AddButton({
    Title = "Buy All Rods",
    Content = "",
    Callback = function()
        for name, rodId in pairs(rods) do
            pcall(function()
                RFPurchaseFishingRod:InvokeServer(rodId)
            end)
            task.wait(0.2)
            notify("Aikoware", "| Rod Purchase", "Purchased " .. name, 2)
        end
    end
})

local bs = Shop:AddSection("Bait Shop")

local RFPurchaseBait = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseBait"]

local baits = {
    ["TopWater Bait"] = 10,
    ["Lucky Bait"] = 2,
    ["Midnight Bait"] = 3,
    ["Chroma Bait"] = 6,
    ["Dark Mater Bait"] = 8,
    ["Corrupt Bait"] = 15,
    ["Aether Bait"] = 16
}

local baitNames = {
    "TopWater Bait",
    "Lucky Bait",
    "Midnight Bait",
    "Chroma Bait",
    "Dark Mater Bait",
    "Corrupt Bait",
    "Aether Bait"
}

local baitKeyMap = {
@@ -1021,50 +1351,64 @@ bs:AddButton({
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Bait Purchase",
                    Content = "Purchased " .. selectedBait,
                    Delay = 3
                })
            else
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Bait Purchase Error",
                    Content = tostring(err),
                    Delay = 5
                })
            end
        else
                AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "| Error",
                Content = "Invalid bait selection",
                Delay = 3
            })
        end
    end
})

bs:AddButton({
    Title = "Buy All Baits",
    Content = "",
    Callback = function()
        for name, baitId in pairs(baits) do
            pcall(function()
                RFPurchaseBait:InvokeServer(baitId)
            end)
            task.wait(0.2)
            notify("Aikoware", "| Bait Purchase", "Purchased " .. name, 2)
        end
    end
})

local bos = Shop:AddSection("Boat Shop")

local RFPurchaseBoat = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseBoat"]

local boatOrder = {
    "Small Boat",
    "Kayak",
    "Jetski",
    "Highfield",
    "Speed Boat",
    "Fishing Boat",
    "Mini Yacht",
    "Hyper Boat",
    "Frozen Boat",
    "Cruiser Boat"
}

local boats = {
    ["Small Boat"] = {Id = 1, Price = 300},
    ["Kayak"] = {Id = 2, Price = 1100},
    ["Jetski"] = {Id = 3, Price = 7500},
    ["Highfield"] = {Id = 4, Price = 25000},
    ["Speed Boat"] = {Id = 5, Price = 70000},
    ["Fishing Boat"] = {Id = 6, Price = 180000},
    ["Mini Yacht"] = {Id = 14, Price = 1200000},
@@ -1127,50 +1471,162 @@ bos:AddButton({
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Boat Purchase",
                    Content = "Purchased " .. selectedBoat,
                    Delay = 3
                })
            else
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Boat Purchase Error",
                    Content = tostring(err),
                    Delay = 5
                })
            end
        else
                AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "| Error",
                Content = "Invalid boat selection",
                Delay = 3
            })
        end
    end
})

bos:AddButton({
    Title = "Buy All Boats",
    Content = "",
    Callback = function()
        for name, data in pairs(boats) do
            pcall(function()
                RFPurchaseBoat:InvokeServer(data.Id)
            end)
            task.wait(0.2)
            notify("Aikoware", "| Boat Purchase", "Purchased " .. name, 2)
        end
    end
})

local boatControls = Boat:AddSection("Boat Controls")
local boatManagement = Boat:AddSection("Boat Management")

local boatSpeedValue = 50
local spawnBoatRemote = NetFolder:FindFirstChild("RF/SpawnBoat") or net:FindFirstChild("RF/SpawnBoat")
local despawnBoatRemote = NetFolder:FindFirstChild("RF/DespawnBoat") or net:FindFirstChild("RF/DespawnBoat")

local function getVehicleSeat()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local seatPart = humanoid and humanoid.SeatPart
    if seatPart and seatPart:IsA("VehicleSeat") then
        return seatPart
    end
    return nil
end

local function setBoatSpeed(speed)
    local seat = getVehicleSeat()
    if seat then
        if seat.MaxSpeed ~= nil then
            seat.MaxSpeed = speed
        elseif seat.Torque ~= nil then
            seat.Torque = speed
        end
        notify("Aikoware", "| Boat Speed", "Speed set to " .. tostring(speed), 2)
    else
        notify("Aikoware", "| Boat Speed", "You are not seated on a boat", 2)
    end
end

boatControls:AddSlider({
    Title = "Set Boat Speed",
    Content = "",
    Min = 0,
    Max = 1000,
    Default = boatSpeedValue,
    Callback = function(value)
        boatSpeedValue = value
        setBoatSpeed(value)
    end
})

boatControls:AddButton({
    Title = "Reset Boat Speed",
    Content = "",
    Callback = function()
        boatSpeedValue = 50
        setBoatSpeed(boatSpeedValue)
    end
})

boatManagement:AddDropdown({
    Title = "Select Boat To Spawn",
    Content = "",
    Options = boatNames,
    Default = boatNames[1],
    Multi = false,
    Callback = function(value)
        if type(value) == "table" then
            selectedBoat = value[1] or boatNames[1]
        else
            selectedBoat = value
        end
    end
})

boatManagement:AddButton({
    Title = "Spawn Selected Boat",
    Content = "",
    Callback = function()
        local key = boatKeyMap[selectedBoat]
        if key and boats[key] and spawnBoatRemote then
            pcall(function()
                spawnBoatRemote:InvokeServer(boats[key].Id)
            end)
            notify("Aikoware", "| Boat", "Spawned " .. key, 2)
        else
            notify("Aikoware", "| Boat", "Spawn remote not found", 2)
        end
    end
})

boatManagement:AddButton({
    Title = "Despawn Boat",
    Content = "",
    Callback = function()
        if despawnBoatRemote then
            pcall(function()
                despawnBoatRemote:InvokeServer()
            end)
            notify("Aikoware", "| Boat", "Despawned boat", 2)
        else
            notify("Aikoware", "| Boat", "Despawn remote not found", 2)
        end
    end
})

local ws = Shop:AddSection("Weather Shop")

local RFPurchaseWeatherEvent = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseWeatherEvent"]

local weathers = {
    ["Wind"] = "Wind",
    ["Snow"] = "Snow",
    ["Cloudy"] = "Cloudy",
    ["Storm"] = "Storm",
    ["Radiant"] = "Radiant",
    ["Shark Hunt"] = "Shark Hunt"
}

local weatherNames = {
    "Wind", "Snow", "Cloudy", "Storm",
    "Radiant", "Shark Hunt"
}

local weatherKeyMap = {
    ["Wind"] = "Wind",
    ["Snow"] = "Snow",
    ["Cloudy"] = "Cloudy",
    ["Storm"] = "Storm",
    ["Radiant"] = "Radiant",
    ["Shark Hunt"] = "Shark Hunt"
@@ -1261,50 +1717,64 @@ ws:AddButton({
            if key and weathers[key] then
                local success, err = pcall(function()
                    RFPurchaseWeatherEvent:InvokeServer(key)
                end)
                if success then
                    AIKO:MakeNotify({
                        Title = "Aikoware",
                        Description = "| Weather Purchase",
                        Content = "Purchased " .. displayName,
                        Delay = 2
                    })
                else
                    AIKO:MakeNotify({
                        Title = "Aikoware",
                        Description = "| Purchase Error",
                        Content = tostring(err),
                        Delay = 3
                    })
                end
                task.wait(0.5)
            end
        end
    end
})

ws:AddButton({
    Title = "Buy All Weathers",
    Content = "",
    Callback = function()
        for _, name in ipairs(weatherNames) do
            pcall(function()
                RFPurchaseWeatherEvent:InvokeServer(name)
            end)
            task.wait(0.2)
            notify("Aikoware", "| Weather Purchase", "Purchased " .. name, 2)
        end
    end
})

local merch = Shop:AddSection("Merchant")

local MerchantUI = {
    Main = PlayerGui.Merchant,
    ItemsFrame = PlayerGui.Merchant.Main.Background.Items.ScrollingFrame,
    RefreshLabel = PlayerGui.Merchant.Main.Background.RefreshLabel
}

ShopParagraph = merch:AddParagraph({
    Title = "Merchant Stock:",
    Icon = "shop",
    Content = "Loading..."
})

merch:AddButton({
    Title = "Toggle Merchant UI",
    Callback = function()
        local merchant = PlayerGui:FindFirstChild("Merchant")
        if merchant then
            merchant.Enabled = not merchant.Enabled
        end
    end
})

function UPX()
@@ -1317,130 +1787,225 @@ function UPX()
                local itemName = frame.ItemName.Text
                if not string.find(itemName, "Mystery") then
                    table.insert(items, "- " .. itemName)
                end
            end
        end
    end
    
    if #items > 0 then
        ShopParagraph:SetContent(table.concat(items, "<br/>") .. "<br/><br/>" .. MerchantUI.RefreshLabel.Text)
    else
        ShopParagraph:SetContent("No items found\n" .. MerchantUI.RefreshLabel.Text)
    end
end

task.spawn(function()
    while task.wait(1) do
        pcall(UPX)
    end
end)

local sell = Shop:AddSection("Sell")

local sellThreshold = 30
local autoSellEnabled = false
local sellInterval = 60
local autoSellTimerEnabled = false

local sellDELAY = sell:AddInput({
    Title = "Auto Sell Delay",
    Content = "",
    Placeholder = "30",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            sellThreshold = num
        end
    end
})

sell:AddInput({
    Title = "Sell Interval (Seconds)",
    Content = "",
    Placeholder = "60",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            sellInterval = num
        end
    end
})

local autoSELL = sell:AddToggle({
    Title = "Auto Sell",
    Content = "Sell when threshold reached.",
    Default = false,
    Callback = function(state)
        autoSellEnabled = state

        if state then
            task.spawn(function()
                while autoSellEnabled do
                    task.wait(5)

                    local Replion = require(ReplicatedStorage.Packages.Replion)
                    local Data = Replion.Client:WaitReplion("Data")
                    local inventoryData = Data:Get("Inventory")

                    if inventoryData and inventoryData.Items then
                        local count = 0
                        for _ in pairs(inventoryData.Items) do
                            count = count + 1
                        end

                        if count >= sellThreshold then
                            SellAllItems:InvokeServer()
                        end
                    end
                end
            end)
        end
    end
})

sell:AddToggle({
    Title = "Auto Sell Timer",
    Content = "Sell all fish on interval.",
    Default = false,
    Callback = function(state)
        autoSellTimerEnabled = state
        if state then
            task.spawn(function()
                while autoSellTimerEnabled do
                    task.wait(sellInterval)
                    pcall(function()
                        SellAllItems:InvokeServer()
                    end)
                end
            end)
        end
    end
})

sell:AddButton({
    Title = "Sell All Fish",
    Content = "Instanly sells non-favorite fish.",
    Callback = function()
        local RFSellAllItems = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]

        pcall(function()
            RFSellAllItems:InvokeServer()
        end)

    end
})

_G.AutoFavoriteRarities = _G.AutoFavoriteRarities or {}

local fav = Favo:AddSection("Auto Favorite")

local GlobalFav = {
    REObtainedNewFishNotification = net:WaitForChild("RE/ObtainedNewFishNotification"),
    REFavoriteItem = net:WaitForChild("RE/FavoriteItem"),

    FishIdToName = {},
    FishNameToId = {},
    FishIdToTier = {},
    FishNames = {},
    Variants = {},
    VariantIdToName = {},
    VariantNameToId = {},

    SelectedFishIds = {},
    SelectedVariants = {},
    SelectedRarities = {},
    AutoFavoriteEnabled = false
}

local function getInventoryItems()
    local inventoryData = Data and Data:Get("Inventory")
    if inventoryData and inventoryData.Items then
        return inventoryData.Items
    end
    return {}
end

local function isItemFavorited(item)
    if item == nil then
        return false
    end
    if item.IsFavorite ~= nil then
        return item.IsFavorite
    end
    if item.Favorite ~= nil then
        return item.Favorite
    end
    if item.Metadata and item.Metadata.Favorite ~= nil then
        return item.Metadata.Favorite
    end
    return false
end

local function toggleFavorite(uuid)
    pcall(function()
        GlobalFav.REFavoriteItem:FireServer(uuid)
    end)
end

local function unfavoriteByRarities(rarities)
    local items = getInventoryItems()
    local count = 0

    for _, item in pairs(items) do
        local itemId = item.ItemId or item.Id or item.ItemID
        local uuid = item.UUID or (item.InventoryItem and item.InventoryItem.UUID)
        local tierName = GetTierName(GlobalFav.FishIdToTier[itemId])
        if uuid and rarities[tierName] and isItemFavorited(item) then
            toggleFavorite(uuid)
            count = count + 1
        end
    end

    return count
end

local function unfavoriteAll()
    local items = getInventoryItems()
    local count = 0

    for _, item in pairs(items) do
        local uuid = item.UUID or (item.InventoryItem and item.InventoryItem.UUID)
        if uuid and isItemFavorited(item) then
            toggleFavorite(uuid)
            count = count + 1
        end
    end

    return count
end

for _, item in pairs(ReplicatedStorage.Items:GetChildren()) do
    local ok, data = pcall(require, item)
    if ok and data.Data and data.Data.Type == "Fish" then
        local id = data.Data.Id
        local name = data.Data.Name
        local tier = data.Data.Tier
        GlobalFav.FishIdToName[id] = name
        GlobalFav.FishNameToId[name] = id
        GlobalFav.FishIdToTier[id] = tier
        table.insert(GlobalFav.FishNames, name)
    end
end

for _, variantModule in pairs(ReplicatedStorage.Variants:GetChildren()) do
    local ok, variantData = pcall(require, variantModule)
    if ok and variantData.Data then
        local id = variantData.Data.Id
        local name = variantData.Data.Name
        if id and name then
            GlobalFav.VariantIdToName[id] = name
            GlobalFav.VariantNameToId[name] = id
            table.insert(GlobalFav.Variants, name)
        end
    end
end
@@ -1591,50 +2156,86 @@ fav:AddButton({
        _G.AutoFavoriteRarities = {}
        GlobalFav.SelectedRarities = {}
        AIKO:MakeNotify({
            Title = "Aikoware",
            Description = "| Cleared",
            Content = "Rarity selection cleared",
            Delay = 2
        })
    end
})

fav:AddButton({
    Title = "Clear Variant Selection",
    Content = "Clear all selected variants",
    Callback = function()
        GlobalFav.SelectedVariants = {}
        AIKO:MakeNotify({
            Title = "Aikoware",
            Description = "| Cleared",
            Content = "Variant selection cleared",
            Delay = 2
        })
    end
})

local unfav = Favo:AddSection("Unfavorite")

local selectedUnfavRarities = {}

unfav:AddDropdown({
    Title = "Unfavorite By Rarity",
    Content = "",
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
    Multi = true,
    Default = {},
    Callback = function(selected)
        selectedUnfavRarities = {}
        for _, rarity in ipairs(selected) do
            selectedUnfavRarities[rarity] = true
        end
    end
})

unfav:AddButton({
    Title = "Run Unfavorite (Rarity)",
    Content = "",
    Callback = function()
        local count = unfavoriteByRarities(selectedUnfavRarities)
        notify("Aikoware", "| Unfavorite", "Unfavorited " .. tostring(count) .. " items", 3)
    end
})

unfav:AddButton({
    Title = "Unfavorite All",
    Content = "",
    Callback = function()
        local count = unfavoriteAll()
        notify("Aikoware", "| Unfavorite", "Unfavorited " .. tostring(count) .. " items", 3)
    end
})

local TeleportData = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/fishit/tpmdl.lua"))()

local loc = Teleport:AddSection("Location")

local locationNames = {}
for name, _ in pairs(TeleportData.Locations) do
    table.insert(locationNames, name)
end
table.sort(locationNames)

local selectedLocation = nil

local locationDropdown = loc:AddDropdown({
    Title = "Select Location",
    Content = "",
    Multi = false,
    Options = locationNames,
    Default = {},
    Callback = function(value)
        if type(value) == "table" and #value > 0 then
            selectedLocation = value[1]
        elseif type(value) == "string" then
            selectedLocation = value
        else
            selectedLocation = nil
@@ -1645,50 +2246,100 @@ local locationDropdown = loc:AddDropdown({
loc:AddButton({
    Title = "Teleport to Location",
    Content = "",
    Callback = function()
        if selectedLocation and TeleportData.Locations[selectedLocation] then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(TeleportData.Locations[selectedLocation])
                    AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Teleported",
                    Content = "Teleported to " .. selectedLocation,
                    Delay = 3
                })
            end
        else
                AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "| Error",
                Content = "No location selected",
                Delay = 3
            })
        end
    end
})

loc:AddButton({
    Title = "Teleport To All Locations",
    Content = "",
    Callback = function()
        if not LocalPlayer.Character then return end
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for _, name in ipairs(locationNames) do
            local target = TeleportData.Locations[name]
            if target then
                hrp.CFrame = CFrame.new(target)
                task.wait(0.6)
            end
        end
        notify("Aikoware", "| Teleport", "Finished teleporting all locations", 3)
    end
})

local saved = Teleport:AddSection("Saved Position")

local savedCFrame = nil

saved:AddButton({
    Title = "Save Position",
    Content = "",
    Callback = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            savedCFrame = hrp.CFrame
            notify("Aikoware", "| Saved", "Position saved", 2)
        else
            notify("Aikoware", "| Error", "Character not loaded", 2)
        end
    end
})

saved:AddButton({
    Title = "Teleport To Saved Position",
    Content = "",
    Callback = function()
        if savedCFrame and LocalPlayer.Character then
            LocalPlayer.Character:PivotTo(savedCFrame)
            notify("Aikoware", "| Teleported", "Teleported to saved position", 2)
        else
            notify("Aikoware", "| Error", "No saved position", 2)
        end
    end
})

local npcl = Teleport:AddSection("NPC")

local npcNames = {}
for name, _ in pairs(TeleportData.NPCs) do
    table.insert(npcNames, name)
end
table.sort(npcNames)

local selectedNPC = nil

local npcDropdown = npcl:AddDropdown({
    Title = "Select NPC",
    Content = "",
    Options = npcNames,
    Default = {},
    Multi = false,
    Callback = function(value)
        if type(value) == "table" and #value > 0 then
            selectedNPC = value[1]
        elseif type(value) == "string" then
            selectedNPC = value
        else
            selectedNPC = nil
        end
    end
@@ -1864,50 +2515,75 @@ local function getAvailableEvents()
            
            if child:IsA("Frame") then
                local displayLabel = child:FindFirstChild("DisplayName")
                if displayLabel and displayLabel:IsA("TextLabel") then
                    displayName = displayLabel.Text
                end
            end
            
            if not displayName or displayName == "" then
                displayName = child.Name
            end
            
            if typeof(displayName) == "string" and 
               displayName ~= "" and 
               displayName ~= "UIListLayout" and
               not IgnoredEvents[displayName] then
                local cleanName = displayName:gsub("^Admin %- ", "")
                table.insert(events, cleanName)
            end
        end
    end
    
    return events
end

local function getEventTimerText(eventName)
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local eventsGui = playerGui and playerGui:FindFirstChild("Events")
    if not eventsGui then return nil end

    local frame = eventsGui:FindFirstChild("Frame")
    frame = frame and frame:FindFirstChild("Events") or frame
    if not frame then return nil end

    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("Frame") then
            local displayLabel = child:FindFirstChild("DisplayName")
            local displayName = displayLabel and displayLabel.Text or child.Name
            if displayName and displayName:lower() == eventName:lower() then
                local timerLabel = child:FindFirstChild("Timer") or child:FindFirstChild("Time") or child:FindFirstChild("Countdown")
                if timerLabel and timerLabel:IsA("TextLabel") then
                    return timerLabel.Text
                end
            end
        end
    end

    return nil
end

local function findEventLocation(eventName)
    if not eventName then return nil end
    
    if eventName == "Megalodon Hunt" then
        local menuRings = Workspace:FindFirstChild("!!! MENU RINGS")
        if menuRings then
            for _, ring in ipairs(menuRings:GetChildren()) do
                local megalodonEvent = ring:FindFirstChild("Megalodon Hunt")
                if megalodonEvent then
                    megalodonEvent = megalodonEvent:FindFirstChild("Megalodon Hunt")
                end
                
                if megalodonEvent and megalodonEvent:IsA("BasePart") then
                    return megalodonEvent
                end
            end
        end
    else
        local propsLocations = {Workspace:FindFirstChild("Props")}
        local menuRings = Workspace:FindFirstChild("!!! MENU RINGS")
        
        if menuRings then
            for _, ring in ipairs(menuRings:GetChildren()) do
                if ring.Name:match("^Props") then
                    table.insert(propsLocations, ring)
@@ -2118,50 +2794,69 @@ evt:AddButton({
                        Title = "Aikoware",
                        Description = "| Teleported",
                        Content = "Teleported to " .. EventSettings.priorityEvent,
                        Delay = 3
                    })
                end
            else
                AIKO:MakeNotify({
                    Title = "Aikoware",
                    Description = "| Error",
                    Content = "Event not found or not active",
                    Delay = 3
                })
            end
        else
            AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "| Error",
                Content = "No priority event selected",
                Delay = 3
            })
        end
    end
})

local eventTimerSection = Teleport:AddSection("Event Timers")

local crystalTimerParagraph = eventTimerSection:AddParagraph({
    Title = "Crystal Fall Event Timer",
    Icon = "clock",
    Content = "Not available"
})

task.spawn(function()
    while task.wait(1) do
        local timerText = getEventTimerText("Crystal Fall")
        if timerText then
            crystalTimerParagraph:SetContent(timerText)
        else
            crystalTimerParagraph:SetContent("Not active")
        end
    end
end)

local ply = Teleport:AddSection("Player")

local selectedPlayer = nil

local playerDropdown = ply:AddDropdown({
    Title = "Select Player",
    Content = "",
    Options = TeleportData.GetPlayerNames(Players, LocalPlayer),
    Default = {},
    Multi = false,
    Callback = function(value)
        if type(value) == "table" and #value > 0 then
            selectedPlayer = value[1]
        elseif type(value) == "string" then
            selectedPlayer = value
        else
            selectedPlayer = nil
        end
    end
})

ply:AddButton({
    Title = "Teleport To Player",
    Content = "",
    Callback = function()
@@ -2215,147 +2910,224 @@ ply:AddButton({

local autotrade = Trade:AddSection("Auto Trade")

local TradeModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/fishit/autotrademdl.lua"))()
local Trade = TradeModule(Players, LocalPlayer, ReplicatedStorage, Library)

local selectedTradePlayer = nil

local tradePlayerDropdown = autotrade:AddDropdown({
    Title = "Select Player",
    Content = "",
    Options = Trade.GetPlayerNames(),
    Default = {},
    Multi = false,
    Callback = function(value)
        if type(value) == "table" and #value > 0 then
            selectedTradePlayer = value[1]
        elseif type(value) == "string" then
            selectedTradePlayer = value
        else
            selectedTradePlayer = nil
        end
    end
})

local tradeFishMap = {}

local function buildTradeFishOptions()
    tradeFishMap = {}
    local options = {}
    local items = getInventoryItems()

    for _, item in pairs(items) do
        local itemId = item.ItemId or item.Id or item.ItemID
        local uuid = item.UUID or (item.InventoryItem and item.InventoryItem.UUID)
        local name = GlobalFav.FishIdToName[itemId]
        if uuid and name then
            local label = name .. " [" .. uuid:sub(1, 8) .. "]"
            tradeFishMap[label] = uuid
            table.insert(options, label)
        end
    end

    table.sort(options)
    return options
end

local tradeFishDropdown = autotrade:AddDropdown({
    Title = "Select Fish To Trade",
    Content = "",
    Options = buildTradeFishOptions(),
    Default = {},
    Multi = false,
    Callback = function(value)
        local key = type(value) == "table" and value[1] or value
        if key and tradeFishMap[key] then
            Trade.Config.TradeItemId = tradeFishMap[key]
        end
    end
})

autotrade:AddButton({
    Title = "Give Item",
    Content = "",
    Callback = function()
        if selectedTradePlayer then
            Trade.SendTradeRequest(selectedTradePlayer)
        else
                AIKO:MakeNotify({
                Title = "Aikoware",
                Description = "| Error",
                Content = "No player selected",
                Delay = 3
            })
        end
    end
})

local autoAccept = autotrade:AddToggle({
    Title = "Auto Accept Trade Requests",
    Content = "",
    Default = false,
    Callback = function(state)
        Trade.SetAutoAccept(state)
    end
})

autotrade:AddButton({
    Title = "Refresh Player List",
    Icon = "refresh-cw",
    Content = "",
    Callback = function()
        tradePlayerDropdown:SetValues(Trade.GetPlayerNames())
        tradeFishDropdown:SetValues(buildTradeFishOptions())
            AIKO:MakeNotify({
            Title = "Aikoware",
            Description = "| Refreshed", 
            Content = "Player list updated", 
            Delay = 3
        })
    end
})

local WebhookModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/fishit/whmdl.lua"))()
WebhookModule.Initialize()

_G.WebhookRarities = _G.hWebhookRarities or {}

local webhookSection = Webhook:AddSection("Webhook Settings")

local sessionStats = {
    Total = 0,
    ByRarity = {}
}

local function updateSessionStatsParagraph(paragraph)
    local lines = {"Total: " .. tostring(sessionStats.Total)}
    for _, rarity in ipairs({"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"}) do
        local count = sessionStats.ByRarity[rarity] or 0
        table.insert(lines, rarity .. ": " .. tostring(count))
    end
    paragraph:SetContent(table.concat(lines, "<br/>"))
end

GlobalFav.REObtainedNewFishNotification.OnClientEvent:Connect(function(itemId)
    local tierName = GetTierName(GlobalFav.FishIdToTier[itemId])
    sessionStats.Total = sessionStats.Total + 1
    sessionStats.ByRarity[tierName] = (sessionStats.ByRarity[tierName] or 0) + 1
end)

local statsParagraph = webhookSection:AddParagraph({
    Title = "Session Stats",
    Icon = "bar-chart",
    Content = "Total: 0"
})

task.spawn(function()
    while task.wait(2) do
        updateSessionStatsParagraph(statsParagraph)
    end
end)

local whurl = webhookSection:AddInput({
    Title = "Webhook URL",
    Default = _G.WebhookFlags.FishCaught.URL,
    Placeholder = "Paste discord webhook...",
    Callback = function(url)
        local cleanUrl = WebhookModule.CleanWebhookURL(url)
        if cleanUrl then
            _G.WebhookFlags.FishCaught.URL = cleanUrl
        end
    end
})

local whfish = webhookSection:AddToggle({
    Title = "Webhook Send",
    Default = _G.WebhookFlags.FishCaught.Enabled,
    Callback = function(enabled)
        _G.WebhookFlags.FishCaught.Enabled = enabled
    end
})

local whrarity = webhookSection:AddDropdown({
    Title = "Rarity Filter",
    Content = "Empty = All",
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
    Multi = true,
    Default = {},
    Callback = function(selected)
        _G.WebhookRarities = {}
        for i, rarity in ipairs(selected) do
            _G.WebhookRarities[i] = rarity
        end
        
        local count = #_G.WebhookRarities
    end
})

webhookSection:AddButton({
    Title = "Test Fish Webhook",
    Callback = function()
        local success, message = WebhookModule.SendTestWebhook()
        AIKO:MakeNotify({
            Title = "Aikoware",
            Description = "| Test Webhook",
            Content = message,
            Delay = 3
        })
    end
})

webhookSection:AddButton({
    Title = "Ping Webhook",
    Callback = function()
        local success, message = WebhookModule.SendTestWebhook()
        notify("Aikoware", "| Webhook Ping", message, 3)
    end
})

webhookSection:AddDivider()

local whname = webhookSection:AddInput({
    Title = "Custom Name (Optional)",
    Default = _G.WebhookCustomName or "",
    Placeholder = "Leave blank to use Roblox name",
    Callback = function(name)
        _G.WebhookCustomName = name
    end
})

local disconnectSection = Webhook:AddSection("Webhook Disconnect Alert")

local dcurl = disconnectSection:AddInput({
    Title = "Webhook URL",
    Default = _G.WebhookFlags.Disconnect.URL,
    Placeholder = "Paste disconnect webhook...",
    Callback = function(url)
        local cleanUrl = WebhookModule.CleanWebhookURL(url)
        if cleanUrl then
            _G.WebhookFlags.Disconnect.URL = cleanUrl
        end
    end
})

@@ -2408,73 +3180,149 @@ local antiSolace = idn:AddToggle({
    Default = true,
    Callback = function(enabled)
        MiscModule.Identity:Toggle(enabled)
    end
})

local uset = Misc:AddSection("User Settings")

local WALKSPEED = uset:AddSlider({
    Title = "Walkspeed",
    Content = "",
    Min = 18,
    Max = 200,
    Default = 18,
    Callback = function(value)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
})

local JUMPPOWER = uset:AddSlider({
    Title = "Jump Power",
    Content = "",
    Min = 50,
    Max = 200,
    Default = 50,
    Callback = function(value)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = value
            end
        end
    end
})

uset:AddButton({
    Title = "Reset Walkspeed",
    Content = "Returns to default speed.",
    Callback = function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 18
            end
        end
    end
})

uset:AddButton({
    Title = "Reset Jump Power",
    Content = "Returns to default jump power.",
    Callback = function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = 50
            end
        end
    end
})

local INFJUMP = uset:AddToggle({
    Title = "Inf Jump",
    Content = "",
    Default = false,
    Callback = function(enabled)
        MiscModule.InfiniteJump:Toggle(enabled)
    end
})

local util = Misc:AddSection("Utility")

local quickInteractEnabled = false
local quickInteractConnection = nil

local function runQuickInteract()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local parent = prompt.Parent
            if parent and parent:IsA("BasePart") then
                if (parent.Position - hrp.Position).Magnitude <= prompt.MaxActivationDistance then
                    if fireproximityprompt then
                        pcall(function()
                            fireproximityprompt(prompt)
                        end)
                    end
                end
            end
        end
    end
end

util:AddToggle({
    Title = "Quick Interact",
    Content = "",
    Default = false,
    Callback = function(enabled)
        quickInteractEnabled = enabled
        if enabled then
            if quickInteractConnection then
                quickInteractConnection:Disconnect()
            end
            quickInteractConnection = RunService.Heartbeat:Connect(runQuickInteract)
        else
            if quickInteractConnection then
                quickInteractConnection:Disconnect()
                quickInteractConnection = nil
            end
        end
    end
})

local perf = Misc:AddSection("Performance")

perf:AddButton({
    Title = "Low GFX",
    Content = "Ultra low graphics mode.",
    Callback = function()
        MiscModule.Performance:LowGFX()
    end
})

perf:AddToggle({
    Title = "Hide Players",
    Content = "",
    Default = false,
    Callback = function(enabled)
        if enabled then
            MiscModule.Performance:EnableHidePlayers()
        else
            MiscModule.Performance:DisableHidePlayers()
        end
    end
})

perf:AddToggle({
    Title = "Remove Shadows",
@@ -2490,50 +3338,166 @@ perf:AddToggle({
    Content = "",
    Default = false,
    Callback = function(enabled)
        MiscModule.Performance:RemoveWaterReflections(enabled)
    end
})

perf:AddToggle({
    Title = "Remove Particles",
    Content = "",
    Default = false,
    Callback = function(enabled)
        MiscModule.Performance:RemoveParticles(enabled)
    end
})

perf:AddToggle({
    Title = "Remove Terrain Decorations",
    Content = "",
    Default = false,
    Callback = function(enabled)
        MiscModule.Performance:RemoveTerrainDecorations(enabled)
    end
})

local env = Misc:AddSection("Environment")

local dayConnection = nil
local nightConnection = nil
local originalFog = {
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd
}
local removedParticles = {}

local function toggleOnlyDay(enabled)
    if enabled then
        if nightConnection then
            nightConnection:Disconnect()
            nightConnection = nil
        end
        dayConnection = RunService.Heartbeat:Connect(function()
            Lighting.ClockTime = 12
        end)
    else
        if dayConnection then
            dayConnection:Disconnect()
            dayConnection = nil
        end
    end
end

local function toggleOnlyNight(enabled)
    if enabled then
        if dayConnection then
            dayConnection:Disconnect()
            dayConnection = nil
        end
        nightConnection = RunService.Heartbeat:Connect(function()
            Lighting.ClockTime = 0
        end)
    else
        if nightConnection then
            nightConnection:Disconnect()
            nightConnection = nil
        end
    end
end

local function setFogRemoved(enabled)
    if enabled then
        Lighting.FogStart = 0
        Lighting.FogEnd = 100000
    else
        Lighting.FogStart = originalFog.FogStart
        Lighting.FogEnd = originalFog.FogEnd
    end
end

local function toggleParticlesByName(keyword, enabled)
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
            local name = descendant.Name:lower()
            local parentName = descendant.Parent and descendant.Parent.Name:lower() or ""
            if name:find(keyword) or parentName:find(keyword) then
                if enabled then
                    if removedParticles[descendant] == nil then
                        removedParticles[descendant] = descendant.Enabled
                    end
                    descendant.Enabled = false
                else
                    if removedParticles[descendant] ~= nil then
                        descendant.Enabled = removedParticles[descendant]
                        removedParticles[descendant] = nil
                    end
                end
            end
        end
    end
end

env:AddToggle({
    Title = "Only Day",
    Default = false,
    Callback = function(enabled)
        toggleOnlyDay(enabled)
    end
})

env:AddToggle({
    Title = "Only Night",
    Default = false,
    Callback = function(enabled)
        toggleOnlyNight(enabled)
    end
})

env:AddToggle({
    Title = "Remove FOG",
    Default = false,
    Callback = function(enabled)
        setFogRemoved(enabled)
    end
})

env:AddToggle({
    Title = "Remove Rain",
    Default = false,
    Callback = function(enabled)
        toggleParticlesByName("rain", enabled)
    end
})

env:AddToggle({
    Title = "Remove Snow",
    Default = false,
    Callback = function(enabled)
        toggleParticlesByName("snow", enabled)
    end
})

-- local SkinModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/fishit/skinmdl.lua"))()
local PingModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/xzc/fishit/pingmdl.lua"))()

--[[ local skinSec = Misc:AddSection("Rod Skin Animations")

skinSec:AddDropdown({
    Title = "Select Skin",
    Options = SkinModule:GetSkins(),
    Multi = false,
    Default = "Eclipse",
    Callback = function(value)
        if type(value) == "table" and #value > 0 then
            SkinModule:SetSkin(value[1])
        elseif type(value) == "string" then
            SkinModule:SetSkin(value)
        end
    end
})

skinSec:AddToggle({
    Title = "Enable Skin Animations",
    Default = false,
    Callback = function(enabled)
        if enabled then
            SkinModule:Enable()
@@ -2559,50 +3523,60 @@ monitor:AddToggle({

PingModule:SetTitle("Aikoware")

local xpb = Misc:AddSection("Level Progress")

local xpProgress = xpb:AddToggle({
    Title = "Show Level Progress Bar",
    Content = "",
    Default = true,
    Callback = function(state)
        MiscModule.XPBar:Toggle(state)
    end
})

local oxy = Misc:AddSection("Infinite Oxygen")

local antiDrown = oxy:AddToggle({
    Title = "Anti Drown",
    Content = "",
    Default = false,
    Callback = function(state)
        MiscModule.AntiDrown:Toggle(state)
    end,
})

oxy:AddButton({
    Title = "Get Oxygen Tank",
    Content = "Auto equip Oxygen Tank if available.",
    Callback = function()
        if not equipToolByName("oxygen") then
            notify("Aikoware", "| Oxygen", "Oxygen tank not found", 2)
        end
    end
})

local zooom = Misc:AddSection("Max Zoom")

function SetMaxZoom(distance)
    local player = game:GetService("Players").LocalPlayer
    if player then
        player.CameraMaxZoomDistance = distance
        player.CameraMinZoomDistance = distance
    end
end


local maxzoom = zooom:AddInput({
    Title = "Camera Max Zoom",
    Default = "128",
    Placeholder = "Enter zoom distance...",
    Callback = function(value)
        local zoomDistance = tonumber(value)
        if zoomDistance and zoomDistance > 0 then
            Player.CameraMaxZoomDistance = zoomDistance
            Player.CameraMinZoomDistance = 0.5
        end
    end
})

function BypassRadar(enabled)
