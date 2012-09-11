#
# peg-coffee.coffee
# 


# set constants  
PASS_NAME = 'compileFromCoffeeScript'

#
# the module itself
# 
PEGCoffee = (CoffeeScript) ->
  initialize: (PEG) ->
    CoffeeScript ?= global.CoffeeScript

    # inject our pass to the passes of peg.js
    PEG.compiler.passes[PASS_NAME] = @pass
    appliedPassNames = PEG.compiler.appliedPassNames    

    if appliedPassNames.indexOf(PASS_NAME) is -1
      # add the pass to the applied passes
      index = appliedPassNames.indexOf 'allocateRegister'
      appliedPassNames.splice index - 1, 0, PASS_NAME


  pass: (ast) ->
    
    compileCoffee = (code) ->
      CoffeeScript.compile(code, bare: true)

    # recursivley walks through all nodes
    compile = (nodes) ->
      for key, value of nodes
        if typeof value is 'object'
          # if we have an object with a code property
          # we compile the code
          value.code = compileCoffee value.code if value and value.code
          compile(value)
            
    compile(ast)





# Export
# Use https://gist.github.com/1262861
# usable for AMD, node.js and the browser

((define) ->
  define 'PEGCoffee', (require) ->
    # require dependencies here
    CoffeeScript = require 'coffee-script'
    
    # the module definition is returned
    return PEGCoffee(CoffeeScript)
)(if typeof define is 'function' and define.amd then define else (id, factory) ->
  if typeof exports isnt 'undefined'
    # Node.js
    module.exports = factory(require)
  else
    # global function
    window[id] = factory (value) -> window[value]
)
