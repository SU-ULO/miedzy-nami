extends Game_Connection

class_name JoinedClient

var joined := false
var player = null

func _init(conf: Dictionary).(conf):
	pass

func _ready():
# warning-ignore:return_value_discarded
	connect("success", self, "request_join")

func get_init_data() -> Dictionary:
	return {"username": config.username, "pos": player.position}

func get_update_data() -> Dictionary:
	return {"pos": player.position, "mov": Vector2(player.moveX, player.moveY)}

func request_join():
	emit_signal("join")

func handle_updates(input):
	if input is Dictionary:
		if input.has("mov") and input["mov"] is Vector2:
			if player:
				player.moveX=input["mov"].x
				player.moveY=input["mov"].y
		if input.has("pos") and input["pos"] is Vector2:
			if player:
				player.position=input["pos"]
