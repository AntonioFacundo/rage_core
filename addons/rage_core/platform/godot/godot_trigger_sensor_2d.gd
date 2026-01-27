# Platform/Godot: ITriggerSensor2D implementation. Allowed deps: Godot APIs only.
class_name GodotTriggerSensor2D
extends ITriggerSensor2D

var _triggers: Array = []

func register_trigger(trigger: Trigger2D) -> void:
	if trigger == null:
		return
	_triggers.append(trigger)

func pop_triggers() -> Array:
	var results := _triggers.duplicate()
	_triggers.clear()
	return results
