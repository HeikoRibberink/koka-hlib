module bytes

import std/core/bytes
import std/num/int64

import hlib/ext/int64
import hlib/ext/ssize-t

pub fun show(bytes : bytes) : string
  var s := []
  for(bytes.length) fn(i)
    s := s ++ [bytes.bytes/unsafe-index(i).int]
  show(s) 

pub fun unsafe-assign(bytes : bytes, start : ssize_t, len : ssize_t, other : bytes) : bytes
  var b := bytes
  for(len) fn(i)
    b := b.assign(start + i, other.unsafe-index(i))
  b

pub fun int64/unsafe-index(bytes : bytes, i : ssize_t) : int64
  var i64 := 0.int64
  for(8.ssize_t) fn(j)
    val i8 = bytes.bytes/unsafe-index(i + j)
    i64 := i64.or(i8.uint8/int64.shl((7 - j.int) * 8))
  i64

pub fun int64/set(bytes : bytes, i : ssize_t, x : int64) : bytes
  var b := bytes
  for(8.ssize_t) fn(j : ssize_t)
    val i8 = x.shr((7 - j.int) * 8).lowest-byte
    b := b.assign(i + j, i8)
  b
