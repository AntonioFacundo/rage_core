# Platform/Godot: ICombatSensor2D implementation. Allowed deps: Godot APIs only.
class_name GodotCombatSensor2D
extends ICombatSensor2D

var _hits: Array = []

func register_hit(hit: Hit2D) -> void:
	if hit == null:
		return
	_hits.append(hit)

func pop_hits() -> Array:
	var results := _hits.duplicate()
	_hits.clear()
	return results
