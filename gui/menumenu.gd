extends Control

var kickbutton = preload("res://gui/podsceny/wide-button.tscn")

func onopen():
	if Globals.start.network.own_id == 0:
		$main/Label.visible = true
		var x = 0
		for i in Globals.start.network.player_characters.keys():
			if i!=0:
				var xx = kickbutton.instance()
				xx.name = str(i)
				xx.get_node("Label").text = Globals.start.network.player_characters[i].username
				xx.connect("pressed", self, "kick_him", [str(i)])
				if x < 5:
					$main/kick1.add_child(xx)
				else:
					$main/kick2.add_child(xx)
				x+=1
func _close():
	Globals.save_file("user://us.settings", Globals.start.menu.usersettings)
	get_parent().get_parent().replace_on_canvas(self)

func _exit():
	get_tree().get_root().get_node("Start").leave_room()

func kick_him(who):
	Globals.start.network.kick(int(who))
	if $main/kick1.has_node(who):
		$main/kick1.get_node(who).queue_free()
	if $main/kick2.has_node(who):
		$main/kick2.get_node(who).queue_free()


func _on_keybinds_pressed():
	get_node("main").visible = !get_node("main").visible
	get_node("keybinds").visible = !get_node("keybinds").visible
