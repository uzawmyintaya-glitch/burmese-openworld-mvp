extends Node2D

onready var player = $Arena/PlayerUnit
onready var enemy = $Arena/EnemyUnit
onready var player_hp_label = $CanvasLayer/PlayerHPLabel
onready var enemy_hp_label = $CanvasLayer/EnemyHPLabel

func _ready():
    # attach unit scripts
    if not player.get_script():
        player.set_script(load("res://scripts/unit.gd"))
    if not enemy.get_script():
        enemy.set_script(load("res://scripts/unit.gd"))
    # expose enemy to enemy script as target if needed
    enemy.target = player
    # initialize labels
    _update_labels()

func _process(delta):
    _update_labels()
    _check_battle_end()

func _input(event):
    # simple touch/mouse control: tap left/right side to move player
    if event is InputEventScreenTouch and event.pressed:
        var x = event.position.x
        var screen_center = get_viewport().size.x / 2
        if x < screen_center:
            player.global_position.x -= 24
        else:
            player.global_position.x += 24
    elif event is InputEventMouseButton and event.pressed:
        var pos = event.position
        # if clicked on enemy, attack
        if enemy and enemy.get_global_rect().has_point(pos):
            if player.has_method("attack"):
                player.attack(enemy)
            else:
                # implement a quick attack directly
                enemy.take_damage(15)

func _update_labels():
    if player and player.has_method("is_alive"):
        var ph = player.hp if player.has_variable("hp") else 0
        player_hp_label.text = "Player HP: %d/%d" % [ph, player.max_hp]
    if enemy and enemy.has_method("is_alive"):
        var eh = enemy.hp if enemy.has_variable("hp") else 0
        enemy_hp_label.text = "Enemy HP: %d/%d" % [eh, enemy.max_hp]

func _check_battle_end():
    if not player or not player.is_inside_tree() or (player.has_method("is_alive") and not player.is_alive()):
        _on_battle_lost()
    elif not enemy or not enemy.is_inside_tree() or (enemy.has_method("is_alive") and not enemy.is_alive()):
        _on_battle_won()

func _on_battle_won():
    get_tree().paused = true
    var dialog = Label.new()
    dialog.text = "You won!"
    dialog.rect_position = get_viewport().size / 2 - Vector2(40, 10)
    add_child(dialog)

func _on_battle_lost():
    get_tree().paused = true
    var dialog = Label.new()
    dialog.text = "You lost!"
    dialog.rect_position = get_viewport().size / 2 - Vector2(40, 10)
    add_child(dialog)
