# Core: 2D hit data. Allowed deps: core types only.
class_name Hit2D

var attacker_id: String
var target_id: String
var point: Vec2
var normal: Vec2
var damage: int
var tags: Array

func _init(
		attacker: String,
		target: String,
		hit_point: Vec2,
		hit_normal: Vec2,
		hit_damage: int,
		hit_tags: Array
	) -> void:
	attacker_id = attacker
	target_id = target
	point = hit_point
	normal = hit_normal
	damage = hit_damage
	tags = hit_tags
