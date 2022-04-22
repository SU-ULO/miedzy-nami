extends Node2D

var npcs = Array()

var random_npcs_num = 10

func _ready():
	var ysort = $Mapa/YSort
	var navpoints = Array()
	
	for c in $NavNPC/NavPoints.get_children():
		navpoints.append(c)
	
	var rand_npcs = Array()
	
	if random_npcs_num>0:
		var l = LookConfiguration.new()
		var preloaded_npc = preload("res://entities/npc.tscn")
		for i in range(random_npcs_num):
			var rand_npc = preloaded_npc.instance()
			rand_npc.default_clothes=l.get_random()
			rand_npc.default_name="losowy uczeń nr "+String(i+1)
			rand_npc.default_color=randi()%14+1
			rand_npc.speed_multiplier=0.4+randf()*0.5
			ysort.add_child(rand_npc)
			for n in navpoints:
				rand_npc.wandering_nodepaths.append(rand_npc.get_path_to(n))
			rand_npc.position=navpoints[randi()%navpoints.size()].position
			rand_npcs.append(rand_npc)
	
	var curr_id=1
	for c in ysort.get_children():
		if c.is_in_group("npc"):
			c.owner_id=curr_id
			curr_id+=1
			npcs.push_back(c)
	
	for r_npc in rand_npcs:
		for npc in npcs:
			if npc != r_npc:
				r_npc.wandering_nodepaths.append(r_npc.get_path_to(npc))
