module rect

import hlib/assert
import hlib/ds/indexed

pub struct rect
  x : int
  y : int
  w : int
  h : int

// Automatically generated.
// Equality comparison of the `rect` type.
pub fbip fun rect/(==)(this : rect, other : rect) : e bool
  match (this, other)
    (Rect(x, y, w, h), Rect(x', y', w', h')) -> x == x' && y == y' && w == w' && h == h'

// Automatically generated.
// Shows a string representation of the `rect` type.
pub fun rect/show(this : rect) : e string
  match this
    Rect(x, y, w, h) -> "Rect(x: " ++ x.show ++ ", y: " ++ y.show ++ ", w: " ++ w.show ++ ", h: " ++ h.show ++ ")"

pub fbip fun rect/xy(this : rect) : (int, int)
  val Rect(x, y, _, _) = this
  (x, y)

pub fbip fun rect/wh(this : rect) : (int, int)
  val Rect(_, _, w, h) = this
  (w, h)

fip fun line-slice(l : int, x' : int, l' : int) : (x : int, l : int)
  val new-x =
    if x' >= 0 then
      x'
    else
      l + x'
  val new-l =
    if l' >= 0 then
      l'
    else
      l - new-x + l'
  (new-x, new-l)
  
fip fun slice/defaultarg(x : int, l : int) : int
  if x >= 0 then
    l - x
  else
    ~x

pub fun slice(
  rect : rect, 
  x : int = 0,
  y : int = 0,
  w : int = slice/defaultarg(x, rect.w),
  h : int = slice/defaultarg(y, rect.h),
  ?kk-file-line : string
) : exn rect
  val Rect(rx, ry, rw, rh) = rect
  val (dx, new-w) = line-slice(rw, x, w)
  val (dy, new-h) = line-slice(rh, y, h)
  val new = Rect(rx + dx, ry + dy, new-w, new-h)
  if dx < 0 || dx > rw || 
     dy < 0 || dy > rh || 
     dx + new-w < 0 || dx + new-w > rw || 
     dy + new-h < 0 || dy + new-h > rh 
  then
    throw(show(new) ++ " is not a valid slice of " ++ show(rect) ++ " at " ++ ?kk-file-line)
  else
    new

pub fip fun move(rect : rect, dxy : (int, int)) : rect
  val Rect(x, y, w, h) = rect
  val (dx, dy) = dxy
  Rect(x + dx, y + dy, w, h)

pub fun single(rect : rect, x : int, y : int) : exn rect
  val Rect(rx, ry, rw, rh) = rect
  val new = Rect(rx + x, ry + y, 1, 1)
  if x < 0 || x >= rw || y < 0 || y >= rh then
    throw(show((x, y)) ++ " is not a valid index in " ++ show(rect))
  else
    new

pub fun foreach(rect : rect, action : (int, int) -> e ()) : e ()
  val Rect(rx, ry, rw, rh) = rect
  for(rx, rx + rw - 1) fn(x)
    for(ry, ry + rh - 1) fn(y)
      action(x, y)

pub fun test()
  val r = Rect(3, 4, 7, 3)
  assert-eq(r.slice(x=2), Rect(5, 4, 5, 3), "slice x")
  assert-eq(r.slice(y= -2), Rect(3,5,7,2), "slice -y")
  assert-eq(r.slice(h= -2), Rect(3,4,7,1), "slice -h")
  assert-eq(r.slice(x= -3,w= -3), Rect(6,4,1,3), "slice -x,-w")
  assert-eq(r.slice(x= 2,w= -3, y=3), Rect(5,7,2,0), "Slice x,-w,y")
