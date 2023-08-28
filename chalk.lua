
--#region CONSTANTS

-- control sequence introducer: https://w.wiki/3PvE
local CSI = "\27["

-- SGR parameters: https://w.wiki/3PvB
-- SGR colors: https://w.wiki/5XYa
local SGR_PARAMETERS = {
    -- MODIFIERS
    reset = 0,
    bold = 1,
    dim = 2,
    italic = 3,
    underline = 4,
    overline = 53,
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

    -- BRIGHT FOREGROUND COLORS
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

    -- BRIGHT BACKGROUND COLORS
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

local ERRORS = {
    CHALK_INVALID_KEY = "[CHALK] Key %s is not valid",
    COMPILER_INVALID_KEY = "[CHALK COMPILER] Key %s is not valid",
    COMPILER_WRONG_STYLE_TYPE = "[CHALK COMPILER] Style string must be type string",
}

--#endregion


--#region UTILITY FUNCTIONS

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

--#endregion


--#region CHALK UTILITY FUNCTIONS

---Gets a SGR string with the specific parameters
---@param parameters string
local function getSGR(parameters)
    return CSI .. parameters .. "m"
end

---Raises an error with the specified error message format
---@param errorMessage string Error message format
local function formattedError(errorMessage, ...)
    local formatted = string.format(errorMessage, ...)

    -- specify level two so error points to
    -- where this function was called
    return error(formatted, 2)
end

--#endregion

---@class Chalk
---@field styleAccumulator string[]
local Chalk = {}
Chalk.__index = Chalk

do
    -- improves performance by a bit as it is used a lot
    local SGR_RESET = getSGR(SGR_PARAMETERS.reset)

    ---Creates a new chalk object
    ---@param initialStyles? string[]
    ---@return Chalk
    function Chalk.new(initialStyles)
        initialStyles = initialStyles or {}

        local chalkObject = {
            styleAccumulator = initialStyles,
        }

        return setmetatable(chalkObject, Chalk)
    end

    ---Adds a new style to chalk
    ---@param key any
    ---@return Chalk
    function Chalk:__index(key)
        local parameter = SGR_PARAMETERS[key]

        if parameter == nil then
            formattedError(ERRORS.CHALK_INVALID_KEY, tostring(key))
        end

        ---@type string[]
        local accumulator = rawget(self, "styleAccumulator")

        table.insert(accumulator, parameter)

        return self
    end

    ---Formats the text using the stored styles
    ---@param text string
    ---@return string
    function Chalk:__call(text)
        ---@type string[]
        local accumulator = rawget(self, "styleAccumulator")

        local styleString = table.concat(accumulator, ";")
        local styleSGR = getSGR(styleString)

        return styleSGR .. tostring(text) .. SGR_RESET
    end

    Chalk.__metatable = "This metatable is locked"
end

---Creates a new chalk object based on the style string
---@param styleString string
---@return Chalk
local function chalkCompile(styleString)
    if type(styleString) ~= "string" then
        formattedError(ERRORS.COMPILER_WRONG_STYLE_TYPE)
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
        else
            formattedError(ERRORS.COMPILER_INVALID_KEY, style)
        end
    end

    return Chalk.new(newAccumulator)
end

---@class ChalkExport
local ChalkExport = {}

do
    ---Wrapper for chalk and chalk compiler
    ---@param key string
    ---@return Chalk | function
    function ChalkExport:__index(key)
        if key == "compile" then
            return chalkCompile
        end

        return Chalk.new()[key]
    end

    ChalkExport.__metatable = "This metatable is locked"
end

return setmetatable({}, ChalkExport)