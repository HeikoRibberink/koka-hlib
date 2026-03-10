module generator

import std/core/undiv

pub effect<a> ctl yield(x : a) : ()

pub type generated<a,b,e>
  Final(ret : b)
  Next(elem : a, next : (() -> e generated<a,b,e>))

pub alias generator<a,b,e> = () -> e generated<a,b,e>

pub fun yielder/generator(yielder : () -> <yield<a>|e> b) : (() -> e generated<a,b,e>)
  fn()
    handle(yielder)
      ctl yield(x)
        Next(x,fn() resume(()))
      return(x)
        Final(x)

pub fun iter/generator(iter : ((a) -> <yield<a>|e> ()) -> <yield<a>|e> b) : (() -> e generated<a,b,e>)
  yielder/generator(fn() iter(yield))

pub fun iterable/generator(collection : c<a>, ?foreach : (c<a>, (a) -> <yield<a>|e> ()) -> <yield<a>|e> ()) : (() -> e generated<a,(),e>)
  iter/generator fn(iter) collection.foreach(iter)

pub fun map(generator : (() -> e generated<a,b,e>), f : (a) -> e c) : (() -> e generated<c,b,e>)
  fn()
    match generator()
      Next(elem, next) -> Next(f(elem), map(next.pretend-decreasing, f))
      Final(elem) -> Final(elem)

pub fun foreach(generator : (() -> e generated<a,b,e>), f : (a) -> e ()) : e b
  match generator()
    Next(elem, next) -> 
      f(elem) 
      next.pretend-decreasing.foreach(f)
    Final(ret) -> ret

pub fun list/collect(generator : (() -> e generated<a,(),e>)) : e list<a>
  match generator()
    Final(_ : ()) -> Nil
    Next(elem, next) -> Cons(elem, list/collect(next.pretend-decreasing))

fun main()
  var x := [1, 2, 3].generator
  fun print-one()
    match x()
      Next(elem, next) ->
        x := next
        elem.println
  print-one()
  print-one()

