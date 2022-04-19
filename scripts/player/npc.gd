extends Dummyplayer

#custom properties
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
export var speed_multiplier: float = 1
export(Array, NodePath) var wandering_nodepaths

#ai active
var ai_active = false

#target stuff
var potential_wandering_targets = Array()
var wandering_target: Node2D
var last_target_pos = Vector2()

#path stuff
var tmp_navpath = PoolVector2Array()
var tmp_target = Vector2()

#state stuff
enum NpcState {WELTSCHMERZ, TRAVELING, IDLING, TALKING}
var current_state = NpcState.WELTSCHMERZ
var state_time_remaining: float = 5

func go_direct(target: Vector2):
	var direction = position.direction_to(target)
	moveX = direction.x
	moveY = direction.y

func set_next_target():
	wandering_target = potential_wandering_targets[randi()%potential_wandering_targets.size()]
	current_state = NpcState.TRAVELING
	last_target_pos = wandering_target.position
	set_navpath(wandering_target.position)
	state_time_remaining=60

func set_navpath(target: Vector2):
	var nav = Globals.start.network.world.get_node("NavNPC")
	tmp_navpath = nav.get_simple_path(position, target)
	return set_next_navpoint()

func set_next_navpoint():
	if tmp_navpath.empty():
		return false
	tmp_target = tmp_navpath[0]
	tmp_navpath.remove(0)
	return true

func end_travel():
	set_next_target()

func do_travel():
	if wandering_target in in_sight\
	and position.distance_to(wandering_target.position)<200:
		tmp_target = wandering_target.position
		if !tmp_navpath.empty():
			tmp_navpath = PoolVector2Array()
		if position.distance_to(tmp_target)<25:
			end_travel()
	else:
		var do_path_recalc = false
		if position.distance_to(tmp_target)<25:
			do_path_recalc = do_path_recalc or !set_next_navpoint()
			do_path_recalc = do_path_recalc or last_target_pos.distance_to(wandering_target.position)>25
		if do_path_recalc:
			set_navpath(wandering_target.position)
			last_target_pos = wandering_target.position
	go_direct(tmp_target)

func _ready():
	username = default_name
	color = default_color
	$Label.text = username

func npc_init():
	Globals.start.network.handle_set_look(default_clothes, owner_id)
	for p in wandering_nodepaths:
		potential_wandering_targets.append(get_node(p))
	if !potential_wandering_targets.empty():
		ai_active = true

func set_player_velocity():
	.set_player_velocity()
	player_velocity = player_velocity * speed_multiplier

func check_line_of_sight():
	for item in in_sight_range:
		var space_state = get_world_2d().direct_space_state
		var sight_check = space_state.intersect_ray(self.position, item.position, [self, item], 1)
			
		if !sight_check.empty():
			if debug_mode: debug_pos_collided.append(sight_check.position)
			if in_sight.has(item):
				in_sight.erase(item);
				if debug_mode: print(item.get_name(), " removed from: sight")
		else:
			if debug_mode: debug_pos_ok.append(item.position)
			if !in_sight.has(item):
				in_sight.push_back(item);
				if debug_mode: print(item.get_name(), " added to: sight")

func _process(delta):
	if ai_active:
		check_line_of_sight()
		if state_time_remaining>0:
			if current_state == NpcState.WELTSCHMERZ:
				pass
			elif current_state == NpcState.TRAVELING:
				do_travel()
		else:
			if current_state==NpcState.WELTSCHMERZ:
				set_next_target()
			elif current_state==NpcState.TRAVELING:
				end_travel()
		state_time_remaining-=delta
	else:
		moveX=0
		moveY=0
