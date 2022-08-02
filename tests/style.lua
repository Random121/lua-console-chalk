local chalk = require("../chalk.lua")

local function assert(condition, message)
    if not condition then
        error(message)
    end
end

do
    local EXPECTED = "\27[31mABCDEFG\27[0m"
    local OUTPUT = chalk.red("ABCDEFG")

    assert(EXPECTED == OUTPUT, "Basic color styling failed")
end

do
    local EXPECTED = "\27[100mTEST\27[0m"
    local OUTPUT = chalk.bgBlackBright("TEST")

    assert(EXPECTED == OUTPUT, "Basic bg color styling failed")
end

do
    local EXPECTED = "\27[90mHELLO\27[0m"
    local OUTPUT1 = chalk.gray("HELLO")
    local OUTPUT2 = chalk.grey("HELLO")

    assert(OUTPUT1 == EXPECTED, "Gray color aliasing failed")
    assert(OUTPUT1 == EXPECTED, "Grey color aliasing failed")
end

do
    local EXPECTED = "\27[95;106;1mCHAINING\27[0m"
    local OUTPUT = chalk.magentaBright.bgCyanBright.bold("CHAINING")

    assert(OUTPUT == EXPECTED, "Style chaining failed")
end

print("All style tests passed")