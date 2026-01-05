local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/a11bove/kdoaz/refs/heads/main/src/sab/Library.lua"))()
Library.Theme = "AIKOWARE"
local Flags = Library.Flags

local Window = Library:Window({
   Text = "Aikoware"
})

local Tab = Window:Tab({
   Text = "Tab 1"
})

local Tab2 = Window:Tab({
   Text = "Tab 2"
})

local Section = Tab:Section({
   Text = "Section 1"
})

local Discord = Tab:Section({
   Text = "Discord",
   Side = Right
})

local Section2 = Tab2:Section({
   Text = "Section 2"
})

Section:Button({
   Text = "Button",
   Callback = function(value)
       warn(value)
   end
})

Section:Dropdown({
   Text = "Dropdown",
   List = {"Banana", "Apple"},
   Callback = function(v)
       warn(v)
   end
})

Section:Slider({
   Text = "Slider",
   Default = 25,
   Minimum = 0,
   Maximum = 200
})

Section:Toggle({
   Text = "Toggle",
   Callback = function(bool)
       warn(bool)
   end
})

Discord:Button({
    Text = "Copy Server Link",
    Callback = function()
      setclipboard("https://discord.gg/JccfFGpDNV")
      Library:Notification({
         Title = "Aikoware",
         Description = "Successfully Copied!",
         Timeout = 5
    })
    end
})

Section2:Keybind({
   Text = "Keybind",
   Default = Enum.KeyCode.Z,
   Callback = function()
       warn("Pressed.")
   end
})

Section2:Input({
   Text = "Input",
   Callback = function(txt)
       warn(txt)
   end
})

Tab:Select()
