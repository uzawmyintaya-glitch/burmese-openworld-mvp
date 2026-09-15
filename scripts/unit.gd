extends Node2D

# Improved unit script for player and enemy units
# Features:
# - HP, attack with cooldown
# - Signals for damage and death
# - Simple approach/attack AI for enemies

signal damaged(amount, global_pos)
signal died()
signal attacked(target)

@export var max_hp: int = 100
@export var speed: int = 100
@export var attack_damage: int = 15
@export var attack_range: float = 28.0
@export var attack_cooldown: float = 0.8

var hp: int
var cooldown: float = 0.0
var is_enemy: bool = false
var target: Node2D = null

func _ready():
    hp = max_hp
    is_enemy = name.to_lower().find("enemy") >= 0

func _process(delta: float) -> void:
    if cooldown > 0.0:
        cooldown = max(0.0, cooldown - delta)
    if is_enemy:
        _enemy_ai(delta)

func _enemy_ai(delta: float) -> void:
    if not target or not target.is_inside_tree():
        var p = get_tree().get_root().get_node_or_null("/root/Battle/Arena/PlayerUnit")
        if p:
            target = p
        else:
            return
    var dir = target.global_position - global_position
    var dist = dir.length()
    if dist > attack_range:
        global_position += dir.normalized() * speed * delta
    else:
        if cooldown <= 0.0:
            attack(target)

func attack(target_node: Node2D) -> void:
    if not target_node:
        return
    cooldown = attack_cooldown
    emit_signal("attacked", target_node)
    # Apply damage after short delay to simulate swing
    var dmg = attack_damage
    # If target has take_damage, call it
    if target_node.has_method("take_damage"):
        # use a short timer
        var t = Timer.new()
        t.one_shot = true
        t.wait_time = 0.18
        add_child(t)
        t.start()
        t.timeout.connect(func():
            if target_node and target_node.has_method("take_damage"):
                target_node.take_damage(dmg)
            t.queue_free()
        )

func take_damage(amount: int) -> void:
    hp = max(0, hp - amount)
    emit_signal("damaged", amount, global_position)
    if hp <= 0:
        die()

func die() -> void:
    emit_signal("died")
    queue_free()

func is_alive() -> bool:
    return hp > 0
