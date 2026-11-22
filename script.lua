-- rty Custom Texture & Sky GUI for Rivals (Auto-Save Supported)
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- ==========================================
-- 自動儲存與讀取系統 (Delta Executor 支援)
-- ==========================================
local ConfigFile = "rty_CustomUI_Config.json"
local Config = {
    Sky = "",
    Texture = "",
    Font = ""
}

local function SaveConfig()
    if writefile then
        pcall(function()
            writefile(ConfigFile, HttpService:JSONEncode(Config))
        end)
    end
end

local function LoadConfig()
    if isfile and isfile(ConfigFile) and readfile then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFile))
        end)
        if success and type(data) == "table" then
            Config.Sky = data.Sky or ""
            Config.Texture = data.Texture or ""
            Config.Font = data.Font or ""
        end
    end
end

LoadConfig()

-- ==========================================
-- 介面建構
-- ==========================================
if CoreGui:FindFirstChild("rty_CustomUI") then
    CoreGui.rty_CustomUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "rty_CustomUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- 主視窗（純黑背景）
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 270)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -135)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 45)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- 頂部標題欄
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

-- 大標題：rty
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "rty"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 22
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- 收合/展開按鈕
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 30, 0, 30)
ToggleBtn.Position = UDim2.new(1, -35, 0, 4)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleBtn.Text = "—"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = TopBar

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

-- 內容容器
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -38)
ContentFrame.Position = UDim2.new(0, 0, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local isMinimized = false
ToggleBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    ContentFrame.Visible = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 360, 0, 38)
        ToggleBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 360, 0, 270)
        ToggleBtn.Text = "—"
    end
end)

-- 分頁按鈕列
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 32)
TabBar.Position = UDim2.new(0, 10, 0, 8)
TabBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TabBar.Parent = ContentFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 6)
TabCorner.Parent = TabBar

local Pages = {}
local TabButtons = {}

local function CreateTab(name, index)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/3, -4, 1, -4)
    btn.Position = UDim2.new((index - 1) / 3, 2, 0, 2)
    btn.BackgroundColor3 = index == 1 and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(22, 22, 22)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = TabBar
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = btn
    
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, -20, 1, -50)
    page.Position = UDim2.new(0, 10, 0, 45)
    page.BackgroundTransparency = 1
    page.Visible = (index == 1)
    page.Parent = ContentFrame
    
    TabButtons[index] = btn
    Pages[index] = page
    
    btn.MouseButton1Click:Connect(function()
        for i, p in ipairs(Pages) do
            p.Visible = (i == index)
            TabButtons[i].BackgroundColor3 = (i == index) and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(22, 22, 22)
        end
    end)
    
    return page
end

local SkyPage = CreateTab("天空", 1)
local TexturePage = CreateTab("材質包", 2)
local FontPage = CreateTab("字型", 3)

-- 通用輸入框與按鈕產生器（內建自動儲存與啟動套用）
local function BuildPageContent(page, configKey, placeholder, buttonText, callback)
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, 0, 0, 115)
    inputBox.Position = UDim2.new(0, 0, 0, 5)
    inputBox.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    inputBox.TextColor3 = Color3.fromRGB(235, 235, 235)
    inputBox.PlaceholderText = placeholder
    inputBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
    inputBox.Text = Config[configKey] or "" -- 啟動時自動填入上次儲存的設定
    inputBox.Font = Enum.Font.Code
    inputBox.TextSize = 13
    inputBox.TextWrapped = true
    inputBox.MultiLine = true
    inputBox.ClearTextOnFocus = false
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.TextYAlignment = Enum.TextYAlignment.Top
    inputBox.Parent = page
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = inputBox
    
    local boxPad = Instance.new("UIPadding")
    boxPad.PaddingTop = UDim.new(0, 8)
    boxPad.PaddingLeft = UDim.new(0, 8)
    boxPad.PaddingRight = UDim.new(0, 8)
    boxPad.Parent = inputBox

    local applyBtn = Instance.new("TextButton")
    applyBtn.Size = UDim2.new(1, 0, 0, 38)
    applyBtn.Position = UDim2.new(0, 0, 1, -42)
    applyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    applyBtn.Text = buttonText
    applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    applyBtn.Font = Enum.Font.GothamBold
    applyBtn.TextSize = 15
    applyBtn.Parent = page
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = applyBtn

    -- 輸入框內容改變時也即時儲存
    inputBox.FocusLost:Connect(function()
        Config[configKey] = inputBox.Text
        SaveConfig()
    end)

    applyBtn.MouseButton1Click:Connect(function()
        local originalText = applyBtn.Text
        local success, msg = pcall(function()
            return callback(inputBox.Text)
        end)
        if success then
            -- 成功套用後儲存設定
            Config[configKey] = inputBox.Text
            SaveConfig()
            
            applyBtn.Text = msg or "✓ 已成功套用並儲存！"
            applyBtn.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
        else
            applyBtn.Text = "✕ 格式錯誤，請檢查貼上內容"
            applyBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
            warn("[rty UI Error]:", msg)
        end
        task.wait(1.8)
        applyBtn.Text = originalText
        applyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)

    -- 腳本啟動時，如果該分頁有儲存過設定，自動執行套用
    if Config[configKey] and Config[configKey] ~= "" then
        task.spawn(function()
            pcall(function()
                callback(Config[configKey])
            end)
        end)
    end
end

-- ==========================================
-- 1. 天空設定邏輯
-- ==========================================
BuildPageContent(
    SkyPage,
    "Sky",
    "請貼上天空圖片網址或 ID\n例如：rbxassetid://123456789 或純數字 ID",
    "套用並儲存天空",
    function(input)
        local cleanId = input:match("%d+")
        assert(cleanId, "找不到有效的圖片 ID")
        local assetUrl = "rbxassetid://" .. cleanId
        
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Sky") then v:Destroy() end
        end
        
        local newSky = Instance.new("Sky")
        newSky.Name = "rty_CustomSky"
        newSky.SkyboxBk = assetUrl
        newSky.SkyboxDn = assetUrl
        newSky.SkyboxFt = assetUrl
        newSky.SkyboxLf = assetUrl
        newSky.SkyboxRt = assetUrl
        newSky.SkyboxUp = assetUrl
        newSky.Parent = Lighting
        return "✓ 天空已套用並儲存！"
    end
)

-- ==========================================
-- 2. 材質包設定邏輯（專屬 JSON FastFlags 解析器）
-- ==========================================
BuildPageContent(
    TexturePage,
    "Texture",
    "請貼上 JSON 材質包設定：\n{\n  \"DFIntTaskSchedulerTargetFps\": 999,\n  \"FIntDebugForceMSAASamples\": 0\n}",
    "套用並儲存材質包",
    function(input)
        local trimmed = input:gsub("^%s*(.-)%s*$", "%1")
        assert(trimmed ~= "", "輸入內容為空")
        assert(trimmed:sub(1, 1) == "{", "必須為 JSON 格式 ({...})")
        
        local flagFunc = setfflag or (syn and syn.set_fflag)
        assert(flagFunc, "目前執行器不支援 setfflag 功能")
        
        local parsedData = HttpService:JSONDecode(trimmed)
        local appliedCount = 0
        
        for key, value in pairs(parsedData) do
            -- 自動移除常見的前綴 (DFFlag, FInt, DFInt, FString 等) 以相容不同執行器的 setfflag 規範
local cleanKey = key:gsub("^D?F[A-Za-z]+", "")
local ok = pcall(function()
flagFunc(cleanKey, tostring(value))
end)
if not ok then
pcall(function()
flagFunc(key, tostring(value))
end)
end
appliedCount = appliedCount + 1
end
assert(appliedCount > 0, "JSON 內沒有有效的參數")
return "✓ 已套用並儲存 " .. appliedCount .. " 項設定！"
end
)
-- ==========================================
-- 3. 字型設定邏輯
-- ==========================================
local function ApplyFontToAll(targetFont)
local function changeFont(obj)
if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
obj.Font = targetFont
end
end
for _, v in ipairs(game:GetDescendants()) do
pcall(changeFont, v)
end
game.DescendantAdded:Connect(function(v)
pcall(changeFont, v)
end)
end
BuildPageContent(
FontPage,
"Font",
"請輸入 Roblox 字型名稱\n例如：GothamBlack, SourceSansBold, Arcade, Code, PermanentMarker",
"套用並儲存字型",
function(input)
local trimmed = input:gsub("^%s*(.-)%s*$", "%1")
assert(trimmed ~= "", "請輸入字型名稱")
local targetFont = nil
for _, fontEnum in ipairs(Enum.Font:GetEnumItems()) do
if fontEnum.Name:lower() == trimmed:lower() then
targetFont = fontEnum
break
end
end
assert(targetFont, "找不到此字型名稱")
ApplyFontToAll(targetFont)
return "✓ 字型 (" .. targetFont.Name .. ") 已儲存！"
end
)
