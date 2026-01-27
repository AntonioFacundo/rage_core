# Game: Run configuration loader. Allowed deps: core types only.
class_name RunConfig

static func load(file_store: IFileStore, path: String) -> Result:
	if file_store == null:
		return Result.err_result("RunConfig.load requires file store")
	var res := file_store.read_text(path)
	if not res.ok:
		return res
	var parsed = JSON.parse_string(String(res.value))
	if not (parsed is Dictionary):
		return Result.err_result("RunConfig invalid JSON: " + path)
	return Result.ok_result(parsed)

static func get_room_limit(config: Dictionary, default_value: int) -> int:
	if not (config is Dictionary):
		return default_value
	var value = config.get("room_limit", default_value)
	if value is int and int(value) > 0:
		return int(value)
	return default_value

static func get_auto_reset(config: Dictionary, default_value: bool) -> bool:
	if not (config is Dictionary):
		return default_value
	if config.has("auto_reset"):
		return bool(config.get("auto_reset"))
	return default_value
