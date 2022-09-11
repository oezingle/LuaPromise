require("luarocks.loader")

local Promise = require("Promise")

-- TODO Promise.use_event_loop(loop|nil) - Promise relies on event loop - maybe even control it with global resolve counter?

---@class Array<T>: { [integer]: T }

---@alias SingleOrArray<T> T|Array<T>

--- Create a test callback wrapped around a function that might throw an error
---@param callback function
---@param name string?
---@return fun(): string, boolean, any
local function test(callback, name)
    return function()
        local success, ret = xpcall(function()
            callback()
        end, function(err)
            print(debug.traceback(err))

            -- passes to ret
            return err
        end)

        return name, success, ret
    end
end

---@enum TextColors
local text_colors = {
    RED    = "\27[31m",
    GREEN  = "\27[32m",
    YELLOW = "\27[33m",
    RESET  = "\27[0m",
}

---@param success boolean|nil
---@return string
local function success_get_color(success)
    if success == nil then
        return text_colors.YELLOW
    elseif success then
        return text_colors.GREEN
    else
        return text_colors.RED
    end
end

---@param success boolean|nil
---@return string
local function success_get_character(success)
    if success == nil then
        return "?"
    elseif success then
        return "✔"
    else
        return "✘"
    end
end

local function test_all(tests)
    local tests_count = 0
    local tests_passed = 0

    print("Running Module Tests:")

    local module_name = "Promise"

    local module_test_count = 0
    ---@type boolean|nil
    local module_all_tests_passed = true
    local module_tests = {}

    if type(tests) == "function" then
        tests = { tests }
    end

    if type(tests) == "table" then
        for _, test in ipairs(tests) do
            module_test_count = module_test_count + 1

            tests_count = tests_count + 1

            local name, success, ret = test()

            if success == nil and module_all_tests_passed ~= false then
                module_all_tests_passed = nil
            elseif success == false then
                module_all_tests_passed = false
                -- might be nil
            elseif success then
                tests_passed = tests_passed + 1
            end

            table.insert(module_tests, {
                success = success,
                name    = name or "[Unnamed test]",
                ret     = (ret ~= nil and tostring(ret) or "")
            })
        end
    else
        print(module_name .. ".__test has an unexpected type of " .. type(tests))
    end

    print(
        success_get_color(module_all_tests_passed) .. "     " ..
        success_get_character(module_all_tests_passed) ..
        " " .. text_colors.RESET .. module_name ..
        " - " .. tostring(module_test_count) .. " tests"
    )

    for _, test_result in ipairs(module_tests) do
        print(
            success_get_color(test_result.success) .. "         " ..
            success_get_character(test_result.success) ..
            " " .. text_colors.RESET .. test_result.name ..
            (
            test_result.success and "" or
                (" - " .. success_get_color(test_result.success) .. test_result.ret .. text_colors.RESET))
        )
    end

    local percent = math.floor((tests_passed / tests_count) * 100)

    print(tostring(percent) .. "% of tests passed")
end

-- TODO improve tests using this format:
--[[
    local testing_result = nil

    Promise.resolve()
        :after(function ()
            testing_result = "success"
        end)

    assert(testing_result)
]]

test_all({
    test(function()
        Promise(function(res)
            res("Hello?")
        end)
            :after(function(input)
                return input:gsub("?", "!")
            end)
            :after(function(input)
                assert(input)
            end)
    end, "Promise()"),

    test(function()
        Promise.resolve()
            :after(function()
                return "Promise test 2"
            end)
            :after(function(input)
                assert(input)
            end)
    end, "Promise.resolve()"),
    test(function()
        Promise.resolve("Hello")
            :after(function(input)
                assert(input)
            end)
    end, "Promise.resolve(<value>)"),

    test(function()
        Promise.reject("Testing!")
            :after(function()
                print("I shouldn't fire!")

                assert(false)
            end)
            :catch(function(value)
                assert(value == "Testing!")
            end)

        -- TODO fix this behavior
        --[[
            :catch(function()
                print("I shouldn't fire!")

                -- assert(false)
            end)
            ]]
    end, "Promise.reject()"),

    test(function()
        Promise.resolve()
            :after(function()
                error("Hello catch()")
            end)
            :after(function()
                -- Promise:chain has no-op functions by default, so :after silently includes a :catch handler
                print("I'm a rejection condiut test!")
            end)
            :catch(function(message)
                assert(message)
            end)
    end, "Promise:after() throws an error"),

    test(function()
        Promise.resolve()
            :after(function()
                return Promise.resolve("Hola")
            end)
            :after(function(input)
                assert(type(input) == "string")
            end)
    end, "Promise nesting"),

    test(function()
        Promise.all({
            Promise.resolve("Hello!"),
            Promise.resolve("Hola!"),
        })
            :after(function(values)
                assert(values[1][1] == "Hello!")
                assert(values[2][1] == "Hola!")
            end)
    end, "Promise.all()"),
})