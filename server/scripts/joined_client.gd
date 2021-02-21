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
	return {"username": config.username}

func request_join():
	emit_signal("join")
