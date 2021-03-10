extends Control

var player
var usage

func _ready():
	player = get_parent().get_parent()
	interactionGUIupdate()
func updateGUI():
	var content = ""
	for i in player.localTaskList:
		content += i.ToString() 
		content += "\n"
	$VBoxContainer/tasklist.text = content

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
func _on_use_pressed():
	player.ui_selected()

func interactionGUIupdate():
	if player.is_in_group("impostors"):
		$impostor.visible = true
	else:
		$impostor.visible = false
		$all/use.visible = true

func _on_sabotage_pressed():
	pass # open sabotage gui

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
	for i in player.interactable:
		if 	i.is_in_group("deadbody"):
			return true
	return false

func _on_report_pressed():
	for i in player.interactable:
		if 	i.is_in_group("deadbody"):
			i.Interact(player)
			break
		
func checkKillability():
	if player.players_interactable.size() > 0:
		return true
	else: 
		return false


func _on_kill_pressed():
	player.ui_kill()
