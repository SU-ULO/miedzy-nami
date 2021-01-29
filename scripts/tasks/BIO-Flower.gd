extends Control

var count = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func task_end():
	# replace this with function to end task
	print("Task ended!")
	var TaskWithGUI = load("res://scripts/tasks/TaskWithGUI.cs")
	TaskWithGUI.TaskWithGUICompleteTask(self)
	# # # # # # # # # # # # # # # # # # # # #


func _on_sunflower_pressed():
	get_node("AnimationPlayer2/doniczka2/sunflower").disabled = true
	get_node("AnimationPlayer2").play("Sunflower_grow")


func _on_lilly_pressed():
	get_node("AnimationPlayer/doniczka1/lilly").disabled = true
	get_node("AnimationPlayer").play("Lilly_grow")


func _on_blueflower_pressed():
	get_node("AnimationPlayer3/doniczka3/blueflower").disabled = true
	get_node("AnimationPlayer3").play("Blueflower_grow")

func _on_AnimationPlayer_animation_finished(_anim_name):
	count+=1
	if count == 3:
		task_end()

func _on_AnimationPlayer3_animation_finished(_anim_name):
	count+=1
	if count == 3:
		task_end()


func _on_AnimationPlayer2_animation_finished(_anim_name):
	count+=1
	if count == 3:
		task_end()
