effect fun log() : ()

fun logger(action)
  var n := 1
  with handler
    fun log()
      println("Log point " ++ n.show)
      n := n + 1
  action()
    
fun inline-print(x, ?show)
  x.println
  x
