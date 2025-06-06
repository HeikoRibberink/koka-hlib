module common

pub fun peep(x, action)
  action(x)
  x

pub fun todo(?kk-file-line : string) : exn a
  throw("TODO reached at " ++ kk-file-line)

