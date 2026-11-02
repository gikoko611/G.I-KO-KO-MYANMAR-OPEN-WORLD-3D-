extends CanvasLayer
signal action_pressed(action)
signal gender_selected(value)

var status_label
var coin_label
var weather_label
var dialogue_label
var inventory_label
var move_vector = Vector2.ZERO
var dragging_move = false
var dragging_look = false
var last_touch = Vector2.ZERO
var move_origin = Vector2.ZERO
var move_touch_index = -1
var look_touch_index = -1
var map_label
var settings_label

func _ready():
    var root = Control.new()
    root.set_anchors_and_margins_preset(Control.PRESET_WIDE)
    add_child(root)
    status_label = _label(root, "ရွာကိုလေ့လာပြီး လယ်ကွင်းကိုရှာပါ", Vector2(18,18), Vector2(760,52), 17)
    status_label.autowrap = true
    coin_label = _label(root, "Coins: 120", Vector2(18,58), Vector2(180,30), 18)
    weather_label = _label(root, "Sunny", Vector2(18,90), Vector2(180,28), 16)
    inventory_label = _label(root, "Bag: Rice 3 | Seed 8 | Water 2", Vector2(18,118), Vector2(520,28), 15)
    dialogue_label = _label(root, "", Vector2(18,-92), Vector2(650,48), 16)
    dialogue_label.anchor_top = 1
    dialogue_label.anchor_bottom = 1
    dialogue_label.autowrap = true
    dialogue_label.add_color_override("font_color", Color(1.0,0.88,0.55))
    _button(root, "Boy", Vector2(18,158), "boy")
    _button(root, "Girl", Vector2(100,158), "girl")
    _button(root, "Mission", Vector2(185,158), "mission")
    _button(root, "Mode", Vector2(280,158), "mode")
    _button(root, "MM/EN", Vector2(375,158), "language")
    _button(root, "Forest +30", Vector2(470,158), "forest_mission")
    var choose_label = _label(root, "CHOOSE YOUR CHARACTER", Vector2(18,140), Vector2(160,18), 10)
    choose_label.modulate = Color(1.0,0.82,0.35,0.9)
    _button(root, "Dive", Vector2(-460,-330), "dive", true)
    _button(root, "Climb", Vector2(-360,-330), "climb", true)
    _button(root, "Fruit", Vector2(-260,-330), "fruit", true)
    _button(root, "Market Sell", Vector2(-560,-330), "shop_sell", true)
    _button(root, "Sword", Vector2(-560,-275), "buy_sword", true)
    _button(root, "Armor", Vector2(-560,-220), "buy_armor", true)
    _button(root, "Shield", Vector2(-560,-165), "buy_shield", true)
    _button(root, "Arrows x5", Vector2(-560,-385), "buy_arrows", true)
    _button(root, "Rod", Vector2(-460,-385), "buy_rod", true)
    _button(root, "Skills", Vector2(-360,-385), "skills", true)
    _button(root, "Upgrade", Vector2(-260,-385), "upgrade_skill", true)
    _button(root, "Story", Vector2(-160,-385), "story", true)
    _button(root, "Gather", Vector2(-460,-275), "gather", true)
    _button(root, "Fish", Vector2(-360,-275), "fish", true)
    _button(root, "Hunt", Vector2(-260,-275), "hunt", true)
    _button(root, "Craft", Vector2(-160,-275), "craft", true)
    _button(root, "Sprint", Vector2(-360,-220), "sprint", true)
    _button(root, "Jump", Vector2(-360,-165), "jump", true)
    _button(root, "View", Vector2(-460,-220), "view", true)
    _button(root, "Ride", Vector2(-260,-220), "ride", true)
    _button(root, "Interact", Vector2(-160,-220), "interact", true)
    _button(root, "Plant", Vector2(-160,-165), "plant", true)
    _button(root, "Water", Vector2(-260,-165), "water", true)
    _button(root, "Harvest", Vector2(-160,-110), "harvest", true)
    _button(root, "Sell Rice", Vector2(-260,-110), "sell", true)
    _button(root, "Weather", Vector2(-360,-110), "weather", true)
    _button(root, "Save", Vector2(-160,-55), "save", true)
    _button(root, "Load", Vector2(-260,-55), "load", true)
    _button(root, "Buy Seed", Vector2(-360,-55), "buy_seed", true)
    _button(root, "Buy Water", Vector2(-460,-165), "buy_water", true)
    _button(root, "Map", Vector2(-460,-55), "map", true)
    _button(root, "Settings", Vector2(-560,-55), "settings", true)
    _button(root, "Quality", Vector2(-560,-110), "quality", true)
    _button(root, "Music", Vector2(-560,-165), "music", true)
    _button(root, "Sound", Vector2(-560,-220), "sound", true)
    map_label = _label(root, "", Vector2(18,205), Vector2(390,145), 14)
    map_label.autowrap = true
    settings_label = _label(root, "", Vector2(420,205), Vector2(330,130), 14)
    settings_label.autowrap = true
    map_label.visible = false
    settings_label.visible = false
    var hint = _label(root, "ဘယ်ဘက်: လှုပ်ရှား  |  ညာဘက်: ကင်မရာလှည့်", Vector2(18,-42), Vector2(460,28), 14)
    hint.modulate = Color(1,1,1,0.8)

func _label(parent, text_value, pos, size, font_size):
    var l = Label.new()
    l.text = text_value
    l.rect_position = pos
    l.rect_size = size
    l.add_color_override("font_color", Color(1,1,1))
    l.add_color_override("font_color_shadow", Color(0,0,0))
    l.add_constant_override("shadow_offset_x", 2)
    l.add_constant_override("shadow_offset_y", 2)
    parent.add_child(l)
    return l

func _button(parent, caption, pos, action, from_right=false):
    var b = Button.new()
    b.text = caption
    b.rect_size = Vector2(94,44)
    b.anchor_left = 1 if from_right else 0
    b.anchor_right = 1 if from_right else 0
    b.anchor_top = 1 if from_right else 0
    b.anchor_bottom = 1 if from_right else 0
    b.rect_position = pos
    b.connect("pressed", self, "_button_action", [action])
    parent.add_child(b)

func _button_action(action):
    if action == "boy" or action == "girl":
        emit_signal("gender_selected", "Boy" if action == "boy" else "Girl")
    else:
        emit_signal("action_pressed", action)

func set_status(message, coins, weather, inventory):
    if status_label:
        status_label.text = str(message)
        coin_label.text = "Coins: " + str(coins)
        weather_label.text = "Weather: " + str(weather)
        inventory_label.text = "Bag: Rice " + str(inventory.get("Rice",0)) + " | Seed " + str(inventory.get("Seed",0)) + " | Water " + str(inventory.get("Water",0)) + " | Gem " + str(inventory.get("Gem",0)) + " | Fruit " + str(inventory.get("Fruit",0)) + " | Meat " + str(inventory.get("Meat",0)) + " | Wood " + str(inventory.get("Wood",0))

func show_dialogue(message):
    if dialogue_label:
        dialogue_label.text = str(message)

func hide_dialogue():
    if dialogue_label:
        dialogue_label.text = ""

func _input(event):
    if event is InputEventScreenTouch:
        if event.pressed:
            var screen_size = get_viewport().size
            if event.position.x < screen_size.x * 0.38 and event.position.y > screen_size.y * 0.52 and move_touch_index == -1:
                move_touch_index = event.index
                move_origin = event.position
                move_vector = Vector2.ZERO
                dragging_move = true
                _send_move()
            elif event.position.x >= screen_size.x * 0.38 and event.position.y > screen_size.y * 0.46 and event.position.y < screen_size.y * 0.64 and look_touch_index == -1:
                look_touch_index = event.index
                last_touch = event.position
                dragging_look = true
        else:
            if event.index == move_touch_index:
                move_touch_index = -1
                dragging_move = false
                move_vector = Vector2.ZERO
                _send_move()
            if event.index == look_touch_index:
                look_touch_index = -1
                dragging_look = false
    elif event is InputEventScreenDrag:
        if event.index == move_touch_index:
            var delta = event.position - move_origin
            move_vector = Vector2(clamp(delta.x/85.0,-1,1), clamp(delta.y/85.0,-1,1))
            _send_move()
        elif event.index == look_touch_index:
            var p = get_parent().get_node_or_null("Player")
            if p:
                p.add_look(event.relative)

func _send_move():
    var p = get_parent().get_node_or_null("Player")
    if p: p.set_move(move_vector)

func set_map_info(position, visible, mission):
    if map_label:
        map_label.visible = visible
        if visible:
            var nearest_name = "Main Village"
            var nearest_distance = 99999.0
            var expansion = get_parent().get_node_or_null("OpenWorldExpansion")
            if expansion:
                for village in expansion.village_centers:
                    var village_pos = village.position
                    var distance = Vector2(position.x, position.z).distance_to(Vector2(village_pos.x, village_pos.z))
                    if distance < nearest_distance:
                        nearest_distance = distance
                        nearest_name = str(village.name)
            var marker_text = "📍 Nearest: " + nearest_name + " (" + str(int(nearest_distance)) + "m)"
            map_label.text = "MYANMAR OPEN WORLD MAP\n12 VILLAGES • 1,200 HOMES\nX: " + str(int(position.x)) + "  Z: " + str(int(position.z)) + "\n" + marker_text + "\nLAKE • WATERFALL • CAVE • FOREST\nObjective: " + str(mission)

func set_settings_info(visible, quality, music, sound):
    if settings_label:
        settings_label.visible = visible
        if visible:
            settings_label.text = "GAME SETTINGS\nGraphics: " + ["Low","Balanced","High"][int(quality)] + "\nBackground Music: " + ("ON" if music else "OFF") + "\nSound: " + ("ON" if sound else "OFF") + "\nTap Quality / Music / Sound to change"
