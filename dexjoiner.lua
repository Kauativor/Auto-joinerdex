local FIREBASE_URL = "..."

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local GuiName = "MobyNotifierGui"

for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == GuiName then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GuiName
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local ClickSound = Instance.new("Sound", ScreenGui)
ClickSound.SoundId = "rbxassetid://75311202481026"
ClickSound.Volume = 0.3
local function playClick() pcall(function() ClickSound:Play() end) end

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local TARGET_SCALE = isMobile and 0.8 or 1.0
local HIDE_SCALE = TARGET_SCALE - 0.15

local Frame = Instance.new("CanvasGroup", ScreenGui)
Frame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.5, -303, 0.5, -182)
Frame.Size = UDim2.new(0, 606, 0, 365)
Frame.Active = true
Frame.GroupTransparency = 1

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 9)
local UIScale = Instance.new("UIScale", Frame)
UIScale.Scale = HIDE_SCALE

TweenService:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
TweenService:Create(UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = TARGET_SCALE}):Play()

local MobyNotifier = Instance.new("TextLabel", Frame)
MobyNotifier.BackgroundTransparency = 1
MobyNotifier.Position = UDim2.new(0, 15, 0, 10)
MobyNotifier.Size = UDim2.new(0, 150, 0, 30)
MobyNotifier.Font = Enum.Font.GothamBold
MobyNotifier.Text = "Moby Notifier"
MobyNotifier.TextColor3 = Color3.fromRGB(255, 255, 255)
MobyNotifier.TextSize = 20
MobyNotifier.TextXAlignment = Enum.TextXAlignment.Left

local MobyNotifier_2 = Instance.new("TextLabel", Frame)
MobyNotifier_2.BackgroundTransparency = 1
MobyNotifier_2.Position = UDim2.new(0, 15, 0, 35)
MobyNotifier_2.Size = UDim2.new(0, 130, 0, 20)
MobyNotifier_2.Font = Enum.Font.GothamMedium
MobyNotifier_2.Text = ".gg/mobynotifier"
MobyNotifier_2.TextColor3 = Color3.fromRGB(122, 122, 122)
MobyNotifier_2.TextSize = 14
MobyNotifier_2.TextXAlignment = Enum.TextXAlignment.Left

local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local dragTweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local ContentArea = Instance.new("Frame", Frame)
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0, 160, 0, 75)
ContentArea.Size = UDim2.new(0, 420, 0, 275)

local MainPage = Instance.new("Frame", ContentArea)
MainPage.BackgroundTransparency = 1
MainPage.Size = UDim2.new(1, 0, 1, 0)

local LogScroll = Instance.new("ScrollingFrame", MainPage)
LogScroll.Active = true
LogScroll.BackgroundTransparency = 1
LogScroll.BorderSizePixel = 0
LogScroll.Size = UDim2.new(1, 0, 1, -10)
LogScroll.ScrollBarThickness = 2
LogScroll.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local LogLayout = Instance.new("UIListLayout", LogScroll)
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
LogLayout.Padding = UDim.new(0, 8)

local LogEntries = {}
local CurrentFilter = "AJ"
local RenderedIDs = {}

local function ApplyFilter()
    for _, entry in ipairs(LogEntries) do
        local v = entry.NumericValue
        if CurrentFilter == "AJ" then
            entry.UI.Visible = true
        elseif CurrentFilter == "10m+" then
            entry.UI.Visible = (v >= 10000000 and v < 50000000)
        elseif CurrentFilter == "50m+" then
            entry.UI.Visible = (v >= 50000000 and v < 100000000)
        elseif CurrentFilter == "100m+" then
            entry.UI.Visible = (v >= 100000000)
        else
            entry.UI.Visible = false
        end
    end
end

local function JoinServer(placeId, jobId)
    pcall(function() TeleportService:TeleportToPlaceInstance(tonumber(placeId), jobId, Player) end)
end

local function ForceServer(placeId, jobId)
    task.spawn(function()
        for i = 1, 50 do
            pcall(function() TeleportService:TeleportToPlaceInstance(tonumber(placeId), jobId, Player) end)
            task.wait(2.5)
        end
    end)
end

local function CreateLogNotification(dbKey, brainrotName, moneyStr, numVal, jobId, placeId)
    if RenderedIDs[dbKey] then return end
    RenderedIDs[dbKey] = true

    local LogItem = Instance.new("Frame", LogScroll)
    LogItem.BackgroundTransparency = 1
    LogItem.Size = UDim2.new(1, -10, 0, 45)

    local line = Instance.new("Frame", LogItem)
    line.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    line.BorderSizePixel = 0
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -1)

    local Left = Instance.new("Frame", LogItem)
    Left.BackgroundTransparency = 1
    Left.Size = UDim2.new(0.6, 0, 1, 0)
    Left.Position = UDim2.new(0, 5, 0, 0)

    local LL = Instance.new("UIListLayout", Left)
    LL.FillDirection = Enum.FillDirection.Horizontal
    LL.VerticalAlignment = Enum.VerticalAlignment.Center
    LL.Padding = UDim.new(0, 8)

    local Icon = Instance.new("ImageLabel", Left)
    Icon.Size = UDim2.new(0, 14, 0, 14)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://136959386531965"
    Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)

    local Name = Instance.new("TextLabel", Left)
    Name.BackgroundTransparency = 1
    Name.AutomaticSize = Enum.AutomaticSize.X
    Name.Font = Enum.Font.GothamMedium
    Name.Text = brainrotName
    Name.TextColor3 = Color3.fromRGB(200, 200, 200)
    Name.TextSize = 12

    local Money = Instance.new("TextLabel", Left)
    Money.BackgroundTransparency = 1
    Money.AutomaticSize = Enum.AutomaticSize.X
    Money.Font = Enum.Font.GothamBold
    Money.Text = moneyStr
    Money.TextColor3 = Color3.fromRGB(255, 255, 255)
    Money.TextSize = 13

    local Right = Instance.new("Frame", LogItem)
    Right.BackgroundTransparency = 1
    Right.Size = UDim2.new(0.4, 0, 1, 0)
    Right.Position = UDim2.new(0.6, -5, 0, 0)

    local RL = Instance.new("UIListLayout", Right)
    RL.FillDirection = Enum.FillDirection.Horizontal
    RL.HorizontalAlignment = Enum.HorizontalAlignment.Right
    RL.VerticalAlignment = Enum.VerticalAlignment.Center
    RL.Padding = UDim.new(0, 8)

    local jBtn = Instance.new("TextButton", Right)
    jBtn.BackgroundColor3 = Color3.fromRGB(0, 106, 255)
    jBtn.Size = UDim2.new(0, 50, 0, 26)
    jBtn.Font = Enum.Font.GothamBold
    jBtn.Text = "JOIN"
    jBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    jBtn.TextSize = 11
    Instance.new("UICorner", jBtn).CornerRadius = UDim.new(0, 6)
    jBtn.MouseEnter:Connect(function() TweenService:Create(jBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(30, 130, 255)}):Play() end)
    jBtn.MouseLeave:Connect(function() TweenService:Create(jBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(0, 106, 255)}):Play() end)
    jBtn.MouseButton1Click:Connect(function() playClick() JoinServer(placeId, jobId) end)

    local fBtn = Instance.new("TextButton", Right)
    fBtn.BackgroundColor3 = Color3.fromRGB(0, 106, 255)
    fBtn.Size = UDim2.new(0, 60, 0, 26)
    fBtn.Font = Enum.Font.GothamBold
    fBtn.Text = "FORCE"
    fBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    fBtn.TextSize = 11
    Instance.new("UICorner", fBtn).CornerRadius = UDim.new(0, 6)
    fBtn.MouseEnter:Connect(function() TweenService:Create(fBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(30, 130, 255)}):Play() end)
    fBtn.MouseLeave:Connect(function() TweenService:Create(fBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(0, 106, 255)}):Play() end)
    fBtn.MouseButton1Click:Connect(function() playClick() ForceServer(placeId, jobId) end)

    table.insert(LogEntries, {NumericValue = numVal, UI = LogItem, PlaceId = placeId, JobId = jobId})
    ApplyFilter()
end

local CommunityPage = Instance.new("Frame", ContentArea)
CommunityPage.BackgroundTransparency = 1
CommunityPage.Size = UDim2.new(1, 0, 1, 0)
CommunityPage.Visible = false

-- TITOLO PROFILE & COMMUNITY
local ProfileTitle = Instance.new("TextLabel", CommunityPage)
ProfileTitle.BackgroundTransparency = 1
ProfileTitle.Position = UDim2.new(0, 0, 0, 0)
ProfileTitle.Size = UDim2.new(1, -20, 0, 30)
ProfileTitle.Font = Enum.Font.GothamBold
ProfileTitle.Text = "Profile & Community"
ProfileTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ProfileTitle.TextSize = 18
ProfileTitle.TextXAlignment = Enum.TextXAlignment.Left

local ProfileCard = Instance.new("Frame", CommunityPage)
ProfileCard.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
ProfileCard.Position = UDim2.new(0, 0, 0, 35)
ProfileCard.Size = UDim2.new(1, -20, 0, 80)
Instance.new("UICorner", ProfileCard).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", ProfileCard).Color = Color3.fromRGB(25, 25, 25)

local AvatarOuter = Instance.new("Frame", ProfileCard)
AvatarOuter.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
AvatarOuter.Position = UDim2.new(0, 15, 0.5, -24)
AvatarOuter.Size = UDim2.new(0, 48, 0, 48)
Instance.new("UICorner", AvatarOuter).CornerRadius = UDim.new(1, 0)

local AvatarImage = Instance.new("ImageLabel", AvatarOuter)
AvatarImage.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AvatarImage.Position = UDim2.new(0.5, 0, 0.5, 0)
AvatarImage.AnchorPoint = Vector2.new(0.5, 0.5)
AvatarImage.Size = UDim2.new(1, -2, 1, -2)
AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=".. Player.UserId .."&w=150&h=150"
Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(1, 0)

-- CONTAINER PER NOME + BADGE
local NameContainer = Instance.new("Frame", ProfileCard)
NameContainer.BackgroundTransparency = 1
NameContainer.Position = UDim2.new(0, 75, 0, 15)
NameContainer.Size = UDim2.new(0, 300, 0, 24)

local NameLayout = Instance.new("UIListLayout", NameContainer)
NameLayout.FillDirection = Enum.FillDirection.Horizontal
NameLayout.VerticalAlignment = Enum.VerticalAlignment.Center
NameLayout.Padding = UDim.new(0, 8)

local DisplayNameText = Instance.new("TextLabel", NameContainer)
DisplayNameText.BackgroundTransparency = 1
DisplayNameText.AutomaticSize = Enum.AutomaticSize.X
DisplayNameText.Size = UDim2.new(0, 0, 0, 24)
DisplayNameText.Font = Enum.Font.GothamBlack
DisplayNameText.Text = Player.DisplayName
DisplayNameText.TextColor3 = Color3.fromRGB(255, 255, 255)
DisplayNameText.TextSize = 17
DisplayNameText.TextXAlignment = Enum.TextXAlignment.Left
DisplayNameText.LayoutOrder = 1

-- BADGE BUYER
local BuyerBadge = Instance.new("Frame", NameContainer)
BuyerBadge.BackgroundColor3 = Color3.fromRGB(45, 35, 15)
BuyerBadge.Size = UDim2.new(0, 75, 0, 20)
BuyerBadge.LayoutOrder = 2
Instance.new("UICorner", BuyerBadge).CornerRadius = UDim.new(0, 4)

local BuyerStroke = Instance.new("UIStroke", BuyerBadge)
BuyerStroke.Color = Color3.fromRGB(255, 185, 50)
BuyerStroke.Thickness = 1

local BuyerText = Instance.new("TextLabel", BuyerBadge)
BuyerText.BackgroundTransparency = 1
BuyerText.Size = UDim2.new(1, 0, 1, 0)
BuyerText.Font = Enum.Font.GothamBold
BuyerText.Text = "👑 BUYER"
BuyerText.TextColor3 = Color3.fromRGB(255, 185, 50)
BuyerText.TextSize = 11

-- ANIMAZIONE GLOW PER BADGE
task.spawn(function()
    while BuyerBadge and BuyerBadge.Parent do
        TweenService:Create(BuyerStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Color3.fromRGB(255, 220, 100)}):Play()
        task.wait(1)
        TweenService:Create(BuyerStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Color3.fromRGB(255, 150, 30)}):Play()
        task.wait(1)
    end
end)

local UsernameText = Instance.new("TextLabel", ProfileCard)
UsernameText.BackgroundTransparency = 1
UsernameText.Position = UDim2.new(0, 75, 0, 42)
UsernameText.Size = UDim2.new(0, 200, 0, 15)
UsernameText.Font = Enum.Font.GothamMedium
UsernameText.Text = "@" .. Player.Name
UsernameText.TextColor3 = Color3.fromRGB(130, 130, 130)
UsernameText.TextSize = 13
UsernameText.TextXAlignment = Enum.TextXAlignment.Left

local DiscordCard = Instance.new("Frame", CommunityPage)
DiscordCard.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
DiscordCard.Position = UDim2.new(0, 0, 0, 130)
DiscordCard.Size = UDim2.new(1, -20, 0, 60)
Instance.new("UICorner", DiscordCard).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", DiscordCard).Color = Color3.fromRGB(25, 25, 25)

local DcIcon = Instance.new("ImageLabel", DiscordCard)
DcIcon.BackgroundTransparency = 1
DcIcon.Position = UDim2.new(0, 20, 0.5, -12)
DcIcon.Size = UDim2.new(0, 24, 0, 24)
DcIcon.Image = "rbxassetid://77743122983414"

local DcText = Instance.new("TextLabel", DiscordCard)
DcText.BackgroundTransparency = 1
DcText.Position = UDim2.new(0, 60, 0, 0)
DcText.Size = UDim2.new(0, 150, 1, 0)
DcText.Font = Enum.Font.GothamBold
DcText.Text = "Join our Discord"
DcText.TextColor3 = Color3.fromRGB(255, 255, 255)
DcText.TextSize = 15
DcText.TextXAlignment = Enum.TextXAlignment.Left

local CopyBtn = Instance.new("TextButton", DiscordCard)
CopyBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
CopyBtn.Position = UDim2.new(1, -85, 0.5, -14)
CopyBtn.Size = UDim2.new(0, 70, 0, 28)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.Text = "Copy"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.TextSize = 12
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 6)

CopyBtn.MouseEnter:Connect(function() TweenService:Create(CopyBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(100, 115, 255)}):Play() end)
CopyBtn.MouseLeave:Connect(function() TweenService:Create(CopyBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play() end)
CopyBtn.MouseButton1Click:Connect(function()
    playClick()
    pcall(function() setclipboard("https://discord.gg/mobynotifier") end)
    CopyBtn.Text = "Copied!"
    TweenService:Create(CopyBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(46, 204, 113)}):Play()
    task.wait(1.5)
    CopyBtn.Text = "Copy"
    TweenService:Create(CopyBtn, tweenInfo, {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
end)

local function showMainPage()
    CommunityPage.Visible = false
    MainPage.Visible = true
end

local function showProfilePage()
    MainPage.Visible = false
    CommunityPage.Visible = true
end

local TopControls = Instance.new("Frame", Frame)
TopControls.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
TopControls.AnchorPoint = Vector2.new(1, 0)
TopControls.Position = UDim2.new(1, -15, 0, 10)
TopControls.Size = UDim2.new(0, 96, 0, 30)
Instance.new("UICorner", TopControls).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", TopControls).Color = Color3.fromRGB(25, 25, 25)

local TopLayout = Instance.new("UIListLayout", TopControls)
TopLayout.FillDirection = Enum.FillDirection.Horizontal
TopLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TopLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TopLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- SETTINGS (icona ingranaggio) - PRIMO
local SettingsBtn = Instance.new("TextButton", TopControls)
SettingsBtn.Name = "Settings"
SettingsBtn.BackgroundTransparency = 1
SettingsBtn.Size = UDim2.new(0, 32, 0, 30)
SettingsBtn.Text = ""
SettingsBtn.LayoutOrder = 1

local SettingsIcon = Instance.new("ImageLabel", SettingsBtn)
SettingsIcon.BackgroundTransparency = 1
SettingsIcon.AnchorPoint = Vector2.new(0.5, 0.5)
SettingsIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
SettingsIcon.Size = UDim2.new(0, 16, 0, 16)
SettingsIcon.Image = "rbxassetid://110986349331865"
SettingsIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)

SettingsBtn.MouseEnter:Connect(function() TweenService:Create(SettingsIcon, tweenInfo, {ImageColor3 = Color3.fromRGB(180, 180, 180)}):Play() end)
SettingsBtn.MouseLeave:Connect(function() TweenService:Create(SettingsIcon, tweenInfo, {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play() end)
SettingsBtn.MouseButton1Click:Connect(function() playClick() showMainPage() end)

-- COMMUNITY (icona persone) - SECONDO
local CommunityBtn = Instance.new("TextButton", TopControls)
CommunityBtn.Name = "Community"
CommunityBtn.BackgroundTransparency = 1
CommunityBtn.Size = UDim2.new(0, 32, 0, 30)
CommunityBtn.Text = ""
CommunityBtn.LayoutOrder = 2

local CommunityIcon = Instance.new("ImageLabel", CommunityBtn)
CommunityIcon.BackgroundTransparency = 1
CommunityIcon.AnchorPoint = Vector2.new(0.5, 0.5)
CommunityIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
CommunityIcon.Size = UDim2.new(0, 16, 0, 16)
CommunityIcon.Image = "rbxassetid://116227018364238"
CommunityIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)

CommunityBtn.MouseEnter:Connect(function() TweenService:Create(CommunityIcon, tweenInfo, {ImageColor3 = Color3.fromRGB(180, 180, 180)}):Play() end)
CommunityBtn.MouseLeave:Connect(function() TweenService:Create(CommunityIcon, tweenInfo, {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play() end)
CommunityBtn.MouseButton1Click:Connect(function() playClick() showProfilePage() end)

-- CLOSE (icona X) - TERZO
local CloseBtn = Instance.new("TextButton", TopControls)
CloseBtn.Name = "Close"
CloseBtn.BackgroundTransparency = 1
CloseBtn.Size = UDim2.new(0, 32, 0, 30)
CloseBtn.Text = ""
CloseBtn.LayoutOrder = 3

local CloseIcon = Instance.new("ImageLabel", CloseBtn)
CloseIcon.BackgroundTransparency = 1
CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
CloseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
CloseIcon.Size = UDim2.new(0, 16, 0, 16)
CloseIcon.Image = "rbxassetid://119410757402001"
CloseIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)

CloseBtn.MouseEnter:Connect(function() TweenService:Create(CloseIcon, tweenInfo, {ImageColor3 = Color3.fromRGB(180, 180, 180)}):Play() end)
CloseBtn.MouseLeave:Connect(function() TweenService:Create(CloseIcon, tweenInfo, {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play() end)
CloseBtn.MouseButton1Click:Connect(function()
    playClick()
    local closeTweenScale = TweenService:Create(UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Scale = HIDE_SCALE})
    local closeTweenFade = TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {GroupTransparency = 1})
    closeTweenScale:Play()
    closeTweenFade:Play()
    closeTweenScale.Completed:Wait()
    ScreenGui:Destroy()
end)

local sidebarButtons = {}
local function createSidebarButton(text, yPos, filter, default)
    local btn = Instance.new("TextButton", Frame)
    btn.Position = UDim2.new(0, 15, 0, yPos)
    btn.Size = UDim2.new(0, 130, 0, 30)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 106, 255) or Color3.fromRGB(12, 12, 12)
    btn.Text = text
    btn.TextColor3 = default and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(122, 122, 122)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local icon = Instance.new("ImageLabel", btn)
    icon.Position = UDim2.new(0, -24, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://126446801335121"
    icon.ImageColor3 = Color3.fromRGB(255, 255, 255)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = default and Color3.fromRGB(0, 106, 255) or Color3.fromRGB(25, 25, 25)

    local padding = Instance.new("UIPadding", btn)
    padding.PaddingLeft = UDim.new(0, 30)

    local data = {Button = btn, Stroke = stroke, IsActive = default}
    table.insert(sidebarButtons, data)

    btn.MouseButton1Click:Connect(function()
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
