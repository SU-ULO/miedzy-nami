extends Node

var available := false

func _ready():
	if OS.has_feature('JavaScript'):
		var f := File.new()
		if f.open("res://scripts/js/touchscreenkeyboard.js", File.READ) == OK:
			JavaScript.eval(f.get_as_text(), true)
			f.close()
			if JavaScript.eval('is_touch_enabled()'):
				available=true
