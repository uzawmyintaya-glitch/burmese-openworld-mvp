extends Node2D

# Town manager for Beta
# Provides basic shop, recruit, and back actions and integrates with party data + save state

var party_data = {
    "leader": "Player",
    "gold": 120,
    "location": "TownA",
    "units": [
        {"id": "unit_1", "name": "Guardian", "type": "infantry", "level": 1, "hp": 100, "attack": 15, "defense": 8, "speed": 6},
        {"id": "unit_2", "name": "Bowman", "type": "archer", "level": 1, "hp": 80, "attack": 12, "defense": 4, "speed": 7}
    ],
    "inventory": [
        {"id": "item_1", "name": "Rice", "type": "consumable", "price": 10},
        {"id": "item_2", "name": "Steel Sword", "type": "weapon", "price": 35}
    ]
}

var save_handler = null

func _ready():
    if not save_handler:
        save_handler = preload("res://scripts/beta_save_handler.gd").new()
        add_child(save_handler)
    _load_party_state()
    _refresh_label()

func _load_party_state():
    var state = save_handler.load_state()
    if state.size() > 0:
        party_data = state

func _save_party_state():
    if save_handler:
        save_handler.save_state(party_data)

func _refresh_label():
    var title = get_node_or_null("UI/LabelTitle")
    if title:
        title.text = "Town - %s | Gold: %d | Party: %d" % [party_data["location"], party_data["gold"], party_data["units"].size()]

func _on_ButtonShop_pressed():
    # Simple shop: buy one item if enough gold
    var item = party_data["inventory"][0]
    if party_data["gold"] >= item["price"]:
        party_data["gold"] -= item["price"]
        print("Bought %s" % item["name"])
        _save_party_state()
        _refresh_label()
    else:
        print("Not enough gold for %s" % item["name"])

func _on_ButtonRecruit_pressed():
    # Simple recruit: add a basic unit if enough gold
    var recruit_cost = 30
    if party_data["gold"] >= recruit_cost:
        party_data["gold"] -= recruit_cost
        var new_unit = {
            "id": "unit_%d" % (party_data["units"].size() + 1),
            "name": "Militia",
            "type": "infantry",
            "level": 1,
            "hp": 85,
            "attack": 13,
            "defense": 6,
            "speed": 5
        }
        party_data["units"].append(new_unit)
        print("Recruit success: %s" % new_unit["name"])
        _save_party_state()
        _refresh_label()
    else:
        print("Not enough gold to recruit")

func _on_ButtonBack_pressed():
    # Return to overworld scene stub
    var over = load("res://scenes/overworld.tscn")
    if over:
        var inst = over.instantiate()
        get_tree().root.add_child(inst)
        queue_free()
