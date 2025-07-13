package = "assimp"
version = "dev-1"

source = {
  url = "git://github.com/nesktf/assimp-lua.git"
}

description = {
  summary = "Lua assimp bindings using LuaJIT & FFI",
  license = "MIT",
  maintainer = "nesktf <nesktf@proton.me>"
}

dependencies = {
  "lua == 5.1",
  "fennel",
}

build = {
  type = "builtin",
  modules = {
    ["assimp"] = "build/assimp/init.lua",
    ["assimp.lib"] = "build/assimp/lib.lua",
    ["assimp.vecmath"] = "build/assimp/vecmath.lua",
  }
}
