extends KinematicBody2D

class_name Dummyplayer

var owner_id := 0
var username := ""

var dead := false

export var default_speed := 900.0
export var default_sight_range := 2000.0
export var default_scaling_speed := 2000.0

# debug mode for visibility checking
var debug_mode := false
var debug_pos_collided := []
var debug_pos_ok := []

var color := 3
var currLook := LookConfiguration.new()

var player_velocity = Vector2()
var in_sight_range = []; var in_interaction_range = []

var in_sight := []
var interactable := []
var players_interactable := []
var deadbody_interactable := []

var flipped := false
var moveX :int
var moveY :int
var joystickUsed = false
var joystick_direction = Vector2()
var currentInteraction = null
var localTaskList := []

var dead_body := preload("res://entities/deadbody.tscn")
var interacted := false # temporary fix

func generate_init_data() -> Dictionary:
	return {"username": username, "pos": position, "dead": dead, "imp": is_in_group("impostors")}

func set_init_data(data: Dictionary):
	username=data["username"]
	position=data["pos"]
	dead=data["dead"]
	if data["imp"]: add_to_group("impostors")

func generate_sync_data():
	return {"mov": Vector2(moveX, moveY), "pos": position}

func set_sync_data(data: Dictionary):
	moveX=data["mov"].x
	moveY=data["mov"].y
	position=data["pos"]

func _ready():
	
	add_to_group("players")
	add_to_group("entities")	
	$sprites.loadLook()
	$Label.text = username
	pass

# process functions
func _process(_delta):
	if debug_mode: update()
	set_player_velocity()
func _physics_process(_delta):
	player_velocity = move_and_slide(player_velocity)

func set_player_velocity():
	if !joystickUsed:
		player_velocity.x = moveX
		player_velocity.y = moveY
		
		if(currentInteraction == null):
		
			if player_velocity.x == 0 && player_velocity.y == 0:
				#$Sprite.visible = true
				$sprites.stopWalk()
				$Sprite.flip_h = flipped
				$AnimatedSprite.visible = false
			else:
				$sprites.startWalk()
				#$AnimatedSprite.visible = true
				#$Sprite.visible = false
				if player_velocity.x == 1:
					$AnimatedSprite.flip_h = flipped
					flipped = false
					$sprites.lookRight()
				else: if player_velocity.x == -1:
					$AnimatedSprite.flip_h = flipped
					flipped = true
					$sprites.lookLeft()
				elif player_velocity.y == 1:
					$sprites.lookFront()
				elif player_velocity.y == -1:
					$sprites.lookBack()
					#$sprites.lookLeft() 

			player_velocity = player_velocity.normalized() * default_speed
	else:
		if joystick_direction.x == 0 && joystick_direction.y == 0:
			$sprites.stopWalk()
		else:
			$sprites.startWalk()
			if joystick_direction.y >=0:
				if joystick_direction.x >= 0:
					if joystick_direction.y > joystick_direction.x:
						$sprites.lookFront()
					else:
						$sprites.lookRight()
				else:
					if joystick_direction.y > -joystick_direction.x:
						$sprites.lookFront()
					else:
						$sprites.lookLeft()
			else:
				if joystick_direction.x >= 0:
					if -joystick_direction.y > joystick_direction.x:
						$sprites.lookBack()
					else:
						$sprites.lookRight()
				else:
					if -joystick_direction.y > -joystick_direction.x:
						$sprites.lookBack()
					else:
						$sprites.lookLeft()							
		player_velocity = joystick_direction.normalized() * default_speed
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
		
	else: if body.is_in_group("players") \
		and self.is_in_group("impostors") \
		and body != self and !body.is_in_group("impostors") \
		and !body.is_in_group("rip"):
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
	print(body.username, " wants to kill", self.username)
	body.get_node("KillCooldown").start()
	body.position = self.position
	get_tree().get_root().get_node("Start").network.request_kill(owner_id)
	interacted = false

func turn_into_corpse(pos: Vector2):
	add_to_group("rip")
	var instance = dead_body.instance()
	instance.position = pos
	instance.lateOwner = owner_id
	instance.get_node("sprites").currLook = currLook.duplicate()
	instance.get_node("sprites").currLook.eye = "sad_closed"
	instance.get_node("sprites").currLook.mouth = "sad closed"
	instance.color = color
	instance.get_node("sprites").loadLook()
	instance.get_node("sprites").stopWalk()
	get_parent().add_child(instance)
	self.visible = 0

func EndInteraction(_body):
	print("you cant be unkilled, how unfortunate")
	# body.currentInteraction = null

func handle_sabotage(type):
	pass

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

