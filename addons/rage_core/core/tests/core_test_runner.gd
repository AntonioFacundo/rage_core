# Core Tests: Engine-agnostic verification for core utilities.
class_name CoreTestRunner

static func run_all() -> Dictionary:
	var errors: Array = []
	var total := 0
	_test_seed_utils(errors)
	total += 4
	_test_rng_determinism(errors)
	total += 1
	_test_fnv1a_consistency(errors)
	total += 2
	return {
		"errors": errors,
		"total": total
	}

static func _test_seed_utils(errors: Array) -> void:
	_assert(SeedUtils.validate_seed8("A1B2C3D4"), "SeedUtils.validate_seed8 should accept base36 seed", errors)
	_assert(SeedUtils.validate_seed8("a1b2c3d4"), "SeedUtils.validate_seed8 should accept lowercase", errors)
	_assert(not SeedUtils.validate_seed8("A1B2C3D"), "SeedUtils.validate_seed8 should reject short seeds", errors)
	_assert(not SeedUtils.validate_seed8("A1B2C3D!"), "SeedUtils.validate_seed8 should reject invalid chars", errors)

static func _test_rng_determinism(errors: Array) -> void:
	var rng_a := DeterministicRng.new()
	var rng_b := DeterministicRng.new()
	rng_a.seed(123456)
	rng_b.seed(123456)
	for i in range(10):
		var a := rng_a.next_u64()
		var b := rng_b.next_u64()
		if a != b:
			_assert(false, "DeterministicRng sequence mismatch at index " + str(i), errors)
			return

static func _test_fnv1a_consistency(errors: Array) -> void:
	var h1 := Fnv1a64.hash_string("TEST")
	var h2 := Fnv1a64.hash_string("TEST")
	var h3 := Fnv1a64.hash_string("TEST2")
	_assert(h1 == h2, "Fnv1a64 hash should be stable", errors)
	_assert(h1 != h3, "Fnv1a64 hash should differ for different input", errors)

static func _assert(condition: bool, message: String, errors: Array) -> void:
	if not condition:
		errors.append(message)
