extends Control


func _ready():
	get_settings()

func get_settings():
	var settings = get_parent().usersettings
	$'OptionsContainer/MatchmakingURL'.text=settings["signaling_url"]

func set_settings():
	var settings = get_parent().usersettings
	settings["signaling_url"]=$'OptionsContainer/MatchmakingURL'.text

func _on_OptionsAcceptButton_pressed():
	set_settings()
	get_parent().open_main()
