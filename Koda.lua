--[[
    ╔══════════════════════════════════════════════════════════╗
    ║              PHANTOM UI LIBRARY v1.0                     ║
    ║          Interface Premium para Roblox Scripts           ║
    ║                                                          ║
    ║  Uso:                                                    ║
    ║  local PhantomUI = loadstring(...)()                     ║
    ║  local Window = PhantomUI:CreateWindow("Titulo")         ║
    ║  local Tab = Window:CreateTab("Nome", "🎮")             ║
    ║  Tab:CreateToggle({...})                                 ║
    ║  Tab:CreateSlider({...})                                 ║
    ║  Tab:CreateButton({...})                                 ║
    ║  Tab:CreateDropdown({...})                               ║
    ║  Tab:CreateInput({...})                                  ║
    ║  Tab:CreateLabel("texto")                                ║
    ║  Tab:CreateSection("titulo")                             ║
    ║  Tab:CreateKeybind({...})                                ║
    ║  Tab:CreateColorPicker({...})                            ║
    ╚══════════════════════════════════════════════════════════╝
]]

local PhantomUI = {}
PhantomUI.__index = PhantomUI

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════
-- CONFIGURAÇÕES GLOBAIS DA LIBRARY
-- ════════════════════════════════════════════════════════════

local THEME = {
    -- Cores principais
    Primary = Color3.fromRGB(100, 80, 255),
    PrimaryDark = Color3.fromRGB(70, 55, 200),
    PrimaryLight = Color3.fromRGB(140, 120, 255),
    Accent = Color3.fromRGB(180, 120, 255),

    -- Backgrounds
    Background = Color3.fromRGB(15, 15, 25),
    BackgroundDark = Color3.fromRGB(10, 10, 18),
    BackgroundLight = Color3.fromRGB(25, 20, 45),
    BackgroundCard = Color3.fromRGB(20, 18, 35),

    -- Textos
    TextPrimary = Color3.fromRGB(230, 215, 255),
    TextSecondary = Color3.fromRGB(160, 145, 200),
    TextMuted = Color3.fromRGB(100, 90, 140),
    TextDisabled = Color3.fromRGB(70, 65, 100),

    -- Estados
    Success = Color3.fromRGB(0, 220, 100),
    Error = Color3.fromRGB(255, 70, 70),
    Warning = Color3.fromRGB(255, 180, 50),
    Info = Color3.fromRGB(80, 180, 255),

    -- Bordas
    Border = Color3.fromRGB(60, 50, 100),
    BorderLight = Color3.fromRGB(80, 70, 130),

    -- Outros
    ToggleOn = Color3.fromRGB(100, 80, 255),
    ToggleOff = Color3.fromRGB(50, 40, 70),
    SliderFill = Color3.fromRGB(100, 80, 255),
    SliderTrack = Color3.fromRGB(40, 35, 65),

    -- Fontes
    FontBold = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,
    FontRegular = Enum.Font.Gotham,

    -- Tamanhos
    CornerRadius = UDim.new(0, 10),
    CornerRadiusSmall = UDim.new(0, 8),
    CornerRadiusLarge = UDim.new(0, 16),
}

-- ════════════════════════════════════════════════════════════
-- UTILIDADES INTERNAS
-- ════════════════════════════════════════════════════════════

local function Tween(object, duration, properties, style, direction)
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(object, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or THEME.CornerRadius
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or THEME.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.5
    stroke.Parent = parent
    return stroke
end

local function CreatePadding(parent, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.Parent = parent
    return padding
end

local function RippleEffect(button, x, y)
    local ripple = Instance.new("Frame")
    ripple.Parent = button
    ripple.BackgroundColor3 = Color3.new(1, 1, 1)
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.ZIndex = button.ZIndex + 1

    local absPos = button.AbsolutePosition
    local posX = x - absPos.X
    local posY = y - absPos.Y

    ripple.Position = UDim2.new(0, posX - 5, 0, posY - 5)
    ripple.Size = UDim2.new(0, 10, 0, 10)

    CreateCorner(ripple, UDim.new(1, 0))

    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5

    Tween(ripple, 0.5, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        Position = UDim2.new(0, posX - maxSize / 2, 0, posY - maxSize / 2),
        BackgroundTransparency = 1
    })

    task.delay(0.5, function()
        if ripple then ripple:Destroy() end
    end)
end

-- ════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ════════════════════════════════════════════════════════════

local NotificationHolder = nil

local function CreateNotificationHolder(screenGui)
    if NotificationHolder then return end

    NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "Notifications"
    NotificationHolder.Parent = screenGui
    NotificationHolder.Size = UDim2.new(0, 300, 1, -20)
    NotificationHolder.Position = UDim2.new(1, -310, 0, 10)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.BorderSizePixel = 0
    NotificationHolder.ZIndex = 100

    local layout = Instance.new("UIListLayout")
    layout.Parent = NotificationHolder
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
end

-- ════════════════════════════════════════════════════════════
-- KEY SYSTEM
-- ════════════════════════════════════════════════════════════

function PhantomUI:CreateKeySystem(config)
    config = config or {}
    local keyName = config.Name or "Premium Script"
    local correctKey = config.Key or "1234"
    local subtitle = config.Subtitle or "Insira a chave para continuar"
    local onSuccess = config.OnSuccess or function() end
    local onFail = config.OnFail or function() end
    local maxAttempts = config.MaxAttempts or 0 -- 0 = infinito
    local attempts = 0

    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "PhantomUI_KeySystem"
    KeyGui.ResetOnSpawn = false
    KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    KeyGui.Parent = CoreGui

    -- Overlay escuro
    local Overlay = Instance.new("Frame")
    Overlay.Parent = KeyGui
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.35
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 10

    -- Partículas decorativas
    for i = 1, 20 do
        local dot = Instance.new("Frame")
        dot.Parent = Overlay
        dot.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
        dot.Position = UDim2.new(math.random() * 0.95, 0, math.random() * 0.95, 0)
        dot.BackgroundColor3 = THEME.Primary
        dot.BackgroundTransparency = math.random(60, 90) / 100
        dot.BorderSizePixel = 0
        dot.ZIndex = 11
        CreateCorner(dot, UDim.new(1, 0))

        task.spawn(function()
            while dot and dot.Parent do
                Tween(dot, math.random(4, 8), {
                    Position = UDim2.new(math.random() * 0.95, 0, math.random() * 0.95, 0),
                    BackgroundTransparency = math.random(50, 90) / 100
                }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.wait(math.random(4, 8))
            end
        end)
    end

    -- Card principal
    local Card = Instance.new("Frame")
    Card.Parent = Overlay
    Card.AnchorPoint = Vector2.new(0.5, 0.5)
    Card.Position = UDim2.new(0.5, 0, 0.5, 0)
    Card.Size = UDim2.new(0, 330, 0, 400)
    Card.BackgroundColor3 = THEME.BackgroundDark
    Card.BorderSizePixel = 0
    Card.ZIndex = 12
    Card.ClipsDescendants = true

    CreateCorner(Card, UDim.new(0, 20))
    local cardStroke = CreateStroke(Card, THEME.Primary, 2, 0.2)

    -- Glow no topo
    local TopGlow = Instance.new("Frame")
    TopGlow.Parent = Card
    TopGlow.Size = UDim2.new(1, 0, 0, 120)
    TopGlow.BackgroundColor3 = THEME.Primary
    TopGlow.BackgroundTransparency = 0.85
    TopGlow.BorderSizePixel = 0
    TopGlow.ZIndex = 12
    CreateCorner(TopGlow, UDim.new(0, 20))

    local topGradient = Instance.new("UIGradient")
    topGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    topGradient.Rotation = 180
    topGradient.Parent = TopGlow

    -- Ícone de cadeado
    local LockIcon = Instance.new("TextLabel")
    LockIcon.Parent = Card
    LockIcon.Size = UDim2.new(0, 70, 0, 70)
    LockIcon.Position = UDim2.new(0.5, -35, 0, 28)
    LockIcon.BackgroundColor3 = THEME.BackgroundLight
    LockIcon.Text = "🔐"
    LockIcon.TextSize = 35
    LockIcon.Font = THEME.FontBold
    LockIcon.TextColor3 = Color3.new(1, 1, 1)
    LockIcon.ZIndex = 14
    CreateCorner(LockIcon, UDim.new(1, 0))
    local lockStroke = CreateStroke(LockIcon, THEME.Primary, 2, 0.3)

    -- Pulse no ícone
    task.spawn(function()
        while LockIcon and LockIcon.Parent do
            Tween(lockStroke, 1.2, {Transparency = 0.7, Color = THEME.PrimaryLight}, Enum.EasingStyle.Sine)
            task.wait(1.2)
            Tween(lockStroke, 1.2, {Transparency = 0.2, Color = THEME.Primary}, Enum.EasingStyle.Sine)
            task.wait(1.2)
        end
    end)

    -- Título
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = Card
    TitleLabel.Size = UDim2.new(1, 0, 0, 28)
    TitleLabel.Position = UDim2.new(0, 0, 0, 110)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = keyName:upper()
    TitleLabel.TextColor3 = THEME.TextPrimary
    TitleLabel.TextSize = 20
    TitleLabel.Font = THEME.FontBold
    TitleLabel.ZIndex = 14

    -- Subtítulo
    local SubLabel = Instance.new("TextLabel")
    SubLabel.Parent = Card
    SubLabel.Size = UDim2.new(1, -40, 0, 35)
    SubLabel.Position = UDim2.new(0, 20, 0, 140)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = subtitle
    SubLabel.TextColor3 = THEME.TextMuted
    SubLabel.TextSize = 12
    SubLabel.Font = THEME.FontRegular
    SubLabel.TextWrapped = true
    SubLabel.ZIndex = 14

    -- Input container
    local InputContainer = Instance.new("Frame")
    InputContainer.Parent = Card
    InputContainer.Size = UDim2.new(1, -40, 0, 48)
    InputContainer.Position = UDim2.new(0, 20, 0, 195)
    InputContainer.BackgroundColor3 = THEME.BackgroundLight
    InputContainer.BorderSizePixel = 0
    InputContainer.ZIndex = 14
    CreateCorner(InputContainer, UDim.new(0, 12))
    local inputStroke = CreateStroke(InputContainer, THEME.Border, 1.5, 0)

    local InputIcon = Instance.new("TextLabel")
    InputIcon.Parent = InputContainer
    InputIcon.Size = UDim2.new(0, 30, 1, 0)
    InputIcon.Position = UDim2.new(0, 10, 0, 0)
    InputIcon.BackgroundTransparency = 1
    InputIcon.Text = "🔑"
    InputIcon.TextSize = 16
    InputIcon.Font = THEME.FontBold
    InputIcon.ZIndex = 15

    local KeyInput = Instance.new("TextBox")
    KeyInput.Parent = InputContainer
    KeyInput.Size = UDim2.new(1, -50, 1, 0)
    KeyInput.Position = UDim2.new(0, 45, 0, 0)
    KeyInput.BackgroundTransparency = 1
    KeyInput.Text = ""
    KeyInput.PlaceholderText = "Digite a key aqui..."
    KeyInput.PlaceholderColor3 = THEME.TextDisabled
    KeyInput.TextColor3 = THEME.TextPrimary
    KeyInput.TextSize = 14
    KeyInput.Font = THEME.FontMedium
    KeyInput.ClearTextOnFocus = false
    KeyInput.ZIndex = 15

    -- Status
    local StatusMsg = Instance.new("TextLabel")
    StatusMsg.Parent = Card
    StatusMsg.Size = UDim2.new(1, -40, 0, 18)
    StatusMsg.Position = UDim2.new(0, 20, 0, 250)
    StatusMsg.BackgroundTransparency = 1
    StatusMsg.Text = ""
    StatusMsg.TextColor3 = THEME.Error
    StatusMsg.TextSize = 11
    StatusMsg.Font = THEME.FontMedium
    StatusMsg.ZIndex = 14

    -- Tentativas label
    local AttemptsLabel = Instance.new("TextLabel")
    AttemptsLabel.Parent = Card
    AttemptsLabel.Size = UDim2.new(1, -40, 0, 15)
    AttemptsLabel.Position = UDim2.new(0, 20, 0, 268)
    AttemptsLabel.BackgroundTransparency = 1
    AttemptsLabel.Text = maxAttempts > 0 and ("Tentativas restantes: " .. maxAttempts) or ""
    AttemptsLabel.TextColor3 = THEME.TextMuted
    AttemptsLabel.TextSize = 10
    AttemptsLabel.Font = THEME.FontRegular
    AttemptsLabel.ZIndex = 14

    -- Botão confirmar
    local ConfirmBtn = Instance.new("Frame")
    ConfirmBtn.Parent = Card
    ConfirmBtn.Size = UDim2.new(1, -40, 0, 48)
    ConfirmBtn.Position = UDim2.new(0, 20, 0, 290)
    ConfirmBtn.BackgroundColor3 = THEME.Primary
    ConfirmBtn.BorderSizePixel = 0
    ConfirmBtn.ZIndex = 14
    ConfirmBtn.ClipsDescendants = true
    CreateCorner(ConfirmBtn, UDim.new(0, 12))

    local confirmGradient = Instance.new("UIGradient")
    confirmGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, THEME.PrimaryDark),
        ColorSequenceKeypoint.new(0.5, THEME.Primary),
        ColorSequenceKeypoint.new(1, THEME.PrimaryDark)
    })
    confirmGradient.Parent = ConfirmBtn

    local ConfirmText = Instance.new("TextLabel")
    ConfirmText.Parent = ConfirmBtn
    ConfirmText.Size = UDim2.new(1, 0, 1, 0)
    ConfirmText.BackgroundTransparency = 1
    ConfirmText.Text = "🔓  DESBLOQUEAR"
    ConfirmText.TextColor3 = Color3.new(1, 1, 1)
    ConfirmText.TextSize = 15
    ConfirmText.Font = THEME.FontBold
    ConfirmText.ZIndex = 15

    local ConfirmButton = Instance.new("TextButton")
    ConfirmButton.Parent = ConfirmBtn
    ConfirmButton.Size = UDim2.new(1, 0, 1, 0)
    ConfirmButton.BackgroundTransparency = 1
    ConfirmButton.Text = ""
    ConfirmButton.ZIndex = 16

    -- Footer
    local Footer = Instance.new("TextLabel")
    Footer.Parent = Card
    Footer.Size = UDim2.new(1, 0, 0, 20)
    Footer.Position = UDim2.new(0, 0, 1, -30)
    Footer.BackgroundTransparency = 1
    Footer.Text = "Phantom UI Library v1.0 • Secured"
    Footer.TextColor3 = THEME.TextDisabled
    Footer.TextSize = 10
    Footer.Font = THEME.FontRegular
    Footer.ZIndex = 14

    -- Focus animations
    KeyInput.Focused:Connect(function()
        Tween(inputStroke, 0.3, {Color = THEME.Primary, Thickness = 2})
    end)
    KeyInput.FocusLost:Connect(function()
        Tween(inputStroke, 0.3, {Color = THEME.Border, Thickness = 1.5})
    end)

    -- Hover no botão
    ConfirmButton.MouseEnter:Connect(function()
        Tween(ConfirmBtn, 0.2, {BackgroundColor3 = THEME.PrimaryLight})
    end)
    ConfirmButton.MouseLeave:Connect(function()
        Tween(ConfirmBtn, 0.2, {BackgroundColor3 = THEME.Primary})
    end)

    -- Shimmer no gradiente
    task.spawn(function()
        while confirmGradient and confirmGradient.Parent do
            Tween(confirmGradient, 2, {Offset = Vector2.new(1, 0)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(2)
            Tween(confirmGradient, 2, {Offset = Vector2.new(-1, 0)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(2)
        end
    end)

    -- Entrada animada
    Card.Size = UDim2.new(0, 0, 0, 0)
    Card.BackgroundTransparency = 1
    task.delay(0.2, function()
        Tween(Card, 0.6, {
            Size = UDim2.new(0, 330, 0, 400),
            BackgroundTransparency = 0
        }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)

    -- Shake function
    local function ShakeCard()
        local orig = Card.Position
        for i = 1, 4 do
            Tween(Card, 0.05, {Position = orig + UDim2.new(0, (i % 2 == 0) and 10 or -10, 0, 0)})
            task.wait(0.05)
        end
        Tween(Card, 0.05, {Position = orig})
    end

    -- Validação
    local function Validate()
        local input = KeyInput.Text:gsub("%s+", "")

        if input == "" then
            StatusMsg.Text = "⚠ Por favor, insira uma key!"
            StatusMsg.TextColor3 = THEME.Warning
            ShakeCard()
            return
        end

        attempts = attempts + 1

        if input == correctKey then
            StatusMsg.Text = "✅ Key válida! Carregando..."
            StatusMsg.TextColor3 = THEME.Success
            AttemptsLabel.Text = ""

            LockIcon.Text = "✅"
            Tween(LockIcon, 0.3, {BackgroundColor3 = Color3.fromRGB(20, 60, 30)})
            Tween(ConfirmBtn, 0.3, {BackgroundColor3 = THEME.Success})
            ConfirmText.Text = "✅  DESBLOQUEADO!"
            Tween(cardStroke, 0.3, {Color = THEME.Success})

            task.wait(1.2)

            Tween(Card, 0.5, {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            Tween(Overlay, 0.5, {BackgroundTransparency = 1})

            task.wait(0.6)
            KeyGui:Destroy()
            onSuccess()
        else
            StatusMsg.Text = "❌ Key incorreta!"
            StatusMsg.TextColor3 = THEME.Error

            if maxAttempts > 0 then
                local remaining = maxAttempts - attempts
                AttemptsLabel.Text = "Tentativas restantes: " .. remaining

                if remaining <= 0 then
                    StatusMsg.Text = "🚫 Tentativas esgotadas!"
                    ConfirmButton.Active = false
                    Tween(ConfirmBtn, 0.3, {BackgroundColor3 = THEME.TextDisabled})
                    ConfirmText.Text = "🚫  BLOQUEADO"
                    onFail()
                    return
                end
            end

            Tween(inputStroke, 0.2, {Color = THEME.Error})
            ShakeCard()
            task.delay(0.5, function()
                Tween(inputStroke, 0.3, {Color = THEME.Border})
            end)
        end
    end

    ConfirmButton.MouseButton1Click:Connect(function(...)
        RippleEffect(ConfirmBtn, ConfirmButton.AbsolutePosition.X + ConfirmBtn.AbsoluteSize.X / 2, ConfirmButton.AbsolutePosition.Y + ConfirmBtn.AbsoluteSize.Y / 2)
        Validate()
    end)

    KeyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then Validate() end
    end)

    return KeyGui
end

-- ════════════════════════════════════════════════════════════
-- WINDOW PRINCIPAL
-- ════════════════════════════════════════════════════════════

function PhantomUI:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Name or "Phantom UI"
    local windowSubtitle = config.Subtitle or "v1.0"
    local windowIcon = config.Icon or "👁"
    local windowSize = config.Size or UDim2.new(0, 520, 0, 400)
    local toggleKey = config.ToggleKey or Enum.KeyCode.K
    local windowVisible = true

    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PhantomUI_Main"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    CreateNotificationHolder(ScreenGui)

    -- Container principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = windowSize
    MainFrame.BackgroundColor3 = THEME.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true

    CreateCorner(MainFrame, THEME.CornerRadiusLarge)
    local mainStroke = CreateStroke(MainFrame, THEME.Primary, 1.5, 0.3)

    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Parent = MainFrame
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://7912134082"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(50, 50, 450, 450)
    Shadow.ZIndex = -1

    -- Gradient overlay
    local GradientOverlay = Instance.new("Frame")
    GradientOverlay.Parent = MainFrame
    GradientOverlay.Size = UDim2.new(1, 0, 1, 0)
    GradientOverlay.BackgroundColor3 = THEME.Primary
    GradientOverlay.BackgroundTransparency = 0.92
    GradientOverlay.BorderSizePixel = 0
    GradientOverlay.ZIndex = 0
    CreateCorner(GradientOverlay, THEME.CornerRadiusLarge)

    local bgGradient = Instance.new("UIGradient")
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 80, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 10, 40))
    })
    bgGradient.Rotation = 135
    bgGradient.Parent = GradientOverlay

    -- ════════════════════════════════════════════════════
    -- SIDEBAR (TAB LIST)
    -- ════════════════════════════════════════════════════

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.Size = UDim2.new(0, 55, 1, 0)
    Sidebar.BackgroundColor3 = THEME.BackgroundDark
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 3

    -- Apenas cantos esquerdos arredondados
    CreateCorner(Sidebar, THEME.CornerRadiusLarge)

    local SidebarFix = Instance.new("Frame")
    SidebarFix.Parent = Sidebar
    SidebarFix.Size = UDim2.new(0, 20, 1, 0)
    SidebarFix.Position = UDim2.new(1, -20, 0, 0)
    SidebarFix.BackgroundColor3 = THEME.BackgroundDark
    SidebarFix.BorderSizePixel = 0
    SidebarFix.ZIndex = 3

    -- Separador vertical
    local SidebarLine = Instance.new("Frame")
    SidebarLine.Parent = Sidebar
    SidebarLine.Size = UDim2.new(0, 1, 0.9, 0)
    SidebarLine.Position = UDim2.new(1, 0, 0.05, 0)
    SidebarLine.BackgroundColor3 = THEME.Border
    SidebarLine.BackgroundTransparency = 0.5
    SidebarLine.BorderSizePixel = 0
    SidebarLine.ZIndex = 4

    -- Sidebar icon no topo
    local SidebarIcon = Instance.new("TextLabel")
    SidebarIcon.Parent = Sidebar
    SidebarIcon.Size = UDim2.new(1, 0, 0, 45)
    SidebarIcon.Position = UDim2.new(0, 0, 0, 8)
    SidebarIcon.BackgroundTransparency = 1
    SidebarIcon.Text = windowIcon
    SidebarIcon.TextSize = 22
    SidebarIcon.Font = THEME.FontBold
    SidebarIcon.TextColor3 = THEME.Primary
    SidebarIcon.ZIndex = 4

    -- Tab buttons container
    local TabButtonContainer = Instance.new("ScrollingFrame")
    TabButtonContainer.Parent = Sidebar
    TabButtonContainer.Size = UDim2.new(1, 0, 1, -60)
    TabButtonContainer.Position = UDim2.new(0, 0, 0, 55)
    TabButtonContainer.BackgroundTransparency = 1
    TabButtonContainer.BorderSizePixel = 0
    TabButtonContainer.ScrollBarThickness = 0
    TabButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabButtonContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabButtonContainer.ZIndex = 4

    local TabBtnLayout = Instance.new("UIListLayout")
    TabBtnLayout.Parent = TabButtonContainer
    TabBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabBtnLayout.Padding = UDim.new(0, 4)
    TabBtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- ════════════════════════════════════════════════════
    -- HEADER
    -- ════════════════════════════════════════════════════

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = MainFrame
    Header.Size = UDim2.new(1, -56, 0, 50)
    Header.Position = UDim2.new(0, 56, 0, 0)
    Header.BackgroundColor3 = THEME.BackgroundDark
    Header.BackgroundTransparency = 0.3
    Header.BorderSizePixel = 0
    Header.ZIndex = 3

    -- Header bottom line
    local HeaderLine = Instance.new("Frame")
    HeaderLine.Parent = Header
    HeaderLine.Size = UDim2.new(0.9, 0, 0, 1)
    HeaderLine.Position = UDim2.new(0.05, 0, 1, 0)
    HeaderLine.BackgroundColor3 = THEME.Border
    HeaderLine.BackgroundTransparency = 0.5
    HeaderLine.BorderSizePixel = 0
    HeaderLine.ZIndex = 4

    -- Tab title (muda com a tab selecionada)
    local TabTitle = Instance.new("TextLabel")
    TabTitle.Parent = Header
    TabTitle.Size = UDim2.new(0.7, 0, 1, 0)
    TabTitle.Position = UDim2.new(0, 15, 0, 0)
    TabTitle.BackgroundTransparency = 1
    TabTitle.Text = windowTitle
    TabTitle.TextColor3 = THEME.TextPrimary
    TabTitle.TextSize = 16
    TabTitle.Font = THEME.FontBold
    TabTitle.TextXAlignment = Enum.TextXAlignment.Left
    TabTitle.ZIndex = 4

    -- Status dot no header
    local StatusDot = Instance.new("Frame")
    StatusDot.Parent = Header
    StatusDot.Size = UDim2.new(0, 8, 0, 8)
    StatusDot.Position = UDim2.new(1, -60, 0.5, -4)
    StatusDot.BackgroundColor3 = THEME.Success
    StatusDot.BorderSizePixel = 0
    StatusDot.ZIndex = 4
    CreateCorner(StatusDot, UDim.new(1, 0))

    -- Versão
    local VersionLabel = Instance.new("TextLabel")
    VersionLabel.Parent = Header
    VersionLabel.Size = UDim2.new(0, 50, 0, 20)
    VersionLabel.Position = UDim2.new(1, -50, 0.5, -10)
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Text = windowSubtitle
    VersionLabel.TextColor3 = THEME.TextMuted
    VersionLabel.TextSize = 10
    VersionLabel.Font = THEME.FontRegular
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
    VersionLabel.ZIndex = 4

    -- Pulse no StatusDot
    task.spawn(function()
        while StatusDot and StatusDot.Parent do
            Tween(StatusDot, 0.6, {
                Size = UDim2.new(0, 10, 0, 10),
                Position = UDim2.new(1, -61, 0.5, -5),
                BackgroundColor3 = Color3.fromRGB(100, 255, 150)
            }, Enum.EasingStyle.Sine)
            task.wait(1)
            Tween(StatusDot, 0.6, {
                Size = UDim2.new(0, 8, 0, 8),
                Position = UDim2.new(1, -60, 0.5, -4),
                BackgroundColor3 = THEME.Success
            }, Enum.EasingStyle.Sine)
            task.wait(1)
        end
    end)

    -- ════════════════════════════════════════════════════
    -- CONTENT AREA
    -- ════════════════════════════════════════════════════

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Parent = MainFrame
    ContentArea.Size = UDim2.new(1, -56, 1, -51)
    ContentArea.Position = UDim2.new(0, 56, 0, 51)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.ZIndex = 2

    -- ════════════════════════════════════════════════════
    -- DRAG
    -- ════════════════════════════════════════════════════

    local dragging, dragStart, startPos = false, nil, nil

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- ════════════════════════════════════════════════════
    -- TOGGLE (K)
    -- ════════════════════════════════════════════════════

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == toggleKey then
            windowVisible = not windowVisible
            if windowVisible then
                MainFrame.Visible = true
                MainFrame.Size = UDim2.new(0, windowSize.X.Offset, 0, 0)
                MainFrame.BackgroundTransparency = 1
                Tween(MainFrame, 0.4, {
                    Size = windowSize,
                    BackgroundTransparency = 0
                }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            else
                local t = Tween(MainFrame, 0.35, {
                    Size = UDim2.new(0, windowSize.X.Offset, 0, 0),
                    BackgroundTransparency = 1
                }, Enum.EasingStyle.Quart)
                t.Completed:Connect(function()
                    if not windowVisible then MainFrame.Visible = false end
                end)
            end
        end
    end)

    -- Animação de entrada
    MainFrame.Size = UDim2.new(0, windowSize.X.Offset, 0, 0)
    MainFrame.BackgroundTransparency = 1
    task.delay(0.1, function()
        Tween(MainFrame, 0.6, {
            Size = windowSize,
            BackgroundTransparency = 0
        }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)

    -- ════════════════════════════════════════════════════
    -- TAB SYSTEM
    -- ════════════════════════════════════════════════════

    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local tabIcon = tabConfig.Icon or "📁"

        local Tab = {}

        -- Tab button na sidebar
        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = TabButtonContainer
        TabBtn.Size = UDim2.new(0, 42, 0, 42)
        TabBtn.BackgroundColor3 = THEME.BackgroundLight
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = tabIcon
        TabBtn.TextSize = 18
        TabBtn.Font = THEME.FontBold
        TabBtn.TextColor3 = THEME.TextMuted
        TabBtn.BorderSizePixel = 0
        TabBtn.ZIndex = 5
        CreateCorner(TabBtn, UDim.new(0, 10))

        -- Indicador de seleção (barra lateral)
        local SelectIndicator = Instance.new("Frame")
        SelectIndicator.Parent = TabBtn
        SelectIndicator.Size = UDim2.new(0, 3, 0, 0)
        SelectIndicator.Position = UDim2.new(0, 0, 0.5, 0)
        SelectIndicator.AnchorPoint = Vector2.new(0, 0.5)
        SelectIndicator.BackgroundColor3 = THEME.Primary
        SelectIndicator.BorderSizePixel = 0
        SelectIndicator.ZIndex = 6
        CreateCorner(SelectIndicator, UDim.new(1, 0))

        -- Tooltip
        local Tooltip = Instance.new("TextLabel")
        Tooltip.Parent = TabBtn
        Tooltip.Size = UDim2.new(0, 0, 0, 24)
        Tooltip.Position = UDim2.new(1, 8, 0.5, -12)
        Tooltip.BackgroundColor3 = THEME.BackgroundLight
        Tooltip.Text = "  " .. tabName .. "  "
        Tooltip.TextColor3 = THEME.TextPrimary
        Tooltip.TextSize = 11
        Tooltip.Font = THEME.FontMedium
        Tooltip.AutomaticSize = Enum.AutomaticSize.X
        Tooltip.ZIndex = 50
        Tooltip.Visible = false
        CreateCorner(Tooltip, UDim.new(0, 6))
        CreateStroke(Tooltip, THEME.Border, 1, 0.3)

        TabBtn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, 0.2, {BackgroundTransparency = 0.5})
            end
            Tooltip.Visible = true
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, 0.2, {BackgroundTransparency = 1})
            end
            Tooltip.Visible = false
        end)

        -- Content scroll para esta tab
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = "Tab_" .. tabName
        TabContent.Parent = ContentArea
        TabContent.Size = UDim2.new(1, -16, 1, -8)
        TabContent.Position = UDim2.new(0, 8, 0, 4)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 3
        TabContent.ScrollBarImageColor3 = THEME.Primary
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabContent.Visible = false
        TabContent.ZIndex = 3

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Parent = TabContent
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 6)

        CreatePadding(TabContent, 4, 4, 4, 4)

        Tab.Content = TabContent
        Tab.Button = TabBtn
        Tab.Indicator = SelectIndicator

        -- Selecionar tab
        local function SelectTab()
            -- Deselecionar todas
            for _, t in pairs(Window.Tabs) do
                t.Content.Visible = false
                Tween(t.Button, 0.25, {BackgroundTransparency = 1, TextColor3 = THEME.TextMuted})
                Tween(t.Indicator, 0.25, {Size = UDim2.new(0, 3, 0, 0)})
            end

            -- Selecionar esta
            Window.ActiveTab = Tab
            TabContent.Visible = true
            TabTitle.Text = tabName
            Tween(TabBtn, 0.25, {BackgroundTransparency = 0.3, TextColor3 = THEME.Primary})
            Tween(SelectIndicator, 0.25, {Size = UDim2.new(0, 3, 0.6, 0)})
        end

        TabBtn.MouseButton1Click:Connect(SelectTab)

        table.insert(Window.Tabs, Tab)

        -- Se é a primeira tab, selecionar
        if #Window.Tabs == 1 then
            SelectTab()
        end

        -- ════════════════════════════════════════════════
        -- COMPONENTES DA TAB
        -- ════════════════════════════════════════════════

        -- SECTION
        function Tab:CreateSection(text)
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Parent = TabContent
            SectionLabel.Size = UDim2.new(1, 0, 0, 24)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = "  ◆  " .. text:upper()
            SectionLabel.TextColor3 = THEME.Primary
            SectionLabel.TextSize = 11
            SectionLabel.Font = THEME.FontBold
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.ZIndex = 4
            return SectionLabel
        end

        -- LABEL
        function Tab:CreateLabel(text)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Parent = TabContent
            LabelFrame.Size = UDim2.new(1, 0, 0, 32)
            LabelFrame.BackgroundColor3 = THEME.BackgroundCard
            LabelFrame.BorderSizePixel = 0
            LabelFrame.ZIndex = 3
            CreateCorner(LabelFrame, THEME.CornerRadiusSmall)

            local LabelText = Instance.new("TextLabel")
            LabelText.Parent = LabelFrame
            LabelText.Size = UDim2.new(1, -20, 1, 0)
            LabelText.Position = UDim2.new(0, 10, 0, 0)
            LabelText.BackgroundTransparency = 1
            LabelText.Text = text
            LabelText.TextColor3 = THEME.TextSecondary
            LabelText.TextSize = 12
            LabelText.Font = THEME.FontRegular
            LabelText.TextXAlignment = Enum.TextXAlignment.Left
            LabelText.ZIndex = 4

            local obj = {}
            function obj:SetText(newText)
                LabelText.Text = newText
            end
            return obj
        end

        -- TOGGLE
        function Tab:CreateToggle(cfg)
            cfg = cfg or {}
            local name = cfg.Name or "Toggle"
            local default = cfg.Default or false
            local flag = cfg.Flag or name
            local callback = cfg.Callback or function() end

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Parent = TabContent
            ToggleFrame.Size = UDim2.new(1, 0, 0, 42)
            ToggleFrame.BackgroundColor3 = THEME.BackgroundLight
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.ZIndex = 3
            CreateCorner(ToggleFrame, THEME.CornerRadius)
            CreateStroke(ToggleFrame, THEME.Border, 1, 0.5)

            local Label = Instance.new("TextLabel")
            Label.Parent = ToggleFrame
            Label.Size = UDim2.new(1, -65, 1, 0)
            Label.Position = UDim2.new(0, 14, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = THEME.TextPrimary
            Label.TextSize = 13
            Label.Font = THEME.FontMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 4

            local SwitchBG = Instance.new("Frame")
            SwitchBG.Parent = ToggleFrame
            SwitchBG.Size = UDim2.new(0, 44, 0, 22)
            SwitchBG.Position = UDim2.new(1, -56, 0.5, -11)
            SwitchBG.BackgroundColor3 = default and THEME.ToggleOn or THEME.ToggleOff
            SwitchBG.BorderSizePixel = 0
            SwitchBG.ZIndex = 4
            CreateCorner(SwitchBG, UDim.new(1, 0))

            local SwitchKnob = Instance.new("Frame")
            SwitchKnob.Parent = SwitchBG
            SwitchKnob.Size = UDim2.new(0, 18, 0, 18)
            SwitchKnob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            SwitchKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            SwitchKnob.BorderSizePixel = 0
            SwitchKnob.ZIndex = 5
            CreateCorner(SwitchKnob, UDim.new(1, 0))

            local toggled = default

            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Parent = ToggleFrame
            ToggleButton.Size = UDim2.new(1, 0, 1, 0)
            ToggleButton.BackgroundTransparency = 1
            ToggleButton.Text = ""
            ToggleButton.ZIndex = 6

            local function SetState(state, silent)
                toggled = state
                local ti = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

                if toggled then
                    TweenService:Create(SwitchKnob, ti, {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
                    TweenService:Create(SwitchBG, ti, {BackgroundColor3 = THEME.ToggleOn}):Play()
                else
                    TweenService:Create(SwitchKnob, ti, {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
                    TweenService:Create(SwitchBG, ti, {BackgroundColor3 = THEME.ToggleOff}):Play()
                end

                if not silent then callback(toggled) end
            end

            ToggleButton.MouseButton1Click:Connect(function()
                SetState(not toggled)
            end)

            if default then callback(default) end

            local obj = {}
            obj.Value = toggled
            function obj:Set(state)
                SetState(state)
                obj.Value = state
            end
            return obj
        end

        -- SLIDER
        function Tab:CreateSlider(cfg)
            cfg = cfg or {}
            local name = cfg.Name or "Slider"
            local min = cfg.Min or 0
            local max = cfg.Max or 100
            local default = cfg.Default or min
            local increment = cfg.Increment or 1
            local suffix = cfg.Suffix or ""
            local callback = cfg.Callback or function() end

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Parent = TabContent
            SliderFrame.Size = UDim2.new(1, 0, 0, 58)
            SliderFrame.BackgroundColor3 = THEME.BackgroundLight
            SliderFrame.BorderSizePixel = 0
            SliderFrame.ZIndex = 3
            CreateCorner(SliderFrame, THEME.CornerRadius)
            CreateStroke(SliderFrame, THEME.Border, 1, 0.5)

            local Label = Instance.new("TextLabel")
            Label.Parent = SliderFrame
            Label.Size = UDim2.new(1, -60, 0, 20)
            Label.Position = UDim2.new(0, 14, 0, 6)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = THEME.TextPrimary
            Label.TextSize = 13
            Label.Font = THEME.FontMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 4

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Parent = SliderFrame
            ValueLabel.Size = UDim2.new(0, 50, 0, 20)
            ValueLabel.Position = UDim2.new(1, -60, 0, 6)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(default) .. suffix
            ValueLabel.TextColor3 = THEME.Primary
            ValueLabel.TextSize = 13
            ValueLabel.Font = THEME.FontBold
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.ZIndex = 4

            local SliderTrack = Instance.new("Frame")
            SliderTrack.Parent = SliderFrame
            SliderTrack.Size = UDim2.new(1, -28, 0, 6)
            SliderTrack.Position = UDim2.new(0, 14, 0, 38)
            SliderTrack.BackgroundColor3 = THEME.SliderTrack
            SliderTrack.BorderSizePixel = 0
            SliderTrack.ZIndex = 4
            CreateCorner(SliderTrack, UDim.new(1, 0))

            local SliderFill = Instance.new("Frame")
            SliderFill.Parent = SliderTrack
            SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = THEME.SliderFill
            SliderFill.BorderSizePixel = 0
            SliderFill.ZIndex = 5
            CreateCorner(SliderFill, UDim.new(1, 0))

            local fillGrad = Instance.new("UIGradient")
            fillGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, THEME.PrimaryDark),
                ColorSequenceKeypoint.new(1, THEME.PrimaryLight)
            })
            fillGrad.Parent = SliderFill

            local SliderKnob = Instance.new("Frame")
            SliderKnob.Parent = SliderTrack
            SliderKnob.Size = UDim2.new(0, 14, 0, 14)
            SliderKnob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
            SliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            SliderKnob.BorderSizePixel = 0
            SliderKnob.ZIndex = 6
            CreateCorner(SliderKnob, UDim.new(1, 0))

            local SliderButton = Instance.new("TextButton")
            SliderButton.Parent = SliderTrack
            SliderButton.Size = UDim2.new(1, 0, 0, 24)
            SliderButton.Position = UDim2.new(0, 0, 0.5, -12)
            SliderButton.BackgroundTransparency = 1
            SliderButton.Text = ""
            SliderButton.ZIndex = 7

            local sliderDragging = false
            local currentValue = default

            local function UpdateSlider(input)
                local trackPos = SliderTrack.AbsolutePosition.X
                local trackSize = SliderTrack.AbsoluteSize.X
                local rel = math.clamp((input.Position.X - trackPos) / trackSize, 0, 1)

                local raw = min + (max - min) * rel
                local value = math.floor(raw / increment + 0.5) * increment
                value = math.clamp(value, min, max)

                local newRel = (value - min) / (max - min)
                currentValue = value

                ValueLabel.Text = tostring(value) .. suffix
                SliderFill.Size = UDim2.new(newRel, 0, 1, 0)
                SliderKnob.Position = UDim2.new(newRel, -7, 0.5, -7)
                callback(value)
            end

            SliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliderDragging = true
                    UpdateSlider(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliderDragging = false
                end
            end)

            callback(default)

            local obj = {}
            obj.Value = currentValue
            function obj:Set(value)
                value = math.clamp(value, min, max)
                local newRel = (value - min) / (max - min)
                currentValue = value
                obj.Value = value
                ValueLabel.Text = tostring(value) .. suffix
                SliderFill.Size = UDim2.new(newRel, 0, 1, 0)
                SliderKnob.Position = UDim2.new(newRel, -7, 0.5, -7)
                callback(value)
            end
            return obj
        end

        -- BUTTON
        function Tab:CreateButton(cfg)
            cfg = cfg or {}
            local name = cfg.Name or "Button"
            local callback = cfg.Callback or function() end

            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Parent = TabContent
            ButtonFrame.Size = UDim2.new(1, 0, 0, 40)
            ButtonFrame.BackgroundColor3 = THEME.BackgroundLight
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.ZIndex = 3
            ButtonFrame.ClipsDescendants = true
            CreateCorner(ButtonFrame, THEME.CornerRadius)
            CreateStroke(ButtonFrame, THEME.Border, 1, 0.5)

            local BtnLabel = Instance.new("TextLabel")
            BtnLabel.Parent = ButtonFrame
            BtnLabel.Size = UDim2.new(1, -20, 1, 0)
            BtnLabel.Position = UDim2.new(0, 14, 0, 0)
            BtnLabel.BackgroundTransparency = 1
            BtnLabel.Text = name
            BtnLabel.TextColor3 = THEME.TextPrimary
            BtnLabel.TextSize = 13
            BtnLabel.Font = THEME.FontMedium
            BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
            BtnLabel.ZIndex = 4

            -- Arrow icon
            local Arrow = Instance.new("TextLabel")
            Arrow.Parent = ButtonFrame
            Arrow.Size = UDim2.new(0, 20, 1, 0)
            Arrow.Position = UDim2.new(1, -30, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "›"
            Arrow.TextColor3 = THEME.TextMuted
            Arrow.TextSize = 20
            Arrow.Font = THEME.FontBold
            Arrow.ZIndex = 4

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Parent = ButtonFrame
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.ZIndex = 5

            ClickBtn.MouseEnter:Connect(function()
                Tween(ButtonFrame, 0.2, {BackgroundColor3 = THEME.BackgroundCard})
                Tween(Arrow, 0.2, {TextColor3 = THEME.Primary, Position = UDim2.new(1, -26, 0, 0)})
            end)
            ClickBtn.MouseLeave:Connect(function()
                Tween(ButtonFrame, 0.2, {BackgroundColor3 = THEME.BackgroundLight})
                Tween(Arrow, 0.2, {TextColor3 = THEME.TextMuted, Position = UDim2.new(1, -30, 0, 0)})
            end)

            ClickBtn.MouseButton1Click:Connect(function()
                RippleEffect(ButtonFrame, ClickBtn.AbsolutePosition.X + ButtonFrame.AbsoluteSize.X / 2, ClickBtn.AbsolutePosition.Y + ButtonFrame.AbsoluteSize.Y / 2)
                callback()
            end)

            return ButtonFrame
        end

        -- DROPDOWN
        function Tab:CreateDropdown(cfg)
            cfg = cfg or {}
            local name = cfg.Name or "Dropdown"
            local options = cfg.Options or {}
            local default = cfg.Default or (options[1] or "")
            local callback = cfg.Callback or function() end

            local isOpen = false
            local selectedValue = default

            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Parent = TabContent
            DropdownFrame.Size = UDim2.new(1, 0, 0, 42)
            DropdownFrame.BackgroundColor3 = THEME.BackgroundLight
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.ZIndex = 3
            DropdownFrame.ClipsDescendants = true
            CreateCorner(DropdownFrame, THEME.CornerRadius)
            CreateStroke(DropdownFrame, THEME.Border, 1, 0.5)

            local Label = Instance.new("TextLabel")
            Label.Parent = DropdownFrame
            Label.Size = UDim2.new(0.5, 0, 0, 42)
            Label.Position = UDim2.new(0, 14, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = THEME.TextPrimary
            Label.TextSize = 13
            Label.Font = THEME.FontMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 4

            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Parent = DropdownFrame
            SelectedLabel.Size = UDim2.new(0.4, 0, 0, 42)
            SelectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
            SelectedLabel.BackgroundTransparency = 1
            SelectedLabel.Text = default
            SelectedLabel.TextColor3 = THEME.Primary
            SelectedLabel.TextSize = 12
            SelectedLabel.Font = THEME.FontMedium
            SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
            SelectedLabel.ZIndex = 4

            local ArrowIcon = Instance.new("TextLabel")
            ArrowIcon.Parent = DropdownFrame
            ArrowIcon.Size = UDim2.new(0, 20, 0, 42)
            ArrowIcon.Position = UDim2.new(1, -28, 0, 0)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Text = "▼"
            ArrowIcon.TextColor3 = THEME.TextMuted
            ArrowIcon.TextSize = 10
            ArrowIcon.Font = THEME.FontBold
            ArrowIcon.ZIndex = 4

            -- Options container
            local OptionsContainer = Instance.new("Frame")
            OptionsContainer.Parent = DropdownFrame
            OptionsContainer.Size = UDim2.new(1, -16, 0, 0)
            OptionsContainer.Position = UDim2.new(0, 8, 0, 46)
            OptionsContainer.BackgroundTransparency = 1
            OptionsContainer.BorderSizePixel = 0
            OptionsContainer.ZIndex = 5

            local OptionsLayout = Instance.new("UIListLayout")
            OptionsLayout.Parent = OptionsContainer
            OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionsLayout.Padding = UDim.new(0, 3)

            -- Criar opções
            local optionButtons = {}

            local function RefreshOptions(opts)
                for _, btn in pairs(optionButtons) do
                    btn:Destroy()
                end
                optionButtons = {}

                for _, option in ipairs(opts) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Parent = OptionsContainer
                    OptBtn.Size = UDim2.new(1, 0, 0, 30)
                    OptBtn.BackgroundColor3 = THEME.BackgroundCard
                    OptBtn.Text = option
                    OptBtn.TextColor3 = option == selectedValue and THEME.Primary or THEME.TextSecondary
                    OptBtn.TextSize = 12
                    OptBtn.Font = THEME.FontMedium
                    OptBtn.BorderSizePixel = 0
                    OptBtn.ZIndex = 6
                    CreateCorner(OptBtn, UDim.new(0, 6))

                    OptBtn.MouseEnter:Connect(function()
                        Tween(OptBtn, 0.15, {BackgroundColor3 = THEME.BackgroundLight})
                    end)
                    OptBtn.MouseLeave:Connect(function()
                        Tween(OptBtn, 0.15, {BackgroundColor3 = THEME.BackgroundCard})
                    end)

                    OptBtn.MouseButton1Click:Connect(function()
                        selectedValue = option
                        SelectedLabel.Text = option
                        callback(option)

                        -- Atualizar cores
                        for _, btn in pairs(optionButtons) do
                            btn.TextColor3 = THEME.TextSecondary
                        end
                        OptBtn.TextColor3 = THEME.Primary

                        -- Fechar dropdown
                        isOpen = false
                        ArrowIcon.Text = "▼"
                        local totalHeight = 42
                        Tween(DropdownFrame, 0.3, {Size = UDim2.new(1, 0, 0, totalHeight)})
                    end)

                    table.insert(optionButtons, OptBtn)
                end
            end

            RefreshOptions(options)

            -- Toggle dropdown
            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Parent = DropdownFrame
            ToggleBtn.Size = UDim2.new(1, 0, 0, 42)
            ToggleBtn.BackgroundTransparency = 1
            ToggleBtn.Text = ""
            ToggleBtn.ZIndex = 7

            ToggleBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    ArrowIcon.Text = "▲"
                    local totalHeight = 42 + 8 + (#options * 33)
                    Tween(DropdownFrame, 0.3, {Size = UDim2.new(1, 0, 0, totalHeight)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                else
                    ArrowIcon.Text = "▼"
                    Tween(DropdownFrame, 0.3, {Size = UDim2.new(1, 0, 0, 42)})
                end
            end)

            if default ~= "" then callback(default) end

            local obj = {}
            obj.Value = selectedValue
            function obj:Set(value)
                selectedValue = value
                obj.Value = value
                SelectedLabel.Text = value
                callback(value)
            end
            function obj:Refresh(newOptions, newDefault)
                options = newOptions
                if newDefault then
                    selectedValue = newDefault
                    SelectedLabel.Text = newDefault
                end
                RefreshOptions(options)
            end
            return obj
        end

        -- INPUT (TextBox)
        function Tab:CreateInput(cfg)
            cfg = cfg or {}
            local name = cfg.Name or "Input"
            local placeholder = cfg.Placeholder or "Digite aqui..."
            local default = cfg.Default or ""
            local callback = cfg.Callback or function() end

            local InputFrame = Instance.new("Frame")
            InputFrame.Parent = TabContent
            InputFrame.Size = UDim2.new(1, 0, 0, 70)
            InputFrame.BackgroundColor3 = THEME.BackgroundLight
            InputFrame.BorderSizePixel = 0
            InputFrame.ZIndex = 3
            CreateCorner(InputFrame, THEME.CornerRadius)
            CreateStroke(InputFrame, THEME.Border, 1, 0.5)

            local Label = Instance.new("TextLabel")
            Label.Parent = InputFrame
            Label.Size = UDim2.new(1, -20, 0, 22)
            Label.Position = UDim2.new(0, 14, 0, 6)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = THEME.TextPrimary
            Label.TextSize = 13
            Label.Font = THEME.FontMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 4

            local InputBox = Instance.new("Frame")
            InputBox.Parent = InputFrame
            InputBox.Size = UDim2.new(1, -20, 0, 30)
            InputBox.Position = UDim2.new(0, 10, 0, 32)
            InputBox.BackgroundColor3 = THEME.BackgroundCard
            InputBox.BorderSizePixel = 0
            InputBox.ZIndex = 4
            CreateCorner(InputBox, UDim.new(0, 8))
            local inputBoxStroke = CreateStroke(InputBox, THEME.Border, 1, 0.5)

            local TextBox = Instance.new("TextBox")
            TextBox.Parent = InputBox
            TextBox.Size = UDim2.new(1, -16, 1, 0)
            TextBox.Position = UDim2.new(0, 8, 0, 0)
            TextBox.BackgroundTransparency = 1
            TextBox.Text = default
            TextBox.PlaceholderText = placeholder
            TextBox.PlaceholderColor3 = THEME.TextDisabled
            TextBox.TextColor3 = THEME.TextPrimary
            TextBox.TextSize = 12
            TextBox.Font = THEME.FontMedium
            TextBox.ClearTextOnFocus = false
            TextBox.ZIndex = 5

            TextBox.Focused:Connect(function()
                Tween(inputBoxStroke, 0.2, {Color = THEME.Primary})
            end)
            TextBox.FocusLost:Connect(function(enter)
                Tween(inputBoxStroke, 0.2, {Color = THEME.Border})
                if enter then callback(TextBox.Text) end
            end)

            local obj = {}
            function obj:Set(text)
                TextBox.Text = text
            end
            function obj:Get()
                return TextBox.Text
            end
            return obj
        end

        -- KEYBIND
        function Tab:CreateKeybind(cfg)
            cfg = cfg or {}
            local name = cfg.Name or "Keybind"
            local default = cfg.Default or Enum.KeyCode.Unknown
            local callback = cfg.Callback or function() end

            local currentKey = default
            local listening = false

            local KeybindFrame = Instance.new("Frame")
            KeybindFrame.Parent = TabContent
            KeybindFrame.Size = UDim2.new(1, 0, 0, 42)
            KeybindFrame.BackgroundColor3 = THEME.BackgroundLight
            KeybindFrame.BorderSizePixel = 0
            KeybindFrame.ZIndex = 3
            CreateCorner(KeybindFrame, THEME.CornerRadius)
            CreateStroke(KeybindFrame, THEME.Border, 1, 0.5)

            local Label = Instance.new("TextLabel")
            Label.Parent = KeybindFrame
            Label.Size = UDim2.new(1, -90, 1, 0)
            Label.Position = UDim2.new(0, 14, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = THEME.TextPrimary
            Label.TextSize = 13
            Label.Font = THEME.FontMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 4

            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Parent = KeybindFrame
            KeyBtn.Size = UDim2.new(0, 65, 0, 26)
            KeyBtn.Position = UDim2.new(1, -78, 0.5, -13)
            KeyBtn.BackgroundColor3 = THEME.BackgroundCard
            KeyBtn.Text = default.Name or "None"
            KeyBtn.TextColor3 = THEME.Primary
            KeyBtn.TextSize = 11
            KeyBtn.Font = THEME.FontMedium
            KeyBtn.BorderSizePixel = 0
            KeyBtn.ZIndex = 5
            CreateCorner(KeyBtn, UDim.new(0, 6))
            CreateStroke(KeyBtn, THEME.Border, 1, 0.3)

            KeyBtn.MouseButton1Click:Connect(function()
                listening = true
                KeyBtn.Text = "..."
                Tween(KeyBtn, 0.2, {BackgroundColor3 = THEME.Primary})
                KeyBtn.TextColor3 = Color3.new(1, 1, 1)
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    listening = false
                    KeyBtn.Text = input.KeyCode.Name
                    Tween(KeyBtn, 0.2, {BackgroundColor3 = THEME.BackgroundCard})
                    KeyBtn.TextColor3 = THEME.Primary
                end

                if not listening and input.KeyCode == currentKey and not gameProcessed then
                    callback(currentKey)
                end
            end)

            local obj = {}
            obj.Value = currentKey
            function obj:Set(key)
                currentKey = key
                obj.Value = key
                KeyBtn.Text = key.Name
            end
            return obj
        end

        -- COLOR PICKER
        function Tab:CreateColorPicker(cfg)
            cfg = cfg or {}
            local name = cfg.Name or "Color"
            local default = cfg.Default or Color3.fromRGB(255, 255, 255)
            local callback = cfg.Callback or function() end

            local isOpen = false
            local currentColor = default

            local ColorFrame = Instance.new("Frame")
            ColorFrame.Parent = TabContent
            ColorFrame.Size = UDim2.new(1, 0, 0, 42)
            ColorFrame.BackgroundColor3 = THEME.BackgroundLight
            ColorFrame.BorderSizePixel = 0
            ColorFrame.ZIndex = 3
            ColorFrame.ClipsDescendants = true
            CreateCorner(ColorFrame, THEME.CornerRadius)
            CreateStroke(ColorFrame, THEME.Border, 1, 0.5)

            local Label = Instance.new("TextLabel")
            Label.Parent = ColorFrame
            Label.Size = UDim2.new(1, -60, 0, 42)
            Label.Position = UDim2.new(0, 14, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = name
            Label.TextColor3 = THEME.TextPrimary
            Label.TextSize = 13
            Label.Font = THEME.FontMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 4

            local ColorPreview = Instance.new("Frame")
            ColorPreview.Parent = ColorFrame
            ColorPreview.Size = UDim2.new(0, 28, 0, 28)
            ColorPreview.Position = UDim2.new(1, -42, 0, 7)
            ColorPreview.BackgroundColor3 = default
            ColorPreview.BorderSizePixel = 0
            ColorPreview.ZIndex = 4
            CreateCorner(ColorPreview, UDim.new(0, 6))
            CreateStroke(ColorPreview, THEME.Border, 1, 0.3)

            -- Color palette (expandível)
            local PaletteContainer = Instance.new("Frame")
            PaletteContainer.Parent = ColorFrame
            PaletteContainer.Size = UDim2.new(1, -16, 0, 0)
            PaletteContainer.Position = UDim2.new(0, 8, 0, 48)
            PaletteContainer.BackgroundTransparency = 1
            PaletteContainer.ZIndex = 5

            local PaletteLayout = Instance.new("UIGridLayout")
            PaletteLayout.Parent = PaletteContainer
            PaletteLayout.CellSize = UDim2.new(0, 30, 0, 30)
            PaletteLayout.CellPadding = UDim2.new(0, 5, 0, 5)
            PaletteLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local presetColors = {
                Color3.fromRGB(255, 0, 0),
                Color3.fromRGB(255, 85, 0),
                Color3.fromRGB(255, 170, 0),
                Color3.fromRGB(255, 255, 0),
                Color3.fromRGB(170, 255, 0),
                Color3.fromRGB(85, 255, 0),
                Color3.fromRGB(0, 255, 0),
                Color3.fromRGB(0, 255, 170),
                Color3.fromRGB(0, 255, 255),
                Color3.fromRGB(0, 170, 255),
                Color3.fromRGB(0, 85, 255),
                Color3.fromRGB(0, 0, 255),
                Color3.fromRGB(85, 0, 255),
                Color3.fromRGB(170, 0, 255),
                Color3.fromRGB(255, 0, 255),
                Color3.fromRGB(255, 0, 170),
                Color3.fromRGB(255, 255, 255),
                Color3.fromRGB(200, 200, 200),
                Color3.fromRGB(130, 130, 130),
                Color3.fromRGB(50, 50, 50),
            }

            for _, color in ipairs(presetColors) do
                local ColorBtn = Instance.new("TextButton")
                ColorBtn.Parent = PaletteContainer
                ColorBtn.BackgroundColor3 = color
                ColorBtn.Text = ""
                ColorBtn.BorderSizePixel = 0
                ColorBtn.ZIndex = 6
                CreateCorner(ColorBtn, UDim.new(0, 6))

                ColorBtn.MouseButton1Click:Connect(function()
                    currentColor = color
                    ColorPreview.BackgroundColor3 = color
                    callback(color)
                end)
            end

            -- Toggle
            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Parent = ColorFrame
            ToggleBtn.Size = UDim2.new(1, 0, 0, 42)
            ToggleBtn.BackgroundTransparency = 1
            ToggleBtn.Text = ""
            ToggleBtn.ZIndex = 7

            ToggleBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    local rows = math.ceil(#presetColors / 6)
                    local totalHeight = 42 + 10 + (rows * 35)
                    Tween(ColorFrame, 0.3, {Size = UDim2.new(1, 0, 0, totalHeight)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                else
                    Tween(ColorFrame, 0.3, {Size = UDim2.new(1, 0, 0, 42)})
                end
            end)

            callback(default)

            local obj = {}
            obj.Value = currentColor
            function obj:Set(color)
                currentColor = color
                obj.Value = color
                ColorPreview.BackgroundColor3 = color
                callback(color)
            end
            return obj
        end

        -- SEPARATOR
        function Tab:CreateSeparator()
            local Sep = Instance.new("Frame")
            Sep.Parent = TabContent
            Sep.Size = UDim2.new(0.92, 0, 0, 1)
            Sep.BackgroundColor3 = THEME.Border
            Sep.BackgroundTransparency = 0.5
            Sep.BorderSizePixel = 0
            Sep.ZIndex = 3
            return Sep
        end

        return Tab
    end

    -- ════════════════════════════════════════════════════
    -- NOTIFICAÇÕES
    -- ════════════════════════════════════════════════════

    function Window:Notify(cfg)
        cfg = cfg or {}
        local title = cfg.Title or "Notificação"
        local message = cfg.Message or ""
        local duration = cfg.Duration or 4
        local nType = cfg.Type or "Info" -- Info, Success, Error, Warning

        local typeColors = {
            Info = THEME.Info,
            Success = THEME.Success,
            Error = THEME.Error,
            Warning = THEME.Warning
        }
        local typeIcons = {
            Info = "ℹ",
            Success = "✅",
            Error = "❌",
            Warning = "⚠"
        }

        local color = typeColors[nType] or THEME.Info
        local icon = typeIcons[nType] or "ℹ"

        local NotifFrame = Instance.new("Frame")
        NotifFrame.Parent = NotificationHolder
        NotifFrame.Size = UDim2.new(1, 0, 0, 65)
        NotifFrame.BackgroundColor3 = THEME.BackgroundDark
        NotifFrame.BorderSizePixel = 0
        NotifFrame.ZIndex = 100
        NotifFrame.ClipsDescendants = true
        CreateCorner(NotifFrame, UDim.new(0, 12))
        CreateStroke(NotifFrame, color, 1.5, 0.3)

        -- Barra lateral colorida
        local SideBar = Instance.new("Frame")
        SideBar.Parent = NotifFrame
        SideBar.Size = UDim2.new(0, 4, 1, -10)
        SideBar.Position = UDim2.new(0, 5, 0, 5)
        SideBar.BackgroundColor3 = color
        SideBar.BorderSizePixel = 0
        SideBar.ZIndex = 101
        CreateCorner(SideBar, UDim.new(1, 0))

        local IconLabel = Instance.new("TextLabel")
        IconLabel.Parent = NotifFrame
        IconLabel.Size = UDim2.new(0, 20, 0, 20)
        IconLabel.Position = UDim2.new(0, 18, 0, 10)
        IconLabel.BackgroundTransparency = 1
        IconLabel.Text = icon
        IconLabel.TextSize = 14
        IconLabel.ZIndex = 101

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Parent = NotifFrame
        TitleLabel.Size = UDim2.new(1, -50, 0, 20)
        TitleLabel.Position = UDim2.new(0, 42, 0, 8)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = title
        TitleLabel.TextColor3 = THEME.TextPrimary
        TitleLabel.TextSize = 13
        TitleLabel.Font = THEME.FontBold
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.ZIndex = 101

        local MsgLabel = Instance.new("TextLabel")
        MsgLabel.Parent = NotifFrame
        MsgLabel.Size = UDim2.new(1, -50, 0, 25)
        MsgLabel.Position = UDim2.new(0, 42, 0, 28)
        MsgLabel.BackgroundTransparency = 1
        MsgLabel.Text = message
        MsgLabel.TextColor3 = THEME.TextSecondary
        MsgLabel.TextSize = 11
        MsgLabel.Font = THEME.FontRegular
        MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
        MsgLabel.TextWrapped = true
        MsgLabel.ZIndex = 101

        -- Progress bar
        local ProgressBar = Instance.new("Frame")
        ProgressBar.Parent = NotifFrame
        ProgressBar.Size = UDim2.new(1, 0, 0, 2)
        ProgressBar.Position = UDim2.new(0, 0, 1, -2)
        ProgressBar.BackgroundColor3 = color
        ProgressBar.BorderSizePixel = 0
        ProgressBar.ZIndex = 101

        -- Animação de entrada
        NotifFrame.Position = UDim2.new(1, 20, 0, 0)
        Tween(NotifFrame, 0.4, {Position = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        -- Progress countdown
        Tween(ProgressBar, duration, {Size = UDim2.new(0, 0, 0, 2)}, Enum.EasingStyle.Linear)

        -- Auto remove
        task.delay(duration, function()
            local exitTween = Tween(NotifFrame, 0.3, {
                Position = UDim2.new(1, 20, 0, 0),
                BackgroundTransparency = 1
            })
            exitTween.Completed:Connect(function()
                NotifFrame:Destroy()
            end)
        end)
    end

    -- ════════════════════════════════════════════════════
    -- MÉTODOS EXTRAS DA WINDOW
    -- ════════════════════════════════════════════════════

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    function Window:Toggle(state)
        if state ~= nil then
            windowVisible = state
        else
            windowVisible = not windowVisible
        end

        if windowVisible then
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, windowSize.X.Offset, 0, 0)
            Tween(MainFrame, 0.4, {Size = windowSize, BackgroundTransparency = 0}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            local t = Tween(MainFrame, 0.35, {Size = UDim2.new(0, windowSize.X.Offset, 0, 0), BackgroundTransparency = 1})
            t.Completed:Connect(function()
                if not windowVisible then MainFrame.Visible = false end
            end)
        end
    end

    return Window
end

-- ════════════════════════════════════════════════════════════
-- RETORNO DA LIBRARY
-- ════════════════════════════════════════════════════════════

return PhantomUI
