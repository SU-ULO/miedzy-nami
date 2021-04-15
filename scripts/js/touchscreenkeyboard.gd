extends Node

var available := false

signal text(text, id)

func _ready():
	if OS.has_feature('JavaScript'):
		var f := File.new()
		if f.open("res://scripts/js/touchscreenkeyboard.js", File.READ) == OK:
			JavaScript.eval(f.get_as_text(), true)
			f.close()
			if JavaScript.eval('setup_touchscreen_keyboard()', true):
				available=true

func start_input(id: String, text: String):
	if !available: return
	JavaScript.eval('start_input("%s", "%s")' % [id, text], true)

func end_input():
	if !available: return
	JavaScript.eval('end_input()', true)

var time := 0
func _process(delta):
	if !available: return
	if time >= 0.1:
		var polled = JavaScript.eval('poll_input()', true)
		if polled:
			var res := JSON.parse(polled)
			if res.error == OK:
				var arr = res.result
				if arr is Array:
					emit_signal("text", arr[0], arr[1])
		time=0
	time+=delta
