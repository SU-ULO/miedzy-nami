extends Control

func _ready():
	pass
func get_settings():
	var settings = {}
	for i in $"ScrollContainer/VBoxContainer".get_children():
		settings[i.name] = i.get_value()
	return settings
func set_settings(settings):
	for i in $"ScrollContainer/VBoxContainer".get_children():
		i.set_value(settings[i.name])
		i.update_label()
