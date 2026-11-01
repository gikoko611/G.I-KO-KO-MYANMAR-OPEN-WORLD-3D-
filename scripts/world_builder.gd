extends Spatial

func build_world():
    _box("Earth", Vector3(0,-0.7,0), Vector3(260,1,260), Color(0.25,0.42,0.20))
    _box("VillagePath", Vector3(0,-0.12,0), Vector3(5,0.18,135), Color(0.62,0.48,0.30))
    _box("River", Vector3(16,-0.25,0), Vector3(8,0.12,150), Color(0.12,0.48,0.68))
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
    _villager(Vector3(-5,0,-13), Color(0.10,0.34,0.28), "Village Elder")
    _villager(Vector3(8,0,18), Color(0.60,0.16,0.22), "Market Seller")
    _market_stall(Vector3(10,0,16))
    _motorbike(Vector3(-10,0,3))
    _monastery(Vector3(-34,0,-30))
    _lotus_pond(Vector3(42,0,35))
    _bamboo_grove(Vector3(-58,0,18))
    _stilt_house(Vector3(38,0,-38))
    _village_well(Vector3(3,0,28))
    _animal(Vector3(6,0,28), Color(0.18,0.12,0.09), "VillageDog")
    _animal(Vector3(12,0,-12), Color(0.72,0.70,0.62), "VillageGoat")
    _animal(Vector3(-17,0,-8), Color(0.90,0.88,0.82), "VillageDuck")
    _animal(Vector3(22,0,25), Color(0.62,0.38,0.32), "VillagePig")

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
    if label == "Earth" or label == "VillagePath" or label == "Bridge":
        var body = StaticBody.new()
        body.translation = pos
        var collision = CollisionShape.new()
        var shape = BoxShape.new()
        shape.extents = size * 0.5
        collision.shape = shape
        body.add_child(collision)
        add_child(body)
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

func _villager(pos, shirt_color, label):
    var skin = Color(0.68,0.43,0.29)
    _box(label + "Body", pos + Vector3(0,1.05,0), Vector3(0.55,0.85,0.32), shirt_color)
    var head = MeshInstance.new()
    head.mesh = SphereMesh.new()
    head.translation = pos + Vector3(0,1.85,0)
    head.scale = Vector3(0.28,0.32,0.28)
    head.material_override = _mat(skin)
    add_child(head)
    _box(label + "Longyi", pos + Vector3(0,0.48,0), Vector3(0.58,0.75,0.38), Color(0.22,0.24,0.38))

func _market_stall(pos):
    _box("MarketTable", pos + Vector3(0,0.8,0), Vector3(3,0.18,1.2), Color(0.35,0.20,0.10))
    _box("MarketAwning", pos + Vector3(0,2.1,0), Vector3(3.5,0.18,1.8), Color(0.65,0.18,0.16))
    for i in range(5):
        _box("MarketPost", pos + Vector3(-1.5 + i*0.75,1.45,-0.7), Vector3(0.08,1.3,0.08), Color(0.25,0.14,0.08))

func _motorbike(pos):
    var wheel = CylinderMesh.new()
    wheel.top_radius = 0.42
    wheel.bottom_radius = 0.42
    wheel.height = 0.16
    _cylinder("MotorbikeFrontWheel", wheel, pos + Vector3(0,0.42,-0.9), Color(0.06,0.06,0.06))
    _cylinder("MotorbikeRearWheel", wheel, pos + Vector3(0,0.42,0.9), Color(0.06,0.06,0.06))
    _box("MotorbikeFrame", pos + Vector3(0,0.85,0), Vector3(0.35,0.28,1.5), Color(0.72,0.08,0.06))
    _box("MotorbikeSeat", pos + Vector3(0,1.1,0.2), Vector3(0.5,0.12,0.65), Color(0.08,0.08,0.08))

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

func _monastery(pos):
    _box("MonasteryWoodHall", pos + Vector3(0,1.5,0), Vector3(12,3,9), Color(0.48,0.27,0.12))
    _box("MonasteryVeranda", pos + Vector3(0,0.55,5), Vector3(14,0.25,2), Color(0.34,0.19,0.10))
    for i in range(5):
        _box("MonasteryPillar", pos + Vector3(-5+i*2.5,1.5,4.1), Vector3(0.22,3,0.22), Color(0.24,0.14,0.08))
    _box("MonasteryRoof", pos + Vector3(0,3.35,0), Vector3(13,0.35,10), Color(0.30,0.16,0.10))
    _box("MonasteryGoldTrim", pos + Vector3(0,3.58,0), Vector3(12,0.08,9), Color(0.82,0.62,0.22))

func _lotus_pond(pos):
    _box("LotusPondWater", pos + Vector3(0,0.02,0), Vector3(16,0.08,12), Color(0.12,0.43,0.48))
    for i in range(12):
        var x = rand_range(-6,6)
        var z = rand_range(-4,4)
        var leaf = CylinderMesh.new()
        leaf.top_radius = 0.42
        leaf.bottom_radius = 0.42
        leaf.height = 0.05
        _cylinder("LotusLeaf", leaf, pos + Vector3(x,0.12,z), Color(0.12,0.42,0.20))
        var flower = SphereMesh.new()
        var n = MeshInstance.new()
        n.mesh = flower
        n.scale = Vector3(0.18,0.12,0.18)
        n.translation = pos + Vector3(x,0.28,z)
        n.material_override = _mat(Color(0.92,0.58,0.70))
        add_child(n)

func _bamboo_grove(pos):
    for i in range(24):
        var x = rand_range(-9,9)
        var z = rand_range(-9,9)
        var stalk = CylinderMesh.new()
        stalk.top_radius = 0.08
        stalk.bottom_radius = 0.12
        stalk.height = rand_range(5,8)
        _cylinder("BambooStalk", stalk, pos + Vector3(x,stalk.height*0.5,z), Color(0.30,0.48,0.18))
        for h in range(2,6,2):
            _box("BambooNode", pos + Vector3(x,float(h),z), Vector3(0.22,0.08,0.22), Color(0.48,0.62,0.26))

func _stilt_house(pos):
    for x in [-2.2,2.2]:
        for z in [-2.0,2.0]:
            _box("StiltHousePost", pos + Vector3(x,1.3,z), Vector3(0.22,2.6,0.22), Color(0.30,0.17,0.08))
    _box("StiltHouseFloor", pos + Vector3(0,2.65,0), Vector3(5.5,0.25,5), Color(0.40,0.25,0.13))
    _box("StiltHouseWall", pos + Vector3(0,3.8,0), Vector3(4.8,2.1,4.2), Color(0.72,0.55,0.34))
    _box("StiltHouseRoof", pos + Vector3(0,5.0,0), Vector3(6,0.35,5.4), Color(0.36,0.20,0.10))
    _box("StiltHouseStairs", pos + Vector3(0,1.35,3.0), Vector3(1.2,2.5,0.8), Color(0.36,0.22,0.12))

func _village_well(pos):
    var ring = CylinderMesh.new()
    ring.top_radius = 1.0
    ring.bottom_radius = 1.0
    ring.height = 0.8
    _cylinder("VillageWell", ring, pos + Vector3(0,0.4,0), Color(0.48,0.46,0.40))
    var water = CylinderMesh.new()
    water.top_radius = 0.72
    water.bottom_radius = 0.72
    water.height = 0.05
    _cylinder("WellWater", water, pos + Vector3(0,0.78,0), Color(0.12,0.42,0.58))
    _box("WellBeam", pos + Vector3(0,2.1,0), Vector3(2.4,0.12,0.12), Color(0.28,0.16,0.08))
