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

  remove: (PEG) ->
    appliedPassNames = PEG.compiler.appliedPassNames
    index = appliedPassNames.indexOf(PASS_NAME)
    if index > -1
      appliedPassNames.splice index, 1
      delete PEG.compiler.passes[PASS_NAME]

  pass: (ast) ->

    # First we need compile the initializer
    # if there is one
    
    unless ast.initializer?
      ast.initializer =
        type: 'initializer'
        code: ''
    # The initializer gets its own scope which we save
    # in __initializer for later use
    wrappedInitializer = """
      __initializer = ( ->
        #{ast.initializer.code}
        return this
      ).call({})
    """
    ast.initializer.code = CoffeeScript.compile(wrappedInitializer, bare: true)

                    
    compileNode = (code) ->
      # We inject the scope of the initializer if it exists
      # into the function that calls the action code
      wrappedCode = "return ( -> #{code} ).apply(__initializer)"
      return CoffeeScript.compile(wrappedCode, bare: true)

    
    
    # recursivley walks through all nodes
    compile = (nodes) ->
      for key, value of nodes
        if value? and typeof value is 'object' and value.type isnt 'initializer'
          # if we have an object with a code property
          # we compile the code
          value.code = compileNode value.code if value.code
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
  if exports?
    # Node.js
    module.exports = factory(require)
  else
    # global function
    window[id] = factory (value) -> window[value]
)
