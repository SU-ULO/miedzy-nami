extends Node

class_name Client

var remote_players: Dictionary = {}

func _ready():
	var menu = preload('res://scenes/menu/menu.tscn').instance()
	menu.name='menu'
	add_child(menu)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
