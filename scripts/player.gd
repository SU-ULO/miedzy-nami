extends "dummy.gd"

onready var entities = get_tree().get_nodes_in_group("entities")

export var default_speed = 900.0
var player_velocity = Vector2()
var in_range = []
var in_sight = []

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
		
	if Input.is_action_pressed("move_down"):
		$AnimatedSprite.visible = true
		$Sprite.visible = false
		player_velocity.y += 1
		
	if player_velocity.y == 0 && player_velocity.x == 0:
		$Sprite.visible = true
		if flipped == $Sprite.is_flipped_h():
			$Sprite.flip_h = flipped
		$AnimatedSprite.visible = false
		
	player_velocity = player_velocity.normalized() * default_speed

func in_sight_check():
	
	for item in in_range:
		var space_state = get_world_2d().direct_space_state
		var sight_check = space_state.intersect_ray(position, item.position, [self, item], 1)
		if in_sight.has(item):
			if !sight_check.empty():
				in_sight.erase(item)
				print( item, "out of sight")
		else:
			if sight_check.empty():
				in_sight.push_back(item)
				print( item, "in sight")
	

func _physics_process(delta):
	get_input()
	player_velocity = move_and_slide(player_velocity)
	in_sight_check()

func _ready():
	pass

func _on_Area2D_body_entered(body):
	if body.is_in_group("entities"):
		in_range.push_back(body)
		print( body, "in range")
	

func _on_Area2D_body_exited(body):
	if body.is_in_group("entities"):
		in_range.erase(body)
		if in_sight.has(body):
			in_sight.erase(body)
			print( body, "out of sight")
		print( body, "out of range")
	
