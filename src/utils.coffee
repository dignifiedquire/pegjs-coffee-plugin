# utils modelled after pegjs/src/utils.js


# Builds a node visitor -- a function which takes a node and any number of
# other parameters, calls an appropriate function according to the node type,
# passes it all its parameters and returns its value. The functions for various
# node types are passed in a parameter to |buildNodeVisitor| as a hash.
utils = 
 buildNodeVisitor: (functions) ->
   (node) ->
     functions[node.type].apply(null, arguments)



module.exports = utils