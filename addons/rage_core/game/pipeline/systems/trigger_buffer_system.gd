# Game: Collects trigger events once per frame. Allowed deps: core types + game types.
class_name TriggerBufferSystem
extends SimulationStep

func run(context: SimulationContext, _delta: float) -> void:
	if context.trigger_sensor == null:
		context.state.set_trigger_buffer([])
		return
	var triggers: Array = context.trigger_sensor.pop_triggers()
	context.state.set_trigger_buffer(triggers)
