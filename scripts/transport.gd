extends Spatial

var vehicles = []

func _ready():
    _make_buffalo(Vector3(-8,0,18))
    _make_cart(Vector3(14,0,5))

func _material(color):
    var m = SpatialMaterial.new()
    m.albedo_color = color
    m.roughness = 0.95
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

func _make_buffalo(pos):
    var root = Spatial.new()
    root.name = "RideableWaterBuffalo"
    root.translation = pos
    root.set_meta("ride_type", "buffalo")
    root.set_meta("ride_speed", 4.2)
    add_child(root)
    _mesh(root, SphereMesh.new(), Vector3(0,0.95,0), Vector3(1.25,0.8,1.8), Color(0.16,0.17,0.15))
    _mesh(root, SphereMesh.new(), Vector3(0,1.05,-1.45), Vector3(0.62,0.62,0.62), Color(0.18,0.18,0.16))
    _mesh(root, SphereMesh.new(), Vector3(-0.53,1.48,-1.75), Vector3(0.48,0.20,0.20), Color(0.82,0.78,0.62), Vector3(0,0,-24))
    _mesh(root, SphereMesh.new(), Vector3(0.53,1.48,-1.75), Vector3(0.48,0.20,0.20), Color(0.82,0.78,0.62), Vector3(0,0,24))
    for side in [-1,1]:
        for z in [-0.9,0.9]:
            _mesh(root, CylinderMesh.new(), Vector3(side*0.72,0.42,z), Vector3(0.22,0.9,0.22), Color(0.13,0.13,0.12))
    _mesh(root, CubeMesh.new(), Vector3(0,1.62,0.05), Vector3(0.75,0.12,0.85), Color(0.48,0.25,0.10))
    vehicles.append(root)

func _make_cart(pos):
    var root = Spatial.new()
    root.name = "MyanmarBullockCart"
    root.translation = pos
    root.set_meta("ride_type", "bullock_cart")
    root.set_meta("ride_speed", 5.0)
    add_child(root)
    # Traditional wooden cart platform, side rails and canopy
    _mesh(root, CubeMesh.new(), Vector3(0,1.05,0.15), Vector3(2.2,0.22,2.7), Color(0.38,0.20,0.09))
    for side in [-1,1]:
        _mesh(root, CubeMesh.new(), Vector3(side*1.0,1.55,0.15), Vector3(0.12,0.9,2.5), Color(0.48,0.27,0.12))
        _mesh(root, CylinderMesh.new(), Vector3(side*1.15,0.85,0.2), Vector3(0.16,1.55,1.55), Color(0.12,0.09,0.06), Vector3(0,0,90))
    _mesh(root, CubeMesh.new(), Vector3(0,2.45,0.15), Vector3(2.5,0.12,2.8), Color(0.66,0.40,0.18))
    # Two yoked oxen at the front of the cart
    for side in [-1,1]:
        var ox = Spatial.new()
        ox.translation = Vector3(side*0.58,0, -2.25)
        root.add_child(ox)
        _mesh(ox, SphereMesh.new(), Vector3(0,0.88,0), Vector3(0.62,0.68,1.0), Color(0.58,0.38,0.22))
        _mesh(ox, SphereMesh.new(), Vector3(0,1.0,-0.82), Vector3(0.38,0.40,0.38), Color(0.62,0.43,0.27))
        _mesh(ox, SphereMesh.new(), Vector3(-0.32,1.28,-1.0), Vector3(0.28,0.12,0.12), Color(0.88,0.78,0.55), Vector3(0,0,-28))
        _mesh(ox, SphereMesh.new(), Vector3(0.32,1.28,-1.0), Vector3(0.28,0.12,0.12), Color(0.88,0.78,0.55), Vector3(0,0,28))
        for leg_side in [-1,1]:
            _mesh(ox, CylinderMesh.new(), Vector3(leg_side*0.35,0.38,0.2), Vector3(0.16,0.8,0.16), Color(0.36,0.23,0.13))
    _mesh(root, CylinderMesh.new(), Vector3(0,0.85,-1.45), Vector3(0.12,0.12,2.4), Color(0.24,0.14,0.07), Vector3(90,0,0))
    vehicles.append(root)

func toggle_ride(player):
    if player.is_mounted():
        player.dismount_vehicle()
        return "ဆင်းပြီးပါပြီ။"
    var nearest = null
    var nearest_distance = 99999.0
    for vehicle in vehicles:
        var d = player.global_transform.origin.distance_to(vehicle.global_transform.origin)
        if d < nearest_distance:
            nearest_distance = d
            nearest = vehicle
    if nearest != null and nearest_distance < 7.0:
        var ride_type = str(nearest.get_meta("ride_type"))
        var offset = Vector3(0,1.0,0.15) if ride_type == "bullock_cart" else Vector3(0,1.0,0.0)
        player.mount_vehicle(nearest, offset, float(nearest.get_meta("ride_speed")))
        if ride_type == "bullock_cart":
            return "နွားလှည်းပေါ် တက်စီးပြီးပါပြီ။"
        return "ကျွဲပေါ် တက်စီးပြီးပါပြီ။"
    return "နွားလှည်း သို့မဟုတ် ကျွဲအနီးကို သွားပြီး Ride ကိုနှိပ်ပါ။"
