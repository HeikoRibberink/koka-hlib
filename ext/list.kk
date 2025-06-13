module list

type insert-result<a>
  Success(set : list<a>)
  Failure(set : list<a>, elem : a)

fip(1) fun insert-result/cons(res, e)
  match res
    Success(set) -> Success(Cons(e, set))
    Failure(set, elem) -> Failure(Cons(e, set), elem)

fun unique-insert-helper(xs : list<a>, elem : a, ^?cmp : (a, a) -> order) : insert-result<a>
  match xs
    Nil -> Success(Cons(elem, Nil))
    Cons(current, tail) -> 
      if current == elem then
        Failure(Cons(current, tail), elem)
      else
        unique-insert-helper(tail, elem).cons(current)

pub tail fun insert-unique(xs : list<a>, elem : a, ^?(==) : (a, a) -> bool) : list<a>
  match xs
    Nil -> Cons(elem, Nil)
    Cons(current, tail) ->
      if current == elem then
        Cons(current, tail)
      else
        Cons(current, insert-unique(tail, elem))

pub tail fun unique(xs : list<a>, ^?(==) : (a, a) -> bool) : _ list<a>
  match xs
    Nil -> Nil
    Cons(x, xs) ->
      xs.unique().insert-unique(x)

pub fun lst/partition(xs : list<a>, pred : a -> e bool, aux1 : list<a> = [], aux2 : list<a> = []) : e (list<a>, list<a>)
  match xs
    Nil -> (aux1, aux2)
    Cons(x, xs) -> if pred(x) then 
      xs.lst/partition(pred, Cons(x, aux1), aux2) 
    else 
      xs.lst/partition(pred, aux1, Cons(x, aux2))


pub fun lst/qsort(xs : list<a>, ^?(<) : (a, a) -> bool) : div list<a>
  match xs
    Nil -> Nil
    Cons(x, Nil) -> [x]
    Cons(x, xs) -> 
      val (l, r) = xs.lst/partition fn(y) y < x
      l.qsort ++ Cons(x, r.qsort)

pub fip fun map-at(xs : list<a>, i : int, ^f : a -> e a) : e list<a>
  match xs
    xs | i < 0 -> xs
    Nil -> Nil
    Cons(x, xs) | i == 0 -> Cons(f(x), xs)
    Cons(x, xs) -> Cons(x, xs.map-at(i - 1, f))

pub fip fun indexed(xs : list<a>, i : int = 0) : list<(int, a)>
  match xs
    Nil -> Nil
    Cons(x, xs) -> Cons((i, x), xs.indexed(i = i + 1))
