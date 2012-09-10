utils = require './utils'
CoffeeScript = require 'coffee-script'

PASS_NAME = 'compileFromCoffeeScript'

module.exports =
  initialize: (PEG) ->
    # inject our pass to the passes of peg.js
    PEG.compiler.passes[PASS_NAME] = @pass

    appliedPassNames = PEG.compiler.appliedPassNames    

    # test if it was already loaded
    if appliedPassNames.indexOf(PASS_NAME) is -1
      # add the pass to the applied passes
      index = appliedPassNames.indexOf 'allocateRegister'
      appliedPassNames.splice index - 1, 0, PASS_NAME

  pass: (ast) ->

    compileCoffee = (code) ->
      CoffeeScript.compile code, bare: true

    # empty function
    nop = ->

    # compile the code   
    compileRule = (node) ->
      compileAction(node.expression)
      
    compileAction = (node) ->
      if node.type is 'action'
        node.code = compileCoffee node.code

    
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
