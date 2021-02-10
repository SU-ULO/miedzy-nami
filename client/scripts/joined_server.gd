extends Game_Connection

class_name JoinedServer

var world := preload('res://scenes/school.tscn').instance()
var own_player

func _init(conf: Dictionary).(conf):
	pass

func _ready():
	peer.create_offer()
# warning-ignore:return_value_discarded
	connect("success", self, "spawn_map")

func spawn_map():
	add_child(world)

func leave():
	.leave()
	remove_child(world)

func spawn_player():
	pass

func handle_events(input):
	if input is Array:
		if input.size()==2:
			if input[0]==0 and input[1] is Dictionary:
				own_player=preload('res://entities/player.tscn').instance()
				world.get_node("Mapa/YSort").add_child(own_player)
				emit_signal("join")
