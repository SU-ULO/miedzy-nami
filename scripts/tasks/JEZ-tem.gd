extends Sprite

var pickedUp = false
var clickDelta = Vector2()
var in_place = false

func _ready():
	#warning-ignore: return_value_discarded
	$TextureButton.connect("button_down", self, "pickUp")
	#warning-ignore: return_value_discarded
	$TextureButton.connect("button_up", self, "drop")

func _process(_delta):
	if pickedUp:
		position = get_viewport().get_mouse_position() + clickDelta

func pickUp():
	pickedUp = true
	clickDelta =  position - get_viewport().get_mouse_position()
	
func drop():
	pickedUp = false
	if (position - get_parent().get_node(name + "-pos").position).length_squared() < 1200:
		position =  get_parent().get_node(name + "-pos").position
		if !in_place:
			get_parent().im_good()
			in_place = true
	else:
		if in_place:
			get_parent().im_bad()
			in_place = false
