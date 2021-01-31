extends Control

export var Pcolor:Color

func _ready():
	$Polygon2D.color = Pcolor
	pass

func anim():
	$AnimationPlayer.play("mniej")

func reset():
	$AnimationPlayer.play("mniej")
	$AnimationPlayer.advance(0)
	$AnimationPlayer.stop()
