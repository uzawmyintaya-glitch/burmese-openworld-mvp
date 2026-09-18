class_name SaveHandler
extends Node

# Save/load party + location state with JSON

const SAVE_PATH := "user://beta_save.json"

func save_state(data: Dictionary) -> bool:
    var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if not f:
        return false
    f.store_string(JSON.stringify(data))
    f.close()
    return true

func load_state() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {}
    var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not f:
        return {}
    var text = f.get_as_text()
    f.close()
    var parsed = JSON.parse_string(text)
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
