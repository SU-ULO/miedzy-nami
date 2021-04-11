extends "dummyplayer.gd"

class_name Player

var fov_toggle :bool = false #temporarily

const arrow_radius = 300.0

var selected_vent = 0
var disabled_movement:bool = false
var joystickUsed = false
var currentSabotage = 0
export var killCooldown = 20
export var sabotageCooldown = 40
export var death_time = 60
onready var mask_width = $Light.get_texture().get_width()
onready var sight_range :float = default_sight_range
var sabotagearrow = null
var sabotagepoint = null
var sight_range_scale = 1
var meetings_left
var network
var bar_last = 0;

var electrical_switches = [0,0,0,0,0]
var electrical_good = [0,0,0,0,0]

func randomize_electrical():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	while electrical_good == electrical_switches:
		for _i in range(0, 5):
			electrical_good[_i] = rng.randi_range(0, 1)
			if electrical_good[_i] == 0:
				electrical_switches[_i] = 1
			else:
				electrical_switches[_i] = 0
	
	print("state randomized")

func handle_gui_sync(name: String, gui_data: Dictionary):
	if name == "electrical":
		electrical_good = gui_data["good"]
		electrical_switches = gui_data["switches"]

signal sabotage_event()

func is_sabotage_timer_done():
	return $SabotageCooldown.time_left == 0

func handle_sabotage(type):
	if $SabotageCooldown.time_left == 0 and currentSabotage == 0:
		$GUI/PlayerCanvas/playerGUI.handle_sabotage(type, 1)
		currentSabotage = type
		if type == 1:
			if !is_in_group("impostors"):
				sight_range = default_sight_range * sight_range_scale / 2
			if $InteractionArea.overlaps_body(network.world.get_node("Mapa/YSort/electrical")) && !is_in_group("rip"):
				_on_interaction_area_enter(network.world.get_node("Mapa/YSort/electrical"))
			sabotagepoint = network.world.get_node("Mapa/YSort/electrical")
			sabotagearrow.visible = true
		if type == 2:
			network.world.get_node("Mapa/door").close_door()
			network.world.get_node("Mapa/door2").close_door()
			network.world.get_node("Mapa/door3").close_door()
			network.world.get_node("Mapa/map-top-sprites/dynamic").z_index = 0
		if type == 3:
			network.comms_disabled = true
			if $InteractionArea.overlaps_body(network.world.get_node("Mapa/YSort/telewizorek")) && !is_in_group("rip"):
				_on_interaction_area_enter(network.world.get_node("Mapa/YSort/telewizorek"))
			sabotagepoint = network.world.get_node("Mapa/YSort/telewizorek")
			sabotagearrow.visible = true
			bar_last = get_node("GUI/PlayerCanvas/playerGUI/ProgressBar").value
			get_node("GUI/PlayerCanvas/playerGUI/ProgressBar").value = 0
		if type == 4:
			$DeathTimer.start(death_time)
			if $InteractionArea.overlaps_body(network.world.get_node("Mapa/YSort/biorko-nauczyciela6")) && !is_in_group("rip"):
				_on_interaction_area_enter(network.world.get_node("Mapa/YSort/biorko-nauczyciela6"))
			sabotagepoint = network.world.get_node("Mapa/YSort/biorko-nauczyciela6")
			sabotagearrow.visible = true
		emit_signal("sabotage_event", currentSabotage)

func handle_end_sabotage(type):
	if not currentSabotage == 0:
		if currentInteraction != null:
			if currentInteraction.is_in_group("sabotage"):
				ui_canceled()
		$GUI/PlayerCanvas/playerGUI.handle_sabotage(0, 0)
		currentSabotage = 0
		$SabotageCooldown.start(sabotageCooldown)
		if type == 1:
			if !is_in_group("impostors"):
				sight_range = default_sight_range * sight_range_scale
			if $InteractionArea.overlaps_body(network.world.get_node("Mapa/YSort/electrical")):
				on_interaction_area_exit(network.world.get_node("Mapa/YSort/electrical"))
		if type == 2:
			network.world.get_node("Mapa/door").open_door()
			network.world.get_node("Mapa/door2").open_door()
			network.world.get_node("Mapa/door3").open_door()
			network.world.get_node("Mapa/map-top-sprites/dynamic").z_index = 100
		if type == 3:
			network.comms_disabled = false
			if $InteractionArea.overlaps_body(network.world.get_node("Mapa/YSort/telewizorek")):
				on_interaction_area_exit(network.world.get_node("Mapa/YSort/telewizorek"))
			if network.gamesettings["taskbar-updates"] == 1:
				get_node("GUI/PlayerCanvas/playerGUI/ProgressBar").value = bar_last
			if network.gamesettings["taskbar-updates"] == 2:
				get_node("GUI/PlayerCanvas/playerGUI").refresh_task_bar()
		if type == 4:
			$DeathTimer.stop()
			if $InteractionArea.overlaps_body(network.world.get_node("Mapa/YSort/biorko-nauczyciela6")):
				on_interaction_area_exit(network.world.get_node("Mapa/YSort/biorko-nauczyciela6"))
		emit_signal("sabotage_event", 0)
		sabotagepoint = null
		sabotagearrow.visible = false

func _ready():
	$SightArea/AreaShape.shape.set_radius(default_sight_range)
	$Light.set_texture_scale(default_sight_range/mask_width*2)
	$GUI/PlayerCanvas/playerGUI.updateTaskList()
	$KillCooldown.wait_time = killCooldown
	network = get_tree().get_root().get_node("Start").network
	network.connect("sabotage", self, "handle_sabotage")
	network.connect("sabotage_end", self, "handle_end_sabotage")
	network.connect("gui_sync", self, "handle_gui_sync")
	meetings_left = network.gamesettings["meeting-count"]
	var ls = Globals.read_file("user://ls.settings")
	var looktoset = currLook.get_look()
	if ls and ls is Dictionary:
		for k in looktoset:
			if ls.has(k):
				looktoset[k]=ls[k]
	currLook.set_look(looktoset)
	network.request_set_look(currLook.get_look())
	sabotagearrow = get_node("arrow")
	
	# dirty fix for reused arrow
	sabotagearrow.get_child(0).disconnect("button_down", sabotagearrow, "_on_arrow_button_down")
	sabotagearrow.get_child(0).disconnect("mouse_entered", sabotagearrow,  "_on_arrow_mouse_entered")
	sabotagearrow.get_child(0).disconnect("mouse_exited", sabotagearrow, "_on_arrow_mouse_exited")

func get_input():
	moveX = 0; moveY = 0
	
	if !disabled_movement and currentInteraction == null:
		joystickUsed = $GUI/PlayerCanvas/playerGUI/Joystick.pressed
		if Input.is_action_pressed("move_right"):
			moveX += 1;
		
		if Input.is_action_pressed("move_left"):
			moveX += -1;
		
		if Input.is_action_pressed("move_down"):
			moveY += 1;
		
		if Input.is_action_pressed("move_up"):
			moveY += -1;
		if joystickUsed:
			moveX = $GUI/PlayerCanvas/playerGUI/Joystick.vec.x
			moveY = $GUI/PlayerCanvas/playerGUI/Joystick.vec.y
		if Input.is_action_just_pressed("ui_select"):
			ui_selected()
			$GUI/PlayerCanvas/playerGUI.updateTaskList()
		if Input.is_action_just_pressed("ui_kill"):
			if self.is_in_group("impostors"):
				ui_kill()
		if Input.is_action_just_pressed("ui_report"):
			if !self.is_in_group("rip"):
				ui_report()
	if Input.is_action_pressed("ui_cancel"):
		ui_canceled()
	if Input.is_action_just_pressed("set_fov"):
		if fov_toggle:
			sight_range = 2000 * sight_range_scale;
		else:
			sight_range = 500 * sight_range_scale
			get_tree().get_root().get_node("Start").network.end_game(true)
		fov_toggle = !fov_toggle
	if currentInteraction != null:
		if currentInteraction.is_in_group("vents"):
			
			var arrows_count = currentInteraction.get_node("arrows").get_child_count()
			var arrow = currentInteraction.get_node("arrows").get_child(selected_vent)
			
			if Input.is_action_just_pressed("next_vent"):
				selected_vent += 1
				if selected_vent > arrows_count-1:
					selected_vent = 0
				currentInteraction.arrowHighlight(selected_vent)
				
			else: if Input.is_action_just_pressed("prev_vent"):
				selected_vent -= 1
				if selected_vent < 0:
					selected_vent = arrows_count-1
				currentInteraction.arrowHighlight(selected_vent)
			
			if Input.is_action_just_pressed("use_vent"):
				arrow.call_teleport()
				selected_vent = 0
		else: if currentInteraction.is_in_group("tasks") and currentInteraction.IsDone():
			currentInteraction = null
			$GUI/PlayerCanvas/playerGUI.updateTaskList()
		else:
			$sprites.stopWalk()

func update_arrows():
	if sabotagepoint == null: return
	var pos = sabotagepoint.position
	var angle = pos.angle_to_point(self.position)
	sabotagearrow.set_position(Vector2(arrow_radius * cos(angle), arrow_radius * sin(angle)))
	sabotagearrow.set_rotation(angle)


func _process(delta):
	scale_sight_range(delta)
	get_input()
	check_line_of_sight()
	check_interaction()
	update_arrows()
	if network.gamesettings["voice-chat"] == 3 && network.gamestate != network.LOBBY:
		calculate_volume()
func scale_sight_range(delta):
	var area = $SightArea/AreaShape.shape
	var radius :float = area.get_radius()
	var lightscale : float = $Light.get_texture_scale()
	var speed : float = default_scaling_speed
	
	if radius > sight_range:
		area.set_radius(radius - 0.5*speed*delta)
		$Light.set_texture_scale(lightscale - speed/mask_width*delta)
		radius = area.get_radius()
		if radius < sight_range:
			area.set_radius(sight_range)
			$Light.set_texture_scale(sight_range/mask_width*2)
			
	else: if radius < sight_range:
		area.set_radius(radius + 0.5*speed*delta)
		$Light.set_texture_scale(lightscale + speed/mask_width*delta)
		radius = area.get_radius()
		if radius > sight_range:
			area.set_radius(sight_range)
			$Light.set_texture_scale(sight_range/mask_width*2)

func check_line_of_sight():
	for item in in_sight_range:
		var space_state = get_world_2d().direct_space_state
		var sight_check = space_state.intersect_ray(self.position, item.position, [self, item], 1)
			
		if !sight_check.empty():
			if debug_mode: debug_pos_collided.append(sight_check.position)
			if in_sight.has(item):
				in_sight.erase(item);
				if debug_mode: print(item.get_name(), " removed from: sight")
		else:
			if debug_mode: debug_pos_ok.append(item.position)
			if !in_sight.has(item):
				in_sight.push_back(item);
				if debug_mode: print(item.get_name(), " added to: sight")

func check_interaction():
	for item in in_interaction_range:
		if item.is_in_group("players"):
			if !in_sight.has(item):
				if players_interactable.has(item):
						players_interactable.erase(item);
						if debug_mode: print(item.get_name(), " removed from: players_interactable")
			else:
				if is_in_group("impostors") && !item.is_in_group("rips"):
					if !players_interactable.has(item):
						players_interactable.push_back(item);
						if debug_mode: print(item.get_name(), " added to: players_interactable")

		elif item.is_in_group("deadbody"):
			if !in_sight.has(item):
				if deadbody_interactable.has(item):
					deadbody_interactable.erase(item);
					if debug_mode: print(item.get_name(), " removed from: deadbody_interactable")
			else:
				if !self.is_in_group("rip"):
					if !deadbody_interactable.has(item):
						deadbody_interactable.push_back(item);
						if debug_mode: print(item.get_name(), " added to: deadbody_interactable")
		else:
			if !in_sight.has(item):
				if interactable.has(item):
					interactable.erase(item);
					if debug_mode: print(item.get_name(), " removed from: interactable")
			else:
				if !interactable.has(item):
					if item.is_in_group("tasks"):
						if item in localTaskList:
							interactable.push_back(item);
							if debug_mode: print(item.get_name(), " added to: interactable")
					elif item.is_in_group("vents"):
						if self.is_in_group("impostors"):
							interactable.push_back(item);
							if debug_mode: print(item.get_name(), " added to: interactable")
					elif item.is_in_group("sabotage"):
						if !is_in_group("rip"):
							interactable.push_back(item);
							if debug_mode: print(item.get_name(), " added to: interactable")
					else:
						interactable.push_back(item);
						if debug_mode: print(item.get_name(), " added to: interactable")

func showMyTasks():
	for i in localTaskList:
		if i.IsDone():
			localTaskList.erase(i)
			if i.material != null:
				if i.material is ShaderMaterial:
					i.material.set_shader_param("aura_width", 0)
		elif i.material != null:
			if i.material is ShaderMaterial:
				i.material.set_shader_param("aura_width", 18)
# interactions

func ui_kill():
	if(players_interactable.size() != 0 && $KillCooldown.time_left == 0 && !is_in_group("rip")):
		var currentBestItem = players_interactable[0]
		var currentBestDistance = position.distance_squared_to(currentBestItem.position)
			
		for item in players_interactable:
			if(position.distance_squared_to(item.position) < currentBestDistance):
				currentBestItem = item
				currentBestDistance = position.distance_squared_to(currentBestItem.position)
		players_interactable.erase(currentBestItem)
		currentBestItem.Interact(self)

func ui_report():
	if(deadbody_interactable.size() != 0 && !is_in_group("rip")):
		var currentBestItem = deadbody_interactable[0]
		var currentBestDistance = position.distance_squared_to(currentBestItem.position)
			
		for item in deadbody_interactable:
			if(position.distance_squared_to(item.position) < currentBestDistance):
				currentBestItem = item
				currentBestDistance = position.distance_squared_to(currentBestItem.position)
		currentBestItem.Interact(self)

func ui_canceled():
	refresh_areas()
	$GUI/PlayerCanvas/playerGUI.updateTaskList()
	showMyTasks()
	if(currentInteraction != null):
		currentInteraction.EndInteraction(self)
		print(currentInteraction.name)
		currentInteraction = null
		
func ui_selected():
	if get_node("GUI").currentGUI != null:
		return
	
	if debug_mode:
		print("sight_range: ", in_sight_range)
		print("sight: ", in_sight)
	
	refresh_areas()
	
	if(interactable.size() != 0):
		var currentBestItem = interactable[0]
		var currentBestDistance = position.distance_squared_to(currentBestItem.position)
			
		for item in interactable:
			if(position.distance_squared_to(item.position) < currentBestDistance):
				currentBestItem = item
				currentBestDistance = position.distance_squared_to(currentBestItem.position)

		var result = currentBestItem.Interact(self)
		
		if result == false:
			return
		else:
			currentInteraction = currentBestItem

func refresh_areas():
	var area1 = get_node("InteractionArea/AreaShape")
	var area2 = get_node("SightArea/AreaShape")
	var radius1 = area1.shape.radius
	var radius2 = area2.shape.radius
	
	get_node("InteractionArea/AreaShape").shape.radius = 0
	get_node("SightArea/AreaShape").shape.radius = 0
	# force update
	get_node("InteractionArea/AreaShape").shape.radius = radius1
	get_node("SightArea/AreaShape").shape.radius = radius2

func become_impostor():
	.become_impostor()
	$GUI/PlayerCanvas/playerGUI.interactionGUIupdate()

func _on_DeathTimer_timeout():
	if not is_in_group("imposotors"):
		self.Interact(self)

func players_in_voice_range():
	return players_in_sight()

func calculate_volume():
	for i in voice_range:
		i.vc_volume = sqrt(1 - (i.position.distance_to(position) / $VoiceArea/AreaShape.shape.radius))
