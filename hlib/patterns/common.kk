module common

// Inspect a list of dot selections without breaking the line.
// # Example
// ```koka
// [1, 2, 3].map(_ * 2).peep(println).sum
// ```
pub fun peep(x : a, action : a -> e ()) : e a
  action(x)
  x

pub fun todo(?kk-file-line : string) : exn a
  throw("TODO reached at " ++ kk-file-line)

pub fun unreachable(?kk-file-line : string) : exn a
  throw("Unreachable reached at " ++ kk-file-line)

pub fip fun infinite-loop(^action : () -> <div|e> ()) : <div|e> a
  action()
  infinite-loop(action)

// Keep calling `action` while it returns Nothing.
// When `action` returns `Just(x), return `x`.`
pub fip fun while-nothing(^action : () -> <div|e> maybe<a>) : <div|e> a
  match action()
    Just(res) -> res
    Nothing -> action.while-nothing

pub fip fun while-true(^action : () -> <div|e> bool) : <div|e> ()
  if action() then
    action.while-true
