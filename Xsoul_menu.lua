-- Xsoul Ui
-- init
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- services
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")
local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new
local http = game:GetService("HttpService")

-- Data persistence system
local DataStoreService = game:GetService("DataStoreService")
local userSettingsStore
local dataStoreAvailable = false

local success, store = pcall(function()
    return DataStoreService:GetDataStore("XsoulUserSettings_" .. player.UserId)
end)
if success then
    userSettingsStore = store
    dataStoreAvailable = true
end

-- Get client ID for exploit compatibility
local clientId = player.UserId

local savedSettings = {
    themes = {},
    fontSize = 14,
    font = "Gotham",
    language = "English",
    toggles = {},  -- Store toggle states
    textboxes = {},  -- Store textbox values
    sliders = {},  -- Store slider values
    dropdowns = {},  -- Store dropdown selections
    colorpickers = {},  -- Store color picker values
    windowPosition = nil,  -- Store window position
    isMaximized = false,  -- Store window maximized state
    selectedPage = nil  -- Store selected page name
}

-- Use local file storage for exploit environments (more reliable)
local settingsFile = "xsoul_settings_" .. player.UserId .. ".json"

local function saveSettings()
    -- Will be defined after themes table
end

local function loadSettings()
    -- Will be defined after themes table
end

-- additional
local utility = {}

-- themes
local objects = {}
local themes = {
    NotToggledColor =  Color3.fromRGB(100, 80, 150),
    Background = Color3.fromRGB(10, 5, 20),
    Glow = Color3.fromRGB(80, 40, 160),
    Accent = Color3.fromRGB(0, 255, 255),
    LightContrast = Color3.fromRGB(30, 15, 50),
    DarkContrast = Color3.fromRGB(20, 10, 35),
    TextColor = Color3.fromRGB(0, 255, 255),
    ButtonColor = Color3.fromRGB(100, 80, 150),
    ToggledColor = Color3.fromRGB(0, 200, 255),
    SliderColor = Color3.fromRGB(120, 60, 200),
    TopBarColor = Color3.fromRGB(60, 20, 120),
}

-- Local file fallback using HttpService (exploit-compatible)
local function saveToLocal()
    local success, err = pcall(function()
        local themeData = {}
        for name, color in pairs(themes) do
            if typeof(color) == "Color3" then
                -- Save as RGB values (0-255) for better compatibility
                themeData[name] = {R = color.R * 255, G = color.G * 255, B = color.B * 255}
            end
        end
        savedSettings.themes = themeData
        local json = http:JSONEncode(savedSettings)
        
        -- Try workspace storage first (most reliable for Xeno/PC exploits)
        local workspaceSuccess = pcall(function()
            local folder = workspace:FindFirstChild("XsoulSettings")
            if not folder then
                folder = Instance.new("Folder")
                folder.Name = "XsoulSettings"
                folder.Parent = workspace
            end
            local value = folder:FindFirstChild("Settings")
            if not value then
                value = Instance.new("StringValue")
                value.Name = "Settings"
                value.Parent = folder
            end
            value.Value = json
            print("Settings saved to workspace")
        end)
        
        if workspaceSuccess then
            return true
        end
        
        -- Try PlayerGui storage as fallback
        local playerGuiSuccess = pcall(function()
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                local folder = playerGui:FindFirstChild("XsoulSettings")
                if not folder then
                    folder = Instance.new("Folder")
                    folder.Name = "XsoulSettings"
                    folder.Parent = playerGui
                end
                local value = folder:FindFirstChild("Settings")
                if not value then
                    value = Instance.new("StringValue")
                    value.Name = "Settings"
                    value.Parent = folder
                end
                value.Value = json
                print("Settings saved to PlayerGui")
            end
        end)
        
        if playerGuiSuccess then
            return true
        end
        
        -- Try simple file path as last resort (for Delta/mobile)
        local fileSuccess = pcall(function()
            writefile(settingsFile, json)
            print("Settings saved to: " .. settingsFile)
        end)
        
        if not fileSuccess then
            warn("All save methods failed")
            return false
        end
        
        return true
    end)
    if not success then
        warn("Failed to save settings: " .. tostring(err))
    end
end

local function loadFromLocal()
    local success, data = pcall(function()
        -- Try workspace storage first (most reliable for Xeno/PC exploits)
        local workspaceData = nil
        local workspaceSuccess = pcall(function()
            local folder = workspace:FindFirstChild("XsoulSettings")
            if folder then
                local value = folder:FindFirstChild("Settings")
                if value and value.Value ~= "" then
                    print("Settings loaded from workspace")
                    workspaceData = http:JSONDecode(value.Value)
                end
            end
        end)
        if workspaceSuccess and workspaceData then
            return workspaceData
        end
        
        -- Try PlayerGui storage as fallback
        local playerGuiData = nil
        local playerGuiSuccess = pcall(function()
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                local folder = playerGui:FindFirstChild("XsoulSettings")
                if folder then
                    local value = folder:FindFirstChild("Settings")
                    if value and value.Value ~= "" then
                        print("Settings loaded from PlayerGui")
                        playerGuiData = http:JSONDecode(value.Value)
                    end
                end
            end
        end)
        if playerGuiSuccess and playerGuiData then
            return playerGuiData
        end
        
        -- Try simple file path as last resort (for Delta/mobile)
        local fileData = nil
        local fileSuccess = pcall(function()
            if isfile(settingsFile) then
                local json = readfile(settingsFile)
                print("Settings loaded from: " .. settingsFile)
                fileData = http:JSONDecode(json)
            end
        end)
        if fileSuccess and fileData then
            return fileData
        end
        
        return nil
    end)
    if success and data then
        savedSettings = data
        if savedSettings.themes then
            for name, colorData in pairs(savedSettings.themes) do
                if themes[name] then
                    -- Values are already in 0-255 range, no need to multiply again
                    themes[name] = Color3.fromRGB(math.floor(colorData.R), math.floor(colorData.G), math.floor(colorData.B))
                end
            end
        end
        return true
    end
    return false
end

-- Now define the actual saveSettings and loadSettings functions
saveSettings = function()
    -- Prioritize local file for exploit environments (more reliable)
    saveToLocal()
    
    -- Also try DataStore as backup
    if dataStoreAvailable then
        local success, err = pcall(function()
            local themeData = {}
            for name, color in pairs(themes) do
                if typeof(color) == "Color3" then
                    -- Save as RGB values (0-255) for better compatibility
                    themeData[name] = {R = color.R * 255, G = color.G * 255, B = color.B * 255}
                end
            end
            savedSettings.themes = themeData
            userSettingsStore:SetAsync("settings", savedSettings)
        end)
        if not success then
            warn("Failed to save to DataStore: " .. tostring(err))
        end
    end
end

loadSettings = function()
    -- Prioritize local file for exploit environments (more reliable)
    local localLoaded = loadFromLocal()
    if localLoaded then
        return true
    end
    
    -- Try DataStore as backup
    if dataStoreAvailable then
        local success, data = pcall(function()
            return userSettingsStore:GetAsync("settings")
        end)
        if success and data then
            savedSettings = data
            if savedSettings.themes then
                for name, colorData in pairs(savedSettings.themes) do
                    if themes[name] then
                        -- Values are already in 0-255 range, no need to multiply again
                        themes[name] = Color3.fromRGB(math.floor(colorData.R), math.floor(colorData.G), math.floor(colorData.B))
                    end
                end
            end
            return true
        end
    end
    return false
end

-- Helper functions for saving/loading individual element values
local function saveToggleValue(key, value)
    if key and value ~= nil then
        savedSettings.toggles[key] = value
    end
end

local function loadToggleValue(key, default)
    if key and savedSettings.toggles[key] ~= nil then
        return savedSettings.toggles[key]
    end
    return default
end

local function saveTextboxValue(key, value)
    if key and value ~= nil then
        savedSettings.textboxes[key] = value
    end
end

local function loadTextboxValue(key, default)
    if key and savedSettings.textboxes[key] ~= nil then
        return savedSettings.textboxes[key]
    end
    return default
end

local function saveSliderValue(key, value)
    if key and value ~= nil then
        savedSettings.sliders[key] = value
    end
end

local function loadSliderValue(key, default)
    if key and savedSettings.sliders[key] ~= nil then
        return savedSettings.sliders[key]
    end
    return default
end

local function saveDropdownValue(key, value)
    if key and value ~= nil then
        savedSettings.dropdowns[key] = value
    end
end

local function loadDropdownValue(key, default)
    if key and savedSettings.dropdowns[key] ~= nil then
        return savedSettings.dropdowns[key]
    end
    return default
end

local function saveColorPickerValue(key, value)
    if key and value ~= nil then
        savedSettings.colorpickers[key] = {R = value.R, G = value.G, B = value.B}
    end
end

local function loadColorPickerValue(key, default)
    if key and savedSettings.colorpickers[key] ~= nil then
        return savedSettings.colorpickers[key]
    end
    return default
end

-- Load settings immediately after themes are defined
loadSettings()

-- Debounced save to avoid performance issues
local saveDebounce = false
local function debouncedSave()
    if saveDebounce then return end
    saveDebounce = true
    spawn(function()
        wait(0.5) -- Wait 0.5 second before saving
        saveSettings()
        saveDebounce = false
    end)
end

do
    -- Dynamic Scroll
    function dynamicscroll(scrollingframe,uilis)
        uilis:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            scrollingframe.CanvasSize = UDim2.new(0, 0, 0, uilis.AbsoluteContentSize.Y + 10)
        end)
    end 

    function utility:Create(instance, properties, children)
        local object = Instance.new(instance)

        for i, v in pairs(properties or {}) do
            object[i] = v

            if typeof(v) == "Color3" then -- save for theme changer later
                local theme = utility:Find(themes, v)

                if theme then
                    objects[theme] = objects[theme] or {}
                    objects[theme][i] = objects[theme][i] or setmetatable({}, {_mode = "k"})

                    table.insert(objects[theme][i], object)
                end
            end
        end

        for i, module in pairs(children or {}) do
            module.Parent = object
        end

        return object
    end

    function utility:Tween(instance, properties, duration, ...)
        tween:Create(instance, tweeninfo(duration, ...), properties):Play()
    end

    function utility:Wait()
        run.RenderStepped:Wait()
        return true
    end

    function utility:Find(table, value) -- table.find doesn't work for dictionaries
        for i, v in  pairs(table) do
            if typeof(v) == "Color3" and typeof(value) == "Color3" then
                if v.R == value.R and v.G == value.G and v.B == value.B then
                    return i
                end
            elseif v == value then
                return i
            end
        end
    end

    function utility:Sort(pattern, values)
        local new = {}
        pattern = pattern:lower()

        if pattern == "" then
            return values
        end

        for i, value in pairs(values) do
            if tostring(value):lower():find(pattern) then
                table.insert(new, value)
            end
        end

        return new
    end

    function utility:Pop(object, shrink)
        local clone = object:Clone()

        clone.AnchorPoint = Vector2.new(0.5, 0.5)
        clone.Size = clone.Size - UDim2.new(0, shrink, 0, shrink)
        clone.Position = UDim2.new(0.5, 0, 0.5, 0)

        clone.Parent = object
        clone:ClearAllChildren()

        object.ImageTransparency = 1
        utility:Tween(clone, {Size = object.Size}, 0.2)

        spawn(function()
            wait(0.2)

            object.ImageTransparency = 0
            clone:Destroy()
        end)

        return clone
    end

    function utility:InitializeKeybind()
        self.keybinds = {}
        self.ended = {}

        input.InputBegan:Connect(function(key)
            if self.keybinds[key.KeyCode] then
                for i, bind in pairs(self.keybinds[key.KeyCode]) do
                    bind()
                end
            end
        end)

        input.InputEnded:Connect(function(key)
            if key.UserInputType == Enum.UserInputType.MouseButton1 then
                for i, callback in pairs(self.ended) do
                    callback()
                end
                -- Save settings after dragging ends (window position is saved in callback)
                saveSettings()
            end
        end)
    end

    function utility:BindToKey(key, callback)

        self.keybinds[key] = self.keybinds[key] or {}

        table.insert(self.keybinds[key], callback)

        return {
            UnBind = function()
                for i, bind in pairs(self.keybinds[key]) do
                    if bind == callback then
                        table.remove(self.keybinds[key], i)
                    end
                end
            end
        }
    end

    function utility:KeyPressed() -- yield until next key is pressed
        local key = input.InputBegan:Wait()

        while key.UserInputType ~= Enum.UserInputType.Keyboard	 do
            key = input.InputBegan:Wait()
        end

        wait() -- overlapping connection

        return key
    end

    function utility:DraggingEnabled(frame, parent)

        parent = parent or frame

        -- stolen from wally or kiriot, kek
        local dragging = false
        local dragInput, mousePos, framePos

        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                mousePos = input.Position
                framePos = parent.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        input.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - mousePos
                parent.Position  = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            end
        end)

    end

    function utility:DraggingEnded(callback)
        table.insert(self.ended, callback)
    end

end

-- classes

local library = {} -- main
local page = {}
local section = {}

do
    library.__index = library
    page.__index = page
    section.__index = section

    -- new classes

    function library.new(title)
        -- Detect mobile device
        local isMobile = input.TouchEnabled

        -- Set different sizes for mobile vs desktop
        local windowSize = isMobile and UDim2.new(0, 340, 0, 280) or UDim2.new(0, 530, 0, 390)
        local windowPosition = isMobile and UDim2.new(0.5, -170, 0.05, 0) or UDim2.new(0.25, 0, 0.052435593, 0)

        local container = utility:Create("ScreenGui", {
            Name = title,
            Parent = game.CoreGui
        }, {
            utility:Create("ImageLabel", {
                Name = "Main",
                BackgroundTransparency = 1,
                Position = windowPosition,
                Size = windowSize,
                Image = "rbxassetid://4641149554",
                ImageColor3 = themes.Background,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(4, 4, 296, 296)
            }, {
                utility:Create("ImageLabel", {
                    Name = "Glow",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -15, 0, -15),
                    Size = UDim2.new(1, 30, 1, 30),
                    ZIndex = 0,
                    Image = "rbxassetid://5028857084",
                    ImageColor3 = themes.Glow,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(24, 24, 276, 276)
                }),
                utility:Create("ImageLabel", {
                    Name = "Pages",
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Position = UDim2.new(0, 0, 0, 38),
                    Size = UDim2.new(0, 126, 1, -38),
                    ZIndex = 3,
                    Image = "rbxassetid://5012534273",
                    ImageColor3 = themes.Background,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(4, 4, 296, 296)
                },
                {
                    utility:Create("Frame", {
                        Name = "sadsad",
                        BackgroundTransparency = 0,
                        BackgroundColor3 = themes.LightContrast,
                        BorderSizePixel = 0,
                        AnchorPoint = Vector2.new(0.5,0),
                        Position = UDim2.new(0.5, 0, 0, 65),
                        Size = UDim2.new(0,60,0,2),
                        ZIndex = 5
                    }),
                    utility:Create("ImageLabel", {
                        Name = "HubLogo",
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0.5,-0.5),
                        Position = UDim2.new(0.5, 0, 0, 5),
                        Size = UDim2.new(0,90,0,90),
                        ZIndex = 5,
                        ImageColor3 = Color3.new(1,1,1),
                        Image = "http://www.roblox.com/asset/?id=118141134715671"
                    }),
                    utility:Create("ScrollingFrame", {
                        Name = "Pages_Container",
                        Active = true,
                        BackgroundTransparency = 1,
Position = UDim2.new(0, 0, 0, 100),
                        Size = UDim2.new(1, 0, 1, -20),
                        CanvasSize = UDim2.new(0, 0, 0, 480),
                        ScrollBarThickness = 5,
                        ScrollBarImageTransparency = 0,
                        ScrollBarImageColor3 = themes.LightContrast
                    }, {
                    utility:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 2)
                    })
                    })
                }

                ),
                utility:Create("ImageLabel", {
                    Name = "TopBar",
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Size = UDim2.new(1, 0, 0, 38),
                    ZIndex = 5,
                    Image = "rbxassetid://4595286933",
                    ImageColor3 = themes.TopBarColor,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(4, 4, 296, 296)
                }, {
                    utility:Create("TextLabel", {
                        Name = "Title",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        ZIndex = 5,
                        Font = Enum.Font.GothamBlack,
                        Text = title,
                        RichText = true,
                        TextColor3 = themes.TextColor,
                        TextSize = 18,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        TextYAlignment = Enum.TextYAlignment.Center
                    }),
                    utility:Create("TextButton", {
                        Name = "ToggleButton",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -90, 0.5, -10),
                        Size = UDim2.new(0, 24, 0, 24),
                        ZIndex = 5,
                        Font = Enum.Font.GothamBlack,
                        Text = "−",
                        TextColor3 = themes.TextColor,
                        TextSize = 20,
                        AutoButtonColor = false,
                        Visible = false
                    }),
                    utility:Create("TextButton", {
                        Name = "MaximizeButton",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -60, 0.5, -10),
                        Size = UDim2.new(0, 24, 0, 24),
                        ZIndex = 5,
                        Font = Enum.Font.GothamBlack,
                        Text = "□",
                        TextColor3 = themes.TextColor,
                        TextSize = 18,
                        AutoButtonColor = false,
                        Visible = false
                    }),
                    utility:Create("TextButton", {
                        Name = "CloseButton",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -30, 0.5, -10),
                        Size = UDim2.new(0, 24, 0, 24),
                        ZIndex = 5,
                        Font = Enum.Font.GothamBlack,
                        Text = "x",
                        TextColor3 = themes.TextColor,
                        TextSize = 18,
                        AutoButtonColor = false,
                        Visible = false
                    }),
                })
            })
        })


        utility:InitializeKeybind()
        utility:DraggingEnabled(container.Main, container.Main)
        
        -- Create Open Button (hidden by default)
        local openButton = utility:Create("ImageButton", {
            Name = "OpenButton",
            Parent = container,
            BackgroundTransparency = 0,
            BackgroundColor3 = themes.TopBarColor,
            Position = UDim2.new(0.25, 0, 0.052435593, 0),
            Size = UDim2.new(0, 50, 0, 50),
            ZIndex = 5,
            Image = "",
            AutoButtonColor = false,
            Visible = false
        }, {
            utility:Create("UICorner", {
                CornerRadius = UDim.new(0, 8)
            }),
            utility:Create("TextLabel", {
                Name = "Title",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 6,
                Font = Enum.Font.GothamBlack,
                Text = "Xsoul",
                RichText = true,
                TextColor3 = themes.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                Visible = true
            })
        })
        
        -- Enable dragging for open button
        utility:DraggingEnabled(openButton, openButton)
        
        local lib = setmetatable({
            container = container,
            pagesContainer = container.Main.Pages.Pages_Container,
            pages = {},
            openButton = openButton,
            toggleButton = container.Main.TopBar.ToggleButton,
            closeButton = container.Main.TopBar.CloseButton,
            position = container.Main.Position,
            toggling = false,
            isMobile = isMobile,
            windowSize = windowSize
        }, library)
        
        -- Set initial state: menu is open, show toggle/close buttons
        lib.toggleButton.Visible = true
        lib.closeButton.Visible = true
        lib.openButton.Visible = false
        lib.position = nil  -- nil = menu is open
        lib.isMaximized = savedSettings.isMaximized or false
        
        -- Apply saved window position if available
        if savedSettings.windowPosition then
            container.Main.Position = UDim2.new(
                savedSettings.windowPosition.X.Scale,
                savedSettings.windowPosition.X.Offset,
                savedSettings.windowPosition.Y.Scale,
                savedSettings.windowPosition.Y.Offset
            )
        end
        
        -- Apply saved maximized state if available
        if lib.isMaximized then
            lib.normalPosition = container.Main.Position
            local margin = lib.isMobile and 5 or 20
            container.Main.Size = UDim2.new(1, -margin * 2, 1, -margin * 2)
            container.Main.Position = UDim2.new(0, margin, 0, margin)
        end
        
        -- Store maximize button reference
        lib.maximizeButton = container.Main.TopBar.MaximizeButton
        lib.maximizeButton.Visible = true
        
        -- Save window position when dragging ends
        utility:DraggingEnded(function()
            if container.Main then
                savedSettings.windowPosition = {
                    X = {Scale = container.Main.Position.X.Scale, Offset = container.Main.Position.X.Offset},
                    Y = {Scale = container.Main.Position.Y.Scale, Offset = container.Main.Position.Y.Offset}
                }
            end
        end)
        
        -- Toggle button click event
        lib.toggleButton.Activated:Connect(function()
            lib:toggle()
            saveSettings()
        end)
        
        -- Close button (exit) click event
        lib.closeButton.Activated:Connect(function()
            saveSettings()
            utility:Pop(container.Main, 5)
            container:Destroy()
        end)
        
        -- Maximize button click event
        lib.maximizeButton.Activated:Connect(function()
            if lib.isMaximized then
                -- Return to normal size
                local normalHeight = lib.isMobile and 280 or 428
                utility:Tween(container.Main, {
                    Size = lib.windowSize + UDim2.new(0, 0, 0, normalHeight - lib.windowSize.Y.Offset),
                    Position = lib.normalPosition or (lib.isMobile and UDim2.new(0.5, -160, 0.05, 0) or UDim2.new(0.25, 0, 0.052435593, 0))
                }, 0.3)
                lib.isMaximized = false
            else
                -- Maximize (almost full screen)
                lib.normalPosition = container.Main.Position
                local margin = lib.isMobile and 5 or 20
                utility:Tween(container.Main, {
                    Size = UDim2.new(1, -margin * 2, 1, -margin * 2),
                    Position = UDim2.new(0, margin, 0, margin)
                }, 0.3)
                lib.isMaximized = true
            end
            savedSettings.isMaximized = lib.isMaximized
            saveSettings()
        end)
        
        -- Open button click event
        lib.openButton.Activated:Connect(function()
            lib:toggle()
            saveSettings()
        end)

        return lib
    end
    
    function page.new(library, title, icon)
        
        local button = utility:Create("TextButton", {
            Name = title,
            Parent = library.pagesContainer,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 26),
            ZIndex = 3,
            AutoButtonColor = false,
            Font = Enum.Font.Gotham,
            Text = "",
            TextSize = 14
        }, {
                utility:Create("TextLabel", {
                    Name = "Title",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 25, 0.5, 0),
                    Size = UDim2.new(1, -25, 1, 0),
                    ZIndex = 3,
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = themes.TextColor,
                    TextSize = 18,
                    TextTransparency = 0.10000000149012,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
            icon and utility:Create("ImageLabel", {
                Name = "Icon",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                ZIndex = 3,
                Image = "rbxassetid://" .. tostring(icon),
                ImageColor3 = themes.TextColor,
                ImageTransparency = 0.10000000149012,
                ScaleType = Enum.ScaleType.Fit
            }) or {}
        })

        local container = utility:Create("ScrollingFrame", {
            Name = title,
            Parent = library.container.Main,
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 134, 0, 46),
            Size = UDim2.new(1, -142, 1, -56),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = themes.DarkContrast,
            Visible = false
        })
        local uilist =  utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = container, 
        })
        --[[

        uilist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            container.CanvasSize = UDim2.new(0, 0, 0, uilist.AbsoluteContentSize.Y + 10)
        end) 
        ]]

        return setmetatable({
            library = library,
            container = container,
            button = button,
            sections = {}
        }, page)
    end

    function section.new(page, title)
        local container = utility:Create("ImageLabel", {
            Name = title,
            Parent = page.container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0, 28),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = themes.LightContrast,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(4, 4, 296, 296),
            ClipsDescendants = true
        }, {
            utility:Create("Frame", {
                Name = "Container",
                Active = true,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 8, 0, 8),
                Size = UDim2.new(1, -16, 1, -16),
                ClipsDescendants = true
            }, {
            utility:Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                ZIndex = 2,
                Font = Enum.Font.Gotham,
                Text =  title,
                TextColor3 = themes.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = 0.10000000149012
            }),
                utility:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 4)
                })
            })
        })


        return setmetatable({
            page = page,
            container = container.Container,
            colorpickers = {},
            modules = {},
            binds = {},
            lists = {},
        }, section)
    end

    function library:NewPage(...)

        local page = page.new(self, ...)
        local button = page.button

        table.insert(self.pages, page)

        button.MouseButton1Click:Connect(function()
            self:SelectPage(page, true)
        end)

        return page
    end

    function page:NewSecction(...)
        local section = section.new(self, ...)

        table.insert(self.sections, section)

        return section
    end

    -- functions

    function library:setTheme(theme, color3)
        themes[theme] = color3

        -- Update tracked objects
        if objects[theme] then
            for property, objs in pairs(objects[theme]) do
                for i, object in pairs(objs) do
                    if not object.Parent or (object.Name == "Button" and object.Parent.Name == "ColorPicker") then
                        objs[i] = nil -- i can do this because weak tables :D
                    else
                        object[property] = color3
                    end
                end
            end
        end

        -- Special handling for TextColor - update all text elements
        if theme == "TextColor" then
            for _, child in pairs(self.container:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    child.TextColor3 = color3
                end
            end
        end

        -- Save settings after theme change
        saveSettings()
    end

    function library:toggle()

        if self.toggling then
            return
        end

        self.toggling = true

        local container = self.container.Main
        local topbar = container.TopBar

        if self.position then
            -- Opening menu
            local openHeight = self.isMobile and 280 or 428
            utility:Tween(container, {
                Size = self.windowSize + UDim2.new(0, 0, 0, openHeight - self.windowSize.Y.Offset),
                Position = self.position
            }, 0.2)
            wait(0.2)

            utility:Tween(topbar, {Size = UDim2.new(1, 0, 0, 38)}, 0.2)
            wait(0.2)

            container.ClipsDescendants = false
            self.position = nil
            self.openButton.Visible = false
            self.openButton.Title.Visible = false
            self.toggleButton.Visible = true
            self.closeButton.Visible = true
            self.maximizeButton.Visible = true

            -- Reset maximized state when opening from collapsed
            if self.isMaximized then
                self.isMaximized = false
            end
            
            -- Ensure focused page container is visible
            if self.focusedPage then
                self.focusedPage.container.Visible = true
            end
            
            -- Expand all sections in the focused page
            if self.focusedPage then
                for i, section in pairs(self.focusedPage.sections) do
                    -- Calculate proper expanded size
                    local padding = 4
                    local size = (4 * padding) + section.container.Title.AbsoluteSize.Y
                    
                    for _, module in pairs(section.modules) do
                        size = size + module.AbsoluteSize.Y + padding
                    end
                    
                    utility:Tween(section.container.Parent, {Size = UDim2.new(1, -10, 0, size)}, 0.1)
                    utility:Tween(section.container.Title, {TextTransparency = 0}, 0.1)
                end
            end
        else
            -- Closing menu
            self.position = container.Position
            container.ClipsDescendants = true

            utility:Tween(topbar, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)
            wait(0.2)

            local closeHeight = self.isMobile and 280 or 428
            utility:Tween(container, {
                Size = UDim2.new(0, self.windowSize.X.Offset, 0, 0),
                Position = self.position + UDim2.new(0, 0, 0, closeHeight)
            }, 0.2)
            wait(0.2)
            
            self.openButton.Visible = true
            self.openButton.Title.Visible = true
            self.toggleButton.Visible = false
            self.closeButton.Visible = false
            self.maximizeButton.Visible = false
            
            -- Hide focused page container when closing
            if self.focusedPage then
                self.focusedPage.container.Visible = false
            end
            
            -- Collapse all sections in the focused page
            if self.focusedPage then
                for i, section in pairs(self.focusedPage.sections) do
                    utility:Tween(section.container.Parent, {Size = UDim2.new(1, -10, 0, 28)}, 0.1)
                    utility:Tween(section.container.Title, {TextTransparency = 1}, 0.1)
                end
            end
        end

        self.toggling = false
    end

    -- new modules

    function library:Notify(title, text, callback)

        -- overwrite last notification
        if self.activeNotification then
            self.activeNotification = self.activeNotification()
        end

        -- standard create
        local notification = utility:Create("ImageLabel", {
            Name = "Notification",
            Parent = self.container,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 200, 0, 60),
            Image = "rbxassetid://5028857472",
            ImageColor3 = themes.Background,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(4, 4, 296, 296),
            ZIndex = 3,
            ClipsDescendants = true
        }, {
            utility:Create("ImageLabel", {
                Name = "Flash",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://4641149554",
                ImageColor3 = themes.TextColor,
                ZIndex = 5
            }),
            utility:Create("ImageLabel", {
                Name = "Glow",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, -15, 0, -15),
                Size = UDim2.new(1, 30, 1, 30),
                ZIndex = 2,
                Image = "rbxassetid://5028857084",
                ImageColor3 = themes.Glow,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(24, 24, 276, 276)
            }),
            utility:Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 8),
                Size = UDim2.new(1, -40, 0, 16),
                ZIndex = 4,
                Font = Enum.Font.GothamSemibold,
                TextColor3 = themes.TextColor,
                TextSize = 14.000,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            utility:Create("TextLabel", {
                Name = "Text",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 1, -24),
                Size = UDim2.new(1, -40, 0, 16),
                ZIndex = 4,
                Font = Enum.Font.Gotham,
                TextColor3 = themes.TextColor,
                TextSize = 12.000,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            utility:Create("ImageButton", {
                Name = "Accept",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -26, 0, 8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = "rbxassetid://5012538259",
                ImageColor3 = themes.TextColor,
                ZIndex = 4
            }),
            utility:Create("ImageButton", {
                Name = "Decline",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -26, 1, -24),
                Size = UDim2.new(0, 16, 0, 16),
                Image = "rbxassetid://5012538583",
                ImageColor3 = themes.TextColor,
                ZIndex = 4
            })
        })

        -- dragging
        utility:DraggingEnabled(notification)

        -- position and size
        title = title or "Notification"
        text = text or ""

        notification.Title.Text = title
        notification.Text.Text = text

        local padding = 10
        local textSize = game:GetService("TextService"):GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(math.huge, 16))

        notification.Position = library.lastNotification or UDim2.new(0, padding, 1, -(notification.AbsoluteSize.Y + padding))
        notification.Size = UDim2.new(0, 0, 0, 60)

        utility:Tween(notification, {Size = UDim2.new(0, textSize.X + 70, 0, 60)}, 0.2)
        wait(0.2)

        notification.ClipsDescendants = false
        utility:Tween(notification.Flash, {
            Size = UDim2.new(0, 0, 0, 60),
            Position = UDim2.new(1, 0, 0, 0)
        }, 0.2)

        -- callbacks
        local active = true
        local close = function()

            if not active then
                return
            end

            active = false
            notification.ClipsDescendants = true

            library.lastNotification = notification.Position
            notification.Flash.Position = UDim2.new(0, 0, 0, 0)
            utility:Tween(notification.Flash, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)

            wait(0.2)
            utility:Tween(notification, {
                Size = UDim2.new(0, 0, 0, 60),
                Position = notification.Position + UDim2.new(0, textSize.X + 70, 0, 0)
            }, 0.2)

            wait(0.2)
            notification:Destroy()
        end

        self.activeNotification = close

        notification.Accept.MouseButton1Click:Connect(function()

            if not active then
                return
            end

            if callback then
                callback(true)
            end

            close()
        end)

        notification.Decline.MouseButton1Click:Connect(function()

            if not active then
                return
            end

            if callback then
                callback(false)
            end

            close()
        end)
    end

    function section:Button(title, callback)
        local button = utility:Create("ImageButton", {
            Name = "Button",
            Parent = self.container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = themes.ButtonColor,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
        }, {
            utility:Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Gotham,
                Text = title,
                TextColor3 = themes.TextColor,
                TextSize = 14,
                TextTransparency = 0.10000000149012
            })
        })

        table.insert(self.modules, button)
        --self:Resize()

        local text = button.Title
        local debounce

        button.MouseButton1Click:Connect(function()

            if debounce then
                return
            end

            -- animation
            utility:Pop(button, 10)

            debounce = true
            text.TextSize = 0
            utility:Tween(button.Title, {TextSize = 16}, 0.2)

            wait(0.2)
            utility:Tween(button.Title, {TextSize = 14}, 0.2)

            if callback then
                callback(function(...)
                    self:updateButton(button, ...)
                end)
            end

            debounce = false
        end)
        local buttonfunc = {}
        function buttonfunc:SetText()
            print("yo")
        end 

        return buttonfunc,button
    end

    function section:Toggle(title, default, callback)
        local sec = self 

        -- local title = t or "Toggle"
        -- local default = typeof(d) == 'bool' and d or false
        -- local callback = typeof(d) == 'function' and d or typeof(c) == 'function' and c or function() end

        local toggle = utility:Create("ImageButton", {
            Name = "Toggle",
            Parent = self.container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = themes.DarkContrast,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
        },{
            utility:Create("TextLabel", {
                Name = "Title",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0.5, 1),
                Size = UDim2.new(0.5, 0, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Gotham,
                Text = title,
                TextColor3 = themes.TextColor,
                TextSize = 12,
                TextTransparency = 0.10000000149012,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            utility:Create("ImageLabel", {
                Name = "Button",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -50, 0.5, -8),
                Size = UDim2.new(0, 40, 0, 16),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = themes.NotToggledColor,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
                utility:Create("ImageLabel", {
                    Name = "Frame",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 2, 0.5, -6),
                    Size = UDim2.new(1, -22, 1, -4),
                    ZIndex = 2,
                    Image = "rbxassetid://5028857472",
                    ImageColor3 = themes.TextColor,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                })
            })
        })

        table.insert(self.modules, toggle)
        --self:Resize()

        local active = default
        self:updateToggle(toggle, nil, active)

        -- Generate unique key and load saved value (with error handling)
        local toggleKey
        pcall(function()
            if sec.page and sec.page.library and sec.page.library.container and sec.page.button then
                toggleKey = sec.page.library.container.Name .. "_" .. sec.page.button.Name .. "_" .. title
                local savedValue = loadToggleValue(toggleKey, default)
                if savedValue ~= nil then
                    active = savedValue
                    self:updateToggle(toggle, nil, active)
                end
            end
        end)

        toggle.MouseButton1Click:Connect(function()
            active = not active
            self:updateToggle(toggle, nil, active)
            
            if toggleKey then
                saveToggleValue(toggleKey, active)
                debouncedSave()
            end

            if callback then
                callback(active, function(...)
                    self:updateToggle(toggle, ...)
                end)
            end
        end)
        local togglefunc = {}
        function togglefunc:Set(bool)
            active =  bool
            sec:updateToggle(toggle,nil,active)
            if toggleKey then
                saveToggleValue(toggleKey, active)
                debouncedSave()
            end
            if callback then
                callback(active, function(...)
                    sec:updateToggle(toggle, ...)
                end)
            end

        end 

        

        return togglefunc,toggle
    end

    function section:Textbox(title, default, callback)
        local textbox = utility:Create("ImageButton", {
            Name = "Textbox",
            Parent = self.container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = themes.DarkContrast,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
        }, {
            utility:Create("TextLabel", {
                Name = "Title",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0.5, 1),
                Size = UDim2.new(0.5, 0, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Gotham,
                Text = title,
                TextColor3 = themes.TextColor,
                TextSize = 12,
                TextTransparency = 0.10000000149012,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            utility:Create("ImageLabel", {
                Name = "Button",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -110, 0.5, -8),
                Size = UDim2.new(0, 100, 0, 16),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = themes.LightContrast,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
                utility:Create("TextBox", {
                    Name = "Textbox",
                    BackgroundTransparency = 1,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Position = UDim2.new(0, 5, 0, 0),
                    Size = UDim2.new(1, -10, 1, 0),
                    ZIndex = 3,
                    Font = Enum.Font.GothamSemibold,
                    Text = default or "",
                    TextColor3 = themes.TextColor,
                    TextSize = 11
                })
            })
        })

        table.insert(self.modules, textbox)
        --self:Resize()

        local button = textbox.Button
        local input = button.Textbox

        -- Generate unique key and load saved value (with error handling)
        local textboxKey
        pcall(function()
            if self.page and self.page.library and self.page.library.container and self.page.button then
                textboxKey = self.page.library.container.Name .. "_" .. self.page.button.Name .. "_" .. title
                local savedValue = loadTextboxValue(textboxKey, default)
                if savedValue ~= nil then
                    input.Text = savedValue
                end
            end
        end)

        textbox.MouseButton1Click:Connect(function()

            if textbox.Button.Size ~= UDim2.new(0, 100, 0, 16) then
                return
            end

            utility:Tween(textbox.Button, {
                Size = UDim2.new(0, 200, 0, 16),
                Position = UDim2.new(1, -210, 0.5, -8)
            }, 0.2)

            wait()

            input.TextXAlignment = Enum.TextXAlignment.Left
            input:CaptureFocus()
        end)

        input:GetPropertyChangedSignal("Text"):Connect(function()

            if button.ImageTransparency == 0 and (button.Size == UDim2.new(0, 200, 0, 16) or button.Size == UDim2.new(0, 100, 0, 16)) then -- i know, i dont like this either
                utility:Pop(button, 10)
            end

            if callback then
                callback(input.Text, nil, function(...)
                    self:updateTextbox(textbox, ...)
                end)
            end
        end)

        input.FocusLost:Connect(function()

            input.TextXAlignment = Enum.TextXAlignment.Center

            utility:Tween(textbox.Button, {
                Size = UDim2.new(0, 100, 0, 16),
                Position = UDim2.new(1, -110, 0.5, -8)
            }, 0.2)

            -- Save value when focus is lost
            if textboxKey then
                saveTextboxValue(textboxKey, input.Text)
                debouncedSave()
            end

            if callback then
                callback(input.Text, true, function(...)
                    self:updateTextbox(textbox, ...)
                end)
            end
        end)

        return textbox
    end

    function section:Keybind(title, default, callback, changedCallback)
        local keybind = utility:Create("ImageButton", {
            Name = "Keybind",
            Parent = self.container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = themes.DarkContrast,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
        }, {
            utility:Create("TextLabel", {
                Name = "Title",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0.5, 1),
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Gotham,
                Text = title,
                TextColor3 = themes.TextColor,
                TextSize = 12,
                TextTransparency = 0.10000000149012,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            utility:Create("ImageLabel", {
                Name = "Button",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -110, 0.5, -8),
                Size = UDim2.new(0, 100, 0, 16),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = themes.LightContrast,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
                utility:Create("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 3,
                    Font = Enum.Font.GothamSemibold,
                    Text = default and default.Name or "None",
                    TextColor3 = themes.TextColor,
                    TextSize = 11
                })
            })
        })

        table.insert(self.modules, keybind)
        --self:Resize()

        local text = keybind.Button.Text
        local button = keybind.Button

        local animate = function()
            if button.ImageTransparency == 0 then
                utility:Pop(button, 10)
            end
        end

        self.binds[keybind] = {callback = function()
            animate()

            if callback then
                callback(function(...)
                    self:updateKeybind(keybind, ...)
                end)
            end
        end}

        if default and callback then
            self:updateKeybind(keybind, nil, default)
        end

        keybind.MouseButton1Click:Connect(function()

            animate()

            if self.binds[keybind].connection then -- unbind
                return self:updateKeybind(keybind)
            end

            if text.Text == "None" then -- new bind
                text.Text = "..."

                local key = utility:KeyPressed()

                self:updateKeybind(keybind, nil, key.KeyCode)
                animate()

                if changedCallback then
                    changedCallback(key, function(...)
                        self:updateKeybind(keybind, ...)
                    end)
                end
            end
        end)

        return keybind
    end

    function section:ColorPicker(title, default, callback)
        local colorpicker = utility:Create("ImageButton", {
            Name = "ColorPicker",
            Parent = self.container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = themes.DarkContrast,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
        },{
            utility:Create("TextLabel", {
                Name = "Title",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0.5, 1),
                Size = UDim2.new(0.5, 0, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Gotham,
                Text = title,
                TextColor3 = themes.TextColor,
                TextSize = 12,
                TextTransparency = 0.10000000149012,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            utility:Create("ImageButton", {
                Name = "Button",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -50, 0.5, -7),
                Size = UDim2.new(0, 40, 0, 14),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            })
        })

        -- Generate unique key and load saved value (with error handling)
        local colorKey
        pcall(function()
            if self.page and self.page.library and self.page.library.container and self.page.button then
                colorKey = self.page.library.container.Name .. "_" .. self.page.button.Name .. "_" .. title
                -- Don't load saved value for theme color pickers (Thai titles with "สี")
                -- They use the current theme value as default
                if not (title and title:find("สี")) then
                    local savedValue = loadColorPickerValue(colorKey, nil)
                    if savedValue then
                        default = Color3.fromRGB(savedValue.R, savedValue.G, savedValue.B)
                    end
                end
            end
        end)

        local tab = utility:Create("ImageLabel", {
            Name = "ColorPicker",
            Parent = self.page.library.container,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.75, 0, 0.400000006, 0),
            Selectable = true,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 162, 0, 169),
            Image = "rbxassetid://5028857472",
            ImageColor3 = themes.Background,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298),
            Visible = false,
        }, {
            utility:Create("ImageLabel", {
                Name = "Glow",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, -15, 0, -15),
                Size = UDim2.new(1, 30, 1, 30),
                ZIndex = 0,
                Image = "rbxassetid://5028857084",
                ImageColor3 = themes.Glow,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(22, 22, 278, 278)
            }),
            utility:Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 8),
                Size = UDim2.new(1, -40, 0, 16),
                ZIndex = 2,
                Font = Enum.Font.GothamSemibold,
                Text = title,
                TextColor3 = themes.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            utility:Create("ImageButton", {
                Name = "Close",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -26, 0, 8),
                Size = UDim2.new(0, 16, 0, 16),
                ZIndex = 2,
                Image = "rbxassetid://5012538583",
                ImageColor3 = themes.TextColor
            }),
            utility:Create("Frame", {
                Name = "Container",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, 32),
                Size = UDim2.new(1, -18, 1, -40)
            }, {
                utility:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 6)
                }),
                utility:Create("ImageButton", {
                    Name = "Canvas",
                    BackgroundTransparency = 1,
                    BorderColor3 = themes.LightContrast,
                    Size = UDim2.new(1, 0, 0, 60),
                    AutoButtonColor = false,
                    Image = "rbxassetid://5108535320",
                    ImageColor3 = Color3.fromRGB(255, 0, 0),
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                }, {
                    utility:Create("ImageLabel", {
                        Name = "White_Overlay",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 60),
                        Image = "rbxassetid://5107152351",
                        SliceCenter = Rect.new(2, 2, 298, 298)
                    }),
                    utility:Create("ImageLabel", {
                        Name = "Black_Overlay",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 60),
                        Image = "rbxassetid://5107152095",
                        SliceCenter = Rect.new(2, 2, 298, 298)
                    }),
                    utility:Create("ImageLabel", {
                        Name = "Cursor",
                        BackgroundColor3 = themes.TextColor,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1.000,
                        Size = UDim2.new(0, 10, 0, 10),
                        Position = UDim2.new(0, 0, 0, 0),
                        Image = "rbxassetid://5100115962",
                        SliceCenter = Rect.new(2, 2, 298, 298)
                    })
                }),
                utility:Create("ImageButton", {
                    Name = "Color",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 4),
                    Selectable = false,
                    Size = UDim2.new(1, 0, 0, 16),
                    ZIndex = 2,
                    AutoButtonColor = false,
                    Image = "rbxassetid://5028857472",
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                }, {
                    utility:Create("Frame", {
                        Name = "Select",
                        BackgroundColor3 = themes.TextColor,
                        BorderSizePixel = 1,
                        Position = UDim2.new(1, 0, 0, 0),
                        Size = UDim2.new(0, 2, 1, 0),
                        ZIndex = 2
                    }),
                    utility:Create("UIGradient", { -- rainbow canvas
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
                            ColorSequenceKeypoint.new(0.82, Color3.fromRGB(255, 0, 255)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
                        })
                    })
                }),
                utility:Create("Frame", {
                    Name = "Inputs",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 158),
                    Size = UDim2.new(1, 0, 0, 16)
                }, {
                    utility:Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 6)
                    }),
                    utility:Create("ImageLabel", {
                        Name = "R",
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0.305, 0, 1, 0),
                        ZIndex = 2,
                        Image = "rbxassetid://5028857472",
                        ImageColor3 = themes.DarkContrast,
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(2, 2, 298, 298)
                    }, {
                        utility:Create("TextLabel", {
                            Name = "Text",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0.400000006, 0, 1, 0),
                            ZIndex = 2,
                            Font = Enum.Font.Gotham,
                            Text = "R:",
                            TextColor3 = themes.TextColor,
                            TextSize = 10.000
                        }),
                        utility:Create("TextBox", {
                            Name = "Textbox",
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0.300000012, 0, 0, 0),
                            Size = UDim2.new(0.600000024, 0, 1, 0),
                            ZIndex = 2,
                            Font = Enum.Font.Gotham,
                            PlaceholderColor3 = themes.DarkContrast,
                            Text = "255",
                            TextColor3 = themes.TextColor,
                            TextSize = 10.000
                        })
                    }),
                    utility:Create("ImageLabel", {
                        Name = "G",
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0.305, 0, 1, 0),
                        ZIndex = 2,
                        Image = "rbxassetid://5028857472",
                        ImageColor3 = themes.DarkContrast,
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(2, 2, 298, 298)
                    }, {
                        utility:Create("TextLabel", {
                            Name = "Text",
                            BackgroundTransparency = 1,
                            ZIndex = 2,
                            Size = UDim2.new(0.400000006, 0, 1, 0),
                            Font = Enum.Font.Gotham,
                            Text = "G:",
                            TextColor3 = themes.TextColor,
                            TextSize = 10.000
                        }),
                        utility:Create("TextBox", {
                            Name = "Textbox",
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0.300000012, 0, 0, 0),
                            Size = UDim2.new(0.600000024, 0, 1, 0),
                            ZIndex = 2,
                            Font = Enum.Font.Gotham,
                            Text = "255",
                            TextColor3 = themes.TextColor,
                            TextSize = 10.000
                        })
                    }),
                    utility:Create("ImageLabel", {
                        Name = "B",
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0.305, 0, 1, 0),
                        ZIndex = 2,
                        Image = "rbxassetid://5028857472",
                        ImageColor3 = themes.DarkContrast,
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(2, 2, 298, 298)
                    }, {
                        utility:Create("TextLabel", {
                            Name = "Text",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0.400000006, 0, 1, 0),
                            ZIndex = 2,
                            Font = Enum.Font.Gotham,
                            Text = "B:",
                            TextColor3 = themes.TextColor,
                            TextSize = 10.000
                        }),
                        utility:Create("TextBox", {
                            Name = "Textbox",
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0.300000012, 0, 0, 0),
                            Size = UDim2.new(0.600000024, 0, 1, 0),
                            ZIndex = 2,
                            Font = Enum.Font.Gotham,
                            Text = "255",
                            TextColor3 = themes.TextColor,
                            TextSize = 10.000
                        })
                    }),
                }),
                utility:Create("ImageButton", {
                    Name = "Button",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 20),
                    ZIndex = 2,
                    Image = "rbxassetid://5028857472",
                    ImageColor3 = themes.DarkContrast,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                }, {
                    utility:Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        ZIndex = 3,
                        Font = Enum.Font.Gotham,
                        Text = "Submit",
                        TextColor3 = themes.TextColor,
                        TextSize = 11.000
                    })
                })
            })
        })

        utility:DraggingEnabled(tab)
        table.insert(self.modules, colorpicker)
        --self:Resize()

        -- Update button color with saved value after tab is created
        -- Skip for theme color pickers (Thai titles with "สี") since they use themes table
        if colorKey and savedSettings.colorpickers and savedSettings.colorpickers[colorKey] and not (title and title:find("สี")) then
            local savedValue = savedSettings.colorpickers[colorKey]
            local color3 = Color3.fromRGB(savedValue.R, savedValue.G, savedValue.B)
            colorpicker.Button.ImageColor3 = color3
        end

        local allowed = {
            [""] = true
        }

        local canvas = tab.Container.Canvas
        local color = tab.Container.Color

        local canvasSize, canvasPosition = canvas.AbsoluteSize, canvas.AbsolutePosition
        local colorSize, colorPosition = color.AbsoluteSize, color.AbsolutePosition

        local draggingColor, draggingCanvas

        local color3 = default or Color3.fromRGB(255, 255, 255)
        local hue, sat, brightness = 0, 0, 1
        local rgb = {
            r = 255,
            g = 255,
            b = 255
        }

        self.colorpickers[colorpicker] = {
            tab = tab,
            callback = function(prop, value)
                rgb[prop] = value
                hue, sat, brightness = Color3.toHSV(Color3.fromRGB(rgb.r, rgb.g, rgb.b))
            end
        }

        local onColorChange = function(value)
            if callback then
                callback(value, function(...)
                    self:updateColorPicker(colorpicker, ...)
                end)
            end
        end

        utility:DraggingEnded(function()
            draggingColor, draggingCanvas = false, false
        end)

        if default then
            self:updateColorPicker(colorpicker, nil, default)

            hue, sat, brightness = Color3.toHSV(default)
            default = Color3.fromHSV(hue, sat, brightness)

            for i, prop in pairs({"r", "g", "b"}) do
                rgb[prop] = default[prop:upper()] * 255
            end
        end

        for i, container in pairs(tab.Container.Inputs:GetChildren()) do -- i know what you are about to say, so shut up
            if container:IsA("ImageLabel") then
                local textbox = container.Textbox
                local focused

                textbox.Focused:Connect(function()
                    focused = true
                end)

                textbox.FocusLost:Connect(function()
                    focused = false

                    if not tonumber(textbox.Text) then
                        textbox.Text = math.floor(rgb[container.Name:lower()])
                    end
                end)

                textbox:GetPropertyChangedSignal("Text"):Connect(function()
                    local text = textbox.Text

                    if not allowed[text] and not tonumber(text) then
                        textbox.Text = text:sub(1, #text - 1)
                    elseif focused and not allowed[text] then
                        rgb[container.Name:lower()] = math.clamp(tonumber(textbox.Text), 0, 255)

                        local color3 = Color3.fromRGB(rgb.r, rgb.g, rgb.b)
                        hue, sat, brightness = Color3.toHSV(color3)

                        self:updateColorPicker(colorpicker, nil, color3)
                    end
                end)
            end
        end

        canvas.MouseButton1Down:Connect(function()
            draggingCanvas = true

            while draggingCanvas and input:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do

                local x, y = mouse.X, mouse.Y

                sat = math.clamp((x - canvasPosition.X) / canvasSize.X, 0, 1)
                brightness = 1 - math.clamp((y - canvasPosition.Y) / canvasSize.Y, 0, 1)

                color3 = Color3.fromHSV(hue, sat, brightness)

                for i, prop in pairs({"r", "g", "b"}) do
                    rgb[prop] = color3[prop:upper()] * 255
                end

                self:updateColorPicker(colorpicker, nil, {hue, sat, brightness}) -- roblox is literally retarded
                utility:Tween(canvas.Cursor, {Position = UDim2.new(sat, 0, 1 - brightness, 0)}, 0.1) -- overwrite

                utility:Wait()
            end
            draggingCanvas = false
        end)

        color.MouseButton1Down:Connect(function()
            draggingColor = true

            while draggingColor and input:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do

                hue = 1 - math.clamp(1 - ((mouse.X - colorPosition.X) / colorSize.X), 0, 1)
                color3 = Color3.fromHSV(hue, sat, brightness)

                for i, prop in pairs({"r", "g", "b"}) do
                    rgb[prop] = color3[prop:upper()] * 255
                end

                local x = hue -- hue is updated
                self:updateColorPicker(colorpicker, nil, {hue, sat, brightness}) -- roblox is literally retarded
                utility:Tween(tab.Container.Color.Select, {Position = UDim2.new(x, 0, 0, 0)}, 0.1) -- overwrite

                utility:Wait()
            end
            draggingColor = false
        end)

        -- click events
        local button = colorpicker.Button
        local toggle, debounce, animate

        lastColor = Color3.fromHSV(hue, sat, brightness)
        animate = function(visible, overwrite)

            if overwrite then

                if not toggle then
                    return
                end

                if debounce then
                    while debounce do
                        utility:Wait()
                    end
                end
            elseif not overwrite then
                if debounce then
                    return
                end

                if button.ImageTransparency == 0 then
                    utility:Pop(button, 10)
                end
            end

            toggle = visible
            debounce = true

            if visible then

                if self.page.library.activePicker and self.page.library.activePicker ~= animate then
                    self.page.library.activePicker(nil, true)
                end

                self.page.library.activePicker = animate
                lastColor = Color3.fromHSV(hue, sat, brightness)

                local x1, x2 = button.AbsoluteSize.X / 2, 162--tab.AbsoluteSize.X
                local px, py = button.AbsolutePosition.X, button.AbsolutePosition.Y

                tab.ClipsDescendants = true
                tab.Visible = true
                tab.Size = UDim2.new(0, 0, 0, 0)

                tab.Position = UDim2.new(0, x1 + x2 + px, 0, py)
                utility:Tween(tab, {Size = UDim2.new(0, 162, 0, 169)}, 0.2)

                -- update size and position
                wait(0.2)
                tab.ClipsDescendants = false

                canvasSize, canvasPosition = canvas.AbsoluteSize, canvas.AbsolutePosition
                colorSize, colorPosition = color.AbsoluteSize, color.AbsolutePosition
            else
                utility:Tween(tab, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
                tab.ClipsDescendants = true

                wait(0.2)
                tab.Visible = false
            end

            debounce = false
        end

        local toggleTab = function()
            animate(not toggle)
        end

        button.MouseButton1Click:Connect(toggleTab)
        colorpicker.MouseButton1Click:Connect(toggleTab)

        tab.Container.Button.MouseButton1Click:Connect(function()
            onColorChange(color3)
            -- Only save to colorpickers if this is NOT a theme color picker
            -- Theme colors (Thai titles with "สี") are already saved in savedSettings.themes via win:setTheme()
            if colorKey and not (title and title:find("สี")) then
                saveColorPickerValue(colorKey, color3)
                debouncedSave()
            end
            animate()
        end)

        tab.Close.MouseButton1Click:Connect(function()
            self:updateColorPicker(colorpicker, nil, lastColor)
            animate()
        end)

        -- Click outside to cancel
        input.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and toggle then
                local mousePos = input.Position
                local tabPos = tab.AbsolutePosition
                local tabSize = tab.AbsoluteSize
                
                if mousePos.X < tabPos.X or mousePos.X > tabPos.X + tabSize.X or
                   mousePos.Y < tabPos.Y or mousePos.Y > tabPos.Y + tabSize.Y then
                    self:updateColorPicker(colorpicker, nil, lastColor)
                    animate()
                end
            end
        end)

        return colorpicker
    end

    function section:Slider(title, min, default, max, callback)
        local sel = self 
        local slider = utility:Create("ImageButton", {
            Name = "Slider",
            Parent = self.container,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0.292817682, 0, 0.299145311, 0),
            Size = UDim2.new(1, 0, 0, 50),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = themes.DarkContrast,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
        }, {
            utility:Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 6),
                Size = UDim2.new(0.5, 0, 0, 16),
                ZIndex = 3,
                Font = Enum.Font.Gotham,
                Text = title,
                TextColor3 = themes.TextColor,
                TextSize = 12,
                TextTransparency = 0.10000000149012,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            utility:Create("TextBox", {
                Name = "TextBox",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -30, 0, 6),
                Size = UDim2.new(0, 20, 0, 16),
                ZIndex = 3,
                Font = Enum.Font.GothamSemibold,
                Text = default or min,
                TextColor3 = themes.TextColor,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right
            }),
            utility:Create("TextLabel", {
                Name = "Slider",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 28),
                Size = UDim2.new(1, -20, 0, 16),
                ZIndex = 3,
                Text = "",
            }, {
                utility:Create("ImageLabel", {
                    Name = "Bar",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.new(1, 0, 0, 4),
                    ZIndex = 3,
                    Image = "rbxassetid://5028857472",
                    ImageColor3 = themes.LightContrast,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                }, {
                    utility:Create("ImageLabel", {
                        Name = "Fill",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.8, 0, 1, 0),
                        ZIndex = 3,
                        Image = "rbxassetid://5028857472",
                        ImageColor3 = themes.SliderColor,
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(2, 2, 298, 298)
                    }, {
                        utility:Create("ImageLabel", {
                            Name = "Circle",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            BackgroundTransparency = 1,
                            ImageTransparency = 1.000,
                            ImageColor3 = themes.SliderColor,
                            Position = UDim2.new(1, 0, 0.5, 0),
                            Size = UDim2.new(0, 10, 0, 10),
                            ZIndex = 3,
                            Image = "rbxassetid://4608020054"
                        })
                    })
                })
            })
        })

        table.insert(self.modules, slider)
        --self:Resize()

        local allowed = {
            [""] = true,
            ["-"] = true
        }

        local textbox = slider.TextBox
        local circle = slider.Slider.Bar.Fill.Circle

        -- Generate unique key and load saved value (with error handling)
        local sliderKey
        local value = default or min
        pcall(function()
            if self.page and self.page.library and self.page.library.container and self.page.button then
                sliderKey = self.page.library.container.Name .. "_" .. self.page.button.Name .. "_" .. title
                local savedValue = loadSliderValue(sliderKey, default)
                if savedValue ~= nil then
                    value = savedValue
                end
            end
        end)
        
        local dragging, last

        local onSliderChange = function(value)
            if callback then
                callback(value, function(...)
                    self:updateSlider(slider, ...)
                end)
            end
        end

        self:updateSlider(slider, nil, value, min, max)

        utility:DraggingEnded(function()
            dragging = false
            if sliderKey then
                saveSliderValue(sliderKey, value)
                debouncedSave()
            end
        end)

        slider.MouseButton1Down:Connect(function(input)
            dragging = true

            while dragging do
                utility:Tween(circle, {ImageTransparency = 0}, 0.1)

                value = self:updateSlider(slider, nil, nil, min, max, value)
                onSliderChange(value)

                utility:Wait()
            end

            wait(0.5)
            utility:Tween(circle, {ImageTransparency = 1}, 0.2)
            if sliderKey then
                saveSliderValue(sliderKey, value)
                debouncedSave()
            end
        end)

        textbox.FocusLost:Connect(function()
            if not tonumber(textbox.Text) then
                value = self:updateSlider(slider, nil, default or min, min, max)
                onSliderChange(value)
            end
            if sliderKey then
                saveSliderValue(sliderKey, value)
                debouncedSave()
            end
        end)

        textbox:GetPropertyChangedSignal("Text"):Connect(function()
            local text = textbox.Text

            if not allowed[text] and not tonumber(text) then
                textbox.Text = text:sub(1, #text - 1)
            elseif not allowed[text] then
                value = self:updateSlider(slider, nil, tonumber(text) or value, min, max)
                onSliderChange(value)
                if sliderKey then
                    saveSliderValue(sliderKey, value)
                    debouncedSave()
                end
            end
        end)

        local sliderfunc = {}
        function sliderfunc:Set(newva)
            local text = tonumber(newva)

            if not allowed[text] and not tonumber(text) then
                textbox.Text = text:sub(1, #text - 1)
            elseif not allowed[text] then
                value = sel:updateSlider(slider, nil, tonumber(text) or value, min, max)
                onSliderChange(value)
                if sliderKey then
                    saveSliderValue(sliderKey, value)
                    debouncedSave()
                end
            end
        end 

        return sliderfunc,slider
    end

    function section:Dropdown(title, list, callback)
        local dropdown = utility:Create("Frame", {
            Name = "Dropdown",
            Parent = self.container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            ClipsDescendants = true
        }, {
            
        
    
            utility:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            }),
            utility:Create("ImageLabel", {
                Name = "Search",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = themes.DarkContrast,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
            
                utility:Create("TextBox", {
                    Name = "TextBox",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Position = UDim2.new(0, 10, 0.5, 1),
                    Size = UDim2.new(1, -42, 1, 0),
                    ZIndex = 3,
                    Font = Enum.Font.Gotham,
                    Text = title,
                    TextColor3 = themes.TextColor,
                    TextSize = 12,
                    TextTransparency = 0.10000000149012,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                utility:Create("ImageButton", {
                    Name = "Button",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -28, 0.5, -9),
                    Size = UDim2.new(0, 18, 0, 18),
                    ZIndex = 3,
                    Image = "rbxassetid://5012539403",
                    ImageColor3 = themes.TextColor,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                })
            }),
            utility:Create("ImageLabel", {
                Name = "List",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, -34),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = themes.Background,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
                
                utility:Create("ScrollingFrame", {
                    Name = "Frame",
                    Active = true,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 4, 0, 4),
                    Size = UDim2.new(1, -8, 1, -8),
                    CanvasPosition = Vector2.new(0, 28),
                    CanvasSize = UDim2.new(0, 0, 0, 120),
                    ZIndex = 2,
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = themes.DarkContrast
                }, {
                    utility:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 4)
                    })
                })
            })
        })

        table.insert(self.modules, dropdown)
        --self:Resize()

        local search = dropdown.Search
        local focused

        -- Generate unique key and load saved value (with error handling)
        local dropdownKey
        pcall(function()
            if self.page and self.page.library and self.page.library.container and self.page.button then
                dropdownKey = self.page.library.container.Name .. "_" .. self.page.button.Name .. "_" .. title
                local savedValue = loadDropdownValue(dropdownKey, nil)
                if savedValue then
                    search.TextBox.Text = savedValue
                end
            end
        end)
        
        list = list or {}

        search.Button.MouseButton1Click:Connect(function()
            if search.Button.Rotation == 0 then
                self:updateDropdown(dropdown, nil, list, callback)
            else
                self:updateDropdown(dropdown, nil, nil, callback)
            end
        end)

        search.TextBox.Focused:Connect(function()
            if search.Button.Rotation == 0 then
                self:updateDropdown(dropdown, nil, list, callback)
            end

            focused = true
        end)

        search.TextBox.FocusLost:Connect(function()
            focused = false
            wait(0.2)
            if search.TextBox.Text == ""  then
                search.TextBox.Text = title
                self:updateDropdown(dropdown, nil, nil, callback)
            else
                -- Save the selected value
                if dropdownKey then
                    saveDropdownValue(dropdownKey, search.TextBox.Text)
                    debouncedSave()
                end
            end
        end)

        search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
            if focused then
                local list = utility:Sort(search.TextBox.Text, list)
                list = #list ~= 0 and list

                self:updateDropdown(dropdown, nil, list, callback)
            end

        end)

        dropdown:GetPropertyChangedSignal("Size"):Connect(function()
            self:Resize()
        end)

        return dropdown
    end

    -- class functions

    function library:SelectPage(page, toggle)

        if toggle and self.focusedPage == page then -- already selected
            return
        end

        local button = page.button
        
        -- Save selected page name
        if toggle and page.button then
            savedSettings.selectedPage = page.button.Name
            saveSettings()
        end

        if toggle then
            -- page button
            button.Title.TextTransparency = 0
            button.Title.Font = Enum.Font.GothamSemibold

            if button:FindFirstChild("Icon") then
                button.Icon.ImageTransparency = 0
            end

            -- update selected page
            local focusedPage = self.focusedPage
            self.focusedPage = page

            if focusedPage then
                self:SelectPage(focusedPage)
            end

            -- sections
            local existingSections = focusedPage and #focusedPage.sections or 0
            local sectionsRequired = #page.sections - existingSections

            page:Resize()

            for i, section in pairs(page.sections) do
                section.container.Parent.ImageTransparency = 0
            end

            if sectionsRequired < 0 then -- "hides" some sections
                for i = existingSections, #page.sections + 1, -1 do
                    local section = focusedPage.sections[i].container.Parent

                    utility:Tween(section, {ImageTransparency = 1}, 0.1)
                end
            end

            wait(0.1)
            page.container.Visible = true

            if focusedPage then
                focusedPage.container.Visible = false
            end

            if sectionsRequired > 0 then -- "creates" more section
                for i = existingSections + 1, #page.sections do
                    local section = page.sections[i].container.Parent

                    section.ImageTransparency = 1
                    utility:Tween(section, {ImageTransparency = 0}, 0.05)
                end
            end

            wait(0.05)

            for i, section in pairs(page.sections) do

                utility:Tween(section.container.Title, {TextTransparency = 0}, 0.1)
                section:Resize(true)

                wait(0.05)
            end

            wait(0.05)
            page:Resize(true)
        else
            -- page button
            button.Title.Font = Enum.Font.Gotham
            button.Title.TextTransparency = 0.65

            if button:FindFirstChild("Icon") then
                button.Icon.ImageTransparency = 0.65
            end

            -- sections
            for i, section in pairs(page.sections) do
                utility:Tween(section.container.Parent, {Size = UDim2.new(1, -10, 0, 28)}, 0.1)
                utility:Tween(section.container.Title, {TextTransparency = 1}, 0.1)
            end

            wait(0.1)

            page.lastPosition = page.container.CanvasPosition.Y
            page:Resize()
        end
    end

    function page:Resize(scroll)
        local padding = 10
        local size = 0

        for i, section in pairs(self.sections) do
            size = size + section.container.Parent.AbsoluteSize.Y + padding
        end

        self.container.CanvasSize = UDim2.new(0, 0, 0, size)
        self.container.ScrollBarImageTransparency = size > self.container.AbsoluteSize.Y

        if scroll then
            utility:Tween(self.container, {CanvasPosition = Vector2.new(0, self.lastPosition or 0)}, 0.2)
        end
    end

    function section:Resize(smooth)

        if self.page.library.focusedPage ~= self.page then
            return
        end

        local padding = 4
        local size = (4 * padding) + self.container.Title.AbsoluteSize.Y -- offset

        for i, module in pairs(self.modules) do
            if module and module.Parent then
                size = size + module.AbsoluteSize.Y + padding
            end
        end

        -- Ensure minimum size
        size = math.max(size, 28)

        if smooth then
            utility:Tween(self.container.Parent, {Size = UDim2.new(1, -10, 0, size)}, 0.05)
        else
            self.container.Parent.Size = UDim2.new(1, -10, 0, size)
            self.page:Resize()
        end
    end

    function section:getModule(info)

        if table.find(self.modules, info) then
            return info
        end

        for i, module in pairs(self.modules) do
            if (module:FindFirstChild("Title") or module:FindFirstChild("TextBox", true)).Text == info then
                return module
            end
        end

        error("No module found under "..tostring(info))
    end

    -- updates

    function section:updateButton(button, title)
        button = self:getModule(button)

        button.Title.Text = title
    end

    function section:updateToggle(toggle, title, value)
        spawn(function()
            toggle = self:getModule(toggle)

            local position = {
                In = UDim2.new(0, 2, 0.5, -6),
                Out = UDim2.new(0, 20, 0.5, -6)
            }
            local color = {
                In = themes.NotToggledColor,
                Out = themes.ToggledColor
            }

            local frame = toggle.Button.Frame
            local btn = toggle.Button
            value = value and "Out" or "In"

            if title then
                toggle.Title.Text = title
            end

            utility:Tween(frame, {
                Size = UDim2.new(1, -22, 1, -9),
                Position = position[value] + UDim2.new(0, 0, 0, 2.5)
            }, 0.2)

            utility:Tween(btn, {
                ImageColor3 = color[value]
            }, 0.2)

            wait(0.1)
            utility:Tween(frame, {
                Size = UDim2.new(1, -22, 1, -4),
                Position = position[value]
            }, 0.1)
        end)
    end

    function section:updateTextbox(textbox, title, value)
        textbox = self:getModule(textbox)

        if title then
            textbox.Title.Text = title
        end

        if value then
            textbox.Button.Textbox.Text = value
        end

    end

    function section:updateKeybind(keybind, title, key)
        keybind = self:getModule(keybind)

        local text = keybind.Button.Text
        local bind = self.binds[keybind]

        if title then
            keybind.Title.Text = title
        end

        if bind.connection then
            bind.connection = bind.connection:UnBind()
        end

        if key then
            self.binds[keybind].connection = utility:BindToKey(key, bind.callback)
            text.Text = key.Name
        else
            text.Text = "None"
        end
    end

    function section:updateColorPicker(colorpicker, title, color)
        colorpicker = self:getModule(colorpicker)

        local picker = self.colorpickers[colorpicker]
        local tab = picker.tab
        local callback = picker.callback

        if title then
            colorpicker.Title.Text = title
            tab.Title.Text = title
        end

        local color3
        local hue, sat, brightness

        if type(color) == "table" then -- roblox is literally retarded x2
            hue, sat, brightness = unpack(color)
            color3 = Color3.fromHSV(hue, sat, brightness)
        else
            color3 = color
            hue, sat, brightness = Color3.toHSV(color3)
        end

        utility:Tween(colorpicker.Button, {ImageColor3 = color3}, 0.5)
        utility:Tween(tab.Container.Color.Select, {Position = UDim2.new(hue, 0, 0, 0)}, 0.1)

        utility:Tween(tab.Container.Canvas, {ImageColor3 = Color3.fromHSV(hue, 1, 1)}, 0.5)
        utility:Tween(tab.Container.Canvas.Cursor, {Position = UDim2.new(sat, 0, 1 - brightness)}, 0.5)

        for i, container in pairs(tab.Container.Inputs:GetChildren()) do
            if container:IsA("ImageLabel") then
                local value = math.clamp(color3[container.Name], 0, 1) * 255

                container.Textbox.Text = math.floor(value)
                --callback(container.Name:lower(), value)
            end
        end
    end

    function section:updateSlider(slider, title, value, min, max, lvalue)
        slider = self:getModule(slider)

        if title then
            slider.Title.Text = title
        end

        local bar = slider.Slider.Bar
        local percent = (mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X

        if value then -- support negative ranges
            percent = (value - min) / (max - min)
        end

        percent = math.clamp(percent, 0, 1)
        value = value or math.floor(min + (max - min) * percent)

        slider.TextBox.Text = value
        utility:Tween(bar.Fill, {
            Size = UDim2.new(percent, 0, 1, 0),
            ImageColor3 = themes.Slider
        }, 0.1)

        if value ~= lvalue and slider.ImageTransparency == 0 then
            utility:Pop(slider, 10)
        end

        return value
    end
    function section:clearDropdown(dropdown)
        dropdown = self:getModule(dropdown)

        if title then
            dropdown.Search.TextBox.Text = title
        end

    
        for i, button in pairs(dropdown.List.Frame:GetChildren()) do
            if button:IsA("ImageButton") then
                button:Destroy()
            end
        end

    end 
    function section:updateDropdown(dropdown, title, list, callback)
        spawn(function()
            dropdown = self:getModule(dropdown)

            if title then
                dropdown.Search.TextBox.Text = title
            end

            local entries = 0

            utility:Pop(dropdown.Search, 10)



            for i, value in pairs(list or {}) do
                local button = utility:Create("ImageButton", {
                    Parent = dropdown.List.Frame,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    ZIndex = 2,
                    Image = "rbxassetid://5028857472",
                    ImageColor3 = themes.DarkContrast,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                }, {
                    utility:Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -10, 1, 0),
                        ZIndex = 3,
                        Font = Enum.Font.Gotham,
                        Text = value,
                        TextColor3 = themes.TextColor,
                        TextSize = 12,
                        TextXAlignment = "Left",
                        TextTransparency = 0.10000000149012
                    })
                })

                button.MouseButton1Click:Connect(function()
                    if callback then
                        callback(value, function(...)
                            self:updateDropdown(dropdown, ...)
                        end)
                    end

                    self:updateDropdown(dropdown, value, nil, callback)
                end)

                entries = entries + 1
            end

            local frame = dropdown.List.Frame

            utility:Tween(dropdown, {Size = UDim2.new(1, 0, 0, (entries == 0 and 30) or math.clamp(entries, 0, 3) * 34 + 38)}, 0.3)
            utility:Tween(dropdown.Search.Button, {Rotation = list and 180 or 0}, 0.3)

            if entries > 3 then

                for i, button in pairs(dropdown.List.Frame:GetChildren()) do
                    if button:IsA("ImageButton") then
                        button.Size = UDim2.new(1, -6, 0, 30)
                    end
                end

                frame.CanvasSize = UDim2.new(0, 0, 0, (entries * 34) - 4)
                frame.ScrollBarImageTransparency = 0
            else
                frame.CanvasSize = UDim2.new(0, 0, 0, 0)
                frame.ScrollBarImageTransparency = 1
            end
        end)

    end
end

local win = library.new("Xsoul Hud")

local page1 = win:NewPage("เมนูหลัก")
local section1 = page1:NewSecction("Test1")
local section2 = page1:NewSecction("Test2")

section1:Toggle("Toggle", false, function(t)
    print(t)
end)

section1:Button("Button", function(t)
    print("asd")
end)

section1:Textbox("Notification", "Default", function(value, kuy)
    print("Input", value)

if focusLost then
    win:Notify("Test1", "Hello", value)
    end
end)
section2:ColorPicker("ColorPicker", Color3.fromRGB(50, 50, 50))

section2:ColorPicker("ColorPicker2")

section2:Slider("Slider", 0, -100, 100, function(value)
    print("Dragged", value)
end)

section2:Dropdown("Dropdown", {"Hello", "World", "Hello World", "Word", 1, 2, 3})

section2:Dropdown("Dropdown", {"Hello", "World", "Hello World", "Word", 1, 2, 3}, function(text)
   print("Selected", text)
end)

-- Auto-select first page to show content (or saved page if available)
local initialPage = page1
if savedSettings.selectedPage then
    for _, page in pairs(win.pages) do
        if page.button and page.button.Name == savedSettings.selectedPage then
            initialPage = page
            break
        end
    end
end
win:SelectPage(initialPage, false)

-- Ensure sections are properly expanded after page selection
wait(0.1)
for _, section in pairs(page1.sections) do
    section:Resize(true)
end

local page3 = win:NewPage("ผู้เล่น")
local player1 = page3:NewSecction("ความไวการเดิน")

player1:Textbox("ความไว", "16", function(value)
    print("Sensitivity:", value)
end)

player1:Toggle("เดินเร็ว", false, function(t)
    print("Speed toggle:", t)
end)

local player2 = page3:NewSecction("กระโดด")

player2:Textbox("ความสูง", "50", function(value)
    print("Jump height:", value)
end)

player2:Toggle("กระโดดสูง", false, function(t)
    print("High jump toggle:", t)
end)

player2:Toggle("กระโดดหลายครั้ง", false, function(t)
    print("Multi jump toggle:", t)
end)

local page2 = win:NewPage("ตั้งค่า")
local setting1 = page2:NewSecction("สีของหน้าต่าง")

setting1:ColorPicker("สีสวิตช์ปิด", themes.NotToggledColor, function(color)
    win:setTheme("NotToggledColor", color)
    saveSettings()
end)

setting1:ColorPicker("สีสวิตช์เปิด", themes.ToggledColor, function(color)
    win:setTheme("ToggledColor", color)
    saveSettings()
end)

setting1:ColorPicker("สีพื้นหลัง", themes.Background, function(color)
    win:setTheme("Background", color)
    saveSettings()
end)

setting1:ColorPicker("สีแถบบน", themes.TopBarColor, function(color)
    win:setTheme("TopBarColor", color)
    saveSettings()
end)

setting1:ColorPicker("สีตัวหนังสือ", themes.TextColor, function(color)
    win:setTheme("TextColor", color)
    saveSettings()
end)

-- Update theme color picker buttons to display loaded theme colors
-- This ensures they show the correct colors after system restart
spawn(function()
    wait(0.5) -- Wait for color pickers to be fully created
    local themeMap = {
        ["สีสวิตช์ปิด"] = "NotToggledColor",
        ["สีสวิตช์เปิด"] = "ToggledColor",
        ["สีพื้นหลัง"] = "Background",
        ["สีแถบบน"] = "TopBarColor",
        ["สีตัวหนังสือ"] = "TextColor"
    }

    -- Use setting1's colorpickers table to update each color picker
    for colorpicker, pickerData in pairs(setting1.colorpickers) do
        if colorpicker and colorpicker:FindFirstChild("Button") and colorpicker:FindFirstChild("Title") then
            local titleText = colorpicker.Title.Text
            local themeName = themeMap[titleText]
            if themeName and themes[themeName] then
                -- Use the section's updateColorPicker function to properly update all properties
                setting1:updateColorPicker(colorpicker, nil, themes[themeName])
            end
        end
    end
end)

local setting2 = page2:NewSecction("ฟอนต์ & ขนาด และภาษา")

setting2:Textbox("ขนาดตัวหนังสือ", tostring(savedSettings.fontSize or 14), function(size)
    local textSize = tonumber(size)
    if textSize and textSize >= 10 and textSize <= 24 then
        for _, child in pairs(win.container.Main:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                -- Skip top bar buttons (Toggle, Maximize, Close) and their text
                if child.Name ~= "Title" or child.Parent.Name ~= "TopBar" then
                    if child.Name ~= "ToggleButton" and child.Name ~= "MaximizeButton" and child.Name ~= "CloseButton" then
                        if child.TextSize >= 10 and child.TextSize <= 24 then
                            child.TextSize = textSize
                        end
                    end
                end
            end
        end
        savedSettings.fontSize = textSize
        saveSettings()
    end
end)

setting2:Dropdown("เปลี่ยนฟอนต์", {"Gotham", "GothamBold", "GothamSemibold", "Arial", "ArialBold", "SourceSans", "SourceSansBold", "SourceSansLight", "SourceSansItalic", "Ubuntu", "UbuntuBold", "Code", "Legacy", "Fantasy", "Cartoon"}, function(font)
    local fontEnum = Enum.Font[font]
    for _, child in pairs(win.container.Main:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            if child.Name ~= "Title" or child.Parent.Name ~= "TopBar" then
                child.Font = fontEnum
            end
        end
    end
    savedSettings.font = font
    saveSettings()
end)

local translations = {
    Thai = {
        ["เมนูหลัก"] = "เมนูหลัก",
        ["Test1"] = "Test1",
        ["Test2"] = "Test2",
        ["Toggle"] = "Toggle",
        ["Notification"] = "การแจ้งเตือน",
        ["Default"] = "ค่าเริ่มต้น",
        ["ColorPicker"] = "เลือกสี",
        ["ColorPicker2"] = "เลือกสี2",
        ["Slider"] = "สไลเดอร์",
        ["Dropdown"] = "รายการแบบเลือก",
        ["Hello"] = "สวัสดี",
        ["World"] = "โลก",
        ["Hello World"] = "สวัสดีโลก",
        ["Word"] = "คำ",
        ["ผู้เล่น"] = "ผู้เล่น",
        ["ความไวการเดิน"] = "ความไวการเดิน",
        ["ความไว"] = "ความไว",
        ["เดินเร็ว"] = "เดินเร็ว",
        ["ความเร็ว"] = "ความเร็ว",
        ["กระโดด"] = "กระโดด",
        ["ความสูง"] = "ความสูง",
        ["กระโดดสูง"] = "กระโดดสูง",
        ["กระโดดหลายครั้ง"] = "กระโดดหลายครั้ง",
        ["ตั้งค่า"] = "ตั้งค่า",
        ["สีของหน้าต่าง"] = "สีของหน้าต่าง",
        ["สีสวิตช์ปิด"] = "สีสวิตช์ปิด",
        ["สีสวิตช์เปิด"] = "สีสวิตช์เปิด",
        ["สีพื้นหลัง"] = "สีพื้นหลัง",
        ["สีแถบบน"] = "สีแถบบน",
        ["สีสไลเดอร์"] = "สีสไลเดอร์",
        ["สีตัวหนังสือ"] = "สีตัวหนังสือ",
        ["ฟอนต์ & ขนาด และภาษา"] = "ฟอนต์ & ขนาด และภาษา",
        ["ขนาดตัวหนังสือ"] = "ขนาดตัวหนังสือ",
        ["Change Font"] = "เปลี่ยนฟอนต์",
        ["Change Language"] = "เปลี่ยนภาษา",
        ["Main Menu"] = "เมนูหลัก",
        ["Player"] = "ผู้เล่น",
        ["Walk Sensitivity"] = "ความไวการเดิน",
        ["Sensitivity"] = "ความไว",
        ["Walk Fast"] = "เดินเร็ว",
        ["Speed"] = "ความเร็ว",
        ["Jump"] = "กระโดด",
        ["Height"] = "ความสูง",
        ["High Jump"] = "กระโดดสูง",
        ["Multi Jump"] = "กระโดดหลายครั้ง",
        ["Settings"] = "ตั้งค่า",
        ["Window Colors"] = "สีของหน้าต่าง",
        ["Switch Off Color"] = "สีสวิตช์ปิด",
        ["Switch On Color"] = "สีสวิตช์เปิด",
        ["Background Color"] = "สีพื้นหลัง",
        ["Top Bar Color"] = "สีแถบบน",
        ["Slider Color"] = "สีสไลเดอร์",
        ["Text Color"] = "สีตัวหนังสือ",
        ["Font & Size & Language"] = "ฟอนต์ & ขนาด และภาษา",
        ["Text Size"] = "ขนาดตัวหนังสือ",
        ["Change Font"] = "เปลี่ยนฟอนต์",
        ["Change Language"] = "เปลี่ยนภาษา"
    },
    English = {
        ["เมนูหลัก"] = "Main Menu",
        ["Test1"] = "Test1",
        ["Test2"] = "Test2",
        ["Toggle"] = "Toggle",
        ["Notification"] = "Notification",
        ["Default"] = "Default",
        ["ColorPicker"] = "Color Picker",
        ["ColorPicker2"] = "Color Picker 2",
        ["Slider"] = "Slider",
        ["Dropdown"] = "Dropdown",
        ["Hello"] = "Hello",
        ["World"] = "World",
        ["Hello World"] = "Hello World",
        ["Word"] = "Word",
        ["ผู้เล่น"] = "Player",
        ["ความไวการเดิน"] = "Walk Sensitivity",
        ["ความไว"] = "Sensitivity",
        ["เดินเร็ว"] = "Walk Fast",
        ["ความเร็ว"] = "Speed",
        ["กระโดด"] = "Jump",
        ["ความสูง"] = "Height",
        ["กระโดดสูง"] = "High Jump",
        ["กระโดดหลายครั้ง"] = "Multi Jump",
        ["ตั้งค่า"] = "Settings",
        ["สีของหน้าต่าง"] = "Window Colors",
        ["สีสวิตช์ปิด"] = "Switch Off Color",
        ["สีสวิตช์เปิด"] = "Switch On Color",
        ["สีพื้นหลัง"] = "Background Color",
        ["สีแถบบน"] = "Top Bar Color",
        ["สีสไลเดอร์"] = "Slider Color",
        ["สีตัวหนังสือ"] = "Text Color",
        ["ฟอนต์ & ขนาด และภาษา"] = "Font & Size & Language",
        ["ขนาดตัวหนังสือ"] = "Text Size",
        ["เปลี่ยนฟอนต์"] = "Change Font",
        ["เปลี่ยนภาษา"] = "Change Language",
        ["Main Menu"] = "Main Menu",
        ["Player"] = "Player",
        ["Walk Sensitivity"] = "Walk Sensitivity",
        ["Sensitivity"] = "Sensitivity",
        ["Walk Fast"] = "Walk Fast",
        ["Speed"] = "Speed",
        ["Jump"] = "Jump",
        ["Height"] = "Height",
        ["High Jump"] = "High Jump",
        ["Multi Jump"] = "Multi Jump",
        ["Settings"] = "Settings",
        ["Window Colors"] = "Window Colors",
        ["Switch Off Color"] = "Switch Off Color",
        ["Switch On Color"] = "Switch On Color",
        ["Background Color"] = "Background Color",
        ["Top Bar Color"] = "Top Bar Color",
        ["Slider Color"] = "Slider Color",
        ["Text Color"] = "Text Color",
        ["Font & Size & Language"] = "Font & Size & Language",
        ["Text Size"] = "Text Size",
        ["Change Font"] = "Change Font",
        ["Change Language"] = "Change Language"
    }
}

local function setLanguage(langKey)
    for _, child in pairs(win.container.Main:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            local currentText = child.Text
            if translations[langKey][currentText] then
                child.Text = translations[langKey][currentText]
            end
        end
    end
    -- Also check the pages container for button texts
    for _, page in pairs(win.pages) do
        if page.button and page.button.Title then
            local currentText = page.button.Title.Text
            if translations[langKey][currentText] then
                page.button.Title.Text = translations[langKey][currentText]
            end
        end
    end
end

-- Apply loaded font size if available
if savedSettings.fontSize then
    for _, child in pairs(win.container.Main:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            -- Skip top bar buttons (Toggle, Maximize, Close) and their text
            if child.Name ~= "Title" or child.Parent.Name ~= "TopBar" then
                if child.Name ~= "ToggleButton" and child.Name ~= "MaximizeButton" and child.Name ~= "CloseButton" then
                    if child.TextSize >= 10 and child.TextSize <= 24 then
                        child.TextSize = savedSettings.fontSize
                    end
                end
            end
        end
    end
end

-- Apply loaded font if available
if savedSettings.font then
    local fontEnum = Enum.Font[savedSettings.font]
    if fontEnum then
        for _, child in pairs(win.container.Main:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                if child.Name ~= "Title" or child.Parent.Name ~= "TopBar" then
                    child.Font = fontEnum
                end
            end
        end
    end
end

-- Apply loaded theme colors if available
if savedSettings.themes then
    for themeName, colorData in pairs(savedSettings.themes) do
        if themes[themeName] then
            -- Values are already in 0-255 range, no need to multiply again
            local color3 = Color3.fromRGB(math.floor(colorData.R), math.floor(colorData.G), math.floor(colorData.B))
            win:setTheme(themeName, color3)
        end
    end
end

-- Set initial language (use saved if available, otherwise default to English)
local initialLanguage = savedSettings.language or "English"
setLanguage(initialLanguage)

setting2:Dropdown("เปลี่ยนภาษา", {"ไทย", "English"}, function(lang)
    local langKey = lang == "ไทย" and "Thai" or "English"
    savedSettings.language = langKey
    saveSettings()
    setLanguage(langKey)
end)

-- Add reset button directly to page container (without section header)
local resetButton = utility:Create("ImageButton", {
    Name = "ResetButton",
    Parent = page2.container,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 0),
    ZIndex = 2,
    Image = "rbxassetid://5028857472",
    ImageColor3 = themes.TopBarColor:Lerp(Color3.new(1, 1, 1), 0.3), -- Lighter than TopBarColor
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(2, 2, 298, 298)
}, {
    utility:Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3,
        Font = Enum.Font.GothamBold,
        Text = "คืนค่าเริ่มต้น",
        TextColor3 = Color3.fromRGB(20, 20, 20), -- Dark text color
        TextSize = 14,
        TextTransparency = 0
    })
})

resetButton.MouseButton1Click:Connect(function()
    -- Reset all settings to default
    savedSettings = {
        themes = {},
        fontSize = 14,
        font = "Gotham",
        language = "English",
        toggles = {},
        textboxes = {},
        sliders = {},
        dropdowns = {},
        colorpickers = {},
        windowPosition = nil,
        isMaximized = false,
        selectedPage = nil
    }
    
    -- Reset theme colors to default
    themes.NotToggledColor = Color3.fromRGB(100, 80, 150)
    themes.Background = Color3.fromRGB(10, 5, 20)
    themes.Glow = Color3.fromRGB(80, 40, 160)
    themes.Accent = Color3.fromRGB(0, 255, 255)
    themes.LightContrast = Color3.fromRGB(30, 15, 50)
    themes.DarkContrast = Color3.fromRGB(20, 10, 35)
    themes.TextColor = Color3.fromRGB(0, 255, 255)
    themes.ButtonColor = Color3.fromRGB(100, 80, 150)
    themes.ToggledColor = Color3.fromRGB(0, 200, 255)
    themes.SliderColor = Color3.fromRGB(120, 60, 200)
    themes.TopBarColor = Color3.fromRGB(60, 20, 120)
    
    -- Apply reset theme
    for themeName, color in pairs(themes) do
        win:setTheme(themeName, color)
    end

    -- Update theme color picker buttons to display reset colors
    local themeMap = {
        ["สีสวิตช์ปิด"] = "NotToggledColor",
        ["สีสวิตช์เปิด"] = "ToggledColor",
        ["สีพื้นหลัง"] = "Background",
        ["สีแถบบน"] = "TopBarColor",
        ["สีตัวหนังสือ"] = "TextColor"
    }

    print("Reset: Found " .. #setting1.modules .. " modules in setting1")
    print("Reset: Found " .. #setting1.colorpickers .. " colorpickers in setting1")

    -- Use setting1's colorpickers table to update each color picker
    for colorpicker, pickerData in pairs(setting1.colorpickers) do
        if colorpicker and colorpicker:FindFirstChild("Button") and colorpicker:FindFirstChild("Title") then
            local titleText = colorpicker.Title.Text
            local themeName = themeMap[titleText]
            print("Reset: Found color picker with title: " .. titleText .. ", themeName: " .. tostring(themeName))
            if themeName and themes[themeName] then
                print("Reset: Updating color picker " .. titleText .. " to " .. tostring(themes[themeName]))
                -- Use the section's updateColorPicker function to properly update all properties
                setting1:updateColorPicker(colorpicker, nil, themes[themeName])
            end
        end
    end

    -- Reset font size
    for _, child in pairs(win.container.Main:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            if child.Name ~= "Title" or child.Parent.Name ~= "TopBar" then
                if child.Name ~= "ToggleButton" and child.Name ~= "MaximizeButton" and child.Name ~= "CloseButton" then
                    if child.TextSize >= 10 and child.TextSize <= 24 then
                        child.TextSize = 14
                    end
                end
            end
        end
    end
    
    -- Reset font
    local fontEnum = Enum.Font.Gotham
    for _, child in pairs(win.container.Main:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            if child.Name ~= "Title" or child.Parent.Name ~= "TopBar" then
                child.Font = fontEnum
            end
        end
    end
    
    -- Reset language
    setLanguage("English")
    
    -- Clear workspace storage
    pcall(function()
        local folder = workspace:FindFirstChild("XsoulSettings")
        if folder then
            folder:Destroy()
        end
    end)
    
    -- Clear PlayerGui storage
    pcall(function()
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            local folder = playerGui:FindFirstChild("XsoulSettings")
            if folder then
                folder:Destroy()
            end
        end
    end)
    
    -- Clear file storage
    pcall(function()
        if isfile(settingsFile) then
            delfile(settingsFile)
        end
    end)
    
    -- Save the reset settings
    saveSettings()
    
    win:Notify("รีเซต", "คืนค่าเริ่มต้นเรียบร้อยแล้ว")
end)

-- Update page canvas size to include reset button
page2:Resize()

return library
