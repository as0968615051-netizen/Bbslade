local TweenService = game:GetService("TweenService")
local TabModule = {}

function TabModule.Create(parent, config)
    local tabObj = {}
    local tabs = {}
    local activeTab = nil

    -- 1. 最外層包裝框
    local mainTabFrame = Instance.new("Frame")
    mainTabFrame.Name = "TabGroup"
    mainTabFrame.Size = UDim2.new(1, 0, 1, 0)
    mainTabFrame.BackgroundTransparency = 1
    mainTabFrame.Parent = parent

    -- 2. 上方 TAB 按鈕列 (Tab Bar)
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, 0, 0, 32)
    tabBar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainTabFrame

    local tabBarCorner = Instance.new("UICorner")
    tabBarCorner.CornerRadius = UDim.new(0, 8)
    tabBarCorner.Parent = tabBar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabBar

    -- 3. 下方內容顯示區域 (Pages Container)
    local pagesFolder = Instance.new("Frame")
    pagesFolder.Name = "Pages"
    pagesFolder.Size = UDim2.new(1, 0, 1, -40)
    pagesFolder.Position = UDim2.new(0, 0, 0, 40)
    pagesFolder.BackgroundTransparency = 1
    pagesFolder.Parent = mainTabFrame

    -- 新增單一 TAB 頁面的方法
    function tabObj:AddTab(tabConfig)
        local tabName = tabConfig.name or tabConfig.Name or "Tab"
        local pageObj = {}

        -- 按鈕 (Tab Button)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tabName .. "_Btn"
        tabBtn.Size = UDim2.new(0, 100, 1, 0)
        tabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = tabName
        tabBtn.TextColor3 = Color3.fromRGB(130, 130, 130)
        tabBtn.Font = Enum.Font.Code
        tabBtn.TextSize = 13
        tabBtn.Parent = tabBar

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = tabBtn

        -- 對應的頁面 (Page Frame)
        local page = Instance.new("ScrollingFrame")
        page.Name = tabName .. "_Page"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
        page.Parent = pagesFolder

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 8)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Parent = page

        -- 自動調整滾動邊界
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 10)
        end)

        -- 頁面切換邏輯
        local function selectTab()
            for _, t in pairs(tabs) do
                t.Page.Visible = false
                TweenService:Create(t.Button, TweenInfo.new(0.2), {
                    TextColor3 = Color3.fromRGB(130, 130, 130),
                    BackgroundTransparency = 1
                }):Play()
            end

            page.Visible = true
            activeTab = tabName
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(240, 240, 240),
                BackgroundColor3 = Color3.fromRGB(35, 35, 42),
                BackgroundTransparency = 0
            }):Play()
        end

        tabBtn.MouseButton1Click:Connect(selectTab)

        -- 把動態元件掛載到這個 Page 上
        local loadedComponents = {}
        local BASE_URL = "https://raw.githubusercontent.com/as0968615051-netizen/Bbslade/main/Components/"

        setmetatable(pageObj, {
            __index = function(_, key)
                if key:sub(1, 3) == "Add" then
                    local componentName = key:sub(4)
                    return function(self, config)
                        if not loadedComponents[componentName] then
                            local success, code = pcall(function()
                                return game:HttpGet(BASE_URL .. componentName .. ".lua")
                            end)
                            if success then
                                loadedComponents[componentName] = loadstring(code)()
                            end
                        end
                        -- 將控制項繪製在這個 TAB 專屬的 page 容器內
                        return loadedComponents[componentName].Create(page, config)
                    end
                end
            end
        })

        table.insert(tabs, { Button = tabBtn, Page = page })

        -- 預設選取第一個 TAB
        if #tabs == 1 then
            selectTab()
        end

        return pageObj
    end

    return tabObj
end

return TabModule
