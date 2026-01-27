#!/usr/bin/env python3
import argparse
import json
import os
import re
import sys


def die(message: str) -> None:
    print(f"error: {message}")
    sys.exit(1)


def ensure_dir(path: str) -> None:
    os.makedirs(path, exist_ok=True)


def write_file(path: str, content: str, force: bool) -> None:
    if os.path.exists(path) and not force:
        die(f"file exists: {path} (use --force to overwrite)")
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


def read_json(path: str) -> dict:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def write_json(path: str, data: dict, force: bool) -> None:
    if os.path.exists(path) and not force:
        die(f"file exists: {path} (use --force to overwrite)")
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")


def append_pack_entry(pack_path: str, entry: dict) -> None:
    if os.path.exists(pack_path):
        data = read_json(pack_path)
    else:
        data = {"pack_id": os.path.splitext(os.path.basename(pack_path))[0], "contents": []}
    contents = data.get("contents", [])
    contents.append(entry)
    data["contents"] = contents
    with open(pack_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")


def to_class_name(value: str) -> str:
    tokens = re.split(r"[^A-Za-z0-9]+", value)
    tokens = [t for t in tokens if t]
    return "".join(t[0].upper() + t[1:] for t in tokens)


def sanitize_filename(value: str) -> str:
    return re.sub(r"[^A-Za-z0-9_]+", "_", value)


def project_root(path: str) -> str:
    root = os.path.abspath(path)
    addons_path = os.path.join(root, "addons", "rage_core")
    if not os.path.isdir(addons_path):
        die("addons/rage_core not found. Run from project root or use --root.")
    return root


def _get_toolkit_path(root: str) -> str:
    """Get path to rage_toolkit (where rage.py now lives)"""
    return os.path.join(root, "addons", "rage_toolkit")


def cmd_mod_new(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    mod_id = args.id
    deps_dict = {}
    for dep in args.deps:
        if "@" not in dep:
            die("deps must be in form id@constraint")
        dep_id, constraint = dep.split("@", 1)
        deps_dict[dep_id] = constraint
    manifest = {
        "id": mod_id,
        "version": args.version,
        "requires_core": args.requires_core,
        "requires_game": args.requires_game,
        "deps": deps_dict,
        "load_order_hint": args.order,
    }
    filename = write_mod_file(
        root,
        mod_id,
        args.description,
        manifest,
        args.force,
    )
    print(f"created mod: {filename}")


def write_mod_file(root: str, mod_id: str, description: str, manifest: dict, force: bool) -> str:
    mod_dir = os.path.join(root, "mods", mod_id)
    ensure_dir(mod_dir)
    class_name = f"Mod{to_class_name(mod_id)}"
    filename = os.path.join(mod_dir, f"mod_{sanitize_filename(mod_id)}.gd")
    content = f"""# Mods: {description}
class_name {class_name}
extends ModBase

var _manifest: ModManifest

func _init() -> void:
\tvar data := {json.dumps(manifest, indent=2).replace('"', '"')}
\tvar result := ModManifest.from_dict(data)
\tif result.ok:
\t\t_manifest = result.value

func get_manifest() -> ModManifest:
\treturn _manifest

func on_load(api: GameAPI) -> void:
\t# TODO: register content or subscribe to events.
\tpass
"""
    write_file(filename, content, force)
    return filename


def cmd_pack_new(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    ensure_dir(os.path.join(root, "data_packs"))
    pack_path = os.path.join(root, "data_packs", f"{args.id}.json")
    data = {"pack_id": args.id, "contents": []}
    write_json(pack_path, data, args.force)
    print(f"created pack: {pack_path}")


def _write_pickup_mod(mod_id: str, pickup_id: str, mod_dir: str, force: bool) -> str:
    class_name = f"ModPickup{to_class_name(pickup_id)}"
    filename = os.path.join(mod_dir, f"mod_pickup_{sanitize_filename(pickup_id)}.gd")
    content = f"""# Mods: Pickup mod ({pickup_id}). Allowed deps: core + game types only.
class_name {class_name}
extends ModBase

var _manifest: ModManifest
var _pickup_id := "{pickup_id}"

func _init() -> void:
\tvar data := {{
\t\t"id": "pickup.{pickup_id}",
\t\t"version": "1.0.0",
\t\t"requires_core": "^1.0.0",
\t\t"requires_game": "^1.0.0",
\t\t"deps": {{}},
\t\t"load_order_hint": 50
\t}}
\tvar result := ModManifest.from_dict(data)
\tif result.ok:
\t\t_manifest = result.value

func get_manifest() -> ModManifest:
\treturn _manifest

func on_load(api: GameAPI) -> void:
\tvar def := ContentDef.new(_pickup_id, GameConstants.CONTENT_PICKUP, {{"type": "{pickup_id}"}}, _manifest.id)
\tvar res := api.register_content(def)
\tif not res.ok:
\t\tapi.get_logger().error("Pickup register failed: " + str(res.error))
\tapi.subscribe(GameConstants.EVENT_PICKUP, func(event: EventBase) -> void:
\t\tif event is PickupEvent and event.get_pickup_id() == _pickup_id:
\t\t\t# TODO: apply pickup effect here.
\t\t\tpass
\t)
"""
    write_file(filename, content, force)
    return filename


def _write_scene(path: str, node_type: str, script_path: str, name: str, force: bool) -> None:
    content = (
        "[gd_scene load_steps=2 format=3]\n"
        f"[ext_resource type=\"Script\" path=\"{script_path}\" id=\"1\"]\n"
        f"[node name=\"{name}\" type=\"{node_type}\"]\n"
        "script = ExtResource(\"1\")\n"
    )
    write_file(path, content, force)


def cmd_pickup_new(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    mod_id = args.mod
    if not mod_id:
        die("--mod is required")
    mod_dir = os.path.join(root, "mods", mod_id)
    ensure_dir(mod_dir)
    mod_file = _write_pickup_mod(mod_id, args.id, mod_dir, args.force)

    ensure_dir(os.path.join(root, "data_packs"))
    pack_path = os.path.join(root, "data_packs", f"{mod_id}.json")
    entry = {"id": args.id, "type": "content.pickup", "data": {"type": args.id}}
    append_pack_entry(pack_path, entry)

    if args.scene:
        ensure_dir(os.path.join(root, "scenes", "pickups"))
        scene_path = os.path.join(root, "scenes", "pickups", f"{args.id}.tscn")
        _write_scene(
            scene_path,
            "Area2D",
            "res://addons/rage_core/presentation/trigger_2d_bridge.gd",
            f"Pickup{to_class_name(args.id)}",
            args.force,
        )
    print(f"created pickup mod: {mod_file}")


def cmd_enemy_new(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    mod_id = args.mod
    if not mod_id:
        die("--mod is required")
    mod_dir = os.path.join(root, "mods", mod_id)
    ensure_dir(mod_dir)
    class_name = f"ModEnemy{to_class_name(args.id)}"
    filename = os.path.join(mod_dir, f"mod_enemy_{sanitize_filename(args.id)}.gd")
    content = f"""# Mods: Enemy mod ({args.id}). Allowed deps: core + game types only.
class_name {class_name}
extends ModBase

var _manifest: ModManifest
var _enemy_id := "{args.id}"

func _init() -> void:
\tvar data := {{
\t\t"id": "enemy.{args.id}",
\t\t"version": "1.0.0",
\t\t"requires_core": "^1.0.0",
\t\t"requires_game": "^1.0.0",
\t\t"deps": {{}},
\t\t"load_order_hint": 60
\t}}
\tvar result := ModManifest.from_dict(data)
\tif result.ok:
\t\t_manifest = result.value

func get_manifest() -> ModManifest:
\treturn _manifest

func on_load(api: GameAPI) -> void:
\tvar def := ContentDef.new(_enemy_id, GameConstants.CONTENT_ENEMY, {{"type": "{args.ai}"}}, _manifest.id)
\tvar res := api.register_content(def)
\tif not res.ok:
\t\tapi.get_logger().error("Enemy register failed: " + str(res.error))
"""
    write_file(filename, content, args.force)

    ensure_dir(os.path.join(root, "data_packs"))
    pack_path = os.path.join(root, "data_packs", f"{mod_id}.json")
    entry = {"id": args.id, "type": "content.enemy", "data": {"ai": args.ai}}
    append_pack_entry(pack_path, entry)

    if args.scene:
        ensure_dir(os.path.join(root, "scenes", "enemies"))
        scene_path = os.path.join(root, "scenes", "enemies", f"{args.id}.tscn")
        _write_scene(
            scene_path,
            "CharacterBody2D",
            "res://addons/rage_core/presentation/player_body_bridge.gd",
            to_class_name(args.id),
            args.force,
        )
    print(f"created enemy mod: {filename}")


def cmd_surface_new(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    mod_id = args.mod
    if not mod_id:
        die("--mod is required")
    ensure_dir(os.path.join(root, "data_packs"))
    pack_path = os.path.join(root, "data_packs", f"{mod_id}.json")
    entry = {
        "id": args.id,
        "type": "content.surface",
        "data": {
            "max_speed_mult": args.max_speed_mult,
            "accel_mult": args.accel_mult,
            "decel_mult": args.decel_mult,
        },
    }
    append_pack_entry(pack_path, entry)

    if args.scene:
        ensure_dir(os.path.join(root, "scenes", "surfaces"))
        scene_path = os.path.join(root, "scenes", "surfaces", f"{args.id}.tscn")
        _write_scene(
            scene_path,
            "Area2D",
            "res://addons/rage_core/presentation/trigger_2d_bridge.gd",
            f"Surface{to_class_name(args.id)}",
            args.force,
        )
    print(f"created surface entry: {args.id}")


def cmd_ladder_new(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    mod_id = args.mod
    if not mod_id:
        die("--mod is required")
    ensure_dir(os.path.join(root, "data_packs"))
    pack_path = os.path.join(root, "data_packs", f"{mod_id}.json")
    entry = {"id": args.id, "type": "content.ladder", "data": {}}
    append_pack_entry(pack_path, entry)

    if args.scene:
        ensure_dir(os.path.join(root, "scenes", "ladders"))
        scene_path = os.path.join(root, "scenes", "ladders", f"{args.id}.tscn")
        _write_scene(
            scene_path,
            "Area2D",
            "res://addons/rage_core/presentation/trigger_2d_bridge.gd",
            f"Ladder{to_class_name(args.id)}",
            args.force,
        )
    print(f"created ladder entry: {args.id}")


def cmd_listener_new(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    mod_id = args.mod
    if not mod_id:
        die("--mod is required")
    mod_dir = os.path.join(root, "mods", mod_id, "systems")
    ensure_dir(mod_dir)
    class_name = f"{to_class_name(args.name)}System"
    filename = os.path.join(mod_dir, f"{sanitize_filename(args.name)}_system.gd")
    content = f"""# Mods: Event-driven system scaffold. Allowed deps: core + game types only.
class_name {class_name}
extends ModBase

var _manifest: ModManifest
var _token: int = -1

func _init() -> void:
\tvar data := {{
\t\t"id": "{mod_id}.{args.name}",
\t\t"version": "1.0.0",
\t\t"requires_core": "^1.0.0",
\t\t"requires_game": "^1.0.0",
\t\t"deps": {{}},
\t\t"load_order_hint": {args.order}
\t}}
\tvar result := ModManifest.from_dict(data)
\tif result.ok:
\t\t_manifest = result.value

func get_manifest() -> ModManifest:
\treturn _manifest

func on_load(api: GameAPI) -> void:
\tvar res := api.subscribe("{args.event}", func(event: EventBase) -> void:
\t\t# TODO: implement system logic here.
\t\tpass
\t)
\tif res.ok:
\t\t_token = int(res.value)

func on_unload(api: GameAPI) -> void:
\tif _token >= 0:
\t\tapi.unsubscribe(_token)
"""
    write_file(filename, content, args.force)
    print(f"created listener: {filename}")


def _write_base_scene(root: str, scene_path: str, force: bool) -> None:
    content = (
        "[gd_scene format=3]\n"
        "[node name=\"Main\" type=\"Node2D\"]\n"
        "[node name=\"Player\" type=\"CharacterBody2D\" parent=\".\"]\n"
        "[node name=\"Floor\" type=\"StaticBody2D\" parent=\".\"]\n"
    )
    write_file(scene_path, content, force)


def cmd_game_new(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    template = args.template
    mod_id = args.id
    manifest = {
        "id": mod_id,
        "version": "1.0.0",
        "requires_core": "^1.0.0",
        "requires_game": "^1.0.0",
        "deps": {},
        "load_order_hint": 0,
    }
    write_mod_file(root, mod_id, "Game mod scaffold", manifest, args.force)
    ensure_dir(os.path.join(root, "data_packs"))
    pack_path = os.path.join(root, "data_packs", f"{mod_id}.json")
    write_json(pack_path, {"pack_id": mod_id, "contents": []}, args.force)

    if args.scene:
        ensure_dir(os.path.join(root, "scenes", mod_id))
        scene_path = os.path.join(root, "scenes", mod_id, "main.tscn")
        _write_base_scene(root, scene_path, args.force)

    if template == "platformer_basic":
        cmd_pickup_new(argparse.Namespace(
            id="pickup_speed",
            mod=mod_id,
            scene=args.scene,
            force=args.force,
            root=args.root
        ))
    elif template == "melee_platformer":
        cmd_pickup_new(argparse.Namespace(
            id="pickup_speed",
            mod=mod_id,
            scene=args.scene,
            force=args.force,
            root=args.root
        ))
        cmd_enemy_new(argparse.Namespace(
            id="enemy_small",
            mod=mod_id,
            ai="patrol",
            scene=args.scene,
            force=args.force,
            root=args.root
        ))
    elif template == "runner_basic":
        cmd_surface_new(argparse.Namespace(
            id="surface_ice",
            mod=mod_id,
            max_speed_mult=1.2,
            accel_mult=0.6,
            decel_mult=0.4,
            scene=args.scene,
            force=args.force,
            root=args.root
        ))
    elif template == "arena_basic":
        cmd_enemy_new(argparse.Namespace(
            id="enemy_small",
            mod=mod_id,
            ai="chase",
            scene=args.scene,
            force=args.force,
            root=args.root
        ))
    print(f"created game scaffold: {mod_id} ({template})")


def cmd_template_new(args: argparse.Namespace) -> None:
    """Create a game from an internal template"""
    root = project_root(args.root)
    game_id = args.id
    template_name = args.template_name
    
    # Get template directory
    toolkit_path = _get_toolkit_path(root)
    template_dir = os.path.join(toolkit_path, "templates", template_name)
    
    if not os.path.isdir(template_dir):
        die(f"template not found: {template_name}")
    
    # Read template manifest
    manifest_path = os.path.join(template_dir, "manifest.json")
    if not os.path.exists(manifest_path):
        die(f"template manifest not found: {manifest_path}")
    
    manifest = read_json(manifest_path)
    
    # Create game directory structure
    ensure_dir(os.path.join(root, "game"))
    ensure_dir(os.path.join(root, "mods"))
    ensure_dir(os.path.join(root, "data_packs"))
    if args.scene:
        ensure_dir(os.path.join(root, "scenes", game_id))
    
    # Copy kernel
    template_kernel = os.path.join(template_dir, "kernel.gd")
    if os.path.exists(template_kernel):
        with open(template_kernel, "r", encoding="utf-8") as f:
            kernel_content = f.read()
        kernel_path = os.path.join(root, "game", "game_kernel.gd")
        write_file(kernel_path, kernel_content, args.force)
        print(f"created kernel: {kernel_path}")
    
    # Create mod from template
    template_mod = os.path.join(template_dir, "mod_base.gd")
    if os.path.exists(template_mod):
        mod_dir = os.path.join(root, "mods", game_id)
        ensure_dir(mod_dir)
        with open(template_mod, "r", encoding="utf-8") as f:
            mod_content = f.read()
        mod_path = os.path.join(mod_dir, f"mod_{game_id}.gd")
        write_file(mod_path, mod_content, args.force)
        
        # Create mod manifest
        mod_manifest = {
            "id": game_id,
            "version": "1.0.0",
            "requires_core": "^1.0.0",
            "requires_game": "^1.0.0",
            "deps": {},
            "load_order_hint": 0,
        }
        manifest_path_mod = os.path.join(mod_dir, "manifest.json")
        write_json(manifest_path_mod, mod_manifest, args.force)
        print(f"created mod: {mod_path}")
    
    # Create pack from template
    template_pack = os.path.join(template_dir, "pack.json")
    if os.path.exists(template_pack):
        pack_data = read_json(template_pack)
        # Update pack_id to match game_id
        pack_data["pack_id"] = game_id
        pack_path = os.path.join(root, "data_packs", f"{game_id}.json")
        write_json(pack_path, pack_data, args.force)
        print(f"created pack: {pack_path}")
    
    # Create base scene if requested
    if args.scene:
        scene_path = os.path.join(root, "scenes", game_id, "main.tscn")
        scene_content = (
            "[gd_scene format=3]\n"
            "[node name=\"Main\" type=\"Node2D\"]\n"
            "[node name=\"Player\" type=\"CharacterBody2D\" parent=\".\"]\n"
            "[node name=\"Floor\" type=\"StaticBody2D\" parent=\".\"]\n"
        )
        write_file(scene_path, scene_content, args.force)
        print(f"created scene: {scene_path}")
    
    print(f"created game '{game_id}' from template '{template_name}'")
    print(f"Template includes: {', '.join(manifest.get('systems', []))}")


def cmd_list_mods(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    mods_path = os.path.join(root, "mods")
    if not os.path.isdir(mods_path):
        print("no mods directory")
        return
    for dirpath, _, filenames in os.walk(mods_path):
        for name in filenames:
            if name.endswith(".gd"):
                print(os.path.join(dirpath, name))


def cmd_list_packs(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    packs_path = os.path.join(root, "data_packs")
    if not os.path.isdir(packs_path):
        print("no data_packs directory")
        return
    for name in os.listdir(packs_path):
        if name.endswith(".json"):
            print(os.path.join(packs_path, name))


def cmd_scene_add_floor(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    scene_path = os.path.join(root, "scenes", args.scene)
    if not os.path.exists(scene_path):
        die(f"scene not found: {scene_path}")
    content = (
        "[node name=\"Floor\" type=\"StaticBody2D\" parent=\".\"]\n"
        "[node name=\"Collision\" type=\"CollisionShape2D\" parent=\"Floor\"]\n"
    )
    with open(scene_path, "a", encoding="utf-8") as f:
        f.write(content)
    print(f"added floor nodes to: {scene_path}")


def cmd_scene_add_player(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    scene_path = os.path.join(root, "scenes", args.scene)
    if not os.path.exists(scene_path):
        die(f"scene not found: {scene_path}")
    content = (
        "[ext_resource type=\"Script\" path=\"res://addons/rage_core/presentation/player_body_bridge.gd\" id=\"1\"]\n"
        "[node name=\"Player\" type=\"CharacterBody2D\" parent=\".\"]\n"
        "script = ExtResource(\"1\")\n"
        "[node name=\"Collision\" type=\"CollisionShape2D\" parent=\"Player\"]\n"
    )
    with open(scene_path, "a", encoding="utf-8") as f:
        f.write(content)
    print(f"added player nodes to: {scene_path}")


def cmd_game_system_new(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    mod_id = args.mod
    if not mod_id:
        die("--mod is required")
    sys_dir = os.path.join(root, "mods", mod_id, "systems", args.name)
    ensure_dir(sys_dir)

    state_path = os.path.join(sys_dir, "state.gd")
    api_path = os.path.join(sys_dir, "api.gd")
    system_path = os.path.join(sys_dir, "system.gd")

    state_content, api_content, system_content = _game_system_templates(
        args.name, mod_id, args.order, args.template
    )

    write_file(state_path, state_content, args.force)
    write_file(api_path, api_content, args.force)
    write_file(system_path, system_content, args.force)
    print(f"created game system: {sys_dir}")


def _game_system_templates(name: str, mod_id: str, order: int, template: str) -> tuple[str, str, str]:
    class_base = to_class_name(name)
    state_header = f"# Mods: System state for {name}.\nclass_name {class_base}State\n\n"
    api_header = f"# Mods: System API for {name}.\nclass_name {class_base}API\n\n"
    system_header = f"# Mods: Game system for {name}.\nclass_name {class_base}System\nextends ModBase\n\n"

    if template == "inventory":
        state_body = "var items := []\nvar max_slots: int = 20\n"
        api_body = (
            f"var _state: {class_base}State\n\n"
            f"func _init(state: {class_base}State) -> void:\n\t_state = state\n\n"
            "func add_item(item_id: String) -> bool:\n\tif _state.items.size() >= _state.max_slots:\n\t\treturn false\n\t_state.items.append(item_id)\n\treturn true\n\n"
            "func remove_item(item_id: String) -> bool:\n\treturn _state.items.erase(item_id)\n\n"
            f"func get_state() -> {class_base}State:\n\treturn _state\n"
        )
    elif template == "cards":
        state_body = "var deck := []\nvar hand := []\nvar discard := []\nvar max_hand: int = 5\n"
        api_body = (
            f"var _state: {class_base}State\n\n"
            f"func _init(state: {class_base}State) -> void:\n\t_state = state\n\n"
            "func draw_card() -> void:\n\tif _state.deck.size() == 0:\n\t\treturn\n\tif _state.hand.size() >= _state.max_hand:\n\t\treturn\n\t_state.hand.append(_state.deck.pop_back())\n\n"
            "func discard_hand() -> void:\n\t_state.discard.append_array(_state.hand)\n\t_state.hand.clear()\n\n"
            f"func get_state() -> {class_base}State:\n\treturn _state\n"
        )
    elif template == "economy":
        state_body = "var currency: int = 0\nvar shop_items := []\n"
        api_body = (
            f"var _state: {class_base}State\n\n"
            f"func _init(state: {class_base}State) -> void:\n\t_state = state\n\n"
            "func add_currency(amount: int) -> void:\n\t_state.currency += max(0, amount)\n\n"
            "func spend_currency(amount: int) -> bool:\n\tif _state.currency < amount:\n\t\treturn false\n\t_state.currency -= amount\n\treturn true\n\n"
            f"func get_state() -> {class_base}State:\n\treturn _state\n"
        )
    elif template == "progression":
        state_body = "var level: int = 1\nvar xp: int = 0\nvar skill_points: int = 0\n"
        api_body = (
            f"var _state: {class_base}State\n\n"
            f"func _init(state: {class_base}State) -> void:\n\t_state = state\n\n"
            "func add_xp(amount: int) -> void:\n\t_state.xp += max(0, amount)\n\n"
            "func level_up() -> void:\n\t_state.level += 1\n\t_state.skill_points += 1\n\n"
            f"func get_state() -> {class_base}State:\n\treturn _state\n"
        )
    elif template == "loot":
        state_body = "var drop_tables := {}\nvar rarity_weights := {}\n"
        api_body = (
            f"var _state: {class_base}State\n\n"
            f"func _init(state: {class_base}State) -> void:\n\t_state = state\n\n"
            "func register_table(table_id: String, entries: Array) -> void:\n\t_state.drop_tables[table_id] = entries\n\n"
            "func get_table(table_id: String) -> Array:\n\treturn _state.drop_tables.get(table_id, [])\n\n"
            f"func get_state() -> {class_base}State:\n\treturn _state\n"
        )
    elif template == "quest":
        state_body = "var active := []\nvar completed := []\nvar progress := {}\n"
        api_body = (
            f"var _state: {class_base}State\n\n"
            f"func _init(state: {class_base}State) -> void:\n\t_state = state\n\n"
            "func start_quest(quest_id: String) -> void:\n\t_state.active.append(quest_id)\n\n"
            "func complete_quest(quest_id: String) -> void:\n\t_state.completed.append(quest_id)\n\t_state.active.erase(quest_id)\n\n"
            f"func get_state() -> {class_base}State:\n\treturn _state\n"
        )
    else:
        state_body = "var data := {}\n"
        api_body = (
            f"var _state: {class_base}State\n\n"
            f"func _init(state: {class_base}State) -> void:\n\t_state = state\n\n"
            f"func get_state() -> {class_base}State:\n\treturn _state\n"
        )

    system_body = (
        "var _manifest: ModManifest\n"
        f"var _state := {class_base}State.new()\n"
        f"var _api := {class_base}API.new(_state)\n\n"
        "func _init() -> void:\n"
        "\tvar data := {\n"
        f"\t\t\"id\": \"{mod_id}.{name}\",\n"
        "\t\t\"version\": \"1.0.0\",\n"
        "\t\t\"requires_core\": \"^1.0.0\",\n"
        "\t\t\"requires_game\": \"^1.0.0\",\n"
        "\t\t\"deps\": {},\n"
        f"\t\t\"load_order_hint\": {order}\n"
        "\t}\n"
        "\tvar result := ModManifest.from_dict(data)\n"
        "\tif result.ok:\n"
        "\t\t_manifest = result.value\n\n"
        "func get_manifest() -> ModManifest:\n\treturn _manifest\n\n"
        "func on_load(api: GameAPI) -> void:\n\t# TODO: register listeners and expose API if needed.\n\tpass\n"
    )

    return (
        state_header + state_body,
        api_header + api_body,
        system_header + system_body,
    )


def _game_kernel_template() -> str:
    return (
        "# Game: Project-specific kernel extension. Allowed deps: Godot + Rage Core.\n"
        "extends GameKernel\n"
        "class_name GameKernelGame\n\n"
        "func _ready() -> void:\n"
        "\tsuper._ready()\n"
        "\t# Optional Rage Core setup (uncomment to enable).\n"
        "\t# Inputs: binds default action ids to Godot input names.\n"
        "\t# _bind_default_inputs()\n"
        "\t# Input sampling + AI + trigger buffering.\n"
        "\t# _player_input_system = PlayerInputSystem.new()\n"
        "\t# _pipeline.register_step(GameConstants.PHASE_INPUT, 100, _player_input_system)\n"
        "\t# _ai_system = AISystem.new()\n"
        "\t# _pipeline.register_step(GameConstants.PHASE_INPUT, 90, _ai_system)\n"
        "\t# _trigger_buffer_system = TriggerBufferSystem.new()\n"
        "\t# _pipeline.register_step(GameConstants.PHASE_INPUT, 10, _trigger_buffer_system)\n"
        "\t# Core movement loop + default player entity.\n"
        "\t# _movement_system = Movement2DSystem.new()\n"
        "\t# _movement_system.register_entity(\"player\")\n"
        "\t# _pipeline.register_step(GameConstants.PHASE_MOVEMENT, 100, _movement_system)\n"
        "\t# Gameplay systems (combat, pickups, surfaces, ladders).\n"
        "\t# _combat_system = CombatSystem.new()\n"
        "\t# _pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 50, _combat_system)\n"
        "\t# _pickup_system = PickupSystem.new()\n"
        "\t# _pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 40, _pickup_system)\n"
        "\t# _surface_system = SurfaceSystem.new()\n"
        "\t# _pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 30, _surface_system)\n"
        "\t# _ladder_system = LadderSystem.new()\n"
        "\t# _pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 20, _ladder_system)\n"
        "\t# Debug: prints pipeline order on boot (requires boot_log enabled).\n"
        "\t# _log_pipeline_registration()\n"
        "\t# Content: packs from res://addons/rage_core/data_packs and res://data_packs.\n"
        "\t# _load_content_packs()\n"
        "\t# Mods: load and call on_load() in deterministic order.\n"
        "\t# _load_mods()\n"
        "\n"
        "func _load_content_packs() -> void:\n"
        "\tsuper._load_content_packs()\n"
        "\t_load_content_packs_from_dir(\"user://data_packs\")\n"
    )

def cmd_project_init(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    ensure_dir(os.path.join(root, "mods"))
    ensure_dir(os.path.join(root, "data_packs"))
    ensure_dir(os.path.join(root, "scenes"))
    ensure_dir(os.path.join(root, "assets"))
    ensure_dir(os.path.join(root, "presentation"))
    ensure_dir(os.path.join(root, "design"))
    ensure_dir(os.path.join(root, "game"))

    manifest = {
        "id": args.mod,
        "version": "1.0.0",
        "requires_core": "^1.0.0",
        "requires_game": "^1.0.0",
        "deps": {},
        "load_order_hint": 0,
    }
    write_mod_file(root, args.mod, "Base game mod", manifest, args.force)
    pack_path = os.path.join(root, "data_packs", f"{args.pack}.json")
    write_json(pack_path, {"pack_id": args.pack, "contents": []}, args.force)
    if args.scene:
        scene_path = os.path.join(root, "scenes", "main.tscn")
        content = (
            "[gd_scene format=3]\n"
            "[node name=\"Main\" type=\"Node2D\"]\n"
            "[node name=\"Player\" type=\"CharacterBody2D\" parent=\".\"]\n"
        )
        write_file(scene_path, content, args.force)
    kernel_path = os.path.join(root, "game", "game_kernel.gd")
    if not os.path.exists(kernel_path) or args.force:
        write_file(kernel_path, _game_kernel_template(), True)
    # rage.py is now in addons/rage_toolkit/, no need to copy it
    toolkit_path = _get_toolkit_path(root)
    if not os.path.exists(toolkit_path):
        print(f"Note: rage.py is now in {toolkit_path}/rage.py")
    print(f"initialized project with mod '{args.mod}' and pack '{args.pack}'")


def cmd_modpack_new(args: argparse.Namespace) -> None:
    root = project_root(args.root)
    manifest = {
        "id": args.id,
        "version": args.version,
        "requires_core": args.requires_core,
        "requires_game": args.requires_game,
        "deps": {},
        "load_order_hint": args.order,
    }
    write_mod_file(root, args.id, "Mod scaffold", manifest, args.force)
    ensure_dir(os.path.join(root, "data_packs"))
    pack_path = os.path.join(root, "data_packs", f"{args.id}.json")
    write_json(pack_path, {"pack_id": args.id, "contents": []}, args.force)
    if args.scene:
        ensure_dir(os.path.join(root, "scenes", args.id))
        scene_path = os.path.join(root, "scenes", args.id, "main.tscn")
        content = (
            "[gd_scene format=3]\n"
            "[node name=\"Main\" type=\"Node2D\"]\n"
            "[node name=\"Player\" type=\"CharacterBody2D\" parent=\".\"]\n"
        )
        write_file(scene_path, content, args.force)
    print(f"created mod+pack: {args.id}")


# ============================================================================
# New Commands: Using Rage Core Metaprogramming Tools
# ============================================================================

def _system_template(system_name: str, phase: str = "phase.gameplay", priority: int = 50) -> str:
    """Generate system template matching SystemGenerator.generate_system_template"""
    class_name = to_class_name(system_name)
    return f"""# Game: {system_name} system. Allowed deps: core types + game types.
class_name {class_name}System
extends SimulationStep

func run(context: SimulationContext, delta: float) -> void:
	# TODO: Implement {system_name} logic
	pass
"""


def _event_template(event_name: str, event_id: str = "") -> str:
    """Generate event template matching SystemGenerator.generate_event_template"""
    if not event_id:
        event_id = f"game.{event_name.lower().replace(' ', '_')}"
    class_name = to_class_name(event_name + "Event")
    return f"""# Game: {event_name} event payload. Uses Rage Core EventBase.
class_name {class_name}
extends EventBase

const ID := "{event_id}"

func _init() -> void:
	super._init(ID)
	payload = {{
		# TODO: Add event payload fields
	}}

func validate() -> Result:
	# TODO: Add validation logic
	return Result.ok_result(true)
"""


def _command_template(command_name: str, command_id: str = "") -> str:
    """Generate command template matching SystemGenerator.generate_command_template"""
    if not command_id:
        command_id = f"cmd.{command_name.lower().replace(' ', '_')}"
    class_name = to_class_name(command_name + "Command")
    return f"""# Game: {command_name} command. Allowed deps: core types + game types.
class_name {class_name}
extends ICommand

const ID := "{command_id}"

var _entity_id: String
# TODO: Add command fields

func _init(entity_id: String) -> void:
	_entity_id = entity_id

func get_id() -> String:
	return ID

func validate() -> Result:
	if not Ids.is_valid_id(_entity_id):
		return Result.err_result("Invalid entity_id")
	# TODO: Add more validation
	return Result.ok_result(true)
"""


def cmd_system_new(args: argparse.Namespace) -> None:
    """Create a game system using SystemGenerator template"""
    root = project_root(args.root)
    system_name = args.name
    output_dir = args.output or "game/systems"
    phase = args.phase or "phase.gameplay"
    priority = args.priority or 50
    
    ensure_dir(os.path.join(root, output_dir))
    system_path = os.path.join(root, output_dir, f"{system_name.lower()}_system.gd")
    content = _system_template(system_name, phase, priority)
    write_file(system_path, content, args.force)
    print(f"created system: {system_path}")
    print(f"  Use CodeGenerator.generate_and_register_system() to auto-register in game_kernel.gd")


def cmd_event_new(args: argparse.Namespace) -> None:
    """Create an event using SystemGenerator template"""
    root = project_root(args.root)
    event_name = args.name
    event_id = args.event_id or ""
    output_dir = args.output or "game/events"
    
    ensure_dir(os.path.join(root, output_dir))
    event_path = os.path.join(root, output_dir, f"{event_name.lower()}_event.gd")
    content = _event_template(event_name, event_id)
    write_file(event_path, content, args.force)
    print(f"created event: {event_path}")


def cmd_command_new(args: argparse.Namespace) -> None:
    """Create a command using SystemGenerator template"""
    root = project_root(args.root)
    command_name = args.name
    command_id = args.command_id or ""
    output_dir = args.output or "game/commands"
    
    ensure_dir(os.path.join(root, output_dir))
    command_path = os.path.join(root, output_dir, f"{command_name.lower()}_command.gd")
    content = _command_template(command_name, command_id)
    write_file(command_path, content, args.force)
    print(f"created command: {command_path}")


def cmd_system_complete(args: argparse.Namespace) -> None:
    """Create a complete system with events using CodeGenerator approach"""
    root = project_root(args.root)
    system_name = args.name
    output_dir = args.output or "game/systems"
    phase = args.phase or "phase.gameplay"
    priority = args.priority or 50
    events = args.events or []
    
    # Generate system
    ensure_dir(os.path.join(root, output_dir))
    system_path = os.path.join(root, output_dir, f"{system_name.lower()}_system.gd")
    
    # Generate system with events if provided
    if events:
        event_preloads = ""
        event_vars = ""
        for event_name in events:
            class_name = to_class_name(event_name + "Event")
            event_preloads += f"const {class_name} = preload(\"res://game/events/{event_name.lower()}_event.gd\")\n"
            event_vars += f"\tvar {event_name.lower()}_ev: {class_name}\n"
        
        class_name = to_class_name(system_name)
        system_content = f"""# Game: {system_name} system. Allowed deps: core types + game types.
class_name {class_name}System
extends SimulationStep

{event_preloads}

func run(context: SimulationContext, delta: float) -> void:
	# TODO: Implement {system_name} logic
{event_vars}
	pass
"""
    else:
        system_content = _system_template(system_name, phase, priority)
    
    write_file(system_path, system_content, args.force)
    
    # Generate event files
    if events:
        events_dir = os.path.join(root, output_dir, "..", "events")
        ensure_dir(events_dir)
        for event_name in events:
            event_path = os.path.join(events_dir, f"{event_name.lower()}_event.gd")
            event_content = _event_template(event_name)
            write_file(event_path, event_content, args.force)
    
    print(f"created system: {system_path}")
    if events:
        print(f"created {len(events)} event(s)")
    print(f"  Use CodeGenerator.generate_and_register_system() to auto-register in game_kernel.gd")


def cmd_generate_script(args: argparse.Namespace) -> None:
    """Generate a GDScript script that uses CodeGenerator to create systems"""
    root = project_root(args.root)
    script_path = os.path.join(root, args.output or "generate_systems.gd")
    
    content = """# Auto-generated script to use CodeGenerator
# Run this from Godot editor (EditorScript) or attach to a Node

extends Node

func _ready() -> void:
	_generate_systems()

func _generate_systems() -> void:
	print("=== Generating Systems with CodeGenerator ===")
	
	# Example: Generate a system
	# var result = CodeGenerator.generate_and_register_system(
	#     "MySystem",
	#     "res://game/game_kernel.gd",
	#     "res://game/systems",
	#     "phase.gameplay",
	#     50,
	#     true
	# )
	
	# Example: Generate system with events
	# var result = CodeGenerator.generate_system_complete(
	#     "Combat",
	#     "res://game/systems",
	#     "phase.gameplay",
	#     50,
	#     ["DamageDealt", "EnemyDefeated"],
	#     true
	# )
	
	print("Edit this script to generate your systems!")
"""
    write_file(script_path, content, args.force)
    print(f"created generator script: {script_path}")
    print("  Edit and run this script in Godot to use CodeGenerator")

def main() -> None:
    parser = argparse.ArgumentParser(prog="rage", description="Rage Core scaffolding CLI")
    parser.add_argument("--root", default=".", help="Project root (default: .)")
    sub = parser.add_subparsers(dest="cmd")

    mod_new = sub.add_parser("mod:new", help="Create a mod scaffold")
    mod_new.add_argument("id")
    mod_new.add_argument("--author", default="Unknown")
    mod_new.add_argument("--version", default="1.0.0")
    mod_new.add_argument("--requires-core", default="^1.0.0")
    mod_new.add_argument("--requires-game", default="^1.0.0")
    mod_new.add_argument("--deps", action="append", default=[])
    mod_new.add_argument("--order", type=int, default=0)
    mod_new.add_argument("--description", default="Mod scaffold")
    mod_new.add_argument("--force", action="store_true")
    mod_new.set_defaults(func=cmd_mod_new)

    pack_new = sub.add_parser("pack:new", help="Create an empty content pack")
    pack_new.add_argument("id")
    pack_new.add_argument("--force", action="store_true")
    pack_new.set_defaults(func=cmd_pack_new)

    pickup_new = sub.add_parser("pickup:new", help="Create a pickup mod and pack entry")
    pickup_new.add_argument("id")
    pickup_new.add_argument("--mod", required=True)
    pickup_new.add_argument("--scene", action="store_true")
    pickup_new.add_argument("--force", action="store_true")
    pickup_new.set_defaults(func=cmd_pickup_new)

    enemy_new = sub.add_parser("enemy:new", help="Create an enemy mod and pack entry")
    enemy_new.add_argument("id")
    enemy_new.add_argument("--mod", required=True)
    enemy_new.add_argument("--ai", default="patrol", choices=["idle", "patrol", "chase"])
    enemy_new.add_argument("--scene", action="store_true")
    enemy_new.add_argument("--force", action="store_true")
    enemy_new.set_defaults(func=cmd_enemy_new)

    surface_new = sub.add_parser("surface:new", help="Create a surface pack entry")
    surface_new.add_argument("id")
    surface_new.add_argument("--mod", required=True)
    surface_new.add_argument("--max-speed-mult", type=float, default=1.0)
    surface_new.add_argument("--accel-mult", type=float, default=1.0)
    surface_new.add_argument("--decel-mult", type=float, default=1.0)
    surface_new.add_argument("--scene", action="store_true")
    surface_new.add_argument("--force", action="store_true")
    surface_new.set_defaults(func=cmd_surface_new)

    ladder_new = sub.add_parser("ladder:new", help="Create a ladder pack entry")
    ladder_new.add_argument("id")
    ladder_new.add_argument("--mod", required=True)
    ladder_new.add_argument("--scene", action="store_true")
    ladder_new.add_argument("--force", action="store_true")
    ladder_new.set_defaults(func=cmd_ladder_new)

    list_mods = sub.add_parser("list:mods", help="List detected mods")
    list_mods.set_defaults(func=cmd_list_mods)

    list_packs = sub.add_parser("list:packs", help="List content packs")
    list_packs.set_defaults(func=cmd_list_packs)

    proj_init = sub.add_parser("project:init", help="Create base mod + pack structure")
    proj_init.add_argument("--mod", default="base")
    proj_init.add_argument("--pack", default="base")
    proj_init.add_argument("--scene", action="store_true")
    proj_init.add_argument("--force", action="store_true")
    proj_init.set_defaults(func=cmd_project_init)

    modpack_new = sub.add_parser("modpack:new", help="Create a mod + pack with same id")
    modpack_new.add_argument("id")
    modpack_new.add_argument("--version", default="1.0.0")
    modpack_new.add_argument("--requires-core", default="^1.0.0")
    modpack_new.add_argument("--requires-game", default="^1.0.0")
    modpack_new.add_argument("--order", type=int, default=0)
    modpack_new.add_argument("--scene", action="store_true")
    modpack_new.add_argument("--force", action="store_true")
    modpack_new.set_defaults(func=cmd_modpack_new)

    listener_new = sub.add_parser("listener:new", help="Create an event-driven listener scaffold")
    listener_new.add_argument("name")
    listener_new.add_argument("--mod", required=True)
    listener_new.add_argument("--event", default="game.damage")
    listener_new.add_argument("--order", type=int, default=0)
    listener_new.add_argument("--force", action="store_true")
    listener_new.set_defaults(func=cmd_listener_new)

    game_new = sub.add_parser("game:new", help="Create a game scaffold with a template")
    game_new.add_argument("id")
    game_new.add_argument("--template", default="custom", choices=["custom", "platformer_basic", "melee_platformer", "runner_basic", "arena_basic"])
    game_new.add_argument("--scene", action="store_true")
    game_new.add_argument("--force", action="store_true")
    game_new.set_defaults(func=cmd_game_new)

    template_new = sub.add_parser("template:new", help="Create a game from an internal template")
    template_new.add_argument("id", help="Game ID")
    template_new.add_argument("--from", dest="template_name", required=True, choices=["arena", "platformer", "roguelike", "topdown", "cards"], help="Template to use")
    template_new.add_argument("--scene", action="store_true", help="Create a base scene")
    template_new.add_argument("--force", action="store_true", help="Overwrite existing files")
    template_new.add_argument("--root", default=".", help="Project root (default: current directory)")
    template_new.set_defaults(func=cmd_template_new)

    scene_floor = sub.add_parser("scene:add_floor", help="Append a basic floor node to a scene")
    scene_floor.add_argument("--scene", required=True)
    scene_floor.set_defaults(func=cmd_scene_add_floor)

    scene_player = sub.add_parser("scene:add_player", help="Append a basic player node to a scene")
    scene_player.add_argument("--scene", required=True)
    scene_player.set_defaults(func=cmd_scene_add_player)

    system_game = sub.add_parser("game_system:new", help="Create a game system scaffold (state + api + system)")
    system_game.add_argument("name")
    system_game.add_argument("--mod", required=True)
    system_game.add_argument("--template", default="custom", choices=["custom", "inventory", "cards", "economy", "progression", "loot", "quest"])
    system_game.add_argument("--order", type=int, default=0)
    system_game.add_argument("--force", action="store_true")
    system_game.set_defaults(func=cmd_game_system_new)

    # New metaprogramming commands
    system_new = sub.add_parser("system:new", help="Create a game system using SystemGenerator template")
    system_new.add_argument("name", help="System name (e.g., 'Combat', 'Economy')")
    system_new.add_argument("--output", default="game/systems", help="Output directory (default: game/systems)")
    system_new.add_argument("--phase", default="phase.gameplay", help="Simulation phase (default: phase.gameplay)")
    system_new.add_argument("--priority", type=int, default=50, help="Priority in phase (default: 50)")
    system_new.add_argument("--force", action="store_true", help="Overwrite existing files")
    system_new.set_defaults(func=cmd_system_new)

    event_new = sub.add_parser("event:new", help="Create an event using SystemGenerator template")
    event_new.add_argument("name", help="Event name (e.g., 'DamageDealt', 'ItemCollected')")
    event_new.add_argument("--event-id", default="", help="Event ID (default: auto-generated)")
    event_new.add_argument("--output", default="game/events", help="Output directory (default: game/events)")
    event_new.add_argument("--force", action="store_true", help="Overwrite existing files")
    event_new.set_defaults(func=cmd_event_new)

    command_new = sub.add_parser("command:new", help="Create a command using SystemGenerator template")
    command_new.add_argument("name", help="Command name (e.g., 'Move', 'Attack')")
    command_new.add_argument("--command-id", default="", help="Command ID (default: auto-generated)")
    command_new.add_argument("--output", default="game/commands", help="Output directory (default: game/commands)")
    command_new.add_argument("--force", action="store_true", help="Overwrite existing files")
    command_new.set_defaults(func=cmd_command_new)

    system_complete = sub.add_parser("system:complete", help="Create a complete system with events (CodeGenerator approach)")
    system_complete.add_argument("name", help="System name")
    system_complete.add_argument("--output", default="game/systems", help="Output directory (default: game/systems)")
    system_complete.add_argument("--phase", default="phase.gameplay", help="Simulation phase (default: phase.gameplay)")
    system_complete.add_argument("--priority", type=int, default=50, help="Priority in phase (default: 50)")
    system_complete.add_argument("--events", nargs="+", default=[], help="Event names to generate (e.g., DamageDealt EnemyDefeated)")
    system_complete.add_argument("--force", action="store_true", help="Overwrite existing files")
    system_complete.set_defaults(func=cmd_system_complete)

    generate_script = sub.add_parser("generate:script", help="Generate a GDScript that uses CodeGenerator")
    generate_script.add_argument("--output", default="generate_systems.gd", help="Output script path (default: generate_systems.gd)")
    generate_script.add_argument("--force", action="store_true", help="Overwrite existing files")
    generate_script.set_defaults(func=cmd_generate_script)

    args = parser.parse_args()
    if not args.cmd:
        parser.print_help()
        sys.exit(1)
    args.func(args)


if __name__ == "__main__":
    main()

