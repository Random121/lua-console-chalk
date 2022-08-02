local string = string
local table = table
local type = type
local rawget = rawget
local error = error
local tostring = tostring
local setmetatable = setmetatable


-- SGR parameters: https://w.wiki/3PvB
-- SGR colors: https://w.wiki/5XYa
local SGR_PARAMETERS = {
    -- MODIFIERS
    reset = 0,
    bold = 1,
    dim = 2,
    italic = 3,
    underline = 4,
    invert = 7,
    hide = 8,
    strike = 9,

    -- FOREGROUND COLORS
    black = 30,
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    white = 37,

    -- bright colors
    blackBright = 90,
    gray = 90, -- alias for blackBright
    grey = 90, -- alias for blackBright
    redBright = 91,
    greenBright = 92,
    yellowBright = 93,
    blueBright = 94,
    magentaBright = 95,
    cyanBright = 96,
    whiteBright = 97,

    -- BACKGROUND COLORS
    bgBlack = 40,
    bgRed = 41,
    bgGreen = 42,
    bgYellow = 43,
    bgBlue = 44,
    bgMagenta = 45,
    bgCyan = 46,
    bgWhite = 47,

    -- bright colors
    bgBlackBright = 100,
    bgGray = 100, -- alias for bgBlackBright
    bgGrey = 100, -- alias for bgBlackBright
    bgRedBright = 101,
    bgGreenBright = 102,
    bgYellowBright = 103,
    bgBlueBright = 104,
    bgMagentaBright = 105,
    bgCyanBright = 106,
    bgWhiteBright = 107,
}


--#region utility functions

local function string_split(str, seperator)
    -- default to whitespace
    seperator = seperator or "%s"

    local pattern = "[^" .. seperator .. "]+"
    local parts = {}

    for part in string.gmatch(str, pattern) do
        parts[#parts+1] = part
    end

    return parts
end

local function formatError(formatMessage, ...)
    local formatted = string.format(formatMessage, ...)

    -- specify level two so error points to
    -- where this function was called
    return error(formatted, 2)
end

--#endregion


-- control sequence: https://w.wiki/3PvE
local CSI = "\027["
local SGR_FORMAT = CSI .. "%sm"

local function getSGR(parameters)
    return string.format(SGR_FORMAT, parameters)
end

-- error messages
local CHALK_INVALID_KEY_ERR = "[CHALK] Key %s is not valid"
local COMPILER_INVALID_KEY_ERR = "[CHALK COMPILER] Key %s is not valid"
local COMPILER_STYLE_STRING_TYPE = "[CHALK COMPILER] Style string must be type string"

local CHALK_CORE_METATABLE = {}
do
    local SGR_RESET_PARAM = getSGR(SGR_PARAMETERS.reset)

    function CHALK_CORE_METATABLE:__index(key)
        local param = SGR_PARAMETERS[key]

        if param ~= nil then
            local accumulator = rawget(self, "styleAccumulator")

            if #accumulator ~= 0 then
                table.insert(accumulator, ";")
            end

            table.insert(accumulator, param)

            return self
        end

        formatError(CHALK_INVALID_KEY_ERR, tostring(key))
    end

    function CHALK_CORE_METATABLE:__call(text)
        local accumulator = rawget(self, "styleAccumulator")
        local styleSGR = getSGR(table.concat(accumulator))

        return styleSGR .. tostring(text) .. SGR_RESET_PARAM
    end

    CHALK_CORE_METATABLE.__metatable = "This metatable is locked"
end

local function createChalk(initialStyles)
    initialStyles = initialStyles or {}

    local chalkClass = {
        styleAccumulator = initialStyles,
    }

    return setmetatable(chalkClass, CHALK_CORE_METATABLE)
end

local function chalkCompiler(styleString)
    if type(styleString) ~= "string" then
        formatError(COMPILER_STYLE_STRING_TYPE)
    end

    local styles = string_split(styleString)
    local newAccumulator = {}

    local style = nil
    local param = nil
    for i = 1, #styles do
        style = styles[i]
        param = SGR_PARAMETERS[style]

        if param ~= nil then
            table.insert(newAccumulator, param)
            table.insert(newAccumulator, ";")
        else
            formatError(COMPILER_INVALID_KEY_ERR, style)
        end
    end

    -- remove the last semicolon as
    -- it would break the SGR sequence
    table.remove(newAccumulator)

    return createChalk(newAccumulator)
end

local CHALK_EXPORT_METATABLE = {}
do
    function CHALK_EXPORT_METATABLE:__index(key)
        if key == "compile" then
            return chalkCompiler
        end

        return createChalk()[key]
    end

    CHALK_EXPORT_METATABLE.__metatable = "This metatable is locked"
end

local chalk = setmetatable({}, CHALK_EXPORT_METATABLE)

return chalk