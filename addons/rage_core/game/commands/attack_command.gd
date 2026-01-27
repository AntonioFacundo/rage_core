# Game: Attack command data. Allowed deps: core types + game constants.
class_name AttackCommand
extends ICommand

const ID := GameConstants.CMD_ATTACK

var attacker_id: String
var target_id: String
var base_damage: int

func _init(_attacker_id: String, _target_id: String, _base_damage: int) -> void:
	attacker_id = _attacker_id
	target_id = _target_id
	base_damage = _base_damage

func get_id() -> String:
	return ID

func validate() -> Result:
	if not Ids.is_valid_id(attacker_id):
		return Result.err_result("Invalid attacker_id")
	if not Ids.is_valid_id(target_id):
		return Result.err_result("Invalid target_id")
	if base_damage <= 0:
		return Result.err_result("base_damage must be > 0")
	return Result.ok_result(true)
