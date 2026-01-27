# Game: Pickup system (trigger -> event). Allowed deps: core types + game types.
class_name PickupSystem
extends SimulationStep

func run(context: SimulationContext, _delta: float) -> void:
	var triggers: Array = context.state.get_trigger_buffer()
	for entry in triggers:
		_process_trigger(context, entry)

func _process_trigger(context: SimulationContext, trigger: Trigger2D) -> void:
	if trigger == null or not (trigger is Trigger2D):
		return
	if trigger.action != "enter":
		return
	if not Ids.is_valid_id(trigger.trigger_id):
		return
	var def := context.content_registry.get_by_id(trigger.trigger_id)
	if def == null:
		context.logger.error("PickupSystem: missing content id " + trigger.trigger_id)
		return
	var event := PickupEvent.new(trigger.trigger_id, trigger.target_id, trigger.tags)
	var result := context.bus.emit(event)
	if not result.ok:
		context.logger.error("PickupSystem emit failed: " + str(result.error))
