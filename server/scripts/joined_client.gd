extends Game_Connection

class_name JoinedClient

func _init(conf: Dictionary).(conf):
	pass

func _ready():
# warning-ignore:return_value_discarded
	connect("success", self, "spawn_player")

func get_init_data() -> Dictionary:
	return {"username": config.username}

func spawn_player():
	emit_signal("join")
	send_events([0, get_init_data()])
