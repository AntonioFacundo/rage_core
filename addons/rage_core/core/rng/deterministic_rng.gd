# Core: Deterministic RNG (splitmix64 + xorshift128+). Allowed deps: core types only.
class_name DeterministicRng
extends IRng

const MASK_64 := -1
const MASK_32 := 0xFFFFFFFF

var _s0: int = 0
var _s1: int = 0

func seed(seed64: int) -> void:
	var sm := _splitmix64(seed64)
	_s0 = _splitmix64(sm)
	_s1 = _splitmix64(_s0)
	if _s0 == 0 and _s1 == 0:
		_s1 = 1

func next_u32() -> int:
	return int(next_u64() & 0xFFFFFFFF)

func next_u64() -> int:
	var s1 := _s0
	var s0 := _s1
	_s0 = s0
	s1 ^= (s1 << 23) & MASK_64
	s1 ^= (s1 >> 17) & MASK_64
	s1 ^= s0
	s1 ^= (s0 >> 26) & MASK_64
	_s1 = s1
	return int((_s0 + _s1) & MASK_64)

func next_float01() -> float:
	var value := next_u64()
	var denom := 18446744073709551615.0
	return float(value) / denom

func range_int(min_inclusive: int, max_inclusive: int) -> int:
	if max_inclusive <= min_inclusive:
		return min_inclusive
	var span := max_inclusive - min_inclusive + 1
	return min_inclusive + int(next_u64() % span)

func _splitmix64(x: int) -> int:
	var gamma := _u64(0x9E3779B9, 0x7F4A7C15)
	var m1 := _u64(0xBF58476D, 0x1CE4E5B9)
	var m2 := _u64(0x94D049BB, 0x133111EB)
	var z := (x + gamma) & MASK_64
	z = (z ^ (z >> 30)) * m1 & MASK_64
	z = (z ^ (z >> 27)) * m2 & MASK_64
	return int(z ^ (z >> 31))

func _u64(hi: int, lo: int) -> int:
	return ((hi & MASK_32) << 32) | (lo & MASK_32)
