extends Reference
const PATH = "user://myanmar_open_world_save.json"
const TEMP_PATH = "user://myanmar_open_world_save.tmp"
const BACKUP_PATH = "user://myanmar_open_world_save.bak"

static func save_game(data):
    var payload = data.duplicate(true)
    payload["save_version"] = 2
    var file = File.new()
    if file.open(TEMP_PATH, File.WRITE) != OK:
        return false
    file.store_string(to_json(payload))
    file.flush()
    file.close()
    var directory = Directory.new()
    if directory.file_exists(BACKUP_PATH):
        directory.remove(BACKUP_PATH)
    if directory.file_exists(PATH):
        var backup_error = directory.rename(PATH, BACKUP_PATH)
        if backup_error != OK:
            directory.remove(TEMP_PATH)
            return false
    var move_error = directory.rename(TEMP_PATH, PATH)
    if move_error != OK:
        if directory.file_exists(BACKUP_PATH):
            directory.rename(BACKUP_PATH, PATH)
        return false
    return true

static func _read_save(path):
    var file = File.new()
    if not file.file_exists(path):
        return {}
    if file.open(path, File.READ) != OK:
        return {}
    var parsed = parse_json(file.get_as_text())
    file.close()
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

static func load_game():
    var data = _read_save(PATH)
    if not data.empty():
        return data
    return _read_save(BACKUP_PATH)
