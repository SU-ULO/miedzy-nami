extends Panel

var chosen = -2 setget set_chosen
var time = 40.0 setget set_time
var label_text = "Koniec czasu dyskusji za: "
var meeting_state = 0

signal meeting_state_changed(state)

var confirm_id = null

func toggle_confirm_buttons(new_box_id = null):
	if confirm_id != null:
		var old_box = get_player_box(confirm_id)
		old_box.get_node("Button/CB").visible = false
		confirm_id = null
	if new_box_id != null:
		get_player_box(new_box_id).get_node("Button/CB").visible = true
		confirm_id = new_box_id

func _ready():
	get_node("Timer").start(time)

func _process(_delta):
	update_time()

func set_time(t):
	var timer = get_node("Timer")
	time = t
	timer.start(t)

func update_time():
	var timer = get_node("Timer")
	var label = get_node("TL")
	label.text = label_text + to_time(timer.time_left)

func to_time(s):
	var mins = int(round(s)/60)
	var secs = round(s) - mins*60
	
	if secs < 10: secs = "0" + String(secs)
	else: secs = String(secs)
	mins = String(mins)
	
	return mins + ":" + secs

func set_chosen(id):
	chosen = id
	set_all_buttons(0)

func get_player_box(id):

	for player in get_node("H/V1").get_children():
		if player.id == id:
			return player
			
	for player in get_node("H/V2").get_children():
		if player.id == id:
			return player
		
	return null

func set_all_buttons(state:bool): # 0 disabled, 1 enabled
	for player in get_node("H/V1").get_children():
		player.get_node("Button").disabled = !state
	
	for player in get_node("H/V2").get_children():
		player.get_node("Button").disabled = !state
		
	get_node("S").disabled = !state

func _on_Timer_timeout():
	emit_signal("meeting_state_changed", meeting_state+1)
