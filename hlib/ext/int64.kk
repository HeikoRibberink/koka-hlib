module int64

pub extern ssize_t/int64(x : ssize_t) : int64
  c inline "(int64_t)(#1)"

pub extern uint8/int64(x : int8) : int64
  c inline "(uint64_t)((uint8_t)(#1))"

// Returns the lowest byte of `int64`.
pub extern lowest-byte(x : int64) : int8
  c inline "(uint8_t)((#1) & 0xFF)"
