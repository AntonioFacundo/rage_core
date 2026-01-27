# Platform/Godot: ILogger implementation using Godot printing. Allowed deps: Godot APIs only.
class_name GodotLogger
extends ILogger

func info(message: String) -> void:
	print(message)

func warn(message: String) -> void:
	push_warning(message)

func error(message: String) -> void:
	push_error(message)
