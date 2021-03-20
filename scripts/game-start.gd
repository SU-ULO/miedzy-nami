extends StaticBody2D

var loadingscreen = preload("res://gui/loadingscreen.tscn")
var x
var heh

func _ready():
	add_to_group("entities")
	add_to_group("interactable")
	
func Interact(body):
	heh = body
	x = loadingscreen.instance()
	body.get_node("CanvasLayer/playerGUI").visible = false
	body.get_parent().get_parent().get_parent().get_node("CanvasLayer").add_child(x)
	#some starting magick in networking
	x.connect("finish", self, "letsgo")
	body.currentInteraction = self
	return false


func EndInteraction(body):
	pass

func letsgo():
	x.disconnect("finish", self, "letsgo")
	x.queue_free()
	heh.get_node("CanvasLayer/playerGUI").visible = true
	heh.currentInteraction = null
