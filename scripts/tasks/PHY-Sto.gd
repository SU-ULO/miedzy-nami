extends Control

var started = false

var start_pos = 0 # positions on animation timeline
var end_pos = 0
var err_margin = 0.1 # fraction of total animation length
var anim_length
var timeout = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("AnimationPlayer").play("wahadlo")
	anim_length = get_node("AnimationPlayer").current_animation_length

func _on_Timer_pressed():
	get_node("AnimationPlayer2").play("clock-tick")
	
	if !started: # start
		start_pos = get_node("AnimationPlayer").current_animation_position
		timeout = false
		get_node("Timer").start(2)
	else: # stop
		get_node("AnimationPlayer2").stop()
		end_pos = get_node("AnimationPlayer").current_animation_position
		check_win()
	started = !started

func check_win():
	if min(abs(end_pos - start_pos), abs(end_pos - start_pos - anim_length)) < anim_length*err_margin \
	and timeout:
		get_node("AnimationPlayer2").play("wait")
		print("OK")
	else: 
		get_node("AnimationPlayer2").play("quick-spin")

func _on_AnimationPlayer2_animation_finished(anim_name):
	if anim_name == "wait":
		TaskWithGUI.TaskWithGUICompleteTask(self)


func _on_Timer_timeout():
	timeout = true
