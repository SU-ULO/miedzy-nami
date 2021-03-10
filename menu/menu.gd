extends CanvasLayer

var usersettings: Dictionary = {
	"signaling_url": 'wss://gaming.rakbook.pl/miedzy-nami/signaling',
	"username": ""
}

signal request_start_client()
signal request_start_server()
signal request_end()
signal request_refresh_servers()
signal request_join_server(key)

func _ready():
	pass

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
	$background.visible = true

func open_main():
	close_everything()
	$'Main'.visible=true
	$background.visible = true

func open_join():
	close_everything()
	$'Join'.visible=true
	$background.visible = true

func open_joining():
	close_everything()
	$'Joining'.visible=true
	$background.visible = true

func request_join_server(key: String):
	open_joining()
	emit_signal("request_join_server", key)

func request_refresh_servers():
	emit_signal("request_refresh_servers")

func update_servers(list: Array):
	$'Join'.update_servers(list)

func end():
	open_main()

func request_end():
	emit_signal("request_end")

func _on_OptionsButton_pressed():
	open_options()

func _on_StartServerButton_pressed():
	pass

func _on_StartClientButton_pressed():
	usersettings.username = $'Main/Username'.text
	if usersettings.username.length()>0:
		emit_signal("request_start_client")
