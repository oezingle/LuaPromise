> [!WARNING]
> This repository is archived. I've re-written Promises for [YAPP](https://github.com/lua-plus/yapp), exported as yapp.class.Promise

# LuaPromise

This project comes from [this Gist](https://gist.github.com/oezingle/f3c37eb6fc19326b836d86e21166a9d8), which is also my code

LuaPromise aims to provide functionality similar to JavaScript's promises in Lua, allowing you to simplify async data flows and scrap the callback soup. You have to bring your own event loop, though synchronous code also works perfectly well with Promises.

## Existing (Probably Better) Solutions 

The idea of Promises in Lua isn't new. If one of these libraries would work better for you, use it:
 - [Billiam/promise.lua](https://github.com/Billiam/promise.lua)
 - [zserge/lua-promises](https://github.com/zserge/lua-promises)
 - [evaera/roblox-lua-promise](https://github.com/evaera/roblox-lua-promise)


## Installing
 - Clone this repository
 - See [Building and Testing](#building-and-testing)

## Usage

```lua
local Promise = require("Promise")
```

### Creating a promise: 
```lua
Promise(function (resolve, reject) 
    local success = true

    if success then
        resolve("Value1", "Value2")
    else
        reject("Failure!")
    end
end)
```
### Chaining Promises
```lua
Promise.resolve("Value1", "Value2")
    :after(function (value1, value2)
        ...
    end)
```
### Nesting Promises
```lua
Promise.resolve()
    :after(function ()
        return Promise.resolve("Hello World!")
    end)
    :after(function(message)
        print(message)
    end)
```

### Using an Array of Promises
```lua
Promise.all({
    Promise.resolve("Hello!")
    Promise.resolve("Hola!")
})
    :after(function (values)
        -- Promise.all's resulting value is a table of tables.
        -- in other words, an any[][]
        for _, value in ipairs(values) do
            print(value[1])
        end
    end)
```

### Catching errors with `Promise:catch()`
```lua
Promise.resolve()
    :after(function ()
        error("I did something stupid!")
    end)
    :after(function ()
        -- this function won't get called, but automatically passes the error down
    end)
    :catch(function (err)
        print(err)
    end)
```


## Building and Testing

### Building

Install to the user's luarocks directory:
```
luarocks make --local
```

Install globally
```
luarocks make
```

Both of these options provide the module `Promise`


### Testing
```
lua test.lua
```

## Tests:
```
✔ Promise - 7 tests
         ✔ Promise()
         ✔ Promise.resolve()
         ✔ Promise.resolve(<value>)
         ✔ Promise.reject()
         ✔ Promise:after() throws an error
         ✔ Promise nesting
         ✔ Promise.all()
```
I also ran some (now removed, sorry!) async tests under [AwesomeWM](https://github.com/awesomeWM/awesome)
```
         ✔ Async Promise
         ✔ Async Promise Rejection
         ✔ Async Promise Nesting
         ✔ Async Promise.all()

```
Async tests were completed using Awesome's `awful.spawn.easy_async()`. Note that **LuaPromise doesn't provide an event loop**, so an asynchronous function won't work in a standard lua runtime 

# Disparities
 - Synchronous JS Promises are inserted into the event loop, but Lua doesn't have an event loop to insert into
 - Promises are still just tables
    - To check if an instance is a Promise, check its metatable __index: 
        ```lua
        local is_promise = getmetatable(maybe_promise).__index == Promise
        ```
    - Private members are only obfuscated by the `_private` subtable. I'm leaving it up to you to not abuse it.
