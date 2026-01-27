# Presentation: Camera2D follow with smoothing, look-ahead, and shake. Allowed deps: Godot APIs only.
extends Camera2D
class_name Camera2DController

@export var target_path: NodePath
@export var follow_speed: float = 8.0
@export var lookahead_distance: float = 64.0
@export var use_limits: bool = false
@export var shake_strength: float = 0.0
@export var shake_decay: float = 10.0

var _target: Node2D
var _last_target_pos := Vector2.ZERO
var _shake_offset := Vector2.ZERO

func _ready() -> void:
	if target_path != NodePath():
		_target = get_node_or_null(target_path)
	if _target != null:
		_last_target_pos = _target.global_position

func _process(delta: float) -> void:
	if _target == null:
		return
	var target_pos := _target.global_position
	var velocity = (target_pos - _last_target_pos) / max(0.0001, delta)
	_last_target_pos = target_pos

	var lookahead := Vector2.ZERO
	if velocity.length() > 0.01:
		lookahead = velocity.normalized() * lookahead_distance

	var desired := target_pos + lookahead
	desired = _apply_limits(desired)
	global_position = global_position.lerp(desired, min(1.0, follow_speed * delta)) + _shake_offset

	_update_shake(delta)

func trigger_shake(strength: float) -> void:
	shake_strength = max(shake_strength, strength)

func _update_shake(delta: float) -> void:
	if shake_strength <= 0.0:
		_shake_offset = Vector2.ZERO
		return
	_shake_offset = Vector2(
		randf_range(-shake_strength, shake_strength),
		randf_range(-shake_strength, shake_strength)
	)
	shake_strength = max(0.0, shake_strength - shake_decay * delta)

func _apply_limits(position: Vector2) -> Vector2:
	var result := position
	if use_limits:
		result.x = clamp(result.x, limit_left, limit_right)
		result.y = clamp(result.y, limit_top, limit_bottom)
	return result
