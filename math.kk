module math

pub alias ivec2 = (int, int)

pub fip fun pair/(+)(l : (a, b), r : (a, b), ^?a/(+) : (a, a) -> e a, ^?b/(+) : (b, b) -> e b) : e (a, b)
  val ((a, b), (c, d)) = (l, r)
  (a + c, b + d)

pub fip fun pair/(-)(l : (a, b), r : (a, b), ^?a/(-) : (a, a) -> e a, ^?b/(-) : (b, b) -> e b) : e (a, b)
  val (la, lb) = l
  val (ra, rb) = r
  (la - ra, lb - rb)

pub fun pair/(*)(l : (a, a), c : a, ^?(*) : (a, a) -> e a) : e (a, a)
  val (a, b) = l
  (a * c, b * c)
