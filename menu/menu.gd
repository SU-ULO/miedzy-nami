extends CanvasLayer

var usersettings: Dictionary = {
	"signaling_url": 'wss://gaming.rakbook.pl/miedzy-nami/signaling',
	"username": ""
}

var serversettings: Dictionary = {
	"hidden": false,
	"name": "nazwa"
}

signal request_start_client()
signal request_start_server(options)
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
	$background.visible = true

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

func open_roomlist():
	close_everything()
	$RoomList.visible=true
	$background.visible = true

func joining_label(text: String):
	$'Joining'.set_label(text)

func open_joining():
	close_everything()
	$'Joining'.set_label("łączenie...")
	$'Joining'.set_button_visibility(false)
	$'Joining'.visible=true
	$background.visible = true

func open_create_room():
	close_everything()
	$Create.visible=true
	$background.visible=true

func request_start_server():
	open_joining()
	emit_signal("request_start_server", serversettings)

func request_join_server(key: String):
	$'Joining'.joining_key=""
	open_joining()
	$'Joining'.joining_key=key
	emit_signal("request_join_server", key)

func request_refresh_servers():
	emit_signal("request_refresh_servers")

func update_servers(list: Array):
	$'RoomList'.update_servers(list)
	$'Joining'.update_servers(list)

func end():
	open_main()

func request_end():
	emit_signal("request_end")

func _on_OptionsButton_pressed():
	open_options()

func _on_StartServerButton_pressed():
	usersettings.username = $'Main/Username'.text
	if usersettings.username.length()>0:
		open_create_room()

func _on_StartClientButton_pressed():
	open_logging_in()
	usersettings.username = $'Main/Username'.text
	if usersettings.username.length()>0:
		emit_signal("request_start_client")
