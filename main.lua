-- ===================================================================
-- Bbslade UI Library Core
-- Repository: https://github.com/as0968615051-netizen/Bbslade
-- ===================================================================

local Bbslade = {}
local CoreGui = game:GetService("CoreGui")

local RAW_BASE = "https://raw.githubusercontent.com/as0968615051-netizen/Bbslade/main/src/"
local COMPONENTS_URL = RAW_BASE .. "Components/"
local LOGO_URL = RAW_BASE .. "logo.png"

-- 1. 防重複載入舊視窗
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
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
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

-- 3. 建立主視窗 API
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

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    -- 標題列
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    for prop, val in pairs(Style.TitleBar) do titleBar[prop] = val end
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    for prop, val in pairs(Style.TitleText) do titleText[prop] = val end
    titleText.Text = title or "BBSLADE // LOADER"
    titleText.Parent = titleBar

    -- 縮小按鈕 (-)
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinimizeBtn"
    minBtn.Size = UDim2.new(0, 24, 0, 24)
    minBtn.Position = UDim2.new(1, -30, 0.5, -12)
    minBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    minBtn.BorderSizePixel = 0
    minBtn.Text = "-"
    minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    minBtn.Font = Enum.Font.Code
    minBtn.TextSize = 16
    minBtn.Parent = titleBar

    local minBtnCorner = Instance.new("UICorner")
    minBtnCorner.CornerRadius = UDim.new(0, 8)
    minBtnCorner.Parent = minBtn

    -- 可拖動的 Logo 浮球 (ImageButton)
    local openLogo = Instance.new("ImageButton")
    openLogo.Name = "OpenLogo"
    openLogo.Size = UDim2.new(0, 48, 0, 48)
    openLogo.Position = UDim2.new(0, 20, 0.8, 0)
    openLogo.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    openLogo.BackgroundTransparency = 0.1
    openLogo.BorderSizePixel = 0
    openLogo.Image = LOGO_URL
    openLogo.Visible = false
    openLogo.Active = true
    openLogo.Draggable = true
    openLogo.Parent = gui

    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(1, 0) -- 完全圓形
    logoCorner.Parent = openLogo

    local logoStroke = Instance.new("UIStroke")
    logoStroke.Color = Color3.fromRGB(50, 50, 60)
    logoStroke.Thickness = 1.5
    logoStroke.Parent = openLogo

    -- 縮小與展開切換邏輯
    minBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        openLogo.Visible = true
    end)

    openLogo.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        openLogo.Visible = false
    end)

    -- 內容容器
    local container = Instance.new("Frame")
    container.Name = "Container"
    for prop, val in pairs(Style.Container) do container[prop] = val end
    container.Parent = mainFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = container

    -- 4. 動態綁定 API
    local loadedComponents = {}

    setmetatable(windowObj, {
        __index = function(_, key)
            if key:sub(1, 3) == "Add" then
                local componentName = key:sub(4)

                return function(self, config)
                    if not loadedComponents[componentName] then
                        local success, code = pcall(function()
                            return game:HttpGet(COMPONENTS_URL .. componentName .. ".lua")
                        end)

                        if success then
                            loadedComponents[componentName] = loadstring(code)()
                        else
                            warn("[Bbslade] 找不到組件檔案: Components/" .. componentName .. ".lua")
                            return nil
                        end
                    end

                    return loadedComponents[componentName].Create(container, config)
                end
            end
        end
    })

    return windowObj
end

return Bbslade
