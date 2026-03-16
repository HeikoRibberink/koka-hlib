module bslice

pub import std/core/bslice

import std/core/undiv
import std/num/int64

import hlib/ext/int64
import hlib/ext/ssize-t

pub fun next-int64(bslice : bslice, x : int64 = 0.int64, i : int = 7) : maybe<(int64, bslice)>
  if i < 0 then
    Just((x, bslice))
  else match bslice.next
    Just((i8, bslice')) -> 
      val x' = x.or(i8.uint8/int64.shl(i * 8))
      //(x, x', i8.uint8/int64, i8.uint8/int64.shl(i * 8), i).trace-show
      bslice'.pretend-decreasing.next-int64(x', i - 1)
    Nothing -> Nothing
