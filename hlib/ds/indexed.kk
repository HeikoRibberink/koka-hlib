module indexed

// An index of type `i` into a collection.
// Use 
// * `index` to retrieve the index.
// * `next` to advance the index.
pub linear effect index<i>
  // Get the index.
  fun index() : i

// Addendum to `index<i>` which allows manually incrementing an index.
pub linear effect incr<i>
  // Advance the index.
  fun next() : ()

// Execute action with an index into `indexable` using effect row `index<i>,incr<i>`.
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
pub fun index-in(indexable : a, action : () -> <index<i>,incr<i>|e> b, ?into-indexer : a -> e (int -> e i)) : e b
  val indexer = mask<local<_>> {into-indexer(indexable)}
  var i := 0
  with handler
    fun index()
      val temp = i
      mask<local<_>>{indexer(temp)}
  with handler
    fun next()
      i := i + 1
  action()

// Executes `action` with the index, while removing the `index<i>` effect.
pub fun take-index(action : (i) -> e a) : <index<i>|e> a
  val i = index()
  with mask<index<_>>
  action(i)

pub fun auto-increment(action : () -> <index<i>|e> a) : <index<i>,incr<i>|e> a
  val out = mask<incr<_>> {action()}
  next()
  out

// Advances the index after executing `action` with the index, while removing
// both the `index<i>` and `incr<i>` effects.
// # Example
// ```kk
// val vec = [1, 2, 3].vector
// val new =
//   with index-in(vec)
//   vec.map fn(x)
//     with i <- take-increment
//     x * i
// assert("`new` should equal `[0, 2, 6]`", new == [0, 2, 6].vector)
// ```
pub fun take-increment(action : (i) -> e a) : <index<i>,incr<i>|e> a
  with auto-increment
  take-index(action)


pub fun vector/into-indexer(v : vector<a>) : (int -> e int)
  fn(x) x

pub fun list/into-indexer(l : list<a>) : (int -> e int)
  fn(x) x

pub fun string/into-indexer(s : string) : (int -> e int)
  fn(x) x
