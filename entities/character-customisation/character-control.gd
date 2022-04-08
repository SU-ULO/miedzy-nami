extends Control

const LookConfiguration = preload("look-configuration.gd")		

var currLook = LookConfiguration.new()
var ccolor = 5
#get previous config and load it

func _ready():
	for i in $"body-parts-control".get_children():
		i.connect("changePart", self, "_part_Change")
	# warning-ignore:return_value_discarded
	$"eye-color".connect("changeEyeColor", self, "_eye_color_Change")	
	# warning-ignore:return_value_discarded
	$"hair-color".connect("changePart", self, "_part_Change")
	# warning-ignore:return_value_discarded	
	$"beard-color".connect("changePart", self, "_part_Change")
	
func _part_Change(part, name):
	print(part, name)
	match(part):
		"beardColor":
			currLook.beard_color = name
			$"body-parts/beard".texture = load(currLook.getBeardPath())
		"beard":
			currLook.beard = name
			$"body-parts/beard".texture = load(currLook.getBeardPath())
		"nose":
			currLook.nose = name
			$"body-parts/nose".texture = load(currLook.getNosePath())
		"hair":
			currLook.hair = name
			$"body-parts/hair".texture = load(currLook.getHairPath())
			$"body-parts/hair".position.y = currLook.getHairPos()
		"acc":
			currLook.acc = name
			$"body-parts/accessories".texture = load(currLook.getAccPath())
		"mouth":
			currLook.mouth = name
			$"body-parts/mouth".texture = load(currLook.getMouthPath())
		"clothes":
			if name == "dress" || name == "hoodie":
				currLook.hasBottom = false
				$"body-parts/jeans".visible = false
			else:
				currLook.hasBottom = true
				$"body-parts/jeans".visible = true
			currLook.topClothes = name
			$"body-parts/clothes".texture = load(currLook.getTopClotes(1, ccolor))
		"skin":
			currLook.skin = name
			$"body-parts/skin".texture = load(currLook.getSkinPath())
			$"body-parts/body".texture = load(currLook.getBodyPath(4))
			_part_Change("mouth", currLook.mouth)
			_part_Change("eye", currLook.eye)
			$"eye-color".visible = false
		"eye":
			currLook.eye = name
			$"body-parts/eye".texture = load(currLook.getEyePath())
			var bonuspath = currLook.getEyeBonusPath()
			if bonuspath!="przykromi":
				$"body-parts/bonus".visible = true
				$"body-parts/bonus".texture = load(currLook.getEyeBonusPath())
			else:
				$"body-parts/bonus".visible = false
			$"eye-color".visible = currLook.hasColoredEyes()
		"hairColor":
			currLook.hairColor = name
			_part_Change("hair", currLook.hair)

func hideAll():
	for i in $"body-parts-control".get_children():
		i.visible = false
		
func _show_Menu(menu):
	hideAll()
	get_node("body-parts-control/" + menu + "-control").visible = true
	$"eye-color".visible = false
	$"beard-color".visible = false
	$"hair-color".visible = false
	if menu == "eye":
		$"eye-color".visible = currLook.hasColoredEyes()
	elif menu == "hair":
		$"hair-color".visible = true
	elif menu == "beard":
		$"beard-color".visible = true

func _eye_color_Change(color):
	currLook.eye_color = color
	_part_Change("eye", currLook.eye)
	

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
	$"body-parts/mouth".texture = load(currLook.getMouthPath())
	$"body-parts/hair".texture = load(currLook.getHairPath())
	$"body-parts/hair".position.y = currLook.getHairPos()
	$"body-parts/nose".texture = load(currLook.getNosePath())
	$"body-parts/skin".texture = load(currLook.getSkinPath())
	$"body-parts/body".texture = load(currLook.getBodyPath(4))
	$"body-parts/accessories".texture = load(currLook.getAccPath())
	$"body-parts/beard".texture = load(currLook.getBeardPath())

func set_random():
	for i in $"body-parts-control".get_children():
		i.get_random()
	get_node("hair-color").get_random()
	get_node("eye-color").get_random()
	randomize()
	if randi() % 2 == 1:
		get_node("beard-color").get_random()
	else:
		_part_Change("beard", "bald")
