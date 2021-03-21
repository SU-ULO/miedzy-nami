extends Control

var settings = {}

func _ready():
	pass
func get_settings():
	for i in $"ScrollContainer/VBoxContainer".get_children():
		settings[i.name] = i.get_value()
	return settings
