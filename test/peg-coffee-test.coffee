should = require 'should'

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
      passes.should.have.property 'compileFromCoffeeScript'
      
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
      appliedPassNames.should.eql expectedPassNames

    test 'should only be added once', ->
      PEGCoffee.initialize PEG
      PEGCoffee.initialize PEG

      PEG.compiler.appliedPassNames.length.should.eql 6

  suite 'compile grammar', ->

    test 'simple coffee script action', ->
      grammar = 'start = "a" { return "#{1+1}" }'
      parser = PEG.buildParser grammar
      result = parser.parse "a"
      result.should.eql "2"
      
      