extends Node

class_name NetworkManager

var world := preload('res://scenes/school.tscn').instance()
var player_characters := Dictionary()
var own_player = null
var own_id := 0
var server_key := ""

# warning-ignore:unused_signal
signal joined_room()
# warning-ignore:unused_signal
signal left_room()

func create_world(config):
	server_key = config.key
	add_child(world)

func display_key(key):
	server_key = key

