extends Node

func _ready():
	if(OS.has_feature("Server") || "--server" in OS.get_cmdline_args()):
		print("Running as server")
	else:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/menu/menu.tscn")
