# Game: Player input system. Allowed deps: core types + game types.
class_name PlayerInputSystem
extends SimulationStep

var _player_id: String = "player"

func set_player_id(player_id: String) -> void:
	_player_id = player_id

func run(context: SimulationContext, _delta: float) -> void:
	var input := Movement2DInput.new()
	input.move_x = context.input_snapshot.get_axis(GameConstants.AXIS_MOVE_X)
	if abs(input.move_x) < 0.01:
		var left := context.input_snapshot.is_pressed(GameConstants.ACTION_MOVE_LEFT)
		var right := context.input_snapshot.is_pressed(GameConstants.ACTION_MOVE_RIGHT)
		input.move_x = float(right) - float(left)
	input.move_y = context.input_snapshot.get_axis(GameConstants.AXIS_MOVE_Y)
	if abs(input.move_y) < 0.01:
		var up := context.input_snapshot.is_pressed(GameConstants.ACTION_MOVE_UP)
		var down := context.input_snapshot.is_pressed(GameConstants.ACTION_MOVE_DOWN)
		input.move_y = float(down) - float(up)
	input.jump_pressed = context.input_snapshot.is_just_pressed(GameConstants.ACTION_JUMP)
	input.jump_released = not context.input_snapshot.is_pressed(GameConstants.ACTION_JUMP)
	input.dash_pressed = context.input_snapshot.is_just_pressed(GameConstants.ACTION_DASH)
	context.state.set_movement_input(_player_id, input)
