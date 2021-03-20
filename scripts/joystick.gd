extends Node2D

var velocity = Vector2(0.0, 0.0)
onready var dot = get_node("Dot")
onready var max_radius = 170

var pressed:bool = false
var vec = Vector2(0, 0)

func _process(_delta):
	if pressed:
		dot.position = get_local_mouse_position().clamped(max_radius)
		vec = Vector2(int(round(dot.position.x/max_radius)), int(round(dot.position.y/max_radius)))
	else:
		dot.position = Vector2(0, 0)
		vec = Vector2(0, 0)
	print(vec)

func _on_Area2D_input_event(_viewport, event, _shape):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.is_pressed():
			pressed = true
			
func _input(event):
	if pressed and event is InputEventMouseButton:
		if !event.is_pressed():
			pressed = false
