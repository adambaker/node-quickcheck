_ = require "underscore"
inf = Number.POSITIVE_INFINITY

arbBool = ->
  -> (if Math.random() > 0.5 then true else false)

arbDouble = (opts = {})->
  minMaxVal = 100
  {min, max, include_zero, include_NAN, include_infinites} = opts
  min ?= -minMaxVal
  max ?= minMaxVal
  include_zero = true if include_zero == undefined
  include_NaN = false if include_NaN == undefined
  include_infinites = false if include_NaN == undefined
  do ->
    firstVals = [max, min]
    firstVals.push 0 if include_zero
    firstVals.push NaN if include_NaN
    if include_infinites
      firstVals.push inf, -inf
    ->
      if firstVals.length > 0
        firstVals.shift()
      else
        Math.random() * (max - min) + min

arbDoubleTest = ->
  # Random Doubles
  doubleGen = arbDouble()
  doubles = [doubleGen() for i in [til 10000]]
  negativeDoubles =  _.filter doubles, (double) -> double < 0
  console.assert 0.4 < negativeDoubles.length / doubles.length < 0.6

  firstVals = doubles[0 to 2]
  console.assert _.isEqual firstVals, [100, -100, 0]

arbInt = (opts = {}) ->
  fn = arbDouble(opts)
  -> Math.floor fn()

arbByte = ->
  arbInt({max: 256, min: 0})

arbChar = ->
  byteGen = arbByte()
  -> String.fromCharCode byteGen()

arbArray = (generator) ->
  -> 
    len = Math.floor(Math.random() * 100)
    [generator() for i in [til len]]

arbString = ->
  gen = arbArray(arbChar())
  -> gen().join ""

forAll = (property, ...generators, opts) ->
  if typeof opts == 'function'
    generators.push opts
    opts = {}
  opts.tries ||= 100
  opts.verbose ||= false;

  fn = (f) -> f()

  i = 0
  while i < opts.tries
    values = generators.map(fn)
    unless property.apply(null, values)
      console.log "*** Failed!\n" + values
      return false
    if opts.verbose
      console.log "  passed #{property.name} with #{values}"
    i++
  console.log "+++ OK, passed #{opts.tries} tests."
  true

forAllSilent = ->
  console.oldLog = console.log
  console.log = ->

  result = forAll.apply(null, arguments)
  console.log = console.oldLog
  result

# Test quickcheck itself
test = ->
  arbDoubleTest()

  propertyEven = (x) ->
    x % 2 is 0

  console.assert not forAllSilent(propertyEven, arbByte())
  propertyNumber = (x) ->
    typeof (x) is "number"

  console.assert forAllSilent(propertyNumber, arbInt())
  propertyTrue = (x) ->
    x

  console.assert not forAllSilent(propertyTrue, arbBool())

  propLengths = (s1,s2) ->s1.length + s2.length == (s1 + s2).length
  console.assert forAll propLengths , arbString(), arbString(), {tries: 400}

  propAddIdent = (i) -> i + 0 == i
  console.assert forAll propAddIdent, arbByte(), {tries: 10, verbose: true}
  true

exports = {
  arbBool
  arbDouble
  arbInt
  arbByte 
  arbChar
  arbArray
  arbString
  forAll
  forAllSilent
}

test()
