extends Spatial

# Lightweight, reusable interior rooms. Only the active room is shown to the player.
var portals = []
var rooms = []
var current_room = -1
var outside_position = Vector3.ZERO
var last_message = ""

func build_world(villages):
    var index = 0
    for village in villages:
        var center = village.position
        var village_name = str(village.name)
        _add_portal(village_name + " - House", "HOUSE", center + Vector3(-51.75, 0.0, -48.5), index)
        index += 1
        _add_portal(village_name + " - Market", "SHOP", center + Vector3(18.0, 0.0, 22.5), index)
        index += 1
    _add_portal("Monastery", "MONASTERY", Vector3(-34.0, 0.0, -24.0), index)
    index += 1
    _add_portal("Myanmar School", "SCHOOL", Vector3(58.0, 0.0, -18.0), index)
    _build_school_exterior()
    index += 1
    _add_portal("Pagoda Prayer Hall", "TEMPLE", Vector3(28.0, 0.0, -14.0), index)
    _build_temple_exterior()
    index += 1
    _add_portal("Hidden Cave", "CAVE", Vector3(440.0, 0.0, 260.0), index)
    _build_cave_exterior()

func _mat(color):
    var material = SpatialMaterial.new()
    material.albedo_color = color
    material.roughness = 0.88
    return material

func _box(parent, label, position, size, color):
    var node = MeshInstance.new()
    node.name = label
    var mesh = CubeMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.translation = position
    node.material_override = _mat(color)
    parent.add_child(node)
    return node

func _add_portal(label, kind, position, room_index):
    var portal = Spatial.new()
    portal.name = "Entrance_" + str(room_index)
    portal.translation = position
    portal.set_meta("label", label)
    portal.set_meta("kind", kind)
    portal.set_meta("room_index", room_index)
    add_child(portal)
    _box(portal, "DoorFrame", Vector3(0, 1.15, 0), Vector3(1.55, 2.3, 0.20), Color(0.28, 0.15, 0.07))
    _box(portal, "DoorPanel", Vector3(0, 1.05, -0.08), Vector3(1.15, 2.05, 0.12), Color(0.48, 0.29, 0.13))
    _box(portal, "EntranceStep", Vector3(0, 0.08, 0.85), Vector3(2.2, 0.16, 1.8), Color(0.50, 0.43, 0.32))
    portals.append(portal)
    var room = Spatial.new()
    room.name = "InteriorRoom_" + str(room_index)
    room.translation = Vector3(-1800.0 - float(room_index) * 28.0, -120.0, 0.0)
    room.visible = false
    add_child(room)
    _build_room(room, kind, label)
    rooms.append(room)

func _build_room(room, kind, label):
    var floor_color = Color(0.34, 0.22, 0.12)
    var wall_color = Color(0.72, 0.61, 0.45)
    if kind == "SHOP":
        floor_color = Color(0.38, 0.26, 0.14)
        wall_color = Color(0.70, 0.48, 0.30)
    elif kind == "MONASTERY":
        floor_color = Color(0.46, 0.32, 0.19)
        wall_color = Color(0.76, 0.65, 0.48)
    elif kind == "SCHOOL":
        floor_color = Color(0.42, 0.34, 0.22)
        wall_color = Color(0.78, 0.70, 0.52)
    elif kind == "TEMPLE":
        floor_color = Color(0.72, 0.57, 0.25)
        wall_color = Color(0.88, 0.72, 0.38)
    elif kind == "CAVE":
        floor_color = Color(0.18, 0.19, 0.18)
        wall_color = Color(0.25, 0.27, 0.25)
    _box(room, "InteriorFloor", Vector3(0, 0, 0), Vector3(14, 0.25, 12), floor_color)
    _box(room, "BackWall", Vector3(0, 2.0, -6), Vector3(14, 4, 0.25), wall_color)
    _box(room, "LeftWall", Vector3(-7, 2.0, 0), Vector3(0.25, 4, 12), wall_color)
    _box(room, "RightWall", Vector3(7, 2.0, 0), Vector3(0.25, 4, 12), wall_color)
    _box(room, "FrontLeftWall", Vector3(-4.8, 2.0, 6), Vector3(4.4, 4, 0.25), wall_color)
    _box(room, "FrontRightWall", Vector3(4.8, 2.0, 6), Vector3(4.4, 4, 0.25), wall_color)
    _box(room, "Roof", Vector3(0, 4.05, 0), Vector3(14, 0.25, 12), wall_color.darkened(0.12))
    _box(room, "DoorwayMarker", Vector3(0, 1.1, 5.75), Vector3(1.7, 2.2, 0.12), Color(0.90, 0.67, 0.24))
    _box(room, "WelcomeSign", Vector3(0, 3.0, -5.78), Vector3(5.2, 0.8, 0.12), Color(0.22, 0.14, 0.08))
    if kind == "HOUSE":
        _box(room, "Bed", Vector3(-3.6, 0.55, -2.5), Vector3(3.2, 0.55, 2.2), Color(0.42, 0.20, 0.15))
        _box(room, "Table", Vector3(2.7, 0.7, -1.0), Vector3(2.4, 0.2, 1.5), Color(0.28, 0.16, 0.08))
        _box(room, "StorageChest", Vector3(4.8, 0.55, -4.0), Vector3(1.3, 1.0, 1.0), Color(0.50, 0.32, 0.12))
    elif kind == "SHOP":
        _box(room, "ShopCounter", Vector3(0, 0.75, -2.0), Vector3(8, 1.3, 1.0), Color(0.34, 0.18, 0.08))
        for i in range(4):
            _box(room, "Shelf_" + str(i), Vector3(-5.0 + i * 3.3, 1.8, -4.8), Vector3(2.3, 1.4, 0.35), Color(0.42, 0.26, 0.12))
    elif kind == "SCHOOL":
        _box(room, "TeacherDesk", Vector3(0, 0.7, -3.2), Vector3(3.2, 0.25, 1.2), Color(0.30, 0.18, 0.08))
        for row in range(2):
            for col in range(3):
                _box(room, "StudentDesk", Vector3(-4.0 + col * 4.0, 0.55, 0.5 + row * 2.0), Vector3(2.0, 0.18, 0.8), Color(0.48, 0.31, 0.15))
    elif kind == "MONASTERY":
        _box(room, "PrayerMat", Vector3(0, 0.16, -1.8), Vector3(7, 0.08, 3.0), Color(0.55, 0.18, 0.12))
        _box(room, "Altar", Vector3(0, 0.8, -4.2), Vector3(4.0, 1.4, 0.8), Color(0.70, 0.53, 0.18))
    elif kind == "TEMPLE":
        _box(room, "Altar", Vector3(0, 0.9, -4.0), Vector3(4.5, 1.5, 1.2), Color(0.92, 0.72, 0.24))
        _box(room, "OfferingTable", Vector3(0, 0.55, -1.2), Vector3(5.0, 0.2, 1.3), Color(0.55, 0.32, 0.10))
    elif kind == "CAVE":
        for i in range(8):
            _box(room, "CaveRock_" + str(i), Vector3(-5.5 + i * 1.55, 0.8 + float(i % 3) * 0.5, -3.5), Vector3(1.0, 1.6, 1.2), Color(0.16, 0.18, 0.17))
        _box(room, "Crystal", Vector3(0, 1.2, -2.0), Vector3(0.8, 2.4, 0.8), Color(0.10, 0.85, 0.78))
    else:
        _box(room, "Table", Vector3(0, 0.65, -1.0), Vector3(3.0, 0.2, 1.2), Color(0.32, 0.19, 0.08))
    _box(room, "InteriorNameplate", Vector3(0, 3.0, -5.7), Vector3(5.5, 0.45, 0.1), Color(0.12, 0.24, 0.20))

func _build_school_exterior():
    _box(self, "MyanmarSchoolBuilding", Vector3(58, 1.5, -27), Vector3(16, 3, 10), Color(0.78, 0.69, 0.48))
    _box(self, "MyanmarSchoolRoof", Vector3(58, 3.25, -27), Vector3(17, 0.45, 11), Color(0.35, 0.18, 0.10))
    _box(self, "SchoolDoor", Vector3(58, 1.0, -21.8), Vector3(1.5, 2.0, 0.15), Color(0.26, 0.14, 0.07))

func _build_temple_exterior():
    _box(self, "PagodaPrayerHall", Vector3(28, 1.4, -28), Vector3(11, 2.8, 8), Color(0.83, 0.68, 0.32))
    _box(self, "PrayerHallRoof", Vector3(28, 3.0, -28), Vector3(12, 0.4, 9), Color(0.42, 0.20, 0.08))

func _build_cave_exterior():
    _box(self, "CaveEntranceLantern", Vector3(440, 2.0, 258), Vector3(1.0, 2.0, 0.5), Color(0.90, 0.62, 0.12))

func try_interact(player):
    if not player or not is_instance_valid(player):
        return false
    if current_room >= 0:
        _leave_room(player)
        return true
    var position = player.global_transform.origin
    var best_index = -1
    var best_distance = 4.5
    for i in range(portals.size()):
        var portal = portals[i]
        if not is_instance_valid(portal):
            continue
        var distance = Vector2(position.x, position.z).distance_to(Vector2(portal.global_transform.origin.x, portal.global_transform.origin.z))
        if distance < best_distance:
            best_distance = distance
            best_index = i
    if best_index < 0:
        return false
    _enter_room(player, best_index)
    return true

func _enter_room(player, portal_index):
    outside_position = player.global_transform.origin
    current_room = portal_index
    var room = rooms[portal_index]
    room.visible = true
    var room_origin = room.global_transform.origin
    player.global_transform.origin = room_origin + Vector3(0, 0.15, 1.5)
    player.velocity = Vector3.ZERO
    player.move_input = Vector2.ZERO
    last_message = str(portals[portal_index].get_meta("label")) + " အတွင်းသို့ ဝင်ရောက်ခဲ့ပါပြီ။ အခန်းအတွင်း လှည့်လည်ကြည့်ရှုပြီး Interact နှိပ်၍ အပြင်ပြန်ထွက်နိုင်ပါတယ်။"

func _leave_room(player):
    if current_room < 0:
        return
    rooms[current_room].visible = false
    player.global_transform.origin = outside_position + Vector3(0, 0.1, 2.0)
    player.velocity = Vector3.ZERO
    player.move_input = Vector2.ZERO
    last_message = "အဆောက်အအုံအပြင်သို့ ပြန်ထွက်လာပါပြီ။"
    current_room = -1
