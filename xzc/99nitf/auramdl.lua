local AuraModule = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Get LocalPlayer
local LocalPlayer = Players.LocalPlayer

-- Public state variables
AuraModule.killAuraToggle = false
AuraModule.chopAuraToggle = false
AuraModule.auraRadius = 50
AuraModule.currentammount = 0

-- Tools Damage IDs
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

-- Axe tools for chop aura
local axeTools = {
    ["Old Axe"] = true,
    ["Good Axe"] = true,
    ["Strong Axe"] = true,
    ["Ice Axe"] = true,
    ["Chainsaw"] = true
}

-- Get any tool from inventory
local function getAnyToolWithDamageID(isChopAura)
    local inventory = LocalPlayer:FindFirstChild("Inventory")
    if not inventory then 
        return nil, nil 
    end
    
    for toolName, damageID in pairs(toolsDamageIDs) do
        -- Skip non-axe tools for chop aura
        if isChopAura and not axeTools[toolName] then
            continue
        end
        
        local tool = inventory:FindFirstChild(toolName)
        if tool then
            return tool, damageID
        end
    end
    
    return nil, nil
end

-- Check if tool is currently equipped in character
local function isToolEquipped(toolName)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local equippedTool = character:FindFirstChild(toolName)
    return equippedTool ~= nil
end

-- Equip Tool Function
local function equipTool(tool)
    if tool then
        local success, err = pcall(function()
            ReplicatedStorage:WaitForChild("RemoteEvents")
                .EquipItemHandle:FireServer("FireAllClients", tool)
        end)
        if success then
            print("[equipTool] Equipped:", tool.Name)
            task.wait(0.1) -- Small delay to ensure tool is equipped
        else
            warn("[equipTool] Failed to equip:", err)
        end
    end
end

-- Unequip Tool Function
local function unequipTool(tool)
    if tool then
        local success, err = pcall(function()
            ReplicatedStorage:WaitForChild("RemoteEvents")
                .UnequipItemHandle:FireServer("FireAllClients", tool)
        end)
        if success then
            print("[unequipTool] Unequipped:", tool.Name)
        else
            warn("[unequipTool] Failed to unequip:", err)
        end
    end
end

-- Kill Aura Loop
local killAuraConnection
local currentKillTool = nil

local function killAuraLoop()
    if killAuraConnection then
        killAuraConnection:Disconnect()
    end
    
    local attackCount = 0
    local hasEquipped = false
    
    killAuraConnection = RunService.Heartbeat:Connect(function()
        if not AuraModule.killAuraToggle then
            if killAuraConnection then
                killAuraConnection:Disconnect()
                killAuraConnection = nil
            end
            -- Unequip when stopped
            if currentKillTool and hasEquipped then
                unequipTool(currentKillTool)
                currentKillTool = nil
                hasEquipped = false
            end
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local tool, damageID = getAnyToolWithDamageID(false)
        if not tool or not damageID then 
            print("[Kill Aura] No weapon found in inventory")
            return 
        end
        
        -- Equip tool if not equipped yet
        if not hasEquipped then
            equipTool(tool)
            currentKillTool = tool
            hasEquipped = true
            return -- Skip this frame to let tool equip
        end
        
        -- Verify tool is actually equipped in character
        if not isToolEquipped(tool.Name) then
            print("[Kill Aura] Waiting for tool to equip...")
            return
        end
        
        -- Attack all mobs in range
        for _, mob in ipairs(Workspace.Characters:GetChildren()) do
            if mob:IsA("Model") and mob ~= character then
                local part = mob:FindFirstChildWhichIsA("BasePart")
                if part then
                    local distance = (part.Position - hrp.Position).Magnitude
                    if distance <= AuraModule.auraRadius then
                        local success, err = pcall(function()
                            ReplicatedStorage:WaitForChild("RemoteEvents", 2)
                                .ToolDamageObject:InvokeServer(
                                    mob,
                                    tool,
                                    damageID,
                                    CFrame.new(part.Position)
                                )
                        end)
                        if not success then
                            warn("[Kill Aura] Error:", err)
                        else
                            attackCount = attackCount + 1
                            if attackCount % 10 == 0 then
                                print("[Kill Aura] Total attacks:", attackCount)
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Chop Aura Loop
local chopAuraConnection
local processedTrees = {}
local currentChopTool = nil

local function chopAuraLoop()
    if chopAuraConnection then
        chopAuraConnection:Disconnect()
    end
    
    local chopCount = 0
    local hasEquipped = false
    
    chopAuraConnection = RunService.Heartbeat:Connect(function()
        if not AuraModule.chopAuraToggle then
            if chopAuraConnection then
                chopAuraConnection:Disconnect()
                chopAuraConnection = nil
            end
            processedTrees = {}
            -- Unequip when stopped
            if currentChopTool and hasEquipped then
                unequipTool(currentChopTool)
                currentChopTool = nil
                hasEquipped = false
            end
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local tool, damageID = getAnyToolWithDamageID(true)
        if not tool or not damageID then 
            print("[Chop Aura] No axe found in inventory")
            return 
        end
        
        -- Equip tool if not equipped yet
        if not hasEquipped then
            equipTool(tool)
            currentChopTool = tool
            hasEquipped = true
            return -- Skip this frame to let tool equip
        end
        
        -- Verify tool is actually equipped in character
        if not isToolEquipped(tool.Name) then
            print("[Chop Aura] Waiting for tool to equip...")
            return
        end
        
        -- Collect all trees
        local trees = {}
        local map = Workspace:FindFirstChild("Map")
        
        if map then
            local foliage = map:FindFirstChild("Foliage")
            if foliage then
                for _, obj in ipairs(foliage:GetChildren()) do
                    if obj:IsA("Model") and (obj.Name == "Small Tree" or obj.Name == "Snowy Small Tree") then
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
        
        -- Attack trees in range
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
                        
                        local success, err = pcall(function()
                            ReplicatedStorage:WaitForChild("RemoteEvents", 2)
                                .ToolDamageObject:InvokeServer(
                                    tree,
                                    tool,
                                    tostring(AuraModule.currentammount) .. "_7367831688",
                                    CFrame.new(trunk.Position)
                                )
                        end)
                        if not success then
                            warn("[Chop Aura] Error:", err)
                        else
                            chopCount = chopCount + 1
                            if chopCount % 5 == 0 then
                                print("[Chop Aura] Total chops:", chopCount)
                            end
                        end
                    end
                end
            end
        end
        
        -- Clean up destroyed trees
        for tree in pairs(processedTrees) do
            if not tree or not tree.Parent then
                processedTrees[tree] = nil
            end
        end
    end)
end

-- Start Kill Aura Function
function AuraModule.StartKillAura()
    if AuraModule.killAuraToggle then return end
    AuraModule.killAuraToggle = true
    print("[Kill Aura] Started - Radius:", AuraModule.auraRadius)
    print("[Kill Aura] Will auto-equip weapon from inventory")
    killAuraLoop()
end

-- Stop Kill Aura Function
function AuraModule.StopKillAura()
    AuraModule.killAuraToggle = false
    if killAuraConnection then
        killAuraConnection:Disconnect()
        killAuraConnection = nil
    end
    if currentKillTool then
        unequipTool(currentKillTool)
        currentKillTool = nil
    end
    print("[Kill Aura] Stopped and unequipped weapon")
end

-- Start Chop Aura Function
function AuraModule.StartChopAura()
    if AuraModule.chopAuraToggle then return end
    AuraModule.chopAuraToggle = true
    AuraModule.currentammount = 0
    processedTrees = {}
    print("[Chop Aura] Started - Radius:", AuraModule.auraRadius)
    print("[Chop Aura] Will auto-equip axe from inventory")
    chopAuraLoop()
end

-- Stop Chop Aura Function
function AuraModule.StopChopAura()
    AuraModule.chopAuraToggle = false
    if chopAuraConnection then
        chopAuraConnection:Disconnect()
        chopAuraConnection = nil
    end
    processedTrees = {}
    if currentChopTool then
        unequipTool(currentChopTool)
        currentChopTool = nil
    end
    print("[Chop Aura] Stopped and unequipped axe")
end

-- Set Aura Radius Function
function AuraModule.SetAuraRadius(radius)
    AuraModule.auraRadius = math.clamp(radius, 1, 200)
    print("[Aura] Radius set to:", AuraModule.auraRadius)
end

-- Check if Kill Aura is Active
function AuraModule.IsKillAuraActive()
    return AuraModule.killAuraToggle
end

-- Check if Chop Aura is Active
function AuraModule.IsChopAuraActive()
    return AuraModule.chopAuraToggle
end

-- Stop All Auras
function AuraModule.StopAllAuras()
    AuraModule.StopKillAura()
    AuraModule.StopChopAura()
end

return AuraModule
