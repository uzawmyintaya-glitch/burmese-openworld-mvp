extends Node

# Encounter manager: decides encounter composition and launches battle

func _ready():
    pass

func spawn_encounter(node_name: String) -> void:
    # decide encounter size based on node difficulty (from map.json)
    var map_path = "res://data/overworld/map.json"
    var difficulty = 1
    if ResourceLoader.exists(map_path):
        var txt = FileAccess.get_file_as_string(map_path)
        var md = JSON.parse_string(txt).result
        difficulty = md.get(node_name, {}).get("difficulty", 1)
    var enemy_count = clamp(1 + difficulty, 1, 6)
    print("Spawning encounter at %s: difficulty=%d, enemy_count=%d" % [node_name, difficulty, enemy_count])
    # pass to battle scene via autoload or singleton? For simplicity set a global var in ProjectSettings (lightweight)
    ProjectSettings.set_setting("application/run/last_encounter_count", enemy_count)
    # change to the battle scene
    var battle_scene = load("res://scenes/battle.tscn")
    if battle_scene:
        var packed = battle_scene.instantiate()
        # if battle manager expects enemy_count export var, set it
        if packed.has_method("set"):
            # many nodes use exported variables; try to set
            if packed.has_variable("enemy_count"):
                packed.enemy_count = enemy_count
        get_tree().root.add_child(packed)
        get_tree().set_current_scene(packed)

