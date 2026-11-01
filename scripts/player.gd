extends KinematicBody

var speed = 6.0
var gravity = 24.0
var velocity = Vector3.ZERO
var gender = "Boy"
var move_input = Vector2.ZERO
var look_delta = Vector2.ZERO
var yaw = 0.0
var pitch = -12.0
var camera_pivot
var camera
var body_root
var mounted_vehicle = null
var mounted_offset = Vector3.ZERO
var mounted_speed = 4.0
var sprint_enabled = false
var first_person = false
var animation_clock = 0.0

func _ready():
    _build_character()
    camera_pivot = Spatial.new()
    camera_pivot.translation = Vector3(0, 1.45, 0)
    add_child(camera_pivot)
    camera = Camera.new()
    camera.translation = Vector3(0, 1.1, 4.2)
    camera.rotation_degrees.x = -10
    camera.current = true
    camera_pivot.add_child(camera)
    var shape = CapsuleShape.new()
    shape.radius = 0.36
    shape.height = 1.65
    var collision = CollisionShape.new()
    collision.shape = shape
    collision.translation.y = 0.85
    add_child(collision)

func _process(delta):
    animation_clock += delta
    if body_root and is_instance_valid(body_root):
        var moving = move_input.length() > 0.12 or (mounted_vehicle != null and is_instance_valid(mounted_vehicle))
        var sway = sin(animation_clock * (10.0 if moving else 2.2))
        body_root.rotation.z = lerp(body_root.rotation.z, sway * (0.055 if moving else 0.018), min(1.0, delta * 8.0))
        body_root.rotation.x = lerp(body_root.rotation.x, (0.025 if moving else 0.0) + sin(animation_clock * 2.0) * 0.008, min(1.0, delta * 5.0))

func _physics_process(delta):
    var input = move_input
    if Input.is_action_pressed("ui_up"): input.y -= 1
    if Input.is_action_pressed("ui_down"): input.y += 1
    if Input.is_action_pressed("ui_left"): input.x -= 1
    if Input.is_action_pressed("ui_right"): input.x += 1
    input = input.normalized()
    var direction = Vector3(input.x, 0, input.y).rotated(Vector3.UP, yaw)
    if mounted_vehicle != null and is_instance_valid(mounted_vehicle):
        mounted_vehicle.translation += direction * mounted_speed * delta
        global_transform.origin = mounted_vehicle.global_transform.xform(mounted_offset)
        velocity = Vector3.ZERO
        yaw -= look_delta.x * 0.004
        pitch = clamp(pitch - look_delta.y * 0.12, -35, 18)
        rotation.y = yaw
        camera_pivot.rotation_degrees.x = pitch
        look_delta = Vector2.ZERO
        return
    var current_speed = speed * (1.65 if sprint_enabled else 1.0)
    velocity.x = direction.x * current_speed
    velocity.z = direction.z * current_speed
    velocity.y -= gravity * delta
    if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
        velocity.y = 8.0
    velocity = move_and_slide(velocity, Vector3.UP)
    yaw -= look_delta.x * 0.004
    pitch = clamp(pitch - look_delta.y * 0.12, -35, 18)
    rotation.y = yaw
    camera_pivot.rotation_degrees.x = pitch
    look_delta = Vector2.ZERO

func set_move(value):
    move_input = value

func jump_now():
    if not is_mounted() and is_on_floor():
        velocity.y = 8.0

func toggle_sprint():
    sprint_enabled = not sprint_enabled
    return sprint_enabled

func toggle_camera_mode():
    first_person = not first_person
    if first_person:
        camera.translation = Vector3(0,0.12,0.02)
        camera.rotation_degrees.x = 0
        body_root.visible = false
    else:
        camera.translation = Vector3(0,1.1,4.2)
        camera.rotation_degrees.x = -10
        body_root.visible = true
    return first_person

func mount_vehicle(vehicle, offset, vehicle_speed):
    mounted_vehicle = vehicle
    mounted_offset = offset
    mounted_speed = vehicle_speed
    velocity = Vector3.ZERO
    global_transform.origin = vehicle.global_transform.xform(mounted_offset)

func dismount_vehicle():
    if mounted_vehicle != null and is_instance_valid(mounted_vehicle):
        global_transform.origin = mounted_vehicle.global_transform.origin + Vector3(1.8,0.2,0)
    mounted_vehicle = null
    move_input = Vector2.ZERO

func is_mounted():
    return mounted_vehicle != null and is_instance_valid(mounted_vehicle)

func add_look(value):
    look_delta += value

func set_gender(value):
    gender = value
    if body_root:
        body_root.queue_free()
    _build_character()

func _build_character():
    body_root = Spatial.new()
    body_root.name = "MyanmarOutfit"
    body_root.visible = not first_person
    add_child(body_root)
    var skin = Color(0.72, 0.48, 0.32)
    var shirt_color = Color(0.12, 0.38, 0.30) if gender == "Boy" else Color(0.68, 0.18, 0.28)
    var cloth_color = Color(0.18, 0.22, 0.42) if gender == "Boy" else Color(0.62, 0.38, 0.12)
    _part(body_root, CapsuleMesh.new(), Vector3(0, 1.12, 0), Vector3(0.55, 0.65, 0.34), shirt_color)
    _part(body_root, SphereMesh.new(), Vector3(0, 1.92, 0), Vector3(0.42, 0.44, 0.42), skin)
    var cloth = CylinderMesh.new()
    cloth.top_radius = 0.28
    cloth.bottom_radius = 0.43
    cloth.height = 0.9
    _part(body_root, cloth, Vector3(0, 0.52, 0), Vector3(1, 1, 1), cloth_color)
    _part(body_root, CylinderMesh.new(), Vector3(-0.17, 0.12, 0), Vector3(0.18, 0.38, 0.18), Color(0.25,0.2,0.17))
    _part(body_root, CylinderMesh.new(), Vector3(0.17, 0.12, 0), Vector3(0.18, 0.38, 0.18), Color(0.25,0.2,0.17))
    _part(body_root, SphereMesh.new(), Vector3(-0.38, 1.12, 0), Vector3(0.16, 0.48, 0.16), skin)
    _part(body_root, SphereMesh.new(), Vector3(0.38, 1.12, 0), Vector3(0.16, 0.48, 0.16), skin)
    if gender == "Girl":
        _part(body_root, SphereMesh.new(), Vector3(0, 2.17, -0.12), Vector3(0.22, 0.18, 0.22), Color(0.08,0.06,0.05))
        var htamein_trim = CylinderMesh.new()
        htamein_trim.top_radius = 0.40
        htamein_trim.bottom_radius = 0.44
        htamein_trim.height = 0.09
        _part(body_root, htamein_trim, Vector3(0, 0.82, 0), Vector3(1,1,1), Color(0.92,0.72,0.28))
    else:
        var longyi_band = CylinderMesh.new()
        longyi_band.top_radius = 0.30
        longyi_band.bottom_radius = 0.34
        longyi_band.height = 0.10
        _part(body_root, longyi_band, Vector3(0, 0.88, 0), Vector3(1,1,1), Color(0.76,0.68,0.42))
        _part(body_root, SphereMesh.new(), Vector3(0, 2.12, -0.08), Vector3(0.30,0.12,0.30), Color(0.10,0.08,0.06))

func _part(parent, mesh, pos, scale, color):
    var node = MeshInstance.new()
    node.mesh = mesh
    node.translation = pos
    node.scale = scale
    var mat = SpatialMaterial.new()
    mat.albedo_color = color
    mat.roughness = 0.92
    node.material_override = mat
    parent.add_child(node)
