# Toolkit: Ejemplo completo - Crear un juego roguelike completo usando metaprogramación
# Este script genera todos los sistemas necesarios para un roguelike básico

extends Node

func _ready() -> void:
	_create_complete_game()

func _create_complete_game() -> void:
	print("=== Generando Juego Roguelike Completo ===")
	
	# Definir todos los sistemas del juego
	var game_systems := [
		{"name": "Combat", "phase": "phase.gameplay", "priority": 50, "events": ["DamageDealt", "EnemyDefeated"]},
		{"name": "Economy", "phase": "phase.gameplay", "priority": 40, "events": ["CurrencyGained", "ItemPurchased"]},
		{"name": "Progression", "phase": "phase.post", "priority": 30, "events": ["LevelUp", "SkillUnlocked"]},
		{"name": "Loot", "phase": "phase.gameplay", "priority": 35, "events": ["ItemDropped", "ItemCollected"]},
		{"name": "Buffs", "phase": "phase.gameplay", "priority": 20, "events": ["BuffApplied", "BuffExpired"]},
		{"name": "Debuffs", "phase": "phase.gameplay", "priority": 15, "events": ["DebuffApplied", "DebuffExpired"]},
	]
	
	var results := {
		"systems_created": 0,
		"events_created": 0,
		"errors": []
	}
	
	# Generar cada sistema
	for system_data in game_systems:
		var system_result = CodeGenerator.generate_system_complete(
			system_data.name,
			"res://game/systems",
			system_data.phase,
			system_data.priority,
			system_data.events,
			true  # force
		)
		
		if system_result.errors.size() == 0:
			results.systems_created += 1
			results.events_created += system_result.event_files.size()
			print("✅ ", system_data.name, " creado")
		else:
			results.errors.append_array(system_result.errors)
			print("❌ ", system_data.name, ": ", system_result.errors)
	
	# Resumen
	print("\n=== Resumen ===")
	print("Sistemas creados: ", results.systems_created)
	print("Eventos creados: ", results.events_created)
	if results.errors.size() > 0:
		print("Errores: ", results.errors.size())
	
	print("\n📝 Próximos pasos:")
	print("   1. Revisa los archivos en res://game/systems/")
	print("   2. Implementa la lógica de cada sistema")
	print("   3. Registra en game_kernel.gd (o usa generate_and_register_system)")
	print("   4. ¡Juega!")
