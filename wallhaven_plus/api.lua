local M = {}
local session = import("wallhaven_plus.session")

local API = "https://wallhaven.cc/api/v1"

local SORTS = {
    trend = { sorting = "toplist", topRange = "1M" },
    top3m = { sorting = "toplist", topRange = "3M" },
    top6m = { sorting = "toplist", topRange = "6M" },
    top1y = { sorting = "toplist", topRange = "1y" },
    recent = { sorting = "date_added" },
    views = { sorting = "views" },
    popular = { sorting = "favorites" },
    hot = { sorting = "hot" },
    random = { sorting = "random" },
}

local RESOLUTION_TAGS = {
    ["1280 x 720"] = "1280x720",
    ["1920 x 1080"] = "1920x1080",
    ["2560 x 1440"] = "2560x1440",
    ["3840 x 2160"] = "3840x2160",
    ["2560 x 1080"] = "2560x1080",
    ["3440 x 1440"] = "3440x1440",
    ["5120 x 1440"] = "5120x1440",
    ["3840 x 1080"] = "3840x1080",
    ["7680 x 2160"] = "7680x2160",
    ["1080 x 1920"] = "1080x1920",
    ["720 x 1280"] = "720x1280",
    ["1440 x 2560"] = "1440x2560",
}

local QUERY_TAGS = {
    Abstract = "abstract",
    Animal = "animal",
    Anime = "anime",
    Cartoon = "cartoon",
    Celebrities = "celebrity",
    CG = "cg",
    Cosplay = "cosplay",
    Cyberpunk = "cyberpunk",
    Fantasy = "fantasy",
    Game = "game",
    Girls = "girl",
    Guys = "guy",
    Landscape = "landscape",
    Medieval = "medieval",
    Memes = "meme",
    MMD = "mmd",
    Models = "model",
    Music = "music",
    Nature = "nature",
    ["Pixel art"] = "pixel art",
    Relaxing = "relaxing",
    Retro = "retro",
    ["Sci-Fi"] = "sci-fi",
    Sports = "sports",
    Technology = "technology",
    Vehicle = "vehicle",
}

M.filters = {
    {
        id = "categories",
        title = "Categories",
        type = "multi_select",
        options = {
            { value = "cat_general", label = "General" },
            { value = "cat_anime", label = "Anime" },
            { value = "cat_people", label = "People" },
        },
    },
    {
        id = "purity",
        title = "Purity",
        type = "multi_select",
        description = "Sketchy is suggestive; NSFW is explicit and requires a Wallhaven API key.",
        options = {
            { value = "SFW", label = "Safe for work" },
            { value = "Sketchy", label = "Suggestive (Sketchy)" },
            { value = "NSFW", label = "Explicit (NSFW)" },
        },
    },
    {
        id = "topics",
        title = "Topics",
        type = "multi_select",
        match_modes = { "any", "all" },
        default_match_mode = "any",
        options = {
            { value = "Abstract", label = "Abstract" },
            { value = "Animal", label = "Animal" },
            { value = "Anime", label = "Anime" },
            { value = "Cartoon", label = "Cartoon" },
            { value = "Celebrities", label = "Celebrities" },
            { value = "CG", label = "CG" },
            { value = "Cosplay", label = "Cosplay" },
            { value = "Cyberpunk", label = "Cyberpunk" },
            { value = "Fantasy", label = "Fantasy" },
            { value = "Game", label = "Game" },
            { value = "Girls", label = "Girls" },
            { value = "Guys", label = "Guys" },
            { value = "Landscape", label = "Landscape" },
            { value = "Medieval", label = "Medieval" },
            { value = "Memes", label = "Memes" },
            { value = "MMD", label = "MMD" },
            { value = "Models", label = "Models" },
            { value = "Music", label = "Music" },
            { value = "Nature", label = "Nature" },
            { value = "Pixel art", label = "Pixel art" },
            { value = "Relaxing", label = "Relaxing" },
            { value = "Retro", label = "Retro" },
            { value = "Sci-Fi", label = "Sci-Fi" },
            { value = "Sports", label = "Sports" },
            { value = "Technology", label = "Technology" },
            { value = "Vehicle", label = "Vehicle" },
        },
    },
    {
        id = "resolution",
        title = "Resolution",
        type = "multi_select",
        options = {
            { value = "1280 x 720", label = "1280 x 720" },
            { value = "1920 x 1080", label = "1920 x 1080" },
            { value = "2560 x 1440", label = "2560 x 1440" },
            { value = "3840 x 2160", label = "3840 x 2160" },
            { value = "2560 x 1080", label = "2560 x 1080" },
            { value = "3440 x 1440", label = "3440 x 1440" },
            { value = "5120 x 1440", label = "5120 x 1440" },
            { value = "3840 x 1080", label = "3840 x 1080" },
            { value = "7680 x 2160", label = "7680 x 2160" },
            { value = "1080 x 1920", label = "1080 x 1920" },
            { value = "720 x 1280", label = "720 x 1280" },
            { value = "1440 x 2560", label = "1440 x 2560" },
        },
    },
}

local function append_query(query, term)
    if not term or term == "" then
        return query
    end
    if query == "" then
        return term
    end
    return query .. " " .. term
end

local function request_json(ctx, url, query)
    local rsp = ctx.http:get(url)
        :headers(session.headers())
        :query(query)
        :timeout(20)
        :send()
    if rsp:status() == 401 or rsp:status() == 403 then
        session.sign_out()
        error("Wallhaven API key was rejected; log in again")
    end
    if not rsp:ok() then
        error("wallhaven http " .. tostring(rsp:status()))
    end
    return rsp:json()
end

local function purity_string(tags)
    local sfw, sketchy, nsfw = false, false, false
    local selected = false
    for _, tag in ipairs(tags) do
        if tag == "SFW" then
            sfw = true
            selected = true
        elseif tag == "Sketchy" then
            sketchy = true
            selected = true
        elseif tag == "NSFW" then
            nsfw = true
            selected = true
        end
    end
    if not selected then
        sfw = true
    end
    if nsfw and not session.authenticated() then
        error("Log in to Wallhaven with an API key to browse NSFW wallpapers")
    end
    return (sfw and "1" or "0") .. (sketchy and "1" or "0") .. (nsfw and "1" or "0")
end

local random_state = { key = nil, seed = nil }

local function make_seed()
    local ok, value = pcall(function()
        return os and os.time and os.time() or nil
    end)
    if ok and type(value) == "number" then
        return string.format("%06x", value % 0xFFFFFF)
    end
    return "wwplus"
end

local function random_seed(params)
    local tags = params.tags or {}
    local key = table.concat({ params.query or "", params.sort or "", table.concat(tags, ",") }, "|")
    if random_state.key ~= key then
        random_state.key = key
        random_state.seed = make_seed()
    end
    return random_state.seed
end

function M.search(ctx, params)
    params = params or {}
    local query = params.query or ""
    local tags = params.tags or {}
    local match_modes = params.filter_match_modes or {}
    local purity = purity_string(tags)

    -- Power-user collection browsing:
    --   collection:<username>/<collection id>
    local username, collection_id = query:match("^%s*collection:([%w_%-%.]+)/(%d+)%s*$")
    if username then
        return request_json(ctx, API .. "/collections/" .. username .. "/" .. collection_id, {
            page = tostring(params.page or 1),
            purity = purity,
        })
    end

    local sort = SORTS[params.sort] or SORTS.recent
    local resolutions = {}
    local general, anime, people = false, false, false
    local category_selected = false
    local topic_mode = match_modes.topics
    local topics = {}

    -- Explicit category filter (General / Anime / People).
    for _, tag in ipairs(tags) do
        if tag == "cat_general" then
            general = true
            category_selected = true
        elseif tag == "cat_anime" then
            anime = true
            category_selected = true
        elseif tag == "cat_people" then
            people = true
            category_selected = true
        end
    end
    if not category_selected then
        general, anime, people = true, true, true
    end

    for _, tag in ipairs(tags) do
        if tag == "SFW" or tag == "Sketchy" or tag == "NSFW" then
            -- Purity is handled above.
        elseif tag == "cat_general" or tag == "cat_anime" or tag == "cat_people" then
            -- Categories are handled above.
        elseif not category_selected and not topic_mode and tag == "Anime" then
            general, anime, people = false, false, false
            category_selected = true
            anime = true
        elseif not category_selected and not topic_mode and (tag == "Girls" or tag == "Guys") then
            general, anime, people = false, false, false
            category_selected = true
            people = true
        end

        local resolution = RESOLUTION_TAGS[tag]
        if resolution then
            table.insert(resolutions, resolution)
        end

        local topic = QUERY_TAGS[tag]
        if topic and topic_mode then
            if topic:find("%s") then
                topic = '"' .. topic:gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
            end
            table.insert(topics, "+" .. topic)
        elseif topic then
            query = append_query(query, topic)
        end
    end

    if #topics > 0 then
        if query:match("%f[%w]id:%d+") then
            error("Wallhaven exact tag searches cannot be combined with Topics")
        end
        local expression = "(" .. table.concat(topics, topic_mode == "any" and " | " or " ") .. ")"
        query = query == "" and expression or "(" .. query .. ") " .. expression
    end

    local q = {
        q = query,
        categories = (general and "1" or "0") .. (anime and "1" or "0") .. (people and "1" or "0"),
        purity = purity,
        sorting = sort.sorting,
        order = "desc",
        page = tostring(params.page or 1),
    }
    if sort.topRange then
        q.topRange = sort.topRange
    end
    if #resolutions > 0 then
        q.resolutions = table.concat(resolutions, ",")
    end
    if sort.sorting == "random" then
        q.seed = random_seed(params)
    end

    return request_json(ctx, API .. "/search", q)
end

function M.wallpaper(ctx, id)
    local payload = request_json(ctx, API .. "/w/" .. tostring(id), {})
    return payload.data or {}
end

return M
