extends Spatial
# Lightweight companion follower for Godot 3.5.2 / GLES2.
# Uses simple low-poly meshes and no navigation plugins.
var target = null
var follow_enabled = true
var work_mode = false
var bond = 0
var companion_level = 1
var follow_distance = 3.2
var follow_speed = 4.2
var companion_body
var companion_head
var status_name = "မောင်လှ"

func _ready():
    _build_character()

func set_target(node):
    target = node

func _build_character():
    var body_mesh = CapsuleMesh.new()
    body_mesh.radius = 0.38
    body_mesh.mid_height = 0.9
    companion_body = MeshInstance.new()
    companion_body.mesh = body_mesh
    var body_mat = SpatialMaterial.new()
    body_mat.albedo_color = Color(0.12, 0.42, 0.30)
    companion_body.material_override = body_mat
    companion_body.translation = Vector3(0, 0.9, 0)
    add_child(companion_body)

    var head_mesh = SphereMesh.new()
    head_mesh.radius = 0.25
    head_mesh.height = 0.5
    companion_head = MeshInstance.new()
    companion_head.mesh = head_mesh
    var head_mat = SpatialMaterial.new()
    head_mat.albedo_color = Color(0.72, 0.48, 0.32)
    companion_head.material_override = head_mat
    companion_head.translation = Vector3(0, 1.58, 0)
    add_child(companion_head)

func _process(delta):
    if not follow_enabled or not is_instance_valid(target):
        return
    var target_pos = target.global_transform.origin
    var behind = -target.global_transform.basis.z * follow_distance
    var desired = target_pos + behind
    desired.y = 0.1
    var current = global_transform.origin
    var distance = Vector2(current.x - desired.x, current.z - desired.z).length()
    if distance > 24.0:
        global_transform.origin = desired
    elif distance > 1.8:
        var next_pos = current.linear_interpolate(desired, min(1.0, delta * follow_speed))
        next_pos.y = 0.1
        global_transform.origin = next_pos
    if distance > 0.2:
        look_at(Vector3(target_pos.x, global_transform.origin.y, target_pos.z), Vector3.UP)

func cycle_mode():
    if not follow_enabled:
        follow_enabled = true
        work_mode = false
        return "FOLLOW"
    if not work_mode:
        work_mode = true
        return "WORK"
    follow_enabled = false
    work_mode = false
    return "REST"

func is_near_player():
    return is_instance_valid(target) and global_transform.origin.distance_to(target.global_transform.origin) <= 8.0

func help_work():
    if not is_near_player() or not work_mode:
        return 0
    bond = min(100, bond + 1)
    companion_level = max(1, 1 + int(bond / 10))
    return 1

func help_hunt_bonus():
    if not is_near_player() or not follow_enabled:
        return 0.0
    bond = min(100, bond + 2)
    companion_level = max(1, 1 + int(bond / 10))
    return min(0.18, 0.04 + float(companion_level - 1) * 0.015)

func get_status():
    var mode = "WORK" if work_mode else ("FOLLOW" if follow_enabled else "REST")
    return status_name + " Lv." + str(companion_level) + " | Bond " + str(bond) + "/100 | " + mode

func save_state():
    return {"follow_enabled":follow_enabled,"work_mode":work_mode,"bond":bond,"companion_level":companion_level}

func load_state(data):
    if typeof(data) != TYPE_DICTIONARY:
        return
    follow_enabled = bool(data.get("follow_enabled",true))
    work_mode = bool(data.get("work_mode",false))
    bond = clamp(int(data.get("bond",0)),0,100)
    companion_level = clamp(int(data.get("companion_level",1)),1,11)
