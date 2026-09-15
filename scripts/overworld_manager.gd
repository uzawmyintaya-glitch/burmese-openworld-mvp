extends Node2D

# Overworld manager: simple node-graph travel + encounter trigger
# Attach to Overworld root (scenes/overworld.tscn)

@export var start_node: String = "TownA"
var current_node: String
var map_data: Dictionary = {}
var is_traveling: bool = false
var travel_timer: Timer = null

func _ready():
    current_node = start_node
    # load map data
    var mp = "res://data/overworld/map.json"
    if ResourceLoader.exists(mp):
        var txt = FileAccess.get_file_as_string(mp)
        map_data = JSON.parse_string(txt).result
    else:
        map_data = {}
    # ensure timer
    travel_timer = Timer.new()
    travel_timer.one_shot = true
    add_child(travel_timer)
    travel_timer.timeout.connect(Callable(self, "_on_travel_complete"))
    _update_ui()

func _on_ButtonTravel_pressed():
    # simple UI: travel to a random connected node
    if is_traveling:
        return
    var conns = map_data.get(current_node, []).get("connections", [])
    if conns.empty():
        push_warning("No connections from %s" % current_node)
        return
    var dest = conns[randi() % conns.size()]
    start_travel_to(dest)

func start_travel_to(dest_name: String) -> void:
    if is_traveling:
        return
    var info = map_data.get(dest_name, null)
    if not info:
        push_error("Destination not found: %s" % dest_name)
        return
    is_traveling = true
    var travel_time = info.get("travel_time", 3)
    print("Starting travel from %s to %s (time %s)" % [current_node, dest_name, travel_time])
    # start a timer (simulate travel)
    travel_timer.wait_time = travel_time
    travel_timer.start()
    emit_signal("travel_started", current_node, dest_name, travel_time)
    # Basic visual feedback: change LabelTitle
    var lbl = get_node_or_null("UI/LabelTitle")
    if lbl:
        lbl.text = "Traveling to %s..." % dest_name

func _on_travel_complete() -> void:
    is_traveling = false
    # find destination by timer - for simplicity pick a random connection
    var conns = map_data.get(current_node, []).get("connections", [])
    var dest = conns.empty() ? current_node : conns[randi() % conns.size()]
    current_node = dest
    print("Arrived: %s" % current_node)
    var lbl = get_node_or_null("UI/LabelTitle")
    if lbl:
        lbl.text = "Overworld - Arrived: %s" % current_node
    # trigger encounter chance
    var encounter_chance = map_data.get(current_node, {}).get("encounter_chance", 0.3)
    if randf() < encounter_chance:
        _trigger_encounter(current_node)

func _trigger_encounter(node_name: String) -> void:
    print("Encounter triggered at %s" % node_name)
    # simple encounter: call EncounterManager if present
    var em = get_node_or_null("EncounterManager")
    if em:
        em.spawn_encounter(node_name)
    else:
        # fallback: directly load battle scene
        var battle_scene = load("res://scenes/battle.tscn")
        if battle_scene:
            get_tree().change_scene_to(battle_scene)

func _update_ui():
    var lbl = get_node_or_null("UI/LabelTitle")
    if lbl:
        lbl.text = "Overworld - Current: %s" % current_node

# Signals (optional)
signal travel_started(from_node, to_node, travel_time)
