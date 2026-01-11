local AIKO = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/src/Library.lua"))()

local Window = AIKO:Window({
    Title = "Aikoware |",
    Footer = "made by @aoki!",
    Version = 1
})

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local LocalPlayer = player
local Character = player.Character or player.CharacterAdded:Wait()

local autoKM_Running = false
local dupe_Running = false
local duplicateCashActive = false

local function autoFarmKm(state)
    autoKM_Running = state

    if state then
        task.spawn(function()
            while autoKM_Running and player.Character do
                local hum = player.Character:FindFirstChild("Humanoid")
                if hum and hum.SeatPart then
                    local car = hum.SeatPart.Parent

                    if car:FindFirstChild("Body") and car.Body:FindFirstChild("#Weight") then
                        car.PrimaryPart = car.Body["#Weight"]
                    end

                    local pos1 = Vector3.new(-6205.2983, 100, 8219.8535)
                    local pos2 = Vector3.new(-7594.5410, 100, 5130.9526)

                    repeat
                        task.wait()
                        car.PrimaryPart.Velocity = car.PrimaryPart.CFrame.LookVector * 550
                        car:PivotTo(CFrame.new(car.PrimaryPart.Position, pos1))
                    until not autoKM_Running or (player.Character.PrimaryPart.Position - pos1).Magnitude < 50

                    car.PrimaryPart.Velocity = Vector3.new()

                    repeat
                        task.wait()
                        car.PrimaryPart.Velocity = car.PrimaryPart.CFrame.LookVector * 550
                        car:PivotTo(CFrame.new(car.PrimaryPart.Position, pos2))
                    until not autoKM_Running or (player.Character.PrimaryPart.Position - pos2).Magnitude < 50

                    car.PrimaryPart.Velocity = Vector3.new()
                end

                task.wait(0.1)
            end
        end)
    end
end

local function activateExp()
    pcall(function()
        local ls = player:FindFirstChild("leaderstats")
        if ls and ls:FindFirstChild("Exp") then
            ls.Exp.Value = 82917
        end
    end)
end

local function duplicateCoin(state)
    dupe_Running = state

    local RS = ReplicatedStorage
    local WS = Workspace
    local Remotes = RS:WaitForChild("Remotes")
    local RecieveCoin = Remotes:WaitForChild("RecieveCoin")
    local Jeepnies = WS:WaitForChild("Jeepnies")

    if state then
        task.spawn(function()
            while dupe_Running do
                pcall(function()
                    local Jeep = Jeepnies:FindFirstChild(player.Name)
                    if Jeep then
                        local PV = Jeep:FindFirstChild("PassengerValues")
                        if PV then
                            RecieveCoin:FireServer({
                                PassengerValues = PV,
                                Password = 123456789,
                                Main = true,
                                Value = 300
                            })
                        end
                    end
                end)
                task.wait(0.01)
            end
        end)
    end
end

local function duplicateCash(state)
    duplicateCashActive = state
    local RecieveCash = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RecieveCash")

    if state then
        task.spawn(function()
            while duplicateCashActive do
                for i = 1, 1250 do
                    pcall(function()
                        RecieveCash:FireServer({
                            Value = 100,
                            Password = 93828272827
                        })
                    end)
                end
                task.wait(0.3)
            end
        end)
    end
end

local settings = { 
    repeatamount = 55, 
    exceptions = {"SayMessageRequest"},
    enabled = false
}

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = function(uh, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    for _, v in pairs(settings.exceptions) do
        if uh.Name == v then
            return old(uh, ...)
        end
    end
    
    if settings.enabled and (method == "FireServer" or method == "InvokeServer") then
        for i = 1, settings.repeatamount do
            old(uh, unpack(args))
        end
    end
    
    return old(uh, unpack(args))
end

setreadonly(mt, true)

local main = Window:AddTab({
    Name = "Main",
    Icon = "star"
})

local expsec = main:AddSection("Exploit")

expsec:AddParagraph({
    Title = "Tip",
    Icon = "idea",
    Content = "Sobrahan niyo ng sukli para dalawang beses mag duplicate."
})

expsec:AddToggle({
    Title = "Manual Duplicate Coins",
    Content = "",
    Default = false,
    Callback = function(value)
        duplicateCoin(value)
    end
})

expsec:AddToggle({
    Title = "Manual Duplicate Cash",
    Default = false,
    Callback = function(v)
        duplicateCash(v)
    end
})

expsec:AddDivider()

expsec:AddToggle({
    Title = "Exp Farm",
    Default = false,
    Callback = function(value)
        settings.enabled = value
    end
})

expsec:AddToggle({
    Title = "Auto Farm KM",
    Content = "",
    Default = false,
    Callback = function(value)
        autoFarmKm(value)
    end
})

local jep = main:AddSection("Spawn Jeepney")

jep:AddButton({
    Title = "Spawn Milwaukee Motor Sport 11 Seater",
    Content = "Spawn the unreleased jeepney ;p",
    Callback = function()
        aiko("Spawning jeepney...")
        task.spawn(function()
            local args = {
                [1] = {
                    ["UnitName"] = "Unit 3 (404)",
                    ["JeepneyName"] = "Milwaukee Motor Sport 11 Seater",
                    ["OperatorNpc"] = workspace:WaitForChild("Map", 9e9):WaitForChild("Misc", 9e9):WaitForChild("Operators", 9e9):WaitForChild("Mang Juan", 9e9)
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 9e9):WaitForChild("SpawnOperatorNPCJeepney", 9e9):FireServer(unpack(args))
        end)
    end
})

jep:AddButton({
    Title = "Spawn Sarao Custombuilt V1 (SH)",
    Callback = function()
        aiko("Spawning jeepney...")
        task.spawn(function()
            local args = {
                [1] = {
                    ["UnitName"] = "Unit 3 (404)";
                    ["JeepneyName"] = "Sarao Custombuilt V1 (SH)";
                    ["OperatorNpc"] = workspace:WaitForChild("Map", 9e9):WaitForChild("Misc", 9e9):WaitForChild("Operators", 9e9):WaitForChild("Mang Juan", 9e9);
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 9e9):WaitForChild("SpawnOperatorNPCJeepney", 9e9):FireServer(unpack(args))
        end)
    end
})

jep:AddButton({
    Title = "Spawn Sarao Custombuilt Model 2",
    Callback = function()
        aiko("Spawning jeepney...")
        task.spawn(function()
            local args = {
                [1] = {
                    ["UnitName"] = "Unit 3 (404)";
                    ["JeepneyName"] = "Sarao Custombuilt Model 2";
                    ["OperatorNpc"] = workspace:WaitForChild("Map", 9e9):WaitForChild("Misc", 9e9):WaitForChild("Operators", 9e9):WaitForChild("Mang Juan", 9e9);
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 9e9):WaitForChild("SpawnOperatorNPCJeepney", 9e9):FireServer(unpack(args))
        end)
    end
})

jep:AddButton({
    Title = "Spawn Morales 10 Seater",
    Callback = function()
        aiko("Spawning jeepney...")
        task.spawn(function()
            local args = {
                [1] = {
                    ["UnitName"] = "Unit 3 (404)";
                    ["JeepneyName"] = "Morales 10 Seater";
                    ["OperatorNpc"] = workspace:WaitForChild("Map", 9e9):WaitForChild("Misc", 9e9):WaitForChild("Operators", 9e9):WaitForChild("Mang Juan", 9e9);
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 9e9):WaitForChild("SpawnOperatorNPCJeepney", 9e9):FireServer(unpack(args))
        end)
    end
})

jep:AddButton({
    Title = "Spawn DF Devera Long Model",
    Callback = function()
        aiko("Spawning jeepney...")
        task.spawn(function()
            local args = {
                [1] = {
                    ["UnitName"] = "Unit 3 (404)";
                    ["JeepneyName"] = "DF Devera Long Model";
                    ["OperatorNpc"] = workspace:WaitForChild("Map", 9e9):WaitForChild("Misc", 9e9):WaitForChild("Operators", 9e9):WaitForChild("Mang Juan", 9e9);
                }
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 9e9):WaitForChild("SpawnOperatorNPCJeepney", 9e9):FireServer(unpack(args))
        end)
    end
})

local visec = main:AddSection("Visual")

visec:AddParagraph({
    Title = "Recommend:",
    Content = "Use the add exp if you're only going to buy something in talyer, then rejoin so your exp wont get reset if you bump into other jeeps or walls."
})

visec:AddButton({
    Title = "Add Exp",
    Callback = function()
        activateExp()
        aiko("Exp Added!")
    end
})

local info = Window:AddTab({
    Name = "Information",
    Icon = "alert"
})

local hideIdentity = main:AddSection("Identity")

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local originalBottomName = ""
local originalBottomColor = Color3.new(1, 1, 1)
local rgbEnabled = false
local hue = 0
local currentOverheadName = nil
local currentPlayerName = nil

task.spawn(function()
    while true do
        if rgbEnabled then
            hue = hue + 0.01
            if hue >= 1 then hue = 0 end
            local color = Color3.fromHSV(hue, 1, 1)
            if currentPlayerName then
                currentPlayerName.TextColor3 = color
            end
            if currentOverheadName then
                overheadName.TextColor3 = color
            end
        end
        task.wait(0.05)
    end
end)

local function findOverheadGui(character)
    wait(2)
    
    local overheadGui = nil
    
    if character:FindFirstChild("OverHeadGui") then
        overheadGui = character.OverHeadGui
    end
    
    if not overheadGui and character:FindFirstChild("Head") then
        if character.Head:FindFirstChild("OverHeadGui") then
            overheadGui = character.Head.OverHeadGui
        end
    end
    
    if not overheadGui and character:FindFirstChild("HumanoidRootPart") then
        if character.HumanoidRootPart:FindFirstChild("OverHeadGui") then
            overheadGui = character.HumanoidRootPart.OverHeadGui
        end
    end
    
    if not overheadGui then
        for _, obj in pairs(character:GetDescendants()) do
            if obj.Name == "OverHeadGui" then
                overheadGui = obj
                break
            end
        end
    end
    
    if not overheadGui then
        return nil
    end
    
    for _, obj in pairs(overheadGui:GetDescendants()) do
        if obj:IsA("TextLabel") then
            return obj
        end
    end
    
    return nil
end

local function setupCharacter(character)
    currentOverheadName = findOverheadGui(character)
    
    local playerGui = player:WaitForChild("PlayerGui")
    local screenGui = playerGui:WaitForChild("Screen")
    local labels = screenGui:WaitForChild("Labels")
    local hungerLabels = labels:WaitForChild("HungerLabels")
    currentPlayerName = hungerLabels:WaitForChild("PlayerName")
    
    if originalBottomName == "" then
        originalBottomName = currentPlayerName.Text
        originalBottomColor = currentPlayerName.TextColor3
    end
    
    if rgbEnabled then
        currentPlayerName.Text = "Aikoware [PROTECTED]"
        if currentOverheadName then
            currentOverheadName.Text = "Aikoware [PROTECTED]"
        end
    else
        currentPlayerName.Text = originalBottomName
        currentPlayerName.TextColor3 = originalBottomColor
        if currentOverheadName then
            currentOverheadName.Text = originalBottomName
            currentOverheadName.TextColor3 = originalBottomColor
        end
    end
end

if player.Character then
    setupCharacter(player.Character)
end

player.CharacterAdded:Connect(function(character)
    setupCharacter(character)
end)

hideIdentity:AddToggle({
    Title = "Hide Identity",
    Content = "",
    Default = true,
    Callback = function(value)
        rgbEnabled = value
        
        if value then
            if currentPlayerName then
                currentPlayerName.Text = "Aikoware [PROTECTED]"
            end
            if currentOverheadName then
                currentOverheadName.Text = "Aikoware [PROTECTED]"
            end
        else
            if currentPlayerName then
                currentPlayerName.Text = originalBottomName
                currentPlayerName.TextColor3 = originalBottomColor
            end
            if currentOverheadName then
                currentOverheadName.Text = originalBottomName
                currentOverheadName.TextColor3 = originalBottomColor
            end
        end
    end
})

local infosec = info:AddSection("Info", true)

infosec:AddParagraph({
    Title = "Discord",
    Content = "Join our discord for more information.",
    Icon = "discord",
    ButtonText = "Copy Discord Link",
    ButtonCallback = function()
        local link = "https://discord.gg/JccfFGpDNV"
        if setclipboard then
            setclipboard(link)
            aiko("Successfully Copied!")
        end
    end
})

AIKO:MakeNotify({
    Title = "Aikoware",
    Description = "| Script Loaded",
    Content = "Game: Diesel 'N Steel",
    Delay = 5
})
