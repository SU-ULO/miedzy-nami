extends TextureButton

# 1 is mic off

var on_icon := preload("res://textures/mic-on.png")
var off_icon := preload("res://textures/mic-off.png")

func _ready():
# warning-ignore:return_value_discarded
	connect("button_down", VoiceChat, "button_down")
# warning-ignore:return_value_discarded
	connect("button_up", VoiceChat, "button_up")
# warning-ignore:return_value_discarded
	VoiceChat.connect("speaking", self, "set_speaking")
	set_speaking(VoiceChat.isunmuted())

func set_speaking(state: bool = false):
	texture_normal = on_icon if state else off_icon
