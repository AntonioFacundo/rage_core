# Core: FNV-1a 64-bit hash. Allowed deps: core types only.
class_name Fnv1a64

const PRIME := 1099511628211
const MASK_64 := -1
const MASK_32 := 0xFFFFFFFF

static func hash_string(text: String) -> int:
	var h := _offset_basis()
	var bytes := text.to_utf8_buffer()
	for b in bytes:
		h = int((h ^ int(b)) * PRIME) & MASK_64
	return h

static func hash_u64(value: int) -> int:
	var h := _offset_basis()
	for i in range(8):
		var byte := (value >> (i * 8)) & 0xFF
		h = int((h ^ int(byte)) * PRIME) & MASK_64
	return h

static func _offset_basis() -> int:
	return _u64(0xCBF29CE4, 0x84222325)

static func _u64(hi: int, lo: int) -> int:
	return ((hi & MASK_32) << 32) | (lo & MASK_32)
