_ = require "underscore"
inf = Number.POSITIVE_INFINITY

arbBool = ->
  -> (if Math.random() > 0.5 then true else false)

arbDouble = ({
  min               = -100,
  max               = 100,
  include-zero      = true,
  include-NaN       = false,
  include-infinites = false,
} = {}
)->
  do ->
    firstVals = [max, min]
    firstVals.push 0 if include-zero && max >= 0 && min <= 0
    firstVals.push NaN if include-NaN
    if include-infinites
      firstVals.push inf, -inf
    ->
      if firstVals.length > 0
        firstVals.shift()
      else
        Math.random() * (max - min) + min

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

module.exports = {
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
