-- DEX NOTIFIER GUI (Visual Only) - FINAL
-- Recriado por Manus

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DexNotifier"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
MainFrame.Size = UDim2.new(0, 500, 0, 300)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false -- Start hidden

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(80, 50, 150)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Close/Open Button (DF) - Movable and on the left
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -20) -- Position on the left side
ToggleButton.Size = UDim2.new(0, 40, 0, 40) -- Square button
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "DF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 18
ToggleButton.BorderSizePixel = 0

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(80, 50, 150)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleButton

local toggleButtonDragging
local toggleButtonDragInput
local toggleButtonDragStart
local toggleButtonStartPos

local function updateToggleButtonPosition(input)
    local delta = input.Position - toggleButtonDragStart
    ToggleButton.Position = UDim2.new(toggleButtonStartPos.X.Scale, toggleButtonStartPos.X.Offset + delta.X, toggleButtonStartPos.Y.Scale, toggleButtonStartPos.Y.Offset + delta.Y)
end

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleButtonDragging = true
        toggleButtonDragStart = input.Position
        toggleButtonStartPos = ToggleButton.Position
        
        input.Changed:Connect(function()  
            if input.UserInputState == Enum.UserInputState.End then  
                toggleButtonDragging = false  
            end  
        end)  
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        toggleButtonDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == toggleButtonDragInput and toggleButtonDragging then
        updateToggleButtonPosition(input)
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BorderSizePixel = 0

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = Sidebar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 10)
Title.Size = UDim2.new(1, -20, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.Text = "DEX NOTIFIER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Parent = Sidebar
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 10, 0, 30)
Status.Size = UDim2.new(1, -20, 0, 15)
Status.Font = Enum.Font.Gotham
Status.Text = "● Connected"
Status.TextColor3 = Color3.fromRGB(0, 255, 100)
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left

local NavButtons = Instance.new("Frame")
NavButtons.Name = "NavButtons"
NavButtons.Parent = Sidebar
NavButtons.BackgroundTransparency = 1
NavButtons.Position = UDim2.new(0, 10, 0, 60)
NavButtons.Size = UDim2.new(1, -20, 1, -110)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = NavButtons
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Parent = MainFrame
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0, 130, 0, 10)
ContentArea.Size = UDim2.new(1, -140, 1, -20)

local currentActiveTab = "Logs"

local function createTabContent(tabName)
    local frame = Instance.new("Frame")
    frame.Name = tabName .. "ContentFrame"
    frame.Parent = ContentArea
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Visible = (tabName == currentActiveTab)
    return frame
end

local LogsContentFrame = createTabContent("Logs")
local HistoryContentFrame = createTabContent("History")
local UsersContentFrame = createTabContent("Users")
local SettingsContentFrame = createTabContent("Settings")

local function switchTab(tabName)
    -- Hide all content frames first
    LogsContentFrame.Visible = false
    HistoryContentFrame.Visible = false
    UsersContentFrame.Visible = false
    SettingsContentFrame.Visible = false

    local targetFrame
    if tabName == "Logs" then
        targetFrame = LogsContentFrame
    elseif tabName == "History" then
        targetFrame = HistoryContentFrame
    elseif tabName == "Users" then
        targetFrame = UsersContentFrame
    elseif tabName == "Settings" then
        targetFrame = SettingsContentFrame
    end

    if targetFrame then
        -- Create and show loading screen inside the target frame
        local loadingFrame = Instance.new("Frame")
        loadingFrame.Name = "LoadingScreen"
        loadingFrame.Parent = targetFrame
        loadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        loadingFrame.BackgroundTransparency = 0.5
        loadingFrame.Size = UDim2.new(1, 0, 1, 0)
        loadingFrame.ZIndex = 5 -- Ensure it's above other content but below UI elements

        local loadingLabel = Instance.new("TextLabel")
        loadingLabel.Parent = loadingFrame
        loadingLabel.BackgroundTransparency = 1
        loadingLabel.Size = UDim2.new(1, 0, 1, 0)
        loadingLabel.Font = Enum.Font.GothamBold
        loadingLabel.Text = "LOADING..."
        loadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadingLabel.TextSize = 24
        loadingLabel.TextXAlignment = Enum.TextXAlignment.Center
        loadingLabel.TextYAlignment = Enum.TextYAlignment.Center

        targetFrame.Visible = true -- Make target frame visible to show loading screen
        currentActiveTab = tabName

        -- Simulate loading time
        task.wait(0.5)

        loadingFrame:Destroy() -- Remove loading screen
    end
end

local function createNavBtn(name)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = NavButtons
    btn.BackgroundColor3 = (name == currentActiveTab) and Color3.fromRGB(40, 30, 80) or Color3.fromRGB(20, 20, 25)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Font = Enum.Font.GothamMedium
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.AutoButtonColor = true

    local c = Instance.new("UICorner")  
    c.CornerRadius = UDim.new(0, 8)  
    c.Parent = btn  
      
    if not (name == currentActiveTab) then  
        local s = Instance.new("UIStroke")  
        s.Color = Color3.fromRGB(40, 40, 50)  
        s.Thickness = 1  
        s.Parent = btn  
    end

    btn.MouseButton1Click:Connect(function()
        for i, v in pairs(NavButtons:GetChildren()) do
            if v:IsA("TextButton") then
                v.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                if not v:FindFirstChildOfClass("UIStroke") then
                    local s = Instance.new("UIStroke")
                    s.Color = Color3.fromRGB(40, 40, 50)
                    s.Thickness = 1
                    s.Parent = v
                end
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(40, 30, 80)
        if btn:FindFirstChildOfClass("UIStroke") then
            btn:FindFirstChildOfClass("UIStroke"):Destroy()
        end
        switchTab(name)
    end)

    return btn
end

createNavBtn("Logs")
createNavBtn("History")
createNavBtn("Users")
createNavBtn("Settings")

local HideUI = Instance.new("TextButton")
HideUI.Name = "HideUI"
HideUI.Parent = Sidebar
HideUI.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
HideUI.Position = UDim2.new(0, 10, 1, -40)
HideUI.Size = UDim2.new(1, -20, 0, 30)
HideUI.Font = Enum.Font.GothamMedium
HideUI.Text = "Hide UI"
HideUI.TextColor3 = Color3.fromRGB(200, 200, 200)
HideUI.TextSize = 12
local HideCorner = Instance.new("UICorner")
HideCorner.CornerRadius = UDim.new(0, 8)
HideCorner.Parent = HideUI

HideUI.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Logs Tab Content (Toggles, TopBar, LogsContainer)
local Toggles = Instance.new("Frame")
Toggles.Name = "Toggles"
Toggles.Parent = LogsContentFrame
Toggles.BackgroundTransparency = 1
Toggles.Position = UDim2.new(0, 10, 0, 0) -- Adjusted position
Toggles.Size = UDim2.new(1, -20, 0, 40)
Toggles.ZIndex = 2 -- Ensure toggles are visible

local function createToggle(name, xOffset, initialState)
    local label = Instance.new("TextLabel")
    label.Parent = Toggles
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, xOffset, 0, 0)
    label.Size = UDim2.new(0, 80, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local bg = Instance.new("Frame")  
    bg.Parent = Toggles  
    bg.BackgroundColor3 = initialState and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 50) -- Initial state color (azul quando ativo)
    bg.Position = UDim2.new(0, xOffset + 70, 0, 10)  
    bg.Size = UDim2.new(0, 40, 0, 20)  
    local bc = Instance.new("UICorner")  
    bc.CornerRadius = UDim.new(1, 0)  
    bc.Parent = bg  
      
    local circle = Instance.new("Frame")  
    circle.Parent = bg  
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  
    circle.Position = initialState and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2) -- Initial state position
    circle.Size = UDim2.new(0, 16, 0, 16)  
    local cc = Instance.new("UICorner")  
    cc.CornerRadius = UDim.new(1, 0)  
    cc.Parent = circle

    local active = initialState

    bg.MouseButton1Click:Connect(function()
        active = not active
        if active then
            bg.BackgroundColor3 = Color3.fromRGB(0, 120, 255) -- Azul quando ativo
            circle:TweenPosition(UDim2.new(1, -18, 0, 2), "Out", "Quad", 0.2, true)
        else
            bg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            circle:TweenPosition(UDim2.new(0, 2, 0, 2), "Out", "Quad", 0.2, true)
        end
    end)
end

createToggle("Auto-Join", 0, false) -- Start desativado
createToggle("Auto-Force", 90, false) -- Start desativado, ajustado para ficar ao lado do Auto-Join

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = LogsContentFrame
TopBar.BackgroundTransparency = 1
TopBar.Position = UDim2.new(0, 0, 0, 50)
TopBar.Size = UDim2.new(1, 0, 0, 20)

local LiveFeedLabel = Instance.new("TextLabel")
LiveFeedLabel.Parent = TopBar
LiveFeedLabel.BackgroundTransparency = 1
LiveFeedLabel.Size = UDim2.new(0, 80, 1, 0)
LiveFeedLabel.Font = Enum.Font.GothamBold
LiveFeedLabel.Text = "LIVE FEED"
LiveFeedLabel.TextColor3 = Color3.fromRGB(80, 60, 150)
LiveFeedLabel.TextSize = 14
LiveFeedLabel.TextXAlignment = Enum.TextXAlignment.Left

local DetectedLabel = Instance.new("TextLabel")
DetectedLabel.Parent = TopBar
DetectedLabel.BackgroundTransparency = 1
DetectedLabel.Position = UDim2.new(1, -120, 0, 0)
DetectedLabel.Size = UDim2.new(0, 80, 1, 0)
DetectedLabel.Font = Enum.Font.Gotham
DetectedLabel.Text = "2 detected"
DetectedLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
DetectedLabel.TextSize = 12
DetectedLabel.TextXAlignment = Enum.TextXAlignment.Right

local ClearButton = Instance.new("TextButton")
ClearButton.Parent = TopBar
ClearButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
ClearButton.Position = UDim2.new(1, -35, 0, 0)
ClearButton.Size = UDim2.new(0, 35, 1, 0)
ClearButton.Font = Enum.Font.GothamBold
ClearButton.Text = "Clear"
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearButton.TextSize = 10
local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 4)
ClearCorner.Parent = ClearButton

local LogsContainer = Instance.new("ScrollingFrame")
LogsContainer.Name = "LogsContainer"
LogsContainer.Parent = LogsContentFrame
LogsContainer.BackgroundTransparency = 1
LogsContainer.Position = UDim2.new(0, 0, 0, 80)
LogsContainer.Size = UDim2.new(1, 0, 1, -80)
LogsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
LogsContainer.ScrollBarThickness = 2

local LogsLayout = Instance.new("UIListLayout")
LogsLayout.Parent = LogsContainer
LogsLayout.Padding = UDim.new(0, 10)
LogsLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function showFakeNotification()
    local notification = Instance.new("ScreenGui")
    notification.Name = "FakeNotification"
    notification.Parent = PlayerGui
    notification.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Parent = notification
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.Position = UDim2.new(0, 10, 0.5, -25) -- Left side
    frame.Size = UDim2.new(0, 250, 0, 50)
    frame.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = "We were unable to enter. Please wait 2 minutes."
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left

    frame:TweenPosition(UDim2.new(0, 10, 0.5, -25), "Out", "Quad", 0.5, true)

    Debris:AddItem(notification, 3) -- Notification disappears after 3 seconds
end

local function createLogItem(name, value)
    local item = Instance.new("Frame")
    item.Name = "LogItem"
    item.Parent = LogsContainer
    item.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    item.Size = UDim2.new(1, -5, 0, 60)
    
    local ic = Instance.new("UICorner")  
    ic.CornerRadius = UDim.new(0, 8)  
    ic.Parent = item  
      
    local is = Instance.new("UIStroke")  
    is.Color = Color3.fromRGB(45, 45, 60)  
    is.Thickness = 1  
    is.Parent = item  
      
    local bar = Instance.new("Frame")  
    bar.Parent = item  
    bar.BackgroundColor3 = Color3.fromRGB(100, 50, 255)  
    bar.Position = UDim2.new(0, 18, 0.2, 0)  -- Adjusted position to accommodate yellow button
    bar.Size = UDim2.new(0, 3, 0.6, 0)  
    local bc = Instance.new("UICorner")  
    bc.CornerRadius = UDim.new(1, 0)  
    bc.Parent = bar  
      
    local title = Instance.new("TextLabel")  
    title.Parent = item  
    title.BackgroundTransparency = 1  
    title.Position = UDim2.new(0, 30, 0, 10) -- Adjusted position  
    title.Size = UDim2.new(0, 200, 0, 20)  
    title.Font = Enum.Font.GothamBold  
    title.Text = name  
    title.TextColor3 = Color3.fromRGB(150, 100, 255)  
    title.TextSize = 14  
    title.TextXAlignment = Enum.TextXAlignment.Left  
      
    local desc = Instance.new("TextLabel")  
    desc.Parent = item  
    desc.BackgroundTransparency = 1  
    desc.Position = UDim2.new(0, 30, 0, 30) -- Adjusted position  
    desc.Size = UDim2.new(0, 200, 0, 20)  
    desc.Font = Enum.Font.Gotham  
    desc.Text = value .. " • Players: 4"  
    desc.TextColor3 = Color3.fromRGB(180, 180, 200)  
    desc.TextSize = 12  
    desc.TextXAlignment = Enum.TextXAlignment.Left  
      
    local join = Instance.new("TextButton")  
    join.Parent = item  
    join.BackgroundColor3 = Color3.fromRGB(40, 30, 100)  
    join.Position = UDim2.new(1, -110, 0.5, -12)  
    join.Size = UDim2.new(0, 50, 0, 24)  
    join.Font = Enum.Font.GothamBold  
    join.Text = "JOIN"  
    join.TextColor3 = Color3.fromRGB(255, 255, 255)  
    join.TextSize = 10  
    local jc = Instance.new("UICorner")  
    jc.CornerRadius = UDim.new(0, 6)  
    jc.Parent = join  
      
    local force = Instance.new("TextButton")  
    force.Parent = item  
    force.BackgroundColor3 = Color3.fromRGB(180, 100, 20)  
    force.Position = UDim2.new(1, -55, 0.5, -12)  
    force.Size = UDim2.new(0, 50, 0, 24)  
    force.Font = Enum.Font.GothamBold  
    force.Text = "FORCE"  
    force.TextColor3 = Color3.fromRGB(255, 255, 255)  
    force.TextSize = 10  
    local fc = Instance.new("UICorner")  
    fc.CornerRadius = UDim.new(0, 6)  
    fc.Parent = force

    local yellowButton = Instance.new("TextButton")
    yellowButton.Parent = item
    yellowButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0) -- Yellow color
    yellowButton.Position = UDim2.new(0, 5, 0.5, -12) -- Position to the left of the log item
    yellowButton.Size = UDim2.new(0, 10, 0, 24) -- Small yellow button
    yellowButton.Font = Enum.Font.GothamBold
    yellowButton.Text = ""
    yellowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    yellowButton.TextSize = 10
    local ybc = Instance.new("UICorner")
    ybc.CornerRadius = UDim.new(0, 6)
    ybc.Parent = yellowButton

    join.MouseButton1Click:Connect(showFakeNotification)
    force.MouseButton1Click:Connect(showFakeNotification)
end

-- Brainrot data for fixed logs
local brainrotData = {
    {name = "LA SECRET COMBINATION", value = "550M/s"},
    {name = "LA GINGER", value = "470M/s"},
    {name = "GARAMA AND MADUNDUNG", value = "50M/s"},
}

local maxLogs = 3 -- Only 3 logs as requested

local function addFixedLogs()
    for i = 1, maxLogs do
        if brainrotData[i] then
            createLogItem(brainrotData[i].name, brainrotData[i].value)
        end
    end
    LogsContainer.CanvasSize = UDim2.new(0, 0, 0, LogsLayout.AbsoluteContentSize.Y)
end

-- Initial logs
addFixedLogs()

-- Clear button functionality
ClearButton.MouseButton1Click:Connect(function()
    for i, child in ipairs(LogsContainer:GetChildren()) do
        if child:IsA("Frame") and child.Name == "LogItem" then
            child:Destroy()
        end
    end
    LogsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    addFixedLogs() -- Re-add fixed logs after clearing
end)

-- History Tab Content
local HistoryLabel = Instance.new("TextLabel")
HistoryLabel.Parent = HistoryContentFrame
HistoryLabel.BackgroundTransparency = 1
HistoryLabel.Size = UDim2.new(1, 0, 1, 0)
HistoryLabel.Font = Enum.Font.GothamBold
HistoryLabel.Text = "History is empty."
HistoryLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
HistoryLabel.TextSize = 18
HistoryLabel.TextWrapped = true
HistoryLabel.TextXAlignment = Enum.TextXAlignment.Center
HistoryLabel.TextYAlignment = Enum.TextYAlignment.Center

-- Users Tab Content
local UsersContainer = Instance.new("ScrollingFrame")
UsersContainer.Name = "UsersContainer"
UsersContainer.Parent = UsersContentFrame
UsersContainer.BackgroundTransparency = 1
UsersContainer.Size = UDim2.new(1, 0, 1, 0)
UsersContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
UsersContainer.ScrollBarThickness = 2

local UsersLayout = Instance.new("UIListLayout")
UsersLayout.Parent = UsersContainer
UsersLayout.Padding = UDim.new(0, 5)
UsersLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function createPlayerItem(playerName, avatarUrl)
    local item = Instance.new("Frame")
    item.Name = "PlayerItem"
    item.Parent = UsersContainer
    item.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    item.Size = UDim2.new(1, -5, 0, 50)

    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(0, 8)
    ic.Parent = item

    local is = Instance.new("UIStroke")
    is.Color = Color3.fromRGB(45, 45, 60)
    is.Thickness = 1
    is.Parent = item

    local avatar = Instance.new("ImageLabel")
    avatar.Parent = item
    avatar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    avatar.Size = UDim2.new(0, 40, 0, 40)
    avatar.Position = UDim2.new(0, 5, 0, 5)
    avatar.Image = avatarUrl
    avatar.BorderSizePixel = 0

    local ac = Instance.new("UICorner")
    ac.CornerRadius = UDim.new(1, 0)
    ac.Parent = avatar

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = item
    nameLabel.BackgroundTransparency = 1
    nameLabel.Position = UDim2.new(0, 55, 0, 0)
    nameLabel.Size = UDim2.new(1, -60, 1, 0)
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.Text = playerName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextYAlignment = Enum.TextYAlignment.Center

    local emptyLabel = Instance.new("TextLabel")
    emptyLabel.Parent = nameLabel
    emptyLabel.BackgroundTransparency = 1
    emptyLabel.Position = UDim2.new(1, -50, 0, 0)
    emptyLabel.Size = UDim2.new(0, 50, 1, 0)
    emptyLabel.Font = Enum.Font.Gotham
    emptyLabel.Text = "(empty)"
    emptyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    emptyLabel.TextSize = 12
    emptyLabel.TextXAlignment = Enum.TextXAlignment.Right
    emptyLabel.TextYAlignment = Enum.TextYAlignment.Center

    -- Make the emptyLabel visible only if the player is 'empty' or similar
    if playerName == "Guest_User" or playerName == "(empty)" then
        emptyLabel.Visible = true
    else
        emptyLabel.Visible = false
    end
end

-- Fake player data (using a generic Roblox avatar asset ID for visual representation)
local fakePlayers = {
    {name = "Player123", avatar = "rbxassetid://214300600"},
    {name = "NoobMaster69", avatar = "rbxassetid://214300600"},
    {name = "RobloxianPro", avatar = "rbxassetid://214300600"},
    {name = "Guest_User", avatar = "rbxassetid://214300600"},
    {name = "BuilderMan", avatar = "rbxassetid://214300600"},
    {name = "ScriptKiddie", avatar = "rbxassetid://214300600"},
    {name = "Admin_Bot", avatar = "rbxassetid://214300600"},
    {name = "CoolGamer", avatar = "rbxassetid://214300600"},
    {name = "ProHacker", avatar = "rbxassetid://214300600"},
    {name = "EpicPlayer", avatar = "rbxassetid://214300600"},
    {name = "LegendaryDev", avatar = "rbxassetid://214300600"},
    {name = "MasterBuilder", avatar = "rbxassetid://214300600"},
}

for i, player in ipairs(fakePlayers) do
    createPlayerItem(player.name, player.avatar)
end

UsersContainer.CanvasSize = UDim2.new(0, 0, 0, UsersLayout.AbsoluteContentSize.Y)

-- Settings Tab Content
local SettingsLabel = Instance.new("TextLabel")
SettingsLabel.Parent = SettingsContentFrame
SettingsLabel.BackgroundTransparency = 1
SettingsLabel.Size = UDim2.new(1, 0, 1, 0)
SettingsLabel.Font = Enum.Font.GothamBold
SettingsLabel.Text = "No settings available."
SettingsLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
SettingsLabel.TextSize = 18
SettingsLabel.TextWrapped = true
SettingsLabel.TextXAlignment = Enum.TextXAlignment.Center
SettingsLabel.TextYAlignment = Enum.TextYAlignment.Center

-- Dragging Functionality for MainFrame
local gui = MainFrame

local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

gui.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = gui.Position
        
        input.Changed:Connect(function()  
            if input.UserInputState == Enum.UserInputState.End then  
                dragging = false  
            end  
        end)  
    end
end)

gui.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
