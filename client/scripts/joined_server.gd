extends Reference

class_name JoinedServer

var key: String = ""

func _init(conf: Dictionary):
	key = conf.key

func leave():
	pass
