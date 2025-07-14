# assimp
LuaJIT bindings for the [Open-Asset-Importer-Library](https://www.assimp.org), using the
builtin FFI.

Tested on ASSIMP 5.2.5 from the Debian 12 repos, may or may not work on other versions.

## Instalation
You need to have installed both LuaJIT and ASSIMP. On Debian:
```sh
$ sudo apt install luajit libassimp-dev
```

Add the repo path to your fennel `package.path`, or compile the source files running the makefile
and then add them to your lua `package.path`. If you want, you can also install the
library using luarocks
```sh
$ make build # Compile the fennel files
$ make install # Install locally using luarocks
```

## Usage
Just `require` the library and run `import_file` you can use either
the gc or nogc version. You have to free the scene if you use the nogc one.

```lua
local assimp = require("assimp")

local scene, err = assimp.import_file("my_funny_model.gltf")
local scenenogc = assimp.import_file_nogc("my_other_funny_model.obj", 0) -- Can pass import flags
-- Do things...
assimp.release_import(scenenogc)
```

Or if you are using fennel
```fennel
(local assimp (require :assimp))
(local (scene err) (assimp.import_file "my_funny_model.gltf"))
(local scenenogc (assimp.import_file_nogc("my_other_funny_model.obj" 0)))
;; Do things...
(assimp.release_import scenenogc)
```

You can access the scene object just like a regular `Assimp::Importer` C++ object. Most methods
should be available using `snake_case` identifiers, other members keep the same name.

Keep in mind that `aiString` objects have to be converted to Lua strings using `ffi.string`.

```lua 
if (scene:has_meshes()) then
    local koishi_hat = scene.mMeshes[0]
    local name = ffi.string(koishi_hat.mName.data, koishi_hat.mName.length)
    print(string.format("Mesh name: %s\n", name))
end
```

If you are using fennel
```fennel 
(when (scene:has_meshes)
  (let [koishi-hat (. scene.mMeshes 0)
        name (ffi.string koishi-hat.mName.data koishi-hat.mName.length)]
    (print (string.format "Mesh name: %s\n" name))))
```

## TODO
- Assimp enums
- Implement all object methods
- Tests
- Utility functions?
