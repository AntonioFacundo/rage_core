# Presentation: HUD controller for health display. Allowed deps: Godot APIs + kernel.
extends CanvasLayer
class_name HUDController

@export var kernel_path: NodePath = NodePath("/root/Kernel")
@export var player_id: String = "player"
@export var health_label_path: NodePath

var _kernel: Node
var _health_label: Label

func _ready() -> void:
	_kernel = get_node_or_null(kernel_path)
	if _kernel == null:
		push_error("HUDController: Kernel not found at " + str(kernel_path))
	if health_label_path != NodePath():
		_health_label = get_node_or_null(health_label_path)

func _process(_delta: float) -> void:
	if _kernel == null or _health_label == null:
		return
	var api = _kernel.get_api()
	if api == null:
		return
	var health = api.get_state().get_health(player_id)
	_health_label.text = "HP: " + str(health)
