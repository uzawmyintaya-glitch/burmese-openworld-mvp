extends Node2D

# Battle manager with multiple enemy support, hit VFX (particles), screen shake, audio manager and LOD for particles

onready var arena = $Arena
onready var player = $Arena/PlayerUnit
onready var template = $Arena/SpawnTemplate
onready var particles = $Arena/Particles
onready var ui_layer = $CanvasLayer
onready var player_hp_label = $CanvasLayer/PlayerHPLabel
onready var enemy_hp_label = $CanvasLayer/EnemyHPLabel

@export var enemy_count: int = 3
@export var formation_spacing: float = 40.0

var enemies = []
var audio_mgr
var popups = []
var shake_time = 0.0
var shake_strength = 0.0

var enemy_textures = [
    "res://assets/enemy1.svg",
    "res://assets/enemy2.svg",
    "res://assets/enemy3.svg"
]

func _ready():
    # attach improved unit scripts to player
    if not player.get_script():
        player.set_script(load("res://scripts/unit.gd"))
    # hide template
    template.visible = false
    # particle LOD based on processor count (simple heuristic)
    var proc = 1
    if OS.has_method("get_processor_count"):
        proc = OS.get_processor_count()
    if proc <= 2:
        particles.amount = 8
    elif proc <= 4:
        particles.amount = 16
    else:
        particles.amount = 28

    # spawn enemies in formation
    _spawn_enemies(enemy_count)
    # connect signals for dynamic enemies
    for e in enemies:
        if e:
            e.connect("damaged", Callable(self, "_on_unit_damaged"))
            e.connect("died", Callable(self, "_on_enemy_died"))
    player.connect("damaged", Callable(self, "_on_unit_damaged"))
    player.connect("died", Callable(self, "_on_player_died"))

    # audio manager
    audio_mgr = preload("res://scripts/audio_manager.gd").new()
    add_child(audio_mgr)
    audio_mgr.play_music()

    # create UI
    _create_ui()

func _spawn_enemies(count: int) -> void:
    enemies.clear()
    var base_pos = template.position
    var half = (count - 1) / 2.0
    for i in range(count):
        var inst = template.duplicate()
        inst.name = "EnemyUnit_%d" % i
        inst.visible = true
        inst.position = base_pos + Vector2((i - half) * formation_spacing, 0)
        arena.add_child(inst)
        # attach unit script
        if not inst.get_script():
            inst.set_script(load("res://scripts/unit.gd"))
        inst.is_enemy = true
        inst.target = player
        # swap sprite texture by variant if present
        var spr = inst.get_node_or_null("Sprite")
        if spr:
            var tex_path = enemy_textures[i % enemy_textures.size()]
            if ResourceLoader.exists(tex_path):
                spr.texture = load(tex_path)
        enemies.append(inst)

func _create_ui():
    var attack_btn = Button.new()
    attack_btn.text = "Attack"
    attack_btn.rect_size = Vector2(110, 48)
    attack_btn.rect_position = Vector2(12, get_viewport().size.y - 60)
    ui_layer.add_child(attack_btn)
    attack_btn.pressed.connect(func(): _on_attack_pressed())

    var special_btn = Button.new()
    special_btn.text = "Special"
    special_btn.rect_size = Vector2(110, 48)
    special_btn.rect_position = Vector2(136, get_viewport().size.y - 60)
    ui_layer.add_child(special_btn)
    special_btn.pressed.connect(func(): _on_special_pressed())

    _update_labels()

func _on_attack_pressed():
    # basic attack: nearest enemy
    var target = _nearest_enemy_to(player.global_position)
    if target:
        if player.has_method("attack"):
            player.attack(target)
        else:
            target.take_damage(20)
        audio_mgr.play_hit()

func _on_special_pressed():
    # AoE around player
    for e in enemies.duplicate():
        if e and e.is_inside_tree() and e.global_position.distance_to(player.global_position) < 80:
            e.take_damage(30)
    audio_mgr.play_special()

func _on_unit_damaged(amount, pos):
    _spawn_popup(str(amount), pos)
    _emit_hit_vfx(pos)
    _screen_shake(0.18, 8)
    audio_mgr.play_hit()

func _spawn_popup(text, world_pos):
    var lbl = Label.new()
    lbl.text = text
    lbl.modulate = Color(1, 0.7, 0.2, 1)
    ui_layer.add_child(lbl)
    var cam = arena.get_node_or_null("Camera2D")
    var canvas_pos = world_pos
    if cam:
        canvas_pos = cam.get_camera_screen_center() + (world_pos - cam.global_position)
    lbl.rect_position = canvas_pos
    var life = {"node": lbl, "vel": Vector2(0, -40), "time": 0.0}
    popups.append(life)

func _emit_hit_vfx(world_pos):
    # spawn simple particles at position
    particles.global_position = world_pos
    particles.one_shot = true
    particles.emitting = true

func _screen_shake(time_sec: float, strength: float) -> void:
    shake_time = time_sec
    shake_strength = strength

func _process(delta):
    _update_popups(delta)
    _update_labels()
    _update_shake(delta)
    _check_battle_end()

func _update_popups(delta):
    for p in popups.duplicate():
        p.time += delta
        p.node.rect_position += p.vel * delta
        p.node.modulate.a = max(0.0, 1.0 - p.time)
        if p.time > 1.0:
            p.node.queue_free()
            popups.erase(p)

func _update_labels():
    var alive = 0
    for e in enemies:
        if e and e.is_inside_tree():
            alive += 1
    enemy_hp_label.text = "Enemies: %d" % alive
    if player and player.is_inside_tree():
        var ph = player.hp if player.has_variable("hp") else 0
        player_hp_label.text = "Player HP: %d/%d" % [ph, player.max_hp]

func _update_shake(delta):
    if shake_time > 0:
        shake_time = max(0.0, shake_time - delta)
        var cam = arena.get_node_or_null("Camera2D")
        if cam:
            var rx = (randf() * 2.0 - 1.0) * shake_strength
            var ry = (randf() * 2.0 - 1.0) * shake_strength
            cam.position = Vector2(rx, ry)
    else:
        var cam = arena.get_node_or_null("Camera2D")
        if cam:
            cam.position = Vector2.ZERO

func _nearest_enemy_to(pos: Vector2):
    var best = null
    var bestd = 1e9
    for e in enemies:
        if e and e.is_inside_tree():
            var d = e.global_position.distance_to(pos)
            if d < bestd:
                best = e
                bestd = d
    return best

func _on_enemy_died():
    # cleanup dead enemies list
    enemies = [e for e in enemies if e and e.is_inside_tree()]

func _on_player_died():
    get_tree().paused = true
    var dialog = Label.new()
    dialog.text = "You lost!"
    dialog.rect_position = get_viewport().size / 2 - Vector2(48, 12)
    ui_layer.add_child(dialog)

func _check_battle_end():
    var alive = 0
    for e in enemies:
        if e and e.is_inside_tree():
            alive += 1
    if alive == 0:
        _on_battle_won()

func _on_battle_won():
    get_tree().paused = true
    var dialog = Label.new()
    dialog.text = "You won!"
    dialog.rect_position = get_viewport().size / 2 - Vector2(48, 12)
    ui_layer.add_child(dialog)
