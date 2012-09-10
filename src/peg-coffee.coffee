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
    console.log "I was called"
  