# Game: Surface system (enter/exit multipliers). Allowed deps: core types + game types.
class_name SurfaceSystem
extends SimulationStep

func run(context: SimulationContext, _delta: float) -> void:
	var triggers: Array = context.state.get_trigger_buffer()
	for entry in triggers:
		_process_trigger(context, entry)

func _process_trigger(context: SimulationContext, trigger: Trigger2D) -> void:
	if trigger == null or not (trigger is Trigger2D):
		return
	var def := context.content_registry.get_by_id(trigger.trigger_id)
	if def == null:
		return
	if def.type_id != GameConstants.CONTENT_SURFACE:
		return
	if trigger.action == "enter":
		var factors := _factors_from_def(def)
		context.state.set_surface_factors(trigger.target_id, factors)
	elif trigger.action == "exit":
		context.state.set_surface_factors(trigger.target_id, {})

func _factors_from_def(def: ContentDef) -> Dictionary:
	var data := def.data
	return {
		"max_speed_mult": float(data.get("max_speed_mult", 1.0)),
		"accel_mult": float(data.get("accel_mult", 1.0)),
		"decel_mult": float(data.get("decel_mult", 1.0))
	}
