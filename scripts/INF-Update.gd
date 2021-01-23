extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Button_pressed():
	get_parent().get_node("AnimationPlayer").play("tux_scale")
	self.disabled = true


func _on_AnimationPlayer_animation_finished(anim_name):
	#end task here
	pass
