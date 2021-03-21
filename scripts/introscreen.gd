extends Node2D

signal finish()

var player_offset = 250
var dummy = preload("res://entities/dummyplayer.tscn")
var players = [dummy.instance(), dummy.instance(), dummy.instance(), dummy.instance(), dummy.instance(), dummy.instance(),dummy.instance()] # to be replaced with real players

func _ready():
	$Timer.start()
	#load players
	var offset = (float(players.size()) / 2.0)
	$players.global_position.x -= offset * player_offset * $players.scale.x
	var pos = 0
	for i in players:
		var x = dummy.instance()
		x.currLook = i.currLook
		$players.add_child(x)
		x.position.x = pos
		pos+=player_offset
		x.get_node("sprites").loadLook()
	$AnimationPlayer.play("fade")

	

func _on_Timer_timeout():
	for i in $players.get_children():
		i.queue_free()
	emit_signal("finish")
