# StreakTracker.nvim

Streak Tracker.nvim - track your daily coding streak inside Neovim.

---

## ✨ Features
- **Save streak data** -> Automatically stores your streak in a JSON file.
- **Load streak data** -> Reads your progress everytime you open Neovim.
- **Automatic updates** -> Increments streak daily on startup.
- **Manual check** -> :Streak shows your current streak in a popup.
- **Reset streak** -> :StreakReset starts you over from 0.
- **Notifications** -> pretty popups with nvim-notify (https://github.com/rcarriga/nvim-notify).

---

## 📦 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "yourname/projectname.nvim",
    dependencies = { "rcarriga/nvim-notify" }, -- if you want notifications
    config = function()
        require("projectname").setup()
    end,
},
````
---

## ⚙️ Configuration

StreakTracker works out of the box with sensible defaults, but you can customize its behavior:
      
```lua
require("streak_plugin").setup({
    allow_reset = false,   -- disable the :StreakReset command
    mode = "activity",     -- only count streaks when saving files
})
````

```lua
{
    allow_reset = true,
    mode = "both", -- "startup", "activity", or both "both"
},
````

- allow_reset -> if false, the :StreakReset command will not be available.
- mode -> Controls when streak update:
    - "startup" -> only on when Neovim startup.
    - "activity" -> only when saving a file.
    - "both" -> updates on both startup and saves


