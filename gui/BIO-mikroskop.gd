extends Control

var cel
var x
var rng = RandomNumberGenerator.new()
func _ready():
	rng.randomize()
	cel = rng.randf_range(10, 30)
	cel *= ((rng.randi_range(0, 1) * 2) - 1)
func _process(_delta):
	x  = $pokretlo/pokreto/guzik.halohalo
	x -= cel
	$dzdzownica.material.set_shader_param("radius", x) 
	if abs (x) < 0.5:
		# brawo dziala
		pass
