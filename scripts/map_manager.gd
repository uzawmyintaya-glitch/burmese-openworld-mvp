# Overworld manager (stub) - simple scene switching
# Attach to root Overworld node

extends Node2D

func _ready():
    pass

func open_town(town_name: String):
    print("Open town: %s" % town_name)
    # TODO: load town scene and manage party/shop

func start_battle():
    print("Start battle (stub)")
    # TODO: switch to battle scene
