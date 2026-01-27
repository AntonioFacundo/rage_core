# Platform/Godot: IClock implementation using Time. Allowed deps: Godot APIs only.
class_name GodotClock
extends IClock

func now_msec() -> int:
	return Time.get_ticks_msec()
