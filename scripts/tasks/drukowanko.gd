extends Control

func _ready():
	pass # Replace with function body.


func _on_TextureButton_pressed():
	#start print
	$TextureButton.visible = false
	$ColorRect.visible = false
	$ColorRect2.visible = false
	$AnimationPlayer/ProgressBar.visible = true
	$AnimationPlayer.play("print")
	yield($AnimationPlayer, "animation_finished")
	TaskWithGui.TaskWithGuiCompleteTask(self)
