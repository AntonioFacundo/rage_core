# Game: Content definition value object. Allowed deps: core types + game types.
class_name ContentDef

var id: String
var type_id: String
var data: Dictionary
var source_mod: String

func _init(def_id: String, def_type: String, def_data: Dictionary, mod_id: String) -> void:
	id = def_id
	type_id = def_type
	data = def_data
	source_mod = mod_id

func validate() -> Result:
	if not Ids.is_valid_id(id):
		return Result.err_result("Invalid content id: " + id)
	if not Ids.is_valid_id(type_id):
		return Result.err_result("Invalid content type: " + type_id)
	if not GameConstants.has_content_type(type_id):
		return Result.err_result("Unknown content type: " + type_id)
	if source_mod == "":
		return Result.err_result("Missing content source_mod")
	return Result.ok_result(true)
