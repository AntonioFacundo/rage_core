# Toolkit: System template generator for rapid development.
# Can generate code strings OR write files directly (true metaprogramming).
class_name SystemGenerator

# Generate and write system file directly
static func create_system_file(system_name: String, output_path: String, phase: String = "phase.gameplay", priority: int = 50, force: bool = false) -> Result:
	var template := generate_system_template(system_name, phase, priority)
	return _write_file(output_path, template, force)

# Generate and write event file directly
static func create_event_file(event_name: String, output_path: String, event_id: String = "", force: bool = false) -> Result:
	var template := generate_event_template(event_name, event_id)
	return _write_file(output_path, template, force)

# Generate and write command file directly
static func create_command_file(command_name: String, output_path: String, command_id: String = "", force: bool = false) -> Result:
	var template := generate_command_template(command_name, command_id)
	return _write_file(output_path, template, force)

# Generate system template (returns string)
static func generate_system_template(system_name: String, phase: String = "phase.gameplay", priority: int = 50) -> String:
	var template := """# Game: {SYSTEM_NAME} system. Allowed deps: core types + game types.
class_name {CLASS_NAME}
extends SimulationStep

func run(context: SimulationContext, delta: float) -> void:
	# TODO: Implement {SYSTEM_NAME} logic
	pass
"""
	template = template.replace("{SYSTEM_NAME}", system_name)
	template = template.replace("{CLASS_NAME}", _to_class_name(system_name))
	return template

static func generate_event_template(event_name: String, event_id: String = "") -> String:
	if event_id == "":
		event_id = "game." + event_name.to_lower().replace(" ", "_")
	
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
	template = template.replace("{CLASS_NAME}", _to_class_name(event_name + "Event"))
	template = template.replace("{EVENT_ID}", event_id)
	return template

static func generate_command_template(command_name: String, command_id: String = "") -> String:
	if command_id == "":
		command_id = "cmd." + command_name.to_lower().replace(" ", "_")
	
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
	template = template.replace("{CLASS_NAME}", _to_class_name(command_name + "Command"))
	template = template.replace("{COMMAND_ID}", command_id)
	return template

static func generate_system_with_events(system_name: String, events: Array, phase: String = "phase.gameplay", priority: int = 50) -> String:
	var event_preloads := ""
	var event_vars := ""
	
	for event_name in events:
		var class_name := _to_class_name(event_name + "Event")
		event_preloads += "const " + class_name + " = preload(\"res://game/events/" + event_name.to_lower() + "_event.gd\")\n"
		event_vars += "\tvar " + event_name.to_lower() + "_ev: " + class_name + "\n"
	
	var template := """# Game: {SYSTEM_NAME} system. Allowed deps: core types + game types.
class_name {CLASS_NAME}
extends SimulationStep

{EVENT_PRELOADS}

func run(context: SimulationContext, delta: float) -> void:
	# TODO: Implement {SYSTEM_NAME} logic
	{EVENT_VARS}
	pass
"""
	template = template.replace("{SYSTEM_NAME}", system_name)
	template = template.replace("{CLASS_NAME}", _to_class_name(system_name))
	template = template.replace("{EVENT_PRELOADS}", event_preloads)
	template = template.replace("{EVENT_VARS}", event_vars)
	return template

static func _to_class_name(name: String) -> String:
	var parts := name.split(" ")
	var result := ""
	for part in parts:
		if part.length() > 0:
			result += part.capitalize()
	return result

# Internal: Write file to disk
static func _write_file(path: String, content: String, force: bool) -> Result:
	# Check if file exists
	if FileAccess.file_exists(path) and not force:
		return Result.err_result("File exists: " + path + " (use force=true to overwrite)")
	
	# Ensure directory exists
	var dir := path.get_base_dir()
	if dir != "" and not dir.begins_with("res://"):
		dir = "res://" + dir
	if dir != "":
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	
	# Write file
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return Result.err_result("Failed to open file for writing: " + path)
	
	file.store_string(content)
	file.close()
	
	return Result.ok_result(path)
