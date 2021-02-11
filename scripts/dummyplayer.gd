extends KinematicBody2D

export var default_speed = 900.0
export var default_sight_range = 2000.0
export var default_scaling_speed = 2000.0

var player_velocity = Vector2()
var in_sight_range = []; var in_interaction_range = []
var in_sight = []; var interactable = []
var flipped = false
var moveX :int
var moveY :int
var currentInteraction = null

func _ready():
	add_to_group("entities")
	pass
	
func _physics_process(_delta):
	set_player_velocity()
	player_velocity = move_and_slide(player_velocity)
	check_line_of_sight()
	check_interaction()

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

func set_player_velocity():
	player_velocity.x = moveX
	player_velocity.y = moveY
	
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
	if(interactable.size() != 0):
		var currentBestItem = interactable[0]
		var currentBestDistance = compute_distance(currentBestItem)
			
		for item in interactable:
			if(compute_distance(item) < currentBestDistance):
				currentBestItem = item
			
		currentBestItem.Interact()
		currentInteraction = currentBestItem
		
func ui_canceled():
	if(currentInteraction != null):
		currentInteraction.EndInteraction()
		currentInteraction = null

func on_sight_area_enter(body):
		if body.is_in_group("entities") and body != self:
			in_sight_range.push_back(body)
			print(body.get_name(), " added to: sight range")

func on_sight_area_exit(body):
	if body.is_in_group("entities"):
		in_sight_range.erase(body)
		if in_sight.has(body):
			in_sight.erase(body)
			print(body.get_name(), " removed from: sight")
		print(body.get_name(), " removed from: sight range")

func _on_interaction_area_enter(body):
	if body.is_in_group("interactable") and body != self:
			in_interaction_range.push_back(body)
			print(body.get_name(), " added to: interaction range")

func on_interaction_area_exit(body):
	if body.is_in_group("interactable"):
		in_interaction_range.erase(body)
		if interactable.has(body):
			interactable.erase(body)
			print(body.get_name(), " removed from: interaction")
		print(body.get_name(), " removed from: interaction range")

func compute_distance(item):
	return sqrt(pow(item.position.x - self.position.x, 2) + pow(item.position.y - self.position.y, 2))
