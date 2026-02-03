// Enum typeclass
module enum

pub struct enum<a>
  pub listed : list<a>
  pub int : a -> int

pub fun default/enum(?listed : list<a>, ?int : a -> int) : enum<a>
  Enum(listed, int)

pub fun (==)(l : enum<a>, r : enum<a>, ?(==) : (a, a) -> bool) : bool
  list/(==)(l.listed.map(fn(x) (x, l.int.(x))), r.listed.map(fn(x) (x, l.int.(x))))
