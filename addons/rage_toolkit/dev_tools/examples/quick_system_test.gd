# Toolkit: Example of rapid system testing
# This demonstrates how to quickly test systems without running the full game

extends Node

func _ready() -> void:
	_test_health_system()
	_test_combat_simulation()

func _test_health_system() -> void:
	print("=== Testing Health System ===")
	
	# Generate system template (for reference)
	var template = SystemGenerator.generate_system_template("HealthRegen")
	print("Template generado (", template.length(), " caracteres)")
	
	# In a real scenario, you would:
	# 1. Create your system
	# var health_system = HealthRegenSystem.new()
	# 
	# 2. Test it quickly
	# var results = SimulationRunner.quick_test_system(
	#     health_system,
	#     {"health": [["player", 100]]},
	#     60  # 1 second at 60 FPS
	# )
	# 
	# 3. Check results
	# print("Player HP after 1 second: ", results.final_state.health[0][1])

func _test_combat_simulation() -> void:
	print("\n=== Testing Combat Simulation ===")
	
	# Example: Simulate combat between player and enemy
	# var combat = CombatSystem.new()
	# var health = HealthSystem.new()
	# 
	# var initial = {
	#     "health": [["player", 100], ["enemy", 80]]
	# }
	# 
	# var results = SimulationRunner.quick_test_scenario(
	#     [combat, health],
	#     initial,
	#     300  # 5 seconds
	# )
	# 
	# print("Combat simulation completed")
	# print("Ticks: ", results.ticks_executed)
	# print("Events: ", results.events_emitted.size())
