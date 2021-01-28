extends Game_Connection

class_name JoinedServer


func _init(conf: Dictionary).(conf):
	pass

func _ready():
	peer.create_offer()
