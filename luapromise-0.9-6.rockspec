package = "LuaPromise"
version = "0.9-6"
source = {
   url = "..." -- We don't have one yet
}
description = {
   summary = "JavaScript-like Promises for Lua.",
   detailed = [[
    Promises aim to improve your async workflows, 
    cutting out the callback soup often associated with async code
   ]],
   homepage = "http://...", -- We don't have one yet
   license = "GPL-3.0-or-later" -- or whatever you like
}
dependencies = {
   "lua >= 5.1 < 5.5"
   -- If you depend on other rocks, add them here
}
build = {
    type = "builtin",
    
    modules = {
      Promise = "src/Promise.lua",

      ["Promise.Class"] = "src/Class/init.lua",

      ["Promise.Class.is_instance"] = "src/Class/is_instance.lua",
    }
}