extends Node2D

signal finish()

func _ready():
	$Timer.start()
	#load players
	

func _on_Timer_timeout():
	emit_signal("finish")
