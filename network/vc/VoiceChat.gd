extends Node

class_name VoiceChat

func _input(event):
	if event.is_action_pressed("vc_push_to_talk"):
		print("vc push")
	elif event.is_action_released("vc_push_to_talk"):
		print("vc release")
