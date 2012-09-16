default: build
# ===== Directories =====

LIB_DIR = lib
TEST_DIR = test
SRC_DIR = src
PUBLIC_DIR = $(TEST_DIR)/public
BIN_DIR = bin
DIST_DIR      = dist
DIST_WEB_DIR  = $(DIST_DIR)/web
DIST_NODE_DIR = $(DIST_DIR)/node

# ===== Files =====

BIN_SRC_FILE = $(BIN_DIR)/pegcoffee.coffee
BIN_OUT_FILE = $(BIN_DIR)/pegcoffee.js

PEGCOFFEE_SRC_FILE = $(SRC_DIR)/pegjs-coffee-plugin.coffee
PEGCOFFEE_LIB_FILE = $(LIB_DIR)/pegjs-coffee-plugin.js

PACKAGE_JSON_SRC_FILE  = package.json
PACKAGE_JSON_DIST_FILE = $(DIST_NODE_DIR)/package.json

PEGCOFFEE_DIST_FILE_DEV = $(DIST_WEB_DIR)/pegjs-coffee-plugin-$(VERSION).js
PEGCOFFEE_DIST_FILE_MIN = $(DIST_WEB_DIR)/pegjs-coffee-plugin-$(VERSION).min.js

LICENSE_FILE = LICENSE
VERSION_FILE = VERSION
CHANGELOG_FILE = CHANGELOG.md
README_FILE = README.md

# ===== Executables =====

COFFEE = node_modules/coffee-script/bin/coffee
PEGJS = node_modules/pegjs/bin/pegjs
MOCHA = node_modules/mocha/bin/mocha --compilers coffee:coffee-script -u tdd
HTTP_SERVER = node_modules/http-server/bin/http-server -p 3000
NPM = npm
JSHINT        = jshint
UGLIFYJS      = uglifyjs

ECHO_NODE = echo "\#!/usr/bin/env node"

# ===== Variables =====

VERSION = `cat $(VERSION_FILE)`

# ===== Preprocessor =====

# A simple preprocessor that recognizes two directives:
#
#   @VERSION          -- insert version
#   @include "<file>" -- include <file> here
#
# This could have been implemented many ways. I chose Perl because everyone will
# have it.
PREPROCESS=perl -e '                                                           \
  use strict;                                                                  \
  use warnings;                                                                \
                                                                               \
  use File::Basename;                                                          \
                                                                               \
  open(my $$f, "$(VERSION_FILE)") or die "Can\x27t open $(VERSION_FILE): $$!"; \
  my $$VERSION = <$$f>;                                                        \
  close($$f);                                                                  \
  chomp($$VERSION);                                                            \
                                                                               \
  sub preprocess {                                                             \
    my $$file = shift;                                                         \
    my $$output = "";                                                          \
                                                                               \
    open(my $$f, $$file) or die "Can\x27t open $$file: $$!";                   \
    while(<$$f>) {                                                             \
      s/\@VERSION/$$VERSION/g;                                                 \
                                                                               \
      if (/^\s*\/\/\s*\@include\s*"([^"]*)"\s*$$/) {                           \
        $$output .= preprocess(dirname($$file) . "/" . $$1);                   \
        next;                                                                  \
      }                                                                        \
                                                                               \
      $$output .= $$_;                                                         \
    }                                                                          \
    close($$f);                                                                \
                                                                               \
    return $$output;                                                           \
  }                                                                            \
                                                                               \
  print preprocess($$ARGV[0]);                                                 \
'

build: 
	$(COFFEE) -c -o $(LIB_DIR) $(SRC_DIR)
	$(PREPROCESS) $(PEGCOFFEE_LIB_FILE) > $(PEGCOFFEE_LIB_FILE).tmp
	mv $(PEGCOFFEE_LIB_FILE).tmp $(PEGCOFFEE_LIB_FILE)
	$(COFFEE) -c $(BIN_DIR)
	# Add the shebang to the bin file
	$(ECHO_NODE)|cat - $(BIN_OUT_FILE) > $(BIN_DIR)/tmp 
	mv $(BIN_DIR)/tmp $(BIN_OUT_FILE)
	chmod u+x $(BIN_OUT_FILE)


build-browser: build
	cp $(PEGCOFFEE_LIB_FILE) $(PUBLIC_DIR)/pegjs-coffee-plugin.js
	$(COFFEE) -c -o $(PUBLIC_DIR) $(TEST_DIR)


install: 
	$(NPM) install


test: build
	$(MOCHA) --ignore-leaks

test-browser: build-browser
	$(HTTP_SERVER) $(PUBLIC_DIR)
	open "http://localhost:3000"


# Prepare dstribution files
dist: build
	# Web
	mkdir -p $(DIST_WEB_DIR)
	cp $(PEGCOFFEE_LIB_FILE) $(PEGCOFFEE_DIST_FILE_DEV)
	$(UGLIFYJS) --ascii -o $(PEGCOFFEE_DIST_FILE_MIN) $(PEGCOFFEE_LIB_FILE)

	# Node.js
	mkdir -p $(DIST_NODE_DIR) $(DIST_NODE_DIR)/bin
	cp -r                 \
	  $(LIB_DIR)          \
	  $(EXAMPLES_DIR)     \
	  $(CHANGELOG_FILE)   \
	  $(LICENSE_FILE)     \
	  $(README_FILE)      \
	  $(VERSION_FILE)     \
	  $(DIST_NODE_DIR)
	cp $(BIN_OUT_FILE) $(DIST_NODE_DIR)/bin/
	$(PREPROCESS) $(PACKAGE_JSON_SRC_FILE) > $(PACKAGE_JSON_DIST_FILE)

# Remove distribution file (created by "dist")
distclean:
	rm -rf $(DIST_DIR)


.PHONY: test test-browser build build-browser dist distclean
.SILENT: test test-browser build build-browser dist distclean
