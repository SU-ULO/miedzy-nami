extends Control

func _ready():
	$"body-parts-control/skin-control".connect("changeSkin", self, "_skin_Change")
	$"body-parts-control/nose-control".connect("changeNose", self, "_nose_Change")
	
func _skin_Change(number):
	$"body-parts/skin".texture = load("res://textures/character/face_front/skin" + number + ".png")

func _nose_Change(name):
	$"body-parts/nose".texture = load("res://textures/character/face parts/noses/" + name + ".png")

func hideAll():
	for i in $"body-parts-control".get_children():
		i.visible = false
		
func _show_Menu(menu):
	hideAll()
	get_node("body-parts-control/" + menu + "-control").visible = true
	
