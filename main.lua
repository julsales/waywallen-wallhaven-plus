local discover = import("wallhaven_plus.discover")
local api = import("wallhaven_plus.api")
local source = import("wallhaven_plus.source")
local wallpaper = import("wallhaven_plus.wallpaper")
local session = import("wallhaven_plus.session")

local M = {}
local account_group = "Wallhaven Plus account"

function M.info()
    return {
        name = "wallhaven_plus",
        display_name = "Wallhaven Plus",
        status = {
            {
                id = "wallhaven_plus_account",
                label = "Status",
                group = "account",
                group_label = account_group,
                order = 10,
            },
        },
        actions = {
            {
                id = "wallhaven_plus_sign_in",
                kind = "form",
                label = "Log in to Wallhaven",
                description = "Use an API key from your Wallhaven account settings. Do not enter your Wallhaven password.",
                group = "account",
                group_label = account_group,
                order = 20,
                required_for_browsing = false,
                fields = {
                    {
                        key = "api_key",
                        label = "API key",
                        description = "Copy the API key from Wallhaven Account Settings.",
                        placeholder = "Wallhaven API key",
                        secret = true,
                        required = true,
                    },
                },
            },
            {
                id = "wallhaven_plus_sign_out",
                kind = "invoke",
                label = "Remove API key",
                group = "account",
                group_label = account_group,
                order = 21,
            },
        },
        capabilities = {
            discover = {
                search = true,
                details = true,
                download = true,
                sorts = {
                    { key = "recent", label = "Recent" },
                    { key = "trend", label = "Trending (1 month)" },
                    { key = "top3m", label = "Top 3 months" },
                    { key = "top6m", label = "Top 6 months" },
                    { key = "top1y", label = "Top 1 year" },
                    { key = "views", label = "Most viewed" },
                    { key = "popular", label = "Most favorited" },
                    { key = "hot", label = "Hot" },
                    { key = "random", label = "Random" },
                },
                filters = api.filters,
            },
            wallpaper = {
                apply = true,
            },
        },
    }
end

M.lifecycle = {}
M.lifecycle.load = session.load
M.lifecycle.save = session.save
M.lifecycle.check = session.check

M.actions = {}
function M.actions.status(ctx)
    local checked = session.current_check()
    local active = checked.state == "signed_in"
    return {
        status = { wallhaven_plus_account = checked.display_value or "" },
        actions = {
            wallhaven_plus_sign_in = { visible = not active, enabled = not active },
            wallhaven_plus_sign_out = { visible = active, enabled = active },
        },
    }
end

function M.actions.invoke(ctx, action_id, values)
    if action_id == "wallhaven_plus_sign_in" then
        session.sign_in(ctx, values and values.api_key)
    elseif action_id == "wallhaven_plus_sign_out" then
        session.sign_out()
    else
        error("unsupported Wallhaven Plus action")
    end
end

M.discover = discover
M.source = source
M.wallpaper = wallpaper

return M
