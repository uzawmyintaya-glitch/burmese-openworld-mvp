extends Node2D

# Simple unit script for player and enemy units
# Attach to PlayerUnit and EnemyUnit nodes in battle scene

@export var max_hp: int = 100
@export var speed: int = 80
@export var attack_damage: int = 12
@export var attack_range: int = 24
@export var attack_cooldown: float = 1.0

var hp: int
var cooldown: float = 0.0
var is_enemy: bool = false
var target: Node2D = null

func _ready():
    hp = max_hp
    # determine role by node name
    is_enemy = name.to_lower().find("enemy") >= 0

func _process(delta):
    if cooldown > 0:
        cooldown = max(0, cooldown - delta)

    if is_enemy:
        _enemy_ai(delta)

func _enemy_ai(delta):
    if not target or not target.is_inside_tree():
        # find player in parent scene tree
        var p = get_tree().get_root().get_node("/root/Battle/Arena/PlayerUnit")
        if p:
            target = p
        else:
            return
    # move toward player
    var dir = (target.global_position - global_position)
    if dir.length() > attack_range:
        global_position += dir.normalized() * speed * delta
    else:
        if cooldown <= 0:
            attack(target)

func attack(target_node: Node2D) -> void:
    if not target_node:
        return
    cooldown = attack_cooldown
    if target_node.has_method("take_damage"):
        target_node.take_damage(attack_damage)

func take_damage(amount: int) -> void:
    hp = max(0, hp - amount)
    if hp <= 0:
        die()

func die():
    queue_free()

func is_alive() -> bool:
    return hp > 0
