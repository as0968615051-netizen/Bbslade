-- ===================================================================
-- Bbslade Loader - Core Architecture
-- Repository: https://github.com/as0968615051-netizen/Bbslade
-- ===================================================================

-- 1. 防重複載入：如果舊的 UI 還在，先清理掉
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("Bbslade") then
    CoreGui.Bbslade:Destroy()
end

-- 2. CSS 樣式表（將視覺與邏輯分離，統一控管主題顏色與樣式）
local Style = {
    MainFrame = {
        Size = UDim2.new(0, 500, 0, 320),
        Position = UDim2.new(0.5, -250, 0.5, -160),
        BackgroundColor3 = Color3.fromRGB(15, 15, 18),
        BorderSizePixel = 0,
        Active = true,
        Draggable = true -- 讓視窗可直接拖曳
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
        Text = "BBSLADE // LOADER",
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Code -- 使用硬朗的程式碼字體
    }
}

-- 3. 建立最頂層 ScreenGui
local Bbslade = Instance.new("ScreenGui")
Bbslade.Name = "Bbslade"
Bbslade.ResetOnSpawn = false
Bbslade.Parent = CoreGui

-- 4. 建立主框架 (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
for prop, val in pairs(Style.MainFrame) do
    MainFrame[prop] = val
end
MainFrame.Parent = Bbslade

-- 5. 建立標題列 (Title Bar)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
for prop, val in pairs(Style.TitleBar) do
    TitleBar[prop] = val
end
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
for prop, val in pairs(Style.TitleText) do
    TitleText[prop] = val
end
TitleText.Parent = TitleBar

print("Bbslade initialized successfully.")
