-- Streak Tracker.nvim
-- Tracks your daily Neovim usage streak and shows notifications
local M = {}

-- Program internal state settings
local internal_state = {
    settings = {
        allow_reset = true,
        mode = "both",
    },
    modes = { "activity", "startup", "both" },
}

local function notify_streak(data, prefix)
    local days_str = data.streak == 1 and " day" or " days!"
    local message = prefix .. data.streak .. days_str

    vim.notify(message, vim.log.levels.INFO, {
        title = "Streak Tracker",
        timeout = 3000,
    })
end

-- Save streak data in JSON at ~/.local/share/nvim/streak.txt
local path = vim.fn.stdpath("data") .. "/streak.json"

-- Save a Lua table as JSON into streak.json file
local function save(tbl)
    local json_text = vim.fn.json_encode(tbl)

    local file = io.open(path, "w")

    if not file then
        return nil
    end

    file:write(json_text)
    file:close()
end

-- Load streak data from streak.json file
local function load()
    local f = io.open(path, "r")
    if not f then
        return { last_date = "", streak = 0 }
    end

    local content = f:read("*a")
    f:close()

    local ok, data = pcall(vim.fn.json_decode, content)
    if not ok or type(data) ~= "table" then
        -- If decode failed, return a fresh streak
        return { last_date = "", streak = 0 }
    end

    return data
end

-- Update lua table with current streak data
local function update_streak()
    local data = load()

    local today = os.date("%Y-%m-%d")

    if data.last_date == today then
        return data
    end

    local yesterday = os.date("%Y-%m-%d", os.time() - 24 * 60 * 60)

    -- If last_date is yesterday, increment the streak by 1, else reset
    if yesterday == data.last_date then
        data.streak = data.streak + 1
    else
        data.streak = 1
    end

    data.last_date = today
    save(data)

    return data
end

function M.setup(opts)
    -- User commands
    opts = opts or {}

    internal_state.settings = vim.tbl_extend("force", internal_state.settings, opts)

    if internal_state.settings.allow_reset then
        vim.api.nvim_create_user_command("StreakReset", function()
            local data = { last_date = os.date("%Y-%m-%d"), streak = 0 }
            save(data)
            vim.notify("🔄 Streak has been reset. " .. data.streak .. " days", vim.log.levels.WARN, {
                title = "Streak Tracker",
            })
        end, {})
    end

    vim.api.nvim_create_user_command("Streak", function()
        local data = load()
        vim.notify("🔥 Current streak: " .. data.streak .. " days", vim.log.levels.INFO, {
            title = "Streak Tracker",
            timeout = 2500,
        })
    end, {})

    if not vim.tbl_contains(internal_state.modes, internal_state.settings.mode) then
        internal_state.settings.mode = "both"
    end

    if internal_state.settings.mode == "startup" or internal_state.settings.mode == "both" then
        -- Autocmd: update streak on startup
        vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                local data = update_streak()
                -- Show popup notification (requires nvim-notify)
                notify_streak(data, "🌟 Coding Streak: ")
            end,
        })
    end

    if internal_state.settings.mode == "activity" or internal_state.settings.mode == "both" then
        vim.api.nvim_create_autocmd("BufWritePost", {
            callback = function()
                local before = load()
                local after = update_streak()

                if before.last_date ~= after.last_date then
                    notify_streak(after, "🌟 Coding Streak: ")
                end
            end,
        })
    end
end

-- Expose an API function to get the current streak (useful for statusline integration like Lualine)
function M.get_streak()
    local data = load()
    return data.streak
end

return M
