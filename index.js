//
// pegjs-coffee-plugin
//

var CoffeeScript = require('coffee-script');
var detectIndent = require('detect-indent');

// The acutal compilation of CoffeeScript.
function compileCoffeeScript(code) {
  // Compile options
  var options = {
    bare: true
  };

  try {
    return CoffeeScript.compile(code, options);
  } catch (error) {
    var message = 'In: \n' + code + '\n was the following error:' + error.message;
    throw new SyntaxError(message, error.fileName, error.lineNumber);
  }
}

// The initializer gets its own scope which we save
// in __initializer for later use
function wrapInitializer(initializer) {
  var indent = detectIndent(initializer) || '  ';
  return [
    '__initializer = ( ->',
    indent +  initializer,
    indent + 'return this',
    ').call({})'
  ].join('\n');
}

function wrapCode(code) {
  return [
    'return ( -> ',
    code,
    ' ).apply(__initializer)'
  ].join('');
}

function compileNode(node) {
  // We inject the scope of the initializer if it exists
  // into the function that calls the action code
  node.code = compileCoffeeScript(wrapCode(node.code));
  return node;
}

function buildNodeVisitor(visitorMap) {
  visitorMap = visitorMap || {};
  return function (node) {
    var visitor = visitorMap[node.type] || function () {};
    return visitor.call(null, node);
  };
}

function compileExpression(node) {
  compile(node.expression);
  return node;
}

function compileSubnodes(property) {
  return function (node) {
    for (var i=0; i< node[property].length; i++) {
      compile(node[property][i]);
    }
    return node
  };
}

// Recursively walk through all nodes
function compile(nodes) {
  buildNodeVisitor({
    grammar:        compileSubnodes('rules'),
    choice:         compileSubnodes('alternatives'),
    sequence:       compileSubnodes('elements'),
    action:         compileNode,
    semantic_not:   compileNode,
    semantic_and:   compileNode,
    rule:           compileExpression,
    named:          compileExpression,
    labeled:        compileExpression,
    text:           compileExpression,
    simple_and:     compileExpression,
    simple_not:     compileExpression,
    optional:       compileExpression,
    zero_or_more:   compileExpression,
    one_or_more:    compileExpression
  })(nodes);
}

function pass(ast) {
  // Add an initializer block if there is none.
  if (!ast.initializer) {
    ast.initializer = {
      type: 'initializer',
      code: ''
    };
  }
  ast.initializer.code = compileCoffeeScript(wrapInitializer(ast.initializer.code));
  compile(ast);
}

module.exports = {
  use: function (config, options) {
    config.passes.transform.unshift(pass);
  }
};
