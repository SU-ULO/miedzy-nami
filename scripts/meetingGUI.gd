extends Panel

var chosen = -2 setget set_chosen
var time = 40.0 setget set_time

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
	label.text = "Koniec głosowania za: " + to_time(timer.time_left)

func to_time(s):
	var mins = int(round(s)/60)
	var secs = round(s) - mins*60
	
	if secs < 10: secs = "0" + String(secs)
	else: secs = String(secs)
	mins = String(mins)
	
	return mins + ":" + secs

func set_chosen(id):
	chosen = id
	disable_all()

func get_player_box(id):
	var path
	if id % 2 == 0: path = "H/V1"
	else: path = "H/V2"
	
	for player in get_node(path).get_children():
		if player.id == id:
			return player
	return null

func disable_all():
	
	for player in get_node("H/V1").get_children():
		player.get_node("Button").disabled = true
	
	for player in get_node("H/V2").get_children():
		player.get_node("Button").disabled = true
		
	get_node("S").disabled = true
