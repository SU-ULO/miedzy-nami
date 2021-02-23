extends Control

var sequence = []

signal start1
signal start2
signal start3
signal start4

var sounds = []

var rng = RandomNumberGenerator.new()
func _ready():
	rng.randomize()
	for i in get_children():
		sounds.append(i.name)
	for i in range(0, 4):
		sequence.append(sounds[rng.randi_range(0, sounds.size()-1)])
		connect(("start" + str(i)), self, ("Start" + str(i)))
	print(sequence)
	
	emit_signal("start1")

func Start1():
	get_node(sequence[0]).play("go")
	yield(get_node(sequence[0]), "animation_finished")
func Start2():
	get_node(sequence[0]).play("go")
	yield(get_node(sequence[0]), "animation_finished")
	get_node(sequence[1]).play("go")
	yield(get_node(sequence[1]), "animation_finished")
func Start3():
	get_node(sequence[0]).play("go")
	yield(get_node(sequence[0]), "animation_finished")
	get_node(sequence[1]).play("go")
	yield(get_node(sequence[1]), "animation_finished")
	get_node(sequence[2]).play("go")
	yield(get_node(sequence[2]), "animation_finished")
func Start4():
	get_node(sequence[0]).play("go")
	yield(get_node(sequence[0]), "animation_finished")
	get_node(sequence[1]).play("go")
	yield(get_node(sequence[1]), "animation_finished")
	get_node(sequence[2]).play("go")
	yield(get_node(sequence[2]), "animation_finished")
	get_node(sequence[3]).play("go")
	yield(get_node(sequence[3]), "animation_finished")
