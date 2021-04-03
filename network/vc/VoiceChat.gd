extends Node

class_name VoiceChat

var available := false

func _ready():
	if OS.has_feature('JavaScript'):
		available=true
	else:
		return
	var f := File.new()
	if f.open("res://network/vc/vc.js", File.READ) == OK:
		JavaScript.eval(f.get_as_text(), true)
		f.close()
	else:
		print("cannot open js")

func _input(event):
	if available:
		if event.is_action_pressed("vc_push_to_talk"):
			print("vc push")
		elif event.is_action_released("vc_push_to_talk"):
			print("vc release")
