extends Node2D

# Overworld manager: simple node-graph travel + selectable destinations
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
    # show available destinations as buttons
    if is_traveling:
        return
    _show_destination_choices()

func _show_destination_choices():
    var conns = map_data.get(current_node, []).get("connections", [])
    var ui = get_node_or_null("UI")
    if not ui:
        return
    # remove previous choice container if any
    var prev = ui.get_node_or_null("DestChoices")
    if prev:
        prev.queue_free()
    var box = VBoxContainer.new()
    box.name = "DestChoices"
    box.rect_position = Vector2(8,80)
    ui.add_child(box)
    if conns.empty():
        var lbl = Label.new()
        lbl.text = "No destinations"
        box.add_child(lbl)
        return
    for dest in conns:
        var btn = Button.new()
        btn.text = "%s (%ds)" % [dest, map_data.get(dest, {}).get("travel_time", 3)]
        box.add_child(btn)
        btn.pressed.connect(func(d=dest): start_travel_to(d))

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
    # remove destination choices
    var choices = get_node_or_null("UI/DestChoices")
    if choices:
        choices.queue_free()

func _on_travel_complete() -> void:
    is_traveling = false
    # we set current_node to the destination name we traveled to earlier via travel_started signal; to keep state simple, find a node whose traveling label shows
    # For robustness, just pick a random connected node from previous current_node's connections
    var conns = map_data.get(current_node, []).get("connections", [])
    var dest = conns.empty() ? current_node : conns[randi() % conns.size()]
    # However, we stored destination in last travel label if available
    var lbl = get_node_or_null("UI/LabelTitle")
    var arrived = null
    if lbl and lbl.text.find("Traveling to ") >= 0:
        arrived = lbl.text.replace("Traveling to ", "").replace("...", "")
    if arrived and map_data.has(arrived):
        current_node = arrived
    else:
        current_node = dest
    print("Arrived: %s" % current_node)
    if lbl:
        lbl.text = "Overworld - Arrived: %s" % current_node
    # trigger encounter chance
    var encounter_chance = map_data.get(current_node, {}).get("encounter_chance", 0.3)
    if randf() < encounter_chance:
        _trigger_encounter(current_node)

func _trigger_encounter(node_name: String) -> void:
    print("Encounter triggered at %s" % node_name)
    var em = get_node_or_null("EncounterManager")
    if em:
        em.spawn_encounter(node_name)
    else:
        var battle_scene = load("res://scenes/battle.tscn")
        if battle_scene:
            # use ProjectSettings to pass enemy_count if set
            var enemy_count = ProjectSettings.get_setting("application/run/last_encounter_count", -1)
            var packed = battle_scene.instantiate()
            if enemy_count > 0 and packed.has_variable("enemy_count"):
                packed.enemy_count = enemy_count
            get_tree().root.add_child(packed)
            get_tree().set_current_scene(packed)

func _update_ui():
    var lbl = get_node_or_null("UI/LabelTitle")
    if lbl:
        lbl.text = "Overworld - Current: %s" % current_node

# Signals (optional)
signal travel_started(from_node, to_node, travel_time)
