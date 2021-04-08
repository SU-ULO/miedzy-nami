extends TextureButton

# 1 is mic off

func _ready():
	connect("button_down", VoiceChat, "button_down")
	connect("button_up", VoiceChat, "button_up")
	VoiceChat.connect("speaking", self, "set_speaking")

func set_speaking(state: bool = false):
	pressed = !state
	
func get_mute():
	return pressed
	
func toggle():
	pressed = !pressed
