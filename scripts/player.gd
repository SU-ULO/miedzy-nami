extends "dummy.gd"

func get_input():
	player_velocity = Vector2()
  
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
		
	if Input.is_action_just_pressed("ui_select"):
		print("ui_select clicked")
		
		if(interactable.size() != 0):
			var currentBestItem = interactable[0]
			var currentBestDistance = compute_distance(currentBestItem)
			
			for item in interactable:
				if(compute_distance(item) < currentBestDistance):
					currentBestItem = item
			
			currentBestItem.Interact()
			
	if Input.is_action_just_pressed("set_fov"):
		if(fov_toggle):
			sight_range = 500
		else:
			sight_range = 2000
		fov_toggle = !fov_toggle
	
	if player_velocity.y == 0 && player_velocity.x == 0:
		$Sprite.visible = true
		$Sprite.flip_h = flipped
		$AnimatedSprite.visible = false
		
	player_velocity = player_velocity.normalized() * default_speed

func _physics_process(_delta):
	get_input()
	pass

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
