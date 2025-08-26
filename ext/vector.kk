module vector
import std/core/undiv

// Performs a fold-left operation on the vector.
pub fun foldl(^v : vector<a>, s : b, f : (b, a) -> e b, i : int = 0) : e b
  match v.at(i)
    Nothing -> s
    Just(e) ->
      val n = f(s, e)
      foldl(pretend-decreasing(v), n, f, i + 1)

pub fun map-indexed(v : vector<a>, f : (int, a) -> e b) : e vector<b>
  var i := -1 
  v.map fn(x)
    i := i + 1
    f(i, x)

pub fun show(v : vector<a>, ?show : a -> _ string) : _ string
  if v.length > 0 then
    val mapped = v.map(show)
    val middle = mapped.foldl(mapped[0], i = 1) fn(s, x)
      s ++ ", " ++ x
    "[" ++ middle ++ "]"
  else
    "[]"

pub fun updated(^v : vector<a>, i : int, assigned : a) : pure vector<a>
  var new := v
  new[i] := assigned
  val res = new
  res

pub fun sum(^v : vector<int>) : int
  v.foldl(0, (+))
