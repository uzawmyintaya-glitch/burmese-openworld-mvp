# Simple player movement script (keyboard + touch) for Godot
# Save as scripts/player.gd and attach to Player Node in overworld.tscn

extends Node2D

@export var speed: int = 120

var target_pos: Vector2 = Vector2()

func _ready():
    target_pos = position

func _process(delta):
    # Keyboard movement (arrow keys / WASD)
    var dir = Vector2.ZERO
    dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    if dir != Vector2.ZERO:
        dir = dir.normalized()
        position += dir * speed * delta
        target_pos = position
        return

    # Touch/mouse target movement
    if position.distance_to(target_pos) > 4:
        var step = (target_pos - position).normalized() * speed * delta
        if step.length() > position.distance_to(target_pos):
            position = target_pos
        else:
            position += step

func _input(event):
    if event is InputEventScreenTouch and event.pressed:
        target_pos = event.position
    elif event is InputEventMouseButton and event.pressed:
        target_pos = event.position
