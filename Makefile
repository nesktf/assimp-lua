FNLC := fennel -c
BUILDDIR := build/assimp/
ROCKSPEC := assimp-dev-1.rockspec
SRCFILES := $(wildcard assimp/*.fnl)
LUAFILES := $(subst .fnl,.lua,$(SRCFILES))

.PHONY: build clean install
build: $(LUAFILES)

install: $(LUAFILES)
	luarocks --lua-version=5.1 make --local $(ROCKSPEC)

%.lua: %.fnl $(BUILDDIR)
	$(FNLC) $< > build/$@

$(BUILDDIR):
	mkdir -p $@

clean:
	rm -rf build/
