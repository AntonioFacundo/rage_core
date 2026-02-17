# Arquitectura de Rage Core

Documentación de la arquitectura en capas del framework y flujos principales. Los diagramas usan fondo claro para correcta visualización en GitHub.

---

## 1. Visión general

Rage Core organiza el juego en **capas** para:

- Mantener la lógica de juego **independiente del motor** (Godot).
- Hacer las reglas **deterministas** y testeables.
- Permitir que el contenido evolucione por **mods** sin tocar código base.
- Concentrar toda la integración con Godot en **adaptadores** y **bridges**.

### Reglas de dependencia

| Capa | Puede depender de |
|------|-------------------|
| **core** | Nada (tipos puros, sin Godot) |
| **game** (en rage_core) | core |
| **mods** | Solo GameAPI (facade) |
| **platform/godot** | Godot + interfaces del core/game |
| **presentation** | Godot + kernel (nodos que conectan escena ↔ kernel) |
| **kernel** | Todas (ensambla todo) |

El **kernel del proyecto** (`res://game/game_kernel.gd`) extiende `GameKernel` y es el único **composition root**: registra sistemas, carga mods y packs, y ejecuta el bucle de simulación.

---

## 2. Diagrama de capas y dependencias

El siguiente diagrama muestra la dirección de las dependencias. Las flechas van de “quien depende” hacia “de quien depende”. Fondo claro para lectura en GitHub.

```mermaid
%%{init: {'theme':'base', 'themeVariables': {'primaryColor':'#e3f2fd','primaryTextColor':'#0d47a1','primaryBorderColor':'#1976d2','lineColor':'#37474f','secondaryColor':'#f5f5f5','tertiaryColor':'#ffffff','background':'#ffffff','mainBkg':'#ffffff','textColor':'#212121'}}}%%
flowchart TB
    subgraph presentation["Presentación (Godot)"]
        P[PlayerBodyBridge, Hitbox2D, Trigger2D, DebugListener, etc.]
    end

    subgraph kernel["Kernel"]
        K[GameKernel / game_kernel.gd]
    end

    subgraph game_layer["Capa game (Rage Core)"]
        API[GameAPI]
        PIP[SimulationPipeline]
        SYS[Systems, Events, Commands]
    end

    subgraph mods_layer["Mods"]
        M[ModBase, on_load]
    end

    subgraph platform["Platform (Godot)"]
        PL[GodotPhysics2D, GodotInputSource, GodotCombatSensor2D, etc.]
    end

    subgraph core["Core"]
        C[EventBus, GameState, Result, Vec2, Interfaces]
    end

    P --> K
    K --> API
    K --> PIP
    K --> PL
    API --> C
    PIP --> SYS
    SYS --> C
    M --> API
    PL --> C
```

**Resumen**: `presentation` → `kernel` → (`game`, `mods`, `platform`) → `core`. El core y la capa game del addon no conocen Godot.

---

## 3. Arranque (boot)

Flujo de inicialización del kernel en `_ready()`: creación de adaptadores, pipeline, API, carga de contenido y mods.

```mermaid
%%{init: {'theme':'base', 'themeVariables': {'primaryColor':'#e8f5e9','primaryTextColor':'#1b5e20','primaryBorderColor':'#388e3c','lineColor':'#37474f','secondaryColor':'#f5f5f5','tertiaryColor':'#ffffff','background':'#ffffff','mainBkg':'#ffffff','textColor':'#212121'}}}%%
flowchart LR
    A[_ready] --> B[Crear Logger, FileStore, Clock, RNG]
    B --> C[Replay: modo y seed]
    C --> D[EventBus, GameState, GameCore]
    D --> E[InputRegistry, ContentRegistry]
    E --> F[GodotPhysics2D, CombatSensor, TriggerSensor]
    F --> G[GameAPI]
    G --> H[SimulationPipeline]
    H --> I[Proyecto: registrar sistemas en pipeline]
    I --> J[Cargar content packs]
    J --> K[Cargar mods, validar, on_load]
    K --> L[Boot listo]
```

El **kernel del proyecto** (en `game/game_kernel.gd`) es quien, en su `_ready()`, llama a `super._ready()` y luego registra sus sistemas en `_pipeline`, aplica config (run_config, etc.) y opcionalmente registra cuerpos. Todo lo que depende de Godot se crea en el kernel base; el proyecto solo añade pasos al pipeline y configuración.

---

## 4. Bucle de juego (tick)

Cada frame, `_process(delta)` acumula tiempo y ejecuta tantos **ticks fijos** como correspondan. En cada tick se obtiene un snapshot de input, se crea un `SimulationContext` y se ejecuta el pipeline.

```mermaid
%%{init: {'theme':'base', 'themeVariables': {'primaryColor':'#fff3e0','primaryTextColor':'#e65100','primaryBorderColor':'#ff9800','lineColor':'#37474f','secondaryColor':'#f5f5f5','tertiaryColor':'#ffffff','background':'#ffffff','mainBkg':'#ffffff','textColor':'#212121'}}}%%
flowchart TB
    subgraph frame["Por frame (_process)"]
        F1[Acumular delta]
        F2{¿accumulator >= fixed_dt?}
        F3[Obtener InputSnapshot para el tick]
        F4[Limpiar inputs de movimiento en state]
        F5[Crear SimulationContext]
        F6[Ejecutar pipeline.run]
        F7[Post-tick: replay, hash, etc.]
        F8[Restar fixed_dt, tick_index++]
    end

    F1 --> F2
    F2 -->|Sí| F3
    F3 --> F4
    F4 --> F5
    F5 --> F6
    F6 --> F7
    F7 --> F8
    F8 --> F2
    F2 -->|No| End[Fin del frame]
```

El **contexto** incluye: estado del juego, snapshot de input, adaptadores de física y sensores (combat, trigger), EventBus, ContentRegistry, logger y GameCore. Los sistemas reciben el mismo contexto y un `delta` fijo.

---

## 5. Orden de fases del pipeline

Los sistemas se registran en **fases** y con **prioridad**. El pipeline ordena por fase (en el orden definido en `GameConstants.PHASE_IDS`) y dentro de cada fase por prioridad (mayor primero).

```mermaid
%%{init: {'theme':'base', 'themeVariables': {'primaryColor':'#fce4ec','primaryTextColor':'#880e4f','primaryBorderColor':'#ad1457','lineColor':'#37474f','secondaryColor':'#f5f5f5','tertiaryColor':'#ffffff','background':'#ffffff','mainBkg':'#ffffff','textColor':'#212121'}}}%%
flowchart LR
    subgraph phase_input["phase.input"]
        I1[PlayerInputSystem]
        I2[AISystem]
        I3[TriggerBufferSystem]
    end

    subgraph phase_movement["phase.movement"]
        M1[Movement2DSystem]
    end

    subgraph phase_gameplay["phase.gameplay"]
        G1[CombatSystem]
        G2[HealthSystem]
        G3[RoomCombatSystem]
        G4[PickupSystem]
        G5[SurfaceSystem]
    end

    subgraph phase_post["phase.post"]
        P1[LevelSelectionSystem]
        P2[ShopOfferSystem]
        P3[RunEndSystem]
    end

    phase_input --> phase_movement
    phase_movement --> phase_gameplay
    phase_gameplay --> phase_post
```

Cada caja es una fase; dentro de ella el orden depende de la prioridad con la que se registró cada sistema. El proyecto decide qué sistemas registrar y en qué fase/prioridad.

---

## 6. Flujo de eventos (EventBus)

Los mods y sistemas se comunican por **eventos**: suscripción vía `GameAPI.subscribe()` y emisión vía `GameAPI.emit()`. El EventBus reparte los eventos a los handlers (con prioridad y opción de intercepción/cancelación).

```mermaid
%%{init: {'theme':'base', 'themeVariables': {'primaryColor':'#e1f5fe','primaryTextColor':'#01579b','primaryBorderColor':'#0288d1','lineColor':'#37474f','secondaryColor':'#f5f5f5','tertiaryColor':'#ffffff','background':'#ffffff','mainBkg':'#ffffff','textColor':'#212121'}}}%%
flowchart LR
    subgraph emisores["Emisores"]
        SYS[Systems]
        MOD[Mods]
        CORE[GameCore]
    end

    subgraph api["GameAPI"]
        EMIT[emit]
        SUB[subscribe]
    end

    subgraph bus["EventBus"]
        BUS[Handlers por evento, prioridad]
    end

    subgraph consumidores["Consumidores"]
        LIST[DebugListener, HUD]
        MOD2[Mods]
        SYS2[Systems]
    end

    SYS --> EMIT
    MOD --> EMIT
    CORE --> EMIT
    EMIT --> BUS
    SUB --> BUS
    BUS --> LIST
    BUS --> MOD2
    BUS --> SYS2
```

Los IDs de eventos están en `GameConstants`; los mods pueden usar prefijos `game.*` o `mod.*`. La lógica de juego no depende de Godot; solo del estado y de los eventos.

---

## 7. Carga de mods

El kernel descubre scripts de mods en `res://mods`, obtiene sus manifests, resuelve el orden (dependencias y versión) y llama a `on_load(api)` en ese orden.

```mermaid
%%{init: {'theme':'base', 'themeVariables': {'primaryColor':'#f3e5f5','primaryTextColor':'#4a148c','primaryBorderColor':'#7b1fa2','lineColor':'#37474f','secondaryColor':'#f5f5f5','tertiaryColor':'#ffffff','background':'#ffffff','mainBkg':'#ffffff','textColor':'#212121'}}}%%
flowchart TB
    A["Descubrir mods en res://mods"] --> B["Recolectar manifests"]
    B --> C["ModLoader.resolve_order"]
    C --> D{"Orden valido?"}
    D -->|No| E["Log error, no cargar mods"]
    D -->|Si| F["Por cada mod en orden"]
    F --> G["Validar requires_core, requires_game, deps"]
    G --> H["mod.on_load(api)"]
    H --> I["Registro en EventBus, etc."]
    I --> F
```

Los mods solo usan `GameAPI`; no acceden a platform ni a nodos de Godot. Así se mantiene la estabilidad del core y la compatibilidad entre versiones.

---

## 8. Conexión con Godot (bridges y adaptadores)

La integración con Godot se hace en dos sitios:

- **platform/godot**: implementaciones de interfaces (input, física, sensores, logger, etc.) que traducen llamadas del core a APIs de Godot.
- **presentation**: nodos de escena que registran cuerpos, hits y triggers en el kernel, o que se suscriben a eventos para la UI.

```mermaid
%%{init: {'theme':'base', 'themeVariables': {'primaryColor':'#e0f2f1','primaryTextColor':'#004d40','primaryBorderColor':'#00897b','lineColor':'#37474f','secondaryColor':'#f5f5f5','tertiaryColor':'#ffffff','background':'#ffffff','mainBkg':'#ffffff','textColor':'#212121'}}}%%
flowchart TB
    subgraph escena["Escena Godot"]
        PB[PlayerBodyBridge]
        HB[Hitbox2DBridge]
        TB[Trigger2DBridge]
    end

    subgraph kernel["Kernel"]
        REG_BODY[register_body]
        REG_HIT[register_hit]
        REG_TRIG[register_trigger]
    end

    subgraph adapters["Adaptadores (platform/godot)"]
        PHY[GodotPhysics2D]
        COMBAT[GodotCombatSensor2D]
        TRIG_S[GodotTriggerSensor2D]
    end

    PB --> REG_BODY
    REG_BODY --> PHY
    HB --> REG_HIT
    REG_HIT --> COMBAT
    TB --> REG_TRIG
    REG_TRIG --> TRIG_S
```

Los sistemas del core leen hits y triggers desde los sensores (por ejemplo en cada tick); no acceden a nodos. Así la arquitectura se mantiene limpia y testeable.

---

## 9. Referencias rápidas

| Documento | Contenido |
|----------|-----------|
| [addons/rage_core/README.md](../addons/rage_core/README.md) | Detalle del addon Rage Core, estructura de carpetas, contrato de mods |
| [addons/rage_toolkit/README.md](../addons/rage_toolkit/README.md) | CLI, dock, plantillas, metaprogramación |
| [addons/rage_toolkit/MULTI_GAME_PRODUCTION.md](../addons/rage_toolkit/MULTI_GAME_PRODUCTION.md) | Flujo para producir muchos juegos |
| [addons/rage_toolkit/CLI.md](../addons/rage_toolkit/CLI.md) | Comandos de scaffolding |
| [addons/rage_core/docs/REPLAY.md](../addons/rage_core/docs/REPLAY.md) | Replay determinista |

Los diagramas de este archivo están en Mermaid con tema de fondo claro para que las letras se vean bien en GitHub.
