# VenUI UI Library (Roblox)

**VenUI** là UI library Roblox phát triển theo định hướng source Rayfield, nhưng đã nâng cấp giao diện và API theo phong cách riêng, tối ưu cho mobile.

## Điểm nâng cấp chính

- Giao diện mới: topbar có title/subtitle, sidebar có search tab, gradient + accent indicator để dễ nhìn hơn.
- Mobile-first: touch target lớn hơn, kéo thả cửa sổ bằng touch/mouse, nút mở lại UI khi minimize.
- Minimize tiện hơn: khi thu nhỏ sẽ xuất hiện **dock bar** có nút `Open` và có thể kéo dock tới vị trí thuận tay.
- API nâng cấp: thêm `AddSection`, `AddParagraph`, `AddKeybind`, `AddColorPicker`, `SetTitle`, `SetSubtitle`, `SelectTab`.
- Quản lý state: `VenUI.Flags`, `GetFlag`, `SetFlag`, `SaveConfig`, `LoadConfig`.

## Cách dùng với `loadstring` + `HttpGet`

```lua
local VenUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/<username>/<repo>/<branch>/VenUI.lua"))()

local Window = VenUI:CreateWindow({
    Title = "VenUI Demo",
    Subtitle = "Mobile + Rayfield-inspired"
})

local Main = Window:CreateTab({
    Name = "Main",
    Icon = "⚡"
})

Main:AddSection("Gameplay")
Main:AddParagraph({
    Title = "Welcome",
    Content = "Đây là VenUI bản nâng cấp, không clone 100% Rayfield."
})

Main:AddToggle({
    Name = "Auto Farm",
    Flag = "autofarm",
    CurrentValue = false,
    Callback = function(v)
        print("Auto Farm:", v)
    end
})

Main:AddSlider({
    Name = "WalkSpeed",
    Flag = "walkspeed",
    Range = {16, 200},
    CurrentValue = 16,
    Callback = function(v)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
})

Main:AddDropdown({
    Name = "Team",
    Flag = "team",
    Options = {"Pirates", "Marines", "Hunters"},
    CurrentOption = "Pirates",
    Callback = function(v)
        print("Team:", v)
    end
})

Main:AddColorPicker({
    Name = "ESP Color",
    Flag = "esp_color",
    Callback = function(color)
        print("Color:", color)
    end
})

Main:AddKeybind({
    Name = "Toggle UI",
    Flag = "ui_key",
    CurrentKeybind = Enum.KeyCode.RightShift,
    Callback = function()
        print("Key pressed")
    end
})

VenUI:Notify({
    Title = "VenUI",
    Content = "Loaded successfully",
    Duration = 3
})
```

## API

### Global
- `VenUI:SetTheme(themeTable)`
- `VenUI:Notify({Title, Content, Duration})`
- `VenUI:GetFlag(flagName)`
- `VenUI:SetFlag(flagName, value)`
- `VenUI:SaveConfig("venui_config.json")` *(cần executor hỗ trợ `writefile`)*
- `VenUI:LoadConfig("venui_config.json")` *(cần `readfile/isfile`)*

### Window
- `window = VenUI:CreateWindow({Title, Subtitle})`
- `window:SetTitle(text)`
- `window:SetSubtitle(text)`
- `window:SelectTab(indexOrName)`
- `window:Destroy()`
- `tab = window:CreateTab({Name, Icon})`

### Tab Elements
- `tab:AddSection(name)`
- `tab:AddParagraph({Title, Content})`
- `tab:AddLabel(text)`
- `tab:AddButton({Name, Callback})`
- `tab:AddToggle({Name, Flag, CurrentValue, Callback})`
- `tab:AddSlider({Name, Flag, Range, CurrentValue, Callback})`
- `tab:AddInput({Name, Flag, PlaceholderText, CurrentValue, RemoveTextAfterFocusLost, Callback})`
- `tab:AddDropdown({Name, Flag, Options, CurrentOption, Callback})`
- `tab:AddColorPicker({Name, Flag, Preset, Callback})`
- `tab:AddKeybind({Name, Flag, CurrentKeybind, Callback, ChangedCallback})`

## Lưu ý

- Dùng trong `LocalScript` (vì thao tác `PlayerGui`).
- Library hỗ trợ tốt mobile, nhưng vẫn chạy ổn trên PC.
- Đây là phiên bản tuỳ biến theo tinh thần Rayfield, không phải bản clone y hệt.
