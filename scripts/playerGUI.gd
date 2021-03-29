extends Control

var player
var usage

var network

var minimap = { "res": preload("res://gui/minimap.tscn"), "map_name": "MiniMap" }
var sabotagemap = { "res": preload("res://gui/sabotagemap.tscn"), "map_name": "SabotageMap" }
var map_opened:Dictionary = {}
func _ready():
	player = get_parent().get_parent()
	interactionGUIupdate()
	network = get_tree().get_root().get_node("Start").network
	$gamecode.text = network.server_key
func updateGUI():
	player.showMyTasks()
	var content = ""
	for i in player.localTaskList:
		content += i.ToString() 
		content += "\n"
	$TaskPanel/VBoxContainer/tasklist.text = content
		
func _process(_delta):
	$ActionButtons/report.visible = !player.is_in_group("rip")
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
	if player.currentInteraction != null:	 
		if player.currentInteraction.is_in_group("vents"):
			player.currentInteraction.EndInteraction(player)
			player.currentInteraction = null
	else:
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
	player.ui_report()
		
func checkKillability():
	if player.currentInteraction != null:
		return false
	return player.players_interactable.size() > 0


func _on_kill_pressed():
	player.ui_kill()

func show_map(map_object = map_opened):
	var canvas = get_owner().get_parent().get_parent().get_parent().get_node("CanvasLayer")
	if map_opened.empty():
		if !map_object.empty():
			var instance = map_object.res.instance()
			canvas.add_child(instance)
			instance.name = map_object.map_name
			if map_object.map_name == "MiniMap":
				instance.get_node("player").player = self.get_parent().get_parent()
				instance.get_node("player").taskList = player.localTaskList
				instance.get_node("player").addTasks()
			elif map_object.map_name == "SabotageMap":
				instance.connect("exit", self, "closeSabotageMap")
				player.connect("sabotage_event", instance, "updateMap")
				instance.sabotage = player.currentSabotage
				instance.curr_time  = player.get_node("SabotageCooldown").time_left
				instance.cooldown = player.sabotageCooldown
				instance.refresh_self()
			map_opened = map_object
			setVisibility("ActionButtons", 0)
			setVisibility("TaskPanel", 0)
			if player.is_in_group("impostors"):
				setVisibility("impostor", 0)
	else:
		canvas.get_child(0).queue_free()
		setVisibility("ActionButtons", 1)
		setVisibility("TaskPanel", 1)
		if player.is_in_group("impostors"):
			setVisibility("impostor", 1)
		map_opened.clear()
		
		if !map_object.empty():
			if map_object.map_name != map_opened.name:
				if map_opened.name == "SabotageMap":
					show_map(minimap)
				elif map_opened.name == "MiniMap":
					print("You shouldn't be able to do that")
					show_map(sabotagemap)
					
			map_opened = map_object


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
	task_panel.visible = !network.comms_disabled
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

func setVisibility(node_name = "self", state:bool = 1):
	var node
	if node_name == "self":
		node = self
	else:
		node = get_node(node_name)
	node.visible = state

func _onTaskContainerButtonPressed():
	toggleTaskContainer()

func closeSabotageMap():
	map_opened.clear()
	get_owner().get_parent().get_parent().get_parent().get_node("CanvasLayer").get_node("SabotageMap").queue_free()
	setVisibility("ActionButtons", 1)
	setVisibility("TaskPanel", 1)
	if player.is_in_group("impostors"):
		setVisibility("impostor", 1)
