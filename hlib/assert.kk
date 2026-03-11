module assert

pub fun assert-eq(l : a, r : a, msg : string = "", ?(==) : (a,a) -> <exn|e> bool, ?show : a -> <exn|e> string, ?kk-file-line : string) : <exn|e> ()
  if l == r then
    ()
  else
    val msg' = if msg.is-empty() then "" else "'" ++ msg ++ "' "
    throw("Assertion " ++ msg' ++ "failed: " ++ show(l) ++ " == " ++ show(r) ++ " at " ++ ?kk-file-line)
