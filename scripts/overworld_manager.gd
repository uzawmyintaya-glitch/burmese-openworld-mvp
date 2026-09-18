extends Node2D

# Overworld manager with save/load and current location persistence

@export var start_node: String = "TownA"
var current_node: String
var map_data: Dictionary = {}
var is_traveling: bool = false
var travel_timer: Timer = null
var save_handler = null

func _ready():
    current_node = start_node
    save_handler = preload("res://scripts/beta_save_handler.gd").new()
    add_child(save_handler)
    var saved = save_handler.load_state()
    if saved.size() > 0 and saved.has("location"):
        current_node = saved["location"]
    var mp = "res://data/overworld/map.json"
    if ResourceLoader.exists(mp):
        var txt = FileAccess.get_file_as_string(mp)
        var parsed = JSON.parse_string(txt)
        if parsed:
            map_data = parsed
    travel_timer = Timer.new()
    travel_timer.one_shot = true
    add_child(travel_timer)
    travel_timer.timeout.connect(Callable(self, "_on_travel_complete"))
    _update_ui()

func _on_ButtonTravel_pressed():
    if is_traveling:
        return
    _show_destination_choices()

func _save_current_state():
    var data = {
        "location": current_node,
        "gold": 120,
        "units": []
    }
    if save_handler:
        save_handler.save_state(data)

func _show_destination_choices():
    var conns = map_data.get(current_node, []).get("connections", [])
    var ui = get_node_or_null("UI")
    if not ui:
        return
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
    travel_timer.wait_time = travel_time
    travel_timer.start()
    var lbl = get_node_or_null("UI/LabelTitle")
    if lbl:
        lbl.text = "Traveling to %s..." % dest_name
    var choices = get_node_or_null("UI/DestChoices")
    if choices:
        choices.queue_free()

func _on_travel_complete() -> void:
    is_traveling = false
    var next_dest = current_node
    var conns = map_data.get(current_node, []).get("connections", [])
    if not conns.is_empty():
        next_dest = conns[randi() % conns.size()]
    current_node = next_dest
    _save_current_state()
    var lbl = get_node_or_null("UI/LabelTitle")
    if lbl:
        lbl.text = "Overworld - Arrived: %s" % current_node

    if randf() < 0.5:
        _trigger_encounter(current_node)

func _trigger_encounter(node_name: String) -> void:
    var em = preload("res://scripts/encounter_builder.gd").new()
    var enc = em.build_encounter(node_name, 1)
    var battle_scene = load("res://scenes/battle.tscn")
    if battle_scene:
        var packed = battle_scene.instantiate()
        if packed.has_variable("enemy_count"):
            packed.enemy_count = enc["enemies"].size()
        get_tree().root.add_child(packed)
        get_tree().set_current_scene(packed)

func _update_ui():
    var lbl = get_node_or_null("UI/LabelTitle")
    if lbl:
        lbl.text = "Overworld - Current: %s" % current_node
