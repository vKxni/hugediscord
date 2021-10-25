CRYSTAL_BIN ?= $(shell which crystal)

SOURCES := $(wildcard src/*.cr src/**/*.cr)

all: bin/gembot

bin/gembot: $(SOURCES)
	$(CRYSTAL_BIN) build -o bin/gembot src/cli.cr

clean:
	rm -rf .crystal bin/gembot

.PHONY: test
test:
	$(CRYSTAL_BIN) spec