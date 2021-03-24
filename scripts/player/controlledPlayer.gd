extends "dummyplayer.gd"

var fov_toggle :bool = false #temporarily
var impostor_toggle :bool = false  #temporarily

var selected_vent = 0
var disabled_movement:bool = false
var joystickUsed = false
var currentSabotage = 0
export var killCooldown = 20
export var sabotageCooldown = 20
onready var mask_width = $Light.get_texture().get_width()
onready var sight_range :float = default_sight_range

signal sabotage_event()

func is_sabotage_timer_done():
	return $SabotageCooldown.time_left == 0
	
# should we take into consideration fov_toggle?
func handle_sabotage(type):
	var network = get_tree().get_root().get_node("Start").network
	if $SabotageCooldown.time_left == 0 and currentSabotage == 0:
		currentSabotage = type
		if type == 1:
			sight_range = default_sight_range / 2
		if type == 2:
			network.world.get_node("Mapa/YSort/door").close_door()
			network.world.get_node("Mapa/YSort/door2").close_door()
			network.world.get_node("Mapa/YSort/door3").close_door()
		if type == 3:
			network.comms_disabled = true

		emit_signal("sabotage_event", currentSabotage)

func handle_end_sabotage(type):
	if not currentSabotage == 0:
		currentSabotage = 0
		$SabotageCooldown.start(sabotageCooldown)
		var network = get_tree().get_root().get_node("Start").network
		if type == 1:
			sight_range = default_sight_range
		if type == 2:
			network.world.get_node("Mapa/YSort/door").open_door()
			network.world.get_node("Mapa/YSort/door2").open_door()
			network.world.get_node("Mapa/YSort/door3").open_door()
		if type == 3:
			network.comms_disabled = false

		emit_signal("sabotage_event", 0)

func _ready():
	$SightArea/AreaShape.shape.set_radius(default_sight_range)
	$Light.set_texture_scale(default_sight_range/mask_width*2)
	$CanvasLayer/playerGUI.updateGUI()
	$KillCooldown.wait_time = killCooldown
	var network = get_tree().get_root().get_node("Start").network
	network.connect("sabotage", self, "handle_sabotage")
	network.connect("sabotage_end", self, "handle_end_sabotage")

func get_input():
	moveX = 0; moveY = 0
	
	if !disabled_movement and currentInteraction == null:
		joystickUsed = $CanvasLayer/playerGUI/Joystick.pressed
		$CanvasLayer/playerGUI.visible = true
		if Input.is_action_pressed("move_right"):
			moveX += 1;
		
		if Input.is_action_pressed("move_left"):
			moveX += -1;
		
		if Input.is_action_pressed("move_down"):
			moveY += 1;
		
		if Input.is_action_pressed("move_up"):
			moveY += -1;
		if joystickUsed:
			moveX = $CanvasLayer/playerGUI/Joystick.vec.x
			moveY = $CanvasLayer/playerGUI/Joystick.vec.y
		if Input.is_action_just_pressed("ui_select"):
			ui_selected()
			$CanvasLayer/playerGUI.updateGUI()
		if Input.is_action_just_pressed("ui_kill"):
			if self.is_in_group("impostors"):
				ui_kill()
		if Input.is_action_just_pressed("ui_report"):
			if !self.is_in_group("rip"):
				ui_report()
	if Input.is_action_pressed("ui_cancel"):
		ui_canceled()
		$CanvasLayer/playerGUI.updateGUI()
		showMyTasks()
	if Input.is_action_just_pressed("set_fov"):
		if fov_toggle:
			sight_range = 2000;
		else:
			sight_range = 500
		fov_toggle = !fov_toggle

	if Input.is_action_just_pressed("GetImpostored"):
		if !impostor_toggle:
			self.add_to_group("impostors")
			self.modulate = Color("#00FF00")
			if debug_mode:
				# most likely broken
				var temp = get_parent().get_parent().get_node("dekoracje/meeting-table/game-spawner")
				temp.teleport_players()
		else:
			self.remove_from_group("impostors")
			self.modulate = Color("#FFFFFF")
		impostor_toggle = !impostor_toggle
		$CanvasLayer/playerGUI.interactionGUIupdate()
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
			$CanvasLayer2/exit_button.visible = false
		else:
			$CanvasLayer/playerGUI.visible = false
			$sprites.stopWalk()
func _process(delta):
	scale_sight_range(delta)
	get_input()
	check_line_of_sight()
	check_interaction()
	
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
	if(players_interactable.size() != 0 && $KillCooldown.time_left == 0):
		var currentBestItem = players_interactable[0]
		var currentBestDistance = position.distance_squared_to(currentBestItem.position)
			
		for item in players_interactable:
			if(position.distance_squared_to(item.position) < currentBestDistance):
				currentBestItem = item
				currentBestDistance = position.distance_squared_to(currentBestItem.position)
		currentBestItem.Interact(self)

func ui_report():
	if(deadbody_interactable.size() != 0):
		var currentBestItem = deadbody_interactable[0]
		var currentBestDistance = position.distance_squared_to(currentBestItem.position)
			
		for item in deadbody_interactable:
			if(position.distance_squared_to(item.position) < currentBestDistance):
				currentBestItem = item
				currentBestDistance = position.distance_squared_to(currentBestItem.position)
		currentBestItem.Interact(self)

func ui_canceled():
	if(currentInteraction != null):
		$CanvasLayer2/exit_button.visible = false
		if currentInteraction.is_in_group("tasks"):
			currentInteraction.EndInteraction()
		else:
			currentInteraction.EndInteraction(self)
		print(currentInteraction.get_name())
		currentInteraction = null
		
func ui_selected():
	if debug_mode:
		print("sight_range: ", in_sight_range)
		print("sight: ", in_sight)
	
	if(interactable.size() != 0):
		var currentBestItem = interactable[0]
		var currentBestDistance = position.distance_squared_to(currentBestItem.position)
			
		for item in interactable:
			if(position.distance_squared_to(item.position) < currentBestDistance):
				currentBestItem = item
				currentBestDistance = position.distance_squared_to(currentBestItem.position)

		var result
		if currentBestItem.is_in_group("tasks"): 
			result = currentBestItem.Interact(); 
		else: result = currentBestItem.Interact(self)
		if result == false:
			return
		currentInteraction = currentBestItem
		if !currentInteraction.is_in_group("vents"): 
			$CanvasLayer2/exit_button.visible = true

func _on_exit_button_pressed():
	ui_canceled()

