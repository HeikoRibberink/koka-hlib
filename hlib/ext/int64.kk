module int64

pub extern ssize_t/int64(x : ssize_t) : int64
  c inline "(int64_t)(#1)"

pub extern uint8/int64(x : int8) : int64
  c inline "(uint64_t)((uint8_t)(#1))"

// Returns the lowest byte of `int64`.
pub extern lowest-byte(x : int64) : int8
  c inline "(uint8_t)((#1) & 0xFF)"

// Returns the byte at position `i`, where i=0 returns the least significant
// byte and i=7 returns the most significant byte.
pub extern byte-at(x : int64, i : int64) : int8
  c inline "(uint8_t)(((#1) >> ((#2) * 8)) & 0xFF)"

// 0x12 34 56 78
