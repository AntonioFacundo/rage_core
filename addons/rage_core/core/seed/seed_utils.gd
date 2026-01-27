# Core: Seed utilities (base36 seed8). Allowed deps: core types only.
class_name SeedUtils

const BASE36 := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

static func normalize_seed8(value: String) -> String:
	return value.strip_edges().to_upper()

static func validate_seed8(value: String) -> bool:
	var v := normalize_seed8(value)
	if v.length() != 8:
		return false
	for i in range(v.length()):
		if BASE36.find(v[i]) == -1:
			return false
	return true

static func seed64_from_seed8(value: String) -> int:
	var v := normalize_seed8(value)
	if not validate_seed8(v):
		return 0
	return Fnv1a64.hash_string(v)
