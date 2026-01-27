# Game: Ladder system (enter/exit). Allowed deps: core types + game types.
class_name LadderSystem
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
	if def.type_id != GameConstants.CONTENT_LADDER:
		return
	var state := context.state.get_movement_state(trigger.target_id)
	if trigger.action == "enter":
		state.on_ladder = true
	elif trigger.action == "exit":
		state.on_ladder = false
