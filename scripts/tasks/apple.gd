extends Area2D

var mouseIn = false
var clickDelta = Vector2()
var pickedUp = false
var ableToBeFed = false

func _ready():
# warning-ignore:return_value_discarded
	connect("mouse_entered", self, "isAbleToBePicked")
# warning-ignore:return_value_discarded
	connect("mouse_exited", self, "notAbleToBePicked")
# warning-ignore:return_value_discarded
	connect("area_entered", self, "isAbleToBeFed")
# warning-ignore:return_value_discarded
	connect("area_exited", self, "notAbleToBeFed")

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.get_button_index() == BUTTON_LEFT:
				if mouseIn:
					pickedUp = true
					clickDelta = (get_viewport().get_mouse_position() - get_parent().position)
		else:
			pickedUp = false
			if ableToBeFed:
				#end
				get_parent().visible = false
				get_parent().get_parent().get_node("AnimationPlayer").play("grow")
	elif event is InputEventMouseMotion:
		if pickedUp:
			get_parent().position = get_viewport().get_mouse_position() - clickDelta
		
		
			

func isAbleToBePicked():
	mouseIn = true

func notAbleToBePicked():
	mouseIn = false

func isAbleToBeFed(area):
	if area.name == "dzdzownica":
		ableToBeFed = true

func notAbleToBeFed(area):
	if area.name == "dzdzownica":
		ableToBeFed = false


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "grow":
		var TaskWithGUI = load("res://scripts/tasks/TaskWithGUI.cs")
		TaskWithGUI.TaskWithGUICompleteTask(get_parent().get_parent())
