extends LineEdit

func _ready():
	if TouchscreenKeyboard.available:
# warning-ignore:return_value_discarded
		connect("focus_entered", self, "js_text_entry")

func js_text_entry():
	print("clicked")
