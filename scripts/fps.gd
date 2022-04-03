extends Label

func _process(_delta) -> void:
	set_text("FPS: " + String(Engine.get_frames_per_second()))
