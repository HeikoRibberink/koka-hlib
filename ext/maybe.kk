module maybe

pub fun expect(m: maybe<a>, msg: string): exn a
  match m
    Just(a) -> a
    Nothing -> throw("Expected `" ++ msg ++ "`")

