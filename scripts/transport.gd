extends Spatial

var vehicles = []

func _ready():
    _make_buffalo(Vector3(-8,0,18))
    _make_cart(Vector3(14,0,5))
    _make_horse(Vector3(-24,0,8))
    _make_elephant(Vector3(34,0,12))
    _make_boat(Vector3(16,0,-18))

func _material(color):
    var m = SpatialMaterial.new()
    m.albedo_color = color
    m.roughness = 0.94
    return m

func _mesh(parent, mesh, pos, scale, color, rotation=Vector3.ZERO):
    var n = MeshInstance.new()
    n.mesh = mesh
    n.translation = pos
    n.scale = scale
    n.rotation_degrees = rotation
    n.material_override = _material(color)
    parent.add_child(n)
    return n

func _new_ride(name, kind, pos, speed):
    var root = Spatial.new()
    root.name = name
    root.translation = pos
    root.set_meta("ride_type", kind)
    root.set_meta("ride_speed", speed)
    add_child(root)
    vehicles.append(root)
    return root

func _make_buffalo(pos):
    var root = _new_ride("RideableWaterBuffalo", "buffalo", pos, 4.2)
    _mesh(root, SphereMesh.new(), Vector3(0,0.95,0), Vector3(1.25,0.8,1.8), Color(0.16,0.17,0.15))
    _mesh(root, SphereMesh.new(), Vector3(0,1.05,-1.45), Vector3(0.62,0.62,0.62), Color(0.18,0.18,0.16))
    _mesh(root, SphereMesh.new(), Vector3(-0.53,1.48,-1.75), Vector3(0.48,0.20,0.20), Color(0.82,0.78,0.62), Vector3(0,0,-24))
    _mesh(root, SphereMesh.new(), Vector3(0.53,1.48,-1.75), Vector3(0.48,0.20,0.20), Color(0.82,0.78,0.62), Vector3(0,0,24))
    for side in [-1,1]:
        for z in [-0.9,0.9]:
            _mesh(root, CylinderMesh.new(), Vector3(side*0.72,0.42,z), Vector3(0.22,0.9,0.22), Color(0.13,0.13,0.12))
    _mesh(root, CubeMesh.new(), Vector3(0,1.62,0.05), Vector3(0.75,0.12,0.85), Color(0.48,0.25,0.10))

func _make_cart(pos):
    var root = _new_ride("MyanmarBullockCart", "bullock_cart", pos, 5.0)
    _mesh(root, CubeMesh.new(), Vector3(0,1.05,0.15), Vector3(2.2,0.22,2.7), Color(0.38,0.20,0.09))
    for side in [-1,1]:
        _mesh(root, CubeMesh.new(), Vector3(side*1.0,1.55,0.15), Vector3(0.12,0.9,2.5), Color(0.48,0.27,0.12))
        _mesh(root, CylinderMesh.new(), Vector3(side*1.15,0.85,0.2), Vector3(0.16,1.55,1.55), Color(0.12,0.09,0.06), Vector3(0,0,90))
    _mesh(root, CubeMesh.new(), Vector3(0,2.45,0.15), Vector3(2.5,0.12,2.8), Color(0.66,0.40,0.18))
    for side in [-1,1]:
        var ox = Spatial.new()
        ox.translation = Vector3(side*0.58,0,-2.25)
        root.add_child(ox)
        _mesh(ox, SphereMesh.new(), Vector3(0,0.88,0), Vector3(0.62,0.68,1.0), Color(0.58,0.38,0.22))
        _mesh(ox, SphereMesh.new(), Vector3(0,1.0,-0.82), Vector3(0.38,0.40,0.38), Color(0.62,0.43,0.27))
        _mesh(ox, SphereMesh.new(), Vector3(-0.32,1.28,-1.0), Vector3(0.28,0.12,0.12), Color(0.88,0.78,0.55), Vector3(0,0,-28))
        _mesh(ox, SphereMesh.new(), Vector3(0.32,1.28,-1.0), Vector3(0.28,0.12,0.12), Color(0.88,0.78,0.55), Vector3(0,0,28))
        for leg_side in [-1,1]:
            _mesh(ox, CylinderMesh.new(), Vector3(leg_side*0.35,0.38,0.2), Vector3(0.16,0.8,0.16), Color(0.36,0.23,0.13))
    _mesh(root, CylinderMesh.new(), Vector3(0,0.85,-1.45), Vector3(0.12,0.12,2.4), Color(0.24,0.14,0.07), Vector3(90,0,0))

func _make_horse(pos):
    var root = _new_ride("MyanmarHorse", "horse", pos, 7.0)
    var brown = Color(0.43,0.22,0.10)
    _mesh(root, SphereMesh.new(), Vector3(0,1.15,0), Vector3(0.72,0.75,1.25), brown)
    _mesh(root, SphereMesh.new(), Vector3(0,1.75,-0.92), Vector3(0.38,0.72,0.38), brown, Vector3(-18,0,0))
    _mesh(root, SphereMesh.new(), Vector3(0,2.2,-1.22), Vector3(0.42,0.42,0.48), brown)
    _mesh(root, SphereMesh.new(), Vector3(0,1.82,0.1), Vector3(0.42,0.7,0.20), Color(0.12,0.07,0.05))
    for x in [-0.42,0.42]:
        for z in [-0.75,0.75]:
            _mesh(root, CylinderMesh.new(), Vector3(x,0.58,z), Vector3(0.13,1.05,0.13), brown)
    _mesh(root, CylinderMesh.new(), Vector3(0,0.18,1.25), Vector3(0.08,0.6,0.08), brown, Vector3(0,0,-20))

func _make_elephant(pos):
    var root = _new_ride("MyanmarElephant", "elephant", pos, 3.5)
    var grey = Color(0.42,0.44,0.43)
    _mesh(root, SphereMesh.new(), Vector3(0,1.45,0), Vector3(1.35,1.2,1.75), grey)
    _mesh(root, SphereMesh.new(), Vector3(0,1.72,-1.42), Vector3(0.85,0.85,0.8), grey)
    _mesh(root, SphereMesh.new(), Vector3(-0.76,1.72,-1.35), Vector3(0.45,0.65,0.18), Color(0.52,0.52,0.50))
    _mesh(root, SphereMesh.new(), Vector3(0.76,1.72,-1.35), Vector3(0.45,0.65,0.18), Color(0.52,0.52,0.50))
    _mesh(root, CylinderMesh.new(), Vector3(0,0.9,-2.0), Vector3(0.22,1.25,0.22), grey, Vector3(-18,0,0))
    for x in [-0.82,0.82]:
        for z in [-0.95,0.95]:
            _mesh(root, CylinderMesh.new(), Vector3(x,0.65,z), Vector3(0.34,1.25,0.34), grey)
    _mesh(root, CubeMesh.new(), Vector3(0,2.25,0.05), Vector3(1.0,0.16,1.1), Color(0.55,0.18,0.12))

func _make_boat(pos):
    var root = _new_ride("MyanmarRiverBoat", "boat", pos, 6.0)
    _mesh(root, CubeMesh.new(), Vector3(0,0.45,0), Vector3(1.65,0.35,4.8), Color(0.36,0.18,0.08), Vector3(0,0,0))
    _mesh(root, CubeMesh.new(), Vector3(-0.78,0.72,0), Vector3(0.12,0.48,4.6), Color(0.52,0.29,0.12))
    _mesh(root, CubeMesh.new(), Vector3(0.78,0.72,0), Vector3(0.12,0.48,4.6), Color(0.52,0.29,0.12))
    _mesh(root, CylinderMesh.new(), Vector3(0,1.45,0), Vector3(0.07,1.6,0.07), Color(0.30,0.19,0.10))
    _mesh(root, CubeMesh.new(), Vector3(0,1.75,-0.15), Vector3(1.5,0.85,0.08), Color(0.82,0.66,0.40))

func toggle_ride(player):
    if player.is_mounted():
        player.dismount_vehicle()
        return "ယာဉ်ပေါ်မှ ဆင်းပြီးပါပြီ။"
    var nearest = null
    var nearest_distance = 99999.0
    for vehicle in vehicles:
        var d = player.global_transform.origin.distance_to(vehicle.global_transform.origin)
        if d < nearest_distance:
            nearest_distance = d
            nearest = vehicle
    if nearest != null and nearest_distance < 8.0:
        var ride_type = str(nearest.get_meta("ride_type"))
        var offset = Vector3(0,1.25,0.15)
        if ride_type == "boat":
            offset = Vector3(0,1.3,0)
        elif ride_type == "elephant":
            offset = Vector3(0,2.5,0.0)
        elif ride_type == "horse":
            offset = Vector3(0,1.5,0.0)
        player.mount_vehicle(nearest, offset, float(nearest.get_meta("ride_speed")))
        var names = {"buffalo":"ကျွဲ", "bullock_cart":"နွားလှည်း", "horse":"မြင်း", "elephant":"ဆင်", "boat":"လှေ"}
        return str(names.get(ride_type,"ယာဉ်")) + " စီးပြီးပါပြီ။"
    return "ကျွဲ၊ နွားလှည်း၊ မြင်း၊ ဆင် သို့မဟုတ် လှေအနီးကို သွားပြီး Ride ကိုနှိပ်ပါ။"
