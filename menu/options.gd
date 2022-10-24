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
	get_parent().open_main()

func toggle_borderless():
	var temp = OS.get_current_screen()
	OS.window_size = OS.get_screen_size()
	OS.window_position = Vector2(0,0)
	OS.set_current_screen(temp)
	OS.window_borderless = !OS.window_borderless
