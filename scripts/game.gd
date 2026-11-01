extends Spatial

const WorldBuilder = preload("res://scripts/world_builder.gd")
const PlayerScript = preload("res://scripts/player.gd")
const UI = preload("res://scripts/touch_ui.gd")
const SaveManager = preload("res://scripts/save_manager.gd")
const Transport = preload("res://scripts/transport.gd")

var player
var ui
var world
var transport
var day_time = 0.32
var weather = "Sunny"
var coins = 120
var inventory = {"Rice": 3, "Seed": 8, "Water": 2}
var mission_text = "ရွာကိုလေ့လာပြီး လယ်ကွင်းကိုရှာပါ"

func _ready():
    randomize()
    world = WorldBuilder.new()
    add_child(world)
    world.build_world()
    player = PlayerScript.new()
    player.name = "Player"
    add_child(player)
    player.translation = Vector3(0, 0.1, 9)
    transport = Transport.new()
    transport.name = "Transport"
    add_child(transport)
    ui = UI.new()
    add_child(ui)
    ui.connect("action_pressed", self, "_on_action")
    ui.connect("gender_selected", self, "_on_gender")
    ui.set_status(mission_text, coins, weather, inventory)
    _apply_environment()

func _process(delta):
    day_time = fmod(day_time + delta * 0.003, 1.0)
    _apply_environment()

func _apply_environment():
    var sun = get_node_or_null("Sun")
    if sun == null:
        sun = DirectionalLight.new()
        sun.name = "Sun"
        sun.rotation_degrees = Vector3(-48, -32, 0)
        add_child(sun)
    var daylight = 0.35 + 0.65 * max(0.0, sin(day_time * PI * 2.0))
    sun.light_energy = daylight
    sun.light_color = Color(1.0, 0.78, 0.55).linear_interpolate(Color(1, 1, 1), daylight)

func _on_gender(value):
    if player:
        player.set_gender(value)

func _on_action(action):
    if action == "ride":
        mission_text = transport.toggle_ride(player)
    elif action == "interact":
        mission_text = "အနီးအနားက အရာဝတ္ထုကို စစ်ဆေးပြီးပါပြီ။"
        coins += 5
    elif action == "farm":
        inventory["Rice"] = int(inventory.get("Rice", 0)) + 1
        mission_text = "စပါးရိတ်သိမ်းပြီးပါပြီ။ +1 Rice"
    elif action == "sell":
        var rice_count = int(inventory.get("Rice", 0))
        if rice_count > 0:
            inventory["Rice"] = rice_count - 1
            coins += 25
            mission_text = "စပါး ၁ ထုပ် ရောင်းပြီး Coins +25 ရရှိပါပြီ။"
        else:
            mission_text = "ရောင်းရန် စပါးမရှိသေးပါ။ လယ်ကွင်းမှာ စိုက်ပျိုးပါ။"
    elif action == "weather":
        weather = "Rainy" if weather == "Sunny" else "Sunny"
        mission_text = "ရာသီဥတု: " + weather
    elif action == "save":
        SaveManager.save_game({"coins": coins, "inventory": inventory, "mission": mission_text, "gender": player.gender})
        mission_text = "Game သိမ်းပြီးပါပြီ။"
    elif action == "load":
        var data = SaveManager.load_game()
        if not data.empty():
            coins = int(data.get("coins", coins))
            inventory = data.get("inventory", inventory)
            mission_text = str(data.get("mission", mission_text))
            player.set_gender(str(data.get("gender", "Boy")))
    ui.set_status(mission_text, coins, weather, inventory)
