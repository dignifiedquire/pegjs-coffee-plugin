fs = require "fs"

module.exports = (grunt) ->
  # ===== Directories =====

  TEST_DIR      = "test"
  PUBLIC_DIR    = "#{TEST_DIR}/public"
  BIN_DIR       = "node_modules/.bin"
  DIST_DIR      = "dist"

  # ===== Files =====

  VERSION_FILE = "VERSION"
  VERSION = fs.readFileSync(VERSION_FILE)

  PEGCOFFEE_DIST_FILE_DEV = "#{DIST_DIR}/pegjs-coffee-plugin-#{VERSION}.js"
  PEGCOFFEE_DIST_FILE_MIN = "#{DIST_DIR}/pegjs-coffee-plugin-#{VERSION}.min.js"

  LICENSE_FILE = "LICENSE"
  CHANGELOG_FILE = "CHANGELOG.md"
  README_FILE = "README.md"


  require("load-grunt-tasks")(grunt)
  grunt.registerTask "default", "build", ["build"]
  grunt.registerTask "build", "build", ["browserify"]
  grunt.registerTask "test", "test", ["mochaTest"]
  grunt.registerTask "test-browser" ,"test in browser", ["build", "copy:browser", "http-server"]
  grunt.registerTask "dist", "dist", ["build", "uglify"]
  grunt.registerTask "distclean", "dist clean", ["clean"]

  pkg = grunt.file.readJSON "package.json"
  grunt.initConfig
    pkg: pkg

    browserify:
      build:
        src: "index.js"
        dest: PEGCOFFEE_DIST_FILE_DEV
        options:
          browserifyOptions:
            standalone: "PEGjs-coffee-plugin"

    mochaTest:
      test:
        options:
          reporter: "spec"
          require: "coffee-script/register"
          ui: "tdd"
        src: ["test/*.js"]

    copy:
      browser:
        src: PEGCOFFEE_DIST_FILE_DEV
        dest: "#{PUBLIC_DIR}/pegjs-coffee-plugin.js"

    "http-server":
      "test-browser":
        root: TEST_DIR
        port: 3000
        host: "localhost"
        openBrowser: true

    uglify:
      dist:
        src: PEGCOFFEE_DIST_FILE_DEV
        dest: PEGCOFFEE_DIST_FILE_MIN
        options:
          ASCIIOnly: true

    clean:
      distclean: [DIST_DIR]