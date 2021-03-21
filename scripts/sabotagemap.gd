extends Control

#icons are temporary

signal sabotage(name)
signal exit()

func _ready():
	for i in get_children():
		i.connect("pressed", self, "sabotage_start", [i.name])

func sabotage_start(name):
	pass


func _on_exit_pressed():
	emit_signal("exit")
