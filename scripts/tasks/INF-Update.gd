extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Button_pressed():
	get_node("AnimationPlayer").play("tux_scale")
	self.disabled = true


func _on_AnimationPlayer_animation_finished(_anim_name):
	# replace this with function to end task
	get_owner().get_parent().remove_child(get_owner())
	# # # # # # # # # # # # # # # # # # # # #
