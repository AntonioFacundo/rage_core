# Core: 2D movement resolution result. Allowed deps: core types only.
class_name Movement2DResult

var contacts: Movement2DContacts
var velocity: Vec2
var position: Vec2

func _init(result_contacts: Movement2DContacts, result_velocity: Vec2, result_position: Vec2) -> void:
	contacts = result_contacts
	velocity = result_velocity
	position = result_position
