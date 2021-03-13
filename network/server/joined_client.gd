extends Game_Connection

class_name JoinedClient

var joined := false
var player = null

func _init(conf: Dictionary).(conf):
	pass

func _ready():
# warning-ignore:return_value_discarded
	connect("success", self, "request_join")

func _exit_tree():
	if player:
		player.queue_free()

func get_init_data() -> Dictionary:
	return {"username": config.username, "pos": player.position}

func get_update_data() -> Dictionary:
	return {"pos": player.position, "mov": Vector2(player.moveX, player.moveY)}

func get_event_task_data(tasks) -> Dictionary:
	return {"add_tasks": tasks}

func request_join():
	emit_signal("join")

func handle_updates(input):
	if input is Dictionary:
		if input.has("mov") and input["mov"] is Vector2:
			if player:
				player.moveX=input["mov"].x
				player.moveY=input["mov"].y
		if input.has("pos") and input["pos"] is Vector2:
			if player:
				player.position=input["pos"]
				
func handle_events(input):
	if input is Dictionary:
		if input.has("update_tasks"):
			var Task = load("res://scripts/tasks/Task.cs")
			var tasks = Task.GetAllTasks()
			var player_id = input["update_tasks"]
			if input.has("state") and input["state"] is Dictionary:
				for i in input["state"]:
					if tasks[i].IsDone() == false:
						tasks[i].state = input["state"][i]
					tasks[i].local = true
			if input.has("started") and input["started"] is Dictionary:
				for i in input["started"]:
					tasks[i].started = input["started"][i]
					tasks[i].local = true
