# Game: Move command data. Allowed deps: core types + game constants.
class_name MoveCommand
extends ICommand

const ID := GameConstants.CMD_MOVE

var entity_id: String
var dir_x: float

func _init(_entity_id: String, _dir_x: float) -> void:
	entity_id = _entity_id
	dir_x = _dir_x

func get_id() -> String:
	return ID

func validate() -> Result:
	if not Ids.is_valid_id(entity_id):
		return Result.err_result("Invalid entity_id")
	if dir_x < -1.0 or dir_x > 1.0:
		return Result.err_result("dir_x out of range")
	return Result.ok_result(true)
