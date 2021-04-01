extends VBoxContainer

var joining_key := ""

func set_label(text: String):
	$'Label'.text=text
	set_button_visibility(true)

func set_button_visibility(vis: bool):
	$'Button'.visible=vis

func update_servers(list):
	if joining_key!="" and visible and $'Button'.visible:
		for s in list:
			if s["key"]==joining_key:
				if s["players"]>=9:
					room_full()
				elif s["gameinprogress"]:
					game_in_progress()
				else:
					get_parent().request_join_server(joining_key)
				return
		no_server()

func no_server():
	set_label("Nie ma pokoju "+joining_key)
	joining_key=""
	set_button_visibility(true)

func room_full():
	set_label("Ten pokój jest pełny, proszę czekać...")
	set_button_visibility(true)

func game_in_progress():
	set_label("Gra trwa w tym pokoju, proszę czekać...")
	set_button_visibility(true)

func join_error(reason: String):
	if reason=="NO_SERVER":
		no_server()
	elif reason=="SERVER_FULL":
		room_full()
	elif reason=="GAME_IN_PROGRESS":
		game_in_progress()

func _on_Button_pressed():
	get_parent().open_roomlist()
