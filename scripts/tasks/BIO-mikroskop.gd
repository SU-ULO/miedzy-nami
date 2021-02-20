extends Control

var focus = false
var good_position = false

var checking = false

var cel
var pos_offset = Vector2(0, 0)
var x
var org_pos = Vector2()
var gooood_pos = Vector2()
var rng = RandomNumberGenerator.new()
var y

func _ready():
	rng.randomize()
	cel = rng.randf_range(10, 30)
	cel *= ((rng.randi_range(0, 1) * 2) - 1)
	pos_offset.x = rng.randf_range(100, 250)  
	pos_offset.x *= ((rng.randi_range(0, 1) * 2) - 1)
	gooood_pos = $dzdzownica.rect_position
	$dzdzownica.rect_position += pos_offset
	org_pos = $dzdzownica.rect_position
	
func _process(_delta):
	x = $pokretlo/pokreto/guzik.halohalo
	y = $pokretlo2/pokreto/guzik.halohalo
	$dzdzownica.rect_position.x = org_pos.x + y * 5
	x -= cel
	$dzdzownica.material.set_shader_param("radius", x) 
	if abs (x) < 0.6 && !focus:
		focus = true
		#print("hej")
		checkWin()
	if abs(gooood_pos.x - $dzdzownica.rect_position.x) < 10 && !good_position:
		good_position = true
		#print("hehe")
		checkWin()


func checkWin():
	if !checking:
		checking = true
		if good_position && focus:
			$Timer.start()
			yield($Timer, "timeout")
			var TaskWithGUI = load("res://scripts/tasks/TaskWithGUI.cs")
			TaskWithGUI.TaskWithGUICompleteTask(self)
	checking = false
