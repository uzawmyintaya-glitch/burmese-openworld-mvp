extends Node2D

# Battle manager (polished)
# Responsibilities:
# - Attach unit scripts
# - Provide mobile-friendly UI (attack/special buttons)
# - Show health bars and damage popups
# - Play SFX via audio_sfx

onready var player = $Arena/PlayerUnit
onready var enemy = $Arena/EnemyUnit
onready var player_hp_label = $CanvasLayer/PlayerHPLabel
onready var enemy_hp_label = $CanvasLayer/EnemyHPLabel
onready var ui_layer = $CanvasLayer

var audio_sfx
var popups = []

func _ready():
    # attach improved unit scripts
    if not player.get_script():
        player.set_script(load("res://scripts/unit.gd"))
    if not enemy.get_script():
        enemy.set_script(load("res://scripts/unit.gd"))
    # give enemy target
    enemy.target = player
    # connect signals
    player.connect("damaged", Callable(self, "_on_unit_damaged"))
    enemy.connect("damaged", Callable(self, "_on_unit_damaged"))
    player.connect("died", Callable(self, "_on_player_died"))
    enemy.connect("died", Callable(self, "_on_enemy_died"))
    # create UI buttons
    _create_ui()
    # setup audio synth helper
    audio_sfx = preload("res://scripts/audio_sfx.gd").new()
    add_child(audio_sfx)

func _create_ui():
    # Attack button
    var attack_btn = Button.new()
    attack_btn.text = "Attack"
    attack_btn.rect_size = Vector2(110, 48)
    attack_btn.rect_position = Vector2(12, get_viewport().size.y - 60)
    ui_layer.add_child(attack_btn)
    attack_btn.pressed.connect(func(): _on_attack_pressed())

    # Special button (placeholder)
    var special_btn = Button.new()
    special_btn.text = "Special"
    special_btn.rect_size = Vector2(110, 48)
    special_btn.rect_position = Vector2(136, get_viewport().size.y - 60)
    ui_layer.add_child(special_btn)
    special_btn.pressed.connect(func(): _on_special_pressed())

    # Health bars (simple Labels updated)
    _update_labels()

func _on_attack_pressed():
    if player and player.has_method("attack"):
        player.attack(enemy)
    else:
        # fallback: direct damage
        if enemy and enemy.has_method("take_damage"):
            enemy.take_damage(20)
    audio_sfx.play_hit()

func _on_special_pressed():
    # placeholder special: deal aoe small damage
    if enemy and enemy.has_method("take_damage"):
        enemy.take_damage(28)
    audio_sfx.play_special()

func _on_unit_damaged(amount, pos):
    _spawn_popup(str(amount), pos)
    audio_sfx.play_hit()

func _spawn_popup(text, world_pos):
    var lbl = Label.new()
    lbl.text = text
    lbl.modulate = Color(1, 0.7, 0.2, 1)
    ui_layer.add_child(lbl)
    # convert world to canvas coords
    var canvas_pos = get_viewport().get_camera_2d().unproject_position(world_pos) if get_viewport().get_camera_2d() else world_pos
    lbl.rect_position = canvas_pos
    var life = {"node": lbl, "vel": Vector2(0, -40), "time": 0.0}
    popups.append(life)

func _process(delta):
    _update_labels()
    _update_popups(delta)
    _check_battle_end()

func _update_labels():
    if player and player.is_inside_tree():
        var ph = player.hp if player.has_variable("hp") else 0
        player_hp_label.text = "Player HP: %d/%d" % [ph, player.max_hp]
    if enemy and enemy.is_inside_tree():
        var eh = enemy.hp if enemy.has_variable("hp") else 0
        enemy_hp_label.text = "Enemy HP: %d/%d" % [eh, enemy.max_hp]

func _update_popups(delta):
    for p in popups.duplicate():
        p.time += delta
        p.node.rect_position += p.vel * delta
        p.node.modulate.a = max(0.0, 1.0 - p.time)
        if p.time > 1.0:
            p.node.queue_free()
            popups.erase(p)

func _check_battle_end():
    if not player or not player.is_inside_tree() or (player.has_method("is_alive") and not player.is_alive()):
        _on_battle_lost()
    elif not enemy or not enemy.is_inside_tree() or (enemy.has_method("is_alive") and not enemy.is_alive()):
        _on_battle_won()

func _on_battle_won():
    get_tree().paused = true
    var dialog = Label.new()
    dialog.text = "You won!"
    dialog.rect_position = get_viewport().size / 2 - Vector2(48, 12)
    ui_layer.add_child(dialog)

func _on_battle_lost():
    get_tree().paused = true
    var dialog = Label.new()
    dialog.text = "You lost!"
    dialog.rect_position = get_viewport().size / 2 - Vector2(48, 12)
    ui_layer.add_child(dialog)

func _on_player_died():
    _on_battle_lost()

func _on_enemy_died():
    _on_battle_won()
