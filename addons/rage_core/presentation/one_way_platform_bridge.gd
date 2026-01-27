# Presentation: One-way platform helper. Allowed deps: Godot APIs only.
extends StaticBody2D
class_name OneWayPlatformBridge

@export var collision_shape_path: NodePath
@export var one_way_enabled: bool = true
@export var one_way_margin: float = 4.0

func _ready() -> void:
	_apply_settings()

func set_one_way_enabled(enabled: bool) -> void:
	one_way_enabled = enabled
	_apply_settings()

func _apply_settings() -> void:
	if collision_shape_path == NodePath():
		return
	var shape := get_node_or_null(collision_shape_path)
	if shape == null:
		return
	if shape is CollisionShape2D:
		shape.one_way_collision = one_way_enabled
		shape.one_way_collision_margin = one_way_margin
