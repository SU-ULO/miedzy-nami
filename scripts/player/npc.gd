extends Dummyplayer

export var default_clothes = {
	"skin": "skin1",
	"mouth": "neutral closed",
	"nose": "long nose",
	"eye": "neutral_open",
	"eye_color": "darkblue",
	"hair": "afro",
	"hairColor": 1,
	"hasBottom": 0,
	"topClothes": "dress",
	"acc": "acc0", # nothing
	"beard": "bald",
	"beard_color": "black"
}

export var default_color = 0

export var default_name = ""

export(Array, NodePath) var default_wandering_path

var wandering_path = Array()
var wandering_point_id = 0
var now_wandering = false
var navpath=PoolVector2Array()

export var speed_multiplier: float = 1

func set_next_wandering_point():
	wandering_point_id+=1
	if wandering_point_id>=wandering_path.size():
		wandering_point_id=0

func set_next_navpoint():
	if navpath.size()>0:
		navpath.remove(0)

func set_navpath():
	var nav = Globals.start.network.world.get_node("NavNPC")
	navpath = nav.get_simple_path(position, wandering_path[wandering_point_id])

func _ready():
	username = default_name
	color = default_color
	$Label.text = username

func npc_init():
	Globals.start.network.handle_set_look(default_clothes, owner_id)
	for p in default_wandering_path:
		wandering_path.append(get_node(p).position)
	now_wandering = true

func set_player_velocity():
	.set_player_velocity()
	player_velocity = player_velocity * speed_multiplier

func _process(_delta):
	if now_wandering and !wandering_path.empty():
		if navpath.empty():
			set_next_wandering_point()
			set_navpath()
		var direction = position.direction_to(navpath[0])
		moveX = direction.x
		moveY=direction.y
		var distance_to_navpoint = position.distance_to(navpath[0])
		if distance_to_navpoint<25:
			set_next_navpoint()
	else:
		moveX = 0
		moveY = 0

