(function(){
  var assert, arbDouble, test, inf;
  assert = require('chai').assert;
  arbDouble = require('../quickcheck').arbDouble;
  require('prelude-ls').installPrelude(global);
  test = it;
  inf = Number.POSITIVE_INFINITY;
  describe('arbDouble', function(){
    test('should yield numbers', function(){
      var doubles, i$, i;
      doubles = arbDouble();
      for (i$ = 1; i$ <= 100; ++i$) {
        i = i$;
        assert.isNumber(doubles(), 'doubles returns numbers');
      }
    });
    describe('defaults', function(){
      beforeEach(function(){
        this.doubles = arbDouble();
      });
      test('should first yield 100 and -100', function(){
        assert.equal(this.doubles(), 100, '100 default max comes first');
        assert.equal(this.doubles(), -100, '-100 default min comes next');
        assert.equal(this.doubles(), 0, '0 included third');
      });
      test('should not generate infinites or NaN', function(){
        var i$, i, x;
        for (i$ = 1; i$ <= 100; ++i$) {
          i = i$;
          x = this.doubles();
          assert(isFinite(x));
        }
      });
    });
    describe('options', function(){
      test('should accept new max and min values', function(){
        var doubles, i$, i, x;
        doubles = arbDouble({
          min: Math.PI,
          max: 2 * Math.PI
        });
        assert.equal(doubles(), 2 * Math.PI, 'max first');
        assert.equal(doubles(), Math.PI, 'min next');
        for (i$ = 1; i$ <= 100; ++i$) {
          i = i$;
          x = doubles();
          assert.operator(x, '<=', 2 * Math.PI, 'less than max');
          assert.operator(x, '>=', Math.PI, 'greater than min');
        }
      });
      test('should add NaN after max, min, and zero with includeNaN', function(){
        var doubles;
        doubles = arbDouble({
          includeNaN: true
        });
        doubles();
        doubles();
        doubles();
        assert(isItNaN(doubles(), 'NaN'));
      });
      test('should add infinites after with includeInfinites', function(){
        var doubles;
        doubles = arbDouble({
          includeInfinites: true,
          includeNaN: true
        });
        doubles();
        doubles();
        doubles();
        doubles();
        assert.equal(doubles(), inf, 'infinity');
        assert.equal(doubles(), -inf, '-infinity');
      });
      test('should not include zero if that is suppressed.', function(){
        var doubles;
        doubles = arbDouble({
          includeZero: false,
          includeNaN: true
        });
        doubles();
        doubles();
        assert.notEqual(doubles(), 0, 'not zero');
      });
    });
  });
}).call(this);
