module ssize-t

import std/core/undiv

pub extern (+)(l : ssize_t, r : ssize_t) : ssize_t
  c inline "(#1 + #2)"

pub extern (-)(l : ssize_t, r : ssize_t) : ssize_t
  c inline "(#1 - #2)"

pub extern (~)(l : ssize_t) : ssize_t
  c inline "-(#1)"

pub extern (*)(l : ssize_t, r : ssize_t) : ssize_t
  c inline "(#1 * #2)"

pub extern (==)(l : ssize_t, r : ssize_t) : bool
  c inline "(#1 == #2)"

pub extern (<)(l : ssize_t, r : ssize_t) : bool
  c inline "(#1 < #2)"

pub extern (<=)(l : ssize_t, r : ssize_t) : bool
  c inline "(#1 <= #2)"

pub extern (>)(l : ssize_t, r : ssize_t) : bool
  c inline "(#1 > #2)"

pub extern (>=)(l : ssize_t, r : ssize_t) : bool
  c inline "(#1 >= #2)"

pub val zero = 0.ssize_t
pub val one = 1.ssize_t

pub fun max(l : ssize_t, r : ssize_t) : ssize_t
  if l > r then l else r

pub fun min(l : ssize_t, r : ssize_t) : ssize_t
  if l < r then l else r

pub fun show(x : ssize_t) : string
  x.int.show

pub fun for(n : ssize_t, action : (ssize_t) -> e ()) : e ()
  range/for(zero, n - one, action)

// Executes `action`  for each integer from `start` to `end` (including `end` ).
// If `start > end`  the function returns without any call to `action` .
pub fun range/for(start: ssize_t, end : ssize_t, ^action : (ssize_t) -> e () ) : e ()
  if start <= end then
    action(start)
    range/for((start + one).pretend-decreasing, end, action)

fun main()
  for(8.ssize_t) fn(i)
    assert("", i < 8.ssize_t)


