# Platform/Godot: ISaveStore implementation using FileAccess. Allowed deps: Godot APIs only.
class_name GodotSaveStore
extends ISaveStore

var _base_path := "user://saves"

func save_json(key: String, data: Dictionary) -> Result:
	if key == "":
		return Result.err_result("Save key is empty")
	var dir_ok := DirAccess.make_dir_recursive_absolute(_base_path)
	if dir_ok != OK:
		return Result.err_result("Failed to create save dir: " + _base_path)
	var path := _base_path + "/" + key + ".json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return Result.err_result("Failed to open save file: " + path)
	file.store_string(JSON.stringify(data))
	return Result.ok_result(true)

func load_json(key: String) -> Result:
	if key == "":
		return Result.err_result("Save key is empty")
	var path := _base_path + "/" + key + ".json"
	if not FileAccess.file_exists(path):
		return Result.err_result("Save not found: " + path)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return Result.err_result("Failed to open save file: " + path)
	var text := file.get_as_text()
	var parsed = JSON.parse_string(text)
	if parsed == null:
		return Result.err_result("Invalid JSON in save: " + path)
	if not (parsed is Dictionary):
		return Result.err_result("Save data is not a dictionary: " + path)
	return Result.ok_result(parsed)

func delete(key: String) -> Result:
	if key == "":
		return Result.err_result("Save key is empty")
	var path := _base_path + "/" + key + ".json"
	if not FileAccess.file_exists(path):
		return Result.ok_result(true)
	var err := DirAccess.remove_absolute(path)
	if err != OK:
		return Result.err_result("Failed to delete save: " + path)
	return Result.ok_result(true)
