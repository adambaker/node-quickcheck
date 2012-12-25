(function(){
  var _, inf, arbBool, arbDouble, arbDoubleTest, arbInt, arbByte, arbChar, arbArray, arbString, forAll, forAllSilent, test, exports, slice$ = [].slice;
  _ = require("underscore");
  inf = Number.POSITIVE_INFINITY;
  arbBool = function(){
    return function(){
      if (Math.random() > 0.5) {
        return true;
      } else {
        return false;
      }
    };
  };
  arbDouble = function(opts){
    var minMaxVal, min, max, include_zero, include_NAN, include_infinites, include_NaN;
    opts == null && (opts = {});
    minMaxVal = 100;
    min = opts.min, max = opts.max, include_zero = opts.include_zero, include_NAN = opts.include_NAN, include_infinites = opts.include_infinites;
    min == null && (min = -minMaxVal);
    max == null && (max = minMaxVal);
    if (include_zero === void 8) {
      include_zero = true;
    }
    if (include_NaN === void 8) {
      include_NaN = false;
    }
    if (include_NaN === void 8) {
      include_infinites = false;
    }
    return function(){
      var firstVals;
      firstVals = [max, min];
      if (include_zero) {
        firstVals.push(0);
      }
      if (include_NaN) {
        firstVals.push(NaN);
      }
      if (include_infinites) {
        firstVals.push(inf, -inf);
      }
      return function(){
        if (firstVals.length > 0) {
          return firstVals.shift();
        } else {
          return Math.random() * (max - min) + min;
        }
      };
    }();
  };
  arbDoubleTest = function(){
    var doubleGen, doubles, res$, i$, ref$, len$, i, negativeDoubles, firstVals;
    doubleGen = arbDouble();
    res$ = [];
    for (i$ = 0, len$ = (ref$ = (fn$())).length; i$ < len$; ++i$) {
      i = ref$[i$];
      res$.push(doubleGen());
    }
    doubles = res$;
    negativeDoubles = _.filter(doubles, function(double){
      return double < 0;
    });
    console.assert(0.4 < (ref$ = negativeDoubles.length / doubles.length) && ref$ < 0.6);
    firstVals = [doubles[0], doubles[1], doubles[2]];
    return console.assert(_.isEqual(firstVals, [100, -100, 0]));
    function fn$(){
      var i$, results$ = [];
      for (i$ = 0; i$ < 10000; ++i$) {
        results$.push(i$);
      }
      return results$;
    }
  };
  arbInt = function(opts){
    var fn;
    opts == null && (opts = {});
    fn = arbDouble(opts);
    return function(){
      return Math.floor(fn());
    };
  };
  arbByte = function(){
    return arbInt({
      max: 256,
      min: 0
    });
  };
  arbChar = function(){
    var byteGen;
    byteGen = arbByte();
    return function(){
      return String.fromCharCode(byteGen());
    };
  };
  arbArray = function(generator){
    return function(){
      var len, i$, ref$, len$, i, results$ = [];
      len = Math.floor(Math.random() * 100);
      for (i$ = 0, len$ = (ref$ = (fn$())).length; i$ < len$; ++i$) {
        i = ref$[i$];
        results$.push(generator());
      }
      return results$;
      function fn$(){
        var i$, to$, results$ = [];
        for (i$ = 0, to$ = len; i$ < to$; ++i$) {
          results$.push(i$);
        }
        return results$;
      }
    };
  };
  arbString = function(){
    var gen;
    gen = arbArray(arbChar());
    return function(){
      return gen().join("");
    };
  };
  forAll = function(property){
    var i$, generators, opts, fn, i, values;
    generators = 1 < (i$ = arguments.length - 1) ? slice$.call(arguments, 1, i$) : (i$ = 1, []), opts = arguments[i$];
    if (typeof opts === 'function') {
      generators.push(opts);
      opts = {};
    }
    opts.tries || (opts.tries = 100);
    opts.verbose || (opts.verbose = false);
    fn = function(f){
      return f();
    };
    i = 0;
    while (i < opts.tries) {
      values = generators.map(fn);
      if (!property.apply(null, values)) {
        console.log("*** Failed!\n" + values);
        return false;
      }
      if (opts.verbose) {
        console.log("  passed " + property.name + " with " + values);
      }
      i++;
    }
    console.log("+++ OK, passed " + opts.tries + " tests.");
    return true;
  };
  forAllSilent = function(){
    var result;
    console.oldLog = console.log;
    console.log = function(){};
    result = forAll.apply(null, arguments);
    console.log = console.oldLog;
    return result;
  };
  test = function(){
    var propertyEven, propertyNumber, propertyTrue, propLengths, propAddIdent;
    arbDoubleTest();
    propertyEven = function(x){
      return x % 2 === 0;
    };
    console.assert(!forAllSilent(propertyEven, arbByte()));
    propertyNumber = function(x){
      return typeof x === "number";
    };
    console.assert(forAllSilent(propertyNumber, arbInt()));
    propertyTrue = function(x){
      return x;
    };
    console.assert(!forAllSilent(propertyTrue, arbBool()));
    propLengths = function(s1, s2){
      return s1.length + s2.length === (s1 + s2).length;
    };
    console.assert(forAll(propLengths, arbString(), arbString(), {
      tries: 400
    }));
    propAddIdent = function(i){
      return i + 0 === i;
    };
    console.assert(forAll(propAddIdent, arbByte(), {
      tries: 10,
      verbose: true
    }));
    return true;
  };
  exports = {
    arbBool: arbBool,
    arbDouble: arbDouble,
    arbInt: arbInt,
    arbByte: arbByte,
    arbChar: arbChar,
    arbArray: arbArray,
    arbString: arbString,
    forAll: forAll,
    forAllSilent: forAllSilent
  };
  test();
}).call(this);
