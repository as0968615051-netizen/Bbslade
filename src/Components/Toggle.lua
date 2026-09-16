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
    slot.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- 設定為純白，由 UIGradient 來上色
    slot.BorderSizePixel = 0
    slot.ClipsDescendants = true
    slot.Parent = track

    -- 4. 建立紅橙黃綠藍紫的彩色漸層 (UIGradient)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 60, 60)),   -- 紅
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 165, 0)),  -- 橙
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 230, 60)),  -- 黃
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(60, 235, 100)),  -- 綠
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 60, 60))   -- 回到紅 (銜接流動)
    })
    gradient.Rotation = 45 -- 傾斜 45 度流動更有質感
    gradient.Parent = slot

    -- 5. 切換滑塊 (Knob)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = state and UDim2.new(0, 26, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = state and Color3.fromRGB(20, 20, 24) or Color3.fromRGB(100, 100, 100)
    knob.BorderSizePixel = 0
    knob.Parent = slot

    -- 6. 透明點擊熱區
    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.Parent = track

    -- 7. 背景彩虹流動控制 (使用 Offset 動畫循環)
    -- 開啟時預設啟動流動，關閉時降低透明度
    gradient.Enabled = true
    
    task.spawn(function()
        local speed = 0.5 -- 流動速度
        local offset = 0
        while track and track.Parent do
            local dt = RunService.RenderStepped:Wait()
            if state then
                offset = (offset + dt * speed) % 1
                gradient.Offset = Vector2.new(offset, 0)
            end
        end
    end)

    -- 8. 動畫設定：從慢到快 (EaseIn)
    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

    -- 9. 點擊切換邏輯
    clickArea.MouseButton1Click:Connect(function()
        state = not state

        local targetKnobPos = state and UDim2.new(0, 26, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local targetKnobColor = state and Color3.fromRGB(20, 20, 24) or Color3.fromRGB(100, 100, 100)
        local targetLabelColor = state and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(140, 140, 140)

        -- 關閉時背景變暗，開啟時亮起彩虹
        if not state then
            slot.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        else
            slot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end

        -- 滑塊移動 EaseIn 動畫
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
