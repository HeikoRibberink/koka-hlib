module indexed

// An index of type `i` into a collection.
// Use 
// * `index` to retrieve the index.
// * `next` to advance the index.
pub linear effect indexed<i>
  // Get the index.
  fun index() : i
  // Advance the index.
  fun next() : ()

// Execute action with an index into `indexable` using effect `indexed`.
// This is can be used for iterators that do not have an `indexed` variant.
// # Example
// ```kk
// val vec = [1, 2, 3].vector
// val new =
//   with index-in(vec)
//   vec.map fn(x)
//     println("vec[" ++ index().show() ++ "] = " ++ x.show())
//     next()
//     index()
// assert("`new` should equal `[1, 2, 3]`", new == vec)
// ```
// # Note on custom collections
// To use `index-in` with a custom collection, there must be a function
// `into-indexer` that maps that collection to an indexer function, which maps
// an integer to an index for that collection.
pub fun index-in(indexable : a, action : () -> <indexed<i>|e> b, ?into-indexer : a -> e (int -> e i)) : e b
  val indexer = mask<local<_>> {into-indexer(indexable)}
  var i := 0
  with handler
    fun index()
      val temp = i
      mask<local<_>>{indexer(temp)}
    fun next()
      i := i + 1
  action()

// Advances the index after executing `action`.
// # Example
// ```kk
// val vec = [1, 2, 3].vector
// val new =
//   with index-in(vec)
//   vec.map fn(x)
//     with i <- loop-increment
//     x * i
// assert("`new` should equal `[0, 2, 6]`", new == [0, 2, 6].vector)
// ```
pub fun loop-increment(action : (i) -> e a) : <indexed<i>|e> a
  val i = index()
  val out = mask<indexed<_>> {action(i)}
  next()
  out

pub fun vector/into-indexer(v : vector<a>) : (int -> e int)
  fn(x) x

pub fun list/into-indexer(l : list<a>) : (int -> e int)
  fn(x) x
