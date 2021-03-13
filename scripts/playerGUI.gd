extends Control

var player
var usage

var minimap = preload("res://gui/minimap.tscn")
var sabotagemap = preload("res://gui/sabotagemap.tscn")
var minimap_opened = false
var sabotagemap_opened = false

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
	$all/use.disabled = !usage
	$all/report.disabled = !checkReportability()
	if player.is_in_group("impostors"):
		$all/use.visible = usage
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
		$all/use.visible = true

func _on_sabotage_pressed():
	var canvas = get_owner().get_parent().get_parent().get_parent().get_node("CanvasLayer")
	if(!sabotagemap_opened):
		var instance = sabotagemap.instance()
		instance.name = "fajnamapasabotazu"
		canvas.add_child(instance)
	else:
		canvas.get_node("fajnamapasabotazu").queue_free()
		
	sabotagemap_opened = !sabotagemap_opened

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

func show_map():
	var canvas = get_owner().get_parent().get_parent().get_parent().get_node("CanvasLayer")
	if(!minimap_opened):
		var instance = minimap.instance()
		instance.name = "fajnamapa"
		canvas.add_child(instance)
		instance.get_node("player").player = self.get_parent().get_parent()
		instance.get_node("player").taskList = player.localTaskList
		instance.get_node("player").addTasks()
	else:
		canvas.get_node("fajnamapa").queue_free()
	minimap_opened = !minimap_opened

func _on_map_pressed():
	show_map()

# # # GUI VISUAL FUNCTIONS AND VARIABLES # # #

var task_panel_opened = true
const task_panel_slide_speed:float = 25.0

onready var task_container = get_node("TaskPanel/TaskContainer")
onready var task_panel_position = task_container.rect_position
onready var task_container_size = task_container.rect_size

func processGui():
	var task_panel = get_node("TaskPanel")
	
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

func _onTaskContainerButtonPressed():
	toggleTaskContainer()
