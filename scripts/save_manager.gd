extends Reference
const PATH = "user://myanmar_open_world_save.json"

static func save_game(data):
    var file = File.new()
    if file.open(PATH, File.WRITE) == OK:
        file.store_string(to_json(data))
        file.close()
        return true
    return false

static func load_game():
    var file = File.new()
    if not file.file_exists(PATH):
        return {}
    if file.open(PATH, File.READ) != OK:
        return {}
    var parsed = parse_json(file.get_as_text())
    file.close()
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
