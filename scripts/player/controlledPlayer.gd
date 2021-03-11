extends "dummyplayer.gd"

var fov_toggle :bool = false #temporarily
var impostor_toggle :bool = false  #temporarily

var selected_vent = 0

export var killCooldown = 20
onready var mask_width = $Light.get_texture().get_width()
onready var sight_range :float = default_sight_range

func _ready():
	$SightArea/AreaShape.shape.set_radius(default_sight_range)
	$Light.set_texture_scale(default_sight_range/mask_width*2)
	$CanvasLayer/playerGUI.updateGUI()
	$KillCooldown.wait_time = killCooldown

func get_input():
	moveX = 0; moveY = 0
	
	if currentInteraction == null:
		$CanvasLayer/playerGUI.visible = true
		if Input.is_action_pressed("move_right"):
			moveX = 1;
		
		if Input.is_action_pressed("move_left"):
			moveX = -1;
		
		if Input.is_action_pressed("move_down"):
			moveY = 1;
		
		if Input.is_action_pressed("move_up"):
			moveY = -1;
		
		if Input.is_action_just_pressed("ui_select"):
			ui_selected()
			$CanvasLayer/playerGUI.updateGUI()
		if Input.is_action_just_pressed("ui_kill"):
			ui_kill()
		if Input.is_action_just_pressed("ui_kill"):
			ui_report()
	if Input.is_action_pressed("ui_cancel"):
		ui_canceled()
		$CanvasLayer/playerGUI.updateGUI()
	
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
		else: if currentInteraction.is_in_group("players") and interacted == false:
			currentInteraction = null
		else:
			$CanvasLayer/playerGUI.visible = false

func _physics_process(delta):
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
					else:
						interactable.push_back(item);
						if debug_mode: print(item.get_name(), " added to: interactable")

func showMyTasks():
	for i in localTaskList:
		if i.material != null:
				print(i.name)
				print(i.material)
				i.material.set_shader_param("aura_width", 18)
