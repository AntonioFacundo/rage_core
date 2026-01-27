# Editor: Scaffold dock for Rage Core. Allowed deps: Godot editor APIs only.
@tool
extends VBoxContainer

const MODS_DIR := "res://mods"
const PACKS_DIR := "res://data_packs"
const SCENES_DIR := "res://scenes"

@onready var _project_init_button: Button = $ProjectInit/ProjectInitButton
@onready var _overwrite: CheckBox = $Options/Overwrite
@onready var _modpack_id: LineEdit = $ModpackNew/ModpackRow/ModpackId
@onready var _modpack_scene: CheckBox = $ModpackNew/ModpackRow/ModpackScene
@onready var _modpack_button: Button = $ModpackNew/ModpackButton
@onready var _game_id: LineEdit = $GameNew/GameRow/GameId
@onready var _game_template: OptionButton = $GameNew/GameRow/GameTemplate
@onready var _game_scene: CheckBox = $GameNew/GameRow/GameScene
@onready var _game_button: Button = $GameNew/GameButton
@onready var _pickup_id: LineEdit = $PickupNew/PickupRow/PickupId
@onready var _pickup_mod: LineEdit = $PickupNew/PickupRow/PickupMod
@onready var _pickup_sprite: LineEdit = $PickupNew/PickupRow/PickupSprite
@onready var _pickup_sprite_pick: Button = $PickupNew/PickupRow/PickupSpritePick
@onready var _pickup_sound: LineEdit = $PickupNew/PickupRow/PickupSound
@onready var _pickup_sound_pick: Button = $PickupNew/PickupRow/PickupSoundPick
@onready var _pickup_scene: CheckBox = $PickupNew/PickupRow/PickupScene
@onready var _pickup_button: Button = $PickupNew/PickupButton
@onready var _enemy_id: LineEdit = $EnemyNew/EnemyRow/EnemyId
@onready var _enemy_mod: LineEdit = $EnemyNew/EnemyRow/EnemyMod
@onready var _enemy_ai: OptionButton = $EnemyNew/EnemyRow/EnemyAI
@onready var _enemy_scene: CheckBox = $EnemyNew/EnemyRow/EnemyScene
@onready var _enemy_button: Button = $EnemyNew/EnemyButton
@onready var _surface_id: LineEdit = $SurfaceNew/SurfaceRow/SurfaceId
@onready var _surface_mod: LineEdit = $SurfaceNew/SurfaceRow/SurfaceMod
@onready var _surface_max_speed: LineEdit = $SurfaceNew/SurfaceRow/SurfaceMaxSpeed
@onready var _surface_accel: LineEdit = $SurfaceNew/SurfaceRow/SurfaceAccel
@onready var _surface_decel: LineEdit = $SurfaceNew/SurfaceRow/SurfaceDecel
@onready var _surface_scene: CheckBox = $SurfaceNew/SurfaceRow/SurfaceScene
@onready var _surface_button: Button = $SurfaceNew/SurfaceButton
@onready var _ladder_id: LineEdit = $LadderNew/LadderRow/LadderId
@onready var _ladder_mod: LineEdit = $LadderNew/LadderRow/LadderMod
@onready var _ladder_scene: CheckBox = $LadderNew/LadderRow/LadderScene
@onready var _ladder_button: Button = $LadderNew/LadderButton
@onready var _wizard_game_id: LineEdit = $Wizard/WizardRow/WizardGameId
@onready var _wizard_scene: LineEdit = $Wizard/WizardRow/WizardScene
@onready var _wizard_button: Button = $Wizard/WizardRow/WizardButton
@onready var _scene_path: LineEdit = $SceneTools/SceneRow/ScenePath
@onready var _scene_pick: Button = $SceneTools/SceneRow/ScenePick
@onready var _open_mods: Button = $SceneTools/SceneRow/OpenMods
@onready var _open_packs: Button = $SceneTools/SceneRow/OpenPacks
@onready var _add_floor: Button = $SceneTools/SceneRow/AddFloor
@onready var _add_player: Button = $SceneTools/SceneRow/AddPlayer
@onready var _open_scene: Button = $SceneTools/SceneRow/OpenScene
@onready var _status: Label = $Status
@onready var _pack_preview: TextEdit = $PackPreview
@onready var _file_dialog: FileDialog = FileDialog.new()
var _file_dialog_mode: String = "scene"

# Metaprogramming UI elements
@onready var _system_name: LineEdit = $SystemNew/SystemRow/SystemName
@onready var _system_phase: OptionButton = $SystemNew/SystemRow/SystemPhase
@onready var _system_priority: LineEdit = $SystemNew/SystemRow/SystemPriority
@onready var _system_button: Button = $SystemNew/SystemButton
@onready var _event_name: LineEdit = $EventNew/EventRow/EventName
@onready var _event_id: LineEdit = $EventNew/EventRow/EventId
@onready var _event_button: Button = $EventNew/EventButton
@onready var _command_name: LineEdit = $CommandNew/CommandRow/CommandName
@onready var _command_id: LineEdit = $CommandNew/CommandRow/CommandId
@onready var _command_button: Button = $CommandNew/CommandButton
@onready var _system_complete_name: LineEdit = $SystemComplete/SystemCompleteRow/SystemCompleteName
@onready var _system_complete_phase: OptionButton = $SystemComplete/SystemCompleteRow/SystemCompletePhase
@onready var _system_complete_priority: LineEdit = $SystemComplete/SystemCompleteRow/SystemCompletePriority
@onready var _system_complete_events: LineEdit = $SystemComplete/SystemCompleteRow/SystemCompleteEvents
@onready var _system_complete_button: Button = $SystemComplete/SystemCompleteButton

func _ready() -> void:
	_disable_auto_translate(self)
	_game_template.add_item("custom")
	_game_template.add_item("platformer_basic")
	_game_template.add_item("melee_platformer")
	_game_template.add_item("runner_basic")
	_game_template.add_item("arena_basic")
	# Internal templates
	_game_template.add_item("arena (template)")
	_game_template.add_item("platformer (template)")
	_game_template.add_item("roguelike (template)")
	_game_template.add_item("topdown (template)")
	_game_template.add_item("cards (template)")

	_enemy_ai.add_item("idle")
	_enemy_ai.add_item("patrol")
	_enemy_ai.add_item("chase")

	# Metaprogramming phase options
	_system_phase.add_item("phase.input")
	_system_phase.add_item("phase.movement")
	_system_phase.add_item("phase.gameplay")
	_system_phase.add_item("phase.post")
	_system_phase.selected = 2  # Default to gameplay
	_system_complete_phase.add_item("phase.input")
	_system_complete_phase.add_item("phase.movement")
	_system_complete_phase.add_item("phase.gameplay")
	_system_complete_phase.add_item("phase.post")
	_system_complete_phase.selected = 2  # Default to gameplay

	_project_init_button.pressed.connect(_on_project_init)
	_modpack_button.pressed.connect(_on_modpack_new)
	_game_button.pressed.connect(_on_game_new)
	_pickup_button.pressed.connect(_on_pickup_new)
	_enemy_button.pressed.connect(_on_enemy_new)
	_surface_button.pressed.connect(_on_surface_new)
	_ladder_button.pressed.connect(_on_ladder_new)
	_wizard_button.pressed.connect(_on_wizard)
	_add_floor.pressed.connect(_on_scene_add_floor)
	_add_player.pressed.connect(_on_scene_add_player)
	_open_scene.pressed.connect(_on_scene_open)
	_scene_pick.pressed.connect(_on_scene_pick)
	_open_mods.pressed.connect(func(): _open_folder(MODS_DIR))
	_open_packs.pressed.connect(func(): _open_folder(PACKS_DIR))
	_pickup_sprite_pick.pressed.connect(_on_pickup_sprite_pick)
	_pickup_sound_pick.pressed.connect(_on_pickup_sound_pick)
	
	# Metaprogramming button connections
	_system_button.pressed.connect(_on_system_new)
	_event_button.pressed.connect(_on_event_new)
	_command_button.pressed.connect(_on_command_new)
	_system_complete_button.pressed.connect(_on_system_complete)
	# Force English labels in Scene Tools.
	$Options/OverwriteLabel.text = "Overwrite"
	_overwrite.text = "Enable"
	$SceneTools/SceneLabel.text = "Scene Tools"
	_scene_pick.text = "Pick Scene"
	_open_mods.text = "Open Mods"
	_open_packs.text = "Open Packs"
	_add_floor.text = "Add Floor"
	_add_player.text = "Add Player"
	_open_scene.text = "Open Scene"
	_scene_path.placeholder_text = "scenes/main.tscn"

	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.filters = PackedStringArray(["*.tscn ; Scenes"])
	add_child(_file_dialog)
	_file_dialog.file_selected.connect(_on_file_selected)

func _disable_auto_translate(node: Node) -> void:
	if node.has_method("set_auto_translate"):
		node.call("set_auto_translate", false)
	for child in node.get_children():
		_disable_auto_translate(child)

func _on_project_init() -> void:
	_project_init(true)

func _on_modpack_new() -> void:
	var mod_id := _modpack_id.text.strip_edges()
	if not _is_valid_id(mod_id):
		_set_status("mod_id required")
		_modpack_id.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		return
	_modpack_id.add_theme_color_override("font_color", Color(1, 1, 1))
	_modpack_new(mod_id, _modpack_scene.button_pressed)

func _on_game_new() -> void:
	var game_id := _game_id.text.strip_edges()
	if not _is_valid_id(game_id):
		_set_status("game_id required")
		_game_id.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		return
	_game_id.add_theme_color_override("font_color", Color(1, 1, 1))
	var template := _game_template.get_item_text(_game_template.selected)
	_game_new(game_id, template, _game_scene.button_pressed)

func _on_pickup_new() -> void:
	var pickup_id := _pickup_id.text.strip_edges()
	var mod_id := _pickup_mod.text.strip_edges()
	if not _is_valid_id(pickup_id) or not _is_valid_id(mod_id):
		_set_status("pickup_id and mod_id required")
		_pickup_id.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		_pickup_mod.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		return
	_pickup_id.add_theme_color_override("font_color", Color(1, 1, 1))
	_pickup_mod.add_theme_color_override("font_color", Color(1, 1, 1))
	var sprite_path := _pickup_sprite.text.strip_edges()
	var sound_path := _pickup_sound.text.strip_edges()
	_validate_path_field(_pickup_sprite, sprite_path)
	_validate_path_field(_pickup_sound, sound_path)
	_pickup_new(pickup_id, mod_id, sprite_path, sound_path, _pickup_scene.button_pressed)

func _on_enemy_new() -> void:
	var enemy_id := _enemy_id.text.strip_edges()
	var mod_id := _enemy_mod.text.strip_edges()
	if not _is_valid_id(enemy_id) or not _is_valid_id(mod_id):
		_set_status("enemy_id and mod_id required")
		_enemy_id.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		_enemy_mod.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		return
	_enemy_id.add_theme_color_override("font_color", Color(1, 1, 1))
	_enemy_mod.add_theme_color_override("font_color", Color(1, 1, 1))
	var ai := _enemy_ai.get_item_text(_enemy_ai.selected)
	_enemy_new(enemy_id, mod_id, ai, _enemy_scene.button_pressed)

func _on_surface_new() -> void:
	var surface_id := _surface_id.text.strip_edges()
	var mod_id := _surface_mod.text.strip_edges()
	if not _is_valid_id(surface_id) or not _is_valid_id(mod_id):
		_set_status("surface_id and mod_id required")
		_surface_id.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		_surface_mod.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		return
	_surface_id.add_theme_color_override("font_color", Color(1, 1, 1))
	_surface_mod.add_theme_color_override("font_color", Color(1, 1, 1))
	var max_speed := _parse_float(_surface_max_speed.text, 1.1)
	var accel := _parse_float(_surface_accel.text, 0.4)
	var decel := _parse_float(_surface_decel.text, 0.2)
	_surface_new(surface_id, mod_id, max_speed, accel, decel, _surface_scene.button_pressed)

func _on_ladder_new() -> void:
	var ladder_id := _ladder_id.text.strip_edges()
	var mod_id := _ladder_mod.text.strip_edges()
	if not _is_valid_id(ladder_id) or not _is_valid_id(mod_id):
		_set_status("ladder_id and mod_id required")
		_ladder_id.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		_ladder_mod.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		return
	_ladder_id.add_theme_color_override("font_color", Color(1, 1, 1))
	_ladder_mod.add_theme_color_override("font_color", Color(1, 1, 1))
	_ladder_new(ladder_id, mod_id, _ladder_scene.button_pressed)

func _on_wizard() -> void:
	var game_id := _wizard_game_id.text.strip_edges()
	var scene_path := _wizard_scene.text.strip_edges()
	if not _is_valid_id(game_id):
		_set_status("game_id required")
		_wizard_game_id.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		return
	_wizard_game_id.add_theme_color_override("font_color", Color(1, 1, 1))
	_modpack_new(game_id, true)
	_pickup_new("pickup_speed", game_id, "", "", true)
	if scene_path != "":
		_scene_add_floor(scene_path)
		_scene_add_player(scene_path)
	_set_status("wizard complete: " + game_id)

func _on_scene_add_floor() -> void:
	var path := _scene_path.text.strip_edges()
	_validate_path_field(_scene_path, "res://" + path if not path.begins_with("res://") else path)
	_scene_add_floor(path)

func _on_scene_add_player() -> void:
	var path := _scene_path.text.strip_edges()
	_validate_path_field(_scene_path, "res://" + path if not path.begins_with("res://") else path)
	_scene_add_player(path)

func _on_scene_open() -> void:
	var path := _scene_path.text.strip_edges()
	if path == "":
		_set_status("scene path required")
		return
	var res_path := path if path.begins_with("res://") else "res://" + path
	_validate_path_field(_scene_path, res_path)
	if not FileAccess.file_exists(res_path):
		_set_status("scene not found: " + path)
		return
	var editor: EditorInterface = get_tree().get_editor_interface()
	editor.open_scene_from_path(res_path)
	_set_status("opened: " + path)

func _on_scene_pick() -> void:
	_file_dialog_mode = "scene"
	_file_dialog.title = "Pick Scene"
	_file_dialog.filters = PackedStringArray(["*.tscn ; Scenes"])
	_file_dialog.popup_centered_ratio(0.6)

func _on_file_selected(path: String) -> void:
	var target := path
	if path.begins_with("res://"):
		target = path
	if _file_dialog_mode == "scene":
		_scene_path.text = target.replace("res://", "")
		_validate_path_field(_scene_path, target)
	elif _file_dialog_mode == "sprite":
		_pickup_sprite.text = target
		_validate_path_field(_pickup_sprite, target)
	elif _file_dialog_mode == "sound":
		_pickup_sound.text = target
		_validate_path_field(_pickup_sound, target)

func _on_pickup_sprite_pick() -> void:
	_file_dialog_mode = "sprite"
	_file_dialog.title = "Pick Sprite"
	_file_dialog.filters = PackedStringArray(["*.png ; PNG", "*.webp ; WEBP", "*.jpg ; JPG"])
	_file_dialog.popup_centered_ratio(0.6)

func _on_pickup_sound_pick() -> void:
	_file_dialog_mode = "sound"
	_file_dialog.title = "Pick Sound"
	_file_dialog.filters = PackedStringArray(["*.wav ; WAV", "*.ogg ; OGG"])
	_file_dialog.popup_centered_ratio(0.6)

func _project_init(create_scene: bool) -> void:
	_ensure_dir(MODS_DIR)
	_ensure_dir(PACKS_DIR)
	_ensure_dir(SCENES_DIR)
	_ensure_dir("res://assets")
	_ensure_dir("res://presentation")
	_ensure_dir("res://design")
	_ensure_dir("res://game")
	var kernel_path := "res://game/game_kernel.gd"
	if not FileAccess.file_exists(kernel_path) or _overwrite.button_pressed:
		_write_file(kernel_path, _game_kernel_template())
	_modpack_new("base", create_scene)
	_set_status("project initialized (game kernel: res://game/game_kernel.gd)")

func _modpack_new(mod_id: String, create_scene: bool) -> void:
	var mod_dir := MODS_DIR + "/" + mod_id
	_ensure_dir(mod_dir)
	var mod_path := mod_dir + "/mod_" + mod_id + ".gd"
	var manifest := {
		"id": mod_id,
		"version": "1.0.0",
		"requires_core": "^1.0.0",
		"requires_game": "^1.0.0",
		"deps": {},
		"load_order_hint": 0
	}
	var mod_content := _mod_template(mod_id, manifest)
	if not _write_file(mod_path, mod_content):
		return

	var pack_path := PACKS_DIR + "/" + mod_id + ".json"
	if not FileAccess.file_exists(pack_path):
		if not _write_json(pack_path, {"pack_id": mod_id, "contents": []}):
			return

	if create_scene:
		var scene_dir := SCENES_DIR + "/" + mod_id
		_ensure_dir(scene_dir)
		var scene_path := scene_dir + "/main.tscn"
		if not _write_file(scene_path, _scene_base()):
			return
	_set_status("mod+pack created: " + mod_id)

func _game_new(game_id: String, template: String, create_scene: bool) -> void:
	# Check if it's an internal template
	if template.ends_with(" (template)"):
		var template_name := template.replace(" (template)", "")
		_template_new_from_internal(game_id, template_name, create_scene)
		return
	
	# Legacy templates
	_modpack_new(game_id, create_scene)
	match template:
		"platformer_basic":
			_pickup_new("pickup_speed", game_id, "", "", create_scene)
		"melee_platformer":
			_pickup_new("pickup_speed", game_id, "", "", create_scene)
			_enemy_new("enemy_small", game_id, "patrol", create_scene)
		"runner_basic":
			_surface_new("surface_ice", game_id, 1.2, 0.6, 0.4, create_scene)
		"arena_basic":
			_enemy_new("enemy_small", game_id, "chase", create_scene)
	_set_status("game created: " + game_id)

func _template_new_from_internal(game_id: String, template_name: String, create_scene: bool) -> void:
	var template_dir := "res://addons/rage_toolkit/templates/" + template_name
	if not DirAccess.dir_exists_absolute(template_dir):
		_set_status("template not found: " + template_name)
		return
	
	# Read template manifest
	var manifest_path := template_dir + "/manifest.json"
	if not FileAccess.file_exists(manifest_path):
		_set_status("template manifest not found")
		return
	
	var file := FileAccess.open(manifest_path, FileAccess.READ)
	if not file:
		_set_status("failed to read template manifest")
		return
	var manifest_text := file.get_as_text()
	file.close()
	var manifest := JSON.parse_string(manifest_text)
	if not manifest:
		_set_status("invalid template manifest")
		return
	
	# Create directories
	_ensure_dir("res://game")
	_ensure_dir(MODS_DIR)
	_ensure_dir(PACKS_DIR)
	if create_scene:
		_ensure_dir(SCENES_DIR + "/" + game_id)
	
	# Copy kernel
	var template_kernel := template_dir + "/kernel.gd"
	if FileAccess.file_exists(template_kernel):
		file = FileAccess.open(template_kernel, FileAccess.READ)
		if file:
			var kernel_content := file.get_as_text()
			file.close()
			var kernel_path := "res://game/game_kernel.gd"
			if _write_file(kernel_path, kernel_content):
				_set_status("kernel created")
	
	# Copy mod
	var template_mod := template_dir + "/mod_base.gd"
	if FileAccess.file_exists(template_mod):
		var mod_dir := MODS_DIR + "/" + game_id
		_ensure_dir(mod_dir)
		file = FileAccess.open(template_mod, FileAccess.READ)
		if file:
			var mod_content := file.get_as_text()
			file.close()
			var mod_path := mod_dir + "/mod_" + game_id + ".gd"
			if _write_file(mod_path, mod_content):
				# Create mod manifest
				var mod_manifest := {
					"id": game_id,
					"version": "1.0.0",
					"requires_core": "^1.0.0",
					"requires_game": "^1.0.0",
					"deps": {},
					"load_order_hint": 0
				}
				var manifest_path_mod := mod_dir + "/manifest.json"
				_write_json(manifest_path_mod, mod_manifest)
	
	# Copy pack
	var template_pack := template_dir + "/pack.json"
	if FileAccess.file_exists(template_pack):
		file = FileAccess.open(template_pack, FileAccess.READ)
		if file:
			var pack_text := file.get_as_text()
			file.close()
			var pack_data := JSON.parse_string(pack_text)
			if pack_data:
				pack_data["pack_id"] = game_id
				var pack_path := PACKS_DIR + "/" + game_id + ".json"
				_write_json(pack_path, pack_data)
	
	# Create scene if requested
	if create_scene:
		var scene_path := SCENES_DIR + "/" + game_id + "/main.tscn"
		_write_file(scene_path, _scene_base())
	
	var systems_list := manifest.get("systems", [])
	_set_status("game created from template: " + game_id + " (systems: " + str(systems_list.size()) + ")")

func _pickup_new(pickup_id: String, mod_id: String, sprite_path: String, sound_path: String, create_scene: bool) -> void:
	var mod_dir := MODS_DIR + "/" + mod_id
	_ensure_dir(mod_dir)
	var mod_path := mod_dir + "/mod_pickup_" + pickup_id + ".gd"
	var content := _pickup_template(pickup_id)
	if not _write_file(mod_path, content):
		return
	if not _append_pack_entry(mod_id, {
		"id": pickup_id,
		"type": "content.pickup",
		"data": {"type": pickup_id, "sprite": sprite_path, "sound": sound_path}
	}):
		return
	if create_scene:
		_ensure_dir(SCENES_DIR + "/pickups")
		var scene_path := SCENES_DIR + "/pickups/" + pickup_id + ".tscn"
		if not _write_file(scene_path, _scene_trigger("Pickup" + pickup_id, sprite_path)):
			return
	_set_status("pickup created: " + pickup_id)

func _enemy_new(enemy_id: String, mod_id: String, ai: String, create_scene: bool) -> void:
	var mod_dir := MODS_DIR + "/" + mod_id
	_ensure_dir(mod_dir)
	var mod_path := mod_dir + "/mod_enemy_" + enemy_id + ".gd"
	var content := _enemy_template(enemy_id, ai)
	if not _write_file(mod_path, content):
		return
	if not _append_pack_entry(mod_id, {
		"id": enemy_id,
		"type": "content.enemy",
		"data": {"ai": ai}
	}):
		return
	if create_scene:
		_ensure_dir(SCENES_DIR + "/enemies")
		var scene_path := SCENES_DIR + "/enemies/" + enemy_id + ".tscn"
		if not _write_file(scene_path, _scene_player("Enemy" + enemy_id)):
			return
	_set_status("enemy created: " + enemy_id)

func _surface_new(surface_id: String, mod_id: String, max_speed: float, accel: float, decel: float, create_scene: bool) -> void:
	if not _append_pack_entry(mod_id, {
		"id": surface_id,
		"type": "content.surface",
		"data": {"max_speed_mult": max_speed, "accel_mult": accel, "decel_mult": decel}
	}):
		return
	if create_scene:
		_ensure_dir(SCENES_DIR + "/surfaces")
		var scene_path := SCENES_DIR + "/surfaces/" + surface_id + ".tscn"
		if not _write_file(scene_path, _scene_trigger("Surface" + surface_id)):
			return
	_set_status("surface created: " + surface_id)

func _ladder_new(ladder_id: String, mod_id: String, create_scene: bool) -> void:
	if not _append_pack_entry(mod_id, {
		"id": ladder_id,
		"type": "content.ladder",
		"data": {}
	}):
		return
	if create_scene:
		_ensure_dir(SCENES_DIR + "/ladders")
		var scene_path := SCENES_DIR + "/ladders/" + ladder_id + ".tscn"
		if not _write_file(scene_path, _scene_trigger("Ladder" + ladder_id)):
			return
	_set_status("ladder created: " + ladder_id)

func _scene_add_floor(path: String) -> void:
	if path == "":
		_set_status("scene path required")
		return
	var res_path := path if path.begins_with("res://") else "res://" + path
	_validate_path_field(_scene_path, res_path)
	if not FileAccess.file_exists(res_path):
		_set_status("scene not found: " + path)
		return
	var content := "[node name=\"Floor\" type=\"StaticBody2D\" parent=\".\"]\n[node name=\"Collision\" type=\"CollisionShape2D\" parent=\"Floor\"]\n"
	_append_file(res_path, content)
	_set_status("floor added")

func _scene_add_player(path: String) -> void:
	if path == "":
		_set_status("scene path required")
		return
	var res_path := path if path.begins_with("res://") else "res://" + path
	_validate_path_field(_scene_path, res_path)
	if not FileAccess.file_exists(res_path):
		_set_status("scene not found: " + path)
		return
	var content := "[ext_resource type=\"Script\" path=\"res://addons/rage_core/presentation/player_body_bridge.gd\" id=\"1\"]\n[node name=\"Player\" type=\"CharacterBody2D\" parent=\".\"]\nscript = ExtResource(\"1\")\n[node name=\"Collision\" type=\"CollisionShape2D\" parent=\"Player\"]\n"
	_append_file(res_path, content)
	_set_status("player added")

func _open_folder(path: String) -> void:
	var editor: EditorInterface = get_tree().get_editor_interface()
	editor.get_resource_filesystem().scan_sources()
	editor.select_file(path)

func _mod_template(mod_id: String, manifest: Dictionary) -> String:
	return "# Mods: Mod scaffold.\nclass_name Mod" + _classify(mod_id) + "\nextends ModBase\n\nvar _manifest: ModManifest\n\nfunc _init() -> void:\n\tvar data := " + JSON.stringify(manifest) + "\n\tvar result := ModManifest.from_dict(data)\n\tif result.ok:\n\t\t_manifest = result.value\n\nfunc get_manifest() -> ModManifest:\n\treturn _manifest\n\nfunc on_load(api: GameAPI) -> void:\n\tpass\n"

func _pickup_template(pickup_id: String) -> String:
	return "# Mods: Pickup mod.\nclass_name ModPickup" + _classify(pickup_id) + "\nextends ModBase\n\nvar _manifest: ModManifest\n\nfunc _init() -> void:\n\tvar data := {\"id\": \"pickup." + pickup_id + "\", \"version\": \"1.0.0\", \"requires_core\": \"^1.0.0\", \"requires_game\": \"^1.0.0\", \"deps\": {}, \"load_order_hint\": 50}\n\tvar result := ModManifest.from_dict(data)\n\tif result.ok:\n\t\t_manifest = result.value\n\nfunc get_manifest() -> ModManifest:\n\treturn _manifest\n\nfunc on_load(api: GameAPI) -> void:\n\tpass\n"

func _enemy_template(enemy_id: String, ai: String) -> String:
	return "# Mods: Enemy mod.\nclass_name ModEnemy" + _classify(enemy_id) + "\nextends ModBase\n\nvar _manifest: ModManifest\n\nfunc _init() -> void:\n\tvar data := {\"id\": \"enemy." + enemy_id + "\", \"version\": \"1.0.0\", \"requires_core\": \"^1.0.0\", \"requires_game\": \"^1.0.0\", \"deps\": {}, \"load_order_hint\": 60}\n\tvar result := ModManifest.from_dict(data)\n\tif result.ok:\n\t\t_manifest = result.value\n\nfunc get_manifest() -> ModManifest:\n\treturn _manifest\n\nfunc on_load(api: GameAPI) -> void:\n\tpass\n"

func _game_kernel_template() -> String:
	return "# Game: Project-specific kernel extension. Allowed deps: Godot + Rage Core.\nextends GameKernel\nclass_name GameKernelGame\n\nfunc _ready() -> void:\n\tsuper._ready()\n\t# Optional Rage Core setup (uncomment to enable).\n\t# Inputs: binds default action ids to Godot input names.\n\t# _bind_default_inputs()\n\t# Input sampling + AI + trigger buffering.\n\t# _player_input_system = PlayerInputSystem.new()\n\t# _pipeline.register_step(GameConstants.PHASE_INPUT, 100, _player_input_system)\n\t# _ai_system = AISystem.new()\n\t# _pipeline.register_step(GameConstants.PHASE_INPUT, 90, _ai_system)\n\t# _trigger_buffer_system = TriggerBufferSystem.new()\n\t# _pipeline.register_step(GameConstants.PHASE_INPUT, 10, _trigger_buffer_system)\n\t# Core movement loop + default player entity.\n\t# _movement_system = Movement2DSystem.new()\n\t# _movement_system.register_entity(\"player\")\n\t# _pipeline.register_step(GameConstants.PHASE_MOVEMENT, 100, _movement_system)\n\t# Gameplay systems (combat, pickups, surfaces, ladders).\n\t# _combat_system = CombatSystem.new()\n\t# _pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 50, _combat_system)\n\t# _pickup_system = PickupSystem.new()\n\t# _pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 40, _pickup_system)\n\t# _surface_system = SurfaceSystem.new()\n\t# _pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 30, _surface_system)\n\t# _ladder_system = LadderSystem.new()\n\t# _pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 20, _ladder_system)\n\t# Debug: prints pipeline order on boot (requires boot_log enabled).\n\t# _log_pipeline_registration()\n\t# Content: packs from res://addons/rage_core/data_packs and res://data_packs.\n\t# _load_content_packs()\n\t# Mods: load and call on_load() in deterministic order.\n\t# _load_mods()\n\nfunc _load_content_packs() -> void:\n\tsuper._load_content_packs()\n\t_load_content_packs_from_dir(\"user://data_packs\")\n"

func _scene_base() -> String:
	return "[gd_scene format=3]\n[node name=\"Main\" type=\"Node2D\"]\n"

func _scene_trigger(name: String, sprite_path: String = "") -> String:
	var res = "[gd_scene load_steps=2 format=3]\n"
	res += "[ext_resource type=\"Script\" path=\"res://addons/rage_core/presentation/trigger_2d_bridge.gd\" id=\"1\"]\n"
	if sprite_path != "":
		res += "[ext_resource type=\"Texture2D\" path=\"" + sprite_path + "\" id=\"2\"]\n"
	res += "[node name=\"" + name + "\" type=\"Area2D\"]\nscript = ExtResource(\"1\")\n"
	if sprite_path != "":
		res += "[node name=\"Sprite\" type=\"Sprite2D\" parent=\".\"]\ntexture = ExtResource(\"2\")\n"
	res += "[node name=\"Collision\" type=\"CollisionShape2D\" parent=\".\"]\n"
	return res

func _scene_player(name: String) -> String:
	return "[gd_scene load_steps=2 format=3]\n[ext_resource type=\"Script\" path=\"res://addons/rage_core/presentation/player_body_bridge.gd\" id=\"1\"]\n[node name=\"" + name + "\" type=\"CharacterBody2D\"]\nscript = ExtResource(\"1\")\n[node name=\"Collision\" type=\"CollisionShape2D\" parent=\".\"]\n"

func _append_pack_entry(mod_id: String, entry: Dictionary) -> bool:
	var pack_path := PACKS_DIR + "/" + mod_id + ".json"
	var data := {"pack_id": mod_id, "contents": []}
	if FileAccess.file_exists(pack_path):
		var text := FileAccess.get_file_as_string(pack_path)
		var parsed := JSON.parse_string(text)
		if parsed is Dictionary:
			data = parsed
	var contents: Array = data.get("contents", [])
	for existing in contents:
		if existing is Dictionary and existing.get("id", "") == entry.get("id", ""):
			_set_status("duplicate content id: " + str(entry.get("id", "")))
			return false
	data["contents"].append(entry)
	var ok := _write_json(pack_path, data)
	if ok:
		_update_pack_preview(data)
	return ok

func _write_json(path: String, data: Dictionary) -> bool:
	if not _can_write(path):
		return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_set_status("write failed: " + path)
		return false
	file.store_string(JSON.stringify(data, "\t") + "\n")
	return true

func _update_pack_preview(data: Dictionary) -> void:
	_pack_preview.text = JSON.stringify(data, "\t")

func _write_file(path: String, content: String) -> bool:
	if not _can_write(path):
		return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_set_status("write failed: " + path)
		return false
	file.store_string(content)
	return true

func _append_file(path: String, content: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ_WRITE)
	if file == null:
		return
	file.seek_end()
	file.store_string(content)

func _ensure_dir(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(path)

func _classify(value: String) -> String:
	# Convert to PascalCase, matching SystemGenerator._to_class_name behavior
	# Handle spaces, underscores, and hyphens
	var normalized := value.replace("-", " ").replace("_", " ")
	var parts := normalized.split(" ", false)
	var out := ""
	for part in parts:
		if part.length() > 0:
			out += part.capitalize()
	return out

func _parse_float(text: String, default_value: float) -> float:
	if text.strip_edges() == "":
		return default_value
	if not text.is_valid_float():
		return default_value
	return float(text)

func _is_valid_id(value: String) -> bool:
	return value != "" and value.find(" ") == -1

func _validate_path_field(field: LineEdit, path: String) -> void:
	if path == "":
		field.add_theme_color_override("font_color", Color(1, 1, 1))
		return
	var ok := FileAccess.file_exists(path)
	field.add_theme_color_override("font_color", Color(1, 1, 1) if ok else Color(1, 0.2, 0.2))

func _can_write(path: String) -> bool:
	if FileAccess.file_exists(path) and not _overwrite.button_pressed:
		_set_status("file exists: " + path)
		return false
	return true

func _set_status(message: String) -> void:
	_status.text = message

# ============================================================================
# Metaprogramming Functions (using SystemGenerator templates)
# ============================================================================

func _on_system_new() -> void:
	var system_name := _system_name.text.strip_edges()
	if not _is_valid_id(system_name):
		_set_status("system name required")
		_system_name.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		return
	_system_name.add_theme_color_override("font_color", Color(1, 1, 1))
	var phase := _system_phase.get_item_text(_system_phase.selected)
	var priority := _parse_int(_system_priority.text, 50)
	_system_new(system_name, phase, priority)

func _on_event_new() -> void:
	var event_name := _event_name.text.strip_edges()
	if not _is_valid_id(event_name):
		_set_status("event name required")
		_event_name.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		return
	_event_name.add_theme_color_override("font_color", Color(1, 1, 1))
	var event_id := _event_id.text.strip_edges()
	_event_new(event_name, event_id)

func _on_command_new() -> void:
	var command_name := _command_name.text.strip_edges()
	if not _is_valid_id(command_name):
		_set_status("command name required")
		_command_name.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		return
	_command_name.add_theme_color_override("font_color", Color(1, 1, 1))
	var command_id := _command_id.text.strip_edges()
	_command_new(command_name, command_id)

func _on_system_complete() -> void:
	var system_name := _system_complete_name.text.strip_edges()
	if not _is_valid_id(system_name):
		_set_status("system name required")
		_system_complete_name.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		return
	_system_complete_name.add_theme_color_override("font_color", Color(1, 1, 1))
	var phase := _system_complete_phase.get_item_text(_system_complete_phase.selected)
	var priority := _parse_int(_system_complete_priority.text, 50)
	var events_text := _system_complete_events.text.strip_edges()
	var events: Array = []
	if events_text != "":
		events = events_text.split(" ", false)
		for i in range(events.size()):
			events[i] = events[i].strip_edges()
	_system_complete(system_name, phase, priority, events)

func _system_new(system_name: String, phase: String, priority: int) -> void:
	var systems_dir := "res://game/systems"
	_ensure_dir(systems_dir)
	var file_name := system_name.to_lower().replace(" ", "_").replace("-", "_")
	var system_path := systems_dir + "/" + file_name + "_system.gd"
	var content := _system_template(system_name, phase, priority)
	if not _write_file(system_path, content):
		return
	_set_status("✅ System created: " + system_path + "\n   Register in game_kernel.gd or use CodeGenerator.generate_and_register_system()")

func _event_new(event_name: String, event_id: String) -> void:
	var events_dir := "res://game/events"
	_ensure_dir(events_dir)
	var file_name := event_name.to_lower().replace(" ", "_").replace("-", "_")
	var event_path := events_dir + "/" + file_name + "_event.gd"
	var content := _event_template(event_name, event_id)
	if not _write_file(event_path, content):
		return
	var final_id := event_id if event_id != "" else "game." + file_name
	_set_status("✅ Event created: " + event_path + "\n   Event ID: " + final_id)

func _command_new(command_name: String, command_id: String) -> void:
	var commands_dir := "res://game/commands"
	_ensure_dir(commands_dir)
	var file_name := command_name.to_lower().replace(" ", "_").replace("-", "_")
	var command_path := commands_dir + "/" + file_name + "_command.gd"
	var content := _command_template(command_name, command_id)
	if not _write_file(command_path, content):
		return
	var final_id := command_id if command_id != "" else "cmd." + file_name
	_set_status("✅ Command created: " + command_path + "\n   Command ID: " + final_id)

func _system_complete(system_name: String, phase: String, priority: int, events: Array) -> void:
	var systems_dir := "res://game/systems"
	_ensure_dir(systems_dir)
	var file_name := system_name.to_lower().replace(" ", "_").replace("-", "_")
	var system_path := systems_dir + "/" + file_name + "_system.gd"
	
	# Generate system with events if provided
	var system_content: String
	if events.size() > 0:
		var event_preloads := ""
		var event_vars := ""
		for event_name in events:
			var event_name_clean := event_name.strip_edges()
			if event_name_clean == "":
				continue
			var event_class_name := _classify(event_name_clean + "Event")
			var event_file_name := event_name_clean.to_lower().replace(" ", "_").replace("-", "_")
			event_preloads += "const " + event_class_name + " = preload(\"res://game/events/" + event_file_name + "_event.gd\")\n"
			var var_name := event_file_name
			event_vars += "\tvar " + var_name + "_ev: " + event_class_name + "\n"
		
		var system_class_name := _classify(system_name)
		system_content = "# Game: " + system_name + " system. Allowed deps: core types + game types.\n"
		system_content += "class_name " + system_class_name + "System\n"
		system_content += "extends SimulationStep\n\n"
		system_content += event_preloads + "\n"
		system_content += "func run(context: SimulationContext, delta: float) -> void:\n"
		system_content += "\t# TODO: Implement " + system_name + " logic\n"
		system_content += event_vars
		system_content += "\tpass\n"
	else:
		system_content = _system_template(system_name, phase, priority)
	
	if not _write_file(system_path, system_content):
		return
	
	# Generate event files
	var events_dir := "res://game/events"
	_ensure_dir(events_dir)
	for event_name in events:
		var event_name_clean := event_name.strip_edges()
		if event_name_clean == "":
			continue
		var event_file_name := event_name_clean.to_lower().replace(" ", "_").replace("-", "_")
		var event_path := events_dir + "/" + event_file_name + "_event.gd"
		var event_content := _event_template(event_name_clean, "")
		if not _write_file(event_path, event_content):
			continue
	
	var msg := "✅ System created: " + system_path
	if events.size() > 0:
		msg += "\n   ✅ " + str(events.size()) + " event(s) created in res://game/events/"
	msg += "\n   Register in game_kernel.gd or use CodeGenerator.generate_and_register_system()"
	_set_status(msg)

func _system_template(system_name: String, phase: String, priority: int) -> String:
	var system_class_name := _classify(system_name)
	var template := """# Game: {SYSTEM_NAME} system. Allowed deps: core types + game types.
class_name {CLASS_NAME}System
extends SimulationStep

func run(context: SimulationContext, delta: float) -> void:
	# TODO: Implement {SYSTEM_NAME} logic
	pass
"""
	template = template.replace("{SYSTEM_NAME}", system_name)
	template = template.replace("{CLASS_NAME}", system_class_name)
	return template

func _event_template(event_name: String, event_id: String) -> String:
	if event_id == "":
		event_id = "game." + event_name.to_lower().replace(" ", "_").replace("-", "_")
	var event_class_name := _classify(event_name + "Event")
	var template := """# Game: {EVENT_NAME} event payload. Uses Rage Core EventBase.
class_name {CLASS_NAME}
extends EventBase

const ID := "{EVENT_ID}"

func _init() -> void:
	super._init(ID)
	payload = {
		# TODO: Add event payload fields
	}

func validate() -> Result:
	# TODO: Add validation logic
	return Result.ok_result(true)
"""
	template = template.replace("{EVENT_NAME}", event_name)
	template = template.replace("{CLASS_NAME}", event_class_name)
	template = template.replace("{EVENT_ID}", event_id)
	return template

func _command_template(command_name: String, command_id: String) -> String:
	if command_id == "":
		command_id = "cmd." + command_name.to_lower().replace(" ", "_").replace("-", "_")
	var command_class_name := _classify(command_name + "Command")
	var template := """# Game: {COMMAND_NAME} command. Allowed deps: core types + game types.
class_name {CLASS_NAME}
extends ICommand

const ID := "{COMMAND_ID}"

var _entity_id: String
# TODO: Add command fields

func _init(entity_id: String) -> void:
	_entity_id = entity_id

func get_id() -> String:
	return ID

func validate() -> Result:
	if not Ids.is_valid_id(_entity_id):
		return Result.err_result("Invalid entity_id")
	# TODO: Add more validation
	return Result.ok_result(true)
"""
	template = template.replace("{COMMAND_NAME}", command_name)
	template = template.replace("{CLASS_NAME}", command_class_name)
	template = template.replace("{COMMAND_ID}", command_id)
	return template

func _parse_int(text: String, default_value: int) -> int:
	if text.strip_edges() == "":
		return default_value
	if not text.is_valid_int():
		return default_value
	return int(text)

