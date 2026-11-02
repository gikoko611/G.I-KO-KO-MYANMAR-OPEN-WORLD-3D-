extends SceneTree

func _init():
    var paths = [
        "res://scripts/game.gd",
        "res://scripts/player.gd",
        "res://scripts/world_builder.gd",
        "res://scripts/touch_ui.gd",
        "res://scripts/save_manager.gd",
        "res://scripts/transport.gd",
        "res://scripts/farming.gd",
        "res://scripts/ambient_music.gd",
        "res://scripts/survival_system.gd",
        "res://scripts/culture_expansion.gd",
        "res://scripts/splash_screen.gd",
        "res://scripts/open_world_expansion.gd",
        "res://scripts/economy_rpg.gd",
        "res://scripts/companion_system.gd",
        "res://scripts/interior_system.gd"
    ]
    var failed = false
    for path in paths:
        print("VALIDATING_SCRIPT: " + path)
        var resource = load(path)
        if resource == null:
            printerr("SCRIPT_LOAD_FAILED: " + path)
            failed = true
        else:
            print("SCRIPT_PARSE_OK: " + path)
    if failed:
        quit(1)
    else:
        print("ALL_GDSCRIPT_RESOURCES_PARSED")
        quit(0)
