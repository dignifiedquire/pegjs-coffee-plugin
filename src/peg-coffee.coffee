#
# peg-coffee.coffee
# 

# Utility functions

# modelled after pegjs/src/utils.js
# 
# Builds a node visitor -- a function which takes a node and any number of
# other parameters, calls an appropriate function according to the node type,
# passes it all its parameters and returns its value. The functions for various
# node types are passed in a parameter to |buildNodeVisitor| as a hash.
utils = 
 buildNodeVisitor: (functions) ->
   (node) ->
     functions[node.type].apply(null, arguments)


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
    
    compileCoffee = (code) -> CoffeeScript.compile(code, bare: true)

    nop = ->

    compileRule = (node) -> compileAction(node.expression)
      
    compileAction = (node) ->  
      node.code = compileCoffee node.code if node.type is 'action'
    
    # recursivly compile in subnodes
    compileInSubnodes = (propertyName) ->
      (node) -> compile(subnode) for subnode in node[propertyName]

    compile = utils.buildNodeVisitor
      grammar:      compileInSubnodes('rules')
      rule:         compileRule
      named:        nop
      choice:       compileInSubnodes('alternatives')
      sequence:     compileInSubnodes('elements')
      labeled:      nop
      simple_and:   nop
      simple_not:   nop
      semantic_and: nop
      semantic_not: nop
      optional:     nop
      zero_or_more: nop
      one_or_more:  nop
      action:       compileAction
      rule_ref:     nop
      literal:      nop
      class:        nop
      any:          nop      

    # compile the grammar (actions and predicates)
    compile(ast)
    
    # compile the initializer
    ast.initializer = compileCoffee ast.initializer if ast.initializer


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
