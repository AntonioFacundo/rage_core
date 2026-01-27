# Revisión de Rage Core - Análisis de Código

## 📋 Resumen Ejecutivo

Rage Core es una arquitectura bien diseñada con separación clara de capas y principios sólidos. Sin embargo, hay varios problemas potenciales y áreas de mejora que deben abordarse.

---

## ✅ Lo que está BIEN

### 1. Arquitectura en Capas
- ✅ Separación clara: `core/` → `game/` → `platform/` → `presentation/`
- ✅ Core y game no dependen de Godot (como se pretende)
- ✅ Interfaces bien definidas (`ILogger`, `IInputSource`, `IClock`, etc.)
- ✅ Kernel centraliza la inicialización

### 2. Sistema de Eventos
- ✅ `EventBus` con prioridades, interceptores y cancelación
- ✅ Validación de eventos antes y después de intercept
- ✅ Orden determinista de ejecución

### 3. Sistema de Mods
- ✅ Validación de versiones con SemVer
- ✅ Detección de ciclos en dependencias
- ✅ Orden determinista de carga
- ✅ API estable para mods (`GameAPI`)

### 4. Determinismo
- ✅ RNG determinista con seeds
- ✅ Sistema de replay con hash verification
- ✅ Estado canónico exportable

### 5. Pipeline de Simulación
- ✅ Fases bien definidas (`PHASE_INPUT`, `PHASE_MOVEMENT`, etc.)
- ✅ Prioridades y orden determinista
- ✅ Contexto compartido entre sistemas

---

## ⚠️ Lo que está MAL o puede mejorarse

### 🔴 Problemas Críticos

#### 1. **GameAPI valida eventos demasiado restrictivamente**
**Ubicación:** `game/game_api.gd:126-129`
```gdscript
func _validate_event_id(event_id: String) -> Result:
    if not GameConstants.EVENT_IDS.has(event_id):
        return Result.err_result("Unknown event id: " + event_id)
    return Result.ok_result(true)
```

**Problema:** Solo permite eventos definidos en `GameConstants.EVENT_IDS`. Esto impide que proyectos o mods creen eventos personalizados sin modificar el core.

**Impacto:** Alto - Limita la extensibilidad

**Solución sugerida:**
- Permitir eventos que empiecen con `"game."` o `"mod."`
- O hacer la validación opcional/configurable
- O permitir registrar nuevos tipos de eventos

#### 2. **EventBus no valida handlers duplicados**
**Ubicación:** `core/event_bus.gd:8-22`
```gdscript
func subscribe(event_id: String, handler: Callable, priority: int = 0, intercept: bool = false) -> int:
    # ... no valida si el mismo handler ya está suscrito
```

**Problema:** El mismo handler puede suscribirse múltiples veces, causando ejecuciones duplicadas.

**Impacto:** Medio - Puede causar bugs sutiles

**Solución sugerida:**
- Validar si el handler ya existe antes de agregar
- O permitir múltiples suscripciones explícitamente con documentación

#### 3. **SimulationPipeline ordena en cada frame**
**Ubicación:** `game/pipeline/simulation_pipeline.gd:26-31`
```gdscript
func run(context: SimulationContext, delta: float) -> void:
    _ensure_phase_order()
    _steps.sort_custom(_step_before)  # ⚠️ Ordena en cada frame
    for entry in _steps:
        var step: SimulationStep = entry["step"]
        step.run(context, delta)
```

**Problema:** Ordena los pasos en cada frame, incluso cuando no cambian. Esto es ineficiente.

**Impacto:** Medio - Problema de rendimiento

**Solución sugerida:**
- Ordenar solo cuando se registra un nuevo paso
- Cachear el orden ordenado
- Invalidar cache cuando se agrega/elimina un paso

#### 4. **GameState tiene métodos públicos que deberían ser privados**
**Ubicación:** `game/game_state.gd`

**Problema:** Métodos como `set_health()`, `apply_damage()` son públicos pero deberían ser controlados a través de `GameCore` para mantener consistencia.

**Impacto:** Medio - Puede causar inconsistencias si se usa directamente

**Solución sugerida:**
- Hacer métodos privados o protegidos
- Forzar uso a través de `GameCore` o `GameAPI`

#### 5. **DamageSystem es un placeholder vacío**
**Ubicación:** `game/pipeline/systems/damage_system.gd`
```gdscript
# TODO: Move damage application here when pipeline is expanded.
```

**Problema:** Archivo placeholder que no hace nada. Confuso para desarrolladores.

**Impacto:** Bajo - Confusión, pero no rompe nada

**Solución sugerida:**
- Eliminar el archivo si no se usa
- O implementarlo según el TODO

---

### 🟡 Problemas Menores

#### 6. **Falta validación de null en algunos lugares**
**Ejemplo:** `game/game_core.gd:19`
```gdscript
if command is AttackCommand:
    var validation = command.validate()  # ⚠️ command ya se validó como null arriba, pero...
```

**Problema:** Aunque hay validación de null, algunos flujos podrían beneficiarse de más validaciones defensivas.

#### 7. **GameAPI._validate_event_id es muy restrictivo**
Ya mencionado arriba, pero vale la pena repetir: impide eventos personalizados.

#### 8. **ModLoader no valida que mods tengan métodos requeridos**
**Ubicación:** `mods/mod_loader.gd:105-106`
```gdscript
var instance: ModBase = mod_by_id[manifest.id]
instance.on_load(api)  # ⚠️ No valida que on_load exista o sea válido
```

**Problema:** Si un mod no implementa `on_load()` correctamente, fallará en runtime.

**Solución sugerida:**
- Validar que el método existe antes de llamarlo
- O usar interfaces/traits más estrictos

#### 9. **Falta documentación de errores comunes**
No hay guía de troubleshooting para problemas comunes como:
- Eventos no registrados
- Mods que no cargan
- Desincronización en replay

#### 10. **GameState.export_canonical() puede ser costoso**
**Ubicación:** `game/game_state.gd:91-103`

**Problema:** Se llama cada frame en modo replay para calcular hash. Podría optimizarse.

**Solución sugerida:**
- Cachear el estado canónico si no cambió
- O calcular hash incrementalmente

---

### 🔵 Inconsistencias y Mejoras Sugeridas

#### 11. **Nomenclatura inconsistente**
- Algunos métodos usan `apply_*` (apply_damage)
- Otros usan `set_*` (set_health, set_movement_config)
- Mejor tener una convención clara

#### 12. **Falta manejo de errores en algunos flujos**
Ejemplo: `game_kernel.gd` no maneja errores si `_pipeline.run()` falla.

#### 13. **No hay límite en EventBus para handlers**
Un evento podría tener miles de handlers, causando problemas de rendimiento.

**Solución sugerida:**
- Agregar límite configurable
- O warning cuando hay muchos handlers

#### 14. **SimulationContext se crea cada frame**
**Ubicación:** `kernel/game_kernel.gd:117-127`

**Problema:** Se crea un nuevo contexto cada tick. Podría reutilizarse.

**Solución sugerida:**
- Pool de contextos
- O al menos reutilizar el mismo objeto actualizando referencias

#### 15. **Falta validación de tipos en algunos lugares**
Ejemplo: `game_state.gd` no valida tipos al setear valores.

---

## 📊 Métricas de Calidad

### Cobertura de Código
- ✅ Tests básicos presentes (`tests/`)
- ⚠️ Cobertura limitada (muchos sistemas sin tests)

### Documentación
- ✅ README completo
- ✅ Documentación de arquitectura
- ⚠️ Falta documentación de API detallada
- ⚠️ Falta guías de troubleshooting

### Mantenibilidad
- ✅ Código bien estructurado
- ✅ Separación de responsabilidades clara
- ⚠️ Algunos archivos muy largos (`game_kernel.gd` ~590 líneas)

---

## 🎯 Prioridades de Mejora

### Alta Prioridad
1. **Permitir eventos personalizados en GameAPI** (bloquea extensibilidad)
2. **Optimizar ordenamiento del pipeline** (problema de rendimiento)
3. **Validar handlers duplicados en EventBus** (puede causar bugs)

### Media Prioridad
4. **Hacer GameState más privado** (consistencia)
5. **Eliminar o implementar DamageSystem** (limpieza)
6. **Mejorar validación de mods** (robustez)

### Baja Prioridad
7. **Optimizar export_canonical()** (rendimiento en replay)
8. **Reutilizar SimulationContext** (optimización menor)
9. **Mejorar documentación** (usabilidad)

---

## 💡 Recomendaciones Generales

1. **Agregar tests unitarios** para componentes críticos
2. **Documentar APIs públicas** con ejemplos
3. **Crear guía de troubleshooting** común
4. **Establecer convenciones de código** claras
5. **Considerar performance profiling** en modo replay
6. **Agregar logging estructurado** para debugging

---

## 🔍 Archivos que Requieren Atención Especial

1. `game/game_api.gd` - Validación restrictiva de eventos
2. `core/event_bus.gd` - Falta validación de duplicados
3. `game/pipeline/simulation_pipeline.gd` - Ordenamiento innecesario
4. `game/game_state.gd` - Métodos demasiado públicos
5. `kernel/game_kernel.gd` - Archivo muy largo, considerar dividir
6. `mods/mod_loader.gd` - Validación de mods podría mejorar

---

## ✅ Conclusión

Rage Core es una arquitectura sólida con buenos principios de diseño. Los problemas identificados son principalmente de:
- **Extensibilidad** (eventos personalizados)
- **Rendimiento** (ordenamiento innecesario)
- **Robustez** (validaciones faltantes)
- **Mantenibilidad** (algunos archivos largos)

La mayoría son fáciles de corregir y no afectan la funcionalidad actual, pero mejorarlos haría el framework más robusto y extensible.
