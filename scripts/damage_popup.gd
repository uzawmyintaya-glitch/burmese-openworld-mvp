# Damage popup helper (not currently required as popups are managed in battle.gd)
# Leave as a reference for future improvements.

extends Label

var life_time := 1.0
var time := 0.0
var velocity := Vector2(0, -40)

func _process(delta: float) -> void:
    time += delta
    rect_position += velocity * delta
    modulate.a = max(0.0, 1.0 - time / life_time)
    if time >= life_time:
        queue_free()
