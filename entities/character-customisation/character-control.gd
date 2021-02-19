extends Control

const LookConfiguration = preload("look-configuration.gd")		

var currLook = LookConfiguration.new()

#get previous config and load it

func _ready():
	$"body-parts-control/skin-control".connect("changeSkin", self, "_skin_Change")
	$"body-parts-control/nose-control".connect("changeNose", self, "_nose_Change")
	$"body-parts-control/mouth-control".connect("changeMouth", self, "_mouth_Change")
	
func _skin_Change(number):
	$"body-parts/skin".texture = load("res://textures/character/face_front/skin" + number + ".png")
	currLook.skin = number
	_mouth_Change(currLook.mouth)

func _nose_Change(name):
	$"body-parts/nose".texture = load("res://textures/character/face parts/noses/" + name + ".png")
	currLook.nose = name
func hideAll():
	for i in $"body-parts-control".get_children():
		i.visible = false
		
func _show_Menu(menu):
	hideAll()
	get_node("body-parts-control/" + menu + "-control").visible = true
	
func _mouth_Change(name):
	currLook.mouth = name
	$"body-parts/mouth".texture = load("res://textures/character/face parts/mouths/" + currLook.getMouthPath(name))
