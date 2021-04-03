extends Control

var res = preload("res://gui/playericon.tscn")
var task_icon = preload("res://gui/taskicon.tscn")
var icon = null
var player = null

var map_center
const map_scale:float = 0.2
const player_height = 38

var taskList = []
var taskIcons = []

func _ready():
	icon = res.instance()
	self.add_child(icon)
	map_center = get_node("Position2D").position

func _process(_delta):
	if player != null:
		icon.position = player.position * map_scale/2 + map_center + Vector2(0, player_height)

func addTasks():
	var node = get_node("task-icons")
	taskIcons.clear()
	
	if not get_tree().get_root().get_node("Start").network.comms_disabled:
		for task in taskList:
			taskIcons.append(task_icon.instance())
			node.add_child(taskIcons.back())
			taskIcons.back().position = map_center + task.position * map_scale/2

func _close():
	player.get_node("GUI").replace_on_canvas(self)
