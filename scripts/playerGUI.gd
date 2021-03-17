extends Control

var player
var usage

var minimap = { "res": preload("res://gui/minimap.tscn"), "map_name": "MiniMap" }
var sabotagemap = { "res": preload("res://gui/sabotagemap.tscn"), "map_name": "SabotageMap" }
var map_opened = false

func _ready():
	player = get_parent().get_parent()
	interactionGUIupdate()

func updateGUI():
	player.showMyTasks()
	var content = ""
	for i in player.localTaskList:
		content += i.ToString() 
		content += "\n"
	$TaskPanel/VBoxContainer/tasklist.text = content
		
func _process(_delta):
	usage = checkUsage()
	$ActionButtons/use.disabled = !usage
	$ActionButtons/report.disabled = !checkReportability()
	if player.is_in_group("impostors"):
		$ActionButtons/use.visible = usage
	$impostor/sabotage.visible = !usage
	if int(player.get_node("KillCooldown").time_left) > 0:
		$impostor/kill/cooldown.text = str(int(player.get_node("KillCooldown").time_left))
		$impostor/kill/cooldown.visible = true
	else:
		$impostor/kill/cooldown.visible = false
	$impostor/kill.disabled = !(checkKillability() && (int(player.get_node("KillCooldown").time_left) == 0))
	
	processGui()

func _on_use_pressed():
	player.ui_selected()

func interactionGUIupdate():
	if player.is_in_group("impostors"):
		$impostor.visible = true
	else:
		$impostor.visible = false
		$ActionButtons/use.visible = true

func checkUsage():
	if player.interactable.size() == 0:
		return false
	for i in player.interactable:
		if i.is_in_group("tasks"):
			if !player.is_in_group("impostors"):
				if i in player.localTaskList:
					return true
		elif i.is_in_group("vents"):
			if 	player.is_in_group("impostors"):
				return true
		else:
				return true
	return false

func checkReportability():
	return player.deadbody_interactable.size() > 0

func _on_report_pressed():
	for i in player.interactable:
		if 	i.is_in_group("deadbody"):
			i.Interact(player)
			break
		
func checkKillability():
	return player.players_interactable.size() > 0


func _on_kill_pressed():
	player.ui_kill()

func show_map(map_object):
	var canvas = get_owner().get_parent().get_parent().get_parent().get_node("CanvasLayer")
	if(!map_opened):
		var instance = map_object.res.instance()
		canvas.add_child(instance)
		instance.name = map_object.map_name
		if map_object.map_name == "MiniMap":
			instance.get_node("player").player = self.get_parent().get_parent()
			instance.get_node("player").taskList = player.localTaskList
			instance.get_node("player").addTasks()
		#elif map_object.map_name == "SabotageMap":
			# nothing here right now
		map_opened = !map_opened
		toggleVisibility("ActionButtons")
		toggleVisibility("TaskPanel")
		if player.is_in_group("impostors"):
			toggleVisibility("impostor")
	else:
		var current_map_name = canvas.get_child(0).name
		canvas.get_child(0).queue_free()
		map_opened = !map_opened
		toggleVisibility("ActionButtons")
		toggleVisibility("TaskPanel")
		if player.is_in_group("impostors"):
			toggleVisibility("impostor")
		
		if map_object.map_name != current_map_name:
			if current_map_name == "SabotageMap":
				show_map(minimap)
			elif current_map_name == "MiniMap":
				print("You shouldn't be able to do that")
				show_map(sabotagemap)


func _on_sabotage_pressed():
	show_map(sabotagemap)

func _on_map_pressed():
	show_map(minimap)


# # # GUI VISUAL FUNCTIONS AND VARIABLES # # #

var task_panel_opened = true
const task_panel_slide_speed:float = 25.0
const task_list_min_size:float = 150.0 # button size + margin

onready var task_container = get_node("TaskPanel/TaskContainer")
onready var task_panel_position = task_container.rect_position
onready var task_container_size = task_container.rect_size
onready var task_label_size = get_node("TaskPanel/VBoxContainer/Label").rect_size

func processGui():
	var task_panel = get_node("TaskPanel")
	var list_size = get_node("TaskPanel/VBoxContainer/tasklist").rect_size
	task_container.rect_size.y = max(list_size.y + task_label_size.y, task_list_min_size)
	
	if(task_panel.rect_position.x != task_panel_position.x):
		if(task_panel.rect_position.x > task_panel_position.x):
			task_panel.rect_position.x -= task_panel_slide_speed
			if(task_panel.rect_position.x < task_panel_position.x):
				task_panel.rect_position.x = task_panel_position.x
		elif(task_panel.rect_position.x< task_panel_position.x):
			task_panel.rect_position.x += task_panel_slide_speed
			if(task_panel.rect_position.x > task_panel_position.x):
				task_panel.rect_position.x = task_panel_position.x

func toggleTaskContainer():
	if(task_panel_opened):
		task_panel_position.x -= task_container_size.x
	else:
		task_panel_position.x += task_container_size.x
	task_panel_opened = !task_panel_opened

func toggleVisibility(node_name):
	var node = get_node(node_name)
	node.visible = !node.visible

func _onTaskContainerButtonPressed():
	toggleTaskContainer()
