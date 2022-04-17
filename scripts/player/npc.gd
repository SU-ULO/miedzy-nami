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

func _ready():
	username = default_name
	color = default_color
	$Label.text = username

func npc_init():
	Globals.start.network.handle_set_look(default_clothes, owner_id)
