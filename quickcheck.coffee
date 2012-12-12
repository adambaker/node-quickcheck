_ = require "underscore"
inf = Number.POSITIVE_INFINITY

arbBool = ->
  (if Math.random() > 0.5 then true else false)

arbDouble = (opts)->
  if opts
    minMaxVal = 100
    {
      min
      max
      include_zero
      include_NAN
      include_infinites
    } = opts
    min?= -minMaxVal
    max?= minMaxVal
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
  else 
    arbDouble({})

arbDoubleTest = ->
  # Random Doubles
  doubleGen = arbDouble()
  doubles = (doubleGen() for i in [0..10000])
  negativeDoubles =  _.filter doubles, (double) -> double < 0
  console.assert .4 < negativeDoubles.length / doubles.length < .6  

  firstVals = doubles[..2]
  console.assert _.isEqual firstVals, [100, -100, 0]

arbInt = ->
  sign = (if Math.random() > 0.5 then 1 else -1)
  sign * Math.floor(Math.random() * Number.MAX_VALUE)

arbByte = ->
  Math.floor Math.random() * 256

arbChar = ->
  String.fromCharCode arbByte()

arbArray = (generator) ->
  len = Math.floor(Math.random() * 100)
  array = []
  i = undefined
  i = 0
  while i < len
    array.push generator()
    i++
  array

arbString = ->
  arbArray(arbChar).join ""

forAll = (property, generators..., opts) ->
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

  console.assert not forAllSilent(propertyEven, arbByte)
  propertyNumber = (x) ->
    typeof (x) is "number"

  console.assert forAllSilent(propertyNumber, arbInt)
  propertyTrue = (x) ->
    x

  console.assert not forAllSilent(propertyTrue, arbBool)

  propLengths = (s1,s2) ->s1.length + s2.length == (s1 + s2).length
  console.assert forAll propLengths , arbString, arbString, {tries: 400}

  propAddIdent = (i) -> i + 0 == i
  console.assert forAll propAddIdent, arbByte, {tries: 10, verbose: true}
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
