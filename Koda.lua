--[[
    Koda UI Library
    Inspired by Gemini Aesthetic
    
    A standalone, premium UI library for Roblox.
    Enhanced Edition with advanced visual effects.
]]

local Koda = {}
Koda.Version = "3.0.3" -- A cada modificaçao sobe 0.0.1
Koda.NotifyHolder = nil
Koda.Plugins = {}
Koda.LegacyMode = false -- Flag para otimização (remove efeitos visuais)

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

-- Constants & Theme
Koda.Themes = {
    Dark = {
        MainColor = Color3.fromRGB(15, 17, 26),
        AccentColor = Color3.fromRGB(244, 63, 94), -- Soft Red (Rose 500)
        SecondaryAccent = Color3.fromRGB(225, 29, 72), -- Deeper Red (Rose 600)
        TextColor = Color3.fromRGB(245, 245, 250),
        SecondaryTextColor = Color3.fromRGB(140, 140, 165),
        StrokeColor = Color3.fromRGB(35, 40, 55),
        DarkerColor = Color3.fromRGB(10, 12, 18),
        ElementColor = Color3.fromRGB(22, 24, 38),
        SuccessColor = Color3.fromRGB(34, 197, 94),
        WarningColor = Color3.fromRGB(250, 204, 21),
        ErrorColor = Color3.fromRGB(239, 68, 68),
        InfoColor = Color3.fromRGB(56, 189, 248),
        ShadowColor = Color3.fromRGB(0, 0, 0)
    },

    Bloom = {
        MainColor = Color3.fromRGB(255, 240, 245), -- Background principal
        AccentColor = Color3.fromRGB(255, 140, 170), -- Rosa vibrante (ToggleEnabled)
        SecondaryAccent = Color3.fromRGB(240, 130, 160), -- Rosa profundo (SliderBackground)
        TextColor = Color3.fromRGB(60, 40, 50), -- Texto principal escuro/vinho
        SecondaryTextColor = Color3.fromRGB(170, 130, 140), -- Placeholder/Texto secundário
        StrokeColor = Color3.fromRGB(230, 200, 210), -- Bordas e divisores
        DarkerColor = Color3.fromRGB(250, 220, 225), -- Topbar ou áreas de destaque
        ElementColor = Color3.fromRGB(255, 235, 240), -- Background de botões/inputs
        SuccessColor = Color3.fromRGB(150, 220, 170), -- Verde Pastel (ajustado para o tema)
        WarningColor = Color3.fromRGB(250, 204, 150), -- Amarelo Pastel
        ErrorColor = Color3.fromRGB(240, 150, 150), -- Vermelho Pastel
        InfoColor = Color3.fromRGB(160, 200, 240), -- Azul Pastel
        ShadowColor = Color3.fromRGB(230, 190, 195) -- Sombra suave rosada
    },
    
    Light = {
        MainColor = Color3.fromRGB(245, 247, 252),
        AccentColor = Color3.fromRGB(79, 70, 229),
        SecondaryAccent = Color3.fromRGB(147, 51, 234),
        TextColor = Color3.fromRGB(15, 23, 42),
        SecondaryTextColor = Color3.fromRGB(100, 116, 139),
        StrokeColor = Color3.fromRGB(220, 225, 240),
        DarkerColor = Color3.fromRGB(235, 238, 245),
        ElementColor = Color3.fromRGB(255, 255, 255),
        SuccessColor = Color3.fromRGB(22, 163, 74),
        WarningColor = Color3.fromRGB(234, 179, 8),
        ErrorColor = Color3.fromRGB(220, 38, 38),
        InfoColor = Color3.fromRGB(14, 165, 233),
        ShadowColor = Color3.fromRGB(180, 180, 200)
    }
}

Koda.Theme = Koda.Themes.Dark

-- ═══════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════

local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    inst.Parent = props.Parent
    return inst
end

local function Tween(inst, speed, props, style, direction)
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(speed, style, direction)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function TweenBounce(inst, speed, props)
    return Tween(inst, speed, props, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function Ripple(obj, color)
    task.spawn(function()
        local mouse = Players.LocalPlayer:GetMouse()
        local ripple = Create("Frame", {
            Name = "Ripple",
            Parent = obj,
            BackgroundColor3 = color or Color3.new(1, 1, 1),
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            Position = UDim2.new(0, mouse.X - obj.AbsolutePosition.X, 0, mouse.Y - obj.AbsolutePosition.Y),
            Size = UDim2.new(0, 0, 0, 0),
            ZIndex = 10
        })
        Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ripple })
        
        local size = math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 2
        Tween(ripple, 0.5, {
            Size = UDim2.new(0, size, 0, size), 
            Position = ripple.Position - UDim2.new(0, size/2, 0, size/2), 
            BackgroundTransparency = 1
        })
        task.wait(0.5)
        ripple:Destroy()
    end)
end

local function GlowEffect(parent, color, size, transparency)
    if Koda.LegacyMode then return nil end
    local glow = Create("ImageLabel", {
        Name = "Glow",
        Parent = parent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, size or 40, 1, size or 40),
        Image = "rbxassetid://5028857084",
        ImageColor3 = color or Koda.Theme.AccentColor,
        ImageTransparency = transparency or 0.85,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276),
        ZIndex = parent.ZIndex - 1
    })
    return glow
end

local function CreateShadow(parent, transparency)
    if Koda.LegacyMode then return nil end
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = parent,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 30, 1, 30),
        Image = "rbxassetid://5028857084",
        ImageColor3 = Koda.Theme.ShadowColor or Color3.fromRGB(0, 0, 0),
        ImageTransparency = transparency or 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276),
        ZIndex = parent.ZIndex - 1
    })
    return shadow
end

local function CreateGradientBar(parent, height, position)
    local bar = Create("Frame", {
        Name = "GradientBar",
        Parent = parent,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Position = position or UDim2.new(0, 0, 1, -height),
        Size = UDim2.new(1, 0, 0, height or 2)
    })
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Koda.Theme.AccentColor),
            ColorSequenceKeypoint.new(0.5, Koda.Theme.SecondaryAccent),
            ColorSequenceKeypoint.new(1, Koda.Theme.AccentColor)
        }),
        Parent = bar
    })
    return bar
end

local function AnimateGradient(gradient)
    if Koda.LegacyMode then return end
    task.spawn(function()
        local offset = 0
        while gradient and gradient.Parent do
            offset = (offset + 0.005) % 1
            gradient.Offset = Vector2.new(offset, 0)
            RunService.Heartbeat:Wait()
        end
    end)
end

local function PulseAnimation(obj, prop, minVal, maxVal, speed)
    task.spawn(function()
        while obj and obj.Parent do
            Tween(obj, speed or 1.5, {[prop] = minVal})
            task.wait(speed or 1.5)
            Tween(obj, speed or 1.5, {[prop] = maxVal})
            task.wait(speed or 1.5)
        end
    end)
end

local function HoverEffect(frame, enterProps, leaveProps, speed)
    speed = speed or 0.25
    frame.MouseEnter:Connect(function()
        Tween(frame, speed, enterProps)
    end)
    frame.MouseLeave:Connect(function()
        Tween(frame, speed, leaveProps)
    end)
end

function Koda:ApplyLegacyOptimization(MainFrame)
    for _, desc in pairs(MainFrame:GetDescendants()) do
        if desc.Name == "Glow" or desc.Name == "Shadow" or desc.Name == "GradientBar" then
            desc:Destroy()
        elseif desc:IsA("UICorner") then
            desc.CornerRadius = UDim.new(0, 3) -- Bordas quase quadradas para performance
        elseif desc:IsA("UIGradient") then
            desc:Destroy()
        elseif desc:IsA("Frame") or desc:IsA("ScrollingFrame") or desc:IsA("CanvasGroup") then
            -- Cores sólidas e remoção de glassmorphism
            if desc.Name ~= "LoadingFrame" then
                desc.BackgroundTransparency = 0
            end
        elseif desc:IsA("UIStroke") then
            desc.Transparency = 0.5 -- Bordas mais simples
            desc.Thickness = 1
        end
    end
    
    -- Ajustar MainUI Containers
    MainFrame.BackgroundColor3 = Koda.Theme.MainColor
    MainFrame.BackgroundTransparency = 0
    
    local mainCorner = MainFrame:FindFirstChildOfClass("UICorner")
    if mainCorner then mainCorner.CornerRadius = UDim.new(0, 6) end
    
    local TopBar = MainFrame:FindFirstChild("TopBar")
    if TopBar then
        TopBar.BackgroundColor3 = Koda.Theme.DarkerColor
        TopBar.BackgroundTransparency = 0
        local tbCorner = TopBar:FindFirstChildOfClass("UICorner")
        if tbCorner then tbCorner.CornerRadius = UDim.new(0, 6) end
        
        local bc = TopBar:FindFirstChild("BottomCover")
        if bc then bc.BackgroundColor3 = Koda.Theme.DarkerColor end
    end
    
    local SideBar = MainFrame:FindFirstChild("SideBar")
    if SideBar then
        SideBar.BackgroundColor3 = Koda.Theme.DarkerColor
        SideBar.BackgroundTransparency = 0
    end
end

local function MakeDraggable(TopBar, MainFrame)
    local Dragging, DragInput, DragStart, StartPos

    local function Update(Input)
        local Delta = Input.Position - DragStart
        local newPos = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        Tween(MainFrame, 0.08, {Position = newPos}, Enum.EasingStyle.Quad)
    end

    TopBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPos = MainFrame.Position

            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    TopBar.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            DragInput = Input
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            Update(Input)
        end
    end)
end

-- ═══════════════════════════════════════════════════════
-- LIBRARY METHODS
-- ═══════════════════════════════════════════════════════

function Koda:AddPlugin(Callback)
    table.insert(Koda.Plugins, Callback)
end

function Koda:RunPlugins(Window)
    for _, Callback in pairs(Koda.Plugins) do
        task.spawn(function()
            Callback(Window)
        end)
    end
end

function Koda:CreateWindow(Config)
    Config = Config or {}
    Config.Name = Config.Name or "Koda Library"
    Config.Theme = Config.Theme or "Dark"
    Config.Size = Config.Size or UDim2.new(0, 700, 0, 460)
    Config.Keybind = Config.Keybind or Enum.KeyCode.RightControl
    
    local KeySystem = Config.KeySystem or false
    local KeySettings = Config.KeySettings or {}
    local ValidKey = KeySettings.Key or ""
    
    if Koda.Themes[Config.Theme] then
        Koda.Theme = Koda.Themes[Config.Theme]
    end
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    local ScreenGui = Create("ScreenGui", {
        Name = "Koda_" .. HttpService:GenerateGUID(false):sub(1, 8),
        Parent = (RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")) or CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- ═══════════════════════════════════════════════════════
    -- NOTIFICATION CONTAINER
    -- ═══════════════════════════════════════════════════════
    local NotifyHolder = Create("Frame", {
        Name = "NotifyHolder",
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -340, 1, -20),
        Size = UDim2.new(0, 330, 1, -20),
        AnchorPoint = Vector2.new(0, 1)
    })
    
    Create("UIListLayout", {
        Parent = NotifyHolder,
        Padding = UDim.new(0, 12),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Koda.NotifyHolder = NotifyHolder

    -- ═══════════════════════════════════════════════════════
    -- MAIN CONTAINER
    -- ═══════════════════════════════════════════════════════
    local MainFrame = Create("CanvasGroup", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Koda.Theme.MainColor,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        GroupTransparency = 0
    })

    local MainScale = Create("UIScale", {
        Parent = MainFrame,
        Scale = 1
    })
    Window.MainScale = MainScale

    Create("UICorner", {
        CornerRadius = UDim.new(0, 18),
        Parent = MainFrame
    })
    
    -- Main frame shadow
    CreateShadow(MainFrame, 0.5)
    
    -- Animated accent border stroke
    local MainStroke = Create("UIStroke", {
        Color = Color3.new(1, 1, 1),
        Thickness = 1.5,
        Parent = MainFrame,
        Transparency = 0.4
    })
    
    local MainStrokeGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Koda.Theme.AccentColor),
            ColorSequenceKeypoint.new(0.5, Koda.Theme.SecondaryAccent),
            ColorSequenceKeypoint.new(1, Koda.Theme.AccentColor)
        }),
        Parent = MainStroke
    })
    
    -- Animate the stroke gradient
    AnimateGradient(MainStrokeGradient)

    -- Breathing effect for the stroke
    PulseAnimation(MainStroke, "Transparency", 0.25, 0.65, 2)

    -- ═══════════════════════════════════════════════════════
    -- TOPBAR
    -- ═══════════════════════════════════════════════════════
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = Koda.Theme.DarkerColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 56),
        ZIndex = 5
    })

    Create("UICorner", {
        CornerRadius = UDim.new(0, 18),
        Parent = TopBar
    })
    
    -- Cover bottom corners of topbar
    Create("Frame", {
        Name = "BottomCover",
        Parent = TopBar,
        BackgroundColor3 = Koda.Theme.DarkerColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -18),
        Size = UDim2.new(1, 0, 0, 18),
        ZIndex = 5
    })

    -- Animated gradient line under topbar
    local TopBarLine = CreateGradientBar(TopBar, 2, UDim2.new(0, 0, 1, -2))
    TopBarLine.ZIndex = 6
    TopBarLine.BackgroundTransparency = 0
    local lineGrad = TopBarLine:FindFirstChildOfClass("UIGradient")
    if lineGrad then AnimateGradient(lineGrad) end

    -- Window Icon/Logo
    local LogoFrame = Create("Frame", {
        Name = "LogoFrame",
        Parent = TopBar,
        BackgroundColor3 = Koda.Theme.AccentColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 16, 0.5, -16),
        Size = UDim2.new(0, 32, 0, 32),
        ZIndex = 6
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 9), Parent = LogoFrame })
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Koda.Theme.AccentColor),
            ColorSequenceKeypoint.new(1, Koda.Theme.SecondaryAccent)
        }),
        Rotation = 135,
        Parent = LogoFrame
    })
    -- Glow pulse no logo
    GlowEffect(LogoFrame, Koda.Theme.AccentColor, 20, 0.8)
    PulseAnimation(LogoFrame, "Rotation", -3, 3, 2.5)
    
    local LogoText = Create("TextLabel", {
        Parent = LogoFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBlack,
        Text = string.sub(Config.Name, 1, 1):upper(),
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 16,
        ZIndex = 7
    })

    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 58, 0, 0),
        Size = UDim2.new(1, -170, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = Config.Name,
        TextColor3 = Koda.Theme.TextColor,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6
    })

    -- Window control buttons
    local ControlsFrame = Create("Frame", {
        Name = "Controls",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -100, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        ZIndex = 6
    })

    -- Minimize Button
    local MinButton = Create("TextButton", {
        Name = "MinButton",
        Parent = ControlsFrame,
        BackgroundColor3 = Koda.Theme.ElementColor,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -11),
        Size = UDim2.new(0, 22, 0, 22),
        Font = Enum.Font.GothamBold,
        Text = "-",
        TextColor3 = Koda.Theme.SecondaryTextColor,
        TextSize = 14,
        AutoButtonColor = false,
        ZIndex = 7
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = MinButton })

    MinButton.MouseEnter:Connect(function()
        Tween(MinButton, 0.15, {BackgroundTransparency = 0.8, Size = UDim2.new(0, 24, 0, 24), TextColor3 = Koda.Theme.TextColor})
    end)
    MinButton.MouseLeave:Connect(function()
        Tween(MinButton, 0.15, {BackgroundTransparency = 1, Size = UDim2.new(0, 22, 0, 22), TextColor3 = Koda.Theme.SecondaryTextColor})
    end)

    local Minimized = false
    local OriginalSize = Config.Size

    MinButton.MouseButton1Click:Connect(function()
        Ripple(MinButton, Koda.Theme.AccentColor)
        if not Minimized then
            Minimized = true
            Tween(MainFrame, 0.4, {Size = UDim2.new(0, Config.Size.X.Offset, 0, 48)})
        else
            Minimized = false
            Tween(MainFrame, 0.4, {Size = Config.Size})
        end
    end)

    -- Close Button
    local CloseButton = Create("TextButton", {
        Name = "CloseButton",
        Parent = ControlsFrame,
        BackgroundColor3 = Koda.Theme.ElementColor,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -34, 0.5, -11),
        Size = UDim2.new(0, 22, 0, 22),
        Font = Enum.Font.GothamBold,
        Text = "X",
        TextColor3 = Koda.Theme.SecondaryTextColor,
        TextSize = 12,
        AutoButtonColor = false,
        ZIndex = 7
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = CloseButton })

    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, 0.15, {BackgroundTransparency = 0.8, Size = UDim2.new(0, 24, 0, 24), TextColor3 = Koda.Theme.ErrorColor})
    end)
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, 0.15, {BackgroundTransparency = 1, Size = UDim2.new(0, 22, 0, 22), TextColor3 = Koda.Theme.SecondaryTextColor})
    end)

    CloseButton.MouseButton1Click:Connect(function()
        Ripple(CloseButton, Koda.Theme.ErrorColor)
        Window:CreateDialog({
            Title = "Fechar Interface?",
            Content = "Você tem certeza que deseja fechar o script? Isso irá encerrar todas as funções.",
            Buttons = {
                {
                    Name = "Sim",
                    Primary = true,
                    Callback = function()
                        Tween(MainFrame, 0.5, {Size = UDim2.new(0, 0, 0, 0), GroupTransparency = 1})
                        task.wait(0.5)
                        ScreenGui:Destroy()
                    end
                },
                {
                    Name = "Não",
                    Primary = false,
                    Callback = function() end
                }
            }
        })
    end)

    MakeDraggable(TopBar, MainFrame)
    
    -- ═══════════════════════════════════════════════════════
    -- SIDEBAR
    -- ═══════════════════════════════════════════════════════
    local SideBar = Create("Frame", {
        Name = "SideBar",
        Parent = MainFrame,
        BackgroundColor3 = Koda.Theme.DarkerColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 56),
        Size = UDim2.new(0, 185, 1, -56)
    })

    -- Sidebar separator line
    local SidebarSep = Create("Frame", {
        Name = "Separator",
        Parent = SideBar,
        BackgroundColor3 = Koda.Theme.StrokeColor,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -1, 0, 8),
        Size = UDim2.new(0, 1, 1, -16),
        BackgroundTransparency = 0.3
    })

    -- Sidebar navigation label
    local NavLabel = Create("TextLabel", {
        Parent = SideBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 12),
        Size = UDim2.new(1, -16, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = "◈  NAVEGAÇÃO",
        TextColor3 = Koda.Theme.AccentColor,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 0.1
    })
    
    local SideBarList = Create("ScrollingFrame", {
        Name = "List",
        Parent = SideBar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 34),
        Size = UDim2.new(1, -20, 1, -44),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Koda.Theme.AccentColor,
        ScrollBarImageTransparency = 0.4,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ElasticBehavior = Enum.ElasticBehavior.Always,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    })
    
    local SideBarLayout = Create("UIListLayout", {
        Parent = SideBarList,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    SideBarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SideBarList.CanvasSize = UDim2.new(0, 0, 0, SideBarLayout.AbsoluteContentSize.Y + 10)
    end)

    -- ═══════════════════════════════════════════════════════
    -- CONTENT CONTAINER
    -- ═══════════════════════════════════════════════════════
    local Container = Create("Frame", {
        Name = "Container",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 185, 0, 56),
        Size = UDim2.new(1, -185, 1, -56),
        ClipsDescendants = true
    })

    -- Subtle background pattern/noise
    local BgPattern = Create("Frame", {
        Name = "BgPattern",
        Parent = Container,
        BackgroundColor3 = Koda.Theme.AccentColor,
        BackgroundTransparency = 0.97,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 0
    })

    -- Version label with styling
    local VersionFrame = Create("Frame", {
        Name = "VersionFrame",
        Parent = MainFrame,
        BackgroundColor3 = Koda.Theme.AccentColor,
        BackgroundTransparency = 0.82,
        Position = UDim2.new(0, 10, 1, -24),
        Size = UDim2.new(0, 78, 0, 18),
        ZIndex = 110
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = VersionFrame })

    Create("TextLabel", {
        Name = "Version",
        Parent = VersionFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "✦ v" .. Koda.Version,
        TextColor3 = Koda.Theme.AccentColor,
        TextTransparency = 0.1,
        TextSize = 10,
        ZIndex = 111
    })
    
    -- ═══════════════════════════════════════════════════════
    -- DIALOG SYSTEM
    -- ═══════════════════════════════════════════════════════
    function Window:CreateDialog(Props)
        Props = Props or {}
        Props.Title = Props.Title or "Dialog"
        Props.Content = Props.Content or "Are you sure?"
        Props.Buttons = Props.Buttons or {
            {Name = "Confirm", Primary = true, Callback = function() end},
            {Name = "Cancel", Primary = false, Callback = function() end}
        }

        local Overlay = Create("TextButton", {
            Name = "Overlay",
            Parent = MainFrame,
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 200
        })

        local DialogFrame = Create("CanvasGroup", {
            Name = "Dialog",
            Parent = Overlay,
            BackgroundColor3 = Koda.Theme.MainColor,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 0, 0, 0),
            ClipsDescendants = true,
            ZIndex = 201
        })

        Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = DialogFrame })
        
        local DStroke = Create("UIStroke", {
            Color = Color3.new(1, 1, 1),
            Thickness = 1.5,
            Parent = DialogFrame,
            Transparency = 0.4
        })
        
        local dStrokeGrad = Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Koda.Theme.AccentColor),
                ColorSequenceKeypoint.new(1, Koda.Theme.SecondaryAccent)
            }),
            Parent = DStroke
        })
        AnimateGradient(dStrokeGrad)
        
        CreateShadow(DialogFrame, 0.4)

        -- Dialog icon
        local DialogIcon = Create("Frame", {
            Parent = DialogFrame,
            BackgroundColor3 = Koda.Theme.AccentColor,
            BackgroundTransparency = 0.85,
            Position = UDim2.new(0, 18, 0, 18),
            Size = UDim2.new(0, 32, 0, 32),
            ZIndex = 202
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = DialogIcon })
        Create("TextLabel", {
            Parent = DialogIcon,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = "?",
            TextColor3 = Koda.Theme.AccentColor,
            TextSize = 18,
            ZIndex = 203
        })

        local DTitle = Create("TextLabel", {
            Parent = DialogFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 58, 0, 18),
            Size = UDim2.new(1, -70, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = Props.Title,
            TextColor3 = Koda.Theme.TextColor,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 202
        })

        local DContent = Create("TextLabel", {
            Parent = DialogFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 58, 0, 40),
            Size = UDim2.new(1, -70, 0, 50),
            Font = Enum.Font.GothamMedium,
            Text = Props.Content,
            TextColor3 = Koda.Theme.SecondaryTextColor,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            ZIndex = 202
        })

        -- Separator line
        Create("Frame", {
            Parent = DialogFrame,
            BackgroundColor3 = Koda.Theme.StrokeColor,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 18, 1, -55),
            Size = UDim2.new(1, -36, 0, 1),
            ZIndex = 202
        })

        local ButtonContainer = Create("Frame", {
            Parent = DialogFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 1, -48),
            Size = UDim2.new(1, -36, 0, 36),
            ZIndex = 202
        })

        Create("UIListLayout", {
            Parent = ButtonContainer,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        local function CloseDialog()
            Tween(DialogFrame, 0.3, {Size = UDim2.new(0, 0, 0, 0), GroupTransparency = 1})
            Tween(Overlay, 0.3, {BackgroundTransparency = 1})
            task.wait(0.3)
            Overlay:Destroy()
        end

        for i, btn in pairs(Props.Buttons) do
            local BFrame = Create("Frame", {
                Name = btn.Name .. "Button",
                Parent = ButtonContainer,
                BackgroundColor3 = btn.Primary and Koda.Theme.AccentColor or Koda.Theme.ElementColor,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 90, 0, 32),
                LayoutOrder = i,
                ZIndex = 203
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = BFrame })
            
            if btn.Primary then
                Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Koda.Theme.AccentColor),
                        ColorSequenceKeypoint.new(1, Koda.Theme.SecondaryAccent)
                    }),
                    Rotation = 90,
                    Parent = BFrame
                })
            else
                Create("UIStroke", { Color = Koda.Theme.StrokeColor, Thickness = 1, Parent = BFrame })
            end

            local BText = Create("TextButton", {
                Parent = BFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = btn.Name,
                TextColor3 = btn.Primary and Color3.new(1, 1, 1) or Koda.Theme.TextColor,
                TextSize = 12,
                AutoButtonColor = false,
                ZIndex = 204
            })

            BFrame.MouseEnter:Connect(function()
                Tween(BFrame, 0.15, {Size = UDim2.new(0, 94, 0, 34)})
            end)
            BFrame.MouseLeave:Connect(function()
                Tween(BFrame, 0.15, {Size = UDim2.new(0, 90, 0, 32)})
            end)

            BText.MouseButton1Click:Connect(function()
                Ripple(BFrame, btn.Primary and Color3.new(1,1,1) or Koda.Theme.AccentColor)
                task.spawn(btn.Callback)
                CloseDialog()
            end)
        end

        -- Animate In
        Tween(Overlay, 0.3, {BackgroundTransparency = 0.45})
        TweenBounce(DialogFrame, 0.45, {Size = UDim2.new(0, 340, 0, 160)})
    end

    -- ═══════════════════════════════════════════════════════
    -- TAB SYSTEM
    -- ═══════════════════════════════════════════════════════
    function Window:CreateTab(Name, Icon)
        local TabButton = Create("TextButton", {
            Name = Name .. "Tab",
            Parent = SideBarList,
            BackgroundColor3 = Koda.Theme.AccentColor,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 44),
            AutoButtonColor = false,
            Font = Enum.Font.GothamSemibold,
            Text = "",
            TextColor3 = Koda.Theme.SecondaryTextColor,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        Create("UICorner", {
            CornerRadius = UDim.new(0, 10),
            Parent = TabButton
        })

        -- Tab icon area
        local TabIconFrame = Create("Frame", {
            Name = "IconFrame",
            Parent = TabButton,
            BackgroundColor3 = Koda.Theme.AccentColor,
            BackgroundTransparency = 0.88,
            Position = UDim2.new(0, 8, 0.5, -14),
            Size = UDim2.new(0, 28, 0, 28),
            ZIndex = 2
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = TabIconFrame })

        local TabIconLabel;
        local IsImage = (type(Icon) == "string" and (Icon:match("rbxassetid://") or Icon:match("http://") or Icon:match("https://") or tonumber(Icon))) or (type(Icon) == "number")
         
         if IsImage then
             TabIconLabel = Create("ImageLabel", {
                 Parent = TabIconFrame,
                 BackgroundTransparency = 1,
                 Size = UDim2.new(0, 16, 0, 16),
                 AnchorPoint = Vector2.new(0.5, 0.5),
                 Position = UDim2.new(0.5, 0, 0.5, 0),
                 Image = (type(Icon) == "number" or tonumber(Icon)) and "rbxassetid://" .. tostring(Icon) or Icon,
                 ImageColor3 = Koda.Theme.AccentColor,
                 ZIndex = 3
             })
        else
            TabIconLabel = Create("TextLabel", {
                Parent = TabIconFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = Icon or "◆",
                TextColor3 = Koda.Theme.AccentColor,
                TextSize = 13,
                ZIndex = 3
            })
        end

        local TabLabel = Create("TextLabel", {
            Name = "Label",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 44, 0, 0),
            Size = UDim2.new(1, -50, 1, 0),
            Font = Enum.Font.GothamSemibold,
            Text = Name,
            TextColor3 = Koda.Theme.SecondaryTextColor,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 2
        })

        -- Active left-bar indicator with gradient
        local TabIndicator = Create("Frame", {
            Name = "Indicator",
            Parent = TabButton,
            BackgroundColor3 = Koda.Theme.AccentColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.12, 0),
            Size = UDim2.new(0, 4, 0.76, 0),
            Visible = false,
            ZIndex = 3
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = TabIndicator })
        Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Koda.Theme.AccentColor),
                ColorSequenceKeypoint.new(1, Koda.Theme.SecondaryAccent)
            }),
            Rotation = 90,
            Parent = TabIndicator
        })

        -- Hover effect for inactive tabs
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab and Window.CurrentTab.Button == TabButton then return end
            Tween(TabButton, 0.2, {BackgroundTransparency = 0.92})
            Tween(TabLabel, 0.2, {TextColor3 = Koda.Theme.TextColor})
        end)
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab and Window.CurrentTab.Button == TabButton then return end
            Tween(TabButton, 0.2, {BackgroundTransparency = 1})
            Tween(TabLabel, 0.2, {TextColor3 = Koda.Theme.SecondaryTextColor})
        end)
        
        local TabContent = Create("CanvasGroup", {
            Name = Name .. "Content",
            Parent = Container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            GroupTransparency = 0
        })

        local TabScroll = Create("ScrollingFrame", {
            Name = "Scroll",
            Parent = TabContent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Koda.Theme.AccentColor,
            ScrollBarImageTransparency = 0.5,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ElasticBehavior = Enum.ElasticBehavior.Always,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
        })
        
        local TabList = Create("UIListLayout", {
            Parent = TabScroll,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })

        TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabScroll.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 60)
        end)
        
        Create("UIPadding", {
            Parent = TabScroll,
            PaddingTop = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12)
        })

        local Tab = {
            Elements = {}
        }
        
        -- ═══════════════════════════════════════════════════════
        -- SECTION
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateSection(Name)
            local SectionFrame = Create("Frame", {
                Name = Name .. "Section",
                Parent = TabScroll,
                BackgroundColor3 = Koda.Theme.AccentColor,
                BackgroundTransparency = 0.88,
                BorderSizePixel = 0,
                Size = UDim2.new(0.94, 0, 0, 34)
            })
            
            Create("UICorner", {
                CornerRadius = UDim.new(0, 10),
                Parent = SectionFrame
            })

            -- Accent bar
            local sBar = Create("Frame", {
                Parent = SectionFrame,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0.15, 0),
                Size = UDim2.new(0, 4, 0.7, 0)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = sBar })
            local sBarGrad = Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Koda.Theme.AccentColor),
                    ColorSequenceKeypoint.new(1, Koda.Theme.SecondaryAccent)
                }),
                Rotation = 90,
                Parent = sBar
            })
            AnimateGradient(sBarGrad)
            
            Create("TextLabel", {
                Name = "Title",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 0),
                Size = UDim2.new(1, -16, 1, 0),
                Font = Enum.Font.GothamBlack,
                Text = "  " .. Name:upper(),
                TextColor3 = Koda.Theme.AccentColor,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = 0.05
            })

            return SectionFrame
        end

        -- ═══════════════════════════════════════════════════════
        -- LABEL
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateLabel(Text, Icon)
            local LabelFrame = Create("Frame", {
                Name = "Label",
                Parent = TabScroll,
                BackgroundColor3 = Koda.Theme.ElementColor,
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
                Size = UDim2.new(0.93, 0, 0, 32)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = LabelFrame })
            
            Create("TextLabel", {
                Parent = LabelFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -24, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = (Icon or "ℹ️") .. "  " .. (Text or "Label"),
                TextColor3 = Koda.Theme.SecondaryTextColor,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            return {
                Set = function(_, NewText)
                    LabelFrame:FindFirstChildOfClass("TextLabel").Text = (Icon or "ℹ️") .. "  " .. NewText
                end
            }
        end

        -- ═══════════════════════════════════════════════════════
        -- PARAGRAPH
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateParagraph(Props)
            Props = Props or {}
            Props.Title = Props.Title or "Paragraph"
            Props.Content = Props.Content or "Content text here."

            local textH = TextService:GetTextSize(Props.Content, 12, Enum.Font.GothamMedium, Vector2.new(380, 1000)).Y

            local ParagraphFrame = Create("Frame", {
                Name = "Paragraph",
                Parent = TabScroll,
                BackgroundColor3 = Koda.Theme.ElementColor,
                BackgroundTransparency = 0.15,
                BorderSizePixel = 0,
                Size = UDim2.new(0.93, 0, 0, 42 + textH)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = ParagraphFrame })
            Create("UIStroke", { Color = Koda.Theme.StrokeColor, Thickness = 1, Transparency = 0.3, Parent = ParagraphFrame })

            Create("TextLabel", {
                Parent = ParagraphFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 10),
                Size = UDim2.new(1, -28, 0, 18),
                Font = Enum.Font.GothamBold,
                Text = Props.Title,
                TextColor3 = Koda.Theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            Create("TextLabel", {
                Parent = ParagraphFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 30),
                Size = UDim2.new(1, -28, 0, textH + 8),
                Font = Enum.Font.GothamMedium,
                Text = Props.Content,
                TextColor3 = Koda.Theme.SecondaryTextColor,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true
            })

            return ParagraphFrame
        end

        -- ═══════════════════════════════════════════════════════
        -- BUTTON (Enhanced)
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateButton(Props)
            Props = Props or {}
            Props.Name = Props.Name or "Button"
            Props.Callback = Props.Callback or function() end
            Props.Description = Props.Description or nil
            
            local height = Props.Description and 58 or 46
            
            local ButtonFrame = Create("Frame", {
                Name = Props.Name .. "Button",
                Parent = TabScroll,
                BackgroundColor3 = Koda.Theme.ElementColor,
                BackgroundTransparency = 0.05,
                BorderSizePixel = 0,
                Size = UDim2.new(0.94, 0, 0, height),
                ClipsDescendants = true
            })
            
            Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = ButtonFrame })
            local bStroke = Create("UIStroke", {
                Color = Koda.Theme.StrokeColor,
                Thickness = 1,
                Transparency = 0.3,
                Parent = ButtonFrame
            })

            Create("TextLabel", {
                Parent = ButtonFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, Props.Description and 8 or 0),
                Size = UDim2.new(1, -65, 0, Props.Description and 22 or height),
                Font = Enum.Font.GothamSemibold,
                Text = Props.Name,
                TextColor3 = Koda.Theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            if Props.Description then
                Create("TextLabel", {
                    Parent = ButtonFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 16, 0, 30),
                    Size = UDim2.new(1, -65, 0, 18),
                    Font = Enum.Font.GothamMedium,
                    Text = Props.Description,
                    TextColor3 = Koda.Theme.SecondaryTextColor,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTransparency = 0.15
                })
            end

            -- Arrow icon (pill style)
            local ArrowBadge = Create("Frame", {
                Parent = ButtonFrame,
                BackgroundColor3 = Koda.Theme.AccentColor,
                BackgroundTransparency = 0.85,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.new(0, 30, 0, 22)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ArrowBadge })
            local ArrowIcon = Create("TextLabel", {
                Parent = ArrowBadge,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = ">",
                TextColor3 = Koda.Theme.AccentColor,
                TextSize = 18,
                TextTransparency = 0.2
            })

            local Button = Create("TextButton", {
                Parent = ButtonFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                AutoButtonColor = false
            })

            Button.MouseEnter:Connect(function()
                Tween(ButtonFrame, 0.2, {BackgroundTransparency = 0})
                Tween(bStroke, 0.2, {Color = Koda.Theme.AccentColor, Transparency = 0.4})
                Tween(ArrowBadge, 0.2, {BackgroundTransparency = 0.65, Size = UDim2.new(0, 34, 0, 24)})
            end)
            
            Button.MouseLeave:Connect(function()
                Tween(ButtonFrame, 0.2, {BackgroundTransparency = 0.05})
                Tween(bStroke, 0.2, {Color = Koda.Theme.StrokeColor, Transparency = 0.3})
                Tween(ArrowBadge, 0.2, {BackgroundTransparency = 0.85, Size = UDim2.new(0, 30, 0, 22)})
            end)
            
            Button.MouseButton1Click:Connect(function()
                Ripple(ButtonFrame, Koda.Theme.AccentColor)
                Tween(ButtonFrame, 0.07, {Size = UDim2.new(0.92, 0, 0, height - 3)})
                task.wait(0.07)
                Tween(ButtonFrame, 0.18, {Size = UDim2.new(0.94, 0, 0, height)})
                Props.Callback()
            end)

            return {
                Set = function(_, NewName)
                    ButtonFrame:FindFirstChildOfClass("TextLabel").Text = NewName
                end
            }
        end

        -- ═══════════════════════════════════════════════════════
        -- TOGGLE (Enhanced)
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateToggle(Props)
            Props = Props or {}
            Props.Name = Props.Name or "Toggle"
            Props.CurrentValue = Props.CurrentValue or false
            Props.Callback = Props.Callback or function() end
            Props.Description = Props.Description or nil
            local Toggled = Props.CurrentValue

            local height = Props.Description and 58 or 46

            local ToggleFrame = Create("Frame", {
                Name = Props.Name .. "Toggle",
                Parent = TabScroll,
                BackgroundColor3 = Koda.Theme.ElementColor,
                BackgroundTransparency = 0.05,
                BorderSizePixel = 0,
                Size = UDim2.new(0.94, 0, 0, height),
                ClipsDescendants = true
            })
            
            Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = ToggleFrame })
            local tStroke = Create("UIStroke", {
                Color = Koda.Theme.StrokeColor,
                Thickness = 1,
                Transparency = 0.3,
                Parent = ToggleFrame
            })

            Create("TextLabel", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, Props.Description and 8 or 0),
                Size = UDim2.new(1, -80, 0, Props.Description and 22 or height),
                Font = Enum.Font.GothamSemibold,
                Text = Props.Name,
                TextColor3 = Koda.Theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            if Props.Description then
                Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 26),
                    Size = UDim2.new(1, -70, 0, 16),
                    Font = Enum.Font.GothamMedium,
                    Text = Props.Description,
                    TextColor3 = Koda.Theme.SecondaryTextColor,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTransparency = 0.2
                })
            end

            local OuterToggle = Create("Frame", {
                Name = "Outer",
                Parent = ToggleFrame,
                BackgroundColor3 = Color3.fromRGB(25, 30, 50),
                Position = UDim2.new(1, -62, 0.5, -12),
                Size = UDim2.new(0, 48, 0, 24)
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = OuterToggle })
            Create("UIStroke", { Color = Koda.Theme.StrokeColor, Thickness = 1, Transparency = 0.4, Parent = OuterToggle })

            local InnerToggle = Create("Frame", {
                Name = "Inner",
                Parent = OuterToggle,
                BackgroundColor3 = Koda.Theme.SecondaryTextColor,
                Position = Toggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
                Size = UDim2.new(0, 20, 0, 20)
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = InnerToggle })
            
            -- Glow inside the toggle dot when active
            local InnerGlow = Create("Frame", {
                Name = "Glow",
                Parent = InnerToggle,
                BackgroundColor3 = Koda.Theme.AccentColor,
                BackgroundTransparency = Toggled and 0.5 or 1,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(0, 8, 0, 8)
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = InnerGlow })

            local Button = Create("TextButton", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                AutoButtonColor = false
            })

            local function Update()
                if Toggled then
                    Tween(OuterToggle, 0.25, {BackgroundColor3 = Koda.Theme.AccentColor})
                    TweenBounce(InnerToggle, 0.3, {Position = UDim2.new(1, -22, 0.5, -10), BackgroundColor3 = Color3.new(1, 1, 1)})
                    Tween(InnerGlow, 0.25, {BackgroundTransparency = 0.4})
                    Tween(tStroke, 0.25, {Color = Koda.Theme.AccentColor, Transparency = 0.5})
                else
                    Tween(OuterToggle, 0.25, {BackgroundColor3 = Color3.fromRGB(25, 30, 50)})
                    Tween(InnerToggle, 0.25, {Position = UDim2.new(0, 2, 0.5, -10), BackgroundColor3 = Koda.Theme.SecondaryTextColor})
                    Tween(InnerGlow, 0.25, {BackgroundTransparency = 1})
                    Tween(tStroke, 0.25, {Color = Koda.Theme.StrokeColor, Transparency = 0.3})
                end
                Props.Callback(Toggled)
            end

            Button.MouseEnter:Connect(function()
                Tween(ToggleFrame, 0.2, {BackgroundTransparency = 0})
            end)
            Button.MouseLeave:Connect(function()
                Tween(ToggleFrame, 0.2, {BackgroundTransparency = 0.05})
            end)

            Button.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                Update()
            end)

            if Toggled then Update() end

            return {
                Set = function(_, NewValue)
                    Toggled = NewValue
                    Update()
                end,
                Get = function()
                    return Toggled
                end
            }
        end

        -- ═══════════════════════════════════════════════════════
        -- SLIDER (Enhanced)
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateSlider(Props)
            Props = Props or {}
            Props.Name = Props.Name or "Slider"
            Props.Min = Props.Min or 0
            Props.Max = Props.Max or 100
            Props.CurrentValue = Props.CurrentValue or 50
            Props.Increment = Props.Increment or 1
            Props.Suffix = Props.Suffix or ""
            Props.Callback = Props.Callback or function() end
            local Value = Props.CurrentValue

            local SliderFrame = Create("Frame", {
                Name = Props.Name .. "Slider",
                Parent = TabScroll,
                BackgroundColor3 = Koda.Theme.ElementColor,
                BackgroundTransparency = 0.05,
                BorderSizePixel = 0,
                Size = UDim2.new(0.94, 0, 0, 62)
            })
            
            Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = SliderFrame })
            Create("UIStroke", {
                Color = Koda.Theme.StrokeColor,
                Thickness = 1,
                Transparency = 0.3,
                Parent = SliderFrame
            })

            Create("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 10),
                Size = UDim2.new(1, -90, 0, 20),
                Font = Enum.Font.GothamSemibold,
                Text = Props.Name,
                TextColor3 = Koda.Theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            -- Value badge
            local ValueBadge = Create("Frame", {
                Parent = SliderFrame,
                BackgroundColor3 = Koda.Theme.AccentColor,
                BackgroundTransparency = 0.8,
                Position = UDim2.new(1, -78, 0, 8),
                Size = UDim2.new(0, 66, 0, 22)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ValueBadge })

            local ValueLabel = Create("TextLabel", {
                Parent = ValueBadge,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = tostring(Value) .. Props.Suffix,
                TextColor3 = Koda.Theme.AccentColor,
                TextSize = 12
            })

            local SliderTrack = Create("Frame", {
                Name = "Track",
                Parent = SliderFrame,
                BackgroundColor3 = Color3.fromRGB(20, 25, 42),
                Position = UDim2.new(0, 16, 1, -20),
                Size = UDim2.new(1, -32, 0, 8)
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderTrack })

            local SliderFill = Create("Frame", {
                Name = "Fill",
                Parent = SliderTrack,
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size = UDim2.new((Value - Props.Min) / (Props.Max - Props.Min), 0, 1, 0)
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderFill })
            local fillGrad = Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Koda.Theme.AccentColor),
                    ColorSequenceKeypoint.new(1, Koda.Theme.SecondaryAccent)
                }),
                Parent = SliderFill
            })

            -- Slider dot with glow
            local SliderDot = Create("Frame", {
                Name = "Dot",
                Parent = SliderFill,
                BackgroundColor3 = Color3.new(1, 1, 1),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 14, 0, 14)
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderDot })
            
            local DotGlow = Create("Frame", {
                Parent = SliderDot,
                BackgroundColor3 = Koda.Theme.AccentColor,
                BackgroundTransparency = 0.7,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, 22, 0, 22)
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = DotGlow })

            local function Update(Input)
                local Percentage
                if typeof(Input) == "number" then
                    Percentage = Input
                else
                    Percentage = math.clamp((Input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                end
                
                -- Snap to increment
                local rawValue = Props.Min + (Props.Max - Props.Min) * Percentage
                Value = math.floor(rawValue / Props.Increment + 0.5) * Props.Increment
                Value = math.clamp(Value, Props.Min, Props.Max)
                Percentage = (Value - Props.Min) / (Props.Max - Props.Min)
                
                ValueLabel.Text = tostring(Value) .. Props.Suffix
                Tween(SliderFill, 0.08, {Size = UDim2.new(Percentage, 0, 1, 0)})
                
                Props.Callback(Value)
            end

            local Dragging = false
            
            SliderFrame.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    Tween(SliderDot, 0.15, {Size = UDim2.new(0, 18, 0, 18)})
                    Tween(DotGlow, 0.15, {BackgroundTransparency = 0.5, Size = UDim2.new(0, 28, 0, 28)})
                    Update(Input)
                end
            end)

            UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                    Tween(SliderDot, 0.15, {Size = UDim2.new(0, 14, 0, 14)})
                    Tween(DotGlow, 0.15, {BackgroundTransparency = 0.7, Size = UDim2.new(0, 22, 0, 22)})
                end
            end)

            UserInputService.InputChanged:Connect(function(Input)
                if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    Update(Input)
                end
            end)

            -- Initialize
            task.spawn(function()
                task.wait()
                Update((Value - Props.Min) / (Props.Max - Props.Min))
            end)

            return {
                Set = function(_, NewValue)
                    Value = math.clamp(NewValue, Props.Min, Props.Max)
                    Update((Value - Props.Min) / (Props.Max - Props.Min))
                end,
                Get = function()
                    return Value
                end
            }
        end

        -- ═══════════════════════════════════════════════════════
        -- INPUT (Enhanced)
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateInput(Props)
            Props = Props or {}
            Props.Name = Props.Name or "Input"
            Props.Placeholder = Props.Placeholder or "Type here..."
            Props.Callback = Props.Callback or function() end
            Props.Description = Props.Description or nil

            local height = Props.Description and 52 or 42

            local InputFrame = Create("Frame", {
                Name = Props.Name .. "Input",
                Parent = TabScroll,
                BackgroundColor3 = Koda.Theme.ElementColor,
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Size = UDim2.new(0.93, 0, 0, height)
            })
            
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = InputFrame })
            Create("UIStroke", {
                Color = Koda.Theme.StrokeColor,
                Thickness = 1,
                Transparency = 0.2,
                Parent = InputFrame
            })

            Create("TextLabel", {
                Parent = InputFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, Props.Description and 4 or 0),
                Size = UDim2.new(0.4, 0, 0, Props.Description and 22 or height),
                Font = Enum.Font.GothamSemibold,
                Text = Props.Name,
                TextColor3 = Koda.Theme.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            if Props.Description then
                Create("TextLabel", {
                    Parent = InputFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 24),
                    Size = UDim2.new(0.4, 0, 0, 16),
                    Font = Enum.Font.GothamMedium,
                    Text = Props.Description,
                    TextColor3 = Koda.Theme.SecondaryTextColor,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTransparency = 0.2
                })
            end

            local InputBox = Create("TextBox", {
                Parent = InputFrame,
                BackgroundColor3 = Koda.Theme.DarkerColor,
                Position = UDim2.new(1, -175, 0.5, -13),
                Size = UDim2.new(0, 160, 0, 26),
                Font = Enum.Font.GothamMedium,
                PlaceholderText = Props.Placeholder,
                Text = "",
                TextColor3 = Koda.Theme.TextColor,
                PlaceholderColor3 = Koda.Theme.SecondaryTextColor,
                TextSize = 12,
                ClearTextOnFocus = false
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = InputBox })
            
            local inputStroke = Create("UIStroke", {
                Color = Koda.Theme.StrokeColor,
                Thickness = 1,
                Transparency = 0.2,
                Parent = InputBox
            })
            Create("UIPadding", {
                Parent = InputBox,
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8)
            })

            InputBox.Focused:Connect(function()
                Tween(inputStroke, 0.2, {Color = Koda.Theme.AccentColor, Transparency = 0})
            end)

            InputBox.FocusLost:Connect(function(EnterPressed)
                Tween(inputStroke, 0.2, {Color = Koda.Theme.StrokeColor, Transparency = 0.2})
                Props.Callback(InputBox.Text, EnterPressed)
            end)

            return {
                Set = function(_, NewValue)
                    InputBox.Text = NewValue
                    Props.Callback(NewValue, false)
                end,
                Get = function()
                    return InputBox.Text
                end
            }
        end

        -- ═══════════════════════════════════════════════════════
        -- DROPDOWN (Enhanced)
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateDropdown(Props)
            Props = Props or {}
            Props.Name = Props.Name or "Dropdown"
            Props.Options = Props.Options or {"Option 1", "Option 2"}
            Props.CurrentOption = Props.CurrentOption or Props.Options[1]
            Props.Callback = Props.Callback or function() end
            local Selected = Props.CurrentOption
            local Opened = false

            local DropdownFrame = Create("Frame", {
                Name = Props.Name .. "Dropdown",
                Parent = TabScroll,
                BackgroundColor3 = Koda.Theme.ElementColor,
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Size = UDim2.new(0.93, 0, 0, 42),
                ClipsDescendants = true
            })
            
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = DropdownFrame })
            local ddStroke = Create("UIStroke", {
                Color = Koda.Theme.StrokeColor,
                Thickness = 1,
                Transparency = 0.2,
                Parent = DropdownFrame
            })

            Create("TextLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(1, -130, 0, 42),
                Font = Enum.Font.GothamSemibold,
                Text = Props.Name,
                TextColor3 = Koda.Theme.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            -- Selected value badge
            local SelectedBadge = Create("Frame", {
                Parent = DropdownFrame,
                BackgroundColor3 = Koda.Theme.AccentColor,
                BackgroundTransparency = 0.85,
                Position = UDim2.new(1, -130, 0, 10),
                Size = UDim2.new(0, 90, 0, 22)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = SelectedBadge })

            local SelectedLabel = Create("TextLabel", {
                Parent = SelectedBadge,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = Selected,
                TextColor3 = Koda.Theme.AccentColor,
                TextSize = 11,
                TextTruncate = Enum.TextTruncate.AtEnd
            })

            -- Animated arrow
            local Arrow = Create("TextLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -32, 0, 12),
                Size = UDim2.new(0, 18, 0, 18),
                Font = Enum.Font.GothamBold,
                Text = "▼",
                TextColor3 = Koda.Theme.SecondaryTextColor,
                TextSize = 10,
                Rotation = 0
            })

            -- Items container with separator
            Create("Frame", {
                Name = "ItemSep",
                Parent = DropdownFrame,
                BackgroundColor3 = Koda.Theme.StrokeColor,
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 14, 0, 42),
                Size = UDim2.new(1, -28, 0, 1)
            })

            local ItemsContainer = Create("Frame", {
                Name = "Items",
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 46),
                Size = UDim2.new(1, 0, 0, 0)
            })
            
            Create("UIListLayout", {
                Parent = ItemsContainer,
                Padding = UDim.new(0, 3),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            
            Create("UIPadding", {
                Parent = ItemsContainer,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 6)
            })

            local function Toggle(State)
                Opened = State
                Tween(Arrow, 0.25, {Rotation = Opened and 180 or 0})
                Tween(ddStroke, 0.2, {Color = Opened and Koda.Theme.AccentColor or Koda.Theme.StrokeColor})
                
                local ContentSize = 42
                if Opened then
                    ContentSize = ContentSize + 8
                    for _, _ in pairs(Props.Options) do
                        ContentSize = ContentSize + 31
                    end
                    ContentSize = ContentSize + 6
                end
                
                Tween(DropdownFrame, 0.35, {Size = UDim2.new(0.93, 0, 0, ContentSize)})
            end

            local function UpdateSelection(Value)
                Selected = Value
                SelectedLabel.Text = Selected
                
                for _, child in pairs(ItemsContainer:GetChildren()) do
                    if child:IsA("Frame") and child:FindFirstChild("Btn") then
                        local isSelected = child.Name == Selected
                        Tween(child, 0.15, {
                            BackgroundColor3 = isSelected and Koda.Theme.AccentColor or Koda.Theme.DarkerColor,
                            BackgroundTransparency = isSelected and 0.8 or 0.2
                        })
                        local btnLabel = child:FindFirstChild("BtnLabel")
                        if btnLabel then
                            Tween(btnLabel, 0.15, {TextColor3 = isSelected and Koda.Theme.AccentColor or Koda.Theme.SecondaryTextColor})
                        end
                        local check = child:FindFirstChild("Check")
                        if check then
                            check.Visible = isSelected
                        end
                    end
                end
                
                Props.Callback(Selected)
            end

            local function AddOption(Value)
                local optFrame = Create("Frame", {
                    Name = Value,
                    Parent = ItemsContainer,
                    BackgroundColor3 = (Value == Selected) and Koda.Theme.AccentColor or Koda.Theme.DarkerColor,
                    BackgroundTransparency = (Value == Selected) and 0.8 or 0.2,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 28)
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = optFrame })

                local btnLabel = Create("TextLabel", {
                    Name = "BtnLabel",
                    Parent = optFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -30, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = Value,
                    TextColor3 = (Value == Selected) and Koda.Theme.AccentColor or Koda.Theme.SecondaryTextColor,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local check = Create("TextLabel", {
                    Name = "Check",
                    Parent = optFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -24, 0, 0),
                    Size = UDim2.new(0, 18, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "✓",
                    TextColor3 = Koda.Theme.AccentColor,
                    TextSize = 12,
                    Visible = (Value == Selected)
                })

                local btn = Create("TextButton", {
                    Name = "Btn",
                    Parent = optFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    AutoButtonColor = false
                })

                btn.MouseEnter:Connect(function()
                    if optFrame.Name ~= Selected then
                        Tween(optFrame, 0.15, {BackgroundTransparency = 0.1})
                    end
                end)
                btn.MouseLeave:Connect(function()
                    if optFrame.Name ~= Selected then
                        Tween(optFrame, 0.15, {BackgroundTransparency = 0.2})
                    end
                end)
                
                btn.MouseButton1Click:Connect(function()
                    Ripple(optFrame, Koda.Theme.AccentColor)
                    UpdateSelection(Value)
                    task.wait(0.1)
                    Toggle(false)
                end)
            end

            for _, opt in pairs(Props.Options) do
                AddOption(opt)
            end

            local MainButton = Create("TextButton", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 42),
                Text = "",
                AutoButtonColor = false
            })

            MainButton.MouseButton1Click:Connect(function()
                Toggle(not Opened)
            end)

            return {
                Set = function(_, NewValue)
                    UpdateSelection(NewValue)
                end,
                Get = function()
                    return Selected
                end,
                Refresh = function(_, NewOptions, ClearOld)
                    if ClearOld then
                        for _, child in pairs(ItemsContainer:GetChildren()) do
                            if child:IsA("Frame") then child:Destroy() end
                        end
                    end
                    Props.Options = NewOptions
                    for _, opt in pairs(NewOptions) do
                        AddOption(opt)
                    end
                    if Opened then
                        Toggle(false)
                        task.wait(0.1)
                        Toggle(true)
                    end
                end
            }
        end

        -- ═══════════════════════════════════════════════════════
        -- COLOR PICKER
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateColorPicker(Props)
            Props = Props or {}
            Props.Name = Props.Name or "Color Picker"
            Props.Default = Props.Default or Color3.fromRGB(99, 102, 241)
            Props.Callback = Props.Callback or function() end
            local CurrentColor = Props.Default

            local PickerFrame = Create("Frame", {
                Name = Props.Name .. "ColorPicker",
                Parent = TabScroll,
                BackgroundColor3 = Koda.Theme.ElementColor,
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Size = UDim2.new(0.93, 0, 0, 42)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = PickerFrame })
            Create("UIStroke", { Color = Koda.Theme.StrokeColor, Thickness = 1, Transparency = 0.2, Parent = PickerFrame })

            Create("TextLabel", {
                Parent = PickerFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Enum.Font.GothamSemibold,
                Text = Props.Name,
                TextColor3 = Koda.Theme.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ColorPreview = Create("Frame", {
                Parent = PickerFrame,
                BackgroundColor3 = CurrentColor,
                Position = UDim2.new(1, -42, 0.5, -11),
                Size = UDim2.new(0, 28, 0, 22)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ColorPreview })
            Create("UIStroke", { Color = Koda.Theme.StrokeColor, Thickness = 1, Parent = ColorPreview })

            local PreviewBtn = Create("TextButton", {
                Parent = PickerFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                AutoButtonColor = false
            })

            PreviewBtn.MouseButton1Click:Connect(function()
                -- Simple color cycle for now (can be expanded)
                local h, s, v = CurrentColor:ToHSV()
                h = (h + 0.05) % 1
                CurrentColor = Color3.fromHSV(h, s, v)
                Tween(ColorPreview, 0.2, {BackgroundColor3 = CurrentColor})
                Props.Callback(CurrentColor)
            end)

            return {
                Set = function(_, NewColor)
                    CurrentColor = NewColor
                    Tween(ColorPreview, 0.2, {BackgroundColor3 = CurrentColor})
                    Props.Callback(CurrentColor)
                end,
                Get = function()
                    return CurrentColor
                end
            }
        end

        -- ═══════════════════════════════════════════════════════
        -- KEYBIND
        -- ═══════════════════════════════════════════════════════
        function Tab:CreateKeybind(Props)
            Props = Props or {}
            Props.Name = Props.Name or "Keybind"
            Props.CurrentKeybind = Props.CurrentKeybind or "E"
            Props.Callback = Props.Callback or function() end
            local CurrentKey = Props.CurrentKeybind
            local Listening = false

            local KeybindFrame = Create("Frame", {
                Name = Props.Name .. "Keybind",
                Parent = TabScroll,
                BackgroundColor3 = Koda.Theme.ElementColor,
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Size = UDim2.new(0.93, 0, 0, 42)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = KeybindFrame })
            Create("UIStroke", { Color = Koda.Theme.StrokeColor, Thickness = 1, Transparency = 0.2, Parent = KeybindFrame })

            Create("TextLabel", {
                Parent = KeybindFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(1, -80, 1, 0),
                Font = Enum.Font.GothamSemibold,
                Text = Props.Name,
                TextColor3 = Koda.Theme.TextColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local KeyBadge = Create("Frame", {
                Parent = KeybindFrame,
                BackgroundColor3 = Koda.Theme.DarkerColor,
                Position = UDim2.new(1, -68, 0.5, -12),
                Size = UDim2.new(0, 54, 0, 24)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = KeyBadge })
            Create("UIStroke", { Color = Koda.Theme.StrokeColor, Thickness = 1, Parent = KeyBadge })

            local KeyLabel = Create("TextLabel", {
                Parent = KeyBadge,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = CurrentKey,
                TextColor3 = Koda.Theme.AccentColor,
                TextSize = 11
            })

            local KeyBtn = Create("TextButton", {
                Parent = KeybindFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                AutoButtonColor = false
            })

            KeyBtn.MouseButton1Click:Connect(function()
                Listening = true
                KeyLabel.Text = "..."
                Tween(KeyBadge, 0.2, {BackgroundColor3 = Koda.Theme.AccentColor})
                Tween(KeyLabel, 0.2, {TextColor3 = Color3.new(1, 1, 1)})
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if Listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    CurrentKey = input.KeyCode.Name
                    KeyLabel.Text = CurrentKey
                    Listening = false
                    Tween(KeyBadge, 0.2, {BackgroundColor3 = Koda.Theme.DarkerColor})
                    Tween(KeyLabel, 0.2, {TextColor3 = Koda.Theme.AccentColor})
                    Props.Callback(CurrentKey)
                end
            end)

            return {
                Set = function(_, NewKey)
                    CurrentKey = NewKey
                    KeyLabel.Text = CurrentKey
                end,
                Get = function()
                    return CurrentKey
                end
            }
        end

        -- ═══════════════════════════════════════════════════════
        -- TAB SELECTION
        -- ═══════════════════════════════════════════════════════
        function Tab:Select()
            if Window.CurrentTab and Window.CurrentTab.Content == TabContent then
                return
            end

            if Window.CurrentTab then
                local OldContent = Window.CurrentTab.Content
                local OldBtn = Window.CurrentTab.Button
                local OldLabel = OldBtn:FindFirstChild("Label")
                local OldIconFrame = OldBtn:FindFirstChild("IconFrame")
                
                OldContent.Visible = false
                OldContent.GroupTransparency = 0
                OldContent.Position = UDim2.new(0, 0, 0, 0)
                
                Tween(OldBtn, 0.25, {BackgroundTransparency = 1})
                if OldLabel then Tween(OldLabel, 0.25, {TextColor3 = Koda.Theme.SecondaryTextColor}) end
                if OldIconFrame then
                    Tween(OldIconFrame, 0.25, {BackgroundTransparency = 0.9})
                    local iconLabel = OldIconFrame:FindFirstChildOfClass("TextLabel") or OldIconFrame:FindFirstChildOfClass("ImageLabel")
                    if iconLabel then
                        if iconLabel:IsA("TextLabel") then
                            Tween(iconLabel, 0.25, {TextColor3 = Koda.Theme.AccentColor})
                        else
                            Tween(iconLabel, 0.25, {ImageColor3 = Koda.Theme.AccentColor})
                        end
                    end
                end
                
                local OldInd = OldBtn:FindFirstChild("Indicator")
                if OldInd then
                    Tween(OldInd, 0.2, {Size = UDim2.new(0, 0, 0.7, 0)})
                    task.delay(0.2, function() OldInd.Visible = false end)
                end
            end

            -- Animate new tab in
            TabContent.Visible = true
            TabContent.Position = UDim2.new(0.04, 0, 0, 12)
            TabContent.GroupTransparency = 1
            Tween(TabContent, 0.3, {Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0})
            
            Tween(TabButton, 0.25, {BackgroundTransparency = 0.82})
            
            local tabLabel = TabButton:FindFirstChild("Label")
            if tabLabel then Tween(tabLabel, 0.25, {TextColor3 = Koda.Theme.TextColor}) end
            
            local iconFrame = TabButton:FindFirstChild("IconFrame")
            if iconFrame then
                Tween(iconFrame, 0.25, {BackgroundTransparency = 0.75})
                local iconLabel = iconFrame:FindFirstChildOfClass("TextLabel") or iconFrame:FindFirstChildOfClass("ImageLabel")
                if iconLabel then
                    if iconLabel:IsA("TextLabel") then
                        Tween(iconLabel, 0.25, {TextColor3 = Color3.new(1, 1, 1)})
                    else
                        Tween(iconLabel, 0.25, {ImageColor3 = Color3.new(1, 1, 1)})
                    end
                end
            end
            
            TabIndicator.Visible = true
            TabIndicator.Size = UDim2.new(0, 0, 0.7, 0)
            TweenBounce(TabIndicator, 0.3, {Size = UDim2.new(0, 3, 0.7, 0)})
            
            Window.CurrentTab = {Button = TabButton, Content = TabContent}
        end
        
        TabButton.MouseButton1Click:Connect(function()
            Tab:Select()
        end)
        
        if not Window.CurrentTab then
            Tab:Select()
        end
        
        return Tab
    end
    
    -- ═══════════════════════════════════════════════════════
    -- LOADING SCREEN
    -- ═══════════════════════════════════════════════════════
    local LoadingFrame = Create("Frame", {
        Name = "LoadingFrame",
        Parent = MainFrame,
        BackgroundColor3 = Koda.Theme.MainColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 100
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = LoadingFrame })

    -- Subtle background gradient
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Koda.Theme.MainColor),
            ColorSequenceKeypoint.new(0.5, Color3.new(
                math.min(Koda.Theme.MainColor.R * 1.15, 1),
                math.min(Koda.Theme.MainColor.G * 1.15, 1),
                math.min(Koda.Theme.MainColor.B * 1.15, 1)
            )),
            ColorSequenceKeypoint.new(1, Koda.Theme.MainColor)
        }),
        Rotation = 45,
        Parent = LoadingFrame
    })

    -- Animated logo in loading
    local LoadingLogo = Create("Frame", {
        Parent = LoadingFrame,
        BackgroundColor3 = Color3.new(1, 1, 1),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.33, 0),
        Size = UDim2.new(0, 64, 0, 64),
        ZIndex = 101
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 18), Parent = LoadingLogo })
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Koda.Theme.AccentColor),
            ColorSequenceKeypoint.new(1, Koda.Theme.SecondaryAccent)
        }),
        Rotation = 135,
        Parent = LoadingLogo
    })
    GlowEffect(LoadingLogo, Koda.Theme.AccentColor, 30, 0.7)
    
    local LoadingLogoText = Create("TextLabel", {
        Parent = LoadingLogo,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBlack,
        Text = string.sub(Config.Name, 1, 1):upper(),
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 30,
        ZIndex = 102
    })

    -- Pulse animation on logo
    task.spawn(function()
        while LoadingLogo and LoadingLogo.Parent do
            Tween(LoadingLogo, 0.8, {Size = UDim2.new(0, 68, 0, 68), Rotation = 5})
            task.wait(0.8)
            Tween(LoadingLogo, 0.8, {Size = UDim2.new(0, 60, 0, 60), Rotation = -5})
            task.wait(0.8)
        end
    end)

    local LoadingTitle = Create("TextLabel", {
        Parent = LoadingFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 200),
        Size = UDim2.new(1, 0, 0, 36),
        Font = Enum.Font.GothamBlack,
        Text = Config.LoadingTitle or Config.Name,
        TextColor3 = Koda.Theme.TextColor,
        TextSize = 26,
        ZIndex = 101,
        TextTransparency = 0
    })
    
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Koda.Theme.AccentColor),
            ColorSequenceKeypoint.new(0.5, Koda.Theme.SecondaryAccent),
            ColorSequenceKeypoint.new(1, Koda.Theme.AccentColor)
        }),
        Parent = LoadingTitle
    })

    local LoadingSubtitle = Create("TextLabel", {
        Parent = LoadingFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 242),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.GothamMedium,
        Text = Config.LoadingSubtitle or "Inicializando módulos...",
        TextColor3 = Koda.Theme.SecondaryTextColor,
        TextSize = 13,
        ZIndex = 101,
        TextTransparency = 0
    })

    -- Loading progress bar with glow
    local ProgressBack = Create("Frame", {
        Parent = LoadingFrame,
        BackgroundColor3 = Color3.fromRGB(20, 25, 42),
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 300),
        Size = UDim2.new(0, 280, 0, 7),
        ZIndex = 101
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ProgressBack })

    local ProgressFill = Create("Frame", {
        Parent = ProgressBack,
        BackgroundColor3 = Color3.new(1, 1, 1),
        Size = UDim2.new(0, 0, 1, 0),
        ZIndex = 102
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ProgressFill })
    
    local progressGrad = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Koda.Theme.AccentColor),
            ColorSequenceKeypoint.new(0.5, Koda.Theme.SecondaryAccent),
            ColorSequenceKeypoint.new(1, Koda.Theme.AccentColor)
        }),
        Parent = ProgressFill
    })
    AnimateGradient(progressGrad)

    -- Loading percentage
    local LoadingPercent = Create("TextLabel", {
        Parent = LoadingFrame,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 275),
        Size = UDim2.new(0, 100, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = "0%",
        TextColor3 = Koda.Theme.SecondaryTextColor,
        TextSize = 11,
        ZIndex = 101
    })

    -- ═══════════════════════════════════════════════════════
    -- TOGGLE / KEYBIND LOGIC
    -- ═══════════════════════════════════════════════════════
    local Toggled = true
    local Debounce = false
    
    function Window:Toggle(state)
        if LoadingFrame and LoadingFrame.Parent then return end
        if Debounce then return end
        Debounce = true
        
        if state ~= nil then
            Toggled = state
        else
            Toggled = not Toggled
        end
        
        if Toggled then
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame.GroupTransparency = 1
            TweenBounce(MainFrame, 0.5, {Size = Config.Size})
            Tween(MainFrame, 0.3, {GroupTransparency = 0})
        else
            Tween(MainFrame, 0.35, {Size = UDim2.new(0, 0, 0, 0), GroupTransparency = 1})
            task.delay(0.35, function()
                if not Toggled then MainFrame.Visible = false end
            end)
        end
        
        task.wait(0.4)
        Debounce = false
    end

    Window.Keybind = Config.Keybind or Enum.KeyCode.K
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Window.Keybind then
            Window:Toggle()
        end
    end)

    -- ═══════════════════════════════════════════════════════
    -- MOBILE TOGGLE
    -- ═══════════════════════════════════════════════════════
    local MobileToggle = Create("TextButton", {
        Name = "MobileToggle",
        Parent = ScreenGui,
        BackgroundColor3 = Koda.Theme.MainColor,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 6),
        Size = UDim2.new(0, 90, 0, 32),
        Font = Enum.Font.GothamBlack,
        Text = "Show UI",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 11,
        ZIndex = 500,
        AutoButtonColor = false,
        ClipsDescendants = true,
        Visible = false
    })
    
    -- Legibility stroke for text
    Create("UIStroke", {
        Parent = MobileToggle,
        Color = Color3.new(0, 0, 0),
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    })
    Window.MobileToggle = MobileToggle
    
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = MobileToggle })
    local mStroke = Create("UIStroke", { 
        Color = Color3.new(1,1,1), 
        Thickness = 1.5, 
        Parent = MobileToggle,
        Transparency = 0.3
    })
    local mStrokeGrad = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Koda.Theme.AccentColor),
            ColorSequenceKeypoint.new(1, Koda.Theme.SecondaryAccent)
        }),
        Parent = mStroke
    })
    AnimateGradient(mStrokeGrad)
    
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Koda.Theme.AccentColor),
            ColorSequenceKeypoint.new(1, Koda.Theme.SecondaryAccent)
        }),
        Rotation = 90,
        Parent = MobileToggle
    })

    MobileToggle.MouseButton1Click:Connect(function()
        Ripple(MobileToggle, Color3.new(1,1,1))
        Window:Toggle()
    end)

    MakeDraggable(MobileToggle, MobileToggle)

    -- ═══════════════════════════════════════════════════════
    -- LOADING ANIMATION
    -- ═══════════════════════════════════════════════════════
    local function StartLoading()
        task.spawn(function()
            if Koda.LegacyMode then
                Koda:ApplyLegacyOptimization(MainFrame)
            end
            
            MainFrame.Visible = true
            MainFrame.GroupTransparency = 1
            TweenBounce(MainFrame, 0.6, {Size = Config.Size})
            Tween(MainFrame, 0.4, {GroupTransparency = 0})
            task.wait(0.3)
            
            -- Animated loading with percentage
            local steps = 20
            for i = 1, steps do
                local pct = i / steps
                Tween(ProgressFill, 0.06, {Size = UDim2.new(pct, 0, 1, 0)})
                LoadingPercent.Text = math.floor(pct * 100) .. "%"
                
                -- Change subtitle text at milestones
                if i == 5 then LoadingSubtitle.Text = "Carregando componentes..." end
                if i == 10 then LoadingSubtitle.Text = "Preparando interface..." end
                if i == 15 then LoadingSubtitle.Text = "Quase pronto..." end
                if i == steps then LoadingSubtitle.Text = "Concluído!" end
                
                task.wait(0.06)
            end
            
            task.wait(0.3)
            
            -- Fade out loading
            Tween(LoadingFrame, 0.5, {BackgroundTransparency = 1})
            Tween(LoadingTitle, 0.4, {TextTransparency = 1})
            Tween(LoadingSubtitle, 0.4, {TextTransparency = 1})
            Tween(LoadingPercent, 0.4, {TextTransparency = 1})
            Tween(ProgressBack, 0.4, {BackgroundTransparency = 1})
            Tween(ProgressFill, 0.4, {BackgroundTransparency = 1})
            Tween(LoadingLogo, 0.4, {BackgroundTransparency = 1})
            Tween(LoadingLogoText, 0.4, {TextTransparency = 1})
            
            task.wait(0.5)
            LoadingFrame:Destroy()
            
            if Config.StartupNotification then
                Koda:Notify(Config.NotificationConfig or {
                    Title = "Koda Library",
                    Content = "Interface carregada com sucesso!",
                    Duration = 5,
                    Type = "Success"
                })
            end

            -- PC Keybind Alert
            if UserInputService.KeyboardEnabled then
                task.delay(1, function()
                    local keyName = Window.Keybind.Name
                    Koda:Notify({
                        Title = "Dica de Atalho (PC)",
                        Content = "Pressione [" .. keyName .. "] para ocultar ou mostrar a interface.",
                        Duration = 8,
                        Type = "Info"
                    })
                end)
            end
        end)
    end

    -- ═══════════════════════════════════════════════════════
    -- DEVICE SELECTION
    -- ═══════════════════════════════════════════════════════
    local function StartKeyOrLoading()
        if KeySystem then
            local KeyFrame = Create("CanvasGroup", {
                Name = "KeyFrame",
                Parent = ScreenGui,
                BackgroundColor3 = Koda.Theme.MainColor,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, 350, 0, 220),
                ClipsDescendants = true
            })
            
            Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = KeyFrame })
            local kfStroke = Create("UIStroke", { 
                Color = Color3.new(1,1,1), 
                Thickness = 1.5, 
                Parent = KeyFrame,
                Transparency = 0.4
            })
            local kfStrokeGrad = Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Koda.Theme.AccentColor),
                    ColorSequenceKeypoint.new(1, Koda.Theme.SecondaryAccent)
                }),
                Parent = kfStroke
            })
            AnimateGradient(kfStrokeGrad)
            CreateShadow(KeyFrame, 0.5)

            -- Key frame accent line
            CreateGradientBar(KeyFrame, 2, UDim2.new(0, 0, 0, 45))

            -- Key frame topbar
            local KTopBar = Create("Frame", {
                Parent = KeyFrame,
                BackgroundColor3 = Koda.Theme.DarkerColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 46)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = KTopBar })
            Create("Frame", {
                Parent = KTopBar,
                BackgroundColor3 = Koda.Theme.DarkerColor,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -14),
                Size = UDim2.new(1, 0, 0, 14)
            })

            -- Lock icon
            local LockIcon = Create("Frame", {
                Parent = KTopBar,
                BackgroundColor3 = Koda.Theme.AccentColor,
                BackgroundTransparency = 0.85,
                Position = UDim2.new(0, 14, 0.5, -13),
                Size = UDim2.new(0, 26, 0, 26)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = LockIcon })
            Create("TextLabel", {
                Parent = LockIcon,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = "🔒",
                TextSize = 13
            })

            Create("TextLabel", {
                Parent = KTopBar,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 48, 0, 0),
                Size = UDim2.new(1, -90, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = KeySettings.Title or "Verificação Necessária",
                TextColor3 = Koda.Theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local KClose = Create("TextButton", {
                Parent = KTopBar,
                BackgroundColor3 = Koda.Theme.ElementColor,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -38, 0.5, -13),
                Size = UDim2.new(0, 26, 0, 26),
                Font = Enum.Font.GothamBold,
                Text = "✕",
                TextColor3 = Koda.Theme.SecondaryTextColor,
                TextSize = 11,
                AutoButtonColor = false
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = KClose })

            KClose.MouseEnter:Connect(function()
                Tween(KClose, 0.2, {BackgroundTransparency = 0.4, BackgroundColor3 = Color3.fromRGB(200, 50, 50), TextColor3 = Color3.new(1,1,1)})
            end)
            KClose.MouseLeave:Connect(function()
                Tween(KClose, 0.2, {BackgroundTransparency = 1, TextColor3 = Koda.Theme.SecondaryTextColor})
            end)
            KClose.MouseButton1Click:Connect(function()
                Tween(KeyFrame, 0.4, {Size = UDim2.new(0, 0, 0, 0), GroupTransparency = 1})
                task.wait(0.4)
                ScreenGui:Destroy()
            end)

            MakeDraggable(KTopBar, KeyFrame)

            Create("TextLabel", {
                Parent = KeyFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 20, 0, 58),
                Size = UDim2.new(1, -40, 0, 18),
                Font = Enum.Font.GothamMedium,
                Text = KeySettings.Subtitle or "Entre com sua chave para acessar o script",
                TextColor3 = Koda.Theme.SecondaryTextColor,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local KInput = Create("TextBox", {
                Parent = KeyFrame,
                BackgroundColor3 = Koda.Theme.DarkerColor,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 20, 0, 90),
                Size = UDim2.new(1, -40, 0, 36),
                Font = Enum.Font.GothamMedium,
                PlaceholderText = "Insira a chave aqui...",
                Text = "",
                TextColor3 = Koda.Theme.TextColor,
                PlaceholderColor3 = Koda.Theme.SecondaryTextColor,
                TextSize = 13
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = KInput })
            local kInputStroke = Create("UIStroke", { Color = Koda.Theme.StrokeColor, Thickness = 1, Parent = KInput })
            Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = KInput })

            KInput.Focused:Connect(function()
                Tween(kInputStroke, 0.2, {Color = Koda.Theme.AccentColor})
            end)
            KInput.FocusLost:Connect(function()
                Tween(kInputStroke, 0.2, {Color = Koda.Theme.StrokeColor})
            end)

            -- Status label
            local StatusLabel = Create("TextLabel", {
                Parent = KeyFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 20, 0, 130),
                Size = UDim2.new(1, -40, 0, 16),
                Font = Enum.Font.GothamMedium,
                Text = "",
                TextColor3 = Koda.Theme.ErrorColor,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = 1
            })

            local VerifyBtn = Create("TextButton", {
                Parent = KeyFrame,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 20, 1, -55),
                Size = UDim2.new(0.45, -10, 0, 36),
                Font = Enum.Font.GothamBold,
                Text = "Verificar",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 13,
                AutoButtonColor = false,
                ClipsDescendants = true
            })
            
            -- Legibility stroke for text
            Create("UIStroke", {
                Parent = VerifyBtn,
                Color = Color3.new(0, 0, 0),
                Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
            })
            
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = VerifyBtn })
            Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Koda.Theme.AccentColor),
                    ColorSequenceKeypoint.new(1, Koda.Theme.SecondaryAccent)
                }),
                Rotation = 90,
                Parent = VerifyBtn
            })

            local GetKeyBtn = Create("TextButton", {
                Parent = KeyFrame,
                BackgroundColor3 = Koda.Theme.ElementColor,
                BorderSizePixel = 0,
                Position = UDim2.new(0.45, 10, 1, -55),
                Size = UDim2.new(0.55, -30, 0, 36),
                Font = Enum.Font.GothamBold,
                Text = "Obter Chave",
                TextColor3 = Koda.Theme.TextColor,
                TextSize = 13,
                AutoButtonColor = false,
                ClipsDescendants = true
            })
            
            -- Legibility stroke for text
            Create("UIStroke", {
                Parent = GetKeyBtn,
                Color = Color3.new(0, 0, 0),
                Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = GetKeyBtn })
            Create("UIStroke", { Color = Koda.Theme.StrokeColor, Thickness = 1, Parent = GetKeyBtn })

            -- Hover effects
            VerifyBtn.MouseEnter:Connect(function()
                Tween(VerifyBtn, 0.15, {Size = UDim2.new(0.45, -8, 0, 38)})
            end)
            VerifyBtn.MouseLeave:Connect(function()
                Tween(VerifyBtn, 0.15, {Size = UDim2.new(0.45, -10, 0, 36)})
            end)
            GetKeyBtn.MouseEnter:Connect(function()
                Tween(GetKeyBtn, 0.15, {Size = UDim2.new(0.55, -28, 0, 38)})
            end)
            GetKeyBtn.MouseLeave:Connect(function()
                Tween(GetKeyBtn, 0.15, {Size = UDim2.new(0.55, -30, 0, 36)})
            end)

            VerifyBtn.MouseButton1Click:Connect(function()
                Ripple(VerifyBtn, Color3.new(1,1,1))
                if KInput.Text == ValidKey then
                    StatusLabel.Text = "✓ Chave válida!"
                    StatusLabel.TextColor3 = Koda.Theme.SuccessColor
                    Tween(StatusLabel, 0.2, {TextTransparency = 0})
                    task.wait(0.5)
                    Tween(KeyFrame, 0.5, {Size = UDim2.new(0, 0, 0, 0), GroupTransparency = 1})
                    task.wait(0.5)
                    KeyFrame:Destroy()
                    StartLoading()
                else
                    StatusLabel.Text = "✕ Chave inválida! Tente novamente."
                    StatusLabel.TextColor3 = Koda.Theme.ErrorColor
                    Tween(StatusLabel, 0.2, {TextTransparency = 0})
                    
                    -- Shake animation
                    local orig = KeyFrame.Position
                    for _ = 1, 3 do
                        Tween(KeyFrame, 0.04, {Position = orig + UDim2.new(0, 6, 0, 0)}, Enum.EasingStyle.Quad)
                        task.wait(0.04)
                        Tween(KeyFrame, 0.04, {Position = orig - UDim2.new(0, 6, 0, 0)}, Enum.EasingStyle.Quad)
                        task.wait(0.04)
                    end
                    Tween(KeyFrame, 0.04, {Position = orig}, Enum.EasingStyle.Quad)
                    
                    KInput.Text = ""
                    task.wait(2)
                    Tween(StatusLabel, 0.3, {TextTransparency = 1})
                end
            end)

            GetKeyBtn.MouseButton1Click:Connect(function()
                Ripple(GetKeyBtn, Koda.Theme.AccentColor)
                if setclipboard then
                    setclipboard(KeySettings.Link or "https://discord.gg/example")
                    GetKeyBtn.Text = "✓ Copiado!"
                    task.wait(1.5)
                    GetKeyBtn.Text = "Obter Chave"
                else
                    print("Key Link: " .. (KeySettings.Link or "https://discord.gg/example"))
                    GetKeyBtn.Text = "Veja o Console"
                    task.wait(1.5)
                    GetKeyBtn.Text = "Obter Chave"
                end
            end)
        else
            StartLoading()
        end
    end

    local function ShowDeviceSelection()
        local SelectionFrame = Create("CanvasGroup", {
            Name = "DeviceSelection",
            Parent = ScreenGui,
            BackgroundColor3 = Koda.Theme.MainColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 420, 0, 380),
            ClipsDescendants = true,
            ZIndex = 110,
            GroupTransparency = 0
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 16), Parent = SelectionFrame })
        local sStroke = Create("UIStroke", { Color = Koda.Theme.StrokeColor, Thickness = 2, Parent = SelectionFrame })

        local STopBar = Create("Frame", {
            Name = "TopBar",
            Parent = SelectionFrame,
            BackgroundColor3 = Koda.Theme.DarkerColor,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 50)
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 16), Parent = STopBar })
        Create("Frame", { -- Fix corner bottom
            Parent = STopBar,
            BackgroundColor3 = Koda.Theme.DarkerColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -10),
            Size = UDim2.new(1, 0, 0, 10)
        })

        local DeviceIcon = Create("Frame", {
            Parent = STopBar,
            BackgroundColor3 = Koda.Theme.AccentColor,
            Position = UDim2.new(0, 12, 0, 12),
            Size = UDim2.new(0, 26, 0, 26)
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = DeviceIcon })
        Create("TextLabel", {
            Parent = DeviceIcon,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = "📱",
            TextSize = 13
        })

        local STitle = Create("TextLabel", {
            Parent = STopBar,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 48, 0, 0),
            Size = UDim2.new(1, -60, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = "Configurações Iniciais",
            TextColor3 = Koda.Theme.TextColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        -- Tab Buttons
        local SelectionTabs = Create("Frame", {
            Name = "Tabs",
            Parent = SelectionFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 50),
            Size = UDim2.new(1, 0, 0, 40)
        })

        local DeviceTabBtn = Create("TextButton", {
            Parent = SelectionTabs,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = "Dispositivos",
            TextColor3 = Koda.Theme.AccentColor,
            TextSize = 12,
            AutoButtonColor = false
        })

        local ConfigTabBtn = Create("TextButton", {
            Parent = SelectionTabs,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 0),
            Size = UDim2.new(0.5, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = "Preferências",
            TextColor3 = Koda.Theme.SecondaryTextColor,
            TextSize = 12,
            AutoButtonColor = false
        })

        local TabIndicator = Create("Frame", {
            Parent = SelectionTabs,
            BackgroundColor3 = Koda.Theme.AccentColor,
            Position = UDim2.new(0, 0, 1, -2),
            Size = UDim2.new(0.5, 0, 0, 2)
        })

        -- Pages
        local DevicePage = Create("Frame", {
            Name = "DevicePage",
            Parent = SelectionFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 90),
            Size = UDim2.new(1, 0, 1, -95),
            Visible = true
        })

        local ConfigPage = Create("Frame", {
            Name = "ConfigPage",
            Parent = SelectionFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0, 0, 90),
            Size = UDim2.new(1, 0, 1, -95),
            Visible = false
        })

        local function SwitchTab(tab)
            if tab == "Device" then
                Tween(DeviceTabBtn, 0.2, {TextColor3 = Koda.Theme.AccentColor})
                Tween(ConfigTabBtn, 0.2, {TextColor3 = Koda.Theme.SecondaryTextColor})
                Tween(TabIndicator, 0.25, {Position = UDim2.new(0, 0, 1, -2)})
                
                DevicePage.Visible = true
                Tween(DevicePage, 0.3, {Position = UDim2.new(0, 0, 0, 90)})
                Tween(ConfigPage, 0.3, {Position = UDim2.new(1, 0, 0, 90)})
                task.delay(0.3, function() if not DevicePage.Visible then ConfigPage.Visible = false end end)
            else
                Tween(DeviceTabBtn, 0.2, {TextColor3 = Koda.Theme.SecondaryTextColor})
                Tween(ConfigTabBtn, 0.2, {TextColor3 = Koda.Theme.AccentColor})
                Tween(TabIndicator, 0.25, {Position = UDim2.new(0.5, 0, 1, -2)})
                
                ConfigPage.Visible = true
                Tween(DevicePage, 0.3, {Position = UDim2.new(-1, 0, 0, 90)})
                Tween(ConfigPage, 0.3, {Position = UDim2.new(0, 0, 0, 90)})
                task.delay(0.3, function() if not ConfigPage.Visible then DevicePage.Visible = false end end)
            end
        end

        DeviceTabBtn.MouseButton1Click:Connect(function() SwitchTab("Device") end)
        ConfigTabBtn.MouseButton1Click:Connect(function() SwitchTab("Config") end)

        -- DEVICE PAGE CONTENT
        Create("TextLabel", {
            Parent = DevicePage,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 5),
            Size = UDim2.new(1, -40, 0, 18),
            Font = Enum.Font.GothamMedium,
            Text = "Escolha seu dispositivo:",
            TextColor3 = Koda.Theme.SecondaryTextColor,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Center
        })

        local function CreateDeviceBtn(name, icon, pos, deviceType, isLegacy)
            local Btn = Create("TextButton", {
                Parent = DevicePage,
                BackgroundColor3 = Koda.Theme.ElementColor,
                BorderSizePixel = 0,
                Position = pos,
                Size = UDim2.new(0.5, -25, 0, 105),
                Font = Enum.Font.GothamBold,
                Text = "",
                AutoButtonColor = false,
                ClipsDescendants = true
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = Btn })
            local bStroke = Create("UIStroke", { Color = Koda.Theme.StrokeColor, Thickness = 1.5, Parent = Btn })

            local IconLabel = Create("TextLabel", {
                Parent = Btn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 15),
                Size = UDim2.new(1, 0, 0, 45),
                Font = Enum.Font.GothamBold,
                Text = icon,
                TextSize = 35
            })

            local NameLabel = Create("TextLabel", {
                Parent = Btn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 65),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = name,
                TextColor3 = Koda.Theme.TextColor,
                TextSize = 13
            })
            
            local SubLabel = Create("TextLabel", {
                Parent = Btn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 82),
                Size = UDim2.new(1, 0, 0, 15),
                Font = Enum.Font.GothamMedium,
                Text = isLegacy and "BETA" or (deviceType == "Mobile" and "Layout Mobile" or "Layout PC"),
                TextColor3 = isLegacy and Color3.fromRGB(150, 150, 150) or Koda.Theme.AccentColor,
                TextSize = 9
            })

            Btn.MouseEnter:Connect(function()
                if isLegacy then return end
                Tween(Btn, 0.2, {BackgroundColor3 = Koda.Theme.DarkerColor})
                Tween(bStroke, 0.2, {Color = Koda.Theme.AccentColor})
            end)
            Btn.MouseLeave:Connect(function()
                if isLegacy then return end
                Tween(Btn, 0.2, {BackgroundColor3 = Koda.Theme.ElementColor})
                Tween(bStroke, 0.2, {Color = Koda.Theme.StrokeColor})
            end)

            Btn.MouseButton1Click:Connect(function()
                if isLegacy then 
                    Koda:Notify({
                        Title = "Opção Indisponível",
                        Content = "O modo Legacy está sendo refinado e voltará em breve!",
                        Duration = 5,
                        Type = "Warning"
                    })
                    return 
                end
                Ripple(Btn, Koda.Theme.AccentColor)
                Window.Device = deviceType
                Koda.LegacyMode = isLegacy
                
                if deviceType == "Mobile" then
                    Config.Size = UDim2.new(0, 500, 0, 340)
                    Window.MainScale.Scale = 1.1
                    Window.MobileToggle.Visible = true
                    MainFrame.Size = UDim2.new(0, 0, 0, 0)
                else
                    Window.MainScale.Scale = 1.0
                    Window.MobileToggle.Visible = false
                end

                Tween(SelectionFrame, 0.4, {Size = UDim2.new(0, 0, 0, 0), GroupTransparency = 1})
                task.wait(0.4)
                SelectionFrame:Destroy()
                StartKeyOrLoading()
            end)
        end

        CreateDeviceBtn("PC (Moderno)", "💻", UDim2.new(0, 20, 0, 35), "PC", false)
        CreateDeviceBtn("PC (Legacy)", "🚀", UDim2.new(0.5, 5, 0, 35), "PC", true)
        CreateDeviceBtn("Mobile", "📱", UDim2.new(0, 20, 0, 150), "Mobile", false)
        CreateDeviceBtn("Tablet", "📟", UDim2.new(0.5, 5, 0, 150), "Mobile", true)

        -- CONFIG PAGE CONTENT
        local function CreateConfigRow(name, parent, pos)
            local Row = Create("Frame", {
                Parent = parent,
                BackgroundTransparency = 1,
                Position = pos,
                Size = UDim2.new(1, -40, 0, 40)
            })
            Create("TextLabel", {
                Parent = Row,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.4, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = name,
                TextColor3 = Koda.Theme.TextColor,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            return Row
        end

        -- Keybind Config
        local KeyRow = CreateConfigRow("Atalho (Toggle):", ConfigPage, UDim2.new(0, 20, 0, 10))
        local KeyBtn = Create("TextButton", {
            Parent = KeyRow,
            BackgroundColor3 = Koda.Theme.ElementColor,
            Position = UDim2.new(0.5, 0, 0.1, 0),
            Size = UDim2.new(0.5, 0, 0.8, 0),
            Font = Enum.Font.GothamBold,
            Text = Config.Keybind.Name,
            TextColor3 = Koda.Theme.AccentColor,
            TextSize = 12,
            AutoButtonColor = false
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = KeyBtn })
        Create("UIStroke", { Color = Koda.Theme.StrokeColor, Thickness = 1, Parent = KeyBtn })

        KeyBtn.MouseButton1Click:Connect(function()
            KeyBtn.Text = "..."
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    Config.Keybind = input.KeyCode
                    KeyBtn.Text = input.KeyCode.Name
                    connection:Disconnect()
                end
            end)
        end)

        -- Theme Config
        local ThemeRow = CreateConfigRow("Tema Visual:", ConfigPage, UDim2.new(0, 20, 0, 60))
        
        local function ApplySelectionTheme()
            SelectionFrame.BackgroundColor3 = Koda.Theme.MainColor
            STopBar.BackgroundColor3 = Koda.Theme.DarkerColor
            sStroke.Color = Koda.Theme.StrokeColor
            STitle.TextColor3 = Koda.Theme.TextColor
            TabIndicator.BackgroundColor3 = Koda.Theme.AccentColor
            -- Buttons follow accent
        end

        local ThemeContainer = Create("Frame", {
            Parent = ConfigPage,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 105),
            Size = UDim2.new(1, -40, 0, 80)
        })
        Create("UIListLayout", {
            Parent = ThemeContainer,
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })

        for themeName, themeData in pairs(Koda.Themes) do
            local TBtn = Create("TextButton", {
                Parent = ThemeContainer,
                BackgroundColor3 = themeData.MainColor,
                Size = UDim2.new(0.3, -7, 0, 60),
                Text = "",
                AutoButtonColor = false
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = TBtn })
            local tStroke = Create("UIStroke", { 
                Color = (Config.Theme == themeName) and themeData.AccentColor or themeData.StrokeColor, 
                Thickness = 2, 
                Parent = TBtn 
            })
            
            Create("Frame", {
                Parent = TBtn,
                BackgroundColor3 = themeData.AccentColor,
                Position = UDim2.new(0.5, -15, 0.3, 0),
                Size = UDim2.new(0, 30, 0, 10)
            })
            
            Create("TextLabel", {
                Parent = TBtn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0.6, 0),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = themeName,
                TextColor3 = themeData.TextColor,
                TextSize = 10
            })

            TBtn.MouseButton1Click:Connect(function()
                Config.Theme = themeName
                Koda.Theme = themeData
                ApplySelectionTheme()
                -- Update all other theme strokes
                for _, child in pairs(ThemeContainer:GetChildren()) do
                    if child:IsA("TextButton") then
                        local stroke = child:FindFirstChildOfClass("UIStroke")
                        if stroke then stroke.Color = Koda.Themes[child.Name].StrokeColor end
                    end
                end
                tStroke.Color = themeData.AccentColor
            end)
            TBtn.Name = themeName
        end

        -- Animate In
        SelectionFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenBounce(SelectionFrame, 0.6, {Size = UDim2.new(0, 420, 0, 380)})
    end

    ShowDeviceSelection()

    return Window
end

-- ═══════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM (Enhanced)
-- ═══════════════════════════════════════════════════════
function Koda:Notify(Config)
    Config = Config or {}
    Config.Title = Config.Title or "Notification"
    Config.Content = Config.Content or "Content"
    Config.Duration = Config.Duration or 5
    Config.Type = Config.Type or "Info"
    
    if not Koda.NotifyHolder then return end
    
    local typeColors = {
        Info = Koda.Theme.InfoColor or Koda.Theme.AccentColor,
        Success = Koda.Theme.SuccessColor or Color3.fromRGB(34, 197, 94),
        Warning = Koda.Theme.WarningColor or Color3.fromRGB(250, 204, 21),
        Error = Koda.Theme.ErrorColor or Color3.fromRGB(239, 68, 68),
        Message = Color3.fromRGB(150, 150, 150)
    }
    
    local typeIcons = {
        Info = "ℹ",
        Success = "✓",
        Warning = "⚠",
        Error = "✕",
        Message = "✉"
    }
    
    local accentColor = typeColors[Config.Type] or typeColors.Info
    local icon = typeIcons[Config.Type] or typeIcons.Info
    
    local function GetAutoHeight(text)
        local h = TextService:GetTextSize(text, 12, Enum.Font.GothamMedium, Vector2.new(260, 1000)).Y
        return 50 + h
    end

    local NotifyFrame = Create("CanvasGroup", {
        Name = "Notification",
        Parent = Koda.NotifyHolder,
        BackgroundColor3 = Koda.Theme.MainColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, GetAutoHeight(Config.Content)),
        ClipsDescendants = true,
        GroupTransparency = 1
    })
    
    Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = NotifyFrame })
    Create("UIStroke", { Color = accentColor, Thickness = 1.5, Parent = NotifyFrame, Transparency = 0.5 })
    
    local NotifyAccent = Create("Frame", {
        Parent = NotifyFrame,
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, 0)
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = NotifyAccent })

    local IconFrame = Create("Frame", {
        Parent = NotifyFrame,
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 0.82,
        Position = UDim2.new(0, 14, 0, 12),
        Size = UDim2.new(0, 32, 0, 32)
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 9), Parent = IconFrame })
    Create("UIGradient", {
        Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, accentColor), ColorSequenceKeypoint.new(1, Koda.Theme.SecondaryAccent) }),
        Rotation = 135,
        Parent = IconFrame
    })

    Create("TextLabel", {
        Parent = IconFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = icon,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 15
    })
    
    Create("TextLabel", {
        Parent = NotifyFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 54, 0, 10),
        Size = UDim2.new(1, -66, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = Config.Title,
        TextColor3 = Koda.Theme.TextColor,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local NContent = Create("TextLabel", {
        Parent = NotifyFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 54, 0, 30),
        Size = UDim2.new(1, -66, 0, 0),
        Font = Enum.Font.GothamMedium,
        Text = Config.Content,
        TextColor3 = Koda.Theme.SecondaryTextColor,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true
    })

    local ProgressBar = Create("Frame", {
        Parent = NotifyFrame,
        BackgroundColor3 = accentColor,
        BackgroundTransparency = 0.4,
        Position = UDim2.new(0, 0, 1, -4),
        Size = UDim2.new(1, 0, 0, 4)
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = ProgressBar })

    -- Animation & Lifetime
    NotifyFrame.Position = UDim2.new(1, 20, 0, 0)
    TweenBounce(NotifyFrame, 0.5, {Position = UDim2.new(0, 0, 0, 0)})
    Tween(NotifyFrame, 0.3, {GroupTransparency = 0})

    local function DeleteNotify()
        Tween(NotifyFrame, 0.4, {Position = UDim2.new(1, 20, 0, 0), GroupTransparency = 1})
        task.wait(0.4)
        Tween(NotifyFrame, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
        task.wait(0.2)
        NotifyFrame:Destroy()
    end

    local duration = tonumber(Config.Duration) or 5
    Tween(ProgressBar, duration, {Size = UDim2.new(0, 0, 0, 4)}, Enum.EasingStyle.Linear)
    
    task.delay(duration, function()
        DeleteNotify()
    end)
end

-- ==========================================
-- UPDATE ALERT SYSTEM
-- ==========================================
function Koda:ShowUpdateAlert(Props)
    Props = Props or {}
    local NewVer = Props.Version or "Desconhecida"
    
    if Koda.ActiveWindow and Koda.ActiveWindow.CreateDialog then
        Koda.ActiveWindow:CreateDialog({
            Title = "🚀 Atualização v" .. NewVer,
            Content = "Uma nova versão foi detectada! Clique em Reset para atualizar a interface agora ou ignore para continuar.",
            Buttons = {
                {
                    Name = "Reset",
                    Primary = true,
                    Callback = function()
                        Koda:Notify({Title = "Reiniciando...", Content = "Aguarde enquanto recarregamos o script.", Duration = 3})
                        task.wait(1)
                        if Koda.ActiveGui then
                            Koda.ActiveGui:Destroy()
                            -- Aqui o usuário normalmente teria um loader que detecta a destruição ou re-executa.
                            -- Como assistente, sugerimos o uso de um loadstring loop.
                        end
                    end
                },
                {
                    Name = "Ignorar",
                    Primary = false,
                    Callback = function() end
                }
            }
        })
    else
        -- Fallback se não houver janela aberta
        Koda:Notify({
            Title = "🚀 Atualização Disponível!",
            Content = "Versão v" .. NewVer .. " detectada. Reinicie o script.",
            Duration = 15,
            Type = "Info"
        })
    end
end

return Koda
