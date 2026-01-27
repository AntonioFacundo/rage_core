# Core: 2D trigger data. Allowed deps: core types only.
class_name Trigger2D

var trigger_id: String
var target_id: String
var point: Vec2
var tags: Array
var action: String

func _init(trigger: String, target: String, trigger_point: Vec2, trigger_tags: Array, trigger_action: String) -> void:
	trigger_id = trigger
	target_id = target
	point = trigger_point
	tags = trigger_tags
	action = trigger_action
