extends TextureButton

var pickedUp = false
var clickOffset = Vector2()

func _ready():
	self.connect("button_down", self, "pickUp")
	self.connect("button_up", self, "drop")

func _process(_delta):
	if pickedUp:
		self.rect_position = get_viewport().get_mouse_position() + clickOffset

func pickUp():
	pickedUp = true
	clickOffset = self.rect_position - get_viewport().get_mouse_position()

func drop():
	pickedUp = false
