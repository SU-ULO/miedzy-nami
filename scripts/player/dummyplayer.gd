extends KinematicBody2D

var owner_id := 0
var username := ""

export var default_speed = 900.0
export var default_sight_range = 2000.0
export var default_scaling_speed = 2000.0

# debug mode for visibility checking
var debug_mode = false
var debug_pos_collided = []
var debug_pos_ok = []


const LookConfiguration = preload("res://entities/character-customisation/look-configuration.gd")		

var color = 3
var currLook = LookConfiguration.new()

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

func generate_init_data() -> Dictionary:
	return {"username": username, "pos": position}

func set_init_data(data: Dictionary):
	username=data["username"]
	position=data["pos"]

func generate_sync_data():
	return {"mov": Vector2(moveX, moveY), "pos": position}

func set_sync_data(data: Dictionary):
	moveX=data["mov"].x
	moveY=data["mov"].y
	position=data["pos"]

func _ready():
	add_to_group("players")
	add_to_group("entities")	
	loadLook()

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
			#$Sprite.visible = true
			stopWalk()
			$Sprite.flip_h = flipped
			$AnimatedSprite.visible = false
		else:
			startWalk()
			#$AnimatedSprite.visible = true
			#$Sprite.visible = false
			if player_velocity.x == 1:
				$AnimatedSprite.flip_h = flipped
				flipped = false
				lookRight()
			else: if player_velocity.x == -1:
				$AnimatedSprite.flip_h = flipped
				flipped = true
				lookLeft()
			elif player_velocity.y == 1:
				lookFront()
			elif player_velocity.y == -1:
				#lookBack()
				lookLeft() 

		player_velocity = player_velocity.normalized() * default_speed

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

func stopWalk():
	$body.playing = false
	$spodnie.playing = false
	$"clothes-top".playing = false
	$face/eyes.playing = false
	$"face/eyes/eye-bonus".playing = false
	$face/nose.playing = false
	$face/mouth.playing = false
	$body.frame = 1
	$spodnie.frame = 1
	$"clothes-top".frame = 1
	$face/eyes.frame = 1
	$"face/eyes/eye-bonus".frame = 1
	$face/nose.frame = 1
	$face/mouth.frame = 1

func startWalk():
	$body.playing = true
	$spodnie.playing = true
	$"clothes-top".playing = true
	$face/eyes.playing = true
	$"face/eyes/eye-bonus".playing = true
	$face/nose.playing = true
	$face/mouth.playing = true

func loadLook():
	if currLook.hasBottom:
		$spodnie.visible = true
	else:
		$spodnie.visible = false
	for i in $"clothes-top".frames.get_animation_names():
		$"clothes-top".frames.clear(i)

	for i in $body.frames.get_animation_names():
		$body.frames.clear(i)
		
	for i in $face/eyes.frames.get_animation_names():
		$face/eyes.frames.clear(i)
	
	for i in $"face/eyes/eye-bonus".frames.get_animation_names():
		$"face/eyes/eye-bonus".frames.clear(i)
		
	for i in $face/nose.frames.get_animation_names():
		$face/nose.frames.clear(i)
		
	for i in $face/mouth.frames.get_animation_names():
		$face/mouth.frames.clear(i)	
		
	for i in $wlosy/hair.frames.get_animation_names():
		$wlosy/hair.frames.clear(i)	
				
	$body.frames.add_frame("walk side", load(currLook.getBodyPath(2)))
	$body.frames.add_frame("walk side", load(currLook.getBodyPath(1)))
	$body.frames.add_frame("walk side", load(currLook.getBodyPath(3)))
	$body.frames.add_frame("walk side", load(currLook.getBodyPath(1)))
	$body.frames.add_frame("walk front", load(currLook.getBodyPath(4)))
	$"clothes-top".frames.add_frame("walk front", load(currLook.getTopClotes(2, color)))
	$"clothes-top".frames.add_frame("walk front", load(currLook.getTopClotes(1, color)))
	$"clothes-top".frames.add_frame("walk front", load(currLook.getTopClotes(3, color)))
	$"clothes-top".frames.add_frame("walk front", load(currLook.getTopClotes(1, color)))
	$"clothes-top".frames.add_frame("walk side", load(currLook.getTopClotes(5, color)))
	$"clothes-top".frames.add_frame("walk side", load(currLook.getTopClotes(4, color)))
	$"clothes-top".frames.add_frame("walk side", load(currLook.getTopClotes(6, color)))
	$"clothes-top".frames.add_frame("walk side", load(currLook.getTopClotes(4, color)))
	$face.texture = load(currLook.getSkinPath())
	$face/eyes.frames.add_frame("front", load(currLook.getEyePath(1)))
	$face/eyes.frames.add_frame("side", load(currLook.getEyePath(2)))
	if currLook.getEyeBonusPath() != "przykromi":
		$"face/eyes/eye-bonus".visible = true
		$"face/eyes/eye-bonus".frames.add_frame("front", load(currLook.getEyeBonusPath(1)))
		$"face/eyes/eye-bonus".frames.add_frame("side", load(currLook.getEyeBonusPath(2)))
	else:
		$"face/eyes/eye-bonus".visible = false
	$spodnie.frame = 0
	$body.frame = 0
	$"clothes-top".frame = 0
	$body.playing = 1
	$spodnie.playing = 1
	$"clothes-top".playing = 1
	$face/nose.frames.add_frame("front", load(currLook.getNosePath()))
	$face/mouth.frames.add_frame("front", load(currLook.getMouthPath()))
	$wlosy/hair.frames.add_frame("front", load(currLook.getHairPath()))
	$wlosy/hair.frames.add_frame("side", load(currLook.getHairPath(2)))
	if $wlosy/hair.animation == "side":
		$wlosy/hair.position.y = 340
		if $wlosy/hair.flip_h == false:
			$wlosy/hair.position.x = -80
		else:
			$wlosy/hair.position.x = 80
	else:
		$wlosy/hair.position.x = 0
		$wlosy/hair.position.y = currLook.getHairPos()

func lookRight():
	$wlosy/hair.position.y = 340
	$wlosy/hair.position.x = -80
	$body.flip_h = false
	$body.animation = "walk side"
	$spodnie.flip_h = false
	$spodnie.animation = "walk side"
	$"clothes-top".flip_h = false
	$"clothes-top".animation = "walk side"
	$face/eyes.animation = "side"
	$face/eyes.flip_h = false
	$"face/eyes/eye-bonus".animation = "side"
	$"face/eyes/eye-bonus".flip_h = false
	$face/nose.flip_h = false
	$face/nose.animation = "side"
	$face/mouth.animation = "right"
	$wlosy/hair.flip_h = false
	$wlosy/hair.animation  = "side"
func lookLeft():
	$wlosy/hair.position.y = 340
	$wlosy/hair.position.x = 80
	$body.flip_h = true
	$body.animation = "walk side"
	$spodnie.flip_h = true
	$spodnie.animation = "walk side"
	$"clothes-top".flip_h = true
	$"clothes-top".animation = "walk side"
	$face/eyes.animation = "side"
	$face/eyes.flip_h = true
	$"face/eyes/eye-bonus".animation = "side"
	$"face/eyes/eye-bonus".flip_h = true
	$face/nose.flip_h = true
	$face/nose.animation = "side"
	$face/mouth.animation = "left"
	$wlosy/hair.flip_h = true
	$wlosy/hair.animation  = "side"
func lookFront():
	$wlosy/hair.position.y = currLook.getHairPos()
	$wlosy/hair.position.x = 0
	$body.flip_h = false
	$body.animation = "walk front"
	$spodnie.flip_h = false
	$spodnie.animation = "walk front"
	$"clothes-top".flip_h = false
	$"clothes-top".animation = "walk front"
	$face/eyes.animation = "front"
	$"face/eyes/eye-bonus".animation = "front"
	$face/nose.flip_h = false
	$face/nose.animation = "front"
	$face/mouth.animation = "front"
	$wlosy/hair.flip_h = false
	$wlosy/hair.animation  = "front"
func lookBack():
	$body.flip_h = false
	$body.animation = "walk back"
	$spodnie.flip_h = false
	$spodnie.animation = "walk back"
	$"clothes-top".flip_h = false
	$"clothes-top".animation = "walk back"
	$face/eyes.animation = "back"
	$"face/eyes/eye-bonus".animation = "back"
	$face/nose.flip_h = false
	$face/nose.animation = "back"
	$face/mouth.animation = "back"
	$wlosy/hair.flip_h = false
	$wlosy/hair.animation  = "back"
