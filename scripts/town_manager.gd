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

var shop_items = [
    {"id": "item_1", "name": "Rice", "type": "consumable", "price": 10},
    {"id": "item_2", "name": "Steel Sword", "type": "weapon", "price": 35},
    {"id": "item_3", "name": "Herbal Salve", "type": "consumable", "price": 18}
]

var recruit_pool = [
    {"name": "Militia", "type": "infantry", "cost": 30, "hp": 85, "attack": 13, "defense": 6, "speed": 5},
    {"name": "Marksman", "type": "archer", "cost": 40, "hp": 75, "attack": 17, "defense": 4, "speed": 8},
    {"name": "Horseman", "type": "cavalry", "cost": 55, "hp": 95, "attack": 19, "defense": 7, "speed": 9}
]

var save_handler = null

func _ready():
    if not save_handler:
        save_handler = preload("res://scripts/beta_save_handler.gd").new()
        add_child(save_handler)
    _load_party_state()
    _refresh_label()
    _show_shop_status()

func _load_party_state():
    var state = save_handler.load_state()
    if state.size() > 0:
        if state.has("units"):
            party_data["units"] = state["units"]
        if state.has("gold"):
            party_data["gold"] = state["gold"]
        if state.has("location"):
            party_data["location"] = state["location"]
        if state.has("inventory"):
            party_data["inventory"] = state["inventory"]

func _save_party_state():
    if save_handler:
        save_handler.save_state(party_data)

func _refresh_label():
    var title = get_node_or_null("UI/LabelTitle")
    if title:
        title.text = "Town - %s | Gold: %d | Party: %d" % [party_data["location"], party_data["gold"], party_data["units"].size()]
    _show_shop_status()

func _show_shop_status(message: String = "") -> void:
    var status = get_node_or_null("UI/LabelStatus")
    if status == null:
        return
    if message == "":
        var shop_names = []
        for item in shop_items:
            shop_names.append("%s (%d)" % [item["name"], item["price"]])
        status.text = "Shop: %s" % ", ".join(shop_names)
    else:
        status.text = message

func _on_ButtonShop_pressed():
    # Simple shop: buy first item if enough gold
    var item = shop_items[0]
    if party_data["gold"] >= item["price"]:
        party_data["gold"] -= item["price"]
        party_data["inventory"].append(item)
        _save_party_state()
        _refresh_label()
        _show_shop_status("Bought %s for %d gold." % [item["name"], item["price"]])
    else:
        _show_shop_status("Not enough gold for %s." % item["name"])

func _on_ButtonRecruit_pressed():
    # Recruit first available unit in pool if enough gold
    for unit in recruit_pool:
        if party_data["gold"] >= unit["cost"]:
            party_data["gold"] -= unit["cost"]
            var new_unit = {
                "id": "unit_%d" % (party_data["units"].size() + 1),
                "name": unit["name"],
                "type": unit["type"],
                "level": 1,
                "hp": unit["hp"],
                "attack": unit["attack"],
                "defense": unit["defense"],
                "speed": unit["speed"]
            }
            party_data["units"].append(new_unit)
            _save_party_state()
            _refresh_label()
            _show_shop_status("Recruited %s for %d gold." % [unit["name"], unit["cost"]])
            return
    _show_shop_status("Not enough gold for any recruit.")

func _on_ButtonBack_pressed():
    # Return to overworld scene stub
    var over = load("res://scenes/overworld.tscn")
    if over:
        var inst = over.instantiate()
        get_tree().root.add_child(inst)
        queue_free()
