extends Game_Connection

class_name JoinedServer

var world := preload('res://scenes/school.tscn').instance()
var Task = load("res://scripts/tasks/Task.cs") 
var own_player = null
var own_id := 0
var remote_players := Dictionary()

func _init(conf: Dictionary).(conf):
	pass

func _ready():
	peer.create_offer()
# warning-ignore:return_value_discarded
	connect("success", self, "spawn_map")

func spawn_map():
	add_child(world)

func leave():
	.leave()
	if world.get_parent()==self:
		remove_child(world)

func spawn_player():
	pass

func handle_events(input):
	print (input)
	if input is Array:
		if input.size()==3:
			if input[0] is int and input[1] is int and input[2] is Dictionary:
				var local_player_preload = preload('res://entities/player.tscn')
				var remote_player_preload = preload('res://entities/dummyplayer.tscn')
				var players_holder = world.get_node("Mapa/YSort")
				if input[0]==0:
					own_id = input[1]
					var players = input[2]
					for p in players:
						if p == own_id:
							own_player=local_player_preload.instance()
							if players[p].has("pos"):
								own_player.position=players[p]["pos"]
							players_holder.add_child(own_player)
						else:
							var instance = remote_player_preload.instance()
							remote_players[p]=instance
							if players[p].has("pos"):
								instance.position=players[p]["pos"]
							players_holder.add_child(instance)
					emit_signal("join")
				elif input[0]==1:
					var instance = remote_player_preload.instance()
					remote_players[input[1]]=instance
					players_holder.add_child(instance)
		elif input.size()==2:
			if input[0] is int and input[1] is int:
				if input[0]==2:
					if remote_players.has(input[1]):
						remote_players[input[1]].queue_free()
# warning-ignore:return_value_discarded
						remote_players.erase(input[1])
	elif input is Dictionary:
		for p in input:
			if p is String:
				if p == "add_tasks":
					print("Adding tasks to player task list")
					
					var taskIDs = input[p]
					for t in taskIDs:
						print("Received task ID", t)
						var task = Task.GetTaskByID(t)
						task.local = true
						own_player.localTaskList.append(task)
				else:
					print("?????")
			else:
				print("???")

func handle_updates(input):
	if input is Dictionary:
		for p in input:
			if p is int:
				var player = input[p]
				if player is Dictionary:
					var synced_player
					if remote_players.has(p):
						synced_player=remote_players[p]
					elif p==own_id:
						synced_player=own_player
					else:
						return
					if player.has("pos") and player["pos"] is Vector2:
						synced_player.position=player["pos"]
					if player.has("mov") and player["mov"] is Vector2:
						synced_player.moveX=player["mov"].x
						synced_player.moveY=player["mov"].y
			

func _process(_delta):
	if established:
		if own_player and is_instance_valid(own_player) and own_player.is_inside_tree():
			send_updates({"mov": Vector2(own_player.moveX, own_player.moveY), "pos": own_player.position})
			if Task.CheckAndClearAnyDirty():
				var state_changes : Dictionary = {}
				var started_changes : Dictionary = {}
				
				for t in Task.GetAllTasks():
					if t.dirty:
						t.dirty = false
						state_changes[t.taskID] = t.state
						started_changes[t.taskID] = t.started
						if t.started and t.state < t.maxState:
							own_player.localTaskList.append(t)
				
				send_events({"update_tasks": own_id, "state": state_changes, "started": started_changes})
