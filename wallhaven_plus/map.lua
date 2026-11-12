local M = {}

local function file_ext(path)
    if type(path) ~= "string" then
        return "jpg"
    end
    local ext = string.lower(path:match("%.([%w]+)$") or "")
    if ext == "jpg" or ext == "jpeg" or ext == "png" or ext == "webp" then
        return ext
    end
    return "jpg"
end

local function safe_id(value)
    local id = tostring(value or ""):gsub("[^%w_-]", "_")
    if id == "" then
        return "wallpaper"
    end
    return id:sub(1, 64)
end

local function tags_from_detail(detail)
    local out = {}
    for _, tag in ipairs(detail.tags or {}) do
        if tag.name and tag.name ~= "" then
            table.insert(out, tag.name)
        end
    end
    return out
end

local function rating(purity)
    if purity == "nsfw" then
        return "Mature"
    end
    if purity == "sketchy" then
        return "Questionable"
    end
    if purity == "sfw" then
        return "Everyone"
    end
    -- An unknown/missing rating must not be treated as safe for work.
    return "Mature"
end

local function uploader_name(detail)
    local uploader = detail.uploader
    if type(uploader) ~= "table" then
        return ""
    end
    return uploader.username or ""
end

local function uploader_avatar(detail)
    local uploader = detail.uploader
    if type(uploader) ~= "table" or type(uploader.avatar) ~= "table" then
        return ""
    end
    local avatar = uploader.avatar
    return avatar["128px"] or avatar["200px"] or avatar["32px"] or avatar["20px"] or ""
end

local function title(item)
    if item.id and item.id ~= "" then
        return "Wallhaven " .. item.id
    end
    return item.url or item.path or "Wallhaven"
end

function M.search_item(item)
    local thumbs = item.thumbs or {}
    return {
        id = item.id or "",
        title = title(item),
        preview_url = thumbs.original or thumbs.large or thumbs.small or item.path or "",
        author = "",
        wp_type = "image",
        width = item.dimension_x,
        height = item.dimension_y,
        extra = {
            resolution = item.resolution or "",
            purity = item.purity or "",
        },
    }
end

function M.details(detail)
    local description = detail.source or detail.url or ""
    return {
        author = uploader_name(detail),
        author_avatar_url = uploader_avatar(detail),
        description = description,
        size = tostring(detail.file_size or ""),
        width = detail.dimension_x,
        height = detail.dimension_y,
        tags = tags_from_detail(detail),
        web_url = detail.url or "",
        extra = {
            url = detail.url or "",
            path = detail.path or "",
            purity = detail.purity or "",
            resolution = detail.resolution or "",
        },
    }
end

function M.download(detail)
    local ext = file_ext(detail.path or "")
    local thumbs = detail.thumbs or {}
    return {
        wp_type = "image",
        url = detail.path or "",
        filename = "wallhaven-" .. safe_id(detail.id) .. "." .. ext,
        title = title(detail),
        preview_url = thumbs.original or thumbs.large or thumbs.small or "",
        description = detail.source or detail.url or "",
        tags = tags_from_detail(detail),
        external_id = tostring(detail.id or ""),
        web_url = detail.url or "",
        size = detail.file_size,
        width = detail.dimension_x,
        height = detail.dimension_y,
        content_rating = rating(detail.purity),
    }
end

return M
