extends Node

# Battle rewards + state sync.
# Applies gold rewards after battle and stores them back to beta_save.json.

var save_handler = null

func _ready():
    save_handler = preload("res://scripts/beta_save_handler.gd").new()
    add_child(save_handler)

func apply_reward(result: String, encounter_data: Dictionary = {}) -> Dictionary:
    var state = {}
    if save_handler:
        state = save_handler.load_state()
    if state.is_empty():
        state = {
            "leader": "Player",
            "gold": 120,
            "location": "TownA",
            "units": [],
            "inventory": []
        }

    var gold = int(state.get("gold", 120))
    var difficulty = int(encounter_data.get("difficulty", 1))
    var delta = 0
    if result == "victory":
        delta = 20 + (difficulty * 15)
        gold += delta
        state["location"] = "TownA"
        state["last_result"] = "victory"
    elif result == "defeat":
        delta = -10
        gold = max(0, gold + delta)
        state["location"] = "TownA"
        state["last_result"] = "defeat"
    else:
        state["last_result"] = result

    state["gold"] = gold
    if save_handler:
        save_handler.save_state(state)
    return {"gold_delta": delta, "gold_total": gold, "result": result}
