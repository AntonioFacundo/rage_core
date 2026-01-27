# Platform/Godot: IFileStore implementation using FileAccess. Allowed deps: Godot APIs only.
class_name GodotFileStore
extends IFileStore

func exists(path: String) -> bool:
	return FileAccess.file_exists(path)

func read_text(path: String) -> Result:
	if not FileAccess.file_exists(path):
		return Result.err_result("File not found: " + path)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return Result.err_result("Failed to open file: " + path)
	return Result.ok_result(file.get_as_text())

func write_text(path: String, content: String) -> Result:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return Result.err_result("Failed to open file: " + path)
	file.store_string(content)
	return Result.ok_result(true)
