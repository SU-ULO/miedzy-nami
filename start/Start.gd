extends Node

func _ready():
	if(OS.has_feature("Server") || "--server" in OS.get_cmdline_args()):
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://server/server.tscn")
	else:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://client/client.tscn")
