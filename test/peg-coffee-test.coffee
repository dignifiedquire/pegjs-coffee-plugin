#
#  test/peg-coffee-test.coffee
# 

# Load dependencies
if require?
  # Node.js
  CoffeeScript  = require 'coffee-script'
  expect        = require 'expect.js'
  PEG           = require 'pegjs'
  PEGCoffee     = require '../lib/peg-coffee'
else
  # Browser
  CoffeeScript = global.CoffeeScript
  expect = global.expect
  PEG = global.PEG
  PEGCoffee = global.PEGCoffee

# Helper functions
tryParse = (parser, text) ->
  try
    result = parser.parse(text)
  catch e
    result = e
  return result
  
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

    test 'removes itself when remove() is called', ->
      PEGCoffee.remove PEG
      appliedPassNames = PEG.compiler.appliedPassNames
      expectedPassNames = [
        'reportMissingRules'
        'reportLeftRecursion'
        'removeProxyRules'
        'computeVarNames'
        'computeParams'
      ]
      expect(appliedPassNames).to.eql expectedPassNames
      expect(PEG.compiler.passes).to.not.have.property 'compileFromCoffeeScript'
    
  suite 'compile grammar', ->
    suite 'simple CoffeeScript', ->
      test 'action', ->
        parser = PEG.buildParser 'start = "a" { "#{1+1}" }'
        expect(tryParse parser, "a").to.equal "2"
        
      test 'initializer', ->
        parser = PEG.buildParser '''
          {
            @val = "#{1+1}"
          }
          start
            = "a" { @val }
        '''
        expect(tryParse parser, "a").to.equal "2"

      test 'empty initializer scope', ->
        parser = PEG.buildParser '''
          start = a { @ }
          a     = "a" { @value = "a" }
        '''
        expect(tryParse parser, "a").to.eql(value: "a")

      suite 'predicates', ->
        suite 'semantic not code', ->
          test 'success on |false| return', ->
            parser = PEG.buildParser '''
              start
                = !{typeof Array is "undefined"}
            '''
            expect(tryParse parser, "").to.equal ""
          test 'failure on |true| return', ->
            parser = PEG.buildParser '''
              start
                = !{typeof Array isnt "undefined"}
            '''
            expect(tryParse parser, "").to.be.a Error
          suite 'variable use', ->
            test 'can use label variables', ->
              parser = PEG.buildParser '''
                start
                  = a:"a" &{a is "a"}
              '''
              expect(tryParse parser, "a").to.eql ["a", ""]
            
            test 'can use the |offset| variable to get the current parse position', ->
              parser = PEG.buildParser '''
                start
                  = "a" &{offset is 1}
              '''
              expect(tryParse parser, "a").to.eql ["a", ""]

            test 'can use the |line| and |column| variables to get the current line and column', ->
              parser = PEG.buildParser '''
                {
                  @result = "test"
                }
                start = line (nl+ line)* {@result }
                line  = thing (" "+ thing)*
                thing = digit / mark
                digit = [0-9]
                mark  = &{ @result = [line, column]; true } "x"
                nl    = ("\\r" / "\\n" / "\\u2028" / "\\u2029")
              ''', trackLineAndColumn: true
              
              expect(tryParse parser, "1\n2\n\n3\n\n\n4 5 x").to.eql [7, 5]

        suite 'semantic and code', ->
          test 'success on |true| return', ->
            parser = PEG.buildParser '''
              start
                = &{typeof Array isnt "undefined"}
            '''
            expect(tryParse parser, "").to.equal ""
          test 'failure on |false| return', ->
            parser = PEG.buildParser '''
              start
                = &{typeof Array is "undefined"}
            '''
            expect(tryParse parser, "").to.be.a Error



          suite 'variable use', ->
            test 'can use label variables', ->
              parser = PEG.buildParser '''
                start
                  = a:"a" !{a isnt "a"}
              '''
              expect(tryParse parser, "a").to.eql ["a", ""]
            
            test 'can use the |offset| variable to get the current parse position', ->
              parser = PEG.buildParser '''
                start
                  = "a" !{offset isnt 1}
              '''
              expect(tryParse parser, "a").to.eql ["a", ""]

            test 'can use the |line| and |column| variables to get the current line and column', ->
              parser = PEG.buildParser '''
                {
                  @result = "test"
                }
                start = line (nl+ line)* {@result }
                line  = thing (" "+ thing)*
                thing = digit / mark
                digit = [0-9]
                mark  = !{ @result = [line, column]; false } "x"
                nl    = ("\\r" / "\\n" / "\\u2028" / "\\u2029")
              ''', trackLineAndColumn: true
              
              expect(tryParse parser, "1\n2\n\n3\n\n\n4 5 x").to.eql [7, 5]

