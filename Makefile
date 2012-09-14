default: build

# directories
LIB = lib
TEST = test
SRC = src
PUBLIC = $(TEST)/public
BIN = bin

# files
BIN_SRC_FILE = $(BIN)/pegcoffee.coffee
BIN_OUT_FILE = $(BIN)/pegcoffee.js

# commands
COFFEE = node_modules/coffee-script/bin/coffee
PEGJS = node_modules/pegjs/bin/pegjs
MOCHA = node_modules/mocha/bin/mocha --compilers coffee:coffee-script -u tdd
MINIFIER = node_modules/uglify-js/bin/uglifyjs --no-copyright --mangle-toplevel --reserved-names require,module,exports,global,window
HTTP_SERVER = node_modules/http-server/bin/http-server -p 3000
NPM = npm
ECHO_NODE = echo "\#!/usr/bin/env node"

build: 
	$(COFFEE) -c -o $(LIB) $(SRC)
	$(COFFEE) -c $(BIN)
	# Add the shebang to the bin file
	$(ECHO_NODE)|cat - $(BIN_OUT_FILE) > $(BIN)/tmp 
	mv $(BIN)/tmp $(BIN_OUT_FILE)
	chmod u+x $(BIN_OUT_FILE)


build-browser: build
	cp $(LIB)/pegjs-coffee-plugin.js $(PUBLIC)/pegjs-coffee-plugin.js
	$(COFFEE) -c -o $(PUBLIC) $(TEST)

#minify: $(LIBMIN)

install: 
	$(NPM) install


test: build
	$(MOCHA) --ignore-leaks

test-browser: build-browser
	$(HTTP_SERVER) $(PUBLIC)
	open "http://localhost:3000"

.PHONY: test test-browser build build-browser
.SILENT: test test-browser build build-browser
