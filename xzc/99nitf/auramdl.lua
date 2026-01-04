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

-- Debug function to find where inventory is stored
local function debugInventoryLocation()
    print("=== DEBUGGING INVENTORY LOCATION ===")
    
    -- Check LocalPlayer children
    print("LocalPlayer children:")
    for _, child in ipairs(LocalPlayer:GetChildren()) do
        print(" -", child.Name, child.ClassName)
        if child.Name == "Inventory" or child.Name == "Backpack" then
            print("   Contents:")
            for _, item in ipairs(child:GetChildren()) do
                print("     *", item.Name, item.ClassName)
            end
        end
    end
    
    -- Check Character
    local character = LocalPlayer.Character
    if character then
        print("Character children (tools):")
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") then
                print(" - EQUIPPED:", child.Name)
            end
        end
    end
    
    print("=== END DEBUG ===")
end

-- NEW: Try multiple locations to find the tool
local function getEquippedTool()
    local character = LocalPlayer.Character
    if not character then 
        print("[getEquippedTool] No character found")
        return nil, nil 
    end
    
    -- First, check what tool is equipped in character
    local equippedToolName = nil
    for toolName, damageID in pairs(toolsDamageIDs) do
        local tool = character:FindFirstChild(toolName)
        if tool and tool:IsA("Tool") then
            equippedToolName = toolName
            print("[getEquippedTool] Found equipped tool in character:", toolName)
            
            -- Now try to find it in various inventory locations
            local invTool = nil
            
            -- Try old location: LocalPlayer.Inventory
            if LocalPlayer:FindFirstChild("Inventory") then
                invTool = LocalPlayer.Inventory:FindFirstChild(toolName)
                if invTool then
                    print("[getEquippedTool] Found in LocalPlayer.Inventory")
                    return invTool, damageID
                end
            end
            
            -- Try Backpack
            if LocalPlayer:FindFirstChild("Backpack") then
                invTool = LocalPlayer.Backpack:FindFirstChild(toolName)
                if invTool then
                    print("[getEquippedTool] Found in LocalPlayer.Backpack")
                    return invTool, damageID
                end
            end
            
            -- Try PlayerGui > Inventory
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                local invGui = playerGui:FindFirstChild("Inventory")
                if invGui then
                    invTool = invGui:FindFirstChild(toolName)
                    if invTool then
                        print("[getEquippedTool] Found in PlayerGui.Inventory")
                        return invTool, damageID
                    end
                end
            end
            
            -- If tool is equipped but not found in inventory, just use the equipped tool
            print("[getEquippedTool] Tool equipped but not found in inventory, using character tool")
            return tool, damageID
        end
    end
    
    print("[getEquippedTool] No tool equipped")
    return nil, nil
end

-- Kill Aura Loop
local killAuraConnection
local function killAuraLoop()
    if killAuraConnection then
        killAuraConnection:Disconnect()
    end
    
    killAuraConnection = RunService.Heartbeat:Connect(function()
        if not AuraModule.killAuraToggle then
            if killAuraConnection then
                killAuraConnection:Disconnect()
                killAuraConnection = nil
            end
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local tool, damageID = getEquippedTool()
        if not tool or not damageID then return end
        
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
                            print("[Kill Aura] Attacked:", mob.Name)
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

local function chopAuraLoop()
    if chopAuraConnection then
        chopAuraConnection:Disconnect()
    end
    
    chopAuraConnection = RunService.Heartbeat:Connect(function()
        if not AuraModule.chopAuraToggle then
            if chopAuraConnection then
                chopAuraConnection:Disconnect()
                chopAuraConnection = nil
            end
            processedTrees = {}
            return
        end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local tool, damageID = getEquippedTool()
        if not tool or not damageID then return end
        
        -- Check if it's an axe
        if not axeTools[tool.Name] then 
            print("[Chop Aura] Not an axe tool:", tool.Name)
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
        
        print("[Chop Aura] Found", #trees, "trees")
        
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
                            print("[Chop Aura] Chopped tree at distance:", distance)
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
    debugInventoryLocation()  -- Run debug on start
    killAuraLoop()
end

-- Stop Kill Aura Function
function AuraModule.StopKillAura()
    AuraModule.killAuraToggle = false
    if killAuraConnection then
        killAuraConnection:Disconnect()
        killAuraConnection = nil
    end
    print("[Kill Aura] Stopped")
end

-- Start Chop Aura Function
function AuraModule.StartChopAura()
    if AuraModule.chopAuraToggle then return end
    AuraModule.chopAuraToggle = true
    AuraModule.currentammount = 0
    processedTrees = {}
    print("[Chop Aura] Started - Radius:", AuraModule.auraRadius)
    debugInventoryLocation()  -- Run debug on start
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
    print("[Chop Aura] Stopped")
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

-- Export debug function for manual testing
AuraModule.DebugInventory = debugInventoryLocation

return AuraModule
