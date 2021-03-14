extends KinematicBody2D

export var default_speed = 900.0
export var default_sight_range = 2000.0
export var default_scaling_speed = 2000.0

# debug mode for visibility checking
var debug_mode = false
var debug_pos_collided = []
var debug_pos_ok = []

var player_velocity = Vector2()
var in_sight_range = []; var in_interaction_range = []
var in_sight = []; var interactable = []; var players_interactable = []; var deadbody_interactable = []
var flipped = false
var moveX :int
var moveY :int
var currentInteraction = null
var localTaskList = []

var dead_body = preload("res://entities/deadbody.tscn")
var interacted = false # temporary fix

func _ready():
	add_to_group("entities")
	add_to_group("players")
	pass

# process functions

func _physics_process(_delta):
	if debug_mode: update()
	set_player_velocity()
	player_velocity = move_and_slide(player_velocity)


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

# interactions

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

func ui_kill():
	if(players_interactable.size() != 0):
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
		if currentInteraction.is_in_group("tasks"):
			currentInteraction.EndInteraction()
		else:
			currentInteraction.EndInteraction(self)
		print(currentInteraction.get_name())
		currentInteraction = null

# sight and interaction areas

func on_sight_area_enter(body):
	if body.is_in_group("entities"):
		in_sight_range.push_back(body)
		if debug_mode: print(body.get_name(), " added to: sight range")

func on_sight_area_exit(body):
	if in_sight_range.has(body):
		in_sight_range.erase(body)
		if debug_mode: print(body.get_name(), " removed from: sight range")
		
		if in_sight.has(body):
			in_sight.erase(body)
			if debug_mode: print(body.get_name(), " removed from: sight")

func _on_interaction_area_enter(body):
	if body.is_in_group("interactable"):
		in_interaction_range.push_back(body)
		if debug_mode: print(body.get_name(), " added to: interaction range")
		
	else: if body.is_in_group("players") and self.is_in_group("impostors") and body != self and !body.is_in_group("impostors") and !body.is_in_group("rip"):
		in_interaction_range.push_back(body)
		if debug_mode: print(body.get_name(), " added to: interaction range")

func on_interaction_area_exit(body):
	if in_interaction_range.has(body): 
		in_interaction_range.erase(body)
		if debug_mode: print(body.get_name(), " removed from: interaction range")
		
		if interactable.has(body):
			interactable.erase(body)
			if debug_mode: print(body.get_name(), " removed from: interaction")
		if players_interactable.has(body):
			players_interactable.erase(body)
			if debug_mode: print(body.get_name(), " removed from: players_interaction")
		if deadbody_interactable.has(body):
			deadbody_interactable.erase(body)
			if debug_mode: print(body.get_name(), " removed from: deadbody_interaction")
# decection via camera

func camera_visibility(body, status):
	if status == 1 and !in_sight.has(body):
		in_sight.push_back(body)
		if debug_mode: print(body.get_name(), " entered camera")
	if status == 0 and in_sight.has(body):
		in_sight.erase(body)
		if debug_mode: print(body.get_name(), " exited camera")

# get shreked

func Interact(body):
	interacted = true
	print(body.get_name(), " killed ", self.get_name())
	add_to_group("rip")
	body.get_node("KillCooldown").start()
	var instance = dead_body.instance()
	get_parent().add_child(instance)
	instance.position = self.position
	body.position = self.position
	self.visible = 0 # <- tutaj sygnał do serwera i jakieś bezpieczne usunięcie
	interacted = false
	
# warning-ignore:unused_argument
func EndInteraction(body):
	print("you cant be unkilled, how unfortunate")
	# body.currentInteraction = null

# draw for debug

func _draw():
	if debug_mode:
		draw_circle(Vector2(), get_node("SightArea").get_child(0).shape.radius, Color(1, 1, 0, 0.3))
		for item in debug_pos_collided:
			draw_line(Vector2(), item-position, Color("#FF0000"))
		for item in debug_pos_ok:
			draw_line(Vector2(), item-position, Color("#00FF00"))
		debug_pos_collided.clear()
		debug_pos_ok.clear()
