extends TextureButton

onready var player = get_owner()

func _close():
	player.get_node("GUI").clear_canvas()
	player.ui_canceled()
