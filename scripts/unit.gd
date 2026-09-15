extends Node2D

# Improved unit script with animation frame-sync support

signal damaged(amount, global_pos)
signal died()
signal attacked(target)

@export var max_hp: int = 100
@export var speed: int = 100
@export var attack_damage: int = 15
@export var attack_range: float = 28.0
@export var attack_cooldown: float = 0.8

# animation sync frame index (0-based). If AnimatedSprite2D present and has an 'attack' animation,
# the damage will be applied when the animation reaches this frame.
@export var attack_frame_index: int = 2

var hp: int
var cooldown: float = 0.0
var is_enemy: bool = false
var target: Node2D = null

# animation sync state
var _attack_animating: bool = false
var _attack_target: Node = null
var _anim_node: Node = null

func _ready():
    hp = max_hp
    is_enemy = name.to_lower().find("enemy") >= 0
    # look for an AnimatedSprite2D child (optional)
    _anim_node = get_node_or_null("AnimatedSprite2D")
    if not _anim_node:
        _anim_node = get_node_or_null("AnimatedSprite")

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

    # If there is an AnimatedSprite2D child and it has an 'attack' animation, use frame sync
    if _anim_node and _anim_node.has_method("play"):
        # try to play an animation named 'attack' if present
        # wrap in a safe call in case the resource doesn't have the animation
        if _anim_node.has_method("animation_names") and "attack" in _anim_node.animation_names():
            # connect to frame change signal to apply damage at the specified frame
            # disconnect existing if needed
            if _anim_node.frame_changed.is_connected(Callable(self, "_on_anim_frame_changed")):
                _anim_node.frame_changed.disconnect(Callable(self, "_on_anim_frame_changed"))
            _anim_node.frame_changed.connect(Callable(self, "_on_anim_frame_changed"))
            _attack_animating = true
            _attack_target = target_node
            _anim_node.play("attack")
            return
        else:
            # try to play even if no named animations (best-effort)
            _anim_node.play()
    # fallback: timed delay for damage (previous behavior)
    var t = Timer.new()
    t.one_shot = true
    t.wait_time = 0.18
    add_child(t)
    t.start()
    t.timeout.connect(func():
        if target_node and target_node.has_method("take_damage"):
            target_node.take_damage(attack_damage)
        t.queue_free()
    )

func _on_anim_frame_changed(frame: int) -> void:
    if not _attack_animating or not _attack_target:
        return
    if frame == attack_frame_index:
        if _attack_target and _attack_target.has_method("take_damage"):
            _attack_target.take_damage(attack_damage)
        # cleanup: disconnect and reset
        if _anim_node and _anim_node.frame_changed.is_connected(Callable(self, "_on_anim_frame_changed")):
            _anim_node.frame_changed.disconnect(Callable(self, "_on_anim_frame_changed"))
        _attack_animating = false
        _attack_target = null

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
