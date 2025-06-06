module matrix

import help/lst
import help/exit
import help/util
import help/maybe

import indexed
import vectorext

// An index into a matrix
pub value struct idx
  i : int
  j : int

pub fun idx/(==)(a : idx, b : idx) : bool
  a.i == b.i && a.j == b.j

pub fun idx/(+)(a : idx, b : idx) : idx
  Idx(a.i + b.i, a.j + b.j)

pub fun idx/int(idx : idx, cols : int) : int
  idx.i * cols + idx.j

pub fun idx/show(idx : idx) : string
  "Idx(" ++ idx.i.show ++ ", " ++ idx.j.show ++ ")"

pub fun int/idx(i : int, cols : int) : idx
  Idx(i / cols, i % cols)

pub fun intpair/idx((i, j) : (int, int)) : idx
  Idx(i, j)

pub fun into-indexer(mat : matrix<a>) : (int -> idx)
  val cols = mat.cols
  fn(i : int)
    idx(i, cols)


// An efficient 2d matrix backed by a vector.
pub value struct matrix<a>
  rows : int
  cols : int
  data : vector<a>

pub fun listlist/matrix(ll : list<list<a>>) : maybe<matrix<a>>
  with exit-nothing
  val rows = ll.length
  val cols = ll[0].else-exit.length
  val len = rows * cols
  val flattened = ll.concat
  if flattened.length != len then
    exit(())
  else
    Matrix(rows, cols, flattened.vector)

pub fun @index(^mat : matrix<a>, ^idx : idx) : exn a
  mat.at(idx).expect(idx.show ++ " to be in bounds.")

pub fun at(^mat : matrix<a>, ^idx : idx) : maybe<a>
  val Idx(r, c) = idx
  if r >= 0 && r < mat.rows && c >= 0 && c < mat.rows then
    val i = idx.int(mat.cols)
    mat.data.at(i)
  else 
    Nothing

pub fun set(mat : matrix<a>, idx : idx, new : a) : pure matrix<a>
  var data := mat.data
  data[idx.int(mat.cols)] := new
  mat(data = data)

pub fun assign/@index(mat : local-var<h, matrix<a>>, idx : idx, assigned : a) : <local<h>,pure> ()
  mat := mat.set(idx, assigned)

pub fun show(mat : matrix<a>, ?show : a -> e string) : e string
  var repr := ""
  val width = mat.cols - 1
  val height = mat.rows - 1
  mat.foreach-indexed fn(i, elem)
    val showed = mask<local<_>> {show(elem)}
    val add =
      match i
        Idx(0, 0) -> 
          "[[" ++ showed
        Idx(_, 0) ->
          " [" ++ showed
        Idx(r, c) | r == height && c == width ->
          showed ++ "]]"
        Idx(_, c) | c == width ->
          showed ++ "],\n"
        Idx(_, _) ->
          showed ++ ", "
    repr := repr ++ add
  repr

pub fun foreach-indexed(^mat : matrix<a>, ^f : (idx, a) -> _ ())
  mat.data.foreach-indexed fn(i, e)
    f(i.idx(mat.cols), e)

pub fun foreach(^mat : matrix<a>, f : a -> e ()) : e ()
  mat.data.foreach(f)

pub fun foldl(^mat : matrix<_>, s, ^f, i : int = 0)
  mat.data.foldl(s, f, i)
  
pub fun map-indexed(^mat : matrix<a>, ^f : (idx, a) -> e b) : e matrix<b>
  var flat-idx := 0
  val new-data = 
    mat.data.vector/map fn(e)
      val idx = flat-idx.idx(mat.cols)
      flat-idx := flat-idx + 1
      mask<local<_>>
        f(idx, e)
  Matrix(mat.rows, mat.cols, new-data)

pub fun find-all(^mat : matrix<a>, ^f : a -> _ bool) : _ list<a>
  var res := Nil
  mat.data.foreach fn(e)
    val b = mask<local<_>>{mask<div>{f(e)}}
    if b then
      res := Cons(e, res)
  res

// Create a `matrix<char>` from `text`, consisting of multiple lines.
pub fun charlistlist/charmatrix(text : string) : maybe<matrix<char>>
  text
  .lines
  .map(list)
  .lst/filter([])
  .matrix
