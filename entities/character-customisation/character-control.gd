extends Control

const LookConfiguration = preload("look-configuration.gd")		

var currLook = LookConfiguration.new()

#get previous config and load it

func _ready():
	$"body-parts-control/skin-control".connect("changeSkin", self, "_skin_Change")
	$"body-parts-control/nose-control".connect("changeNose", self, "_nose_Change")
	$"body-parts-control/mouth-control".connect("changeMouth", self, "_mouth_Change")
	$"body-parts-control/eye-control".connect("changeEye", self, "_eye_Change")
	$"eye-color".connect("changeEyeColor", self, "_eye_color_Change")	
func _skin_Change(number):
	$"body-parts/skin".texture = load("res://textures/character/face_front/skin" + number + ".png")
	currLook.skin = number
	_mouth_Change(currLook.mouth)
	_eye_Change(currLook.eye)
	$"eye-color".visible = false
func _nose_Change(name):
	$"body-parts/nose".texture = load("res://textures/character/face parts/noses/" + name + ".png")
	currLook.nose = name
func hideAll():
	for i in $"body-parts-control".get_children():
		i.visible = false
		
func _show_Menu(menu):
	hideAll()
	get_node("body-parts-control/" + menu + "-control").visible = true
	if menu == "eye":
		$"eye-color".visible = currLook.hasColoredEyes()
	else:
		$"eye-color".visible = false
	
func _mouth_Change(name):
	currLook.mouth = name
	$"body-parts/mouth".texture = load("res://textures/character/face parts/mouths/" + currLook.getMouthPath(name))

func _eye_Change(name):
	currLook.eye = name
	$"body-parts/eye".texture = load("res://textures/character/face parts/oczy/" + currLook.getEyePath(name))
	var bonuspath = currLook.getEyeBonusPath(name)
	if bonuspath!="przykromi":
		$"body-parts/bonus".visible = true
		$"body-parts/bonus".texture = load("res://textures/character/face parts/oczy/" + currLook.getEyePath(name))
	else:
		$"body-parts/bonus".visible = false
	$"eye-color".visible = currLook.hasColoredEyes()

func _eye_color_Change(color):
	currLook.eye_color = color
	_eye_Change(currLook.eye)
