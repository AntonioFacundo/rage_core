# Guía de Desarrollo Rápido con Rage Core

## 🚀 Mejoras Implementadas

### ✅ Problemas Críticos Arreglados

1. **Eventos Personalizados** - Ahora puedes crear eventos con `game.*` o `mod.*` sin modificar el core
2. **Pipeline Optimizado** - Ya no ordena en cada frame, solo cuando se registran nuevos sistemas
3. **Handlers Duplicados** - EventBus previene suscripciones duplicadas automáticamente

### ✅ Nuevas Herramientas

1. **HeadlessSimulator** - Simula sistemas sin UI
2. **SystemGenerator** - Genera templates de sistemas, eventos y comandos
3. **SimulationRunner** - API de alto nivel para pruebas rápidas

---

## 📖 Uso Rápido

### 1. Generar un Sistema Nuevo

```gdscript
# Generar template de sistema
var template = SystemGenerator.generate_system_template("HealthRegen", "phase.gameplay", 15)
# Guarda en: game/systems/health_regen_system.gd
```

### 2. Simular un Sistema Individual

```gdscript
# Crear tu sistema
var my_system = MySystem.new()

# Configurar estado inicial
var initial_state = {
    "health": [["player", 100], ["enemy", 50]]
}

# Simular 100 ticks
var results = SimulationRunner.quick_test_system(my_system, initial_state, 100)

print("Estado final: ", results.final_state)
print("Ticks ejecutados: ", results.ticks)
```

### 3. Simular Múltiples Sistemas

```gdscript
var systems = [CombatSystem.new(), HealthSystem.new(), EconomySystem.new()]

var initial_state = {
    "health": [["player", 100]],
    "currency": [["player", 50]]
}

var results = SimulationRunner.quick_test_scenario(systems, initial_state, 1000)

print("Simulación completada en ", results.ticks_executed, " ticks")
print("Eventos emitidos: ", results.events_emitted.size())
```

### 4. Simular Hasta Condición

```gdscript
var simulator = HeadlessSimulator.new(...)

# Simular hasta que el jugador muera
var results = simulator.simulate_until(func():
    return _state.get_health("player") <= 0
, max_ticks=5000)

if results.condition_met:
    print("Jugador murió en tick ", results.stopped_at_tick)
```

### 5. Crear Eventos Personalizados

```gdscript
# Ya no necesitas modificar GameConstants!
# Crea eventos con prefijo "game." o "mod."

var my_event = MyCustomEvent.new()  # ID: "game.custom.event"
var result = api.emit(my_event)  # ✅ Funciona sin modificar el core
```

---

## 🎯 Flujo de Desarrollo Rápido

### Paso 1: Generar Sistema
```gdscript
var template = SystemGenerator.generate_system_template("MySystem")
# Copia el template a game/systems/my_system.gd
```

### Paso 2: Implementar Lógica
```gdscript
# En my_system.gd
func run(context: SimulationContext, delta: float) -> void:
    # Tu lógica aquí
    pass
```

### Paso 3: Probar Rápidamente
```gdscript
# En un script de prueba
var system = MySystem.new()
var results = SimulationRunner.quick_test_system(system, {}, 100)
print(results)
```

### Paso 4: Integrar al Juego
```gdscript
# En game_kernel.gd
_my_system = MySystem.new()
_pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 50, _my_system)
```

---

## 🔧 Ejemplos Avanzados

### Simular Combate

```gdscript
var combat_system = CombatSystem.new()
var health_system = HealthSystem.new()

var initial = {
    "health": [["player", 100], ["enemy", 80]]
}

# Simular 60 ticks (1 segundo a 60 FPS)
var results = SimulationRunner.quick_test_scenario(
    [combat_system, health_system],
    initial,
    60
)

# Ver quién ganó
var player_hp = results.final_state.health.find(func(p): return p[0] == "player")[1]
var enemy_hp = results.final_state.health.find(func(p): return p[0] == "enemy")[1]

print("Player: ", player_hp, " HP")
print("Enemy: ", enemy_hp, " HP")
```

### Generar Sistema Completo con Eventos

```gdscript
var template = SystemGenerator.generate_system_with_events(
    "ShopSystem",
    ["ItemPurchased", "ItemSold", "ShopOpened"],
    "phase.post",
    30
)
```

---

## 📊 Ventajas

✅ **Desarrollo más rápido** - Genera código automáticamente  
✅ **Pruebas instantáneas** - Simula sin correr el juego  
✅ **Sin modificar core** - Extiende sin tocar Rage Core  
✅ **Determinista** - Resultados reproducibles  
✅ **Headless** - No necesitas UI para probar  

---

## 🎮 Próximos Pasos

1. Usa `SystemGenerator` para crear nuevos sistemas
2. Prueba con `SimulationRunner` antes de integrar
3. Crea eventos personalizados con prefijo `game.*`
4. Simula escenarios completos sin render
