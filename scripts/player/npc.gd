extends Dummyplayer

class_name NPC

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
var last_target_num: int = 0

#path stuff
var tmp_navpath = PoolVector2Array()
var tmp_target = Vector2()

func clear_navpath():
	if !tmp_navpath.empty():
		tmp_navpath = PoolVector2Array()

#state stuff
enum NpcState {WELTSCHMERZ, TRAVELING, IDLING, IDLING_WALK, TALKING}
var current_state = NpcState.WELTSCHMERZ
var state_time_remaining: float = 5

func go_direct(target: Vector2):
	var direction = position.direction_to(target)
	moveX = direction.x
	moveY = direction.y

func set_next_target():
	var id = last_target_num
	while id == last_target_num:
		id = randi()%potential_wandering_targets.size()
	wandering_target = potential_wandering_targets[id]
	last_target_num=id
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

func start_idle():
	current_state=NpcState.IDLING
	state_time_remaining=2
	if wandering_target is NavPoint:
		state_time_remaining=wandering_target.wait_time

func do_idle():
	moveX=0
	moveY=0
	if wandering_target is NavPoint:
		if wandering_target.look_dir==NavPoint.LookDirection.DOWN:
			$sprites.lookFront()
		elif wandering_target.look_dir==NavPoint.LookDirection.UP:
			$sprites.lookBack()
		elif wandering_target.look_dir==NavPoint.LookDirection.LEFT:
			$sprites.lookLeft()
		elif wandering_target.look_dir==NavPoint.LookDirection.RIGHT:
			$sprites.lookRight()

func end_idle():
	if wandering_target is NavPoint:
		var continue_idle = randf() < wandering_target.idling_chance
		if continue_idle:
			start_idle_walk()
		else:
			set_next_target()

func start_idle_walk():
	current_state=NpcState.IDLING_WALK
	state_time_remaining=1
	var p = wandering_target.position
	var d = Vector2(randf()*2-1, randf()*2-1).normalized() * 500
	clear_navpath()
	tmp_target=p+d

func do_idle_walk():
	go_direct(tmp_target)

func end_idle_walk():
	start_idle()

func do_travel():
	if wandering_target in in_sight\
	and position.distance_to(wandering_target.position)<200:
		tmp_target = wandering_target.position
		clear_navpath()
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

func end_travel():
	if position.distance_to(wandering_target.position)<50:
		if wandering_target is NavPoint:
			if wandering_target.type==NavPoint.NavpointType.ROOM_NAVPOINT:
				start_idle()
			elif wandering_target.type==NavPoint.NavpointType.PATH_NAVPOINT:
				set_next_target()
		elif wandering_target.is_class("NPC"):
			set_next_target()

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
				moveX=0
				moveY=0
			elif current_state == NpcState.TRAVELING:
				do_travel()
			elif current_state == NpcState.IDLING:
				do_idle()
			elif current_state == NpcState.IDLING_WALK:
				do_idle_walk()
		else:
			if current_state==NpcState.WELTSCHMERZ:
				set_next_target()
			elif current_state==NpcState.TRAVELING:
				end_travel()
			elif current_state==NpcState.IDLING:
				end_idle()
			elif current_state==NpcState.IDLING_WALK:
				end_idle_walk()
		state_time_remaining-=delta
	else:
		moveX=0
		moveY=0
