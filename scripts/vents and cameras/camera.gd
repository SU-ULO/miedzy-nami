extends Node2D

signal camera_detection(player, status)

func _ready():
	add_to_group("entities")
	add_to_group("cameras")
	pass

func _on_Area2D_body_entered(body):
	if body.is_in_group("players"):
		emit_signal("camera_detection", body, 1)

func _on_Area2D_body_exited(body):
	if body.is_in_group("players"):
		emit_signal("camera_detection", body, 0)

func detect():
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("players"):
			emit_signal("camera_detection", body, 1)
