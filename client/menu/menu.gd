extends CanvasLayer


var usersettings: Dictionary = {
	"signaling_url": 'wss://gaming.rakbook.pl/miedzy-nami/signaling',
	"username": ""
}

signal start()
signal end()
signal refresh_servers()
signal join_server(key)

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func close_everything():
	for n in get_children():
		n.visible=false

func open_logging_in():
	close_everything()
	$'LoggingIn'.visible=true

func open_options():
	var optionsnode=$"Options"
	optionsnode.get_settings()
	close_everything()
	optionsnode.visible=true

func open_main():
	close_everything()
	$'Main'.visible=true

func open_join():
	close_everything()
	$'Join'.visible=true

func open_joining():
	close_everything()
	$'Joining'.visible=true

func join_server(key: String):
	open_joining()
	emit_signal("join_server", key)

func refresh_servers():
	emit_signal("refresh_servers")

func update_servers(list: Array):
	$'Join'.update_servers(list)

func _on_StartButton_pressed():
	usersettings.username = $'Main/Username'.text
	if usersettings.username.length()>0:
		emit_signal("start")

func request_end():
	emit_signal("end")

func end():
	open_main()

func _on_OptionsButton_pressed():
	open_options()
