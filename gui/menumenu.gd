extends Control

func _close():
	Globals.start.menu.usersettings["vc-mode"]=get_voice_method()
	Globals.start.vc.update_vc_mode()
	get_parent().get_parent().replace_on_canvas(self)

func _exit():
	get_tree().get_root().get_node("Start").leave_room()

func get_voice_method():
	return $"voice-chat".get_value() # 0 is push to talk, 1 is open mic
