#
#  test/peg-coffee-test.coffee
# 

# Load dependencies
if typeof require isnt 'undefined'
  # Node.js
  CoffeeScript = require 'coffee-script'
  expect = require 'expect.js'
  PEG = require 'pegjs'
  PEGCoffee = require '../lib/peg-coffee'
else
  # Browser
  CoffeeScript = global.CoffeeScript
  expect = global.expect
  PEG = global.PEG
  PEGCoffee = global.PEGCoffee


# Test suite for the plugin  
suite 'peg-coffee', ->
  setup ->
    PEGCoffee.initialize PEG
    
  suite 'initialize plugin', ->
    
    test 'adds pass to passes', ->
      passes = PEG.compiler.passes
      expect(passes).to.have.property 'compileFromCoffeeScript'
      
    test 'adds pass to appliedPassNames', ->
      appliedPassNames = PEG.compiler.appliedPassNames
      expectedPassNames = [
        'reportMissingRules'
        'reportLeftRecursion'
        'removeProxyRules'
        'compileFromCoffeeScript'
        'computeVarNames'
        'computeParams'
      ]
      expect(appliedPassNames).to.eql expectedPassNames

    test 'pass should only be added once', ->
      PEGCoffee.initialize PEG
      PEGCoffee.initialize PEG

      expect(PEG.compiler.appliedPassNames.length).to.equal 6

  suite 'compile grammar', ->

    test 'simple coffee script action', ->
      grammar = 'start = "a" { return "#{1+1}" }'
      parser = PEG.buildParser grammar
      result = parser.parse "a"
      expect(result).to.equal "2"
      
    test 'simple coffee script initializer', ->
      grammar = '''
        {
          val = "#{1+1}"
        }
        start
          = "a" { return val }
      '''
      parser = PEG.buildParser grammar
      result = parser.parse "a"
      expect(result).to.equal "2"
    