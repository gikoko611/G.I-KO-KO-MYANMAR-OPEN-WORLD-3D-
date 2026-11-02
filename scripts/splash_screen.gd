extends Spatial

var emblem
var spin_speed = 0.45

func _ready():
    var camera = Camera.new()
    camera.translation = Vector3(0,2.4,10)
    camera.current = true
    add_child(camera)
    camera.look_at(Vector3(0,1.5,0), Vector3.UP)

    var light = DirectionalLight.new()
    light.rotation_degrees = Vector3(-42,-28,0)
    light.light_energy = 1.25
    add_child(light)

    var environment_node = WorldEnvironment.new()
    var environment = Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.025,0.045,0.055)
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.30,0.42,0.38)
    environment.ambient_light_energy = 0.8
    environment_node.environment = environment
    add_child(environment_node)

    emblem = Spatial.new()
    emblem.translation = Vector3(0,1.7,0)
    add_child(emblem)
    var ring = MeshInstance.new()
    var torus = TorusMesh.new()
    torus.inner_radius = 1.55
    torus.outer_radius = 1.78
    ring.mesh = torus
    var gold = SpatialMaterial.new()
    gold.albedo_color = Color(0.95,0.65,0.16)
    gold.metallic = 0.82
    gold.roughness = 0.22
    ring.material_override = gold
    emblem.add_child(ring)

    var icon_plane = MeshInstance.new()
    var quad = QuadMesh.new()
    quad.size = Vector2(2.75,2.75)
    icon_plane.mesh = quad
    var icon_material = SpatialMaterial.new()
    icon_material.albedo_texture = load("res://icon.png")
    icon_material.flags_unshaded = true
    icon_material.params_cull_mode = SpatialMaterial.CULL_DISABLED
    icon_plane.material_override = icon_material
    icon_plane.translation = Vector3(0,0,0.06)
    emblem.add_child(icon_plane)

    var title_layer = CanvasLayer.new()
    add_child(title_layer)
    var panel = ColorRect.new()
    panel.color = Color(0.015,0.025,0.03,0.22)
    panel.anchor_left = 0.0
    panel.anchor_top = 0.0
    panel.anchor_right = 1.0
    panel.anchor_bottom = 1.0
    title_layer.add_child(panel)

    var title = Label.new()
    title.text = "G.I KO KO  |  MYANMAR OPEN WORLD"
    title.rect_position = Vector2(20,22)
    title.rect_size = Vector2(850,54)
    title.add_color_override("font_color", Color(1.0,0.82,0.38))
    title.add_color_override("font_color_shadow", Color(0,0,0))
    title.add_constant_override("shadow_offset_x", 2)
    title.add_constant_override("shadow_offset_y", 2)
    title_layer.add_child(title)

    var powered = Label.new()
    powered.text = "Powered by အိုင်ကိုကို"
    powered.anchor_left = 0.0
    powered.anchor_right = 1.0
    powered.anchor_top = 1.0
    powered.anchor_bottom = 1.0
    powered.margin_left = 0
    powered.margin_right = 0
    powered.margin_top = -64
    powered.margin_bottom = -18
    powered.align = Label.ALIGN_CENTER
    powered.add_color_override("font_color", Color(1.0,0.78,0.25))
    powered.add_color_override("font_color_shadow", Color(0,0,0))
    powered.add_constant_override("shadow_offset_x", 2)
    powered.add_constant_override("shadow_offset_y", 2)
    powered_layer_add(title_layer, powered)

    var subtitle = Label.new()
    subtitle.text = "Explore • Farm • Survive • Discover Myanmar"
    subtitle.anchor_left = 0.0
    subtitle.anchor_right = 1.0
    subtitle.anchor_top = 1.0
    subtitle.anchor_bottom = 1.0
    subtitle.margin_top = -112
    subtitle.margin_bottom = -76
    subtitle.align = Label.ALIGN_CENTER
    subtitle.add_color_override("font_color", Color(0.76,0.88,0.82))
    title_layer.add_child(subtitle)

    var timer = Timer.new()
    timer.wait_time = 3.6
    timer.one_shot = true
    add_child(timer)
    timer.connect("timeout", self, "_start_game")
    timer.start()

func powered_layer_add(layer, node):
    layer.add_child(node)

func _process(delta):
    if emblem:
        emblem.rotation.y += delta * spin_speed
        emblem.rotation.z = sin(OS.get_ticks_msec() / 1000.0) * 0.035

func _start_game():
    get_tree().change_scene("res://scenes/main.tscn")
