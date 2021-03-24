extends Button

var id = -1
var totalvotes = 0
onready var vote = load("res://gui/meeting/Vote.tscn")

signal chosen(id)

func _on_S_pressed():
	emit_signal("chosen", id)

func set_vote(color):
	totalvotes += 1
	var instance = vote.instance()
	instance.get_stylebox("panel", "").bg_color = Color(color)
	get_node("SH").add_child(instance)
	get_owner().toggle_confirm_buttons()
