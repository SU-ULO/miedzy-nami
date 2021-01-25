extends TextureButton

signal clicked(button)

export var colorr = Color("#000000") setget set_colorr
# bo color bylo zajete :(

func set_colorr(new_color):
	colorr = new_color
	$Polygon2D.color = colorr
	
func get_colorr():
	return colorr

func _ready():
	pass
	
func press(noclick):
	if(!self.pressed):
		$Polygon2D.position += Vector2(0, 170)
	else:
		$Polygon2D.position += Vector2(0, -170)
	if noclick: self.pressed = !self.pressed
	
func _on_TextureButton_button_down():
	press(false)
	emit_signal("clicked", self)
