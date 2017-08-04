SOURCES := $(shell find -type f -name '*.moon')
LUAOUT := $(SOURCES:.moon=.lua)

.PHONY: all run build clean

all: run

build: $(LUAOUT)

clean: 
	rm -vfr $(LUAOUT)

%.lua: %.moon
	moonc $<

run: build
	luajit init.lua

doc: build
	ldoc -q nm
