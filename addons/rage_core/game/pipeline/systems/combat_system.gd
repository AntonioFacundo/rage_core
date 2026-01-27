# Game: Combat system (hit processing + i-frames). Allowed deps: core types + game types.
class_name CombatSystem
extends SimulationStep

var _default_invuln: float = 0.15

func run(context: SimulationContext, delta: float) -> void:
	context.state.tick_invuln(delta)
	if context.combat_sensor == null:
		return
	var hits: Array = context.combat_sensor.pop_hits()
	for hit in hits:
		_process_hit(context, hit)

func _process_hit(context: SimulationContext, hit: Hit2D) -> void:
	if hit == null or not (hit is Hit2D):
		return
	if not Ids.is_valid_id(hit.target_id):
		return
	var timer := context.state.get_invuln_timer(hit.target_id)
	if timer > 0.0:
		return
	var invuln := context.state.get_invuln_duration(hit.target_id, _default_invuln)
	context.state.set_invuln_timer(hit.target_id, invuln)
	var result := context.core.apply_damage(hit.attacker_id, hit.target_id, hit.damage, hit.tags)
	if not result.ok:
		context.logger.error("CombatSystem damage failed: " + str(result.error))
