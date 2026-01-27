# Toolkit: Advanced code generator with file writing (true metaprogramming).
# This extends SystemGenerator with automatic file creation and project integration.
class_name CodeGenerator

# Generate a complete system with all files
static func generate_system_complete(
	system_name: String,
	output_dir: String = "res://game/systems",
	phase: String = "phase.gameplay",
	priority: int = 50,
	events: Array = [],
	force: bool = false
) -> Dictionary:
	var results := {
		"system_file": "",
		"event_files": [],
		"errors": []
	}
	
	# Ensure directory exists
	if not output_dir.begins_with("res://"):
		output_dir = "res://" + output_dir
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	
	# Generate system file
	var system_path := output_dir + "/" + system_name.to_lower() + "_system.gd"
	var system_result: Result
	if events.size() > 0:
		var template := SystemGenerator.generate_system_with_events(system_name, events, phase, priority)
		system_result = _write_file(system_path, template, force)
	else:
		system_result = SystemGenerator.create_system_file(system_name, system_path, phase, priority, force)
	
	if not system_result.ok:
		results["errors"].append("System file: " + str(system_result.error))
	else:
		results["system_file"] = system_path
	
	# Generate event files
	var events_dir := output_dir + "/../events"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(events_dir))
	
	for event_name in events:
		var event_path := events_dir + "/" + event_name.to_lower() + "_event.gd"
		var event_result := SystemGenerator.create_event_file(event_name, event_path, "", force)
		if not event_result.ok:
			results["errors"].append("Event " + event_name + ": " + str(event_result.error))
		else:
			results["event_files"].append(event_path)
	
	return results

# Generate system and auto-register in game_kernel.gd
static func generate_and_register_system(
	system_name: String,
	kernel_path: String = "res://game/game_kernel.gd",
	output_dir: String = "res://game/systems",
	phase: String = "phase.gameplay",
	priority: int = 50,
	force: bool = false
) -> Dictionary:
	var results := generate_system_complete(system_name, output_dir, phase, priority, [], force)
	
	# Try to auto-register in kernel (if file exists and is readable)
	if FileAccess.file_exists(kernel_path):
		var kernel_content := FileAccess.get_file_as_string(kernel_path)
		var class_name := _to_class_name(system_name) + "System"
		var var_name := "_" + system_name.to_lower() + "_system"
		
		# Check if already registered
		if kernel_content.contains(var_name):
			results["errors"].append("System already registered in kernel")
		else:
			# Add variable declaration
			var insert_pos := kernel_content.find("var _auto_reset")
			if insert_pos > 0:
				var new_var := "\tvar " + var_name + ": " + class_name + "\n"
				kernel_content = kernel_content.insert(insert_pos, new_var)
			
			# Add registration
			var register_line := "\t" + var_name + " = " + class_name + ".new()\n"
			register_line += "\t_pipeline.register_step(GameConstants." + phase.to_upper().replace(".", "_") + ", " + str(priority) + ", " + var_name + ")\n"
			
			# Find insertion point (after other system registrations)
			var reg_pos := kernel_content.find("_pipeline.register_step(GameConstants.PHASE_GAMEPLAY")
			if reg_pos > 0:
				var last_reg := kernel_content.rfind("_pipeline.register_step(GameConstants.PHASE_GAMEPLAY")
				if last_reg > 0:
					var next_line := kernel_content.find("\n", last_reg)
					if next_line > 0:
						kernel_content = kernel_content.insert(next_line + 1, register_line)
			
			# Write back
			var write_result := _write_file(kernel_path, kernel_content, true)
			if not write_result.ok:
				results["errors"].append("Failed to update kernel: " + str(write_result.error))
			else:
				results["kernel_updated"] = true
	
	return results

static func _to_class_name(name: String) -> String:
	var parts := name.split(" ")
	var result := ""
	for part in parts:
		if part.length() > 0:
			result += part.capitalize()
	return result

static func _write_file(path: String, content: String, force: bool) -> Result:
	if FileAccess.file_exists(path) and not force:
		return Result.err_result("File exists: " + path + " (use force=true)")
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return Result.err_result("Failed to open: " + path)
	
	file.store_string(content)
	file.close()
	return Result.ok_result(path)
