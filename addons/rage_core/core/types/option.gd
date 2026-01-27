# Core: Option type for explicit presence/absence. Allowed deps: none.
class_name Option

var has_value: bool = false
var value = null

static func some(v) -> Option:
	var o := Option.new()
	o.has_value = true
	o.value = v
	return o

static func none() -> Option:
	return Option.new()
