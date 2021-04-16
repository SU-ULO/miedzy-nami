extends LineEdit

export var text_id := ""

func _ready():
	if TouchscreenKeyboard.available:
# warning-ignore:return_value_discarded
		connect("focus_entered", self, "js_text_entry")
# warning-ignore:return_value_discarded
		connect("focus_exited", TouchscreenKeyboard, "end_input")
# warning-ignore:return_value_discarded
		TouchscreenKeyboard.connect("text", self, "handle_text_keyboard")

func js_text_entry():
	TouchscreenKeyboard.start_input(text_id, text)

func handle_text_keyboard(keyboardtext: String, id: String):
	if id==text_id:
		text=keyboardtext
	else:
		release_focus()

func on_focus(state):
	Globals.start.network.own_player.chat_focused = state
