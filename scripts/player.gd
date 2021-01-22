extends "dummy.gd"

export var default_speed = 900.0
export var default_sight_range = 2000.0
export var default_scaling_speed = 2000.0
var player_velocity = Vector2()
var in_sight_range = []; var in_interaction_range = []
var in_sight = []; var interactable = []

onready var mask_width = $Light.get_texture().get_width()
onready var sight_range :float = default_sight_range

func get_input():	
	player_velocity = Vector2()
	var flipped = false
	
	if Input.is_action_pressed("move_left"):
		player_velocity.x -= 1
		$AnimatedSprite.visible = true
		$Sprite.visible = false
		$AnimatedSprite.flip_h = true
		flipped = true
		
	if Input.is_action_pressed("move_right"):
		player_velocity.x += 1
		$AnimatedSprite.visible = true
		$Sprite.visible = false
		$AnimatedSprite.flip_h = false
		flipped = false
		
	if Input.is_action_pressed("move_up"):
		$AnimatedSprite.visible = true
		$Sprite.visible = false
		player_velocity.y -= 1
		sight_range = 2000
		
	if Input.is_action_pressed("move_down"):
		$AnimatedSprite.visible = true
		$Sprite.visible = false
		player_velocity.y += 1
		sight_range = 500
		
	if Input.is_action_just_pressed("ui_select"):
		print("ui_select clicked")
		for item in interactable:
			print(item.name)
			item.Interact()
			
		
	if player_velocity.y == 0 && player_velocity.x == 0:
		$Sprite.visible = true
		if flipped == $Sprite.is_flipped_h():
			$Sprite.flip_h = flipped
		$AnimatedSprite.visible = false
		
	player_velocity = player_velocity.normalized() * default_speed

func in_direct_line():
	for item in in_sight_range:	
		var space_state = get_world_2d().direct_space_state
		var sight_check = space_state.intersect_ray(position, item.position, [self, item], 1)
			
		if !sight_check.empty():
			if in_sight.has(item):
				in_sight.erase(item); print(item, "out of sight")
				
				if in_interaction_range.has(item) and interactable.has(item):
					interactable.erase(item); print(item, "uninteractable")
		else:
			if !in_sight.has(item):
				in_sight.push_back(item); print(item, "in sight")
		
			if in_interaction_range.has(item) and !interactable.has(item):
				interactable.push_back(item); print(item, "interactable")

func scale_sight_range(delta):
	var area = $SightArea/AreaShape.shape
	var radius :float = area.get_radius()
	var lightscale : float = $Light.get_texture_scale()
	var speed : float = default_scaling_speed
	
	if radius > sight_range:
		# print(radius, " ", 3500*lightscale/2)
		area.set_radius(radius - 0.5*speed*delta)
		$Light.set_texture_scale(lightscale - speed/mask_width*delta)
		radius = area.get_radius()
		if radius < sight_range:
			area.set_radius(sight_range)
			$Light.set_texture_scale(sight_range/mask_width*2)
			
	else: if radius < sight_range:
		# print(radius, " ", 3500*lightscale/2)
		area.set_radius(radius + 0.5*speed*delta)
		$Light.set_texture_scale(lightscale + speed/mask_width*delta)
		radius = area.get_radius()
		if radius > sight_range:
			area.set_radius(sight_range)
			$Light.set_texture_scale(sight_range/mask_width*2)

func _physics_process(delta):
	get_input()
	player_velocity = move_and_slide(player_velocity)
	in_direct_line()
	scale_sight_range(delta)

func _ready():
	$SightArea/AreaShape.shape.set_radius(default_sight_range)
	$Light.set_texture_scale(default_sight_range/mask_width*2)
	pass

func on_sight_area_enter(body):
		if body.is_in_group("entities") and body != self:
			in_sight_range.push_back(body)
			print(body, "in sight range")

func on_sight_area_exit(body):
	if body.is_in_group("entities"):
		in_sight_range.erase(body)
		print(body, "out of sight range")

func _on_interaction_area_enter(body):
	if body.is_in_group("interactable") and body != self:
			in_interaction_range.push_back(body)
			print(body, "in interaction range")

func on_interaction_area_exit(body):
	if body.is_in_group("interactable"):
		in_interaction_range.erase(body)
		print(body, "out of interaction range")
