# Toolkit: Ejemplo práctico - Sistema de Veneno generado con metaprogramación
# Este archivo muestra cómo usar CodeGenerator para crear un sistema completo

extends Node

func _ready() -> void:
	_demo_poison_system()

func _demo_poison_system() -> void:
	print("=== Generando Sistema de Veneno ===")
	
	# Paso 1: Generar eventos necesarios
	var event_results := []
	event_results.append(SystemGenerator.create_event_file(
		"PoisonApplied",
		"res://game/events/poison_applied_event.gd",
		"game.poison.applied",
		true  # force
	))
	event_results.append(SystemGenerator.create_event_file(
		"PoisonTick",
		"res://game/events/poison_tick_event.gd",
		"game.poison.tick",
		true
	))
	
	for result in event_results:
		if result.ok:
			print("✅ Evento creado: ", result.value)
		else:
			print("❌ Error: ", result.error)
	
	# Paso 2: Generar sistema completo
	var system_result = CodeGenerator.generate_system_complete(
		"Poison",
		"res://game/systems",
		"phase.gameplay",
		25,
		["PoisonApplied", "PoisonTick"],
		true  # force
	)
	
	if system_result.errors.size() == 0:
		print("✅ Sistema creado: ", system_result.system_file)
		print("✅ Eventos creados: ", system_result.event_files)
		print("\n📝 Ahora puedes:")
		print("   1. Abrir el archivo generado")
		print("   2. Implementar la lógica del veneno")
		print("   3. Registrar en game_kernel.gd (o usar generate_and_register_system)")
	else:
		print("❌ Errores: ", system_result.errors)
