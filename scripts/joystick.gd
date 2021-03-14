extends Node2D

var velocity = Vector2(0.0, 0.0)
onready var dot = get_node("Dot")
onready var max_radius = 170

func _process(_delta):
	dot.position = get_local_mouse_position().clamped(max_radius)
