# Game: Content pack loader (dictionary-based). Allowed deps: core types + game types.
class_name ContentPackLoader

var _registry: ContentRegistry

func _init(registry: ContentRegistry) -> void:
	_registry = registry

func load_pack_data(pack: Dictionary, source_mod: String) -> Result:
	if not pack.has("contents") or not (pack["contents"] is Array):
		return Result.err_result("Content pack missing contents array")
	var contents: Array = pack["contents"]
	var errors: Array = []
	var index := 0
	for entry in contents:
		var entry_label := "index " + str(index)
		if not (entry is Dictionary):
			errors.append("Invalid content entry at " + entry_label)
			index += 1
			continue
		var content_id = entry.get("id", null)
		if not (content_id is String) or String(content_id) == "":
			errors.append("Content entry missing id at " + entry_label)
			index += 1
			continue
		var content_type = entry.get("type", null)
		if not (content_type is String) or String(content_type) == "":
			errors.append("Content entry missing type at " + entry_label + " id=" + String(content_id))
			index += 1
			continue
		var data = entry.get("data", null)
		if not (data is Dictionary):
			errors.append("Content entry data must be Dictionary at " + entry_label + " id=" + String(content_id))
			index += 1
			continue
		var content_id_str := String(content_id)
		var content_type_str := String(content_type)
		var def := ContentDef.new(content_id_str, content_type_str, data, source_mod)
		var res := _registry.register(def)
		if not res.ok:
			errors.append(res.error)
		index += 1
	if errors.size() > 0:
		return Result.err_result(errors)
	return Result.ok_result(true)
