extends Game_Connection

class_name JoinedServer

signal password

func _init(conf: Dictionary).(conf):
	pass

func _ready():
	peer.create_offer()
