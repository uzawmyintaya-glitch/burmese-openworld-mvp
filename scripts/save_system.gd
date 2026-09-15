extends Node

# Simple save/load skeleton for Beta (JSON files saved to user://)

const SAVE_FILE := "user://savegame.json"

func save_game(data: Dictionary) -> bool:
    var f = File.new()
    var err = f.open(SAVE_FILE, File.WRITE)
    if err != OK:
        push_error("Failed to open save file: %s" % err)
        return false
    var json = JSON.print(data)
    f.store_string(json)
    f.close()
    return true

func load_game() -> Dictionary:
    var f = File.new()
    if not f.file_exists(SAVE_FILE):
        return {}
    var err = f.open(SAVE_FILE, File.READ)
    if err != OK:
        push_error("Failed to open save file: %s" % err)
        return {}
    var json = f.get_as_text()
    f.close()
    var res = JSON.parse(json)
    if res.error != OK:
        push_error("Failed to parse save JSON: %s" % res.error)
        return {}
    return res.result
