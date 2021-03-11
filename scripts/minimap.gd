extends Control

var res = preload("res://gui/playericon.tscn")
var map_center
var icon = null
var player = null

func _ready():
	self.add_child(res.instance())
	icon = self.get_child(0)
	map_center = get_parent().get_node("Position2D").position


func _process(_delta):
	if player != null:
		icon.position = map_center + player.position/2
