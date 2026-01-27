# Presentation: Simple moving platform. Allowed deps: Godot APIs only.
extends Node2D
class_name MovingPlatformBridge

@export var move_axis: Vector2 = Vector2(1, 0)
@export var amplitude: float = 64.0
@export var speed: float = 1.0

var _origin := Vector2.ZERO
var _time := 0.0

func _ready() -> void:
	_origin = global_position

func _process(delta: float) -> void:
	_time += delta * speed
	var offset := move_axis.normalized() * sin(_time) * amplitude
	global_position = _origin + offset
