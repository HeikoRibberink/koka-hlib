module bytesb

pub import std/core/bytes
import std/core/bslice
pub import std/num/int64

import std/core/undiv

import hlib/ext/bytes
import hlib/ext/bslice
import hlib/ext/int64
import hlib/ext/ssize-t
import hlib/patterns/common

/* Provides an efficient bytes builder
*/

// An efficient bytes builder.
// Invariants:
// 1. `idx < buf.length`.
// 2. Every `buf[i]` with `i < idx` has been set.
// 3. Every byte in every `bytes` of `filled` has been set.
abstract struct bytesb
  // A list of filled buffers
  filled : ctx<list<bytes>>
  // The buffer to append to.
  buf : bytes
  // The index into `buf`, where the next byte should come.
  idx : ssize_t

pub fun show(bytesb : bytesb) : string
  "Bytesb(buf: " ++ show(bytesb.buf) ++ ", idx: " ++ bytesb.idx.show ++ ")"

pub fun empty(n : ssize_t = 16.ssize_t) : bytesb
  Bytesb(ctx hole, bytes/alloc(max(n, 1.ssize_t)), 0.ssize_t)

// Adds `buf` to `filled` and sets `buf` to a bytes with twice the size of the
// old `buf`, and sets `idx` to zero.
// Pre:
// - `bytesb` satisfies inveriants 2 and 3, and has `idx == buf.length`.
// Returns: 
// - A valid `bytesb`, unless Pre is not satisfied.
inline fun finalize-buf(bytesb : bytesb) : bytesb
  val Bytesb(filled, buf, _) = bytesb
  val buf-len = buf.length
  Bytesb(filled ++ ctx Cons(buf, hole), bytes/alloc(buf-len * 2.ssize_t), 0.ssize_t)

// Unsafe!
// Writes `x` to `bytesb.buf`, incrementing `idx`, creating a `bytesb` that may not have `idx < buf.length`.
// Pre: 
// - `bytesb` is valid, UB otherwise.
inline fun append-unchecked(bytesb : bytesb, x : int8) : bytesb
  val Bytesb(filled, buf, idx) = bytesb
  Bytesb(filled, buf.assign(idx, x), idx + 1.ssize_t)

pub inline fun int8/append(bytesb : bytesb, x : int8) : bytesb
  val bytesb' = bytesb.append-unchecked(x)
  val buf-len = bytesb.buf.length
  if bytesb'.idx >= buf-len then
    bytesb'.finalize-buf
  else
    bytesb'

fun catch-impossible(action, ?kk-file-line : string)
  with catch fn(_) {
    impossible("This should not throw.")
  }
  action()

// Appends `b` to `bytesb`. 
pub inline fun bytes/append(bytesb : bytesb, b : bytes) : bytesb
  // This works by copying `bytesb.buf` to a `bytes` of length `bytesb.idx`,
  // appending that to `bytesb.filled`, then appending `b`, reusing the old
  // `bytesb.buf` again by setting `idx` to zero. Unfortunately, because
  // `bslice/assign` doesn't work when the first parameter is the empty bytes,
  // we need to special-case for `idx == 0`.
  val Bytesb(filled, buf, idx) = bytesb
  val buf-copied = bytes/alloc(idx).unsafe-assign(0.ssize_t, idx, buf)
  Bytesb(
    filled ++ ctx Cons(buf-copied, Cons(b, hole)),
    buf,
    0.ssize_t
  )

// Appends `r` to `l`.
pub inline fun bytesb/append(l : bytesb, r : bytesb) : bytesb
  val new-filled = (l.filled ++ ctx Cons(l.buf.adjust-length(l.idx), hole)) ++ r.filled
  r(filled = new-filled)
  
  
// Returns a `bytes` containing the bytes added to `bytesb`, in order from left to right.
pub fun bytes(bytesb: bytesb) : bytes
  // Finish `filled` by adding `buf` to it, up to `idx`.
  val Bytesb(filled, buf, idx) = bytesb
  val buf' = buf.adjust-length(idx)
  val filled' = filled ++. Cons(buf', Nil)
  // Calculate the total length of all the buffers
  val total-len = filled'.foldl(0.ssize_t) fn(s, part) s + part.length
  // Then fill a new buffer with the contents of all the others.
  val (_, bytes) = filled'.foldl((0.ssize_t, bytes/alloc(total-len))) fn((i, bytes), part)
    val part-len = part.bytes/length
    val bytes' = bytes.unsafe-assign(i, part-len, part)
    (i + part-len, bytes')
  bytes

val uint64/lowest-byte-mask = 0xFF.int64.not

// Appends `x` to `bytesb`, little-endian.
pub fun uint64/append(bytesb : bytesb, x : int64, i : int = 7) : bytesb
  if i < 0 then
    bytesb
  else
    val b = x.shr(i * 8).lowest-byte
    uint64/append(bytesb.int8/append(b), x.pretend-decreasing, i - 1)

fun main()
  val s = "1234567890feafilajfialfjaifjalijeilfjilaejfileajlifjaeilfjailfjeilaejilfjalifjileajfeliajeiflajliefajlifjalvlajalvliajvl ieljaf a\t\t\n\rliejailf jail lifeji"
  val per-char = s
    .list
    .foldl(bytesb/empty()) fn(bytesb, char)
      bytesb.append(char.int.int8)
    .bytes
  assert(per-char.length.show, per-char.length == s.count.ssize_t)
  assert(per-char.string, per-char.string == s)

  val int64s = [0x10, 0x20].map(int64)
  val add-int64 = int64s
    .foldl(bytesb/empty()) fn(bytesb, i)
      bytesb.append(i)
    .bytes
  assert(add-int64.length.show, add-int64.length.int == int64s.length * 8)
  int64s.foldl(add-int64.slice) fn(slice, i1)
    match slice.next-int64
      Just((i2, slice')) ->
        assert(show((i2, i1)), i2 == i1)
        slice'
  val i1 = add-int64.slice.next-int64.unjust.fst
  assert(show(i1), i1 == int64s[0].unjust)
  val i2 = add-int64.slice.next-int64.unjust.fst
  assert(show(i1), i1 == int64s[0].unjust)


  val whole-string = bytesb/empty()
    .append(s.bytes)
    .bytes
  assert(whole-string.string, whole-string.string == s)

  val empty-empty = bytesb/empty()
    .append(bytesb/empty())
    .bytes
  assert(empty-empty.string, empty-empty.string == "")

  val empty-string = bytesb/empty()
    .append(bytesb/empty(n=0.ssize_t).append(s.bytes))
    .bytes
  assert(empty-string.string, empty-string.string == s)
