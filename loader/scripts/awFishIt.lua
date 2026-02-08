-- Block keywords setup with hookfunction
local originalNamecall = hookfunction(game.GetService, function(serviceName)
    return oldServices[serviceName] or game:GetService(serviceName)
end)

-- Load AIKO library
local aiko = require(game:GetService("ReplicatedStorage").AIKO)

-- Create Window
local window = aiko:CreateWindow("Game GUI")

-- Define all services and remotes
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

-- Tabs creation
local tabs = {}

-- Home Tab with Discord and Server sections
local homeTab = window:CreateTab("Home")

-- Discord Section
local discordSection = homeTab:CreateSection("Discord")
local antiAFKToggle = discordSection:CreateToggle("Anti AFK", function(value)
    if value then
        while true do
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Enum.UserInputType.MouseButton2)
            wait(5)
        end
    end
end)
local autoReconnectToggle = discordSection:CreateToggle("Auto Reconnect", function(value)
    -- Logic for reconnect
end)
local rejoinButton = discordSection:CreateButton("Rejoin", function()
    game.Players.LocalPlayer:Kick("Rejoining...")
    wait(5)
    game:GetService("TeleportService"):Teleport(game.PlaceId, Players.LocalPlayer)
end)

-- Fishing Tab
local fishingTab = window:CreateTab("Fishing")

-- Legit Fishing Section
local legitFishingSection = fishingTab:CreateSection("Legit Fishing")
local legitFishingToggle = legitFishingSection:CreateToggle("Toggle Legit Fishing", function(value)
    if value then
        StartLegitFishing()
    end
end)
local legitFishingButton = legitFishingSection:CreateButton("Start Fishing", function()
    StartLegitFishing()
end)

-- Instant Fishing Section
local instantFishingSection = fishingTab:CreateSection("Instant Fishing")
local instantFishingToggle = instantFishingSection:CreateToggle("Toggle Instant Fishing", function(value)
    if value then
        StartInstantFishing(1) -- Placeholder for delay
    end
end)
local inputDelay = instantFishingSection:CreateInput("Delay (seconds)", function(value)
    -- Logic for delay
end)

-- Blatant Section
local blatantSection = fishingTab:CreateSection("Blatant Fishing")
local blatantToggle = blatantSection:CreateToggle("Toggle Blatant Fishing", function(value)
    if value then
        -- Logic for blatant fishing
    end
end)
local inputDelays = blatantSection:CreateInput("Delays (milliseconds)", function(value)
end)
local fixButton = blatantSection:CreateButton("Manual Fix", function()
    -- Logic for manual fix
end)

-- Blatant V2 Section
local blatantV2Section = fishingTab:CreateSection("Blatant V2")
local blatantV2Toggle = blatantV2Section:CreateToggle("Toggle Blatant V2", function(value)
    if value then
        -- Logic for Blatant V2
    end
end)
local inputV2 = blatantV2Section:CreateInput("Input for settings", function(value)
end)

-- Enchant Section
local enchantSection = fishingTab:CreateSection("Enchant")
local enchantToggle = enchantSection:CreateToggle("Auto Enchant", function(value)
    if value then
        -- Logic for auto enchanting
    end
end)

-- Auto Fish Misc Section
local autoFishMiscSection = fishingTab:CreateSection("Auto Fish Misc")
local notificationToggle = autoFishMiscSection:CreateToggle("Notifications", function(value)
    -- Handle notifications
end)
local animationToggle = autoFishMiscSection:CreateToggle("Animations", function(value)
    -- Handle animations
end)
local freezeToggle = autoFishMiscSection:CreateToggle("Freeze", function(value)
    -- Handle freeze
end)

-- Shop Tab
local shopTab = window:CreateTab("Shop")

-- Rod Shop section
local rodShopSection = shopTab:CreateSection("Rod Shop")
local rodDropdown = rodShopSection:CreateDropdown("Select Rod", {"Rod1", "Rod2"}, function(selected)
    -- Logic for selecting rod
end)
local buyRodButton = rodShopSection:CreateButton("Buy Rod", function()
    -- Logic for buying rod
end)

-- Bait Shop section
local baitShopSection = shopTab:CreateSection("Bait Shop")
local baitDropdown = baitShopSection:CreateDropdown("Select Bait", {"Bait1", "Bait2"}, function(selected)
    -- Logic for selecting bait
end)
local buyBaitButton = baitShopSection:CreateButton("Buy Bait", function()
    -- Logic for buying bait
end)

-- Auto Favorite Tab
local autoFavoriteTab = window:CreateTab("Auto Favorite")
-- Add UI elements for Auto Favorite tab

-- Teleport Tab
local teleportTab = window:CreateTab("Teleport")
-- Add UI elements for Teleport tab

-- Trade Tab
local tradeTab = window:CreateTab("Trade")
-- Add UI elements for Trade tab

-- Webhook Tab
local webhookTab = window:CreateTab("Webhook")
-- Add UI elements for Webhook tab

-- Misc Tab
local miscTab = window:CreateTab("Misc")
-- Add UI elements for Misc tab

-- Helper functions
function getFishCount()
    -- Logic to get fish count
end

function StartLegitFishing()
    -- Logic to start legit fishing
end

function StartInstantFishing(delay)
    wait(delay)
    -- Logic to start instant fishing
end

-- Add more functions as needed based on the functionality required
