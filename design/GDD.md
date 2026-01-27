# Game Design Document - Lost Dreams

## 1. Visión General

**Título:** Lost Dreams

**Género:** Roguelike / Tower Defense Híbrido

**Plataforma:** Godot Engine

**Descripción:** Un juego de acción roguelike donde el jugador navega por torres de combate, resuelve desafíos de parkour, gestiona una economía de combate y progresa mediante un sistema de habilidades progresivas con finales únicos basados en decisiones.

---

## 2. Mecánicas Principales

### 2.1 Sistema de Combate
- **Tipo:** Acción en tiempo real
- **Características:**
  - Sistema de combate basado en salas (room_combat_system)
  - Encuentros contra enemigos con dificultad escalable
  - Recompensas por victoria (dinero, ítems, experiencia)
  - Sistema de daño y defensa

### 2.2 Sistema de Progresión
- **Selección de Niveles:** El jugador elige qué nivel/torre jugar
- **Oleadas de Enemigos:** Progression por waves con dificultad creciente
- **Boss Fights:** Encuentros finales con mecánicas especiales
  - Sistema de etapas de boss (boss_stage_system)
  - Recompensas especiales por derrota (boss_reward_system)

### 2.3 Sistema de Habilidades
- **Asignación de Habilidades:** El jugador obtiene habilidades progresivamente
- **Award System:** Sistema de otorgamiento automático basado en logros/progreso
- **Árbol de Habilidades:** Progresión conectada de habilidades

### 2.4 Sistema de Parkour
- **Gates de Parkour:** Desafíos de movimiento para avanzar
- **Sistema de Puertas:** Progresión mediante superación de obstáculos
- **Mecánicas:** Saltos, deslizamientos, evitación de peligros

### 2.5 Sistema de Economía
- **Moneda de Combate:** Ganancia en cada sala
- **Tienda:** Sistema de compra/venta en checkpoints
  - Ofertas de tienda (shop_offer_system)
  - Resolución de transacciones (shop_resolve_system)
- **Gestión de Recursos:** Dinero, ítems, potenciadores

### 2.6 Sistema de Finales
- **Múltiples Finales:** Basados en decisiones y progreso
- **Condiciones de Victoria/Derrota:** Claras y definidas
- **Cierre de Corrida:** Sistema de finalización de runs (run_end_system)
- **Registro de Runs:** Sistema de replay para reproducción

---

## 3. Estructuras de Datos

### 3.1 Configuración de Corrida (Run Config)
```
- Dificultad
- Semilla de generación (RNG)
- Modificadores de experiencia
- Reglas de final
```

### 3.2 Estado de Juego
```
- Progreso del jugador
- Inventario actual
- Estadísticas de combate
- Nivel actual
- Oleada actual
```

### 3.3 Definiciones de Contenido
```
- Definiciones de enemigos (enemy_def)
- Definiciones de salas (room_def)
- Definiciones de oleadas (wave_def)
- Definiciones de niveles (level_def)
- Registros de enemigos, salas, oleadas
```

---

## 4. Flujo de Juego

### 4.1 Inicio
1. Pantalla de título
2. Selección de dificultad/modificadores
3. Pantalla de selección de nivel

### 4.2 Bucle Principal
1. **Selección de Torre/Nivel** → `level_selection_system`
2. **Combate en Salas** → `room_combat_system`
3. **Economía/Tienda** → `shop_offer_system` + `shop_resolve_system`
4. **Desafíos de Parkour** → `parkour_gate_system`
5. **Oleadas y Progresión** → `wave_registry` + `room_registry`
6. **Boss Final** → `boss_stage_system` + `boss_reward_system`

### 4.3 Finalización
1. Evaluación de condiciones de final
2. Pantalla de resultados
3. Sistema de puntuación/replay

---

## 5. Sistemas Principales

### 5.1 Sistema de Combate
- **room_combat_system.gd:** Gestiona encuentros enemigos
- **Mecánicas:** Ataque, defensa, habilidades especiales
- **IA de Enemigos:** Patterns y comportamientos

### 5.2 Sistema de Habilidades
- **ability_award_system.gd:** Otorga habilidades automáticamente
- **Árbol de Habilidades:** Conexiones y dependencias
- **Efectos:** Modificadores de estadísticas, nuevas acciones

### 5.3 Sistema de Recompensas
- **boss_reward_system.gd:** Recompensas de boss
- **Dinero, Ítems Únicos, Habilidades Desbloqueadas**

### 5.4 Sistema de Finales
- **Condiciones Múltiples:** Victoria, Derrota, Final Secreto
- **Impacto de Decisiones:** Afecta al final obtenido
- **Cierre de Corrida:** `run_end_system.gd`

### 5.5 Sistema de Configuración
- **run_config.gd + run_config.json**
- **Parámetros Ajustables:** Dificultad, RNG, Multiplicadores

---

## 6. Contenido y Datos

### 6.1 Niveles/Torres
```
- Estructura de salas progresivas
- Enemigos por nivel
- Dificultad escalada
- Recompensas por nivel
```

### 6.2 Enemigos
- **Tipos Variados:** Melee, Range, Boss
- **Estadísticas:** HP, Ataque, Defensa, Velocidad
- **Drops:** Dinero, Ítems, Experiencia

### 6.3 Ítems y Habilidades
- **Rareza:** Común, Raro, Épico, Legendario
- **Efectos:** Pasivos y Activos
- **Sinergia:** Bonificaciones por combinaciones

---

## 7. Sistemas de Datos y Utilidades

### 7.1 RNG (Random Number Generation)
- **Seed System:** Reproducibilidad en replays
- **Determinismo:** Runs idénticas con misma seed

### 7.2 Hash System
- **Verificación de Integridad**
- **Identificadores Únicos**

### 7.3 Type System
- **Tipos de Contenido**
- **Validación de Datos**

### 7.4 Event Bus
- **Comunicación entre Sistemas**
- **Desacoplamiento de Módulos**

### 7.5 Sistema de Errores
- **Manejo de Excepciones**
- **Logging y Debugging**

---

## 8. Mods y Extensibilidad

### 8.1 Sistema de Mods
- **Packs de Contenido:** `mod_packs/`
- **Ejemplos de Mods:**
  - `example_item_mod/`: Añade ítems nuevos
  - `example_level_mod/`: Añade niveles nuevos

### 8.2 Integración de Mods
- **Carga Dinámica**
- **Compatibilidad**
- **Sandboxing**

---

## 9. Especificaciones Técnicas

### 9.1 Engine
- **Godot Engine 4.x**
- **GDScript**

### 9.2 Arquitectura
- **Núcleo de Juego:** `game_core.gd` + `game_kernel.gd`
- **API de Juego:** `game_api.gd`
- **Estado:** `game_state.gd` + `run_state.gd`
- **Constantes:** `constants.gd`

### 9.3 Plugins
- **rage_core:** Sistema central
- **rage_toolkit:** Herramientas de editor

---

## 10. Finales y Reglas de Fin (End Rules)

### 10.1 Condiciones de Victoria
1. **Derrota de Boss Final**
2. **Completar N Oleadas**
3. **Acumular X Dinero**

### 10.2 Condiciones de Derrota
1. **HP Llega a Cero**
2. **Tiempo se Agota**
3. **Falla en Desafío de Parkour Crítico**

### 10.3 Finales Secretos
1. **Obtener Habilidad Legendaria**
2. **Completar Objetivo Oculto**
3. **Decisión Única en Tienda**

### 10.4 Sistema de Puntuación
- **Dinero Acumulado**
- **Enemigos Derrotados**
- **Habilidades Obtenidas**
- **Tiempo de Juego**
- **Multiplicador de Dificultad**

---

## 11. Progresión y Balanceo

### 11.1 Curva de Dificultad
- **Escalado Gradual:** Primer 25% fácil, incremento progresivo
- **Picos de Dificultad:** Boss fights
- **Descansos:** Salas de tienda/parkour

### 11.2 Recompensas
- **Dinero:** 10-100 por sala, 500+ por boss
- **Ítems:** 20% chance por sala
- **Habilidades:** 1 cada 3 salas aprox.

### 11.3 Curva de Poder del Jugador
- **Temprana:** Habilidades básicas, poco dinero
- **Media:** Ítems synergizados, comienza especialización
- **Tardía:** Builds poderosos, habilidades legendarias

---

## 12. UI/UX

### 12.1 Pantallas Principales
- **Menú Principal**
- **Selección de Nivel**
- **HUD de Combate:** HP, Habilidades, Dinero
- **Pantalla de Tienda**
- **Pantalla de Habilidades**
- **Pantalla de Resultados**

### 12.2 Información del Jugador
- **Estadísticas Actuales**
- **Inventario**
- **Historial de Habilidades**
- **Puntuación**

---

## 13. Notas de Desarrollo

- Sistema completamente modular
- Diseño extensible via mods
- Énfasis en replayability via RNG + finales múltiples
- Replay system para compartir/analizar runs
- Event bus para comunicación desacoplada
- Validación de tipos mediante type system

---

**Versión del Documento:** 1.0  
**Última Actualización:** 26 de Enero, 2026  
**Responsable:** Equipo de Desarrollo
