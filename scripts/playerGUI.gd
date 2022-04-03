extends Control

var player
var usage
var network
var GUI
var all = 1
var done = 0
var comms = false
#  GUI resources
var minimap = { "gui_res": load("res://gui/minimap.tscn"), "gui_name": "MiniMap" }
var sabotagemap = { "gui_res": load("res://gui/sabotagemap.tscn"), "gui_name": "SabotageMap" }
var settings = { "gui_res": load("res://gui/menumenu.tscn"), "gui_name": "Settings" }

var last_task_list = []

var chat_open = false

func _ready():
	network = get_tree().get_root().get_node("Start").network
	network.connect("taskschange", self, "progress_update")
	player = get_owner()
	GUI = get_parent().get_parent()
	
	$gamecode.text = network.server_key
	interactionGUIupdate()

func updateTaskList():
	player.showMyTasks()
	var content = ""
	if !comms:
		for i in player.localTaskList:
			content += i.ToString() 
			content += "\n"
	print("updateing!")
	$TaskPanel/VBoxContainer/tasklist.text = content

func interactionGUIupdate():
	if player.is_in_group("impostors"):
		$ImpostorButtons.visible = true
	else:
		$ImpostorButtons.visible = false
		$ActionButtons/use.visible = true

func _process(_delta):
	usage = checkUsage()
	$ActionButtons/use.disabled = !usage
	$ActionButtons/report.disabled = !checkReportability()
	if player.is_in_group("impostors"):
		$ActionButtons/use.visible = usage
	$ImpostorButtons/sabotage.visible = !usage
	if int(player.get_node("KillCooldown").time_left) > 0:
		$ImpostorButtons/kill/cooldown.text = str(int(player.get_node("KillCooldown").time_left))
		$ImpostorButtons/kill/cooldown.visible = true
	else:
		$ImpostorButtons/kill/cooldown.visible = false
	$ImpostorButtons/kill.disabled = !(checkKillability() && (int(player.get_node("KillCooldown").time_left) == 0))
	
	if player.currentSabotage == 4:
		$TaskPanel/VBoxContainer/sabotage.text = "Idź spytać się czy są lekcje! (" + str(int(player.get_node("DeathTimer").get_time_left())) + "s)"
	processGui()
	if last_task_list != player.localTaskList:
		last_task_list = player.localTaskList.duplicate()
		print("oops")
		updateTaskList()

func checkUsage():
	if player.interactable.size() == 0:
		return false
	for i in player.interactable:
		if i.is_in_group("tasks"):
			if i in player.localTaskList:
				return true
		elif i.is_in_group("vents"):
			if player.is_in_group("impostors"):
				return true
		else:
				return true
	return false

func checkReportability():
	return player.deadbody_interactable.size() > 0
	
func checkKillability():
	if player.is_in_group("rip"):
		return false
	if player.currentInteraction != null:
		return false
	return player.players_interactable.size() > 0

func _on_gui_button_pressed(button_name):
	if button_name == "sabotage" and ((player.currentInteraction != null and !player.currentInteraction.is_in_group("vents")) or player.currentInteraction == null):
		var instance = sabotagemap["gui_res"].instance()
		instance.name = sabotagemap["gui_name"]
		if GUI.replace_on_canvas(instance):
			instance.player = player
			player.connect("sabotage_event", instance, "updateMap")
			instance.sabotage = player.currentSabotage
			instance.curr_time  = player.get_node("SabotageCooldown").time_left
			instance.cooldown = player.sabotageCooldown
			instance.refresh_self()
	elif button_name == "kill":
		player.ui_kill()
	elif button_name == "settings":
		var instance = settings["gui_res"].instance()
		instance.name = settings["gui_name"]
		if GUI.is_on_canvas(instance):
			#save setting
			pass
		else:
			#set setting
			pass
		GUI.replace_on_canvas(instance)
		instance.onopen()
	elif button_name == "map":
		var instance = minimap["gui_res"].instance()
		instance.name = minimap["gui_name"]
		if GUI.replace_on_canvas(instance):
			instance.player = player
			instance.taskList = player.localTaskList
			if !comms:
				instance.addTasks()
	elif button_name == "use":
		if player.currentInteraction != null:
			if player.currentInteraction.is_in_group("vents"):
				player.currentInteraction.EndInteraction(player)
				player.currentInteraction = null
		else:
			player.ui_selected()
	elif button_name == "report":
		player.ui_report()
	elif button_name == "exit":
		player.ui_canceled()
	elif button_name == "chat":
		var chat = GUI.get_node("CloseButton/ChatPanel")
		if network.gamestate == NetworkManager.MEETING:
			chat.get_node("bg").visible = !chat.visible
			chat.show(!chat.visible)
		else:
			GUI.replace_on_canvas(chat, false)
	elif button_name == "mic":
		print("mic")

# # # GUI VISUAL FUNCTIONS AND VARIABLES # # #

var task_panel_opened = true
const task_panel_slide_speed:float = 25.0
const task_list_min_size:float = 150.0 # button size + margin

onready var task_container = get_node("TaskPanel/TaskContainer")
onready var task_panel_position = task_container.rect_position
onready var task_container_size = task_container.rect_size
onready var task_label_size = get_node("TaskPanel/VBoxContainer/Label").rect_size
onready var button = get_node("TaskPanel/TaskButton")

func processGui():
	var task_panel = get_node("TaskPanel")
	var list_size = get_node("TaskPanel/VBoxContainer/tasklist").rect_size
	var sabotage_size
	
	if player.currentSabotage != 0:
		sabotage_size = get_node("TaskPanel/VBoxContainer/sabotage").rect_size
	else: 
		sabotage_size = Vector2()
	
	task_container.rect_size.y = max(list_size.y + task_label_size.y + sabotage_size.y, task_list_min_size)
	
	if(task_panel.rect_position.x != task_panel_position.x):
		if(task_panel.rect_position.x > task_panel_position.x):
			task_panel.rect_position.x -= task_panel_slide_speed
			if(task_panel.rect_position.x < task_panel_position.x):
				task_panel.rect_position.x = task_panel_position.x
				button.text = "pokaż"
		elif(task_panel.rect_position.x < task_panel_position.x):
			task_panel.rect_position.x += task_panel_slide_speed
			if(task_panel.rect_position.x > task_panel_position.x):
				task_panel.rect_position.x = task_panel_position.x
				button.text = "ukryj"

func toggleTaskContainer():
	if(task_panel_opened):
		task_panel_position.x -= task_container_size.x
	else:
		task_panel_position.x += task_container_size.x
	task_panel_opened = !task_panel_opened

func _onTaskContainerButtonPressed():
	toggleTaskContainer()

func leave_game():
	player.get_tree().get_root().get_node("Start").leave_room()

func handle_sabotage(type, enabled):
	if enabled:
		if type == 1:
			$TaskPanel/VBoxContainer/sabotage.text = "Światła są wyłączone!"
		if type == 3:
			comms = true
			$TaskPanel/VBoxContainer/sabotage.text = "Komunikacja jest wyłączona!"
		if type == 4:
			$TaskPanel/VBoxContainer/sabotage.text = "Idź spytać się czy są lekcje!"
		if type != 2:
			$TaskPanel/VBoxContainer/sabotage.visible = true
	else:
		$TaskPanel/VBoxContainer/sabotage.visible = false
		comms = false
	updateTaskList()

func progress_update(done_n, all_n):
	done = done_n
	all = all_n
	if player.currentSabotage != 3:
		if network.gamesettings["taskbar-updates"] == 2:
			refresh_task_bar()

func refresh_task_bar():
	$ProgressBar.value = (done * 100) / all
