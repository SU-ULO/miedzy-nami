extends Node2D

var sabotageOn = true
var gui

func _ready():
	add_to_group("entities")
	add_to_group("interactable")

func Interact(_body):
	gui = load("res://gui/electrical.tscn").instance()
	get_owner().get_node("CanvasLayer").add_child(gui)

func EndInteraction(_body):
	get_owner().get_node("CanvasLayer").remove_child(gui)

