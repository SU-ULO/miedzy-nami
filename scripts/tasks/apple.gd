extends Area2D

var mouseIn = false
var clickDelta = Vector2()
var pickedUp = false
var ableToBeFed = false

func _ready():
# warning-ignore:return_value_discarded
	connect("area_entered", self, "isAbleToBeFed")
# warning-ignore:return_value_discarded
	connect("area_exited", self, "notAbleToBeFed")

func _input(event):
	if event is InputEventMouseMotion:
		if pickedUp:
			get_parent().rect_position = get_viewport().get_mouse_position() - clickDelta

func isAbleToBeFed(area):
	if area.name == "dzdzownica":
		ableToBeFed = true

func notAbleToBeFed(area):
	if area.name == "dzdzownica":
		ableToBeFed = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "grow":
		TaskWithGUI.TaskWithGUICompleteTask(get_parent().get_parent())

func _on_jablko_button_down():
	pickedUp = true
	clickDelta = (get_viewport().get_mouse_position() - get_parent().rect_position)

func _on_jablko_button_up():
	pickedUp = false
	if ableToBeFed:
		get_parent().visible = false
		get_parent().get_parent().get_node("AnimationPlayer").play("grow")
