# Metaprogramación en Rage Core

## 📝 Aclaración: Generación de Código vs Metaprogramación

### SystemGenerator (Versión Original)
- **Tipo**: Generación de templates (strings)
- **Uso**: Devuelve código como string, tú lo copias manualmente
- **No es metaprogramación**: Solo genera texto, no ejecuta código

```gdscript
var template = SystemGenerator.generate_system_template("MySystem")
# Tú copias el template a un archivo .gd manualmente
```

### CodeGenerator (Versión Mejorada) - ✅ VERDADERA METAPROGRAMACIÓN
- **Tipo**: Generación y escritura automática de archivos
- **Uso**: Crea archivos directamente en el proyecto
- **Es metaprogramación**: El programa escribe código automáticamente

```gdscript
# Crea el archivo automáticamente
var results = CodeGenerator.generate_system_complete("MySystem", "res://game/systems")
# Archivo creado: res://game/systems/my_system.gd
```

---

## 🚀 CodeGenerator - Metaprogramación Real

### `generate_system_complete()`
Genera un sistema completo con todos sus archivos.

```gdscript
var results = CodeGenerator.generate_system_complete(
    "ShopSystem",
    "res://game/systems",      # Dónde crear archivos
    "phase.post",              # Fase del pipeline
    30,                        # Prioridad
    ["ItemPurchased", "ItemSold"],  # Eventos relacionados
    false                      # No sobrescribir si existe
)

# Resultado:
# - res://game/systems/shop_system.gd (creado)
# - res://game/events/item_purchased_event.gd (creado)
# - res://game/events/item_sold_event.gd (creado)
```

### `generate_and_register_system()`
Genera el sistema Y lo registra automáticamente en `game_kernel.gd`.

```gdscript
var results = CodeGenerator.generate_and_register_system(
    "HealthRegen",
    "res://game/game_kernel.gd",
    "res://game/systems",
    "phase.gameplay",
    15
)

# Hace TODO automáticamente:
# 1. Crea res://game/systems/health_regen_system.gd
# 2. Agrega variable en kernel: var _health_regen_system: HealthRegenSystem
# 3. Agrega registro: _health_regen_system = HealthRegenSystem.new()
# 4. Agrega al pipeline: _pipeline.register_step(..., _health_regen_system)
```

---

## 📊 Comparación

| Característica | SystemGenerator | CodeGenerator |
|---------------|-----------------|---------------|
| Genera código | ✅ (string) | ✅ (archivo) |
| Escribe archivos | ❌ | ✅ |
| Auto-registro | ❌ | ✅ |
| Metaprogramación | ❌ | ✅ |
| Uso manual | ✅ | ❌ (automático) |

---

## 🎯 Ejemplo Completo: Crear Sistema en 1 Línea

### Antes (Manual):
1. Crear archivo `my_system.gd`
2. Copiar template
3. Implementar lógica
4. Agregar variable en kernel
5. Registrar en pipeline

### Ahora (Metaprogramación):
```gdscript
# Una línea crea TODO
CodeGenerator.generate_and_register_system("MySystem")
```

**Resultado**: Sistema completo, registrado y listo para usar.

---

## ⚠️ Notas Importantes

1. **Permisos**: Escribir archivos requiere que el proyecto esté abierto en Godot
2. **Validación**: Verifica si archivos existen antes de sobrescribir
3. **Seguridad**: Usa `force=true` solo cuando estés seguro
4. **Editor**: Funciona mejor desde el editor de Godot (no desde runtime)

---

## 🔄 Flujo de Desarrollo con Metaprogramación

```gdscript
# 1. Generar sistema completo
var results = CodeGenerator.generate_and_register_system("ShopSystem")

# 2. Si hay errores, revisarlos
if results.errors.size() > 0:
    print("Errores: ", results.errors)

# 3. El sistema ya está creado y registrado
# Solo necesitas implementar la lógica en el archivo generado

# 4. Probar rápidamente
var system = ShopSystem.new()
var test_results = SimulationRunner.quick_test_system(system, {}, 100)
```

---

## ✅ Ventajas de la Metaprogramación Real

- **Velocidad**: Crea sistemas en segundos
- **Consistencia**: Mismo formato siempre
- **Sin errores**: No olvidas registrar el sistema
- **Escalable**: Genera múltiples sistemas rápidamente
- **Mantenible**: Cambias el template, regeneras todo
