extends Spatial

var wandering_animals = []
var animated_npcs = []
var animal_animation_clock = 0.0

func _process(delta):
    animal_animation_clock += delta
    for npc in animated_npcs:
        if is_instance_valid(npc):
            var phase = float(npc.get_meta("idle_phase", 0.0)) + delta
            npc.set_meta("idle_phase", phase)
            npc.rotation.y = sin(phase * 0.55) * 0.035
            npc.translation.y = sin(phase * 1.8) * 0.025
    for animal in wandering_animals:
        if not is_instance_valid(animal):
            continue
        var timer = float(animal.get_meta("wander_timer", 0.0)) - delta
        var direction = animal.get_meta("wander_direction", Vector3.ZERO)
        if timer <= 0.0:
            var angle = rand_range(-PI, PI)
            direction = Vector3(cos(angle), 0, sin(angle))
            timer = rand_range(1.5, 4.0)
            animal.set_meta("wander_direction", direction)
        animal.set_meta("wander_timer", timer)
        var next_position = animal.translation + direction * delta * float(animal.get_meta("wander_speed", 0.7))
        next_position.x = clamp(next_position.x, -68.0, 68.0)
        next_position.z = clamp(next_position.z, -68.0, 68.0)
        animal.translation = next_position
        if direction.length() > 0.1:
            animal.rotation.y = atan2(direction.x, direction.z)
        var base_y = float(animal.get_meta("base_y", 0.5))
        var moving = direction.length() > 0.1 and timer > 0.0
        animal.translation.y = base_y + abs(sin(animal_animation_clock * 5.0 + float(animal.get_meta("anim_phase", 0.0)))) * (0.045 if moving else 0.012)
        var gait_phase = animal_animation_clock * (7.0 if moving else 2.0) + float(animal.get_meta("anim_phase", 0.0))
        for part in animal.get_children():
            if part is MeshInstance and bool(part.get_meta("is_animal_leg", false)):
                part.rotation.x = sin(gait_phase + float(part.get_meta("leg_phase", 0.0))) * (0.28 if moving else 0.035)
        animal.rotation.z = sin(animal_animation_clock * 3.0 + float(animal.get_meta("anim_phase", 0.0))) * 0.025

func build_world():
    _box("Earth", Vector3(0,-0.7,0), Vector3(260,1,260), Color(0.25,0.42,0.20))
    _box("VillagePath", Vector3(0,-0.12,0), Vector3(5,0.18,135), Color(0.62,0.48,0.30))
    _box("River", Vector3(16,-0.25,0), Vector3(8,0.12,150), Color(0.12,0.48,0.68))
    _box("RiverBankLeft", Vector3(11.7,-0.12,0), Vector3(0.65,0.18,150), Color(0.42,0.38,0.22))
    _box("RiverBankRight", Vector3(20.3,-0.12,0), Vector3(0.65,0.18,150), Color(0.42,0.38,0.22))
    _river_rocks()
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
    var is_water = color.b > color.r and color.b > color.g * 1.08
    var is_gold = color.r > 0.76 and color.g > 0.42 and color.b < 0.48
    m.roughness = 0.28 if is_water else (0.48 if is_gold else 0.88)
    m.metallic = 0.16 if is_water else (0.42 if is_gold else 0.0)
    m.specular = 0.82 if is_water else 0.58
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
    if label == "Earth" or label == "VillagePath" or label == "Bridge" or label == "MyanmarHouse" or label == "MonasteryWoodHall" or label == "StiltHouseWall" or label == "MarketTable":
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
    _box("RoofFrontTrim", pos + Vector3(0,2.38,2.52), Vector3(6.25,0.16,0.14), Color(0.24,0.12,0.06))
    _box("RoofBackTrim", pos + Vector3(0,2.38,-2.52), Vector3(6.25,0.16,0.14), Color(0.24,0.12,0.06))
    _box("Door", pos + Vector3(0,0.9,2.03), Vector3(0.9,1.8,0.12), Color(0.24,0.12,0.06))
    _box("WindowLeft", pos + Vector3(-1.55,1.35,2.04), Vector3(0.72,0.58,0.10), Color(0.18,0.34,0.38))
    _box("WindowRight", pos + Vector3(1.55,1.35,2.04), Vector3(0.72,0.58,0.10), Color(0.18,0.34,0.38))

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
    var ridge = MeshInstance.new()
    var ridge_mesh = SphereMesh.new()
    ridge_mesh.radius = radius * 0.72
    ridge_mesh.height = radius * 0.92
    ridge.mesh = ridge_mesh
    ridge.translation = pos + Vector3(radius * 0.62, radius * 0.52, -radius * 0.16)
    ridge.scale = Vector3(1.4,0.85,1.0)
    ridge.material_override = _mat(Color(0.25,0.43,0.26))
    add_child(ridge)

func _river_rocks():
    for i in range(12):
        var side = -1.0 if i % 2 == 0 else 1.0
        var z = -62.0 + i * 10.5 + rand_range(-2.0,2.0)
        var rock = MeshInstance.new()
        var rock_mesh = SphereMesh.new()
        rock_mesh.radius = rand_range(0.28,0.58)
        rock_mesh.height = rock_mesh.radius * 0.9
        rock.mesh = rock_mesh
        rock.translation = Vector3(16.0 + side * rand_range(4.6,5.5),0.05,z)
        rock.scale = Vector3(1.35,0.7,0.9)
        rock.material_override = _mat(Color(0.34,0.37,0.34))
        add_child(rock)

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
    var ring_mesh = CylinderMesh.new()
    ring_mesh.top_radius = 0.78
    ring_mesh.bottom_radius = 0.92
    ring_mesh.height = 0.16
    _cylinder("StupaGoldBand", ring_mesh, pos + Vector3(0,3.35,0), Color(1.0,0.82,0.32))
    var finial = SphereMesh.new()
    finial.radius = 0.22
    finial.height = 0.44
    var finial_node = MeshInstance.new()
    finial_node.mesh = finial
    finial_node.translation = pos + Vector3(0,6.22,0)
    finial_node.material_override = _mat(Color(1.0,0.84,0.38))
    add_child(finial_node)

func _cylinder(label, mesh, pos, color):
    var n = MeshInstance.new()
    n.name = label
    n.mesh = mesh
    n.translation = pos
    n.material_override = _mat(color)
    add_child(n)

func _tree_line():
    for i in range(34):
        var x = rand_range(-65,65)
        var z = rand_range(-65,65)
        if abs(x) < 8 and abs(z) < 20: continue
        var trunk = CylinderMesh.new()
        trunk.top_radius = 0.18
        trunk.bottom_radius = 0.28
        trunk.height = 2.0
        _cylinder("TreeTrunk", trunk, Vector3(x,1,z), Color(0.28,0.16,0.08))
        var crown_radius = rand_range(1.0,1.55)
        var leaf_color = Color(rand_range(0.08,0.16),rand_range(0.30,0.48),rand_range(0.12,0.22))
        for layer in range(3):
            var crown = SphereMesh.new()
            crown.radius = crown_radius * (1.0 if layer == 0 else 0.72)
            crown.height = crown.radius * 1.45
            var n = MeshInstance.new()
            n.mesh = crown
            n.translation = Vector3(x,2.8 + layer * 0.72,z)
            n.scale = Vector3(1.15,0.82,1.0)
            n.material_override = _mat(leaf_color.lightened(layer * 0.045))
            add_child(n)

func _villager(pos, shirt_color, label):
    var root = Spatial.new()
    root.name = label.replace(" ", "")
    root.translation = pos
    root.set_meta("idle_phase", rand_range(0.0, 6.0))
    add_child(root)
    var skin = Color(0.68,0.43,0.29)
    var body = MeshInstance.new()
    body.mesh = CapsuleMesh.new()
    body.translation = Vector3(0,1.05,0)
    body.scale = Vector3(0.34,0.52,0.24)
    body.material_override = _mat(shirt_color)
    root.add_child(body)
    var head = MeshInstance.new()
    head.mesh = SphereMesh.new()
    head.translation = Vector3(0,1.85,0)
    head.scale = Vector3(0.28,0.32,0.28)
    head.material_override = _mat(skin)
    root.add_child(head)
    var longyi = MeshInstance.new()
    var cloth = CylinderMesh.new()
    cloth.top_radius = 0.28
    cloth.bottom_radius = 0.34
    cloth.height = 0.75
    longyi.mesh = cloth
    longyi.translation = Vector3(0,0.48,0)
    longyi.material_override = _mat(Color(0.22,0.24,0.38))
    root.add_child(longyi)
    animated_npcs.append(root)

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
    var n = Spatial.new()
    n.name = label
    n.translation = pos + Vector3(0,0.5,0)
    var body_mesh = SphereMesh.new()
    body_mesh.radius = 0.55
    body_mesh.height = 0.9
    var body = MeshInstance.new()
    body.mesh = body_mesh
    body.scale = Vector3(1.5,0.8,0.8)
    body.material_override = _mat(color)
    n.add_child(body)
    var head = MeshInstance.new()
    head.mesh = SphereMesh.new()
    head.translation = Vector3(0,0.12,-0.62)
    head.scale = Vector3(0.38,0.38,0.38)
    head.material_override = _mat(color.darkened(0.04))
    n.add_child(head)
    var muzzle = MeshInstance.new()
    muzzle.mesh = SphereMesh.new()
    muzzle.translation = Vector3(0,-0.02,-0.91)
    muzzle.scale = Vector3(0.22,0.17,0.18)
    muzzle.material_override = _mat(color.lightened(0.12))
    n.add_child(muzzle)
    for side in [-1,1]:
        var ear = MeshInstance.new()
        ear.mesh = SphereMesh.new()
        ear.translation = Vector3(side*0.29,0.34,-0.57)
        ear.scale = Vector3(0.13,0.22,0.10)
        ear.material_override = _mat(color.darkened(0.12))
        n.add_child(ear)
    for side in [-1,1]:
        for front_back in [-1,1]:
            var leg = MeshInstance.new()
            leg.mesh = CylinderMesh.new()
            leg.translation = Vector3(side*0.36,-0.35,front_back*0.34)
            leg.scale = Vector3(0.13,0.62,0.13)
            leg.material_override = _mat(color.darkened(0.16))
            leg.set_meta("is_animal_leg", true)
            leg.set_meta("leg_phase", 0.0 if (side * front_back) > 0 else PI)
            n.add_child(leg)
    var tail = MeshInstance.new()
    tail.mesh = CylinderMesh.new()
    tail.translation = Vector3(0,0.08,0.69)
    tail.rotation_degrees.x = 28
    tail.scale = Vector3(0.055,0.42,0.055)
    tail.material_override = _mat(color.darkened(0.18))
    n.add_child(tail)
    if label == "Chicken" or label == "VillageDuck":
        head.scale = Vector3(0.25,0.27,0.25)
        muzzle.scale = Vector3(0.13,0.10,0.16)
        body.scale = Vector3(0.92,0.82,0.82)
        for child in n.get_children():
            if child is MeshInstance and child.mesh is CylinderMesh:
                child.scale *= 0.72
    elif label == "VillageDog" or label == "VillageGoat":
        head.scale = Vector3(0.31,0.31,0.31)
    n.set_meta("base_y", 0.5)
    n.set_meta("anim_phase", rand_range(0.0, 6.28))
    n.set_meta("wander_timer", rand_range(0.2, 2.0))
    n.set_meta("wander_direction", Vector3(rand_range(-1.0,1.0),0,rand_range(-1.0,1.0)).normalized())
    n.set_meta("wander_speed", rand_range(0.35,0.85))
    add_child(n)
    wandering_animals.append(n)

func _monastery(pos):
    _box("MonasteryWoodHall", pos + Vector3(0,1.5,0), Vector3(12,3,9), Color(0.48,0.27,0.12))
    _box("MonasteryVeranda", pos + Vector3(0,0.55,5), Vector3(14,0.25,2), Color(0.34,0.19,0.10))
    for i in range(5):
        _box("MonasteryPillar", pos + Vector3(-5+i*2.5,1.5,4.1), Vector3(0.22,3,0.22), Color(0.24,0.14,0.08))
    _box("MonasteryRoof", pos + Vector3(0,3.35,0), Vector3(13,0.35,10), Color(0.30,0.16,0.10))
    _box("MonasteryGoldTrim", pos + Vector3(0,3.58,0), Vector3(12,0.08,9), Color(0.82,0.62,0.22))

func _lotus_pond(pos):
    _box("LotusPondWater", pos + Vector3(0,0.02,0), Vector3(16,0.08,12), Color(0.12,0.43,0.48))
    for i in range(8):
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
    for i in range(14):
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
