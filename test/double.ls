require! { chai.assert }
require! {'../quickcheck'.arbDouble}
require('prelude-ls').installPrelude(global)

inf = Number.POSITIVE_INFINITY

describe 'arbDouble', !(x)->
  it 'should yield numbers' !->
    doubles = arbDouble()
    for i from 1 to 100
      assert.isNumber doubles!, 'doubles returns numbers'

  describe 'defaults' !(x)->

    before-each !->
      @doubles = arbDouble()

    it 'should first yield 100 and -100' !->
      assert.equal @doubles!, 100, '100 default max comes first'
      assert.equal @doubles!, -100, '-100 default min comes next'
      assert.equal @doubles!, 0, '0 included third'

    it 'should not generate infinites or NaN' !->
      for i from 1 to 100
        x = @doubles!
        assert isFinite(x)

  describe 'options' !(x) ->
    it 'should accept new max and min values' !->
      doubles = arbDouble {min: Math.PI, max: 2*Math.PI}
      assert.equal doubles!, 2*Math.PI, 'max first'
      assert.equal doubles!, Math.PI, 'min next'
      for i from 1 to 100
        x = doubles!
        assert.operator x, '<=', 2*Math.PI, 'less than max'
        assert.operator x, '>=', Math.PI, 'greater than min'

    it 'should add NaN after max, min, and zero with includeNaN' !->
      doubles = arbDouble {include-NaN: true}
      doubles!; doubles!; doubles!
      assert isItNaN doubles!, 'NaN'

    it 'should add infinites after with includeInfinites' !->
      doubles = arbDouble {include-infinites: true, include-NaN: true}
      doubles!; doubles!; doubles!; doubles!
      assert.equal doubles!, inf, 'infinity'
      assert.equal doubles!, -inf, '-infinity'

    it 'should not include zero if that is suppressed.' !->
      doubles = arbDouble {include-zero: false, include-NaN: true}
      doubles!; doubles!
      assert.notEqual doubles!, 0, 'not zero'
