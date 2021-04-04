extends Control


func _ready():
	get_settings()

func get_settings():
	var settings = get_parent().usersettings
	$OptionsContainer/MatchmakingURL.text=settings["signaling_url"]

func set_settings():
	var settings = get_parent().usersettings
	settings["signaling_url"]=$OptionsContainer/MatchmakingURL.text
	Globals.save_file("user://us.settings", settings)

func _on_OptionsAcceptButton_pressed():
	set_settings()
	Globals.start.vc.audiotest(false)
	get_parent().open_main()


func _on_AudioTest_pressed():
	Globals.start.vc.audiotest()
