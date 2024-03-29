extends NetworkManager

class_name SingleplayerManager

func _init():
	preloadedmap = preload('res://scenes/school_single.tscn')

func _ready():
	var gs = Globals.read_file("user://gs.settings")
	if gs and gs is Dictionary:
		for k in gamesettings:
			if gs.has(k):
				gamesettings[k]=gs[k]

func handle_game_settings(settings):
	Globals.save_file("user://gs.settings", settings)
	.handle_game_settings(settings)

func set_game_settings(settings):
	for c in player_characters:
		var p = player_characters[c]
		p.player_speed = p.default_speed * gamesettings["player-speed"]
	handle_game_settings(settings)

func create_world(config):
	.create_world(config)
	own_player = preload("res://entities/player.tscn").instance()
	own_player.username = get_parent().menu.usersettings["username"]
	player_characters[own_id]=own_player
	own_player.global_position = get_spawn_position(own_id)
	own_player.color = randi()%14+1
	world.get_node('Mapa/YSort').add_child(own_player)
	for npc in world.npcs:
		player_characters[npc.owner_id]=npc
	emit_signal("joined_room")
	set_game_settings(gamesettings)
	world.get_node("Mapa/lobby/start").add_to_group("interactable")
	if endscreen: endscreen.queue_free()

func recreate_world():
	var init_data
	init_data=own_player.generate_init_data()
	init_data["pos"]=get_spawn_position(own_player.owner_id)
	init_data["imp"]=false
	init_data["dead"]=false
	.recreate_world()
	taken_colors=0
	player_characters[0].set_init_data(init_data)
	own_player.get_node("sprites").loadLook()

func start():
	create_world({"key": ""})

func get_tasks_number(tasksarray: Array) -> int:
	var task_count = 0
	for i in tasksarray:
		task_count += Task.GetTaskByID(i).taskLength
	return task_count

func request_game_start():
	set_game_settings(gamesettings)
	gamestate = STARTED
	gamestate_params = {"imp": []}
	Task.SetTaskCategoriesPerPlayer(3, gamesettings["short-tasks"])
	Task.SetTaskCategoriesPerPlayer(0, gamesettings["long-tasks"])
	var ids = player_characters.keys()
	ids.sort()
	Task.DivideTasks(ids)
	var own_tasks = Task.GetTaskIDsForPlayerID(own_id)
	own_player.assignedtasks=get_tasks_number(own_tasks)
	game_start(gamestate_params, own_tasks)
	for npc in world.npcs:
		npc.npc_init()

func request_set_look(look: Dictionary):
	handle_set_look(look, own_id)

func handle_set_look(look: Dictionary, id: int):
	set_look(id, look)

func kick(_id: int):
	pass

func kick_him():
	pass

func request_color_change(c: int):
	player_characters[own_id].color = c
	player_characters[own_id].get_node("sprites").loadLook()
