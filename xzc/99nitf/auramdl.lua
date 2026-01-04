local AuraModule = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

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

local function isToolEquipped()
    local character = LocalPlayer.Character
    if not character then return false, nil, nil end
    
    for toolName, damageID in pairs(toolsDamageIDs) do
        local equippedTool = character:FindFirstChild(toolName)
        if equippedTool and equippedTool:IsA("Tool") then
            local inventoryTool = LocalPlayer:FindFirstChild("Inventory") 
                and LocalPlayer.Inventory:FindFirstChild(toolName)
            
            return true, inventoryTool or equippedTool, damageID
        end
    end
    
    return false, nil, nil
end

local function killAuraLoop()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not AuraModule.killAuraToggle then
            connection:Disconnect()
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local equipped, tool, damageID = isToolEquipped()
        if not equipped or not tool or not damageID then return end
        
        for _, mob in ipairs(Workspace.Characters:GetChildren()) do
            if mob:IsA("Model") and mob ~= character then
                local part = mob:FindFirstChildWhichIsA("BasePart")
                if part then
                    local distance = (part.Position - hrp.Position).Magnitude
                    if distance <= AuraModule.auraRadius then
                        pcall(function()
                            ReplicatedStorage:WaitForChild("RemoteEvents")
                                .ToolDamageObject:InvokeServer(
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
    end)
end

local function chopAuraLoop()
    local connection
    local processedTrees = {}
    
    connection = RunService.Heartbeat:Connect(function()
        if not AuraModule.chopAuraToggle then
            connection:Disconnect()
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local equipped, tool, baseDamageID = isToolEquipped()
        if not equipped or not tool or not baseDamageID then return end
        
        local toolName = tool.Name
        local validAxes = {
            ["Old Axe"] = true,
            ["Good Axe"] = true,
            ["Strong Axe"] = true,
            ["Ice Axe"] = true,
            ["Chainsaw"] = true
        }
        
        if not validAxes[toolName] then return end
        
        local trees = {}
        local map = Workspace:FindFirstChild("Map")
        
        if map then
            local foliage = map:FindFirstChild("Foliage")
            if foliage then
                for _, obj in ipairs(foliage:GetChildren()) do
                    if obj:IsA("Model") and 
                       (obj.Name == "Small Tree" or obj.Name == "Snowy Small Tree") then
                        table.insert(trees, obj)
                    end
                end
            end
            
            local landmarks = map:FindFirstChild("Landmarks")
            if landmarks then
                for _, obj in ipairs(landmarks:GetChildren()) do
                    if obj:IsA("Model") and obj.Name == "Small Tree" then
                        table.insert(trees, obj)
                    end
                end
            end
        end
        
        for _, tree in ipairs(trees) do
            if tree and tree.Parent then
                local trunk = tree:FindFirstChild("Trunk")
                if trunk and trunk:IsA("BasePart") then
                    local distance = (trunk.Position - hrp.Position).Magnitude
                    if distance <= AuraModule.auraRadius then
                        if not processedTrees[tree] then
                            processedTrees[tree] = true
                            AuraModule.currentammount = AuraModule.currentammount + 1
                        end
                        
                        pcall(function()
                            ReplicatedStorage:WaitForChild("RemoteEvents")
                                .ToolDamageObject:InvokeServer(
                                    tree,
                                    tool,
                                    tostring(AuraModule.currentammount) .. "_7367831688",
                                    CFrame.new(trunk.Position)
                                )
                        end)
                    end
                end
            end
        end
        
        for tree in pairs(processedTrees) do
            if not tree or not tree.Parent then
                processedTrees[tree] = nil
            end
        end
    end)
end

function AuraModule.StartKillAura()
    if not AuraModule.killAuraToggle then
        AuraModule.killAuraToggle = true
        task.spawn(killAuraLoop)
    end
end

function AuraModule.StopKillAura()
    AuraModule.killAuraToggle = false
end

function AuraModule.StartChopAura()
    if not AuraModule.chopAuraToggle then
        AuraModule.chopAuraToggle = true
        AuraModule.currentammount = 0
        task.spawn(chopAuraLoop)
    end
end

function AuraModule.StopChopAura()
    AuraModule.chopAuraToggle = false
end

function AuraModule.SetAuraRadius(radius)
    AuraModule.auraRadius = math.clamp(radius, 1, 200)
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
