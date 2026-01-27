# Presentation: Registers a body with the kernel physics adapter. Allowed deps: Godot APIs + kernel.
extends CharacterBody2D
class_name PlayerBodyBridge

@export var body_id: String = "player"
@export var kernel_path: NodePath = NodePath("/root/Kernel")

func _ready() -> void:
	var kernel := get_node_or_null(kernel_path)
	if kernel == null:
		push_error("PlayerBodyBridge: Kernel not found at " + str(kernel_path))
		return
	if not kernel.has_method("register_body"):
		push_error("PlayerBodyBridge: Kernel missing register_body")
		return
	var result = kernel.register_body(body_id, self)
	if result is Result and not result.ok:
		push_error("PlayerBodyBridge: register_body failed " + str(result.error))
