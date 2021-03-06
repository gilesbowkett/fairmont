# Array Functions

    {curry, flip, compose, partial, _, identity,
      unary, binary, ternary} = require "./core"

    {detach} = require "./object"
    {deepEqual} = require "./type"

    # array only version of empty, not exported
    empty = (x) -> x.length == 0

    {odd, lt} = require "./numeric"

    {assert, describe} = require "./helpers"


    describe "Array functions", (context) ->

## cat

Concatenates (joins) arrays.

      cat = detach Array::concat

      context.test "cat", ->
        data = [1..5]
        assert deepEqual (cat data), data
        assert deepEqual (cat data, data), data.concat data

## slice

Curryied version of `Array::slice`.

      slice = curry (i, j, ax) -> ax[i...j]

      context.test "slice", ->
        data = [1..5]
        assert deepEqual ((slice 1, 2) data), [2]

## first

Returns the first element of an array.

      first = (ax) -> ax[0]

      context.test "first", ->
        data = [1..5]
        assert (first data) == 1

      second = (ax) -> ax[1]
      third = (ax) -> ax[2]


## last

Returns the last element of an array.

      last = ([rest..., x]) -> x

      context.test "last", ->
        do (data = [1..5]) -> assert (last data) == 5

## rest

Returns all array elements but the first.

      rest = slice 1, undefined

      context.test "rest", ->
        do (data = [1..5]) -> assert deepEqual (rest data), [2..5]

## includes

Check if an element is a member of an array.

      includes = curry (x, ax) -> x in ax

      context.test "includes", ->
        do (data = [1..5]) ->
          assert (includes 3, data)
          assert !(includes 6, data)

## uniqueBy

Returns a new array containing only unique members of an array,
after transforming them with `f`. This is a generalized version of
[`unique`](#unique) below.

      uniqueBy = curry (f, ax) ->
        bx = []
        for a in ax
          b = f a
          (bx.push b) unless b in bx
        bx

## unique

Returns a new array containing only unique member of an array.

      unique = uniq = uniqueBy identity

      context.test "unique", ->
        assert deepEqual (unique cat [1..5], [1..5], [1..5]), [1..5]

## dupes

Returns only the elements that exist more than once.

      dupes = ([a, ax...]) ->
        if empty ax
          []
        else
          bx = dupes ax
          if a in ax && !(a in bx) then [a, bx...] else bx


      context.test "dupes", ->
        assert deepEqual (dupes cat [1..3], [2..4], [3..5]), [2..4]

## union

Set union (combination of two array with duplicates removed).

      union = curry compose unique, cat

      context.test "union", ->
        do (a = [1..4], b = [3..6]) ->
          assert deepEqual (union a, b), [1..6]
          assert deepEqual (union a, a), [1..4]

## intersection

      intersection = (first, rest...) ->
        if empty rest
          first
        else
          x for x in (intersection rest...) when x in first

      context.test "intersection", ->
        assert  empty intersection [1, 2], [3, 4]
        assert empty intersection [1, 1], [2, 2]
        assert empty intersection [], [1, 2, 3]
        assert empty intersection [1, 2, 3], []
        assert empty intersection [1, 2], [2, 3], [3, 4]
        assert (first intersection [1, 2], [2, 3]) == 2
        assert (first intersection [1, 2], [2, 3], [3, 2]) == 2

## difference

Returns the elements that are not shared between two arrays.

      difference = curry (ax, bx) ->
        cx = union ax, bx
        cx.filter (c) ->
          (c in ax && !(c in bx)) ||
            (c in bx && !(c in ax))

      context.test "difference", ->
        do (ax = [1..4], bx = [3..6]) ->
          assert deepEqual (difference ax, bx), [1,2,5,6]

## complement

Returns the complement of the second array relative to the first array.

      complement = curry (ax, bx) ->
        ax.filter (c) -> !(c in bx)

      context.test "complement", ->
        do (ax = [1..4], bx = [3..6]) ->
          assert deepEqual (complement ax, bx), [1,2]

## remove

Destructively remove an element from an array. Returns the element removed.

      remove = (array, element) ->
        if (index = array.indexOf( element )) > -1
          array[index..index] = []
          element
        else
          null

## shuffle

Takes an array and returns a new array with all values shuffled randomly. Use the [Fisher-Yates algorithm][shuffle-1]. Adapted from the [CoffeeScript Cookbook][shuffle-2].

[shuffle-1]:http://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
[shuffle-2]:http://coffeescriptcookbook.com/chapters/arrays/shuffling-array-elements

      shuffle = (ax) ->
        bx = cat ax
        unless bx.length <= 1
          for b, i in bx
            j = i
            while j == i
              j = Math.floor Math.random() * bx.length
            [bx[i], bx[j]] = [bx[j], bx[i]]
          if deepEqual ax, bx then shuffle ax else bx
        else
          bx

      context.test "shuffle", ->
        do (data = [1..5]) ->
          assert !deepEqual (shuffle data), data

## range

Generates an array of integers based on the given range.

      range = (start, finish) -> [start..finish]

      context.test "range", -> assert deepEqual (range 1, 5), [1..5]

---


      module.exports = {cat, slice, first, second, third, last, rest,
        includes, uniqueBy, unique, uniq, dupes, union, intersection,
        difference, remove, shuffle}
