local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SliderModule = {}

function SliderModule.Create(parent, config)
    -- 相容自訂名稱 (tallest / lowest) 或標準名稱 (Max / Min)
    local minVal = config.lowest or config.Min or 0
    local maxVal = config.tallest or config.Max or 100
    local defaultVal = math.clamp(config.Default or minVal, minVal, maxVal)
    local labelText = config.Text or "Slider"
    local callback = config.Callback or config.OnChanged

    local currentVal = defaultVal
    local isDragging = false

    -- 1. 外框 (Track)
    local track = Instance.new("Frame")
    track.Name = labelText .. "_Slider"
    track.Size = UDim2.new(1, 0, 0, 48)
    track.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    track.BorderSizePixel = 0
    track.Parent = parent

    -- 2. 標題與數值顯示
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Code
    label.TextSize = 13
    label.Parent = track

    local valueDisplay = Instance.new("TextLabel")
    valueDisplay.Size = UDim2.new(0.3, 0, 0, 20)
    valueDisplay.Position = UDim2.new(0.7, -12, 0, 4)
    valueDisplay.BackgroundTransparency = 1
    valueDisplay.Text = tostring(math.floor(currentVal))
    valueDisplay.TextColor3 = Color3.fromRGB(160, 160, 160)
    valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
    valueDisplay.Font = Enum.Font.Code
    valueDisplay.TextSize = 13
    valueDisplay.Parent = track

    -- 3. 滑軌底座 (Bar Background)
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -24, 0, 8)
    barBg.Position = UDim2.new(0, 12, 0, 30)
    barBg.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    barBg.BorderSizePixel = 0
    barBg.Parent = track

    local barBgCorner = Instance.new("UICorner")
    barBgCorner.CornerRadius = UDim.new(1, 0)
    barBgCorner.Parent = barBg

    -- 4. 填滿進度條 (Bar Fill)
    local initialPercent = (currentVal - minVal) / (maxVal - minVal)
    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(initialPercent, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg

    local barFillCorner = Instance.new("UICorner")
    barFillCorner.CornerRadius = UDim.new(1, 0)
    barFillCorner.Parent = barFill

    -- 5. 圓形拖曳按鈕 (Knob)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(initialPercent, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = barBg

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    -- 6. 計算與更新數值 logic
    local function updateValue(input)
        local posX = math.clamp(input.Position.X - barBg.AbsolutePosition.X, 0, barBg.AbsoluteSize.X)
        local percent = posX / barBg.AbsoluteSize.X
        
        currentVal = math.floor(minVal + (maxVal - minVal) * percent)
        valueDisplay.Text = tostring(currentVal)

        -- 平滑動畫更新滑塊與進度條
        barFill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, 0, 0.5, 0)

        if type(callback) == "function" then
            callback(currentVal)
        end
    end

    -- 7. 拖曳事件綁定
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            updateValue(input)
        end
    end)

    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input)
        end
    end)

    return track
end

return SliderModule
