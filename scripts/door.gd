extends StaticBody2D


func _ready():
	$AnimatedSprite.playing = false
	$AnimatedSprite.frame = 0

func close_door():
	$AnimatedSprite.animation = "close"
	$AnimatedSprite.playing = true
	
	$occluder.visible = true
	$hitbox.disabled = false
	
	$Timer.start(10)
	yield($Timer, "timeout")
	open_door()
	get_tree().get_root().get_node("Start").network.request_end_sabotage(2)

func open_door():
	$AnimatedSprite.animation = "open"
	$AnimatedSprite.playing = true
	
	$occluder.visible = false
	$hitbox.disabled = true
