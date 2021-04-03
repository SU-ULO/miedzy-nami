extends Control

# vars for win checking
var offset_set = false
var blur_set = false
var checking = false

var offset; var blur

onready var offset_knob = get_node("Knob1/Knob")
onready var blur_knob = get_node("Knob2/Knob")
onready var correct_offset = $worm.rect_position

var rng = RandomNumberGenerator.new()

const knob_sensitivity:float = 10.0 # how much rotaton changes value
const accepted_incorectness = 5 # how precise you need to be

func _ready():
	# randomize offset and blur
	rng.randomize()
	var random_offset = Vector2(rng.randf_range(100, 250) * ((rng.randi_range(0, 1) * 2) - 1), 0)
	$worm.rect_position += random_offset; offset = $worm.rect_position
	blur = rng.randf_range(10, 30) *((rng.randi_range(0, 1) * 2) - 1)

func _process(_delta):
	# get new values from knobs
	var new_offset = offset_knob.prevangle + 2*PI*offset_knob.full_rotations
	var new_blur = blur - (blur_knob.prevangle + 2*PI*blur_knob.full_rotations)
	
	# set new values to image
	$worm.rect_position.x = offset.x + new_offset * knob_sensitivity
	$worm.material.set_shader_param("radius", new_blur * knob_sensitivity * 0.1)
	
	# check win
	if abs(new_blur) < 0.6 * accepted_incorectness: blur_set = true
	else: blur_set = false
	
	if abs(correct_offset.x - $worm.rect_position.x) < 10 * accepted_incorectness: offset_set = true
	else: offset_set = false
	
	if offset_set and blur_set and !checking: checkWin()

func checkWin():
	checking = true
	$Timer.start()
	yield($Timer, "timeout")
	TaskWithGUI.TaskWithGUICompleteTask(self)
