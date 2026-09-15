# Main scene script: handle Start button and synth music

extends Node2D

onready var music_node = preload("res://scripts/music_synth.gd").new()

func _ready():
    add_child(music_node)

func _on_ButtonStart_pressed():
    # Load overworld
    var overworld = load("res://scenes/overworld.tscn").instantiate()
    get_tree().root.add_child(overworld)
    music_node.start_music()
