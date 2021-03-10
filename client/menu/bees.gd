extends Control

const bees_count:int = 9
var bees = []
var bees_momentum = []
var bees_angle = []

onready var resource = preload("res://client/menu/bee.tscn")
var sprites = ["res://textures/pszczola_1.png", "res://textures/pszczola_2.png", "res://textures/pszczola_1.png"]

func space_evenly(bee_number):
	var x = (1920-200)/3
	var y = (1080-200)/2
	
	var pos = Vector2(x*(1 + bee_number%3), y*(1 + bee_number/2))
	pos += Vector2(-100+randi()%3*100 , -100+randi()%2*100)
	return pos

func _ready():
	randomize()
	
	for iter in range(bees_count):
		var bee = resource.instance()
		bee.get_node("Sprite").set_texture(load(sprites[randi() % sprites.size()]))
		
		if(iter < 6): bee.position = space_evenly(iter)
		else: bee.position = Vector2(rand_range(100.0, 1820.0), rand_range(100.0, 980.0))
		
		bees_momentum.append(Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)))
		bees_angle.append(rand_range(-0.01, 0.01))
		
		bees.append(bee); self.add_child(bee)


func _physics_process(_delta):
	var iter = 0
	for bee in bees:
		bee.position += bees_momentum[iter]
		if bee.position.x < -100.0: bee.position.x = 1970.0
		elif bee.position.x > 2020.0: bee.position.x = -50.0
		
		if bee.position.y < -100.0: bee.position.y = 1130.0
		elif bee.position.y > 1180.0: bee.position.y = -50.0
		
		bee.rotation += bees_angle[iter]
		iter += 1

