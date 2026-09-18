extends Node

# Encounter builder passes enemy composition to BattleManager
# This is the main Beta integration layer between overworld/travel and fights.

func build_encounter(node_name: String, difficulty: int = 1) -> Dictionary:
    var enemies = []
    var count = clamp(1 + difficulty, 1, 6)
    var enemy_types = ["infantry","archer","cavalry"]
    for i in range(count):
        var kind = enemy_types[i % enemy_types.size()]
        enemies.append({
            "id": "enemy_%d_%s" % [i, kind],
            "name": "%s Raider" % kind.capitalize(),
            "type": kind,
            "level": difficulty,
            "hp": 50 + difficulty * 12,
            "attack": 10 + difficulty * 3,
            "defense": 5 + difficulty * 2,
            "speed": 5 + difficulty
        })
    return {
        "node": node_name,
        "difficulty": difficulty,
        "enemies": enemies
    }
