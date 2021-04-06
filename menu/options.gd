extends Control

func update_vc_mode():
	VoiceChat.update_vc_mode($'setting'.get_value())

func _ready():
	get_settings()
	$setting.connect("settingchanged", self, "update_vc_mode")

func get_settings():
	var settings = get_parent().usersettings
	$OptionsContainer/MatchmakingURL.text=settings["signaling_url"]
	$'setting'.set_value(settings["vc-mode"])
	$setting.update_label()

func set_settings():
	var settings = get_parent().usersettings
	settings["signaling_url"]=$OptionsContainer/MatchmakingURL.text
	settings["vc-mode"]=$'setting'.get_value()
	Globals.save_file("user://us.settings", settings)

func _on_OptionsAcceptButton_pressed():
	set_settings()
	VoiceChat.update_vc_mode()
	VoiceChat.audiotest(false)
	VoiceChat.setwantstospeak(false)
	get_parent().open_main()


func _on_AudioTest_pressed():
	VoiceChat.update_vc_mode()
	VoiceChat.audiotest()
