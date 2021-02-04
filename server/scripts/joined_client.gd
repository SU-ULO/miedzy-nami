extends Game_Connection

class_name JoinedClient

func _init(conf: Dictionary).(conf):
	pass

func _ready():
	connect("success", self, "spawn_player")

func spawn_player():
	emit_signal("join")
	send_init([0, {"username": config.username}])
