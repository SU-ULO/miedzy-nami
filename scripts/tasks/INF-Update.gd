extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Button_pressed():
	get_node("AnimationPlayer").play("tux_scale")
	self.disabled = true


func _on_AnimationPlayer_animation_finished(_anim_name):
	print("Loading TaskWithGUI")
	var TaskWithGUI = load("res://scripts/tasks/TaskWithGUI.cs")
	# we want to get a direct child (not a grand child) of the node highest in the hierarchy
	# or the node highest in the hierarchy itself 
	
	# in this case, we get the highest node
	TaskWithGUI.TaskWithGUICompleteTask(self.get_owner())
