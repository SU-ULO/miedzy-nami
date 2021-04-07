extends TextureButton

# 1 is mic off

func set_mute(state: bool = false):
	pressed = state
	
func get_mute():
	return pressed
	
func toggle():
	pressed = !pressed
