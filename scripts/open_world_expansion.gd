extends Spatial

var village_centers = []
var village_names = ["ရွှေတောင်ရွာ","စိမ်းလန်းရွာ","မြစ်ကမ်းရွာ","တောင်ခြေရွာ","ပန်းခင်းရွာ","ဝါးတောရွာ","ရေကန်ရွာ","မိုးကုတ်ရွာ","ငွေလမင်းရွာ","သစ်တောရွာ","ရွှေစပါးရွာ","ငှက်ပျောရွာ"]
var pickup_nodes = []

func build_world():
    _build_ground()
    _build_roads()
    _build_villages()
    _build_lake_and_waterfall()
    _build_cave()
    _build_hidden_treasures()
    _build_fruit_trees()

func _material(color, transparent = false):
    var material = SpatialMaterial.new()
    material.albedo_color = color
    material.roughness = 0.82 if not transparent else 0.18
    if transparent:
        material.flags_transparent = true
        material.params_depth_draw_mode = SpatialMaterial.DEPTH_DRAW_DISABLED
    return material

func _build_ground():
    var ground = MeshInstance.new()
    var mesh = CubeMesh.new()
    mesh.size = Vector3(1400,1,1000)
    ground.mesh = mesh
    ground.translation = Vector3(0,-0.7,0)
    ground.material_override = _material(Color(0.25,0.42,0.20))
    add_child(ground)
    var body = StaticBody.new()
    body.translation = Vector3(0,-0.7,0)
    var collision = CollisionShape.new()
    var shape = BoxShape.new()
    shape.extents = Vector3(700,0.5,500)
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func _box(label, pos, size, color):
    var node = MeshInstance.new()
    node.name = label
    var mesh = CubeMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.translation = pos
    node.material_override = _material(color)
    add_child(node)
    return node

func _build_roads():
    for z in [-300.0,0.0,300.0]:
        _box("VillageMainRoad", Vector3(0,-0.08,z), Vector3(920,0.16,9), Color(0.55,0.43,0.29))
    for x in [-450.0,-150.0,150.0,450.0]:
        _box("VillageMainRoad", Vector3(x,-0.08,0), Vector3(9,0.16,620), Color(0.55,0.43,0.29))
    _box("LongRiverCanal", Vector3(90,-0.10,0), Vector3(10,0.12,920), Color(0.12,0.43,0.60))
    for z in [-300.0,0.0,300.0]:
        _box("CanalBridge", Vector3(90,0.05,z), Vector3(17,0.28,5), Color(0.38,0.23,0.13))

func _build_villages():
    var xs = [-450.0,-150.0,150.0,450.0]
    var zs = [-300.0,0.0,300.0]
    var index = 0
    for z in zs:
        for x in xs:
            var center = Vector3(x,0,z)
            village_centers.append({"name":village_names[index],"position":center})
            _village_sign(center, village_names[index], index)
            _build_village_market(center, index)
            _house_batch(center, "walls", Vector3(5,2.2,4), 1.1, Color(0.75,0.62,0.43))
            _house_batch(center, "floors", Vector3(5.5,0.22,4.5), 0.12, Color(0.34,0.20,0.10))
            _house_batch(center, "roofs", Vector3(6.2,0.36,5.2), 2.48, Color(0.38,0.19,0.08))
            index += 1

func _build_village_market(center, index):
    var shop_pos = center + Vector3(18,0,18)
    _box("VillageMarket_" + str(index), shop_pos + Vector3(0,1.0,0), Vector3(8,2.0,6), Color(0.55,0.32,0.12))
    _box("VillageMarketRoof_" + str(index), shop_pos + Vector3(0,2.4,0), Vector3(9,0.5,7), Color(0.72,0.18,0.12))
    _box("VillageMarketCounter_" + str(index), shop_pos + Vector3(0,0.55,3.2), Vector3(7,1.1,0.6), Color(0.34,0.19,0.08))

func _house_batch(center, part, size, y, color):
    var multimesh = MultiMesh.new()
    multimesh.transform_format = MultiMesh.TRANSFORM_3D
    var mesh = CubeMesh.new()
    mesh.size = Vector3.ONE
    multimesh.mesh = mesh
    multimesh.instance_count = 100
    for i in range(100):
        var row = int(i / 10)
        var col = i % 10
        var offset = Vector3((col - 4.5) * 11.5, y, (row - 4.5) * 11.5)
        var basis = Basis().scaled(size)
        multimesh.set_instance_transform(i, Transform(basis, center + offset))
    var batch = MultiMeshInstance.new()
    batch.name = "VillageHouseBatch_" + part
    batch.multimesh = multimesh
    var material = _material(color)
    batch.material_override = material
    add_child(batch)

func _village_sign(center, label, index):
    _box("VillageSignPost", center + Vector3(-67,1.4,-67), Vector3(0.35,2.8,0.35), Color(0.30,0.18,0.08))
    _box("VillageSignBoard", center + Vector3(-67,2.6,-67), Vector3(5.5,1.1,0.25), Color(0.40,0.24,0.10))
    # A distinct colored marker identifies each village from a distance.
    var marker = MeshInstance.new()
    var mesh = SphereMesh.new()
    mesh.radius = 1.2
    mesh.height = 2.4
    marker.mesh = mesh
    marker.translation = center + Vector3(0,4.2,0)
    marker.material_override = _material(Color(0.78 + float(index % 3) * 0.05,0.62,0.22))
    add_child(marker)

func _build_lake_and_waterfall():
    _box("LakeSandBank", Vector3(180,-0.12,240), Vector3(112,0.22,82), Color(0.67,0.57,0.37))
    var water = _box("SwimmingLake", Vector3(180,3.0,240), Vector3(92,0.14,64), Color(0.12,0.48,0.68,0.76))
    water.material_override = _material(Color(0.12,0.48,0.68,0.76), true)
    _box("WaterfallRock", Vector3(235,3.0,240), Vector3(8,9,18), Color(0.36,0.39,0.34))
    _box("WaterfallFlow", Vector3(230,2.9,240), Vector3(2.2,5.8,12), Color(0.30,0.72,0.86,0.78))
    _box("LakeIsland", Vector3(180,0.05,240), Vector3(12,0.45,8), Color(0.38,0.46,0.22))
    for i in range(8):
        var rock = MeshInstance.new()
        var rock_mesh = SphereMesh.new()
        rock_mesh.radius = rand_range(1.0,2.2)
        rock_mesh.height = rock_mesh.radius * 0.8
        rock.mesh = rock_mesh
        rock.translation = Vector3(135 + i * 13,0.2,205 + (i % 3) * 30)
        rock.material_override = _material(Color(0.38,0.40,0.36))
        add_child(rock)

func _build_cave():
    var cave = Vector3(440,0,245)
    _box("CaveRockLeft", cave + Vector3(-5,4,0), Vector3(5,8,14), Color(0.20,0.23,0.22))
    _box("CaveRockRight", cave + Vector3(5,4,0), Vector3(5,8,14), Color(0.20,0.23,0.22))
    _box("CaveRoof", cave + Vector3(0,8,0), Vector3(14,3,15), Color(0.18,0.20,0.19))
    _box("CaveDarkness", cave + Vector3(0,2,-1), Vector3(5,4,0.4), Color(0.025,0.03,0.03))
    _box("CaveTrail", cave + Vector3(0,0.02,12), Vector3(9,0.08,28), Color(0.35,0.30,0.22))

func _pickup(kind, value, pos, color, radius):
    var node = MeshInstance.new()
    node.name = "Hidden" + str(kind)
    var mesh = SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 2.0
    node.mesh = mesh
    node.translation = pos
    node.scale = Vector3(1.0,1.25,1.0)
    node.material_override = _material(color)
    node.set_meta("pickup_id", str(kind) + "_" + str(pickup_nodes.size()))
    node.set_meta("pickup_type", kind)
    node.set_meta("pickup_value", value)
    node.add_to_group("world_pickups")
    add_child(node)
    pickup_nodes.append(node)

func _build_hidden_treasures():
    var gem_spots = [
        Vector3(-66,0.8,-58),Vector3(-48,0.8,-46),Vector3(-30,0.8,-62),Vector3(-5,0.8,-55),
        Vector3(35,0.8,-58),Vector3(62,0.8,-42),Vector3(82,0.8,22),Vector3(115,0.8,140),
        Vector3(155,0.8,215),Vector3(175,0.8,242),Vector3(195,0.8,255),Vector3(225,0.8,260),
        Vector3(420,0.8,240),Vector3(438,0.8,248),Vector3(455,0.8,252),Vector3(470,0.8,260),
        Vector3(-430,0.8,-280),Vector3(-160,0.8,-320),Vector3(160,0.8,-320),Vector3(455,0.8,-320),
        Vector3(-455,0.8,280),Vector3(-150,0.8,320),Vector3(150,0.8,320),Vector3(455,0.8,280),
        Vector3(-390,0.8,60),Vector3(-260,0.8,145),Vector3(270,0.8,-130),Vector3(390,0.8,-80),
        Vector3(350,0.8,410),Vector3(-350,0.8,410)
    ]
    for i in range(gem_spots.size()):
        _pickup("Gem", 50 + (i % 4) * 25, gem_spots[i], Color(0.10,0.95,0.85), 0.48)
    for i in range(60):
        var x = rand_range(-640,640)
        var z = rand_range(-450,450)
        _pickup("Coin", 5 + (i % 5) * 5, Vector3(x,0.65,z), Color(1.0,0.72,0.18), 0.22)

func _build_fruit_trees():
    for i in range(30):
        var x = -600 + float((i * 173) % 1200)
        var z = -420 + float((i * 97) % 840)
        if abs(x) < 95 and abs(z) < 95:
            x += 125
        var tree = Spatial.new()
        tree.name = "FruitTree_" + str(i + 1)
        tree.translation = Vector3(x,0,z)
        tree.set_meta("fruit_count", 3)
        tree.set_meta("tree_height", 7.0)
        tree.add_to_group("climb_trees")
        tree.add_to_group("fruit_trees")
        var trunk = MeshInstance.new()
        var trunk_mesh = CylinderMesh.new()
        trunk_mesh.top_radius = 0.25
        trunk_mesh.bottom_radius = 0.42
        trunk_mesh.height = 4.2
        trunk.mesh = trunk_mesh
        trunk.translation.y = 2.1
        trunk.material_override = _material(Color(0.30,0.17,0.08))
        tree.add_child(trunk)
        var crown = MeshInstance.new()
        var crown_mesh = SphereMesh.new()
        crown_mesh.radius = 2.6
        crown_mesh.height = 4.5
        crown.mesh = crown_mesh
        crown.translation.y = 5.0
        crown.material_override = _material(Color(0.12,0.42,0.17))
        tree.add_child(crown)
        for fruit_index in range(3):
            var fruit = MeshInstance.new()
            var fruit_mesh = SphereMesh.new()
            fruit_mesh.radius = 0.22
            fruit_mesh.height = 0.44
            fruit.mesh = fruit_mesh
            fruit.translation = Vector3(-0.8 + fruit_index * 0.8,4.5 + (fruit_index % 2) * 0.6,-1.8)
            fruit.material_override = _material(Color(0.88,0.18,0.08))
            tree.add_child(fruit)
        add_child(tree)

