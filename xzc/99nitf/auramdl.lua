local AuraModule = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

AuraModule.killAuraToggle = false
AuraModule.chopAuraToggle = false
AuraModule.auraRadius = 50
AuraModule.currentammount = 0

local toolsDamageIDs = {
    ["Old Axe"] = "3_7367831688",
    ["Good Axe"] = "112_7367831688",
    ["Strong Axe"] = "116_7367831688",
    ["Ice Axe"] = "116_7367831688",
    ["Admin Axe"] = "116_7367831688",
    ["Morningstar"] = "116_7367831688",
    ["Laser Sword"] = "116_7367831688",
    ["Ice Sword"] = "116_7367831688",
    ["Infernal Sword"] = "6_7461591369",
    ["Katana"] = "116_7367831688",
    ["Trident"] = "116_7367831688",
    ["Poison Spear"] = "116_7367831688",
    ["Chainsaw"] = "647_8992824875",
    ["Spear"] = "196_8999010016",
    ["Rifle"] = "22_6180169035"
}

local function getEquippedTool()
    local character = LocalPlayer.Character
    if not character then return nil, nil end
    
    for toolName, damageID in pairs(toolsDamageIDs) do
        local equippedTool = character:FindFirstChild(toolName)
        if equippedTool and equippedTool:IsA("Tool") then
            local inventoryTool = LocalPlayer:FindFirstChild("Inventory") and LocalPlayer.Inventory:FindFirstChild(toolName)
            if inventoryTool then
                return inventoryTool, damageID
            end
        end
    end
    
    return nil, nil
end

local function killAuraLoop()
    while AuraModule.killAuraToggle do
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local tool, damageID = getEquippedTool()
            if tool and damageID then
                for _, mob in ipairs(Workspace.Characters:GetChildren()) do
                    if mob:IsA("Model") then
                        local part = mob:FindFirstChildWhichIsA("BasePart")
                        if part and (part.Position - hrp.Position).Magnitude <= AuraModule.auraRadius then
                            pcall(function()
                                ReplicatedStorage:WaitForChild("RemoteEvents").ToolDamageObject:InvokeServer(
                                    mob,
                                    tool,
                                    damageID,
                                    CFrame.new(part.Position)
                                )
                            end)
                        end
                    end
                end
            end
        end
        task.wait(0.01)
    end
end

local function chopAuraLoop()
    while AuraModule.chopAuraToggle do
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local tool, baseDamageID = getEquippedTool()
            if tool and baseDamageID then
                local toolName = tool.Name
                if toolName == "Old Axe" or toolName == "Good Axe" or toolName == "Strong Axe" or toolName == "Ice Axe" or toolName == "Chainsaw" then
                    AuraModule.currentammount = AuraModule.currentammount + 1
                    local trees = {}
                    local map = Workspace:FindFirstChild("Map")
                    if map then
                        if map:FindFirstChild("Foliage") then
                            for _, obj in ipairs(map.Foliage:GetChildren()) do
                                if obj:IsA("Model") and (obj.Name == "Small Tree" or obj.Name == "Snowy Small Tree") then
                                    table.insert(trees, obj)
                                end
                            end
                        end
                        if map:FindFirstChild("Landmarks") then
                            for _, obj in ipairs(map.Landmarks:GetChildren()) do
                                if obj:IsA("Model") and obj.Name == "Small Tree" then
                                    table.insert(trees, obj)
                                end
                            end
                        end
                    end
                    for _, tree in ipairs(trees) do
                        local trunk = tree:FindFirstChild("Trunk")
                        if trunk and trunk:IsA("BasePart") and (trunk.Position - hrp.Position).Magnitude <= AuraModule.auraRadius then
                            local alreadyammount = false
                            task.spawn(function()
                                while AuraModule.chopAuraToggle and tree and tree.Parent and not alreadyammount do
                                    alreadyammount = true
                                    AuraModule.currentammount = AuraModule.currentammount + 1
                                    pcall(function()
                                        ReplicatedStorage:WaitForChild("RemoteEvents").ToolDamageObject:InvokeServer(
                                            tree,
                                            tool,
                                            tostring(AuraModule.currentammount) .. "_7367831688",
                                            CFrame.new(-2.962610244751, 4.5547881126404, -75.950843811035, 0.89621275663376, -1.3894891459643e-08, 0.44362446665764, -7.994568895775e-10, 1, 3.293635941759e-08, -0.44362446665764, -2.9872644802253e-08, 0.89621275663376)
                                        )
                                    end)
                                end
                            end)
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end

function AuraModule.StartKillAura()
    AuraModule.killAuraToggle = true
    task.spawn(killAuraLoop)
end

function AuraModule.StopKillAura()
    AuraModule.killAuraToggle = false
end

function AuraModule.StartChopAura()
    AuraModule.chopAuraToggle = true
    task.spawn(chopAuraLoop)
end

function AuraModule.StopChopAura()
    AuraModule.chopAuraToggle = false
end

function AuraModule.SetAuraRadius(radius)
    AuraModule.auraRadius = math.clamp(radius, 1, 100)
end

function AuraModule.IsKillAuraActive()
    return AuraModule.killAuraToggle
end

function AuraModule.IsChopAuraActive()
    return AuraModule.chopAuraToggle
end

function AuraModule.StopAllAuras()
    AuraModule.StopKillAura()
    AuraModule.StopChopAura()
end

return AuraModule
