extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_settings()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_settings():
	var settings = get_parent().usersettings
	$'OptionsContainer/MatchmakingURL'.text=settings["signaling_url"]

func set_settings():
	var settings = get_parent().usersettings
	settings["signaling_url"]=$'OptionsContainer/MatchmakingURL'.text

func _on_OptionsAcceptButton_pressed():
	set_settings()
	get_parent().open_main()
