extends TextureRect

export var colorr = Color("#c0412c") setget set_colorr
# bo color bylo zajete :(

func set_colorr(new_color):
	colorr = new_color
	$Polygon2D.color = colorr
	
func get_colorr():
	return colorr

func _ready():
	pass
