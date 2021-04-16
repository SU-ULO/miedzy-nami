extends Control

var rng = RandomNumberGenerator.new()

onready var knob = get_node("Texture/Knob/Knob")
onready var wave1_pos = get_node("Texture/wave1").global_position
onready var wave2_pos = get_node("Texture/wave2").global_position
onready var timer = get_node("Timer")

const max_noise:float = 8.0
const min_noise:float = -8.0
const move = 10
var x = 0

var set:bool = false

func _ready():
	rng.randomize()
	
	knob.full_rotations = 2
	if rng.randi_range(0, 1) == 0:
		knob.full_rotations *= -1

func _process(delta):
	update()
	x+=move*delta
	
func check(noise):
	if abs(noise) < 0.5: set = true
	else: set = false
	
	if set and timer.time_left == 0: timer.start()
	elif !set and timer.time_left > 0: timer.stop()

func _draw():
	var noise = knob.prevangle + 2*PI*knob.full_rotations
	check(noise)
	# some magic values
	draw_sin(25.0, 16.88, 25.0, 5.0, wave1_pos, 0.5, Color("#00FF00"))
	draw_sin(25.0, 16.88, 25.0, 5.0, wave2_pos, clamp(noise, min_noise, max_noise))

func draw_sin(scale = 1, length = 500, resolution = 4, speed = 1, offset = Vector2(0, 0), noise_amount = 0, color = Color(1, 1, 1, 1)):
	if abs(noise_amount) < 0.5: noise_amount = 0.5
	var points = PoolVector2Array()
	for i in range(resolution * length):
		var p1raw = i / resolution
		var p2 = sin(p1raw * speed + x) + rng.randf_range(0, 0.4) * noise_amount - 0.2 * noise_amount
		var p1 = p1raw
		points.push_back(Vector2(p1, p2) * scale + offset)
	for i in range(resolution * length - 1):
		draw_line(points[i], points[i + 1], color)

func _on_Timer_timeout():
	Globals.start.network.request_end_sabotage(3)
	
