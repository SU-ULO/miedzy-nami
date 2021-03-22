extends StaticBody2D


func _ready():
	$AnimatedSprite.playing = false
	$AnimatedSprite.frame = 0
func close_door():
	$AnimationPlayer.play("close")
	$AnimatedSprite.animation = "close"
	$AnimatedSprite.playing = true

func open_door():
	$AnimationPlayer.play_backwards("close")
	$AnimatedSprite.animation = "open"
	$AnimatedSprite.playing = true
