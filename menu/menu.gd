extends CanvasLayer

var usersettings: Dictionary = {
	"signaling_url": 'wss://miedzy-nami.rakbook.pl/signaling',
	"username": "",
	"vc-mode": 0
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

func _init():
	var us = Globals.read_file("user://us.settings")
	if us and us is Dictionary and us.has("signaling_url") and us.has("username") and us.has("vc-mode"):
		usersettings = us
	var ss = Globals.read_file("user://ss.settings")
	if ss and ss is Dictionary and ss.has("hidden") and ss.has("name"):
		serversettings = ss

func _ready():
	$Main/Username.text = usersettings["username"]

func close_everything():
	for n in get_children():
		n.visible = false

func open_logging_in():
	close_everything()
	$'LoggingIn'.visible=true
	$background.visible = true

func open_options():
	close_everything()
	VoiceChat.askforstream()
	var optionsnode=$"Options"
	optionsnode.get_settings()
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

func joining_error(reason: String):
	$'Joining'.join_error(reason)

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
		Globals.save_file("user://us.settings", usersettings)
		open_create_room()
	else:
		highlight()

func _on_StartClientButton_pressed():
	usersettings.username = $'Main/Username'.text
	if usersettings.username.length()>0:
		open_logging_in()
		Globals.save_file("user://us.settings", usersettings)
		emit_signal("request_start_client")
	else:
		highlight()

func highlight():
	get_node("Main/AnimationPlayer").play("highlight")
