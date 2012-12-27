(function(){
  var _, inf, arbBool, arbDouble, arbInt, arbByte, arbChar, arbArray, arbString, forAll, forAllSilent, test, slice$ = [].slice;
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
  arbDouble = function(arg$){
    var ref$, min, ref1$, max, includeZero, includeNaN, includeInfinites;
    ref$ = arg$ != null
      ? arg$
      : {}, min = (ref1$ = ref$.min) != null
      ? ref1$
      : -100, max = (ref1$ = ref$.max) != null ? ref1$ : 100, includeZero = (ref1$ = ref$.includeZero) != null ? ref1$ : true, includeNaN = (ref1$ = ref$.includeNaN) != null ? ref1$ : false, includeInfinites = (ref1$ = ref$.includeInfinites) != null ? ref1$ : false;
    return function(){
      var firstVals;
      firstVals = [max, min];
      if (includeZero && max >= 0 && min <= 0) {
        firstVals.push(0);
      }
      if (includeNaN) {
        firstVals.push(NaN);
      }
      if (includeInfinites) {
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
  module.exports = {
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
