extends Control

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func _process(_delta):
	update()

func _draw():
	draw_sin(get_parent().get_node("HSlider").value, 100, get_parent().get_node("HSlider2").value, get_parent().get_node("HSlider3").value, Vector2(200, 200), get_parent().get_node("HSlider4").value)
	
func draw_sin(scale = 1, length = 500, resolution = 4, speed = 1, offset = Vector2(0, 0), noise_amount = 0, color = Color(1, 1, 1, 1)):
	var points = PoolVector2Array()
	for i in range(resolution * length):
		var p1raw = i / resolution
		var p2 = sin(p1raw * speed) + rng.randf_range(0, 0.4) * noise_amount - 0.2 * noise_amount
		var p1 = p1raw
		points.push_back(Vector2(p1, p2) * scale + offset)
	for i in range(resolution * length - 1):
		draw_line(points[i], points[i + 1], color)

