# Presentation: Trigger volume that reports overlaps to the kernel. Allowed deps: Godot APIs + kernel.
extends Area2D
class_name Trigger2DBridge

@export var trigger_id: String = ""
@export var tags: Array = []
@export var kernel_path: NodePath = NodePath("/root/Kernel")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if trigger_id == "":
		return
	var kernel := get_node_or_null(kernel_path)
	if kernel == null:
		push_error("Trigger2DBridge: Kernel not found at " + str(kernel_path))
		return
	if not kernel.has_method("register_trigger"):
		push_error("Trigger2DBridge: Kernel missing register_trigger")
		return
	var target_id := body.name
	var trigger := Trigger2D.new(
		trigger_id,
		target_id,
		Vec2.new(global_position.x, global_position.y),
		tags,
		"enter"
	)
	kernel.register_trigger(trigger)

func _on_body_exited(body: Node) -> void:
	if trigger_id == "":
		return
	var kernel := get_node_or_null(kernel_path)
	if kernel == null:
		return
	if not kernel.has_method("register_trigger"):
		return
	var target_id := body.name
	var trigger := Trigger2D.new(
		trigger_id,
		target_id,
		Vec2.new(global_position.x, global_position.y),
		tags,
		"exit"
	)
	kernel.register_trigger(trigger)
