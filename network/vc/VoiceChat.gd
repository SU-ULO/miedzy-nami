extends Node

var available := false

var webrtc := JSON.print({"iceServers":[{"urls":["stun:stun.l.google.com:19302"]}]})
var own_id := -1
var speaking_ids := 0
var unmuted_ids := 0
var forcedmute := false
var wantstospeak := false
var vc_mode := 0

signal offer(offer, id)
signal answer(answer, id)
signal candidate(candidate, id)
signal speaking(isspeaking)

func setwantstospeak(wants: bool):
	wantstospeak=wants
	setmute(!wantstospeak)

func update_vc_mode(mode: int = -1):
	if mode==-1:
		mode = Globals.start.menu.usersettings["vc-mode"]
	else:
		Globals.start.menu.usersettings["vc-mode"]=mode
	vc_mode = mode
	if vc_mode==0:
		wantstospeak=false
		setmute(true)
	elif vc_mode==1:
		setmute(!wantstospeak)

func _ready():
	if OS.has_feature('JavaScript'):
		var f := File.new()
		if f.open("res://network/vc/vc.js", File.READ) == OK:
			JavaScript.eval(f.get_as_text(), true)
			f.close()
			available=true

func forcemute(mute: bool):
	forcedmute = mute
	if mute:
		setmute(true)
	else:
		setmute(!wantstospeak)

func setmute(mute: bool):
	if available:
		if mute or forcedmute:
			JavaScript.eval("setmute(true)", true)
		else:
			JavaScript.eval("setmute(false)", true)
		emit_signal("speaking", isunmuted())

func button_down():
	if vc_mode==0:
		setwantstospeak(true)
	else:
		setwantstospeak(!wantstospeak)

func button_up():
	if vc_mode==0:
		wantstospeak=false
		setmute(true)

func _input(event):
	if available:
		if event.is_action_pressed("vc_push_to_talk"):
			button_down()
		elif event.is_action_released("vc_push_to_talk"):
			button_up()

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
	forcemute(false)

func set_offer(offer, id: int):
	if !available: return
	JavaScript.eval("set_offer("+JSON.print(offer)+","+String(id)+")", true)

func set_answer(answer, id: int):
	if !available: return
	JavaScript.eval("set_answer("+JSON.print(answer)+","+String(id)+")", true)

func set_candidate(candidate, id: int):
	if !available: return
	JavaScript.eval("set_candidate("+JSON.print(candidate)+","+String(id)+")", true)

func setunmutepeers(unmuted: int):
	if !available: return
	unmuted_ids=unmuted
	JavaScript.eval("setunmutepeers("+String(unmuted)+")", true)

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
			if p.has("gotstream"):
				update_vc_mode()

var time := 0.0
func _process(delta):
	if !available or own_id<0: return
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

