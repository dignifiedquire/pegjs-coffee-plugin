#
# peg-coffee.coffee
# 


# set constants  
PASS_NAME = 'compileFromCoffeeScript'
VERSION = '@VERSION'

#
# the module itself
# 
PEGjsCoffeePlugin = (CoffeeScript) ->
  VERSION: VERSION
  addTo: (PEG) ->
    CoffeeScript ?= global.CoffeeScript

    # inject our pass to the passes of peg.js
    PEG.compiler.passes[PASS_NAME] = @pass
    appliedPassNames = PEG.compiler.appliedPassNames    

    if appliedPassNames.indexOf(PASS_NAME) is -1
      # add the pass to the applied passes
      index = appliedPassNames.indexOf 'allocateRegister'
      appliedPassNames.splice index - 1, 0, PASS_NAME

  removeFrom: (PEG) ->
    appliedPassNames = PEG.compiler.appliedPassNames
    index = appliedPassNames.indexOf(PASS_NAME)
    if index > -1
      appliedPassNames.splice index, 1
      delete PEG.compiler.passes[PASS_NAME]

  pass: (ast) ->

    # this function handles the actual compilation of the
    # code and the error handling
    compileCoffeeScript = (code) ->
      # compile options
      options = bare: true
      try
        compiled = CoffeeScript.compile(code, options)
      catch error
        throw new SyntaxError(
          "In: \"#{code}\"\n was the following error: #{error.message}",
          error.fileName,
          error.lineNumber
        )

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
    ast.initializer.code = compileCoffeeScript(wrappedInitializer)

                    
    compileNode = (code) ->
      # We inject the scope of the initializer if it exists
      # into the function that calls the action code
      wrappedCode = "return ( -> #{code} ).apply(__initializer)"
      compileCoffeeScript(wrappedCode)

    
    
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
  define 'PEGjsCoffeePlugin', (require) ->
    # require dependencies here
    CoffeeScript = require 'coffee-script'
    
    # the module definition is returned
    return PEGjsCoffeePlugin(CoffeeScript)
)(if typeof define is 'function' and define.amd then define else (id, factory) ->
  if exports?
    # Node.js
    module.exports = factory(require)
  else
    # global function
    window[id] = factory (value) -> window[value]
)
