extends StaticBody2D


func _ready():
	$AnimatedSprite.playing = false
	$AnimatedSprite.frame = 0
func close_door():
	$AnimationPlayer.play("close")
	$AnimatedSprite.animation = "close"
	$AnimatedSprite.playing = true
	$Timer.start(10)
	yield($Timer, "timeout")
	open_door()
	get_tree().get_root().get_node("Start").network.request_end_sabotage(2)


func open_door():
	$AnimationPlayer.play_backwards("close")
	$AnimatedSprite.animation = "open"
	$AnimatedSprite.playing = true
