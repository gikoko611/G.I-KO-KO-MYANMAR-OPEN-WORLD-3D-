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
        "res://scripts/splash_screen.gd"
    ]
    var failed = false
    for path in paths:
        var resource = load(path)
        if resource == null:
            printerr("SCRIPT_LOAD_FAILED: " + path)
            failed = true
        else:
            var instance = resource.new()
            if instance == null:
                printerr("SCRIPT_INSTANTIATE_FAILED: " + path)
                failed = true
            else:
                print("SCRIPT_LOAD_AND_INSTANTIATE_OK: " + path)
                instance.free()
    if failed:
        quit(1)
    else:
        print("ALL_GDSCRIPT_RESOURCES_LOADED")
        quit(0)
