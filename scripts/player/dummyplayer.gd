extends KinematicBody2D

export var default_speed = 900.0
export var default_sight_range = 2000.0
export var default_scaling_speed = 2000.0

var debug_mode = false # debug mode for visibility checking
var debug_pos_collided = []
var debug_pos_ok = []


const LookConfiguration = preload("res://entities/character-customisation/look-configuration.gd")		

var color = 1
var currLook = LookConfiguration.new()

var player_velocity = Vector2()
var in_sight_range = []; var in_interaction_range = []
var in_sight = []; var interactable = []
var flipped = false
var moveX :int
var moveY :int
var currentInteraction = null
var localTaskList = []

func _ready():
	add_to_group("entities")
	pass
	
func _physics_process(_delta):
	if debug_mode: update()
	set_player_velocity()
	player_velocity = move_and_slide(player_velocity)
	check_line_of_sight()
	check_interaction()

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
		if !in_sight.has(item):
			if interactable.has(item):
				interactable.erase(item);
				if debug_mode: print(item.get_name(), " removed from: interactable")
		else:
			if !interactable.has(item):
				interactable.push_back(item);
				if debug_mode: print(item.get_name(), " added to: interactable")

func set_player_velocity():
	player_velocity.x = moveX
	player_velocity.y = moveY
	
	if(currentInteraction == null):
	
		if player_velocity.x == 0 && player_velocity.y == 0:
			$Sprite.visible = true
			$Sprite.flip_h = flipped
			$AnimatedSprite.visible = false
		else:
			$AnimatedSprite.visible = true
			$Sprite.visible = false
		
			if player_velocity.x == 1:
				$AnimatedSprite.flip_h = flipped
				flipped = false
			else: if player_velocity.x == -1:
				$AnimatedSprite.flip_h = flipped
				flipped = true
		
		player_velocity = player_velocity.normalized() * default_speed

func ui_selected():
	print(in_sight_range)
	print(in_sight)
	if(interactable.size() != 0):
		var currentBestItem = interactable[0]
		var currentBestDistance = compute_distance(currentBestItem)
			
		for item in interactable:
			if(compute_distance(item) < currentBestDistance):
				currentBestItem = item
			
		if currentBestItem.is_in_group("vents"):
			currentBestItem.enter(self)
		else: if currentBestItem.is_in_group("cameras"):
			currentBestItem.open(self)
		else:
			currentBestItem.Interact()
		currentInteraction = currentBestItem

func ui_canceled():
	if(currentInteraction != null):
		if currentInteraction.is_in_group("vents"):
			currentInteraction.exit(self)
		else: if currentInteraction.is_in_group("cameras"):
			currentInteraction.close(self)
		else:
			currentInteraction.EndInteraction()
		currentInteraction = null

func on_sight_area_enter(body):
		if body.is_in_group("entities") and body != self:
			in_sight_range.push_back(body)
			if debug_mode: print(body.get_name(), " added to: sight range")

func on_sight_area_exit(body):
	if body.is_in_group("entities"):
		in_sight_range.erase(body)
		if in_sight.has(body):
			in_sight.erase(body)
			if debug_mode: print(body.get_name(), " removed from: sight")
		if debug_mode: print(body.get_name(), " removed from: sight range")

func _on_interaction_area_enter(body):
	if body.is_in_group("interactable") and body != self:
			in_interaction_range.push_back(body)
			if debug_mode: print(body.get_name(), " added to: interaction range")

func on_interaction_area_exit(body):
	if body.is_in_group("interactable"):
		in_interaction_range.erase(body)
		if interactable.has(body):
			interactable.erase(body)
			if debug_mode: print(body.get_name(), " removed from: interaction")
		if debug_mode: print(body.get_name(), " removed from: interaction range")

func compute_distance(item):
	return sqrt(pow(item.position.x - self.position.x, 2) + pow(item.position.y - self.position.y, 2))
	
func _draw():
	if debug_mode:
		draw_circle(Vector2(), get_node("SightArea").get_child(0).shape.radius, Color(1, 1, 0, 0.3))
		for item in debug_pos_collided:
			draw_line(Vector2(), item-position, Color("#FF0000"))
		for item in debug_pos_ok:
			draw_line(Vector2(), item-position, Color("#00FF00"))
		debug_pos_collided.clear()
		debug_pos_ok.clear()

func loadLook():
	if currLook.hasBottom:
		$spodnie.visible = true
	else:
		$spodnie.visible = false
	
	$body.frames.add_frame("walk side", load(currLook.getBodyPath(2)))
	$body.frames.add_frame("walk side", load(currLook.getBodyPath(1)))
	$body.frames.add_frame("walk side", load(currLook.getBodyPath(3)))
	$body.frames.add_frame("walk side", load(currLook.getBodyPath(1)))
	$body.frames.add_frame("walk front", load(currLook.getBodyPath(4)))
	$"clothes-top".frames.add_frame("walk front", load(currLook.getTopClotes(2, color)))
	$"clothes-top".frames.add_frame("walk front", load(currLook.getTopClotes(1, color)))
	$"clothes-top".frames.add_frame("walk front", load(currLook.getTopClotes(3, color)))
	$"clothes-top".frames.add_frame("walk front", load(currLook.getTopClotes(1, color)))
	$face.texture = load(currLook.getSkinPath())
	$face/eyes.frames.add_frame("front", load(currLook.getEyePath(1)))
	if currLook.getEyeBonusPath() != "przykromi":
		$"face/eyes/eye-bonus".visible = true
		$"face/eyes/eye-bonus".frames.add_frame("front", load(currLook.getEyeBonusPath(1)))
	else:
		$"face/eyes/eye-bonus".visible = false
	$spodnie.playing = 1
	$"clothes-top".playing = 1
