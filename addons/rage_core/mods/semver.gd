# Mods: Minimal semver parser and matcher. Allowed deps: core types only.
class_name SemVer

var major: int
var minor: int
var patch: int

func _init(_major: int, _minor: int, _patch: int) -> void:
	major = _major
	minor = _minor
	patch = _patch

static func parse(version: String) -> Result:
	var parts := version.split(".")
	if parts.size() != 3:
		return Result.err_result("Invalid version: " + version)
	if not _is_int(parts[0]) or not _is_int(parts[1]) or not _is_int(parts[2]):
		return Result.err_result("Invalid version: " + version)
	return Result.ok_result(SemVer.new(int(parts[0]), int(parts[1]), int(parts[2])))

static func compare(a: SemVer, b: SemVer) -> int:
	if a.major != b.major:
		return _cmp(a.major, b.major)
	if a.minor != b.minor:
		return _cmp(a.minor, b.minor)
	return _cmp(a.patch, b.patch)

static func satisfies(version: String, constraint: String) -> bool:
	var ver_result := parse(version)
	if not ver_result.ok:
		return false
	var ver: SemVer = ver_result.value

	constraint = constraint.strip_edges()
	if constraint.begins_with("^"):
		var base := parse(constraint.substr(1, constraint.length() - 1))
		if not base.ok:
			return false
		return _in_range(ver, base.value, SemVer.new(base.value.major + 1, 0, 0))
	if constraint.begins_with("~"):
		var base2 := parse(constraint.substr(1, constraint.length() - 1))
		if not base2.ok:
			return false
		return _in_range(ver, base2.value, SemVer.new(base2.value.major, base2.value.minor + 1, 0))

	if constraint.find(" ") != -1:
		var parts := constraint.split(" ", false)
		for part in parts:
			if part == "":
				continue
			if not _eval_range(ver, part):
				return false
		return true

	var exact := parse(constraint)
	if not exact.ok:
		return false
	return compare(ver, exact.value) == 0

static func _eval_range(ver: SemVer, expr: String) -> bool:
	if expr.begins_with(">="):
		var r := parse(expr.substr(2, expr.length() - 2))
		return r.ok and compare(ver, r.value) >= 0
	if expr.begins_with("<="):
		var r2 := parse(expr.substr(2, expr.length() - 2))
		return r2.ok and compare(ver, r2.value) <= 0
	if expr.begins_with(">"):
		var r3 := parse(expr.substr(1, expr.length() - 1))
		return r3.ok and compare(ver, r3.value) > 0
	if expr.begins_with("<"):
		var r4 := parse(expr.substr(1, expr.length() - 1))
		return r4.ok and compare(ver, r4.value) < 0
	return false

static func _in_range(ver: SemVer, min_v: SemVer, max_v: SemVer) -> bool:
	return compare(ver, min_v) >= 0 and compare(ver, max_v) < 0

static func _cmp(a: int, b: int) -> int:
	if a < b:
		return -1
	if a > b:
		return 1
	return 0

static func _is_int(value: String) -> bool:
	for i in value.length():
		var c := value[i]
		if c < "0" or c > "9":
			return false
	return true
