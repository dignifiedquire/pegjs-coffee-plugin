default: build
# ===== Directories =====

TEST_DIR      = test
PUBLIC_DIR    = $(TEST_DIR)/public
BIN_DIR       = node_modules/.bin
DIST_DIR      = dist

# ===== Files =====

VERSION_FILE = VERSION

PEGCOFFEE_DIST_FILE_DEV = $(DIST_DIR)/pegjs-coffee-plugin-$(VERSION).js
PEGCOFFEE_DIST_FILE_MIN = $(DIST_DIR)/pegjs-coffee-plugin-$(VERSION).min.js

LICENSE_FILE = LICENSE
CHANGELOG_FILE = CHANGELOG.md
README_FILE = README.md

# ===== Executables =====

MOCHA         = $(BIN_DIR)/mocha --compilers coffee:coffee-script -u tdd
HTTP_SERVER   = $(BIN_DIR)/http-server -p 3000
JSHINT        = $(BIN_DIR)/jshint
UGLIFYJS      = $(BIN_DIR)/uglifyjs
BROWSERIFY    = $(BIN_DIR)/browserify

# ===== Variables =====

VERSION = `cat $(VERSION_FILE)`

build:
	$(BROWSERIFY) --standalone "PEGjs-coffee-plugin" -o $(PEGCOFFEE_DIST_FILE_DEV) index.js

test:
	$(MOCHA) --ignore-leaks

test-browser: build
	cp $(PEGCOFFEE_DIST_FILE_DEV) $(PUBLIC_DIR)/pegjs-coffee-plugin.js
	$(HTTP_SERVER) $(TEST_DIR)
	open "http://localhost:3000"


# Prepare dstribution files
dist: build
	# Web
	$(UGLIFYJS) --ascii -o $(PEGCOFFEE_DIST_FILE_MIN) $(PEGCOFFEE_DIST_FILE_DEV)

# Remove distribution file (created by "dist")
distclean:
	rm -rf $(DIST_DIR)


.PHONY: test test-browser build dist distclean
.SILENT: test test-browser build dist distclean
