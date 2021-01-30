extends "dummyplayer.gd"

var fov_toggle = true #temporarily

func get_input():
	if Input.is_action_pressed("move_right"):
		moveX = 1;
	
	if Input.is_action_pressed("move_left"):
		moveX = -1;
	
	if Input.is_action_pressed("move_up"):
		moveY = 1;
	
	if Input.is_action_pressed("move_down"):
		moveY = -1;
	
	if Input.is_action_just_pressed("set_fov"):
		if fov_toggle:
			sight_range = 2000;
		else:
			sight_range = 500
		fov_toggle = !fov_toggle

	if Input.is_action_just_pressed("ui_select"):
		ui_selected()

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
