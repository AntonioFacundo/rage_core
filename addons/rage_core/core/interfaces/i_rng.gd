# Core: Deterministic RNG interface. Allowed deps: core types only.
class_name IRng

func seed(_seed64: int) -> void:
	pass

func next_u32() -> int:
	return 0

func next_u64() -> int:
	return 0

func next_float01() -> float:
	return 0.0

func range_int(_min_inclusive: int, _max_inclusive: int) -> int:
	return 0
