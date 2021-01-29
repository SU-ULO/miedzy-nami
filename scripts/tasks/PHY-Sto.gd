extends Control

var pos = 0
var pos2 = 0
var started = false
# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("AnimationPlayer").play("wahadlo")


func _on_TextureButton_pressed():
	get_node("AnimationPlayer2").play("clock-tick")
	if !started:
		started = true
		pos = get_node("AnimationPlayer").current_animation_position	
	else:
		started = false
		get_node("AnimationPlayer2").stop()
		pos2 = get_node("AnimationPlayer").current_animation_position
		if abs(pos - pos2) < 0.1 || abs(pos - (get_node("AnimationPlayer").current_animation_length - pos2)) < 0.1:
			print("Gratulacje!") # only for testing
			get_node("AnimationPlayer2").play("wait")
		else:
			#ups zrob to jeszcze raz (jak to zasygnalizowac graczowi??)
			print("Nie") #only for testing


func _on_AnimationPlayer2_animation_finished(anim_name):
	if anim_name == "wait":
		var TaskWithGUI = load("res://scripts/tasks/TaskWithGUI.cs")
		TaskWithGUI.TaskWithGUICompleteTask(self)
