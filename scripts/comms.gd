extends Control

var rng = RandomNumberGenerator.new()

onready var knob = get_node("Texture/Knob/Knob")
onready var wave1_pos = get_node("Texture/wave1").global_position
onready var wave2_pos = get_node("Texture/wave2").global_position

func _ready():
	rng.randomize()
	knob.full_rotations = randi() % 2 + 1

func _process(_delta):
	update()

func _draw():
	var noise = knob.prevangle + 2*PI*knob.full_rotations
	# some magic values
	draw_sin(20.0, 21.0, 50.0, 15.0, wave1_pos, noise)
	draw_sin(20.0, 21.0, 50.0, 15.0, wave2_pos, noise)
	
func draw_sin(scale = 1, length = 500, resolution = 4, speed = 1, offset = Vector2(0, 0), noise_amount = 0, color = Color(1, 1, 1, 1)):
	var points = PoolVector2Array()
	for i in range(resolution * length):
		var p1raw = i / resolution
		var p2 = sin(p1raw * speed) + rng.randf_range(0, 0.4) * noise_amount - 0.2 * noise_amount
		var p1 = p1raw
		points.push_back(Vector2(p1, p2) * scale + offset)
	for i in range(resolution * length - 1):
		draw_line(points[i], points[i + 1], color)

