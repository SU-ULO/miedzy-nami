extends Control

var kawa
var rozmiar
var cukier

var rng = RandomNumberGenerator.new()
func _ready():
	rng.randomize()
	kawa = rng.randi_range(0, 1)
	rozmiar = rng.randi_range(0, 1)
	cukier = rng.randi_range(1, 3)
	print(kawa)
	print(rozmiar)
	print(cukier)


func _on_ready_pressed():
	if $main/herbata.pressed == bool(kawa) && $main/mala.pressed == bool(rozmiar) && int($"main/1".group.get_pressed_button().name) == cukier:
		print ("jej!")
		# start timer
	else:
		print("buuu")
		# jakiś sygnał niepowodzenia?


