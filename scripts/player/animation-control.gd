extends Node2D

var currLook
var color

func _ready():
	currLook = get_parent().currLook
	color = get_parent().color
func stopWalk():
	$body.playing = false
	$spodnie.playing = false
	$"clothes-top".playing = false
	$face/eyes.playing = false
	$"face/eyes/eye-bonus".playing = false
	$face/nose.playing = false
	$face/mouth.playing = false
	$body.frame = 1
	$spodnie.frame = 1
	$"clothes-top".frame = 1
	$face/eyes.frame = 1
	$"face/eyes/eye-bonus".frame = 1
	$face/nose.frame = 1
	$face/mouth.frame = 1

func startWalk():
	$body.playing = true
	$spodnie.playing = true
	$"clothes-top".playing = true
	$face/eyes.playing = true
	$"face/eyes/eye-bonus".playing = true
	$face/nose.playing = true
	$face/mouth.playing = true

func loadLook():
	if currLook.hasBottom:
		$spodnie.visible = true
	else:
		$spodnie.visible = false
	for i in $"clothes-top".frames.get_animation_names():
		$"clothes-top".frames.clear(i)

	for i in $body.frames.get_animation_names():
		$body.frames.clear(i)
		
	for i in $face/eyes.frames.get_animation_names():
		$face/eyes.frames.clear(i)
	
	for i in $"face/eyes/eye-bonus".frames.get_animation_names():
		$"face/eyes/eye-bonus".frames.clear(i)
		
	for i in $face/nose.frames.get_animation_names():
		$face/nose.frames.clear(i)
		
	for i in $face/mouth.frames.get_animation_names():
		$face/mouth.frames.clear(i)	
		
	for i in $wlosy/hair.frames.get_animation_names():
		$wlosy/hair.frames.clear(i)	
				
	$body.frames.add_frame("walk side", load(currLook.getBodyPath(2)))
	$body.frames.add_frame("walk side", load(currLook.getBodyPath(1)))
	$body.frames.add_frame("walk side", load(currLook.getBodyPath(3)))
	$body.frames.add_frame("walk side", load(currLook.getBodyPath(1)))
	$body.frames.add_frame("walk front", load(currLook.getBodyPath(4)))
	$"clothes-top".frames.add_frame("walk front", load(currLook.getTopClotes(2, color)))
	$"clothes-top".frames.add_frame("walk front", load(currLook.getTopClotes(1, color)))
	$"clothes-top".frames.add_frame("walk front", load(currLook.getTopClotes(3, color)))
	$"clothes-top".frames.add_frame("walk front", load(currLook.getTopClotes(1, color)))
	$"clothes-top".frames.add_frame("walk side", load(currLook.getTopClotes(5, color)))
	$"clothes-top".frames.add_frame("walk side", load(currLook.getTopClotes(4, color)))
	$"clothes-top".frames.add_frame("walk side", load(currLook.getTopClotes(6, color)))
	$"clothes-top".frames.add_frame("walk side", load(currLook.getTopClotes(4, color)))
	$face.texture = load(currLook.getSkinPath())
	$face/eyes.frames.add_frame("front", load(currLook.getEyePath(1)))
	$face/eyes.frames.add_frame("side", load(currLook.getEyePath(2)))
	if currLook.getEyeBonusPath() != "przykromi":
		$"face/eyes/eye-bonus".visible = true
		$"face/eyes/eye-bonus".frames.add_frame("front", load(currLook.getEyeBonusPath(1)))
		$"face/eyes/eye-bonus".frames.add_frame("side", load(currLook.getEyeBonusPath(2)))
	else:
		$"face/eyes/eye-bonus".visible = false
	$spodnie.frame = 0
	$body.frame = 0
	$"clothes-top".frame = 0
	$body.playing = 1
	$spodnie.playing = 1
	$"clothes-top".playing = 1
	$face/nose.frames.add_frame("front", load(currLook.getNosePath()))
	$face/mouth.frames.add_frame("front", load(currLook.getMouthPath()))
	$wlosy/hair.frames.add_frame("front", load(currLook.getHairPath()))
	$wlosy/hair.frames.add_frame("side", load(currLook.getHairPath(2)))
	if $wlosy/hair.animation == "side":
		$wlosy/hair.position.y = 340
		if $wlosy/hair.flip_h == false:
			$wlosy/hair.position.x = -80
		else:
			$wlosy/hair.position.x = 80
	else:
		$wlosy/hair.position.x = 0
		$wlosy/hair.position.y = currLook.getHairPos()

func lookRight():
	$wlosy/hair.position.y = 340
	$wlosy/hair.position.x = -80
	$body.flip_h = false
	$body.animation = "walk side"
	$spodnie.flip_h = false
	$spodnie.animation = "walk side"
	$"clothes-top".flip_h = false
	$"clothes-top".animation = "walk side"
	$face/eyes.animation = "side"
	$face/eyes.flip_h = false
	$"face/eyes/eye-bonus".animation = "side"
	$"face/eyes/eye-bonus".flip_h = false
	$face/nose.flip_h = false
	$face/nose.animation = "side"
	$face/mouth.animation = "right"
	$wlosy/hair.flip_h = false
	$wlosy/hair.animation  = "side"
func lookLeft():
	$wlosy/hair.position.y = 340
	$wlosy/hair.position.x = 80
	$body.flip_h = true
	$body.animation = "walk side"
	$spodnie.flip_h = true
	$spodnie.animation = "walk side"
	$"clothes-top".flip_h = true
	$"clothes-top".animation = "walk side"
	$face/eyes.animation = "side"
	$face/eyes.flip_h = true
	$"face/eyes/eye-bonus".animation = "side"
	$"face/eyes/eye-bonus".flip_h = true
	$face/nose.flip_h = true
	$face/nose.animation = "side"
	$face/mouth.animation = "left"
	$wlosy/hair.flip_h = true
	$wlosy/hair.animation  = "side"
func lookFront():
	$wlosy/hair.position.y = currLook.getHairPos()
	$wlosy/hair.position.x = 0
	$body.flip_h = false
	$body.animation = "walk front"
	$spodnie.flip_h = false
	$spodnie.animation = "walk front"
	$"clothes-top".flip_h = false
	$"clothes-top".animation = "walk front"
	$face/eyes.animation = "front"
	$"face/eyes/eye-bonus".animation = "front"
	$face/nose.flip_h = false
	$face/nose.animation = "front"
	$face/mouth.animation = "front"
	$wlosy/hair.flip_h = false
	$wlosy/hair.animation  = "front"
func lookBack():
	$body.flip_h = false
	$body.animation = "walk back"
	$spodnie.flip_h = false
	$spodnie.animation = "walk back"
	$"clothes-top".flip_h = false
	$"clothes-top".animation = "walk back"
	$face/eyes.animation = "back"
	$"face/eyes/eye-bonus".animation = "back"
	$face/nose.flip_h = false
	$face/nose.animation = "back"
	$face/mouth.animation = "back"
	$wlosy/hair.flip_h = false
	$wlosy/hair.animation  = "back"
