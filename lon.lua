--[[
    SPEAR FISHING - PERFECT AURA FARM (PROFESSIONAL TABBED GUI)
    - Reverted Local Nearest Farm to Global WorldSea Check
    - Added Player Aura Farm (Nearest to Target)
    - Auto Chest (Tween Speed x2) & ResFishData Require
    - Added Auto Sell Fish (with Keep Mutation Filters)
    - Added Auto Skill
    - Added Speed 100
]]

local PLAYER = game.Players.LocalPlayer
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local FIRE_RE = REPLICATED_STORAGE:WaitForChild("Remotes"):WaitForChild("FireRE")
local FishRE = REPLICATED_STORAGE:WaitForChild("Remotes"):WaitForChild("FishRE")
local TWEEN_SERVICE = game:GetService("TweenService")

-- Tự động lấy Data Cá từ Config của game
local ResFishData = {}
pcall(function()
    local configFolder = REPLICATED_STORAGE:WaitForChild("Config", 5)
    if configFolder then
        local resFishModule = configFolder:WaitForChild("ResFish", 5)
        if resFishModule then
            ResFishData = require(resFishModule)
        end
    end
end)

-- ==========================================
-- GIAO DIỆN (GUI) - THIẾT KẾ CHUYÊN NGHIỆP TẠO THEO DẠNG TAB
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
ScreenGui.Parent = success and coreGui or PLAYER:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 450, 0, 400)
MainFrame.Position = UDim2.new(0.5, -225, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true 

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Header.BorderSizePixel = 0
local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 10)
-- Sửa lại góc dưới của Header vuông vức cho liền mạch
local HeaderFix = Instance.new("Frame", Header)
HeaderFix.Size = UDim2.new(1, 0, 0, 10)
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
HeaderFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🐟 FISHING HUB PRO"
Title.TextColor3 = Color3.fromRGB(0, 200, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Nút Thu Nhỏ / Đóng
local MinimizeBtn = Instance.new("TextButton", Header)
MinimizeBtn.Size = UDim2.new(0, 40, 1, 0)
MinimizeBtn.Position = UDim2.new(1, -80, 0, 0)
MinimizeBtn.Text = "-"
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20

local CloseGUIBtn = Instance.new("TextButton", Header)
CloseGUIBtn.Size = UDim2.new(0, 40, 1, 0)
CloseGUIBtn.Position = UDim2.new(1, -40, 0, 0)
CloseGUIBtn.Text = "X"
CloseGUIBtn.BackgroundTransparency = 1
CloseGUIBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseGUIBtn.Font = Enum.Font.GothamBold
CloseGUIBtn.TextSize = 16

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    MainFrame.Size = isMinimized and UDim2.new(0, 450, 0, 40) or UDim2.new(0, 450, 0, 400)
end)

-- Thanh Tab Container
local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(1, 0, 0, 35)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabContainer.BorderSizePixel = 0

local TabListLayout = Instance.new("UIListLayout", TabContainer)
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Content Container
local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, 0, 1, -75)
ContentContainer.Position = UDim2.new(0, 0, 0, 75)
ContentContainer.BackgroundTransparency = 1

-- Hàm tạo Tab
local tabs = {}
local frames = {}

local function createTab(name, order)
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(0.25, 0, 1, 0) -- Đã chỉnh thành 0.25 để chia đều 4 Tab
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 12
    TabBtn.BackgroundColor3 = order == 1 and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(35, 35, 35)
    TabBtn.TextColor3 = order == 1 and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(150, 150, 150)
    TabBtn.BorderSizePixel = 0
    TabBtn.LayoutOrder = order

    local PageFrame = Instance.new("ScrollingFrame", ContentContainer)
    PageFrame.Size = UDim2.new(1, -20, 1, -10)
    PageFrame.Position = UDim2.new(0, 10, 0, 5)
    PageFrame.BackgroundTransparency = 1
    PageFrame.ScrollBarThickness = 4
    PageFrame.Visible = order == 1
    PageFrame.BorderSizePixel = 0
    
    local PageLayout = Instance.new("UIListLayout", PageFrame)
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    table.insert(tabs, TabBtn)
    table.insert(frames, PageFrame)

    TabBtn.MouseButton1Click:Connect(function()
        for i, t in ipairs(tabs) do
            t.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            t.TextColor3 = Color3.fromRGB(150, 150, 150)
            frames[i].Visible = false
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        TabBtn.TextColor3 = Color3.fromRGB(0, 200, 150)
        PageFrame.Visible = true
    end)

    return PageFrame
end

local MainTab = createTab("MAIN", 1)
local FilterTab = createTab("FILTERS", 2)
local PlayerTab = createTab("PLAYER", 3)
local BossTrackerTab = createTab("BOSS", 4) -- Tab thứ 4 chứa Boss Tracker

-- Hàm tạo Nút Toggle Chuẩn
local function createToggle(parent, text)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.Text = text .. ": OFF"
    Btn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    return Btn
end

-- ================= TAB 1: MAIN FARM =================
local currentWeapon = "Harpoon"
local WeaponBtn = Instance.new("TextButton", MainTab)
WeaponBtn.Size = UDim2.new(1, 0, 0, 35)
WeaponBtn.Text = "WEAPON: HARPOON"
WeaponBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
WeaponBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
WeaponBtn.Font = Enum.Font.GothamBold
WeaponBtn.TextSize = 13
Instance.new("UICorner", WeaponBtn).CornerRadius = UDim.new(0, 6)
WeaponBtn.LayoutOrder = 1

WeaponBtn.MouseButton1Click:Connect(function()
    currentWeapon = currentWeapon == "Harpoon" and "Gun" or "Harpoon"
    WeaponBtn.Text = "WEAPON: " .. string.upper(currentWeapon)
end)

local ToggleBtn = createToggle(MainTab, "AURA (NEAREST)")
local HPFarmBtn = createToggle(MainTab, "AURA (MAX HP)")
local LowestHPFarmBtn = createToggle(MainTab, "AURA (MIN HP)")
local BossBtn = createToggle(MainTab, "BOSS FARM")
local ChestBtn = createToggle(MainTab, "AUTO CHEST (TWEEN)")
local AutoSkillBtn = createToggle(MainTab, "AUTO SKILL")
local SpeedBtn = createToggle(MainTab, "SPEED 100")
MainTab.CanvasSize = UDim2.new(0, 0, 0, 350)

-- ================= TAB 2: FILTERS =================
local MutationFarmBtn = createToggle(FilterTab, "MUTATION FARM")
local MutationListFrame = Instance.new("Frame", FilterTab)
MutationListFrame.Size = UDim2.new(1, 0, 0, 80)
MutationListFrame.BackgroundTransparency = 1
local UIGridLayoutMut = Instance.new("UIGridLayout", MutationListFrame)
UIGridLayoutMut.CellSize = UDim2.new(0.31, 0, 0, 25)
UIGridLayoutMut.CellPadding = UDim2.new(0.03, 0, 0, 5)

local activeMutations = { Marsh = false, Iceborne = false, Rain = false, Snow = false, Big = false, Iris = false, Valentine = false }
local mutationNames = {"Marsh", "Iceborne", "Rain", "Snow", "Big", "Iris", "Valentine"}

for _, mutName in ipairs(mutationNames) do
    local btn = Instance.new("TextButton", MutationListFrame)
    btn.Text = mutName
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        activeMutations[mutName] = not activeMutations[mutName]
        btn.BackgroundColor3 = activeMutations[mutName] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 80)
    end)
end

local RarityFarmBtn = createToggle(FilterTab, "RARITY FARM")
local RarityListFrame = Instance.new("Frame", FilterTab)
RarityListFrame.Size = UDim2.new(1, 0, 0, 80)
RarityListFrame.BackgroundTransparency = 1
local RarityGridLayout = Instance.new("UIGridLayout", RarityListFrame)
RarityGridLayout.CellSize = UDim2.new(0.22, 0, 0, 25)
RarityGridLayout.CellPadding = UDim2.new(0.04, 0, 0, 5)

local activeRarities = {["1"]=false, ["2"]=false, ["3"]=false, ["4"]=false, ["5"]=false, ["6"]=false, ["7"]=false, ["8"]=false}
for i = 1, 8 do
    local rName = tostring(i)
    local btn = Instance.new("TextButton", RarityListFrame)
    btn.Text = "Rarity " .. rName
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        activeRarities[rName] = not activeRarities[rName]
        btn.BackgroundColor3 = activeRarities[rName] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 80)
    end)
end

-- ================= AUTO SELL VỚI KEEP MUTATION FILTER =================
local AutoSellBtn = createToggle(FilterTab, "AUTO SELL FISH")
local KeepMutationListFrame = Instance.new("Frame", FilterTab)
KeepMutationListFrame.Size = UDim2.new(1, 0, 0, 80)
KeepMutationListFrame.BackgroundTransparency = 1
local KeepMutGridLayout = Instance.new("UIGridLayout", KeepMutationListFrame)
KeepMutGridLayout.CellSize = UDim2.new(0.31, 0, 0, 25)
KeepMutGridLayout.CellPadding = UDim2.new(0.03, 0, 0, 5)

local keepMutations = { Marsh = false, Iceborne = false, Rain = false, Snow = false, Big = false, Iris = false, Valentine = false }

for _, mutName in ipairs(mutationNames) do
    local btn = Instance.new("TextButton", KeepMutationListFrame)
    btn.Text = mutName
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        keepMutations[mutName] = not keepMutations[mutName]
        btn.BackgroundColor3 = keepMutations[mutName] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 80)
    end)
end

-- ================= NO MUTATION FARM (MỚI THÊM VÀO FILTER) =================
local NoMutationFarmBtn = createToggle(FilterTab, "NO MUTATION FARM")
local NoMutConfigFrame = Instance.new("Frame", FilterTab)
NoMutConfigFrame.Size = UDim2.new(1, 0, 0, 110)
NoMutConfigFrame.BackgroundTransparency = 1
local NoMutGridLayout = Instance.new("UIGridLayout", NoMutConfigFrame)
NoMutGridLayout.CellSize = UDim2.new(0.31, 0, 0, 25)
NoMutGridLayout.CellPadding = UDim2.new(0.03, 0, 0, 5)

local noMutFarmState = {Near = false, Global = false, ["1"]=false, ["2"]=false, ["3"]=false, ["4"]=false, ["5"]=false, ["6"]=false, ["7"]=false, ["8"]=false}
local noMutBtnNames = {"Near", "Global", "1", "2", "3", "4", "5", "6", "7", "8"}

for _, btnName in ipairs(noMutBtnNames) do
    local btn = Instance.new("TextButton", NoMutConfigFrame)
    btn.Text = (btnName == "Near" or btnName == "Global") and string.upper(btnName) or "Rarity " .. btnName
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        -- Ràng buộc: Chọn Global thì tắt Near và ngược lại
        if btnName == "Near" and not noMutFarmState["Near"] then
            noMutFarmState["Global"] = false
        elseif btnName == "Global" and not noMutFarmState["Global"] then
            noMutFarmState["Near"] = false
        end
        
        noMutFarmState[btnName] = not noMutFarmState[btnName]
        
        for _, child in ipairs(NoMutConfigFrame:GetChildren()) do
            if child:IsA("TextButton") then
                local n = child.Text:gsub("Rarity ", "")
                if n == "NEAR" then n = "Near" end
                if n == "GLOBAL" then n = "Global" end
                child.BackgroundColor3 = noMutFarmState[n] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 80)
            end
        end
    end)
end

FilterTab.CanvasSize = UDim2.new(0, 0, 0, 550)

-- ================= TAB 3: PLAYER FARM =================
local PlayerBoxFarmBtn = createToggle(PlayerTab, "PLAYER FARM (FRONT BOX)")
local PlayerAuraFarmBtn = createToggle(PlayerTab, "PLAYER FARM (AURA AROUND)")

local RefreshPlayerBtn = Instance.new("TextButton", PlayerTab)
RefreshPlayerBtn.Size = UDim2.new(1, 0, 0, 30)
RefreshPlayerBtn.Text = "🔄 REFRESH PLAYER LIST"
RefreshPlayerBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
RefreshPlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshPlayerBtn.Font = Enum.Font.GothamBold
RefreshPlayerBtn.TextSize = 12
Instance.new("UICorner", RefreshPlayerBtn).CornerRadius = UDim.new(0, 6)

local PlayerGridFrame = Instance.new("Frame", PlayerTab)
PlayerGridFrame.Size = UDim2.new(1, 0, 0, 200)
PlayerGridFrame.BackgroundTransparency = 1
local PlayerGridLayout = Instance.new("UIGridLayout", PlayerGridFrame)
PlayerGridLayout.CellSize = UDim2.new(0.48, 0, 0, 25)
PlayerGridLayout.CellPadding = UDim2.new(0.04, 0, 0, 5)

local targetPlayerName = nil

local function refreshPlayers()
    for _, child in pairs(PlayerGridFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= PLAYER then
            local btn = Instance.new("TextButton", PlayerGridFrame)
            btn.Text = p.Name
            btn.BackgroundColor3 = (targetPlayerName == p.Name) and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 80)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 10
            btn.TextScaled = true
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            
            btn.MouseButton1Click:Connect(function()
                targetPlayerName = p.Name
                for _, c in pairs(PlayerGridFrame:GetChildren()) do
                    if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(80, 80, 80) end
                end
                btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            end)
        end
    end
    -- Calculate canvas height dynamically
    local count = #game.Players:GetPlayers() - 1
    PlayerTab.CanvasSize = UDim2.new(0, 0, 0, 150 + (math.ceil(count/2) * 30))
end
RefreshPlayerBtn.MouseButton1Click:Connect(refreshPlayers)
refreshPlayers()

-- ================= LOGIC XỬ LÝ NÚT BẤM =================
local farming = false
local hpFarming = false
local lowestHPFarming = false
local bossFarming = false
local collectChests = false
local mutationFarming = false
local playerBoxFarming = false
local playerAuraFarming = false
local rarityFarming = false
local noMutationFarming = false -- Biến cờ No Mutation Farm
local autoSelling = false
local autoSkilling = false
local speedEnabled = false
local runLoop = true

local function handleToggle(btn, stateVar, name)
    btn.MouseButton1Click:Connect(function()
        if name == "AURA (NEAREST)" then farming = not farming; stateVar = farming
        elseif name == "AURA (MAX HP)" then hpFarming = not hpFarming; stateVar = hpFarming
        elseif name == "AURA (MIN HP)" then lowestHPFarming = not lowestHPFarming; stateVar = lowestHPFarming
        elseif name == "BOSS FARM" then bossFarming = not bossFarming; stateVar = bossFarming
        elseif name == "AUTO CHEST (TWEEN)" then collectChests = not collectChests; stateVar = collectChests
        elseif name == "MUTATION FARM" then mutationFarming = not mutationFarming; stateVar = mutationFarming
        elseif name == "PLAYER FARM (FRONT BOX)" then playerBoxFarming = not playerBoxFarming; stateVar = playerBoxFarming
        elseif name == "PLAYER FARM (AURA AROUND)" then playerAuraFarming = not playerAuraFarming; stateVar = playerAuraFarming
        elseif name == "RARITY FARM" then rarityFarming = not rarityFarming; stateVar = rarityFarming
        elseif name == "NO MUTATION FARM" then noMutationFarming = not noMutationFarming; stateVar = noMutationFarming
        elseif name == "AUTO SELL FISH" then autoSelling = not autoSelling; stateVar = autoSelling
        elseif name == "AUTO SKILL" then autoSkilling = not autoSkilling; stateVar = autoSkilling
        elseif name == "SPEED 100" then speedEnabled = not speedEnabled; stateVar = speedEnabled
        end
        btn.Text = name .. (stateVar and ": ON" or ": OFF")
        btn.BackgroundColor3 = stateVar and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(255, 60, 60)
    end)
end

handleToggle(ToggleBtn, farming, "AURA (NEAREST)")
handleToggle(HPFarmBtn, hpFarming, "AURA (MAX HP)")
handleToggle(LowestHPFarmBtn, lowestHPFarming, "AURA (MIN HP)")
handleToggle(BossBtn, bossFarming, "BOSS FARM")
handleToggle(ChestBtn, collectChests, "AUTO CHEST (TWEEN)")
handleToggle(MutationFarmBtn, mutationFarming, "MUTATION FARM")
handleToggle(PlayerBoxFarmBtn, playerBoxFarming, "PLAYER FARM (FRONT BOX)")
handleToggle(PlayerAuraFarmBtn, playerAuraFarming, "PLAYER FARM (AURA AROUND)")
handleToggle(RarityFarmBtn, rarityFarming, "RARITY FARM")
handleToggle(NoMutationFarmBtn, noMutationFarming, "NO MUTATION FARM")
handleToggle(AutoSellBtn, autoSelling, "AUTO SELL FISH")
handleToggle(AutoSkillBtn, autoSkilling, "AUTO SKILL")
handleToggle(SpeedBtn, speedEnabled, "SPEED 100")

CloseGUIBtn.MouseButton1Click:Connect(function()
    farming = false; hpFarming = false; lowestHPFarming = false; bossFarming = false;
    collectChests = false; mutationFarming = false; playerBoxFarming = false; 
    playerAuraFarming = false; rarityFarming = false; noMutationFarming = false; autoSelling = false;
    autoSkilling = false; speedEnabled = false; runLoop = false
    ScreenGui:Destroy()
end)

-- ==========================================
-- CÁC HÀM QUÉT MỤC TIÊU
-- ==========================================

-- Đã khôi phục Farm Gần (Nearest) quét WorldSea thông thường (Không dùng Sphere nữa)
local function getNearestFish()
    local char = PLAYER.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearest, minDist = nil, math.huge
    local worldSea = workspace:FindFirstChild("WorldSea")
    
    if worldSea then
        for _, sea in pairs(worldSea:GetChildren()) do
            for _, fish in pairs(sea:GetChildren()) do
                if fish:IsA("Model") or fish:IsA("BasePart") then
                    local curHP = fish:GetAttribute("CurHP") or 1 
                    if curHP > 0 then
                        local part = fish:IsA("Model") and (fish.PrimaryPart or fish:FindFirstChildWhichIsA("BasePart")) or fish
                        if part then
                            local d = (hrp.Position - part.Position).Magnitude
                            if d < minDist then
                                nearest = fish
                                minDist = d
                            end
                        end
                    end
                end
            end
        end
    end
    return nearest
end

local function getHighestHPFish()
    local highestHPFish, maxFoundHP = nil, -1
    local worldSea = workspace:FindFirstChild("WorldSea")
    if worldSea then
        for _, sea in pairs(worldSea:GetChildren()) do
            for _, fish in pairs(sea:GetChildren()) do
                if fish:IsA("Model") or fish:IsA("BasePart") then
                    local hp = fish:GetAttribute("HP") or 0
                    local curHP = fish:GetAttribute("CurHP") or hp
                    if curHP > 0 and hp > maxFoundHP then
                        maxFoundHP = hp
                        highestHPFish = fish
                    end
                end
            end
        end
    end
    return highestHPFish
end

local function getLowestHPFish()
    local lowestHPFish, minFoundHP = nil, math.huge
    local worldSea = workspace:FindFirstChild("WorldSea")
    if worldSea then
        for _, sea in pairs(worldSea:GetChildren()) do
            for _, fish in pairs(sea:GetChildren()) do
                if fish:IsA("Model") or fish:IsA("BasePart") then
                    local hp = fish:GetAttribute("HP") or 0
                    local curHP = fish:GetAttribute("CurHP") or hp
                    if curHP > 0 and hp < minFoundHP and hp > 0 then
                        minFoundHP = hp
                        lowestHPFish = fish
                    end
                end
            end
        end
    end
    return lowestHPFish
end

local function getNearestMutationFish()
    local char = PLAYER.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest, minDist = nil, math.huge
    local worldSea = workspace:FindFirstChild("WorldSea")
    
    if worldSea then
        for _, sea in pairs(worldSea:GetChildren()) do
            for _, fish in pairs(sea:GetChildren()) do
                if fish:IsA("Model") or fish:IsA("BasePart") then
                    local mut = fish:GetAttribute("Mutation")
                    if mut and activeMutations[mut] then
                        local curHP = fish:GetAttribute("CurHP") or 1
                        if curHP > 0 then
                            local part = fish:IsA("Model") and (fish.PrimaryPart or fish:FindFirstChildWhichIsA("BasePart")) or fish
                            if part then
                                local d = (hrp.Position - part.Position).Magnitude
                                if d < minDist then nearest = fish; minDist = d end
                            end
                        end
                    end
                end
            end
        end
    end
    return nearest
end

-- Chế độ 1: Player Farm (Hộp không gian phía trước)
local function getPlayerFishByBox()
    if not targetPlayerName then return nil end
    local targetPlayer = game.Players:FindFirstChild(targetPlayerName)
    if not targetPlayer then return nil end
    local char = targetPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearestFish, minDist = nil, math.huge
    local worldSea = workspace:FindFirstChild("WorldSea")
    if not worldSea then return nil end
    
    local boxSize = Vector3.new(20, 60, 100)
    local boxCFrame = hrp.CFrame * CFrame.new(0, 7, -50)
    
    local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Include
    overlapParams.FilterDescendantsInstances = {worldSea}
    
    local partsInBox = workspace:GetPartBoundsInBox(boxCFrame, boxSize, overlapParams)
    local checkedModels = {}
    
    for _, hitPart in ipairs(partsInBox) do
        local fishModel = hitPart
        while fishModel and fishModel ~= workspace do
            if fishModel:GetAttribute("CurHP") or fishModel:GetAttribute("isFish") or (fishModel.Parent and fishModel.Parent.Name:match("Sea%d+")) then break end
            fishModel = fishModel.Parent
        end
        
        if fishModel and fishModel ~= workspace and not checkedModels[fishModel] then
            checkedModels[fishModel] = true
            local curHP = fishModel:GetAttribute("CurHP") or 1
            if curHP > 0 then
                local part = fishModel:IsA("Model") and (fishModel.PrimaryPart or fishModel:FindFirstChildWhichIsA("BasePart")) or fishModel
                if part then
                    local d = (hrp.Position - part.Position).Magnitude
                    if d < minDist then minDist = d; nearestFish = fishModel end
                end
            end
        end
    end
    return nearestFish
end

-- Chế độ 2: Player Farm (Quét cá xung quanh mục tiêu - Aura)
local function getPlayerFishByAura()
    if not targetPlayerName then return nil end
    local targetPlayer = game.Players:FindFirstChild(targetPlayerName)
    if not targetPlayer then return nil end
    local char = targetPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearest, minDist = nil, math.huge
    local worldSea = workspace:FindFirstChild("WorldSea")
    
    if worldSea then
        for _, sea in pairs(worldSea:GetChildren()) do
            for _, fish in pairs(sea:GetChildren()) do
                if fish:IsA("Model") or fish:IsA("BasePart") then
                    local curHP = fish:GetAttribute("CurHP") or 1 
                    if curHP > 0 then
                        local part = fish:IsA("Model") and (fish.PrimaryPart or fish:FindFirstChildWhichIsA("BasePart")) or fish
                        if part then
                            -- Lấy tâm là HRP của thằng mục tiêu chứ đéo phải của mình
                            local d = (hrp.Position - part.Position).Magnitude
                            if d < minDist then
                                nearest = fish
                                minDist = d
                            end
                        end
                    end
                end
            end
        end
    end
    return nearest
end

-- Rarity Farm (Cập nhật Ưu tiên Rarity cao nhất, sau đó mới đến Distance)
local function getNearestRarityFish()
    local char = PLAYER.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local bestFish = nil
    local bestRarity = -1
    local minDist = math.huge
    local worldSea = workspace:FindFirstChild("WorldSea")
    
    if worldSea then
        for _, sea in pairs(worldSea:GetChildren()) do
            for _, fish in pairs(sea:GetChildren()) do
                if fish:IsA("Model") or fish:IsA("BasePart") then
                    local fishData = ResFishData[fish.Name]
                    if fishData and fishData.Rarity then
                        local r = tostring(fishData.Rarity)
                        if activeRarities[r] then
                            local curHP = fish:GetAttribute("CurHP") or 1
                            if curHP > 0 then
                                local part = fish:IsA("Model") and (fish.PrimaryPart or fish:FindFirstChildWhichIsA("BasePart")) or fish
                                if part then
                                    local d = (hrp.Position - part.Position).Magnitude
                                    local rNum = tonumber(fishData.Rarity) or 0
                                    
                                    -- Logic ưu tiên: Rarity cao > Rarity thấp, Cùng Rarity > Gần hơn
                                    if rNum > bestRarity then
                                        bestRarity = rNum
                                        minDist = d
                                        bestFish = fish
                                    elseif rNum == bestRarity then
                                        if d < minDist then
                                            minDist = d
                                            bestFish = fish
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bestFish
end

-- Farm không có Mutation (Với 10 tùy chỉnh Near/Global/Rarity)
local function getNoMutationFish()
    local char = PLAYER.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local bestFish = nil
    local bestRarity = -1
    local minDist = math.huge
    local worldSea = workspace:FindFirstChild("WorldSea")
    
    if worldSea then
        for _, sea in pairs(worldSea:GetChildren()) do
            for _, fish in pairs(sea:GetChildren()) do
                if fish:IsA("Model") or fish:IsA("BasePart") then
                    local mut = fish:GetAttribute("Mutation")
                    -- Chỉ farm những con KHÔNG có mutation
                    if not mut or mut == "" then
                        local fishData = ResFishData[fish.Name]
                        if fishData and fishData.Rarity then
                            local rStr = tostring(fishData.Rarity)
                            -- Nếu Rarity đó được bật trong config 8 nút
                            if noMutFarmState[rStr] then
                                local curHP = fish:GetAttribute("CurHP") or 1
                                if curHP > 0 then
                                    local part = fish:IsA("Model") and (fish.PrimaryPart or fish:FindFirstChildWhichIsA("BasePart")) or fish
                                    if part then
                                        local d = (hrp.Position - part.Position).Magnitude
                                        
                                        local isValidDist = true
                                        if noMutFarmState["Near"] and d > 200 then
                                            isValidDist = false -- Giới hạn Near là 200 studs
                                        end
                                        
                                        if isValidDist then
                                            local rNum = tonumber(fishData.Rarity) or 0
                                            -- Logic ưu tiên: Rarity cao > Rarity thấp, Cùng Rarity > Gần hơn
                                            if rNum > bestRarity then
                                                bestRarity = rNum
                                                minDist = d
                                                bestFish = fish
                                            elseif rNum == bestRarity then
                                                if d < minDist then
                                                    minDist = d
                                                    bestFish = fish
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bestFish
end

local function getNearestBoss()
    local char = PLAYER.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest, minDist = nil, math.huge
    local worldBoss = workspace:FindFirstChild("WorldBoss")
    
    if worldBoss then
        for _, point in pairs(worldBoss:GetChildren()) do
            for _, boss in pairs(point:GetChildren()) do
                if boss:IsA("Model") or boss:IsA("BasePart") then
                    local part = boss:IsA("Model") and (boss.PrimaryPart or boss:FindFirstChildWhichIsA("BasePart")) or boss
                    if part then
                        local d = (hrp.Position - part.Position).Magnitude
                        if d < minDist then nearest = boss; minDist = d end
                    end
                end
            end
        end
    end
    return nearest
end

local function getWeapon()
    local char = PLAYER.Character
    if char then
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Tool") and v.Name:find(currentWeapon) then return v end
        end
    end
    return nil
end

local currentLockedHPFish = nil
local currentLockedLowestHPFish = nil
local currentLockedMutationFish = nil
local currentLockedRarityFish = nil
local currentLockedNoMutFish = nil

-- ==========================================
-- LUỒNG CHẠY (LOOPS)
-- ==========================================

-- Loop Auto Chest độc lập (Tween Speed x2 - Đã chỉnh lên x2: dist / 200)
task.spawn(function()
    while task.wait(0.2) do
        if not runLoop then break end
        if collectChests then
            local char = PLAYER.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Name == "Chest" and collectChests and runLoop then
                        local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj:IsA("BasePart") and obj or nil
                        if targetPart then
                            local dist = (hrp.Position - targetPart.Position).Magnitude
                            local timeToMove = dist / 200 -- SPEED x2
                            local tweenInfo = TweenInfo.new(timeToMove, Enum.EasingStyle.Linear)
                            local tween = TWEEN_SERVICE:Create(hrp, tweenInfo, {CFrame = targetPart.CFrame})
                            tween:Play()
                            tween.Completed:Wait()
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
    end
end)

-- Loop Aura Farm
task.spawn(function()
    while task.wait(0.05) do
        if not runLoop then break end
        
        local weapon = getWeapon()
        
        if farming and weapon then
            local targetFish = getNearestFish()
            if targetFish then
                local targetPart = targetFish:IsA("Model") and (targetFish.PrimaryPart or targetFish:FindFirstChildWhichIsA("BasePart")) or targetFish
                if targetPart then
                    FIRE_RE:FireServer("Hit", { fishInstance = targetFish, HitPos = targetPart.Position, toolInstance = weapon })
                end
            end
        end
        
        if hpFarming and weapon then
            if not currentLockedHPFish or not currentLockedHPFish.Parent or (currentLockedHPFish:GetAttribute("CurHP") and currentLockedHPFish:GetAttribute("CurHP") <= 0) then
                currentLockedHPFish = getHighestHPFish()
            end
            if currentLockedHPFish then
                local targetPart = currentLockedHPFish:IsA("Model") and (currentLockedHPFish.PrimaryPart or currentLockedHPFish:FindFirstChildWhichIsA("BasePart")) or currentLockedHPFish
                if targetPart then
                    FIRE_RE:FireServer("Hit", { fishInstance = currentLockedHPFish, HitPos = targetPart.Position, toolInstance = weapon })
                end
            end
        end
        
        if lowestHPFarming and weapon then
            if not currentLockedLowestHPFish or not currentLockedLowestHPFish.Parent or (currentLockedLowestHPFish:GetAttribute("CurHP") and currentLockedLowestHPFish:GetAttribute("CurHP") <= 0) then
                currentLockedLowestHPFish = getLowestHPFish()
            end
            if currentLockedLowestHPFish then
                local targetPart = currentLockedLowestHPFish:IsA("Model") and (currentLockedLowestHPFish.PrimaryPart or currentLockedLowestHPFish:FindFirstChildWhichIsA("BasePart")) or currentLockedLowestHPFish
                if targetPart then
                    FIRE_RE:FireServer("Hit", { fishInstance = currentLockedLowestHPFish, HitPos = targetPart.Position, toolInstance = weapon })
                end
            end
        end
        
        if mutationFarming and weapon then
            if not currentLockedMutationFish or not currentLockedMutationFish.Parent or (currentLockedMutationFish:GetAttribute("CurHP") and currentLockedMutationFish:GetAttribute("CurHP") <= 0) then
                currentLockedMutationFish = getNearestMutationFish()
            end
            if currentLockedMutationFish then
                local targetPart = currentLockedMutationFish:IsA("Model") and (currentLockedMutationFish.PrimaryPart or currentLockedMutationFish:FindFirstChildWhichIsA("BasePart")) or currentLockedMutationFish
                if targetPart then
                    FIRE_RE:FireServer("Hit", { fishInstance = currentLockedMutationFish, HitPos = targetPart.Position, toolInstance = weapon })
                end
            end
        end

        if playerBoxFarming and weapon and targetPlayerName then
            local targetFish = getPlayerFishByBox()
            if targetFish then
                local targetPart = targetFish:IsA("Model") and (targetFish.PrimaryPart or targetFish:FindFirstChildWhichIsA("BasePart")) or targetFish
                if targetPart then
                    local args = { "Hit", { fishInstance = targetFish, HitPos = targetPart.Position, toolInstance = weapon } }
                    FIRE_RE:FireServer(unpack(args))
                    FIRE_RE:FireServer(unpack(args))
                end
            end
        end

        if playerAuraFarming and weapon and targetPlayerName then
            local targetFish = getPlayerFishByAura()
            if targetFish then
                local targetPart = targetFish:IsA("Model") and (targetFish.PrimaryPart or targetFish:FindFirstChildWhichIsA("BasePart")) or targetFish
                if targetPart then
                    local args = { "Hit", { fishInstance = targetFish, HitPos = targetPart.Position, toolInstance = weapon } }
                    FIRE_RE:FireServer(unpack(args))
                    FIRE_RE:FireServer(unpack(args))
                end
            end
        end

        if rarityFarming and weapon then
            if not currentLockedRarityFish or not currentLockedRarityFish.Parent or (currentLockedRarityFish:GetAttribute("CurHP") and currentLockedRarityFish:GetAttribute("CurHP") <= 0) then
                currentLockedRarityFish = getNearestRarityFish()
            end
            if currentLockedRarityFish then
                local targetPart = currentLockedRarityFish:IsA("Model") and (currentLockedRarityFish.PrimaryPart or currentLockedRarityFish:FindFirstChildWhichIsA("BasePart")) or currentLockedRarityFish
                if targetPart then
                    FIRE_RE:FireServer("Hit", { fishInstance = currentLockedRarityFish, HitPos = targetPart.Position, toolInstance = weapon })
                end
            end
        end
        
        if noMutationFarming and weapon then
            if not currentLockedNoMutFish or not currentLockedNoMutFish.Parent or (currentLockedNoMutFish:GetAttribute("CurHP") and currentLockedNoMutFish:GetAttribute("CurHP") <= 0) then
                currentLockedNoMutFish = getNoMutationFish()
            end
            if currentLockedNoMutFish then
                local targetPart = currentLockedNoMutFish:IsA("Model") and (currentLockedNoMutFish.PrimaryPart or currentLockedNoMutFish:FindFirstChildWhichIsA("BasePart")) or currentLockedNoMutFish
                if targetPart then
                    FIRE_RE:FireServer("Hit", { fishInstance = currentLockedNoMutFish, HitPos = targetPart.Position, toolInstance = weapon })
                end
            end
        end
        
        if bossFarming and weapon then
            local targetBoss = getNearestBoss()
            if targetBoss then
                local targetPart = targetBoss:IsA("Model") and (targetBoss.PrimaryPart or targetBoss:FindFirstChildWhichIsA("BasePart")) or targetBoss
                if targetPart then
                    FIRE_RE:FireServer("Hit", { fishInstance = targetBoss, HitPos = targetPart.Position, toolInstance = weapon })
                end
            end
        end
        
    end
end)

-- Loop Auto Sell Fish
task.spawn(function()
    while task.wait(10) do
        if not runLoop then break end
        if autoSelling then
            local uidsToSell = {}
            local dataFolder = PLAYER.PlayerGui:FindFirstChild("Data")
            local fishFolder = dataFolder and dataFolder:FindFirstChild("Fish")
            
            if fishFolder then
                for _, fishObj in ipairs(fishFolder:GetChildren()) do
                    local uid = fishObj:GetAttribute("UID")
                    local isLocked = fishObj:GetAttribute("Lock")
                    local mutation = fishObj:GetAttribute("Mutation") -- Lấy thuộc tính Mutation
                    
                    if uid and not isLocked then
                        if mutation and mutation ~= "" and keepMutations[mutation] then
                            -- Không bán cá có đột biến đang chọn giữ lại
                        else
                            table.insert(uidsToSell, uid)
                        end
                    end
                end
            end
            
            if #uidsToSell > 0 then
                pcall(function()
                    FishRE:FireServer("SellAll", {
                        UIDs = uidsToSell
                    })
                end)
            end
        end
    end
end)

-- Loop Auto Skill
task.spawn(function()
    while task.wait(0.1) do
        if not runLoop then break end
        if autoSkilling then
            local playerGui = PLAYER:FindFirstChild("PlayerGui")
            local dataFolder = playerGui and playerGui:FindFirstChild("Data")
            local skillEquippedObj = dataFolder and dataFolder:FindFirstChild("SkillEquipped")
            
            if skillEquippedObj then
                local equippedSkills = skillEquippedObj:GetAttributes()
                
                for slotIndex, skillID in pairs(equippedSkills) do
                    if type(skillID) == "string" and skillID ~= "" then
                        local cooldown = PLAYER:GetAttribute(skillID .. "Cooldown") or 0
                        
                        if type(cooldown) == "number" and cooldown <= 0 then
                            pcall(function()
                                FishRE:FireServer("Skill", {
                                    ID = skillID
                                })
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- Loop Speed 100
task.spawn(function()
    while task.wait(0.1) do
        if not runLoop then break end
        if speedEnabled then
            local char = PLAYER.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 100
            end
        end
    end
end)

-- ================= TAB 4: BOSS TRACKER (MỚI THÊM) =================
local WorldBoss = workspace:WaitForChild("WorldBoss", 10)
local bossFrames = {}
local bossSpawnTimes = {}

if WorldBoss then
    task.spawn(function()
        while task.wait(1) do
            if not runLoop then break end
            
            local activeCount = 0
            
            for i, point in ipairs(WorldBoss:GetChildren()) do
                local pointName = point.Name
                local hasBoss = point:GetAttribute("HasBoss")
                local remainTime = point:GetAttribute("RemainTime") or 0
                local nextBossId = point:GetAttribute("NextBossId") or pointName
                
                if not bossFrames[pointName] then
                    local bFrame = Instance.new("Frame", BossTrackerTab)
                    bFrame.Size = UDim2.new(1, 0, 0, 40)
                    bFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    Instance.new("UICorner", bFrame).CornerRadius = UDim.new(0, 6)
                    
                    local bText = Instance.new("TextLabel", bFrame)
                    bText.Size = UDim2.new(1, -10, 1, 0)
                    bText.Position = UDim2.new(0, 5, 0, 0)
                    bText.BackgroundTransparency = 1
                    bText.Font = Enum.Font.GothamSemibold
                    bText.TextSize = 14
                    bText.TextXAlignment = Enum.TextXAlignment.Left
                    
                    bossFrames[pointName] = {Frame = bFrame, Label = bText}
                end
                
                local label = bossFrames[pointName].Label
                if hasBoss then
                    if not bossSpawnTimes[pointName] then
                        bossSpawnTimes[pointName] = os.time()
                    end
                    local timeAlive = os.time() - bossSpawnTimes[pointName]
                    local m = math.floor(timeAlive / 60)
                    local s = math.floor(timeAlive % 60)
                    
                    label.Text = string.format("[⚔️ ĐANG XUẤT HIỆN] %s (%02d:%02d)", nextBossId, m, s)
                    label.TextColor3 = Color3.fromRGB(0, 255, 127)
                else
                    bossSpawnTimes[pointName] = nil
                    local m = math.floor(remainTime / 60)
                    local s = math.floor(remainTime % 60)
                    
                    label.Text = string.format("[⏳] %s ra sau: %02d:%02d", nextBossId, m, s)
                    label.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
                
                activeCount = activeCount + 1
            end
            
            BossTrackerTab.CanvasSize = UDim2.new(0, 0, 0, activeCount * 45)
        end
    end)
end

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Aura Farm Pro (All in 1)",
    Text = "Đã gộp thành công Auto Sell, Auto Skill & Speed 100",
    Duration = 5
})


