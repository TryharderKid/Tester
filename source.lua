local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Lurnai = {
    Version = "1.0.0",
    Flags = {},
    Theme = {
        Background = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(60, 60, 60),
        Gradient1 = Color3.fromRGB(45, 45, 45),
        Gradient2 = Color3.fromRGB(35, 35, 35)
    },
    Assets = {
        Close = "rbxassetid://9886659671",
        Min = "rbxassetid://9886659276",
        Max = "rbxassetid://9886659406",
        Restore = "rbxassetid://9886659001"
    }
}

Lurnai.SaveManager = {
    Folder = "LurnaiUI",
    Ignore = {},
    Settings = {},
    
    Save = function(name)
        local data = {}
        for flag, value in pairs(Lurnai.Flags) do
            if not table.find(Lurnai.SaveManager.Ignore, flag) then
                data[flag] = value
            end
        end
        writefile(Lurnai.SaveManager.Folder .. "/" .. name .. ".json", HttpService:JSONEncode(data))
    end,
    
    Load = function(name)
        local data = HttpService:JSONDecode(readfile(Lurnai.SaveManager.Folder .. "/" .. name .. ".json"))
        for flag, value in pairs(data) do
            if Lurnai.Flags[flag] then
                Lurnai.Flags[flag] = value
            end
        end
    end
}

function Lurnai:CreateWindow(config)
    local Window = {
        Tabs = {},
        Elements = {},
        Minimized = false,
        Maximized = false
    }
    
    Window.Main = Instance.new("ScreenGui")
    Window.Main.Name = "LurnaiUI"
    Window.Main.Parent = CoreGui
    
    Window.Frame = Instance.new("Frame")
    Window.Frame.Size = config.Size or UDim2.fromOffset(600, 400)
    Window.Frame.Position = UDim2.fromScale(0.5, 0.5)
    Window.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Window.Frame.BackgroundColor3 = self.Theme.Background
    Window.Frame.Parent = Window.Main
    
    local dragging = false
    local dragInput, dragStart, startPos
    
    Window.Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Window.Frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Window.Frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    function Window:CreateTab(name)
        local Tab = {
            Name = name,
            Elements = {}
        }
        
        Tab.Button = Instance.new("TextButton")
        Tab.Button.Size = UDim2.new(1, 0, 0, 30)
        Tab.Button.BackgroundColor3 = Lurnai.Theme.Border
        Tab.Button.Text = name
        Tab.Button.TextColor3 = Lurnai.Theme.Text
        Tab.Button.Parent = Window.TabHolder
        
        Tab.Container = Instance.new("ScrollingFrame")
        Tab.Container.Size = UDim2.fromScale(1, 1)
        Tab.Container.BackgroundTransparency = 1
        Tab.Container.ScrollBarThickness = 2
        Tab.Container.Parent = Window.Container
        
        function Tab:CreateButton(name, options)
            local Button = {
                Name = name,
                Instance = Instance.new("TextButton"),
                Callback = options.Callback
            }
            
            Button.Instance.Size = UDim2.new(1, -20, 0, 32)
            Button.Instance.BackgroundColor3 = Lurnai.Theme.Border
            Button.Instance.Text = name
            Button.Instance.TextColor3 = Lurnai.Theme.Text
            Button.Instance.Parent = Tab.Container
            
            Button.Instance.MouseButton1Click:Connect(Button.Callback)
            
            return Button
        end
        
        function Tab:CreateToggle(name, options)
            local Toggle = {
                Name = name,
                Value = options.Default or false,
                Flag = options.Flag,
                Callback = options.Callback
            }
            
            Toggle.Instance = Instance.new("Frame")
            Toggle.Instance.Size = UDim2.new(1, -20, 0, 32)
            Toggle.Instance.BackgroundColor3 = Lurnai.Theme.Border
            Toggle.Instance.Parent = Tab.Container
            
            Toggle.Button = Instance.new("TextButton")
            Toggle.Button.Size = UDim2.fromOffset(24, 24)
            Toggle.Button.Position = UDim2.new(0, 4, 0.5, -12)
            Toggle.Button.BackgroundColor3 = Toggle.Value and Lurnai.Theme.Accent or Lurnai.Theme.Background
            Toggle.Button.Parent = Toggle.Instance
            
            Toggle.Label = Instance.new("TextLabel")
            Toggle.Label.Text = name
            Toggle.Label.Size = UDim2.new(1, -36, 1, 0)
            Toggle.Label.Position = UDim2.fromOffset(32, 0)
            Toggle.Label.BackgroundTransparency = 1
            Toggle.Label.TextColor3 = Lurnai.Theme.Text
            Toggle.Label.Parent = Toggle.Instance
            
            Toggle.Button.MouseButton1Click:Connect(function()
                Toggle.Value = not Toggle.Value
                Toggle.Button.BackgroundColor3 = Toggle.Value and Lurnai.Theme.Accent or Lurnai.Theme.Background
                if Toggle.Flag then
                    Lurnai.Flags[Toggle.Flag] = Toggle.Value
                end
                Toggle.Callback(Toggle.Value)
            end)
            
            return Toggle
        end
        
        function Tab:CreateSlider(name, options)
            local Slider = {
                Name = name,
                Value = options.Default or options.Min,
                Min = options.Min or 0,
                Max = options.Max or 100,
                Flag = options.Flag,
                Callback = options.Callback
            }
            
            Slider.Instance = Instance.new("Frame")
            Slider.Instance.Size = UDim2.new(1, -20, 0, 42)
            Slider.Instance.BackgroundColor3 = Lurnai.Theme.Border
            Slider.Instance.Parent = Tab.Container
            
            Slider.Label = Instance.new("TextLabel")
            Slider.Label.Text = string.format("%s: %d", name, Slider.Value)
            Slider.Label.Size = UDim2.new(1, -16, 0, 18)
            Slider.Label.Position = UDim2.fromOffset(8, 2)
            Slider.Label.BackgroundTransparency = 1
            Slider.Label.TextColor3 = Lurnai.Theme.Text
            Slider.Label.Parent = Slider.Instance
            
            Slider.SliderBar = Instance.new("Frame")
            Slider.SliderBar.Size = UDim2.new(1, -16, 0, 4)
            Slider.SliderBar.Position = UDim2.fromOffset(8, 28)
            Slider.SliderBar.BackgroundColor3 = Lurnai.Theme.Background
            Slider.SliderBar.Parent = Slider.Instance
            
            Slider.Fill = Instance.new("Frame")
            Slider.Fill.Size = UDim2.new((Slider.Value - Slider.Min)/(Slider.Max - Slider.Min), 0, 1, 0)
            Slider.Fill.BackgroundColor3 = Lurnai.Theme.Accent
            Slider.Fill.Parent = Slider.SliderBar
            
            local dragging = false
            
            Slider.SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            Slider.SliderBar.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local percentage = math.clamp((input.Position.X - Slider.SliderBar.AbsolutePosition.X) / Slider.SliderBar.AbsoluteSize.X, 0, 1)
                    local value = math.floor(Slider.Min + ((Slider.Max - Slider.Min) * percentage))
                    Slider.Value = value
                    Slider.Label.Text = string.format("%s: %d", name, value)
                    Slider.Fill.Size = UDim2.new(percentage, 0, 1, 0)
                    if Slider.Flag then
                        Lurnai.Flags[Slider.Flag] = value
                    end
                    Slider.Callback(value)
                end
            end)
            
            return Slider
        end
        
        function Tab:CreateDropdown(name, options)
            local Dropdown = {
                Name = name,
                Value = options.Default or options.List[1],
                List = options.List,
                Flag = options.Flag,
                Callback = options.Callback,
                Open = false
            }
            
            Dropdown.Instance = Instance.new("Frame")
            Dropdown.Instance.Size = UDim2.new(1, -20, 0, 32)
            Dropdown.Instance.BackgroundColor3 = Lurnai.Theme.Border
            Dropdown.Instance.Parent = Tab.Container
            
            Dropdown.Button = Instance.new("TextButton")
            Dropdown.Button.Size = UDim2.fromScale(1, 1)
            Dropdown.Button.BackgroundTransparency = 1
            Dropdown.Button.Text = string.format("%s: %s", name, Dropdown.Value)
            Dropdown.Button.TextColor3 = Lurnai.Theme.Text
            Dropdown.Button.Parent = Dropdown.Instance
            
            Dropdown.ItemHolder = Instance.new("Frame")
            Dropdown.ItemHolder.Size = UDim2.new(1, 0, 0, #Dropdown.List * 32)
            Dropdown.ItemHolder.Position = UDim2.fromOffset(0, 32)
            Dropdown.ItemHolder.BackgroundColor3 = Lurnai.Theme.Border
            Dropdown.ItemHolder.Visible = false
            Dropdown.ItemHolder.Parent = Dropdown.Instance
            
            for i, item in ipairs(Dropdown.List) do
                local ItemButton = Instance.new("TextButton")
                ItemButton.Size = UDim2.new(1, 0, 0, 32)
                ItemButton.Position = UDim2.fromOffset(0, (i-1) * 32)
                ItemButton.BackgroundTransparency = 1
                ItemButton.Text = item
                ItemButton.TextColor3 = Lurnai.Theme.Text
                ItemButton.Parent = Dropdown.ItemHolder
                
                ItemButton.MouseButton1Click:Connect(function()
                    Dropdown.Value = item
                    Dropdown.Button.Text = string.format("%s: %s", name, item)
                    Dropdown.ItemHolder.Visible = false
                    Dropdown.Open = false
                    if Dropdown.Flag then
                        Lurnai.Flags[Dropdown.Flag] = item
                    end
                    Dropdown.Callback(item)
                end)
            end
            
            Dropdown.Button.MouseButton1Click:Connect(function()
                Dropdown.Open = not Dropdown.Open
                Dropdown.ItemHolder.Visible = Dropdown.Open
            end)
            
            return Dropdown
        end
        
        function Tab:CreateColorPicker(name, options)
            local ColorPicker = {
                Name = name,
                Value = options.Default or Color3.fromRGB(255, 255, 255),
                Flag = options.Flag,
                Callback = options.Callback
            }
            
            ColorPicker.Instance = Instance.new("Frame")
            ColorPicker.Instance.Size = UDim2.new(1, -20, 0, 32)
            ColorPicker.Instance.BackgroundColor3 = Lurnai.Theme.Border
            ColorPicker.Instance.Parent = Tab.Container
            
            ColorPicker.Preview = Instance.new("Frame")
            ColorPicker.Preview.Size = UDim2.fromOffset(24, 24)
            ColorPicker.Preview.Position = UDim2.new(0, 4, 0.5, -12)
            ColorPicker.Preview.BackgroundColor3 = ColorPicker.Value
            ColorPicker.Preview.Parent = ColorPicker.Instance
            
            ColorPicker.Label = Instance.new("TextLabel")
            ColorPicker.Label.Text = name
            ColorPicker.Label.Size = UDim2.new(1, -36, 1, 0)
            ColorPicker.Label.Position = UDim2.fromOffset(32, 0)
            ColorPicker.Label.BackgroundTransparency = 1
            ColorPicker.Label.TextColor3 = Lurnai.Theme.Text
            ColorPicker.Label.Parent = ColorPicker.Instance
            
ColorPicker.PickerFrame = Instance.new("Frame")
ColorPicker.PickerFrame.Size = UDim2.fromOffset(200, 240)
ColorPicker.PickerFrame.Position = UDim2.new(1, 10, 0, 0)
ColorPicker.PickerFrame.BackgroundColor3 = Lurnai.Theme.Border
ColorPicker.PickerFrame.Visible = false
ColorPicker.PickerFrame.Parent = ColorPicker.Instance

ColorPicker.MainPicker = Instance.new("ImageLabel")
ColorPicker.MainPicker.Size = UDim2.new(1, -20, 0, 180)
ColorPicker.MainPicker.Position = UDim2.fromOffset(10, 10)
ColorPicker.MainPicker.Image = "rbxassetid://4155801252"
ColorPicker.MainPicker.Parent = ColorPicker.PickerFrame

ColorPicker.Cursor = Instance.new("Frame")
ColorPicker.Cursor.Size = UDim2.fromOffset(4, 4)
ColorPicker.Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
ColorPicker.Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
ColorPicker.Cursor.Parent = ColorPicker.MainPicker

ColorPicker.HueSlider = Instance.new("Frame")
ColorPicker.HueSlider.Size = UDim2.new(1, -20, 0, 20)
ColorPicker.HueSlider.Position = UDim2.fromOffset(10, 200)
ColorPicker.HueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
ColorPicker.HueSlider.Parent = ColorPicker.PickerFrame

local HueGradient = Instance.new("UIGradient")
HueGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
})
HueGradient.Parent = ColorPicker.HueSlider

ColorPicker.HueCursor = Instance.new("Frame")
ColorPicker.HueCursor.Size = UDim2.fromOffset(2, 20)
ColorPicker.HueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
ColorPicker.HueCursor.Parent = ColorPicker.HueSlider

local function UpdateColor()
    local hue, sat, val = Color3.toHSV(ColorPicker.Value)
    ColorPicker.Preview.BackgroundColor3 = ColorPicker.Value
    ColorPicker.HueCursor.Position = UDim2.fromScale(hue, 0)
    ColorPicker.MainPicker.ImageColor3 = Color3.fromHSV(hue, 1, 1)
    ColorPicker.Cursor.Position = UDim2.fromScale(sat, 1 - val)
end

local function SetColor(hue, sat, val)
    ColorPicker.Value = Color3.fromHSV(hue, sat, val)
    UpdateColor()
    if ColorPicker.Flag then
        Lurnai.Flags[ColorPicker.Flag] = ColorPicker.Value
    end
    ColorPicker.Callback(ColorPicker.Value)
end

local pickerDragging = false
ColorPicker.MainPicker.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        pickerDragging = true
    end
end)

ColorPicker.MainPicker.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and pickerDragging then
        local sat = math.clamp((input.Position.X - ColorPicker.MainPicker.AbsolutePosition.X) / ColorPicker.MainPicker.AbsoluteSize.X, 0, 1)
        local val = 1 - math.clamp((input.Position.Y - ColorPicker.MainPicker.AbsolutePosition.Y) / ColorPicker.MainPicker.AbsoluteSize.Y, 0, 1)
        local hue = Color3.toHSV(ColorPicker.Value)
        SetColor(hue, sat, val)
    end
end)

local hueDragging = false
ColorPicker.HueSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        hueDragging = true
    end
end)

ColorPicker.HueSlider.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and hueDragging then
        local hue = math.clamp((input.Position.X - ColorPicker.HueSlider.AbsolutePosition.X) / ColorPicker.HueSlider.AbsoluteSize.X, 0, 1)
        local _, sat, val = Color3.toHSV(ColorPicker.Value)
        SetColor(hue, sat, val)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        pickerDragging = false
        hueDragging = false
    end
end)

ColorPicker.Preview.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        ColorPicker.PickerFrame.Visible = not ColorPicker.PickerFrame.Visible
    end
end)

UpdateColor()
            
            return ColorPicker
        end
        
        function Tab:CreateKeybind(name, options)
            local Keybind = {
                Name = name,
                Value = options.Default or Enum.KeyCode.Unknown,
                Flag = options.Flag,
                Callback = options.Callback,
                Listening = false
            }
            
            Keybind.Instance = Instance.new("Frame")
            Keybind.Instance.Size = UDim2.new(1, -20, 0, 32)
            Keybind.Instance.BackgroundColor3 = Lurnai.Theme.Border
            Keybind.Instance.Parent = Tab.Container
            
            Keybind.Button = Instance.new("TextButton")
            Keybind.Button.Size = UDim2.fromOffset(100, 24)
            Keybind.Button.Position = UDim2.new(1, -104, 0.5, -12)
            Keybind.Button.BackgroundColor3 = Lurnai.Theme.Background
            Keybind.Button.Text = Keybind.Value.Name
            Keybind.Button.TextColor3 = Lurnai.Theme.Text
            Keybind.Button.Parent = Keybind.Instance
            
            Keybind.Label = Instance.new("TextLabel")
            Keybind.Label.Text = name
            Keybind.Label.Size = UDim2.new(1, -110, 1, 0)
            Keybind.Label.Position = UDim2.fromOffset(8, 0)
            Keybind.Label.BackgroundTransparency = 1
            Keybind.Label.TextColor3 = Lurnai.Theme.Text
            Keybind.Label.Parent = Keybind.Instance
            
            Keybind.Button.MouseButton1Click:Connect(function()
                Keybind.Listening = true
                Keybind.Button.Text = "..."
            end)
            
            UserInputService.InputBegan:Connect(function(input)
                if Keybind.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    Keybind.Value = input.KeyCode
                    Keybind.Button.Text = input.KeyCode.Name
                    Keybind.Listening = false
                    if Keybind.Flag then
                        Lurnai.Flags[Keybind.Flag] = input.KeyCode
                    end
                    Keybind.Callback(input.KeyCode)
                end
            end)
            
            return Keybind
        end

        return Tab
    end
    
    return Window
end

return Lurnai        
