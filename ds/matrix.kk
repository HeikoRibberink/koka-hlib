module matrix

import hlib/ds/indexed
import hlib/ext/vector
import hlib/patterns/exit

// An index into a matrix
pub alias idx = (int, int)

pub fun idx/i((i, _) : idx) : int
  i

pub fun idx/j((_, j) : idx) : int
  j

pub fun idx/int((i, j) : idx, cols : int) : int
  i * cols + j

pub fun int/idx(i : int, cols : int) : idx
  (i / cols, i % cols)

pub fun into-indexer(mat : matrix<a>) : (int -> e idx)
  val cols = mat.cols
  fn(i : int)
    idx(i, cols)


// A 2d matrix backed by a vector.
pub value struct matrix<a>
  rows : int
  cols : int
  data : vector<a>

// Create a new matrix of `rows` by `cols` with elements given by function `f`.
pub fun func/matrix(rows : int, cols : int, f : idx -> e a) : e matrix<a>
  val data = vector-init(rows * cols) fn(i)
    f(i.idx(cols))
  Matrix(rows, cols, data)

// Create a new matrix from a list of lists `ll`.
// Returns Nothing if `ll` is not square.
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

fun check-idx(^mat : matrix<a>, idx : idx) : bool
  val (r, c) = idx
  if r >= 0 && r < mat.rows && c >= 0 && c < mat.cols then
    True
  else 
    False
  

pub fun @index(^mat : matrix<a>, idx : idx) : exn a
  match mat.at(idx)
    Just(x) -> x
    Nothing -> throw("Index " ++ show(idx) ++ " out of bounds")

pub fun at(^mat : matrix<a>, ^idx : idx) : maybe<a>
  if mat.check-idx(idx) then
    val i = idx.int(mat.cols)
    mat.data.at(i)
  else 
    Nothing

pub fun set(mat : matrix<a>, idx : idx, new : a) : pure matrix<a>
  val Matrix(r, c, d) = mat
  if mat.check-idx(idx) then
    var data := d
    data[idx.int(c)] := new
    Matrix(r, c, data)
  else
    throw("Index " ++ idx.show ++ " out of bounds.")

pub fun local-var/assign/@index(mat : local-var<h, matrix<a>>, idx : idx, assigned : a) : <local<h>,pure> ()
  mat := mat.set(idx, assigned)

pub fun ref/assign/@index(mat : ref<h, matrix<a>>, idx : idx, assigned : a) : <read<h>,write<h>,pure> ()
  mat.modify fn(m)
    m[idx] := assigned

pub fun show(mat : matrix<a>, ?show : a -> e string) : e string
  var repr := ""
  val width = mat.cols - 1
  val height = mat.rows - 1
  mat.foreach-indexed fn(i, elem)
    val showed = mask<local<_>> {show(elem)}
    val add =
      match i
        (0, 0) -> 
          "[[" ++ showed ++ ", "
        (_, 0) ->
          " [" ++ showed ++ ", "
        (r, c) | r == height && c == width ->
          showed ++ "]]"
        (_, c) | c == width ->
          showed ++ "],\n"
        (_, _) ->
          showed ++ ", "
    repr := repr ++ add
  repr

pub fun foreach-indexed(^mat : matrix<a>, ^f : (idx, a) -> _ ())
  mat.data.foreach-indexed fn(i, e)
    f(i.idx(mat.cols), e)

pub fun foreach(^mat : matrix<a>, f : a -> e ()) : e ()
  mat.data.foreach(f)

pub fun foldl(mat : matrix<a>, s : b, ^f : (b, a) -> <index<idx>|e> b) : e b
  with index-in(mat)
  mat.data.foldl(s, i = 0) fn(state, e)
    with auto-increment
    f(state, e)
  
pub fun map(mat : matrix<a>, ^f : (idx, a) -> e b) : e matrix<b>
  var flat-idx := 0
  val cols = mat.cols
  val new-data = 
    mat.data.vector/map fn(e)
      val idx = flat-idx.idx(cols)
      val res = mask<local<_>> {f(idx, e)}
      flat-idx := flat-idx + 1
      res
  Matrix(mat.rows, cols, new-data)

pub fun find-all(^mat : matrix<a>, ^f : a -> _ bool) : _ list<a>
  var res := Nil
  mat.data.foreach fn(e)
    val b = mask<local<_>>{mask<div>{f(e)}}
    if b then
      res := Cons(e, res)
  res

// Create a `matrix<char>` from `text`, consisting of multiple lines.
pub fun string/charmatrix(text : string) : maybe<matrix<char>>
  text
  .lines
  .map(list)
  .remove(is-nil)
  .matrix

pub fun charmatrix/join-rows(mat : matrix<char>, sep : char) : exn string
  vector-init(mat.rows * (mat.cols + 1)) fn(index)
    val (i, j) = index.idx(mat.cols + 1)
    if j < mat.cols then
      mat[(i, j)]
    else
      sep
  .string
 
  
