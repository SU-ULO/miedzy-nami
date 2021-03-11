extends Control

var res = preload("res://gui/playericon.tscn")
var task_icon = preload("res://gui/taskicon.tscn")
var map_center
var icon = null
var player = null

var taskList = []
var taskIcons = []

func _ready():
	self.add_child(res.instance())
	icon = self.get_child(0)
	map_center = get_parent().get_node("Position2D").position


func _process(_delta):
	if player != null:
		icon.position = map_center + player.position/2

func addTasks():
	for i in taskIcons:
		i.queue_free()
	for i in taskList:
		taskIcons.append(task_icon.instance())
		get_parent().add_child(taskIcons.back())
		taskIcons.back().position = map_center + i.position/2
		
