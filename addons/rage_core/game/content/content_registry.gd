# Game: Content registry for mods. Allowed deps: core types + game types.
class_name ContentRegistry

var _by_id := {}

func register(definition: ContentDef) -> Result:
	if definition == null or not (definition is ContentDef):
		return Result.err_result("ContentRegistry.register requires ContentDef")
	var validation := definition.validate()
	if not validation.ok:
		return validation
	if _by_id.has(definition.id):
		return Result.err_result("Duplicate content id: " + definition.id)
	_by_id[definition.id] = definition
	return Result.ok_result(true)

func get_by_id(content_id: String) -> ContentDef:
	return _by_id.get(content_id, null)

func list_by_type(type_id: String) -> Array:
	var results: Array = []
	var keys := _by_id.keys()
	keys.sort()
	for key in keys:
		var def: ContentDef = _by_id[key]
		if def.type_id == type_id:
			results.append(def)
	return results
