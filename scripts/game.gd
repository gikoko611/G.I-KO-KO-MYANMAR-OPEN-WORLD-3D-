extends Spatial

const WorldBuilder = preload("res://scripts/world_builder.gd")
const PlayerScript = preload("res://scripts/player.gd")
const UI = preload("res://scripts/touch_ui.gd")
const SaveManager = preload("res://scripts/save_manager.gd")
const Transport = preload("res://scripts/transport.gd")
const Farming = preload("res://scripts/farming.gd")

var player
var ui
var world
var transport
var farming
var day_time = 0.32
var weather = "Sunny"
var coins = 120
var inventory = {"Rice": 3, "Seed": 8, "Water": 2}
var mission_text = "ရွာလူကြီးကို သွားတွေ့ပါ။"
var quest_stage = 0
var quest_sell_remaining = 4
var hud_refresh = 0.0
var environment_refresh = 0.0
var dialogue_timer = 0.0
var crop_visuals = []
var music_controller
var graphics_level = 1
var music_enabled = true
var sound_enabled = true
var map_visible = false
var settings_visible = false

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
    farming = Farming.new()
    _create_crop_visuals()
    ui = UI.new()
    add_child(ui)
    ui.connect("action_pressed", self, "_on_action")
    ui.connect("gender_selected", self, "_on_gender")
    ui.set_status(mission_text + " | " + farming.get_status() + (" | Mission: Sell " + str(quest_sell_remaining) if quest_stage == 2 else ""), coins, weather, inventory)
    _apply_environment()
    _apply_graphics_quality()
    var MusicScript = preload("res://scripts/ambient_music.gd")
    music_controller = MusicScript.new()
    add_child(music_controller)

func _process(delta):
    if dialogue_timer > 0.0:
        dialogue_timer -= delta
        if dialogue_timer <= 0.0 and ui:
            ui.hide_dialogue()
    farming.tick(delta)
    _update_crop_visuals()
    hud_refresh += delta
    if hud_refresh >= 0.5:
        hud_refresh = 0.0
        if ui:
            ui.set_status(mission_text + " | " + farming.get_status() + (" | Mission: Sell " + str(quest_sell_remaining) if quest_stage == 2 else ""), coins, weather, inventory)
    day_time = fmod(day_time + delta * 0.003, 1.0)
    environment_refresh += delta
    if environment_refresh >= 0.25:
        environment_refresh = 0.0
        _apply_environment()
    if ui and player:
        ui.set_map_info(player.global_transform.origin, map_visible, mission_text)


func _create_crop_visuals():
    for i in range(4):
        var crop = MeshInstance.new()
        var mesh = CylinderMesh.new()
        mesh.top_radius = 0.025
        mesh.bottom_radius = 0.055
        mesh.height = 1.0
        crop.mesh = mesh
        var mat = SpatialMaterial.new()
        mat.albedo_color = Color(0.20,0.62,0.18)
        crop.material_override = mat
        crop.translation = Vector3(-17.2 + i*1.6, 0.08, 24.0)
        crop.scale = Vector3(1,0.08,1)
        crop.visible = false
        add_child(crop)
        crop_visuals.append(crop)

func _update_crop_visuals():
    var height = 0.0
    var crop_color = Color(0.20,0.62,0.18)
    if farming.phase == "planted":
        height = 0.18
    elif farming.phase == "growing":
        height = 0.18 + 0.65 * clamp(farming.growth_seconds / farming.growth_required, 0.0, 1.0)
    elif farming.phase == "ready":
        height = 0.95
        crop_color = Color(0.82,0.68,0.20)
    for crop in crop_visuals:
        crop.visible = height > 0.0
        crop.scale = Vector3(1,height,1)
        crop.translation.y = 0.12 + height * 0.5
        var mat = crop.material_override as SpatialMaterial
        if mat:
            mat.albedo_color = crop_color

func _apply_environment():
    var sun = get_node_or_null("Sun")
    if sun == null:
        sun = DirectionalLight.new()
        sun.name = "Sun"
        sun.rotation_degrees = Vector3(-48, -32, 0)
        sun.shadow_enabled = true
        sun.directional_shadow_mode = DirectionalLight.SHADOW_ORTHOGONAL
        sun.directional_shadow_max_distance = 90.0
        sun.shadow_bias = 0.08
        add_child(sun)
    var world_environment = get_node_or_null("WorldEnvironment")
    if world_environment == null:
        world_environment = WorldEnvironment.new()
        world_environment.name = "WorldEnvironment"
        var environment = Environment.new()
        environment.background_mode = Environment.BG_SKY
        var sky = ProceduralSky.new()
        sky.sky_top_color = Color(0.12, 0.32, 0.58)
        sky.sky_horizon_color = Color(0.72, 0.82, 0.91)
        sky.ground_bottom_color = Color(0.12, 0.16, 0.12)
        sky.ground_horizon_color = Color(0.48, 0.55, 0.42)
        sky.sun_angle_max = 18.0
        sky.sun_curve = 0.12
        environment.background_sky = sky
        environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
        environment.ambient_light_color = Color(0.62, 0.70, 0.78)
        environment.ambient_light_energy = 0.72
        environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
        environment.fog_enabled = true
        environment.fog_color = Color(0.62, 0.72, 0.78)
        environment.fog_depth_begin = 55.0
        environment.fog_depth_end = 190.0
        world_environment.environment = environment
        add_child(world_environment)
    var daylight = 0.35 + 0.65 * max(0.0, sin(day_time * PI * 2.0))
    sun.light_energy = daylight * (0.58 if weather == "Rainy" else 1.0)
    var target_sky = Color(0.55,0.60,0.66) if weather == "Rainy" else Color(1,1,1)
    sun.light_color = Color(1.0, 0.78, 0.55).linear_interpolate(target_sky, daylight)
    if world_environment.environment:
        world_environment.environment.fog_color = Color(0.40,0.48,0.55) if weather == "Rainy" else Color(0.62,0.72,0.78)
        world_environment.environment.ambient_light_energy = 0.52 if weather == "Rainy" else 0.72
        var active_sky = world_environment.environment.background_sky as ProceduralSky
        if active_sky:
            var sunset_mix = clamp(1.0 - daylight, 0.0, 1.0)
            active_sky.sky_top_color = Color(0.12,0.32,0.58).linear_interpolate(Color(0.12,0.12,0.24), sunset_mix)
            active_sky.sky_horizon_color = Color(0.72,0.82,0.91).linear_interpolate(Color(0.92,0.42,0.22), sunset_mix)

func _on_gender(value):
    if player:
        player.set_gender(value)

func _on_action(action):
    if action == "ride":
        mission_text = transport.toggle_ride(player)
    elif action == "jump":
        player.jump_now()
        mission_text = "ခုန်လိုက်ပါပြီ။"
    elif action == "sprint":
        var active = player.toggle_sprint()
        mission_text = "ပြေးနှုန်းမြှင့်ထားသည်။" if active else "ပုံမှန်လမ်းလျှောက်နှုန်း။"
    elif action == "view":
        var first_person = player.toggle_camera_mode()
        mission_text = "First Person View" if first_person else "Third Person View"
    elif action == "interact":
        var player_pos = player.global_transform.origin
        if quest_stage == 3 and player_pos.distance_to(Vector3(28,0,-22)) < 9.0:
            quest_stage = 4
            coins += 40
            ui.show_dialogue("ဘုရားစေတီ: ရွာအတွက် ကူညီပေးမှုအတွက် ကျေးဇူးတင်ပါတယ်။ Chapter 1 ပြီးဆုံးပါပြီ။ Coins +40")
            dialogue_timer = 7.0
            mission_text = "Chapter 1 ပြီးဆုံးပါပြီ။ ရွာလူကြီးထံမှ နောက်တာဝန်ကို ရယူပါ။"
        elif quest_stage == 4 and player_pos.distance_to(Vector3(-5,0,-13)) < 7.0:
            quest_stage = 5
            ui.show_dialogue("ရွာလူကြီး: ဘုန်းကြီးကျောင်းအတွက် ရေ ၃ ခွက် ပို့ပေးပါ။ ရေတွင်းမှာ အခမဲ့ ဖြည့်နိုင်ပါတယ်။")
            dialogue_timer = 7.0
            mission_text = "Chapter 2: ရေတွင်းမှ ရေ ၃ ခွက်ယူပြီး ဘုန်းကြီးကျောင်းသို့ ပို့ပါ။"
        elif quest_stage == 5 and player_pos.distance_to(Vector3(-34,0,-30)) < 12.0:
            if int(inventory.get("Water",0)) >= 3:
                inventory["Water"] = int(inventory.get("Water",0)) - 3
                quest_stage = 6
                coins += 60
                ui.show_dialogue("ဘုန်းကြီးကျောင်း: ရေ ၃ ခွက် လက်ခံရရှိပါပြီ။ ကူညီမှုအတွက် Coins +60")
                dialogue_timer = 7.0
                mission_text = "Chapter 2 ပြီးဆုံးပါပြီ။ နောက်ထပ်ရွာလုပ်ငန်းများကို စူးစမ်းပါ။"
            else:
                mission_text = "ဘုန်းကြီးကျောင်းသို့ ရေ ၃ ခွက် ယူလာပါ။ လက်ရှိရေ: " + str(int(inventory.get("Water",0)))
        elif quest_stage == 0 and player_pos.distance_to(Vector3(-5,0,-13)) < 7.0:
            quest_stage = 1
            ui.show_dialogue("ရွာလူကြီး: မင်္ဂလာပါ။ ဒီရွာရဲ့ လယ်ယာကို ကူညီပေးပါ။ စပါးစိုက်ပြီး ရိတ်သိမ်းကာ ဈေးမှာ ၄ ထုပ် ရောင်းပေးပါ။")
            dialogue_timer = 7.0
            quest_sell_remaining = 4
            coins += 30
            mission_text = "ရွာလူကြီးက စပါး ၄ ထုပ် စိုက်ပျိုးရိတ်သိမ်းဖို့ တာဝန်ပေးလိုက်ပါတယ်။ Coins +30"
        elif quest_stage == 2 and player_pos.distance_to(Vector3(8,0,18)) < 8.0 and quest_sell_remaining <= 0:
            ui.show_dialogue("ဈေးသည်: အရမ်းကောင်းပါတယ်။ စပါး ၄ ထုပ်လုံး လက်ခံရရှိပါပြီ။ ဒီမှာ ဆုကြေး Coins 50 ယူပါ။")
            dialogue_timer = 7.0
            quest_stage = 3
            coins += 50
            mission_text = "စပါးပို့ဆောင်မှု အောင်မြင်ပါပြီ။ ဘုရားစေတီသို့ သွားပြီး Interact လုပ်ပါ။ +50 Coins"
        elif player_pos.distance_to(Vector3(8,0,18)) < 8.0:
            ui.show_dialogue("ဈေးသည်: စပါးတစ်ထုပ်ကို Coins 25 နဲ့ ဝယ်ပါတယ်။ Sell Rice ကိုနှိပ်ပြီး ရောင်းနိုင်ပါတယ်။")
            dialogue_timer = 6.0
            mission_text = "ဈေးသည်နဲ့ စကားပြောပြီးပါပြီ။"
        elif player_pos.distance_to(Vector3(-5,0,-13)) < 7.0:
            ui.show_dialogue("ရွာလူကြီး: လယ်ကွင်းဘက်ကို သွားပါ။ Plant → Water → အချိန်စောင့် → Harvest လုပ်ပါ။")
            dialogue_timer = 6.0
            mission_text = "ရွာလူကြီးနဲ့ စကားပြောပြီးပါပြီ။"
        else:
            mission_text = "စကားပြောရန် ရွာလူကြီး သို့မဟုတ် ဈေးသည်အနီးသို့ သွားပါ။"
    elif action == "plant":
        if player.global_transform.origin.distance_to(Vector3(-18,0,24)) < 15.0:
            mission_text = farming.plant(inventory)
        else:
            mission_text = "စပါးခင်းထဲသို့ သွားပြီး Plant နှိပ်ပါ။"
    elif action == "water":
        if player.global_transform.origin.distance_to(Vector3(-18,0,24)) < 15.0:
            mission_text = farming.water(inventory)
        else:
            mission_text = "စပါးခင်းထဲသို့ သွားပြီး Water နှိပ်ပါ။"
    elif action == "harvest":
        var rice_before = int(inventory.get("Rice",0))
        if player.global_transform.origin.distance_to(Vector3(-18,0,24)) < 15.0:
            mission_text = farming.harvest(inventory)
        else:
            mission_text = "စပါးခင်းထဲသို့ သွားပြီး Harvest နှိပ်ပါ။"
        var rice_after = int(inventory.get("Rice",0))
        if quest_stage == 1 and rice_after > rice_before and rice_after >= 4:
            quest_stage = 2
            mission_text = "Mission: စပါးရရှိပါပြီ။ ဈေးသည်ဆီသို့ သွားရောက်ရောင်းချပါ။"
    elif action == "buy_seed":
        if player.global_transform.origin.distance_to(Vector3(8,0,18)) >= 9.0:
            mission_text = "မျိုးစေ့ဝယ်ရန် ဈေးသည်အနီးသို့ သွားပါ။"
        elif coins >= 10:
            coins -= 10
            inventory["Seed"] = int(inventory.get("Seed",0)) + 1
            mission_text = "မျိုးစေ့ ၁ ထုပ် ဝယ်ပြီးပါပြီ။"
        else:
            mission_text = "မျိုးစေ့ဝယ်ရန် Coins 10 လိုအပ်ပါတယ်။"
    elif action == "buy_water":
        var player_pos = player.global_transform.origin
        if player_pos.distance_to(Vector3(3,0,28)) < 7.0:
            inventory["Water"] = int(inventory.get("Water",0)) + 3
            mission_text = "ရွာရေတွင်းမှ ရေ ၃ ခွက် အခမဲ့ ဖြည့်ပြီးပါပြီ။"
            ui.show_dialogue("ရေတွင်း: ရေသန့်သန့်လေး ရပါပြီ။ လယ်ကွင်းကို သွားပြီး စပါးခင်းကို ရေလောင်းနိုင်ပါပြီ။")
            dialogue_timer = 5.0
        elif player_pos.distance_to(Vector3(8,0,18)) < 9.0 and coins >= 5:
            coins -= 5
            inventory["Water"] = int(inventory.get("Water",0)) + 2
            mission_text = "Coins 5 ဖြင့် ရေ ၂ ခွက် ဝယ်ပြီးပါပြီ။"
        else:
            mission_text = "ရေတွင်းမှာ အခမဲ့ဖြည့်ပါ၊ သို့မဟုတ် ဈေးသည်အနီးမှာ Coins 5 ဖြင့် ဝယ်ပါ။"
    elif action == "sell":
        var player_pos = player.global_transform.origin
        if player_pos.distance_to(Vector3(8,0,18)) >= 9.0:
            mission_text = "စပါးရောင်းရန် ဈေးသည်ဆီသို့ သွားပါ။"
        else:
            var rice_count = int(inventory.get("Rice", 0))
            if rice_count > 0:
                inventory["Rice"] = rice_count - 1
                coins += 25
                if quest_stage == 2 and quest_sell_remaining > 0:
                    quest_sell_remaining -= 1
                mission_text = "စပါး ၁ ထုပ် ရောင်းပြီး Coins +25 ရရှိပါပြီ။"
                if quest_stage == 2 and quest_sell_remaining > 0:
                    mission_text += " | Mission အတွက် " + str(quest_sell_remaining) + " ထုပ် ကျန်ပါသည်။"
                elif quest_stage == 2:
                    mission_text = "စပါး ၄ ထုပ်လုံး ပို့ပြီးပါပြီ။ ဈေးသည်ကို Interact လုပ်ပြီး ဆုယူပါ။"
            else:
                mission_text = "ရောင်းရန် စပါးမရှိသေးပါ။ လယ်ကွင်းမှာ စိုက်ပျိုးပါ။"
    elif action == "map":
        map_visible = not map_visible
        ui.set_map_info(player.global_transform.origin, map_visible, mission_text)
        mission_text = "မြေပုံဖွင့်ထားသည်။" if map_visible else "မြေပုံပိတ်ထားသည်။"
    elif action == "settings":
        settings_visible = not settings_visible
        ui.set_settings_info(settings_visible, graphics_level, music_enabled, sound_enabled)
        mission_text = "Game Settings ဖွင့်ထားသည်။" if settings_visible else "Game Settings ပိတ်ထားသည်။"
    elif action == "quality":
        graphics_level = (graphics_level + 1) % 3
        _apply_graphics_quality()
        ui.set_settings_info(settings_visible, graphics_level, music_enabled, sound_enabled)
        mission_text = "Graphics Quality: " + ["Low","Balanced","High"][graphics_level]
    elif action == "music":
        music_enabled = not music_enabled
        if music_controller: music_controller.set_music_enabled(music_enabled)
        ui.set_settings_info(settings_visible, graphics_level, music_enabled, sound_enabled)
        mission_text = "Background Music: " + ("ON" if music_enabled else "OFF")
    elif action == "sound":
        sound_enabled = not sound_enabled
        if music_controller: music_controller.set_sound_enabled(sound_enabled)
        ui.set_settings_info(settings_visible, graphics_level, music_enabled, sound_enabled)
        mission_text = "Sound: " + ("ON" if sound_enabled else "OFF")
    elif action == "weather":
        weather = "Rainy" if weather == "Sunny" else "Sunny"
        mission_text = "ရာသီဥတု: " + weather
    elif action == "save":
        var save_position = player.global_transform.origin
        if player.is_mounted() and is_instance_valid(player.mounted_vehicle):
            var vehicle_basis = player.mounted_vehicle.global_transform.basis
            save_position = player.mounted_vehicle.global_transform.origin + vehicle_basis.xform(Vector3(2.0,0.0,0.0)) + Vector3(0,0.2,0)
        var saved = SaveManager.save_game({"graphics_level": graphics_level, "music_enabled": music_enabled, "sound_enabled": sound_enabled,"coins": coins, "inventory": inventory, "mission": mission_text, "gender": player.gender, "day_time": day_time, "weather": weather, "player_x": save_position.x, "player_y": save_position.y, "player_z": save_position.z, "crop_phase": farming.phase, "crop_growth": farming.growth_seconds, "quest_stage": quest_stage, "quest_sell_remaining": quest_sell_remaining, "first_person": player.first_person, "player_yaw": player.rotation.y, "player_pitch": player.camera_pivot.rotation_degrees.x, "vehicle_state": transport.get_save_data()})
        mission_text = "Game သိမ်းပြီးပါပြီ။" if saved else "Save မအောင်မြင်ပါ။ Storage permission နှင့် နေရာလွတ်ကို စစ်ပါ။"
    elif action == "load":
        var data = SaveManager.load_game()
        if not data.empty():
            if player.is_mounted():
                player.dismount_vehicle()
            coins = int(data.get("coins", coins))
            inventory = data.get("inventory", inventory)
            mission_text = str(data.get("mission", mission_text))
            player.set_gender(str(data.get("gender", "Boy")))
            if bool(data.get("first_person", false)) != player.first_person:
                player.toggle_camera_mode()
            day_time = float(data.get("day_time", day_time))
            weather = str(data.get("weather", weather))
            player.translation = Vector3(float(data.get("player_x", 0)), float(data.get("player_y", 0.1)), float(data.get("player_z", 9)))
            player.rotation.y = float(data.get("player_yaw", player.rotation.y))
            player.yaw = player.rotation.y
            player.camera_pivot.rotation_degrees.x = float(data.get("player_pitch", player.camera_pivot.rotation_degrees.x))
            transport.load_save_data(data.get("vehicle_state", {}))
            farming.phase = str(data.get("crop_phase", "empty"))
            farming.growth_seconds = float(data.get("crop_growth", 0.0))
            quest_stage = int(data.get("quest_stage", quest_stage))
            quest_sell_remaining = int(data.get("quest_sell_remaining", quest_sell_remaining))
            graphics_level = int(data.get("graphics_level", graphics_level))
            music_enabled = bool(data.get("music_enabled", music_enabled))
            sound_enabled = bool(data.get("sound_enabled", sound_enabled))
            _apply_graphics_quality()
            if music_controller:
                music_controller.set_music_enabled(music_enabled)
                music_controller.set_sound_enabled(sound_enabled)
            ui.set_settings_info(settings_visible, graphics_level, music_enabled, sound_enabled)
            ui.set_map_info(player.global_transform.origin, map_visible, mission_text)
    ui.set_status(mission_text + " | " + farming.get_status() + (" | Mission: Sell " + str(quest_sell_remaining) if quest_stage == 2 else ""), coins, weather, inventory)

func _apply_graphics_quality():
    var sun = get_node_or_null("Sun")
    if sun:
        sun.shadow_enabled = graphics_level >= 1
        sun.directional_shadow_max_distance = [45.0, 70.0, 90.0][clamp(graphics_level, 0, 2)]
    if get_viewport():
        get_viewport().msaa = Viewport.MSAA_DISABLED
        get_viewport().shadow_atlas_size = [1024, 1536, 2048][clamp(graphics_level, 0, 2)]
    if player and player.camera:
        player.camera.far = [85.0, 135.0, 190.0][clamp(graphics_level, 0, 2)]
        player.camera.fov = [72.0, 70.0, 68.0][clamp(graphics_level, 0, 2)]
