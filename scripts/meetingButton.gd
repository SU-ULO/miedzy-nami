extends Control

onready var vote = load("res://gui/meeting/Vote.tscn")

var id
var color setget set_color
var totalvotes = 0

signal chosen(id)

func _on_Control_pressed():
	emit_signal("chosen", id)

func set_color(color):
	get_node("C").get_stylebox("panel", "").bg_color = Color(color)

func set_vote(color):
	var path
	if totalvotes < 6: path = "Button/V/H1"
	else: path = "Button/V/H2"
	totalvotes += 1
	var instance = vote.instance()
	instance.get_stylebox("panel", "").bg_color = Color(color)
	get_node(path).add_child(instance)

func set_voted():
	get_node("Button/Voted").visible = true
