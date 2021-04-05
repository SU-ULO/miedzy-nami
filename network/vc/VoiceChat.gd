extends Node

class_name VoiceChat

var available := false

var webrtc := JSON.print({"iceServers":[{"urls":["stun:stun.l.google.com:19302"]}]})
var own_id := -1
var speaking_ids := 0

signal offer(offer, id)
signal answer(answer, id)
signal candidate(candidate, id)
signal speaking(isspeaking)

func _ready():
	if OS.has_feature('JavaScript'):
		var f := File.new()
		if f.open("res://network/vc/vc.js", File.READ) == OK:
			JavaScript.eval(f.get_as_text(), true)
			f.close()
			available=true
	askforstream()

func setmute(mute: bool):
	if available:
		if mute:
			JavaScript.eval("setmute(true)", true)
		else:
			JavaScript.eval("setmute(false)", true)
		emit_signal("speaking", !mute)

func _input(event):
	if available:
		if event.is_action_pressed("vc_push_to_talk"):
			setmute(false)
		elif event.is_action_released("vc_push_to_talk"):
			setmute(true)

func askforstream():
	if !available: return
	JavaScript.eval("askforstream()", true)

func audiotest(play: bool = true):
	if !available: return
	JavaScript.eval("soundtest("+("true" if play else "false")+")", true)

func addpeer(id: int):
	if !available: return
	JavaScript.eval("addpeer("+String(id)+","+webrtc+")", true)
	if id<own_id:
		JavaScript.eval("callpeer("+String(id)+")", true)

func removepeer(id: int):
	if !available: return
	JavaScript.eval("removepeer("+String(id)+")", true)
	setremotespeaking(false, id)

func clearpeers():
	if !available: return
	JavaScript.eval("clearpeers()", true)
	speaking_ids=0

func set_offer(offer, id: int):
	if !available: return
	JavaScript.eval("set_offer("+JSON.print(offer)+","+String(id)+")", true)

func set_answer(answer, id: int):
	if !available: return
	JavaScript.eval("set_answer("+JSON.print(answer)+","+String(id)+")", true)

func set_candidate(candidate, id: int):
	if !available: return
	JavaScript.eval("set_candidate("+JSON.print(candidate)+","+String(id)+")", true)

func isunmuted():
	if !available: return
	return JavaScript.eval("isunmuted()", true)

func handle_poll(data: Dictionary):
	if data.has("peers"):
		var peers = data["peers"]
		for id in peers:
			var p = peers[id]
			if p.has("offer"):
				emit_signal("offer", p["offer"], int(id))
			if p.has("answer"):
				emit_signal("answer", p["answer"], int(id))
			if p.has("candidates"):
				for c in p["candidates"]:
					emit_signal("candidate", c, int(id))

var time := 0.0
func _process(delta):
	if !available: return
	if time >= 0.1:
		var polled = JavaScript.eval("poll()", true)
		if polled:
			var json = JSON.parse(polled)
			if json.error==OK:
				handle_poll(json.result)
		time=0.0
	time+=delta

func setremotespeaking(speaking: bool, id: int):
	if speaking:
		speaking_ids|=1<<id
	else:
		speaking_ids&=~(1<<id)

func is_speaking(id: int):
	return bool(speaking_ids&(1<<id))
