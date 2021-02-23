extends Control

var sequence = []

var stage = -1

var x = 0

signal start1
signal start2
signal start3
signal start4

var sounds = ["c", "d", "e", "f", "g", "a", "h"]

var rng = RandomNumberGenerator.new()
func _ready():
	rng.randomize()
	for i in range(0, 4):
		sequence.append(sounds[rng.randi_range(0, sounds.size()-1)])
		connect(("start" + str(i+1)), self, ("Start" + str(i+1)))
	print(sequence)
	for i in get_children():
		i.get_node(i.name).connect("pressed", self, "Record", [i.name])
	emit_signal("start1")

func Record(note):
	if stage > 0:
		if note == sequence[x]:
			get_node(note).play("good")
			x+=1
			if x == stage:
				if stage == 4:
					pass
					#jej wygrana
				else:
					emit_signal(("start" + str(stage + 1)))
		else:
			get_node(note).play("bad")
			yield(get_node(note), "animation_finished")
			emit_signal("start1")
func Start1():
	x=0
	stage = -1
	get_node(sequence[0]).play("go")
	yield(get_node(sequence[0]), "animation_finished")
	stage = 1
func Start2():
	x=0
	stage = -1
	get_node(sequence[0]).play("go")
	yield(get_node(sequence[0]), "animation_finished")
	get_node(sequence[1]).play("go")
	yield(get_node(sequence[1]), "animation_finished")
	stage = 2
func Start3():
	x = 0
	stage = -1
	get_node(sequence[0]).play("go")
	yield(get_node(sequence[0]), "animation_finished")
	get_node(sequence[1]).play("go")
	yield(get_node(sequence[1]), "animation_finished")
	get_node(sequence[2]).play("go")
	yield(get_node(sequence[2]), "animation_finished")
	stage = 3
func Start4():
	x = 0
	stage = -1
	get_node(sequence[0]).play("go")
	yield(get_node(sequence[0]), "animation_finished")
	get_node(sequence[1]).play("go")
	yield(get_node(sequence[1]), "animation_finished")
	get_node(sequence[2]).play("go")
	yield(get_node(sequence[2]), "animation_finished")
	get_node(sequence[3]).play("go")
	yield(get_node(sequence[3]), "animation_finished")
	stage = 4
