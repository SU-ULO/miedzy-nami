extends Control

var kawa
var rozmiar
var cukier
var done = 3
var timeleft
var TaskWithGUI
var t
var rng = RandomNumberGenerator.new()
func _ready():
	t = TaskWithGUI.GetTaskFromControl(self)
	done = t.done
	if done == 1:
		kawa = t.kawa
		if kawa:
			$AnimationPlayer/main/kawakubek.visible = 1
		else:
			$AnimationPlayer/main/herbatakubek.visible = 1
		$AnimationPlayer.play("open")

		yield($AnimationPlayer, "animation_finished")
	elif done == 2:
		timeleft = t.get_node("Timer").time_left
		countFrom(int(timeleft))
	else:
		$AnimationPlayer/main/drzwiczki.rect_position = Vector2(71.637, -44.24)
		rng.randomize()
		kawa = rng.randi_range(0, 1)
		rozmiar = rng.randi_range(0, 1)
		cukier = rng.randi_range(1, 3)
		$AnimationPlayer/main/notka.visible  = 1
		var tekst = ""
		if kawa:
			tekst += "herbata\n"
		else:
			tekst+=	"kawa\n"
		if rozmiar:
			tekst+="mała\n"
		else:
			tekst+="duża\n"
		tekst += str(cukier)
		tekst += " cukru"
		$AnimationPlayer/main/notka/Label.text = tekst
		t.kawa = kawa
		

func _on_ready_pressed():
	if done == 3:			
		if $AnimationPlayer/main/herbata.pressed == bool(kawa) && $AnimationPlayer/main/mala.pressed == bool(rozmiar) && int($"AnimationPlayer/main/1".group.get_pressed_button().name) == cukier:
			print ("jej!")
			$AnimationPlayer.play_backwards("open")
			done = 2
			t.done = 2
			yield($AnimationPlayer, "animation_finished")
			t.get_node("Timer").start()
			countFrom(60)
		else:
			print("buuu")
		# jakiś sygnał niepowodzenia?


func countFrom(time):
	for i in range(0, time + 1):
		$Timer.start()
		$AnimationPlayer/main/Label.text = "Time left: " + str(time - i) + "s"		
		yield($Timer, "timeout")
	done = 1
	t.done = 1
	if kawa:
		$AnimationPlayer/main/kawakubek.visible = 1
	else:
		$AnimationPlayer/main/herbatakubek.visible = 1
	$AnimationPlayer.play("open")
		

func _on_kubek_pressed():
	TaskWithGUI.TaskWithGUICompleteTask(self)
