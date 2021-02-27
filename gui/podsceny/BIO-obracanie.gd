extends TextureButton

onready var rotation = self.rotation
onready var posmarker = get_node("Middle").position
onready var dot = get_node("Dot")

# some magic values
const radius:float = 85.0
const elipsefy:float = 1.2

var clockwise:bool = true
var prevangle:float = 0.0
var hovered = false
var full_rotations = 0

func move_dot(angle):
	
	if angle <= -0.75*PI and prevangle >= 0.75*PI:
		full_rotations += 1
		clockwise = true
	else: if prevangle <= -0.75*PI and angle >= 0.75*PI:
		full_rotations -= 1
		clockwise = false
	else: if prevangle > angle: clockwise = true
	else: clockwise = false
	
	prevangle = angle
	
	dot.set_position(Vector2(posmarker.x + radius * cos(angle) * elipsefy, posmarker.y + radius * sin(angle)))

func _process(_delta):
	if self.pressed and hovered:
		var mausepos = get_local_mouse_position()
		var angle = mausepos.angle_to_point(posmarker)
		move_dot(angle)
		
# scroll support :D
func _input(event):
	if hovered and event is InputEventMouseButton and event.is_pressed() and !self.pressed:
		if event.button_index == BUTTON_WHEEL_UP:
			clockwise = true
			move_dot(prevangle + 1)
		if event.button_index == BUTTON_WHEEL_DOWN:
			clockwise = false
			move_dot(prevangle - 1)

func _on_Control_mouse_entered():
	hovered = true

func _on_Control_mouse_exited():
	hovered = false
