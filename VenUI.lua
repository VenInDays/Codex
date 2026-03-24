-- VenUI v2
-- Rayfield-inspired but with a custom upgraded UI/API focused on mobile.

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local VenUI = {
    Flags = {},
    Connections = {},
}
VenUI.__index = VenUI

local Theme = {
    Background = Color3.fromRGB(15, 17, 24),
    Surface = Color3.fromRGB(24, 27, 37),
    SurfaceLight = Color3.fromRGB(35, 40, 53),
    SurfaceLighter = Color3.fromRGB(45, 52, 68),
    Text = Color3.fromRGB(244, 246, 255),
    Muted = Color3.fromRGB(170, 178, 195),
    Accent = Color3.fromRGB(0, 174, 255),
    AccentDark = Color3.fromRGB(0, 126, 184),
    Success = Color3.fromRGB(73, 214, 134),
}

local function isTouchDevice()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function sv(px)
    if isTouchDevice() then
        return math.floor(px * 1.18)
    end
    return px
end

local function tween(inst, info, props)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function stroke(parent, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = transparency or 0.4
    s.Thickness = 1
    s.Parent = parent
    return s
end

local function pad(parent, value)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, value)
    p.PaddingBottom = UDim.new(0, value)
    p.PaddingLeft = UDim.new(0, value)
    p.PaddingRight = UDim.new(0, value)
    p.Parent = parent
    return p
end

local function vlist(parent, spacing)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, spacing)
    l.FillDirection = Enum.FillDirection.Vertical
    l.HorizontalAlignment = Enum.HorizontalAlignment.Left
    l.VerticalAlignment = Enum.VerticalAlignment.Top
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

local function makeButton(parent, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, sv(34))
    btn.BackgroundColor3 = Theme.SurfaceLighter
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = sv(12)
    btn.AutoButtonColor = false
    btn.Text = text
    btn.Parent = parent
    corner(btn, sv(10))
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.SurfaceLighter),
        ColorSequenceKeypoint.new(1, Theme.SurfaceLight),
    })
    grad.Rotation = 90
    grad.Parent = btn
    return btn
end

function VenUI:SetTheme(newTheme)
    for k, v in pairs(newTheme) do
        if Theme[k] ~= nil then
            Theme[k] = v
        end
    end
end

function VenUI:GetFlag(flag)
    return self.Flags[flag]
end

function VenUI:SetFlag(flag, value)
    self.Flags[flag] = value
end

function VenUI:SaveConfig(fileName)
    if not writefile then
        return false, "writefile is not available"
    end
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(self.Flags)
    end)
    if not ok then
        return false, "failed to encode config"
    end
    writefile(fileName, encoded)
    return true
end

function VenUI:LoadConfig(fileName)
    if not readfile or not isfile then
        return false, "readfile/isfile is not available"
    end
    if not isfile(fileName) then
        return false, "config file not found"
    end
    local raw = readfile(fileName)
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if not ok then
        return false, "failed to decode config"
    end
    for k, v in pairs(decoded) do
        self.Flags[k] = v
    end
    return true
end

function VenUI:Notify(config)
    local titleText = config.Title or "VenUI"
    local contentText = config.Content or "Notification"
    local duration = config.Duration or 3

    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(0, sv(320), 0, sv(76))
    toast.Position = UDim2.new(1, -sv(12), 1, sv(130))
    toast.AnchorPoint = Vector2.new(1, 1)
    toast.BackgroundColor3 = Theme.Surface
    toast.Parent = self._gui
    toast.ZIndex = 999
    corner(toast, sv(14))
    stroke(toast, Theme.Accent, 0.2)

    local accent = Instance.new("Frame")
    accent.BackgroundColor3 = Theme.Accent
    accent.Size = UDim2.new(0, sv(4), 1, 0)
    accent.Parent = toast
    corner(accent, sv(10))

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Theme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = sv(13)
    title.Position = UDim2.new(0, sv(14), 0, sv(9))
    title.Size = UDim2.new(1, -sv(18), 0, sv(20))
    title.Parent = toast

    local content = Instance.new("TextLabel")
    content.BackgroundTransparency = 1
    content.TextWrapped = true
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.Text = contentText
    content.TextColor3 = Theme.Muted
    content.Font = Enum.Font.Gotham
    content.TextSize = sv(12)
    content.Position = UDim2.new(0, sv(14), 0, sv(30))
    content.Size = UDim2.new(1, -sv(18), 1, -sv(34))
    content.Parent = toast

    tween(toast, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -sv(12), 1, -sv(12)),
    })

    task.delay(duration, function()
        tween(toast, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, -sv(12), 1, sv(130)),
        }).Completed:Wait()
        toast:Destroy()
    end)
end

function VenUI:CreateWindow(config)
    local titleText = config.Title or config.Name or "VenUI"
    local subtitleText = config.Subtitle or "Mobile-ready UI library"

    local gui = Instance.new("ScreenGui")
    gui.Name = "VenUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui
    self._gui = gui

    local dock = Instance.new("Frame")
    dock.Name = "Dock"
    dock.Visible = false
    dock.Size = UDim2.new(0, sv(220), 0, sv(50))
    dock.Position = UDim2.new(0.5, 0, 1, -sv(24))
    dock.AnchorPoint = Vector2.new(0.5, 1)
    dock.BackgroundColor3 = Theme.Surface
    dock.Parent = gui
    dock.ZIndex = 50
    corner(dock, sv(14))
    stroke(dock, Theme.Accent, 0.3)

    local dockGradient = Instance.new("UIGradient")
    dockGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Surface),
        ColorSequenceKeypoint.new(1, Theme.SurfaceLight),
    })
    dockGradient.Rotation = 90
    dockGradient.Parent = dock

    local dockTitle = Instance.new("TextLabel")
    dockTitle.BackgroundTransparency = 1
    dockTitle.Text = "VenUI (Minimized)"
    dockTitle.Font = Enum.Font.GothamSemibold
    dockTitle.TextSize = sv(12)
    dockTitle.TextColor3 = Theme.Text
    dockTitle.TextXAlignment = Enum.TextXAlignment.Left
    dockTitle.Size = UDim2.new(1, -sv(90), 1, 0)
    dockTitle.Position = UDim2.new(0, sv(12), 0, 0)
    dockTitle.Parent = dock

    local open = Instance.new("TextButton")
    open.Name = "Restore"
    open.Size = UDim2.new(0, sv(70), 0, sv(32))
    open.Position = UDim2.new(1, -sv(8), 0.5, 0)
    open.AnchorPoint = Vector2.new(1, 0.5)
    open.BackgroundColor3 = Theme.Accent
    open.Text = "Open"
    open.TextScaled = false
    open.TextSize = sv(12)
    open.TextColor3 = Color3.new(1, 1, 1)
    open.Font = Enum.Font.GothamBold
    open.Parent = dock
    open.ZIndex = 51
    corner(open, sv(10))

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.fromScale(0.94, 0.84)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Theme.Background
    main.Parent = gui
    corner(main, sv(18))
    stroke(main, Theme.SurfaceLighter, 0.25)

    local mainGrad = Instance.new("UIGradient")
    mainGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Background),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(19, 23, 32)),
    })
    mainGrad.Rotation = 100
    mainGrad.Parent = main

    local uiscale = Instance.new("UIScale")
    uiscale.Scale = isTouchDevice() and 1.02 or 1
    uiscale.Parent = main

    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, sv(62))
    top.BackgroundColor3 = Theme.Surface
    top.Parent = main
    corner(top, sv(18))
    local topGrad = Instance.new("UIGradient")
    topGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Surface),
        ColorSequenceKeypoint.new(1, Theme.SurfaceLight),
    })
    topGrad.Rotation = 90
    topGrad.Parent = top

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, sv(16), 0, sv(8))
    title.Size = UDim2.new(1, -sv(128), 0, sv(22))
    title.Text = titleText
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = sv(16)
    title.Parent = top

    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.new(0, sv(16), 0, sv(30))
    subtitle.Size = UDim2.new(1, -sv(128), 0, sv(18))
    subtitle.Text = subtitleText
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextColor3 = Theme.Muted
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = sv(11)
    subtitle.Parent = top

    local minimize = Instance.new("TextButton")
    minimize.Size = UDim2.new(0, sv(38), 0, sv(38))
    minimize.Position = UDim2.new(1, -sv(52), 0.5, 0)
    minimize.AnchorPoint = Vector2.new(1, 0.5)
    minimize.BackgroundColor3 = Theme.SurfaceLighter
    minimize.Text = "_"
    minimize.TextColor3 = Theme.Text
    minimize.Font = Enum.Font.GothamBold
    minimize.TextSize = sv(16)
    minimize.Parent = top
    corner(minimize, sv(12))

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, sv(38), 0, sv(38))
    close.Position = UDim2.new(1, -sv(10), 0.5, 0)
    close.AnchorPoint = Vector2.new(1, 0.5)
    close.BackgroundColor3 = Theme.SurfaceLighter
    close.Text = "✕"
    close.TextColor3 = Theme.Text
    close.Font = Enum.Font.GothamBold
    close.TextSize = sv(14)
    close.Parent = top
    corner(close, sv(12))

    local body = Instance.new("Frame")
    body.BackgroundTransparency = 1
    body.Position = UDim2.new(0, sv(8), 0, sv(68))
    body.Size = UDim2.new(1, -sv(16), 1, -sv(76))
    body.Parent = main

    local left = Instance.new("Frame")
    left.Name = "Sidebar"
    left.BackgroundColor3 = Theme.Surface
    left.Size = UDim2.new(0, sv(140), 1, 0)
    left.Parent = body
    corner(left, sv(14))
    pad(left, sv(8))
    local leftGrad = Instance.new("UIGradient")
    leftGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Surface),
        ColorSequenceKeypoint.new(1, Theme.SurfaceLight),
    })
    leftGrad.Rotation = 90
    leftGrad.Parent = left

    local search = Instance.new("TextBox")
    search.Size = UDim2.new(1, 0, 0, sv(34))
    search.BackgroundColor3 = Theme.SurfaceLight
    search.PlaceholderText = "Search tab..."
    search.Text = ""
    search.TextColor3 = Theme.Text
    search.PlaceholderColor3 = Theme.Muted
    search.TextSize = sv(12)
    search.Font = Enum.Font.Gotham
    search.ClearTextOnFocus = false
    search.Parent = left
    corner(search, sv(10))

    local tabsFrame = Instance.new("ScrollingFrame")
    tabsFrame.Size = UDim2.new(1, 0, 1, -sv(42))
    tabsFrame.Position = UDim2.new(0, 0, 0, sv(42))
    tabsFrame.BackgroundTransparency = 1
    tabsFrame.CanvasSize = UDim2.new()
    tabsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabsFrame.ScrollBarThickness = 0
    tabsFrame.Parent = left
    vlist(tabsFrame, sv(7))

    local pages = Instance.new("Frame")
    pages.BackgroundTransparency = 1
    pages.Position = UDim2.new(0, sv(148), 0, 0)
    pages.Size = UDim2.new(1, -sv(148), 1, 0)
    pages.Parent = body

    local pagesLayout = Instance.new("UIPageLayout")
    pagesLayout.Parent = pages
    pagesLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pagesLayout.EasingStyle = Enum.EasingStyle.Quad
    pagesLayout.EasingDirection = Enum.EasingDirection.InOut
    pagesLayout.TweenTime = 0.2

    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    top.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput and dragStart and startPos then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    local dockDrag, dockDragInput, dockDragStart, dockStartPos = false, nil, nil, nil
    dock.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dockDrag = true
            dockDragStart = input.Position
            dockStartPos = dock.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dockDrag = false
                end
            end)
        end
    end)
    dock.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dockDragInput = input
        end
    end)
    table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
        if dockDrag and input == dockDragInput and dockDragStart and dockStartPos then
            local delta = input.Position - dockDragStart
            dock.Position = UDim2.new(
                dockStartPos.X.Scale,
                dockStartPos.X.Offset + delta.X,
                dockStartPos.Y.Scale,
                dockStartPos.Y.Offset + delta.Y
            )
        end
    end))

    minimize.MouseButton1Click:Connect(function()
        tween(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.fromScale(0.7, 0),
            BackgroundTransparency = 0.25,
        }).Completed:Wait()
        main.Visible = false
        main.Size = UDim2.fromScale(0.94, 0.84)
        main.BackgroundTransparency = 0
        dock.Visible = true
    end)

    open.MouseButton1Click:Connect(function()
        dock.Visible = false
        main.Visible = true
        main.Size = UDim2.fromScale(0.7, 0)
        tween(main, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromScale(0.94, 0.84),
        })
    end)

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    local window = {
        _tabs = {},
        _buttons = {},
        _layout = pagesLayout,
    }

    function window:SetTitle(newTitle)
        title.Text = tostring(newTitle)
    end

    function window:SetSubtitle(newSubtitle)
        subtitle.Text = tostring(newSubtitle)
    end

    function window:SelectTab(indexOrName)
        if type(indexOrName) == "number" then
            local tab = self._tabs[indexOrName]
            if tab then pagesLayout:JumpTo(tab.Page) end
        elseif type(indexOrName) == "string" then
            for _, tab in ipairs(self._tabs) do
                if tab.Name == indexOrName then
                    pagesLayout:JumpTo(tab.Page)
                    break
                end
            end
        end
    end

    function window:Destroy()
        gui:Destroy()
    end

    local function refreshTabFilter()
        local q = string.lower(search.Text)
        for _, item in ipairs(window._tabs) do
            local ok = q == "" or string.find(string.lower(item.Name), q, 1, true)
            item.Button.Visible = ok
        end
    end

    search:GetPropertyChangedSignal("Text"):Connect(refreshTabFilter)

    local function updateActiveButton(active)
        for _, tabInfo in ipairs(window._tabs) do
            tabInfo.Button.BackgroundColor3 = (tabInfo == active) and Theme.Accent or Theme.SurfaceLighter
            if tabInfo.Indicator then
                tabInfo.Indicator.Visible = (tabInfo == active)
            end
        end
    end

    function window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local icon = tabConfig.Icon or "◆"

        local tabButton = makeButton(tabsFrame, icon .. "  " .. tabName)
        tabButton.TextXAlignment = Enum.TextXAlignment.Left

        local page = Instance.new("ScrollingFrame")
        page.Name = "Page_" .. HttpService:GenerateGUID(false)
        page.Size = UDim2.fromScale(1, 1)
        page.CanvasSize = UDim2.new()
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.ScrollBarThickness = 0
        page.BackgroundColor3 = Theme.Surface
        page.BorderSizePixel = 0
        page.Parent = pages
        corner(page, sv(14))
        pad(page, sv(12))
        vlist(page, sv(8))

        local tab = {
            Name = tabName,
            Icon = icon,
            Button = tabButton,
            Page = page,
            Indicator = nil,
        }

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, sv(3), 1, -sv(8))
        indicator.Position = UDim2.new(0, sv(4), 0, sv(4))
        indicator.BackgroundColor3 = Theme.Accent
        indicator.Visible = false
        indicator.Parent = tabButton
        corner(indicator, sv(99))
        tab.Indicator = indicator

        local function container(height)
            local f = Instance.new("Frame")
            f.BackgroundColor3 = Theme.SurfaceLight
            f.BorderSizePixel = 0
            f.Size = UDim2.new(1, 0, 0, height or sv(44))
            f.AutomaticSize = Enum.AutomaticSize.Y
            f.Parent = page
            corner(f, sv(12))
            pad(f, sv(10))
            return f
        end

        local function setFlag(flag, value, callback)
            if flag and flag ~= "" then
                VenUI.Flags[flag] = value
            end
            if callback then callback(value) end
        end

        function tab:AddSection(name)
            local h = container(sv(30))
            h.BackgroundColor3 = Theme.Surface
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 0, sv(20))
            lbl.Text = tostring(name or "Section")
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = sv(13)
            lbl.TextColor3 = Theme.Accent
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = h
            return lbl
        end

        function tab:AddParagraph(data)
            local h = container(sv(62))
            local t = Instance.new("TextLabel")
            t.BackgroundTransparency = 1
            t.Size = UDim2.new(1, 0, 0, sv(18))
            t.Text = data.Title or "Paragraph"
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.Font = Enum.Font.GothamSemibold
            t.TextSize = sv(13)
            t.TextColor3 = Theme.Text
            t.Parent = h

            local d = Instance.new("TextLabel")
            d.BackgroundTransparency = 1
            d.Position = UDim2.new(0, 0, 0, sv(20))
            d.Size = UDim2.new(1, 0, 0, sv(32))
            d.TextWrapped = true
            d.TextYAlignment = Enum.TextYAlignment.Top
            d.TextXAlignment = Enum.TextXAlignment.Left
            d.Text = data.Content or ""
            d.Font = Enum.Font.Gotham
            d.TextSize = sv(12)
            d.TextColor3 = Theme.Muted
            d.Parent = h

            return h
        end

        function tab:AddLabel(text)
            local h = container(sv(30))
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 0, sv(20))
            lbl.Text = tostring(text or "Label")
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = sv(12)
            lbl.TextColor3 = Theme.Muted
            lbl.Parent = h
            return lbl
        end

        function tab:AddButton(data)
            local h = container(sv(48))
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, sv(30))
            btn.BackgroundColor3 = Theme.Accent
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = sv(12)
            btn.Text = data.Name or "Button"
            btn.AutoButtonColor = false
            btn.Parent = h
            corner(btn, sv(10))
            btn.MouseButton1Click:Connect(function()
                if data.Callback then data.Callback() end
            end)
            return btn
        end

        function tab:AddToggle(data)
            local value = data.CurrentValue == true
            local h = container(sv(44))

            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -sv(76), 1, 0)
            lbl.Text = data.Name or "Toggle"
            lbl.TextColor3 = Theme.Text
            lbl.TextSize = sv(12)
            lbl.Font = Enum.Font.GothamSemibold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = h

            local sw = Instance.new("TextButton")
            sw.Size = UDim2.new(0, sv(58), 0, sv(28))
            sw.Position = UDim2.new(1, 0, 0.5, 0)
            sw.AnchorPoint = Vector2.new(1, 0.5)
            sw.BackgroundColor3 = value and Theme.Success or Theme.Surface
            sw.Text = ""
            sw.AutoButtonColor = false
            sw.Parent = h
            corner(sw, sv(99))

            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, sv(22), 0, sv(22))
            dot.Position = value and UDim2.new(1, -sv(25), 0.5, 0) or UDim2.new(0, sv(3), 0.5, 0)
            dot.AnchorPoint = Vector2.new(0, 0.5)
            dot.BackgroundColor3 = Color3.new(1, 1, 1)
            dot.Parent = sw
            corner(dot, sv(99))

            local function sync(animate)
                if animate then
                    tween(sw, TweenInfo.new(0.15), {BackgroundColor3 = value and Theme.Success or Theme.Surface})
                    tween(dot, TweenInfo.new(0.15), {Position = value and UDim2.new(1, -sv(25), 0.5, 0) or UDim2.new(0, sv(3), 0.5, 0)})
                else
                    sw.BackgroundColor3 = value and Theme.Success or Theme.Surface
                    dot.Position = value and UDim2.new(1, -sv(25), 0.5, 0) or UDim2.new(0, sv(3), 0.5, 0)
                end
            end

            sync(false)
            setFlag(data.Flag, value)

            sw.MouseButton1Click:Connect(function()
                value = not value
                sync(true)
                setFlag(data.Flag, value, data.Callback)
            end)

            return {
                Set = function(_, v)
                    value = v == true
                    sync(true)
                    setFlag(data.Flag, value, data.Callback)
                end,
                Get = function()
                    return value
                end,
            }
        end

        function tab:AddSlider(data)
            local min = data.Range and data.Range[1] or 0
            local max = data.Range and data.Range[2] or 100
            local value = tonumber(data.CurrentValue) or min
            local draggingSlider = false

            local h = container(sv(76))

            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 0, sv(20))
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextColor3 = Theme.Text
            lbl.Font = Enum.Font.GothamSemibold
            lbl.TextSize = sv(12)
            lbl.Parent = h

            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, 0, 0, sv(10))
            bar.Position = UDim2.new(0, 0, 0, sv(36))
            bar.BackgroundColor3 = Theme.Surface
            bar.Parent = h
            corner(bar, sv(99))

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = Theme.Accent
            fill.Parent = bar
            corner(fill, sv(99))

            local function sync(callback)
                value = math.clamp(value, min, max)
                local alpha = (value - min) / (max - min)
                fill.Size = UDim2.new(alpha, 0, 1, 0)
                lbl.Text = string.format("%s: %s", data.Name or "Slider", tostring(value))
                if callback then
                    setFlag(data.Flag, value, data.Callback)
                end
            end

            local function updateFromX(x)
                local alpha = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * alpha)
                sync(true)
            end

            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                    updateFromX(input.Position.X)
                end
            end)
            bar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateFromX(input.Position.X)
                end
            end)

            sync(false)
            return {
                Set = function(_, v)
                    value = tonumber(v) or value
                    sync(true)
                end,
                Get = function()
                    return value
                end,
            }
        end

        function tab:AddInput(data)
            local h = container(sv(62))

            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 0, sv(18))
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = data.Name or "Input"
            lbl.TextColor3 = Theme.Text
            lbl.Font = Enum.Font.GothamSemibold
            lbl.TextSize = sv(12)
            lbl.Parent = h

            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, 0, 0, sv(30))
            box.Position = UDim2.new(0, 0, 0, sv(24))
            box.BackgroundColor3 = Theme.Surface
            box.Text = data.CurrentValue or ""
            box.PlaceholderText = data.PlaceholderText or "Type..."
            box.TextColor3 = Theme.Text
            box.PlaceholderColor3 = Theme.Muted
            box.ClearTextOnFocus = false
            box.Font = Enum.Font.Gotham
            box.TextSize = sv(12)
            box.Parent = h
            corner(box, sv(10))

            box.FocusLost:Connect(function(enterPressed)
                local value = box.Text
                if data.RemoveTextAfterFocusLost then
                    box.Text = ""
                end
                setFlag(data.Flag, value, function(v)
                    if data.Callback then data.Callback(v, enterPressed) end
                end)
            end)
            return box
        end

        function tab:AddDropdown(data)
            local options = data.Options or {}
            local selected = data.CurrentOption or options[1] or ""
            local index = table.find(options, selected) or 1

            local h = container(sv(62))

            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 0, sv(18))
            lbl.Text = data.Name or "Dropdown"
            lbl.TextColor3 = Theme.Text
            lbl.TextSize = sv(12)
            lbl.Font = Enum.Font.GothamSemibold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = h

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, sv(30))
            btn.Position = UDim2.new(0, 0, 0, sv(24))
            btn.BackgroundColor3 = Theme.Surface
            btn.TextColor3 = Theme.Text
            btn.TextSize = sv(12)
            btn.Font = Enum.Font.Gotham
            btn.Text = tostring(selected)
            btn.AutoButtonColor = false
            btn.Parent = h
            corner(btn, sv(10))

            btn.MouseButton1Click:Connect(function()
                index += 1
                if index > #options then index = 1 end
                selected = options[index] or selected
                btn.Text = tostring(selected)
                setFlag(data.Flag, selected, data.Callback)
            end)

            setFlag(data.Flag, selected)

            return {
                Set = function(_, value)
                    local i = table.find(options, value)
                    if i then
                        index = i
                        selected = value
                        btn.Text = tostring(value)
                        setFlag(data.Flag, selected, data.Callback)
                    end
                end,
                Get = function()
                    return selected
                end,
                Refresh = function(_, newOptions)
                    options = newOptions or options
                    index = 1
                    selected = options[1] or ""
                    btn.Text = tostring(selected)
                    setFlag(data.Flag, selected, data.Callback)
                end,
            }
        end

        function tab:AddColorPicker(data)
            local palette = data.Preset or {
                Color3.fromRGB(255, 70, 70),
                Color3.fromRGB(255, 170, 0),
                Color3.fromRGB(255, 255, 80),
                Color3.fromRGB(60, 220, 140),
                Color3.fromRGB(80, 170, 255),
                Color3.fromRGB(180, 120, 255),
            }
            local idx = 1
            local current = palette[idx]

            local h = container(sv(52))
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -sv(64), 1, 0)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = data.Name or "Color"
            lbl.TextColor3 = Theme.Text
            lbl.Font = Enum.Font.GothamSemibold
            lbl.TextSize = sv(12)
            lbl.Parent = h

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, sv(44), 0, sv(28))
            btn.Position = UDim2.new(1, 0, 0.5, 0)
            btn.AnchorPoint = Vector2.new(1, 0.5)
            btn.Text = ""
            btn.BackgroundColor3 = current
            btn.Parent = h
            corner(btn, sv(10))

            btn.MouseButton1Click:Connect(function()
                idx += 1
                if idx > #palette then idx = 1 end
                current = palette[idx]
                btn.BackgroundColor3 = current
                setFlag(data.Flag, current, data.Callback)
            end)

            setFlag(data.Flag, current)
            return {
                Set = function(_, color)
                    current = color
                    btn.BackgroundColor3 = color
                    setFlag(data.Flag, current, data.Callback)
                end,
                Get = function()
                    return current
                end,
            }
        end

        function tab:AddKeybind(data)
            local current = data.CurrentKeybind or Enum.KeyCode.RightShift
            local waiting = false

            local h = container(sv(52))
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -sv(90), 1, 0)
            lbl.Text = data.Name or "Keybind"
            lbl.TextColor3 = Theme.Text
            lbl.Font = Enum.Font.GothamSemibold
            lbl.TextSize = sv(12)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = h

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, sv(82), 0, sv(28))
            btn.Position = UDim2.new(1, 0, 0.5, 0)
            btn.AnchorPoint = Vector2.new(1, 0.5)
            btn.BackgroundColor3 = Theme.Surface
            btn.TextColor3 = Theme.Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = sv(11)
            btn.Text = current.Name
            btn.Parent = h
            corner(btn, sv(10))

            btn.MouseButton1Click:Connect(function()
                waiting = true
                btn.Text = "Press key"
            end)

            UserInputService.InputBegan:Connect(function(input, gp)
                if gp then return end
                if waiting and input.KeyCode ~= Enum.KeyCode.Unknown then
                    current = input.KeyCode
                    waiting = false
                    btn.Text = current.Name
                    setFlag(data.Flag, current.Name)
                    if data.ChangedCallback then data.ChangedCallback(current) end
                    return
                end

                if input.KeyCode == current then
                    if data.Callback then data.Callback(current) end
                end
            end)

            setFlag(data.Flag, current.Name)
            return {
                Set = function(_, keyCode)
                    current = keyCode
                    btn.Text = current.Name
                    setFlag(data.Flag, current.Name, data.ChangedCallback)
                end,
                Get = function()
                    return current
                end,
            }
        end

        tabButton.MouseButton1Click:Connect(function()
            pagesLayout:JumpTo(page)
            updateActiveButton(tab)
        end)

        table.insert(window._tabs, tab)

        if #window._tabs == 1 then
            pagesLayout:JumpTo(page)
            updateActiveButton(tab)
        end

        return tab
    end

    return window
end

return setmetatable(VenUI, VenUI)
