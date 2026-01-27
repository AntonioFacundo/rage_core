# Tests: Guard against Godot usage in core/game layers. Uses Godot file APIs.
class_name LayerGuardRunner

const BANNED_TOKENS := [
	"extends Node",
	"\\bInput\\.",
	"\\bInputMap\\b",
	"\\bFileAccess\\b",
	"\\bResourceLoader\\b",
	"\\bOS\\.",
	"\\bEngine\\."
]

static func run_all() -> Dictionary:
	var errors: Array = []
	var total := 0
	total += _scan_dir("res://addons/rage_core/core", errors)
	total += _scan_dir("res://addons/rage_core/game", errors)
	return {
		"errors": errors,
		"total": total
	}

static func _scan_dir(path: String, errors: Array) -> int:
	var total := 0
	var dir := DirAccess.open(path)
	if dir == null:
		errors.append("LayerGuardRunner: failed to open " + path)
		return total
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if name != "." and name != "..":
			var full = path + "/" + name
			if DirAccess.dir_exists_absolute(full):
				total += _scan_dir(full, errors)
			elif name.ends_with(".gd"):
				total += 1
				var text := FileAccess.get_file_as_string(full)
				for token in BANNED_TOKENS:
					if _regex_has(text, token):
						errors.append("Forbidden token in " + full + ": " + token)
		name = dir.get_next()
	dir.list_dir_end()
	return total

static func _regex_has(text: String, pattern: String) -> bool:
	var re := RegEx.new()
	if re.compile(pattern) != OK:
		return false
	return re.search(text) != null
