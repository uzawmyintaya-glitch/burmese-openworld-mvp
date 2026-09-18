extends Node2D

# Party data model for Beta
# Stores leader + roster + gold + location + save metadata

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

func _ready():
    pass

func get_party_data() -> Dictionary:
    return party_data

func set_party_data(data: Dictionary) -> void:
    party_data = data
