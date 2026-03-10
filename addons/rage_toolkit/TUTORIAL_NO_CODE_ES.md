# Rage Toolkit: Tutorial Sin Código (Screenshots Simulados)

Esta guía muestra cómo crear un prototipo jugable sin programar.
Las capturas son simuladas para que coincidan con la UI.

## 0) Activar Plugins

Abre **Project Settings → Plugins** y activa:
- Rage Core
- Rage Toolkit

```
┌────────────────────────── Plugins ──────────────────────────┐
│ [✓] Rage Core        Enabled                               │
│ [✓] Rage Toolkit     Enabled                               │
└─────────────────────────────────────────────────────────────┘
```

## 1) Abrir el Dock

Abre el dock **Rage Core Scaffold** (lado derecho).

```
┌──────────────────── Rage Core Scaffold ─────────────────────┐
│ Project Init     [Create Base]                              │
│ Mod + Pack       [mod_id ______] [Create Scene] [Create]    │
│ Game Template    [game_id ___] [template v] [Scene] [Go]    │
│ Pickup           [pickup_id][mod_id][Pick Sprite][Pick Sfx] │
│ Enemy            [enemy_id][mod_id][AI v][Scene][Create]    │
│ Surface          [surface_id][mod_id][speed][accel][decel]  │
│ Ladder           [ladder_id][mod_id][Scene][Create]         │
│ Quick Wizard     [game_id][scenes/main.tscn][Create]        │
│ Scene Tools      [scenes/main.tscn][Pick][Add Floor][Add P] │
│ Status: Ready.                                              │
└─────────────────────────────────────────────────────────────┘
```

## 2) Crear un juego simple (Wizard)

En **Quick Wizard**:
- game_id: `mi_juego`
- scene: `scenes/main.tscn`
- click **Create Simple Game**

```
Quick Wizard:
[game_id: mi_juego] [scenes/main.tscn] [Create Simple Game]
```

Resultado:
- Crea `mods/mi_juego/` y `data_packs/mi_juego.json`
- Crea `scenes/mi_juego/main.tscn`
- Agrega un pickup base
- Agrega piso/jugador si la escena existe

## 3) Agregar colisiones

Abre `scenes/mi_juego/main.tscn` y agrega:
- **CollisionShape2D** bajo Player
- **CollisionShape2D** bajo Floor

```
Main
 ├─ Player (CharacterBody2D)
 │   └─ CollisionShape2D
 └─ Floor (StaticBody2D)
     └─ CollisionShape2D
```

## 4) Crear un Pickup

En el dock:
- pickup_id: `pickup_speed`
- mod_id: `mi_juego`
- selecciona sprite/sonido (opcional)
- Create Scene (activo)
- Click **Create Pickup**

```
Pickup:
[pickup_speed] [mi_juego] [Pick Sprite] [Pick Sfx] [✓ Scene] [Create Pickup]
```

Resultado:
- Agrega la entrada en `data_packs/mi_juego.json`
- Crea `scenes/pickups/pickup_speed.tscn`

## 5) Colocar el pickup en la escena

Arrastra `scenes/pickups/pickup_speed.tscn` dentro de la escena principal.
Colócalo sobre el piso.

## 6) Configurar Inputs

En **Project Settings → Input Map**, crea:
- move_left
- move_right
- move_up
- move_down
- jump
- ability_primary

## 7) Jugar

Presiona **Play**. El personaje se mueve y el pickup aplica su efecto.

## Problemas comunes

- No se mueve: verifica Input Map.
- No hay colisiones: asigna una Shape en CollisionShape2D.
- Pickup no activa: asegúrate de que el Area2D tenga CollisionShape2D y esté en escena.

## 8) Jugar en celular (Android/iOS)

Este proyecto es Godot. Para usarlo en celular debes exportar una build.

### Android
1) Instala export templates: **Editor → Manage Export Templates**.
2) Instala JDK + Android SDK (Android Studio) y configura rutas en:
   **Editor Settings → Export → Android**.
3) Ve a **Project → Export** y agrega el preset **Android**.
4) Configura el identificador del paquete (ej: `com.tuempresa.mijuego`).
5) Exporta un `.apk` (debug para pruebas) y cópialo al celular.

### iOS
- Requiere macOS + Xcode (desde Linux no se puede exportar iOS).
- Agrega el preset **iOS** en **Project → Export** y compila en Xcode
  con una cuenta de Apple para firmar la app.

### Controles táctiles
El juego usa acciones del **Input Map** (`move_left`, `move_right`, etc.).
En celular necesitas controles en pantalla:
- Agrega nodos `TouchScreenButton` o un joystick virtual en tu escena.
- Asigna cada botón a las acciones del Input Map.

