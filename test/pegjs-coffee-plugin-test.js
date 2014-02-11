var CoffeeScript, PEG, PEGjsCoffeePlugin, buildParser, expect, tryParse;

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

buildParser = function(code) {
  return PEG.buildParser(code, {
    plugins: [PEGjsCoffeePlugin]
  });
};

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

suite('peg-coffee', function() {
  suite('compile grammar', function() {
    suite('simple CoffeeScript', function() {
      test('action', function() {
        var parser = buildParser('start = "a" { "#{1+1}" }');
        expect(tryParse(parser, "a")).to.equal("2");
      });
      test('initializer', function() {
        var parser = buildParser('{\n  @val = "#{1+1}"\n}\nstart\n  = "a" { @val }');
        expect(tryParse(parser, "a")).to.equal("2");
      });
      test('initializer four spaces', function() {
        var parser = buildParser('{\n    @val = "#{1+1}"\n}\nstart\n  = "a" { @val }');
        expect(tryParse(parser, "a")).to.equal("2");
      });
      test('initializer four spaces multi line', function() {
        var parser = buildParser('{\n    @val = 2\n    @val2 = 1\n}\nstart\n  = "a" { "#{@val + @val2}" }');
        expect(tryParse(parser, "a")).to.equal("3");
      });
      test('empty initializer scope', function() {
        var parser = buildParser('start = a { @ }\na     = "a" { @value = "a" }');
        expect(tryParse(parser, "a")).to.be.eql({
          value: "a"
        });
      });
      test('four space indentation', function() {
        var parser = buildParser('start = "a" {\n    a = 10\n    "#{a+1}"\n}');
        expect (tryParse(parser, "a")).to.be.eql("11");
      });
      suite('predicates', function() {
        suite('semantic not code', function() {
          test('success on |false| return', function() {
            var parser = buildParser('start\n  = !{no}');
            expect(tryParse(parser, "")).to.be.undefined;
          });
          test('failure on |true| return', function() {
            var parser = buildParser('start\n  = !{yes}');
            expect(tryParse(parser, "")).to.be.an(Error);
          });
          suite('variable use', function() {
            test('can use this references', function() {
              var parser = buildParser('{\n  @a="a"\n}\nstart\n  = a:"a" !{a isnt @a}');
                expect(tryParse(parser, "a")).to.be.eql(["a", void 0]);
            });
            test('can use label variables', function() {
              var parser = buildParser('start\n  = a:"a" !{a isnt "a"}');
              expect(tryParse(parser, "a")).to.be.eql(["a", void 0]);
            });
            test('can use the |offset| variable to get the current parse position', function() {
              var parser = buildParser('start\n  = "a" !{offset() isnt 1}');
              expect(tryParse(parser, "a")).to.be.eql(["a", void 0]);
            });
            test('can use the |line| and |column| variables to get the current line and column', function() {
              var parser = buildParser('{\n  @result = "test"\n}\nstart = line (nl+ line)* { @result }\nline  = thing (" "+ thing)*\nthing = digit / mark\ndigit = [0-9]\nmark  = !{ @result = [line(), column()]; false } "x"\nnl    = ("\\r" / "\\n" / "\\u2028" / "\\u2029")', {
                trackLineAndColumn: true
              });
              expect(tryParse(parser, "1\n2\n\n3\n\n\n4 5 x")).to.be.eql([7, 5]);
            });
          });
        });
        suite('semantic and code', function() {
          test('success on |true| return', function() {
            var parser = buildParser('start\n  = &{yes}');
            expect(tryParse(parser, "")).to.equal(void 0);
          });
          test('failure on |false| return', function() {
            var parser = buildParser('start\n  = &{no}');
            expect(tryParse(parser, "")).to.be.a(Error);
          });
          suite('variable use', function() {
            test('can use this references', function() {
              var parser = buildParser('{\n  @a="a"\n  @b = 10\n}\nstart\n  = a:"a" &{a is @a and @b is 10}');
                expect(tryParse(parser, "a")).to.be.eql(["a", void 0]);
            });
            test('can use label variables', function() {
              var parser = buildParser('start\n  = a:"a" &{a is "a"}');
              expect(tryParse(parser, "a")).to.be.eql(["a", void 0]);
            });
            test('can use the |offset| variable to get the current parse position', function() {
              var parser = buildParser('start\n  = "a" &{offset() is 1}');
              expect(tryParse(parser, "a")).to.be.eql(["a", void 0]);
            });
            test('can use the |line| and |column| variables to get the current line and column', function() {
              var parser = buildParser('{\n  @result = "test"\n}\nstart = line (nl+ line)* {@result }\nline  = thing (" "+ thing)*\nthing = digit / mark\ndigit = [0-9]\nmark  = &{ @result = [line(), column()]; true } "x"\nnl    = ("\\r" / "\\n" / "\\u2028" / "\\u2029")', {
                trackLineAndColumn: true
              });
              expect(tryParse(parser, "1\n2\n\n3\n\n\n4 5 x")).to.be.eql([7, 5]);
            });
          });
        });
      });
    });
  });
});


