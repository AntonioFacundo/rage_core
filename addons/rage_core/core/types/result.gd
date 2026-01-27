# Core: Result type for explicit success/failure. Allowed deps: none.
class_name Result

var ok: bool = false
var value = null
var error = null

static func ok_result(v) -> Result:
	var r := Result.new()
	r.ok = true
	r.value = v
	return r

static func err_result(e) -> Result:
	var r := Result.new()
	r.ok = false
	r.error = e
	return r

func is_ok() -> bool:
	return ok
