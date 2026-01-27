# Toolkit: Script para crear un roguelike completo usando metaprogramación
# Ejecuta esto desde el editor de Godot (EditorScript) o desde un nodo temporal

extends Node

# Ejecutar: Crea todos los sistemas de un roguelike básico
func create_roguelike() -> void:
	print("🎮 Creando Roguelike con Metaprogramación...")
	print("")
	
	var systems := [
		{
			"name": "Combat",
			"description": "Sistema de combate básico",
			"phase": "PHASE_GAMEPLAY",
			"priority": 50,
			"events": ["DamageDealt", "EnemyDefeated", "PlayerHit"]
		},
		{
			"name": "Economy",
			"description": "Sistema de monedas y compras",
			"phase": "PHASE_GAMEPLAY",
			"priority": 40,
			"events": ["CurrencyGained", "CurrencySpent", "ItemPurchased"]
		},
		{
			"name": "Loot",
			"description": "Sistema de drops y recolección",
			"phase": "PHASE_GAMEPLAY",
			"priority": 35,
			"events": ["ItemDropped", "ItemCollected", "RareItemFound"]
		},
		{
			"name": "Progression",
			"description": "Sistema de progresión y niveles",
			"phase": "PHASE_POST",
			"priority": 30,
			"events": ["LevelUp", "SkillUnlocked", "StatIncreased"]
		},
		{
			"name": "Buffs",
			"description": "Sistema de mejoras temporales",
			"phase": "PHASE_GAMEPLAY",
			"priority": 20,
			"events": ["BuffApplied", "BuffExpired", "BuffStacked"]
		},
		{
			"name": "Debuffs",
			"description": "Sistema de efectos negativos",
			"phase": "PHASE_GAMEPLAY",
			"priority": 15,
			"events": ["DebuffApplied", "DebuffExpired", "DebuffStacked"]
		}
	]
	
	var total_systems := 0
	var total_events := 0
	var errors: Array = []
	
	for system_data in systems:
		print("📦 Generando: ", system_data.name, " - ", system_data.description)
		
		# Convertir phase string a formato correcto
		var phase_str := "phase." + system_data.phase.to_lower().replace("phase_", "")
		
		var result = CodeGenerator.generate_system_complete(
			system_data.name,
			"res://game/systems/roguelike",
			phase_str,
			system_data.priority,
			system_data.events,
			true  # force overwrite
		)
		
		if result.errors.size() == 0:
			total_systems += 1
			total_events += result.event_files.size()
			print("   ✅ Sistema: ", result.system_file)
			print("   ✅ Eventos: ", result.event_files.size(), " creados")
		else:
			errors.append_array(result.errors)
			print("   ❌ Errores: ", result.errors)
		print("")
	
	# Resumen
	print("=" * 50)
	print("✅ COMPLETADO")
	print("   Sistemas creados: ", total_systems)
	print("   Eventos creados: ", total_events)
	if errors.size() > 0:
		print("   Errores: ", errors.size())
	print("=" * 50)
	print("")
	print("📝 Próximos pasos:")
	print("   1. Revisa: res://game/systems/roguelike/")
	print("   2. Implementa la lógica de cada sistema")
	print("   3. Registra en game_kernel.gd")
	print("   4. ¡Prueba con SimulationRunner!")

# Ejemplo: Crear solo el sistema de combate
func create_combat_only() -> void:
	print("⚔️ Creando Sistema de Combate...")
	
	var result = CodeGenerator.generate_and_register_system(
		"Combat",
		"res://game/game_kernel.gd",
		"res://game/systems",
		"phase.gameplay",
		50,
		true
	)
	
	if result.errors.size() == 0:
		print("✅ Sistema de Combate creado y registrado!")
		print("   Archivo: ", result.system_file)
		if result.has("kernel_updated"):
			print("   ✅ Registrado en game_kernel.gd")
	else:
		print("❌ Errores: ", result.errors)

# Ejemplo: Crear sistema de veneno (más complejo)
func create_poison_system() -> void:
	print("☠️ Creando Sistema de Veneno...")
	
	var result = CodeGenerator.generate_system_complete(
		"Poison",
		"res://game/systems",
		"phase.gameplay",
		25,
		["PoisonApplied", "PoisonTick", "PoisonExpired"],
		true
	)
	
	if result.errors.size() == 0:
		print("✅ Sistema de Veneno creado!")
		print("   Sistema: ", result.system_file)
		print("   Eventos: ", result.event_files)
		print("")
		print("📝 Ahora implementa la lógica en el archivo generado")
	else:
		print("❌ Errores: ", result.errors)
