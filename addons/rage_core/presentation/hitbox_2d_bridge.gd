# Presentation: Hitbox that reports hits to the kernel. Allowed deps: Godot APIs + kernel.
extends Area2D
class_name Hitbox2DBridge

@export var attacker_id: String = "player"
@export var damage: int = 1
@export var tags: Array = []
@export var kernel_path: NodePath = NodePath("/root/Kernel")

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	var kernel := get_node_or_null(kernel_path)
	if kernel == null:
		push_error("Hitbox2DBridge: Kernel not found at " + str(kernel_path))
		return
	if not kernel.has_method("register_hit"):
		push_error("Hitbox2DBridge: Kernel missing register_hit")
		return
	if not body.has_method("get_instance_id"):
		return
	var target_id := body.name
	var hit := Hit2D.new(
		attacker_id,
		target_id,
		Vec2.new(global_position.x, global_position.y),
		Vec2.new(0.0, 0.0),
		damage,
		tags
	)
	kernel.register_hit(hit)
