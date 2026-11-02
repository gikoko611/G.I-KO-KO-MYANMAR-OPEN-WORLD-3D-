extends Spatial

var animated_people = []
var clock = 0.0

func build_world():
    _build_forest_camps()
    _build_religious_places()

func _process(delta):
    clock += delta
    for person in animated_people:
        if is_instance_valid(person):
            person.rotation.y = sin(clock * 0.45 + float(person.get_meta("phase", 0.0))) * 0.06
            person.translation.y = sin(clock * 1.5 + float(person.get_meta("phase", 0.0))) * 0.018

func _mat(color):
    var material = SpatialMaterial.new()
    material.albedo_color = color
    material.roughness = 0.88
    return material

func _box(label, pos, size, color):
    var node = MeshInstance.new()
    node.name = label
    var mesh = CubeMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.translation = pos
    node.material_override = _mat(color)
    add_child(node)
    return node

func _cylinder(label, pos, radius, height, color):
    var node = MeshInstance.new()
    node.name = label
    var mesh = CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    node.mesh = mesh
    node.translation = pos
    node.material_override = _mat(color)
    add_child(node)
    return node

func _person(label, pos, robe_color, role_color = Color(0.68,0.43,0.29)):
    var root = Spatial.new()
    root.name = label
    root.translation = pos
    root.set_meta("phase", rand_range(0.0, 6.28))
    var body = MeshInstance.new()
    body.mesh = CapsuleMesh.new()
    body.translation = Vector3(0,1.0,0)
    body.scale = Vector3(0.34,0.52,0.25)
    body.material_override = _mat(robe_color)
    root.add_child(body)
    var head = MeshInstance.new()
    head.mesh = SphereMesh.new()
    head.translation = Vector3(0,1.78,0)
    head.scale = Vector3(0.28,0.31,0.28)
    head.material_override = _mat(role_color)
    root.add_child(head)
    var legs = MeshInstance.new()
    legs.mesh = CylinderMesh.new()
    legs.translation = Vector3(0,0.35,0)
    legs.scale = Vector3(0.25,0.48,0.25)
    legs.material_override = _mat(Color(0.20,0.20,0.22))
    root.add_child(legs)
    add_child(root)
    animated_people.append(root)
    return root

func _build_forest_camps():
    # Hermit's quiet forest retreat
    var hermit = Vector3(-59,0,-43)
    _box("HermitHutFloor", hermit + Vector3(0,0.12,0), Vector3(5,0.24,4), Color(0.34,0.22,0.13))
    _box("HermitHutWalls", hermit + Vector3(0,1.35,0), Vector3(4.5,2.5,3.6), Color(0.55,0.42,0.27))
    _box("HermitHutRoof", hermit + Vector3(0,2.75,0), Vector3(5.5,0.28,4.5), Color(0.28,0.17,0.10))
    _person("Forest Hermit", hermit + Vector3(3,0,2), Color(0.62,0.48,0.25))
    _cylinder("HermitFirewood", hermit + Vector3(-3,0.45,1), 0.18, 1.8, Color(0.30,0.17,0.08))

    # Timber cutters' camp
    var timber = Vector3(-46,0,34)
    _box("TimberCampShelter", timber + Vector3(0,1.6,0), Vector3(8,3.2,5), Color(0.40,0.28,0.16))
    _box("TimberCampRoof", timber + Vector3(0,3.35,0), Vector3(9,0.3,6), Color(0.25,0.15,0.08))
    for i in range(5):
        _cylinder("StackedLog", timber + Vector3(-2.4 + i*1.2,0.35,3.2), 0.24, 2.5, Color(0.38,0.23,0.12))
    _person("Lumberjack", timber + Vector3(5,0,2), Color(0.24,0.34,0.22))
    _person("Woodcutter", timber + Vector3(-5,0,1), Color(0.42,0.25,0.13))

    # Bamboo cutters near the bamboo grove
    var bamboo = Vector3(-61,0,18)
    _box("BambooCutterShelter", bamboo + Vector3(0,1.1,0), Vector3(6,2.2,4), Color(0.46,0.34,0.19))
    for i in range(7):
        _cylinder("CutBamboo", bamboo + Vector3(-2.5 + i*0.8,0.42,2.8), 0.09, 3.5, Color(0.34,0.52,0.20))
    _person("Bamboo Cutter", bamboo + Vector3(4,0,1), Color(0.28,0.39,0.20))

    # Hunter's camp and lookout
    var hunter = Vector3(-53,0,-12)
    _box("HunterCampFloor", hunter + Vector3(0,0.12,0), Vector3(7,0.24,5), Color(0.32,0.22,0.13))
    _box("HunterCampRoof", hunter + Vector3(0,2.7,0), Vector3(8,0.3,6), Color(0.25,0.14,0.08))
    _person("Forest Hunter", hunter + Vector3(4,0,2), Color(0.25,0.30,0.20))
    _person("Forest Ranger", hunter + Vector3(-4,0,1), Color(0.18,0.28,0.34))
    _person("Lost Traveler", Vector3(-65,0,-26), Color(0.42,0.28,0.18))
    _cylinder("HunterCampfire", hunter + Vector3(0,0.18,-2.4), 0.65, 0.35, Color(0.22,0.16,0.12))

func _build_religious_places():
    # Buddhist monastery extension: monk and nun residence
    var monastery = Vector3(-34,0,-30)
    _person("Buddhist Monk", monastery + Vector3(8,0,5), Color(0.72,0.34,0.12))
    _person("Buddhist Nun", monastery + Vector3(-8,0,5), Color(0.86,0.84,0.70))
    _box("NunneryHall", monastery + Vector3(-12,1.25,0), Vector3(7,2.5,6), Color(0.72,0.68,0.54))
    _box("NunneryRoof", monastery + Vector3(-12,2.65,0), Vector3(8,0.25,7), Color(0.34,0.20,0.12))
    _box("MonasteryBellTower", monastery + Vector3(0,2.0,-8), Vector3(1.3,4,1.3), Color(0.40,0.25,0.12))
    _cylinder("MonasteryBell", monastery + Vector3(0,3.2,-8), 0.5, 0.65, Color(0.82,0.65,0.24))

    # Christian church in a separate village clearing
    var church = Vector3(49,0,-45)
    _box("ChurchFoundation", church + Vector3(0,0.18,0), Vector3(14,0.36,10), Color(0.66,0.62,0.52))
    _box("ChurchNave", church + Vector3(0,2.0,0), Vector3(11,3.6,8), Color(0.82,0.79,0.68))
    _box("ChurchRoof", church + Vector3(0,4.0,0), Vector3(12,0.35,9), Color(0.28,0.20,0.16))
    _box("ChurchDoor", church + Vector3(0,1.3,4.08), Vector3(1.5,2.6,0.16), Color(0.28,0.18,0.12))
    _box("ChurchWindowLeft", church + Vector3(-3.6,2.2,4.1), Vector3(1.0,1.5,0.12), Color(0.24,0.50,0.68))
    _box("ChurchWindowRight", church + Vector3(3.6,2.2,4.1), Vector3(1.0,1.5,0.12), Color(0.24,0.50,0.68))
    _box("ChurchTower", church + Vector3(0,5.0,-2.7), Vector3(2.0,3.2,2.0), Color(0.78,0.75,0.65))
    _box("ChurchCrossStem", church + Vector3(0,7.2,-2.7), Vector3(0.22,1.4,0.22), Color(0.90,0.82,0.58))
    _box("ChurchCrossArms", church + Vector3(0,7.35,-2.7), Vector3(0.95,0.22,0.22), Color(0.90,0.82,0.58))
    _person("Christian Pastor", church + Vector3(8,0,3), Color(0.20,0.28,0.42))
    _person("Church Helper", church + Vector3(-8,0,3), Color(0.46,0.30,0.26))
