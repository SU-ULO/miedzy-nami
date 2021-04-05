extends Control

func onopen():
	print(Globals.start.menu.usersettings["vc-mode"])
	$'voice-chat'.set_value(Globals.start.menu.usersettings["vc-mode"])
	$'voice-chat'.update_label()

func _close():
	Globals.start.menu.usersettings["vc-mode"]=get_voice_method()
	VoiceChat.update_vc_mode()
	get_parent().get_parent().replace_on_canvas(self)

func _exit():
	get_tree().get_root().get_node("Start").leave_room()

func get_voice_method():
	return $"voice-chat".get_value() # 0 is push to talk, 1 is open mic
