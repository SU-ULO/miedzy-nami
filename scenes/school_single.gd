extends Node2D

var npcs = Array()

func _ready():
	var curr_id=1
	for c in $Mapa/YSort.get_children():
		if c.is_in_group("npc"):
			c.owner_id=curr_id
			curr_id+=1
			npcs.push_back(c)
