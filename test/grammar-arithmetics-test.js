var CoffeeScript, PEG, PEGjsCoffeePlugin, expect, grammar, tryParse;

if (typeof require !== "undefined" && require !== null) {
  CoffeeScript = require('coffee-script');
  expect = require('expect.js');
  PEG = require('pegjs');
  PEGjsCoffeePlugin = require('../index');
} else {
  CoffeeScript = global.CoffeeScript;
  expect = global.expect;
  PEG = global.PEG;
  PEGjsCoffeePlugin = global.PEGjsCoffeePlugin;
}

tryParse = function(parser, text) {
  var e, result;
  try {
    result = parser.parse(text);
  } catch (_error) {
    e = _error;
    result = e;
  }
  return result;
};

grammar = [
  'start',
  '  = additive',
  '',
  'additive',
  '  = left:multiplicative "+" right:additive { left + right }',
  '  / multiplicative',
  '',
  'multiplicative',
  '  = left:primary "*" right:multiplicative { left * right }',
  '  / primary',
  '',
  'primary',
  '  = integer',
  '  / "(" additive:additive ")" { additive }',
  '',
  'integer "integer"',
  '  = digits:[0-9]+ { parseInt digits.join(""), 10 }'
].join('\n');

suite('arithmetic grammar', function() {
  test('parses 2*(3+4)', function() {
    var parser = (PEG.buildParser || PEG.generate).bind(PEG)(grammar, {
      plugins: [PEGjsCoffeePlugin]
    });
    expect(tryParse(parser, "2*(3+4)")).to.equal(14);
  });
});
