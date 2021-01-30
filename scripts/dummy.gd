extends KinematicBody2D

export var default_speed = 900.0
export var default_sight_range = 2000.0
export var default_scaling_speed = 2000.0

var player_velocity = Vector2()
var in_sight_range = []; var in_interaction_range = []
var in_sight = []; var interactable = []
var fov_toggle = true #temporarily
var flipped = false

onready var mask_width = $Light.get_texture().get_width()
onready var sight_range :float = default_sight_range

func _ready():
	add_to_group("entities")
	$SightArea/AreaShape.shape.set_radius(default_sight_range)
	$Light.set_texture_scale(default_sight_range/mask_width*2)
	pass
	
func _physics_process(delta):
	player_velocity = move_and_slide(player_velocity)
	check_line_of_sight()
	check_interaction()
	scale_sight_range(delta)

func check_line_of_sight():
	for item in in_sight_range:	
		var space_state = get_world_2d().direct_space_state
		var sight_check = space_state.intersect_ray(position, item.position, [self, item], 1)
			
		if !sight_check.empty():
			if in_sight.has(item):
				in_sight.erase(item); print(item.get_name(), " removed from: sight")
		else:
			if !in_sight.has(item):
				in_sight.push_back(item); print(item.get_name(), " added to: sight")

func check_interaction():
	for item in in_interaction_range:
		if !in_sight.has(item):
			if interactable.has(item):
				interactable.erase(item); print(item.get_name(), " removed from: interactable")
		else:
			if !interactable.has(item):
				interactable.push_back(item); print(item.get_name(), " added to: interactable")

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
