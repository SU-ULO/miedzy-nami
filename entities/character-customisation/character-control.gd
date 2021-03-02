extends Control

const LookConfiguration = preload("look-configuration.gd")		

var currLook = LookConfiguration.new()

#get previous config and load it

func _ready():
	# warning-ignore:return_value_discarded
	$"body-parts-control/skin-control".connect("changeSkin", self, "_skin_Change")
	# warning-ignore:return_value_discarded
	$"body-parts-control/nose-control".connect("changeNose", self, "_nose_Change")
	# warning-ignore:return_value_discarded
	$"body-parts-control/mouth-control".connect("changeMouth", self, "_mouth_Change")
	# warning-ignore:return_value_discarded
	$"body-parts-control/eye-control".connect("changeEye", self, "_eye_Change")
	# warning-ignore:return_value_discarded
	$"body-parts-control/hair-control".connect("changeHair", self, "_hair_Change")
	# warning-ignore:return_value_discarded
	$"eye-color".connect("changeEyeColor", self, "_eye_color_Change")	
	# warning-ignore:return_value_discarded
	$"hair-color".connect("changeHairColor", self, "_hair_color_Change")	
func _skin_Change(number):
	currLook.skin = number
	$"body-parts/skin".texture = load(currLook.getSkinPath())
	_mouth_Change(currLook.mouth)
	_eye_Change(currLook.eye)
	$"eye-color".visible = false
func _nose_Change(name):
	currLook.nose = name
	$"body-parts/nose".texture = load(currLook.getNosePath())
func _hair_Change(name):
	currLook.hair = name
	$"body-parts/hair".texture = load(currLook.getHairPath())
	$"body-parts/hair".position.y = currLook.getHairPos()
	
func hideAll():
	for i in $"body-parts-control".get_children():
		i.visible = false
		
func _show_Menu(menu):
	hideAll()
	get_node("body-parts-control/" + menu + "-control").visible = true
	if menu == "eye":
		$"eye-color".visible = currLook.hasColoredEyes()
		$"hair-color".visible = false
	elif menu == "hair":
		$"hair-color".visible = true
		$"eye-color".visible = false
	else:
		$"eye-color".visible = false
		$"hair-color".visible = false
func _mouth_Change(name):
	currLook.mouth = name
	$"body-parts/mouth".texture = load(currLook.getMouthPath())

func _eye_Change(name):
	currLook.eye = name
	$"body-parts/eye".texture = load(currLook.getEyePath())
	var bonuspath = currLook.getEyeBonusPath()
	if bonuspath!="przykromi":
		$"body-parts/bonus".visible = true
		$"body-parts/bonus".texture = load(currLook.getEyeBonusPath())
	else:
		$"body-parts/bonus".visible = false
	$"eye-color".visible = currLook.hasColoredEyes()

func _eye_color_Change(color):
	currLook.eye_color = color
	_eye_Change(currLook.eye)

func _hair_color_Change(color):
	currLook.hairColor = color
	_hair_Change(currLook.hair)
