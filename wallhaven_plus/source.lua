local M = {}

local function safe_path(path)
    if type(path) ~= "string" or path == "" or path:sub(1, 1) ~= "/" then
        return false
    end
    if path:find("%z") then
        return false
    end
    for segment in path:gmatch("[^/]+") do
        if segment == ".." then
            return false
        end
    end
    return true
end

local function under_root(path, root)
    if type(root) ~= "string" or root == "" then
        return true
    end
    root = root:gsub("/+$", "")
    if root == "" then
        return true
    end
    return path == root or path:sub(1, #root + 1) == root .. "/"
end

function M.remove(ctx, item)
    item = item or {}
    local path = item.path
    if not path or path == "" then
        path = item.resource
    end
    if not path or path == "" then
        error("missing item path")
    end
    if not safe_path(path) then
        error("refusing to remove unsafe item path")
    end
    if not under_root(path, item.library_root) then
        error("refusing to remove item outside its library")
    end
    ctx.remove_file(path)
    ctx.remove_file(path .. ".json")
end

return M
