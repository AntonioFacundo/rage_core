# Game: Canonical state hashing. Allowed deps: core types + game types.
class_name StateHasher

static func hash_canonical_state(canonical: Dictionary) -> String:
	var payload: Array = _sorted_pairs(canonical)
	var json := JSON.stringify(payload, "")
	var h := Fnv1a64.hash_string(json)
	return _u64_to_hex(h)

static func _u64_to_hex(value: int) -> String:
	var chars := "0123456789abcdef"
	var out := ""
	for i in range(16):
		var shift := (15 - i) * 4
		var nibble := (value >> shift) & 0xF
		out += chars[nibble]
	return out

static func _sorted_pairs(data: Dictionary) -> Array:
	var keys := data.keys()
	keys.sort()
	var out: Array = []
	for key in keys:
		out.append([key, data[key]])
	return out
