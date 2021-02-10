extends Game_Connection

class_name JoinedClient

func _init(conf: Dictionary).(conf):
	pass

func _ready():
# warning-ignore:return_value_discarded
	connect("success", self, "spawn_player")

func spawn_player():
	emit_signal("join")
	while send_events([0, {"username": config.username}])!=OK:
		pass
