local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ToggleModule = {}

function ToggleModule.Create(parent, config)
    local state = config.DefaultState or false
    local labelText = config.Text or "Option"

    -- 1. 外框 (Track)
    local track = Instance.new("Frame")
    track.Name = labelText .. "_Toggle"
    track.Size = UDim2.new(1, 0, 0, 36)
    track.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    track.BorderSizePixel = 0
    track.Parent = parent

    -- 2. 標題文字
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = state and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(140, 140, 140)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Code
    label.TextSize = 13
    label.Parent = track

    -- 3. 開關滑軌背景 (Switch Slot)
    local slot = Instance.new("Frame")
    slot.Size = UDim2.new(0, 44, 0, 20)
    slot.Position = UDim2.new(1, -52, 0.5, -10)
    slot.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 35)
    slot.BorderSizePixel = 0
    slot.ClipsDescendants = true
    slot.Parent = track

    -- 膠囊大圓角 (Slot)
    local slotCorner = Instance.new("UICorner")
    slotCorner.CornerRadius = UDim.new(1, 0)
    slotCorner.Parent = slot

    -- 4. 彩色漸層 (UIGradient)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 60, 60)),   -- 紅
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 165, 0)),  -- 橙
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 230, 60)),  -- 黃
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(60, 235, 100)),  -- 綠
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 60, 60))   -- 紅
    })
    gradient.Rotation = 45
    gradient.Enabled = state -- 預設根據 state 決定是否啟用漸層
    gradient.Parent = slot

    -- 5. 切換滑塊 (Knob)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = state and UDim2.new(0, 26, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = state and Color3.fromRGB(20, 20, 24) or Color3.fromRGB(100, 100, 100)
    knob.BorderSizePixel = 0
    knob.Parent = slot

    -- 圓形滑塊 (Knob)
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    -- 6. 透明點擊熱區
    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.Parent = track

    -- 7. 背景彩虹流動動畫
    local renderConn
    local offset = 0
    local speed = 0.5

    renderConn = RunService.RenderStepped:Connect(function(dt)
        if not track or not track.Parent then
            if renderConn then renderConn:Disconnect() end
            return
        end

        if state then
            offset = (offset + dt * speed) % 1
            gradient.Offset = Vector2.new(offset, 0)
        end
    end)

    -- 當物件被 Destroy 時自動斷開連線
    track.Destroying:Connect(function()
        if renderConn then
            renderConn:Disconnect()
        end
    end)

    -- 8. 動畫設定：先快後慢 (EaseOut 體驗較佳)
    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- 9. 點擊切換邏輯
    clickArea.MouseButton1Click:Connect(function()
        state = not state

        local targetKnobPos = state and UDim2.new(0, 26, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local targetKnobColor = state and Color3.fromRGB(20, 20, 24) or Color3.fromRGB(100, 100, 100)
        local targetLabelColor = state and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(140, 140, 140)

        -- 開關彩虹漸層啟用狀態
        gradient.Enabled = state
        slot.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(30, 30, 35)

        -- 動畫平滑過渡
        TweenService:Create(knob, tweenInfo, {
            Position = targetKnobPos,
            BackgroundColor3 = targetKnobColor
        }):Play()

        TweenService:Create(label, tweenInfo, { TextColor3 = targetLabelColor }):Play()

        -- 觸發外部邏輯
        if state then
            if type(config.On) == "function" then config.On() end
        else
            if type(config.Off) == "function" then config.Off() end
        end
    end)

    return track
end

return ToggleModule
