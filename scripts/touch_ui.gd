extends CanvasLayer
signal action_pressed(action)
signal gender_selected(value)

var status_label
var coin_label
var weather_label
var inventory_label
var move_vector = Vector2.ZERO
var dragging_move = false
var dragging_look = false
var last_touch = Vector2.ZERO

func _ready():
    var root = Control.new()
    root.set_anchors_and_margins_preset(Control.PRESET_WIDE)
    add_child(root)
    status_label = _label(root, "ရွာကိုလေ့လာပြီး လယ်ကွင်းကိုရှာပါ", Vector2(18,18), Vector2(600,36), 20)
    coin_label = _label(root, "Coins: 120", Vector2(18,58), Vector2(180,30), 18)
    weather_label = _label(root, "Sunny", Vector2(18,90), Vector2(180,28), 16)
    inventory_label = _label(root, "Bag: Rice 3 | Seed 8 | Water 2", Vector2(18,118), Vector2(420,28), 15)
    _button(root, "Boy", Vector2(18,158), "boy")
    _button(root, "Girl", Vector2(100,140), "girl")
    _button(root, "Interact", Vector2(-160,-220), "interact", true)
    _button(root, "Farm", Vector2(-160,-165), "farm", true)
    _button(root, "Sell Rice", Vector2(-260,-165), "sell", true)
    _button(root, "Weather", Vector2(-160,-110), "weather", true)
    _button(root, "Save", Vector2(-160,-55), "save", true)
    _button(root, "Load", Vector2(-260,-55), "load", true)
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
        inventory_label.text = "Bag: Rice " + str(inventory.get("Rice",0)) + " | Seed " + str(inventory.get("Seed",0)) + " | Water " + str(inventory.get("Water",0))

func _input(event):
    if event is InputEventScreenTouch:
        if event.pressed:
            last_touch = event.position
            dragging_move = event.position.x < get_viewport().size.x * 0.38
            dragging_look = not dragging_move and event.position.y < get_viewport().size.y * 0.78
        else:
            dragging_move = false
            dragging_look = false
            move_vector = Vector2.ZERO
            _send_move()
    elif event is InputEventScreenDrag:
        var delta = event.position - last_touch
        if dragging_move:
            move_vector = Vector2(clamp(delta.x/70.0,-1,1), clamp(delta.y/70.0,-1,1))
            _send_move()
        elif dragging_look:
            var p = get_parent().get_node_or_null("Player")
            if p: p.add_look(delta)
        last_touch = event.position

func _send_move():
    var p = get_parent().get_node_or_null("Player")
    if p: p.set_move(move_vector)
