default: build

# directories
LIB = lib
TEST = test
SRC = src
PUBLIC = $(TEST)/public

# commands
COFFEE = node_modules/coffee-script/bin/coffee
PEGJS = node_modules/pegjs/bin/pegjs
MOCHA = node_modules/mocha/bin/mocha --compilers coffee:coffee-script -u tdd
MINIFIER = node_modules/uglify-js/bin/uglifyjs --no-copyright --mangle-toplevel --reserved-names require,module,exports,global,window
HTTP_SERVER = node_modules/http-server/bin/http-server -p 3000
NPM = npm

build: 
	$(COFFEE) -c -o $(LIB) $(SRC)

build-browser: build
	cp $(LIB)/peg-coffee.js $(PUBLIC)/peg-coffee.js
	$(COFFEE) -c -o $(PUBLIC) $(TEST)/peg-coffee-test.coffee

#minify: $(LIBMIN)

install: 
	$(NPM) install


test: build
	$(MOCHA) --ignore-leaks

test-browser: build-browser
	$(HTTP_SERVER) $(PUBLIC)

.PHONY: test test-browser build build-browser
.SILENT: test test-browser build build-browser
