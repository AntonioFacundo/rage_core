# Core: Stable id helpers. Allowed deps: none.
class_name Ids

static func is_valid_id(id: String) -> bool:
	return id != "" and id.find(" ") == -1
