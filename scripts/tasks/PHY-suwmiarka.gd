extends Control

var toleration = 10
var goodpos = false

var rng = RandomNumberGenerator.new()
var scalee = 1

func _ready():
	# warning-ignore:return_value_discarded
	$arr_up.connect("increment", self, "increment")
	# warning-ignore:return_value_discarded
	$arr_down.connect("decrement", self, "decrement")
	rng.randomize()
	scalee *= rng.randf_range(0.6, 1.2)
	$bloczek.rect_scale *= Vector2(scalee, scalee)  
	$bloczek.rect_position.x -=  ($koniec.position.x - $poczatek.position.x) * scalee - $koniec.position.x + $poczatek.position.x
	$wynik.text = str(floor(rng.randf_range($bloczek.rect_size.x * scalee/3, $bloczek.rect_size.x * scalee/3 * 2)))

func _process(_delta):
	$Label.text = str(floor( ($mainpart/ruchome1/pozycja.global_position.x - $"mainpart/0".global_position.x) * 150 / ($"mainpart/150".global_position.x - $"mainpart/0".global_position.x)) )
	if abs($mainpart/ruchome1/pozycja.global_position.x - $bloczek/end.global_position.x) < toleration:
		goodpos = true
	else:
		goodpos = false
func increment():
	$wynik.text = str(clamp(int($wynik.text) + 1, 0, 200))
	checkWin()

func decrement():
	$wynik.text = str(clamp(int($wynik.text) - 1, 0, 200))
	checkWin()
	
func checkWin():
	if goodpos && $wynik.text == $Label.text:
		$arr_up.disconnect("increment", self, "increment")
		$arr_down.disconnect("decrement", self, "decrement")
		$Timer.start()
		yield($Timer, "timeout")
		TaskWithGUI.TaskWithGUICompleteTask(self)
