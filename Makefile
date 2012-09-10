default: build

# directories
LIB = lib
TESTS = tests
SRC = src

# commands
COFFEE = node_modules/coffee-script/bin/coffee
PEGJS = node_modules/pegjs/bin/pegjs
MOCHA = node_modules/mocha/bin/mocha --compilers coffee:coffee-script -u tdd
MINIFIER = node_modules/uglify-js/bin/uglifyjs --no-copyright --mangle-toplevel --reserved-names require,module,exports,global,window

build: 
	$(COFFEE) -c -o $(LIB) $(SRC)

#minify: $(LIBMIN)

# TODO: build-browser
# TODO: test-browser


test: build
	$(MOCHA) 


.PHONY: test
