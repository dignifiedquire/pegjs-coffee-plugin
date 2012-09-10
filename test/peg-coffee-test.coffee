expect = require 'expect.js'

suite 'peg-coffee', ->
  PEG = {}
  PEGCoffee = {}
  
  setup ->
    PEG = require 'pegjs'
    PEGCoffee = require '../lib/peg-coffee'
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

    test 'should only be added once', ->
      PEGCoffee.initialize PEG
      PEGCoffee.initialize PEG

      expect(PEG.compiler.appliedPassNames.length).to.equal 6

  suite 'compile grammar', ->

    test 'simple coffee script action', ->
      grammar = 'start = "a" { return "#{1+1}" }'
      parser = PEG.buildParser grammar
      result = parser.parse "a"
      expect(result).to.equal "2"
      
      