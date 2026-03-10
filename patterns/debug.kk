effect fun log() : ()

// Deprecated:
// Made obsolete by `trace-show`, which is the better version of this.
fun logger(action)
  var n := 1
  with handler
    fun log()
      println("log point " ++ n.show)
      n := n + 1
  action()
    
fun inline-print(x, ?show)
  x.println
  x
