extends Control

const LookConfiguration = preload("look-configuration.gd")		

var currLook = LookConfiguration.new()
var ccolor = 5
#get previous config and load it

func _ready():
	# warning-ignore:return_value_discarded
	$"body-parts-control/skin-control".connect("changeSkin", self, "_skin_Change")
	# warning-ignore:return_value_discarded
	$"body-parts-control/nose-control".connect("changeNose", self, "_nose_Change")
	# warning-ignore:return_value_discarded
	$"body-parts-control/clothes-control".connect("changeClothes", self, "_clothes_Change")
	# warning-ignore:return_value_discarded
	$"body-parts-control/mouth-control".connect("changeMouth", self, "_mouth_Change")
	# warning-ignore:return_value_discarded
	$"body-parts-control/acc-control".connect("changeAcc", self, "_acc_Change")
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
	$"body-parts/body".texture = load(currLook.getBodyPath(4))
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
	
func _acc_Change(name):
	print(name)
	currLook.acc = name
	print(currLook.getAccPath())
	$"body-parts/accessories".texture = load(currLook.getAccPath())

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
	
func _clothes_Change(name):
	if name == "dress" || name == "hoodie":
		currLook.hasBottom = false
		$"body-parts/jeans".visible = false
	else:
		currLook.hasBottom = true
		$"body-parts/jeans".visible = true
		
	currLook.topClothes = name
	$"body-parts/clothes".texture = load(currLook.getTopClotes(1, ccolor))

func refresh():
	$"body-parts/clothes".texture = load(currLook.getTopClotes(1, ccolor))
	$"body-parts/jeans".visible = currLook.hasBottom
	$"body-parts/eye".texture = load(currLook.getEyePath())
	var bonuspath = currLook.getEyeBonusPath()
	if bonuspath!="przykromi":
		$"body-parts/bonus".visible = true
		$"body-parts/bonus".texture = load(currLook.getEyeBonusPath())
	else:
		$"body-parts/bonus".visible = false
	$"eye-color".visible = currLook.hasColoredEyes()
	$"body-parts/mouth".texture = load(currLook.getMouthPath())
	$"body-parts/hair".texture = load(currLook.getHairPath())
	$"body-parts/hair".position.y = currLook.getHairPos()
	$"body-parts/nose".texture = load(currLook.getNosePath())
	$"body-parts/skin".texture = load(currLook.getSkinPath())
	$"body-parts/body".texture = load(currLook.getBodyPath(4))
	$"body-parts/accessories".texture = load(currLook.getAccPath())

func set_random():
	for i in $"body-parts-control".get_children():
		i.get_random()
	get_node("hair-color").get_random()
	get_node("eye-color").get_random()
