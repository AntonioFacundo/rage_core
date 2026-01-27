# Core: Error types and helpers. Allowed deps: core types only.
class_name CoreErrors

class ValidationError:
	var message: String
	var field: String

	func _init(_message: String, _field: String = "") -> void:
		message = _message
		field = _field

	func to_string() -> String:
		if field != "":
			return "ValidationError(" + field + "): " + message
		return "ValidationError: " + message

class ModLoadError:
	var message: String

	func _init(_message: String) -> void:
		message = _message

	func to_string() -> String:
		return "ModLoadError: " + message

class DependencyError:
	var message: String

	func _init(_message: String) -> void:
		message = _message

	func to_string() -> String:
		return "DependencyError: " + message
