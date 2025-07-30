module math

fun pair/(+)(l : (a, b), r : (a, b), ?a/(+) : (a, a) -> e a, ?b/(+) : (b, b) -> e b) : e (a, b)
  val ((a, b), (c, d)) = (l, r)
  (a + c, b + d)

fun pair/(-)(l : (a, b), r : (a, b), ?a/(-) : (a, a) -> e a, ?b/(-) : (b, b) -> e b) : e (a, b)
  val ((a, b), (c, d)) = (l, r)
  (a - c, b - d)

fun pair/(*)(l : (a, a), c : a, ?(*) : (a, a) -> e a) : e (a, a)
  val (a, b) = l
  (a * c, b * c)

fun pair/(/)(l : (a, a), c : a, ?(/) : (a, a) -> e a) : e (a, a)
  val (a, b) = l
  (a / c, b / c)
