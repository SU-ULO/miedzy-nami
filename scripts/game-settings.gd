extends Control

func _ready():
	for i in $"ScrollContainer/VBoxContainer".get_children():
		if "div" in i:
			print("\"" + i.name + "\": " + str(i.default_value/i.div))
		else:
			print("\"" + i.name + "\": " + str(i.default_value))
func get_settings():
	var settings = {}
	for i in $"ScrollContainer/VBoxContainer".get_children():
		settings[i.name] = i.get_value()
	return settings
func set_settings(settings):
	for i in $"ScrollContainer/VBoxContainer".get_children():
		if i.name in settings.keys():
			i.set_value(settings[i.name])
			i.update_label()
