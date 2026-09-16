-- ===================================================================
-- Bbslade UI Library Core
-- Repository: https://github.com/as0968615051-netizen/Bbslade
-- ===================================================================

local Bbslade = {}

-- 1. 防重複載入舊視窗
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("Bbslade") then
    CoreGui.Bbslade:Destroy()
end

-- 2. Style 樣式表
local Style = {
    MainFrame = {
        Size = UDim2.new(0, 500, 0, 320),
        Position = UDim2.new(0.5, -250, 0.5, -160),
        BackgroundColor3 = Color3.fromRGB(15, 15, 18),
        BorderSizePixel = 0,
        Active = true,
        Draggable = true
    },
    TitleBar = {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Color3.fromRGB(25, 25, 30),
        BorderSizePixel = 0
    },
    TitleText = {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Code
    },
    Container = {
        Size = UDim2.new(1, -20, 1, -55),
        Position = UDim2.new(0, 10, 0, 45),
        BackgroundTransparency = 1
    }
}

-- 3. 建立主視窗 API (被呼叫時才會畫視窗)
function Bbslade:CreateWindow(title)
    local windowObj = {}

    -- 建立最頂層 GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "Bbslade"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    -- 主框架
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    for prop, val in pairs(Style.MainFrame) do mainFrame[prop] = val end
    mainFrame.Parent = gui

    -- 標題列
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    for prop, val in pairs(Style.TitleBar) do titleBar[prop] = val end
    titleBar.Parent = mainFrame

    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    for prop, val in pairs(Style.TitleText) do titleText[prop] = val end
    titleText.Text = title or "BBSLADE // LOADER"
    titleText.Parent = titleBar

    -- 內容容器
    local container = Instance.new("Frame")
    container.Name = "Container"
    for prop, val in pairs(Style.Container) do container[prop] = val end
    container.Parent = mainFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = container

    -- 4. 為這個視窗掛載 AddToggle API (檢視外部是否有呼叫 Toggle)
    function windowObj:AddToggle(config)
        local state = config.DefaultState or false
        local labelText = config.Text or "Option"

        local button = Instance.new("TextButton")
        button.Name = labelText .. "_Toggle"
        button.Size = UDim2.new(1, 0, 0, 32)
        button.BorderSizePixel = 0
        button.Font = Enum.Font.Code
        button.TextSize = 13
        button.Parent = container

        local function updateVisual()
            if state then
                button.Text = labelText .. " [ON]"
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
            else
                button.Text = labelText .. " [OFF]"
                button.TextColor3 = Color3.fromRGB(120, 120, 120)
                button.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
            end
        end

        updateVisual()

        -- 點擊觸發外部傳入的 On / Off
        button.MouseButton1Click:Connect(function()
            state = not state
            updateVisual()

            if state then
                if type(config.On) == "function" then config.On() end
            else
                if type(config.Off) == "function" then config.Off() end
            end
        end)

        return button
    end

    return windowObj
end

-- 回傳整個 Library 物件
return Bbslade
