extends VBoxContainer

signal button_hover_enter(button)
signal button_hover_exit(button)

func _ready():
	pass # Replace with function body.

func clean_list():
	for c in $'lists/ver/ServersListVeryfied/VBoxContainer'.get_children():
		c.queue_free()
	for c in $'lists/rest/ServersList/VBoxContainer'.get_children():
		c.queue_free()

func update_servers(list: Array):
	clean_list()
	var serverlist_veryfied = $'lists/ver/ServersListVeryfied/VBoxContainer'
	var serverlist_rest = $'lists/rest/ServersList/VBoxContainer'
	for s in list:
		if !(s.key is String):
			clean_list()
			return
		var bbb = load("res://gui/podsceny/MenuButton.tscn").instance()
		var b = bbb.get_node("TextureButton")
		b.connect("mouse_entered", self, "hover_enter", [b])
		b.connect("mouse_exited", self, "hover_exit", [b])
		var l = b.get_node("Label")
		b.get_node("code").text = s.key
		b.name = s.key
		l.text = s.name+' '+String(s.players)+'/10 '+("gra trwa" if s.gameinprogress else "")
		b.connect("pressed", get_parent(), 'request_join_server', [s.key])
		if(s.has('verified') and s['verified']):
			pass #stuff to do with verified servers
			serverlist_veryfied.add_child(bbb)
		else:
			serverlist_rest.add_child(bbb)

func _on_Refresh_pressed():
	get_parent().request_refresh_servers()

func _on_Exit_pressed():
	get_parent().request_end()

func _on_TextureButton_pressed():
	get_parent().request_join_server($JoinedKey/JoinedKeyField.text.to_upper())

func _on_Button_pressed(): #super invisible button for mobile fix
	$JoinedKey/JoinedKeyField.grab_focus()

func hover_enter(button):
	button.get_node("Label").visible = 0
	button.get_node("code").visible = 1

func hover_exit(button):
	button.get_node("Label").visible = 1
	button.get_node("code").visible = 0
