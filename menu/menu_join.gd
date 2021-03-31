extends VBoxContainer

var joining_key := ""

func set_label(text: String):
	$'Label'.text=text
	set_button_visibility(true)

func set_button_visibility(vis: bool):
	$'Button'.visible=vis

func update_servers(list):
	if visible and $'Button'.visible:
		for s in list:
			if s["key"]==joining_key:
				if !s["gameinprogress"] and s["players"]<9:
					get_parent().request_join_server(joining_key)
				return
		get_parent().open_roomlist()


func _on_Button_pressed():
	get_parent().open_roomlist()
