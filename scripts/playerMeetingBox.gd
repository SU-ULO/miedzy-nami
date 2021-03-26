extends Control

onready var vote = load("res://gui/meeting/Vote.tscn")

var id
var color setget set_color
var totalvotes = 0
var confirm:bool = false

signal chosen(id)

func _on_Control_pressed():
	get_parent().get_owner().toggle_confirm_buttons(id)

func set_color(col):
	color = Color(col)
	get_node("Button/C").get_stylebox("panel", "").bg_color = color

func set_vote(col):
	var path
	if totalvotes < 5: path = "Button/V/H1"
	else: path = "Button/V/H2"
	totalvotes += 1
	var instance = vote.instance()
	instance.get_stylebox("panel", "").bg_color = Color(col)
	get_node(path).add_child(instance)

func set_vote_visibility(state):
	get_node("Button/V/H1").visible = state
	get_node("Button/V/H2").visible = state

func set_voted():
	get_node("Button/Voted").visible = true

func _on_R_pressed():
	get_parent().get_owner().toggle_confirm_buttons()

func _on_G_pressed():
	emit_signal("chosen", id)
	get_parent().get_owner().toggle_confirm_buttons()
