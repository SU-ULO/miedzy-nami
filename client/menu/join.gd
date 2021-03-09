extends VBoxContainer



func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func clean_list():
	for c in $'ServersList'.get_children():
		c.queue_free()

func update_servers(list: Array):
	clean_list()
	var serverlist = $'ServersList'
	for s in list:
		if !(s.key is String):
			clean_list()
			return
		var bbb = load("res://gui/podsceny/MenuButton.tscn").instance()
		var b = bbb.get_node("TextureButton")
		var l = b.get_node("Label")
		b.name=s.key
		l.text=s.key
		b.connect("pressed", get_parent(), 'join_server', [s.key])
		serverlist.add_child(bbb)

func _on_Refresh_pressed():
	get_parent().refresh_servers()


func _on_Exit_pressed():
	get_parent().request_end()
