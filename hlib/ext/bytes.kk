module bytes

import std/core/bytes

import hlib/ext/ssize-t

pub fun show(bytes : bytes) : string
  var s := []
  for(bytes.length) fn(i)
    s := s ++ [bytes.unsafe-index(i).int]
  show(s) 

pub fun unsafe-assign(bytes : bytes, start : ssize_t, len : ssize_t, other : bytes) : bytes
  var b := bytes
  for(len) fn(i)
    b := b.assign(start + i, other.unsafe-index(i))
  b
