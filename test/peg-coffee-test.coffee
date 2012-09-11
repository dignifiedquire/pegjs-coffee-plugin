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
    suite 'simple CoffeeScript', ->
      test 'action', ->
        parser = PEG.buildParser 'start = "a" { return "#{1+1}" }'
        expect(parser.parse "a").to.equal "2"
        
      test 'initializer', ->
        parser = PEG.buildParser '''
          {
            val = "#{1+1}"
          }
          start
            = "a" { return val }
        '''
        expect(parser.parse "a").to.equal "2"

      suite 'predicates', ->
        test 'semantic not code', ->
          parser = PEG.buildParser '''
            start
              = !{return typeof Array is "undefined"}
          '''
          expect(parser.parse "").to.equal ""

        test 'semantic and code', ->
          parser = PEG.buildParser '''
            start
              = &{return typeof Array isnt "undefined"}
          '''
          expect(parser.parse "").to.equal ""


      suite 'variable use', ->
        test 'can use label variables', ->
          parser = PEG.buildParser '''
            start
              = a:"a" &{return a is "a"}
          '''
          expect(parser.parse "a").to.eql ["a", ""]
        
        test 'can use the |offset| variable to get the current parse position', ->
          parser = PEG.buildParser '''
            start
              = "a" &{return offset is 1}
          '''
          expect(parser.parse "a").to.eql ["a", ""]
