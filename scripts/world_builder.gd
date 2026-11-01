extends Spatial

func build_world():
    _box("Earth", Vector3(0,-0.7,0), Vector3(180,1,180), Color(0.25,0.42,0.20))
    _box("VillagePath", Vector3(0,-0.12,0), Vector3(5,0.18,85), Color(0.62,0.48,0.30))
    _box("River", Vector3(16,-0.25,0), Vector3(8,0.12,100), Color(0.12,0.48,0.68))
    _box("Bridge", Vector3(11,-0.02,7), Vector3(11,0.5,3), Color(0.40,0.23,0.12))
    for i in range(12):
        var x = -25 + (i % 4) * 13
        var z = -24 + int(i / 4) * 19
        _house(Vector3(x,0,z), i)
    for i in range(9):
        _hill(Vector3(-42 + i*11, 0, -48 - (i%3)*9), 8 + (i%4)*2)
    _farm(Vector3(-18,0,24))
    _pagoda(Vector3(28,0,-22))
    _tree_line()
    _animal(Vector3(-7,0,12), Color(0.42,0.28,0.16), "Buffalo")
    _animal(Vector3(4,0,-7), Color(0.92,0.88,0.72), "Chicken")

func _mat(color):
    var m = SpatialMaterial.new()
    m.albedo_color = color
    m.roughness = 1.0
    return m

func _box(label, pos, size, color):
    var n = MeshInstance.new()
    n.name = label
    var mesh = CubeMesh.new()
    mesh.size = size
    n.mesh = mesh
    n.translation = pos
    n.material_override = _mat(color)
    add_child(n)
    return n

func _house(pos, index):
    var wall = Color(0.78,0.65,0.46)
    _box("MyanmarHouse", pos + Vector3(0,1.1,0), Vector3(5,2.2,4), wall)
    _box("WoodenFloor", pos + Vector3(0,0.1,0), Vector3(5.5,0.25,4.5), Color(0.34,0.20,0.10))
    _box("ThatchedRoof", pos + Vector3(0,2.55,0), Vector3(6.2,0.35,5.2), Color(0.38,0.19,0.08))
    _box("Door", pos + Vector3(0,0.9,2.03), Vector3(0.9,1.8,0.12), Color(0.24,0.12,0.06))

func _hill(pos, radius):
    var n = MeshInstance.new()
    var mesh = SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 1.35
    n.mesh = mesh
    n.translation = pos + Vector3(0, radius*0.48, 0)
    n.scale = Vector3(1.7,1,1.2)
    n.material_override = _mat(Color(0.20,0.37,0.22))
    add_child(n)

func _farm(pos):
    for x in range(4):
        for z in range(5):
            _box("RicePaddy", pos + Vector3(x*2.2,0.03,z*2.2), Vector3(2,0.08,2), Color(0.34,0.50,0.20))
            _box("WaterPlot", pos + Vector3(x*2.2,0.09,z*2.2), Vector3(1.7,0.025,1.7), Color(0.30,0.55,0.57))

func _pagoda(pos):
    var base = CylinderMesh.new()
    base.top_radius = 2.1
    base.bottom_radius = 2.5
    base.height = 0.7
    _cylinder("PagodaBase", base, pos + Vector3(0,0.35,0), Color(0.82,0.68,0.32))
    var body = CylinderMesh.new()
    body.top_radius = 0.9
    body.bottom_radius = 1.5
    body.height = 3.0
    _cylinder("GoldenStupa", body, pos + Vector3(0,2.1,0), Color(0.92,0.68,0.18))
    var spire = CylinderMesh.new()
    spire.top_radius = 0.02
    spire.bottom_radius = 0.7
    spire.height = 2.8
    _cylinder("StupaSpire", spire, pos + Vector3(0,4.8,0), Color(0.98,0.78,0.25))

func _cylinder(label, mesh, pos, color):
    var n = MeshInstance.new()
    n.name = label
    n.mesh = mesh
    n.translation = pos
    n.material_override = _mat(color)
    add_child(n)

func _tree_line():
    for i in range(55):
        var x = rand_range(-65,65)
        var z = rand_range(-65,65)
        if abs(x) < 8 and abs(z) < 20: continue
        var trunk = CylinderMesh.new()
        trunk.top_radius = 0.18
        trunk.bottom_radius = 0.28
        trunk.height = 2.0
        _cylinder("TreeTrunk", trunk, Vector3(x,1,z), Color(0.28,0.16,0.08))
        var crown = SphereMesh.new()
        crown.radius = rand_range(1.0,1.8)
        crown.height = crown.radius*1.7
        var n = MeshInstance.new()
        n.mesh = crown
        n.translation = Vector3(x,3,z)
        n.material_override = _mat(Color(0.12,rand_range(0.28,0.48),0.16))
        add_child(n)

func _animal(pos, color, label):
    var n = MeshInstance.new()
    n.name = label
    var mesh = SphereMesh.new()
    mesh.radius = 0.55
    mesh.height = 0.9
    n.mesh = mesh
    n.translation = pos + Vector3(0,0.5,0)
    n.scale = Vector3(1.5,0.8,0.8)
    n.material_override = _mat(color)
    add_child(n)
