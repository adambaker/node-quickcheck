arbBool = ->
  (if Math.random() > 0.5 then true else false)
arbDouble = ->
  sign = (if Math.random() > 0.5 then 1 else -1)
  sign * Math.random() * Number.MAX_VALUE
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
  propertyEven = undefined
  propertyNumber = undefined
  propertyTrue = undefined
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

exports.arbBool = arbBool
exports.arbDouble = arbDouble
exports.arbInt = arbInt
exports.arbByte = arbByte
exports.arbChar = arbChar
exports.arbArray = arbArray
exports.arbString = arbString
exports.forAll = forAll
exports.forAllSilent = forAllSilent
exports.test = test

test()
