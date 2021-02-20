extends "dummyplayer.gd"

var fov_toggle = false #temporarily
var selected_vent = 0

onready var mask_width = $Light.get_texture().get_width()
onready var sight_range :float = default_sight_range

func _on_ready():
	$SightArea/AreaShape.shape.set_radius(default_sight_range)
	$Light.set_texture_scale(default_sight_range/mask_width*2)

func get_input():
	moveX = 0; moveY = 0
	
	if currentInteraction == null:
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
	
	if Input.is_action_pressed("ui_cancel"):
		ui_canceled()
	
	if Input.is_action_just_pressed("set_fov"):
		if fov_toggle:
			sight_range = 2000;
		else:
			sight_range = 500
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
				
		else: if currentInteraction.IsDone():
			currentInteraction = null

func _physics_process(delta):
	scale_sight_range(delta)
	get_input()

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
