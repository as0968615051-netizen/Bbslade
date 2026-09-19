-- ===================================================================
-- Bbslade UI Library Core
-- Repository: https://github.com/as0968615051-netizen/Bbslade
-- ===================================================================

local Bbslade = {}
local CoreGui = game:GetService("CoreGui")
local BASE_URL = "https://raw.githubusercontent.com/as0968615051-netizen/Bbslade/main/Components/"

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

    -- 圓角
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    -- 標題列
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    for prop, val in pairs(Style.Style or Style.TitleBar) do titleBar[prop] = val end
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

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

    -- 4. 動態綁定 API (取代原本寫死的 function windowObj:AddToggle)
    local loadedComponents = {}

    setmetatable(windowObj, {
        __index = function(_, key)
            -- 當外部呼叫 Window:AddToggle() 或 Window:AddSlider() 時自動攔截
            if key:sub(1, 3) == "Add" then
                local componentName = key:sub(4) -- 取得 "Toggle" 或 "Slider"

                return function(self, config)
                    -- 如果沒載入過，自動向上去 GitHub Components/ 抓該組件
                    if not loadedComponents[componentName] then
                        local success, code = pcall(function()
                            return game:HttpGet(BASE_URL .. componentName .. ".lua")
                        end)
                        
                        if success then
                            loadedComponents[componentName] = loadstring(code)()
                        else
                            warn("[Bbslade] 找不到組件檔案: Components/" .. componentName .. ".lua")
                            return nil
                        end
                    end

                    -- 把容器 container 傳給獨立的組件做繪製
                    return loadedComponents[componentName].Create(container, config)
                end
            end
        end
    })

    return windowObj
end

-- 回傳整個 Library 物件
return Bbslade
