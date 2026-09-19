local TweenService = game:GetService("TweenService")
local DropdownModule = {}

function DropdownModule.Create(parent, config)
    local labelText = config.Text or "Dropdown"
    local options = config.Options or {}
    local defaultOption = config.Default or options[1] or "Select..."
    local callback = config.Callback or config.OnChanged

    local selectedValue = defaultOption
    local isOpen = false

    -- 1. 外框 (Track)
    local track = Instance.new("Frame")
    track.Name = labelText .. "_Dropdown"
    track.Size = UDim2.new(1, 0, 0, 36) -- 預設收合高度
    track.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    track.BorderSizePixel = 0
    track.ClipsDescendants = true
    track.Parent = parent

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 8)
    trackCorner.Parent = track

    -- 2. 標題與當前選取值
    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 36)
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.Parent = track

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Code
    label.TextSize = 13
    label.Parent = headerBtn

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.4, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.6, -12, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = selectedValue .. "  ▼"
    valueLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.Code
    valueLabel.TextSize = 12
    valueLabel.Parent = headerBtn

    -- 3. 選項清單容器 (Options Container)
    local optionsFrame = Instance.new("ScrollingFrame")
    optionsFrame.Size = UDim2.new(1, -24, 0, 0)
    optionsFrame.Position = UDim2.new(0, 12, 0, 40)
    optionsFrame.BackgroundTransparency = 1
    optionsFrame.BorderSizePixel = 0
    optionsFrame.ScrollBarThickness = 2
    optionsFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    optionsFrame.Parent = track

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = optionsFrame

    -- 自動調整 Canvas 尺寸
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        optionsFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)

    -- 4. 動態生成選項按鈕
    local function populateOptions()
        for _, child in pairs(optionsFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for _, optName in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, -4, 0, 28)
            optBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
            optBtn.BorderSizePixel = 0
            optBtn.Text = optName
            optBtn.TextColor3 = (optName == selectedValue) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
            optBtn.Font = Enum.Font.Code
            optBtn.TextSize = 12
            optBtn.Parent = optionsFrame

            local optCorner = Instance.new("UICorner")
            optCorner.CornerRadius = UDim.new(0, 6)
            optCorner.Parent = optBtn

            optBtn.MouseButton1Click:Connect(function()
                selectedValue = optName
                valueLabel.Text = selectedValue .. "  ▼"
                if type(callback) == "function" then
                    callback(selectedValue)
                end
                
                -- 選完後自動收合
                isOpen = false
                valueLabel.Text = selectedValue .. "  ▼"
                TweenService:Create(track, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, 36)
                }):Play()
                TweenService:Create(optionsFrame, TweenInfo.new(0.25), { Size = UDim2.new(1, -24, 0, 0) }):Play()
            end)
        end
    end

    populateOptions()

    -- 5. 切換展開/收合
    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local optionCount = #options
        local maxVisibleOptions = math.min(optionCount, 4) -- 最多同時顯示 4 個選項，超出可滾動
        local targetOptionsHeight = maxVisibleOptions * 32
        local targetTrackHeight = isOpen and (44 + targetOptionsHeight) or 36

        valueLabel.Text = selectedValue .. (isOpen and "  ▲" or "  ▼")

        TweenService:Create(track, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, targetTrackHeight)
        }):Play()

        TweenService:Create(optionsFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -24, 0, targetOptionsHeight)
        }):Play()
    end)

    return track
end

return DropdownModule
