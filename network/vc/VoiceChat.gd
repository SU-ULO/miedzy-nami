extends Node

class_name VoiceChat

var available := false

signal offer(offer, id)
signal answer(answer, id)
signal candidate(candidate, id)

func _ready():
	if OS.has_feature('JavaScript'):
		var f := File.new()
		if f.open("res://network/vc/vc.js", File.READ) == OK:
			JavaScript.eval(f.get_as_text(), true)
			f.close()
			available=true
	askforstream()

func _input(event):
	if available:
		if event.is_action_pressed("vc_push_to_talk"):
			pass
		elif event.is_action_released("vc_push_to_talk"):
			pass

func askforstream():
	if !available: return
	JavaScript.eval("askforstream()", true)

func audiotest(play: bool = true):
	if !available: return
	JavaScript.eval("soundtest("+("true" if play else "false")+")", true)

var time := 0.0
func _process(delta):
	if time >= 1:
		print(JavaScript.eval("poll()", true))
		time=0.0
	time+=delta
