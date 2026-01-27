# Game: Stable ids for events, commands, and tags. Allowed deps: none.
class_name GameConstants

const EVENT_DAMAGE := "game.damage"
const EVENT_ROOM := "game.room"
const EVENT_PICKUP := "game.pickup"

const CMD_ATTACK := "cmd.attack"
const CMD_MOVE := "cmd.move"

const TAG_PHYSICAL := "tag.physical"

const ACTION_MOVE_LEFT := "action.move_left"
const ACTION_MOVE_RIGHT := "action.move_right"
const ACTION_MOVE_UP := "action.move_up"
const ACTION_MOVE_DOWN := "action.move_down"
const ACTION_JUMP := "action.jump"
const ACTION_DASH := "action.dash"
const ACTION_ATTACK := "action.attack"
const ACTION_INTERACT := "action.interact"

const AXIS_MOVE_X := "axis.move_x"
const AXIS_MOVE_Y := "axis.move_y"
const AXIS_LOOK_X := "axis.look_x"
const AXIS_LOOK_Y := "axis.look_y"

const CONTENT_ITEM := "content.item"
const CONTENT_SKILL := "content.skill"
const CONTENT_PICKUP := "content.pickup"
const CONTENT_ENEMY := "content.enemy"
const CONTENT_ROOM := "content.room"
const CONTENT_WAVE := "content.wave"
const CONTENT_SPRITE := "content.sprite"
const CONTENT_SOUND := "content.sound"
const CONTENT_SURFACE := "content.surface"
const CONTENT_LADDER := "content.ladder"

const EVENT_IDS := [EVENT_DAMAGE, EVENT_ROOM, EVENT_PICKUP]
const COMMAND_IDS := [CMD_ATTACK, CMD_MOVE]
const ACTION_IDS := [
	ACTION_MOVE_LEFT, ACTION_MOVE_RIGHT, ACTION_MOVE_UP, ACTION_MOVE_DOWN,
	ACTION_JUMP, ACTION_DASH, ACTION_ATTACK, ACTION_INTERACT
]
const AXIS_IDS := [AXIS_MOVE_X, AXIS_MOVE_Y, AXIS_LOOK_X, AXIS_LOOK_Y]
const BASE_CONTENT_TYPES := [
	CONTENT_ITEM, CONTENT_SKILL, CONTENT_PICKUP, CONTENT_ENEMY,
	CONTENT_ROOM, CONTENT_WAVE, CONTENT_SPRITE, CONTENT_SOUND, CONTENT_SURFACE, CONTENT_LADDER
]

static var _content_types: Array = BASE_CONTENT_TYPES.duplicate()

static func has_content_type(type_id: String) -> bool:
	_ensure_content_types()
	return _content_types.has(type_id)

static func list_content_types() -> Array:
	_ensure_content_types()
	return _content_types.duplicate()

static func register_content_type(type_id: String) -> bool:
	_ensure_content_types()
	if type_id == "" or not type_id.begins_with("content."):
		return false
	if _content_types.has(type_id):
		return true
	_content_types.append(type_id)
	_content_types.sort()
	return true

static func _ensure_content_types() -> void:
	if _content_types.size() == 0:
		_content_types = BASE_CONTENT_TYPES.duplicate()

const PHASE_INPUT := "phase.input"
const PHASE_MOVEMENT := "phase.movement"
const PHASE_GAMEPLAY := "phase.gameplay"
const PHASE_POST := "phase.post"

const PHASE_IDS := [PHASE_INPUT, PHASE_MOVEMENT, PHASE_GAMEPLAY, PHASE_POST]
