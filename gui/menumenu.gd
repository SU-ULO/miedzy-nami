extends Control

func _close():
	#get_parent().player.change_voice_method(get_voice_method()) or sth
	get_parent().get_parent().replace_on_canvas(self)

func _exit():
	get_tree().get_root().get_node("Start").leave_room()

func get_voice_method():
	return $"voice-chat".get_value() # 0 is push to talk, 1 is open mic
