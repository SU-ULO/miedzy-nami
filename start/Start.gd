extends Node

var run_as_server: bool = false #for debugginig purposes

func _ready():
	if(OS.has_feature("Server") || "--server" in OS.get_cmdline_args()) || run_as_server:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://server/server.tscn")
	else:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://client/client.tscn")
