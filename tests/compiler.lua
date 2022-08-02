local chalk = require("../chalk.lua")

local function assert(condition, message)
    if not condition then
        error(message)
    end
end

do
    local EXPECTED = "\27[31mTEST\27[0m"
    local OUTPUT = chalk.compile("red")("TEST")

    assert(EXPECTED == OUTPUT, "Basic color compiling failed")
end

do
    local EXPECTED = "\27[31;32;102mTEST\27[0m"
    local OUTPUT = chalk.compile("red green bgGreenBright")("TEST")

    assert(EXPECTED == OUTPUT, "Chained color compiling failed")
end

do
    local EXPECTED = chalk.red.bgWhiteBright("TEST")
    local OUTPUT = chalk.compile("red bgWhiteBright")("TEST")

    assert(EXPECTED == OUTPUT, "Mismatch between compiled style and chained style")
end

print("All compiler checks passed")