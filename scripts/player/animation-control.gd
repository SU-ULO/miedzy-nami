extends Node2D

var stopped = true
var all_animated_sprites = []

const LookConfiguration = preload("res://entities/character-customisation/look-configuration.gd")		

var currLook = LookConfiguration.new()

func _ready():
	currLook = get_parent().currLook
	all_animated_sprites = [$body, $"clothes-top", $eyes, $"eyes/eye-bonus", $nose, $mouth, $spodnie, $wlosy/hair, $acc, $beard]
func stopWalk():
	for i in all_animated_sprites:
		i.playing = false
	for i in all_animated_sprites:
		i.frame = 1
	stopped = true

func startWalk():
	if stopped:
		for i in all_animated_sprites:
			i.frame = 0
		stopped = false
	for i in all_animated_sprites:
		i.playing = true
	
func loadLook():
	$spodnie.visible = currLook.hasBottom
	for i in $"clothes-top".frames.get_animation_names():
		$"clothes-top".frames.clear(i)

	for i in $body.frames.get_animation_names():
		$body.frames.clear(i)
		
	for i in $eyes.frames.get_animation_names():
		$eyes.frames.clear(i)
	
	for i in $"eyes/eye-bonus".frames.get_animation_names():
		$"eyes/eye-bonus".frames.clear(i)
		
	for i in $nose.frames.get_animation_names():
		$nose.frames.clear(i)
		
	for i in $mouth.frames.get_animation_names():
		$mouth.frames.clear(i)
	
	for i in $acc.frames.get_animation_names():
		$acc.frames.clear(i)		
		
	for i in $beard.frames.get_animation_names():
		$beard.frames.clear(i)		
		
	for i in $wlosy/hair.frames.get_animation_names():
		$wlosy/hair.frames.clear(i)	
				
	$body.frames.add_frame("side", load(currLook.getBodyPath(3)))
	$body.frames.add_frame("side", load(currLook.getBodyPath(1)))
	$body.frames.add_frame("side", load(currLook.getBodyPath(2)))
	$body.frames.add_frame("side", load(currLook.getBodyPath(1)))
	$body.frames.add_frame("front", load(currLook.getBodyPath(4)))
	$body.frames.add_frame("back", load(currLook.getBodyPath(4)))
	$"clothes-top".frames.add_frame("front", load(currLook.getTopClotes(2, get_parent().color)))
	$"clothes-top".frames.add_frame("front", load(currLook.getTopClotes(1, get_parent().color)))
	$"clothes-top".frames.add_frame("front", load(currLook.getTopClotes(3, get_parent().color)))
	$"clothes-top".frames.add_frame("front", load(currLook.getTopClotes(1, get_parent().color)))
	$"clothes-top".frames.add_frame("side", load(currLook.getTopClotes(5, get_parent().color)))
	$"clothes-top".frames.add_frame("side", load(currLook.getTopClotes(4, get_parent().color)))
	$"clothes-top".frames.add_frame("side", load(currLook.getTopClotes(6, get_parent().color)))
	$"clothes-top".frames.add_frame("side", load(currLook.getTopClotes(4, get_parent().color)))
	$"clothes-top".frames.add_frame("back", load(currLook.getTopClotes(8, get_parent().color)))
	$"clothes-top".frames.add_frame("back", load(currLook.getTopClotes(7, get_parent().color)))
	$"clothes-top".frames.add_frame("back", load(currLook.getTopClotes(9, get_parent().color)))
	$"clothes-top".frames.add_frame("back", load(currLook.getTopClotes(7, get_parent().color)))
	$face.texture = load(currLook.getSkinPath())
	$eyes.frames.add_frame("front", load(currLook.getEyePath(1)))
	$eyes.frames.add_frame("side", load(currLook.getEyePath(2)))
	if currLook.getEyeBonusPath() != "przykromi":
		$"eyes/eye-bonus".visible = true
		$"eyes/eye-bonus".frames.add_frame("front", load(currLook.getEyeBonusPath(1)))
		$"eyes/eye-bonus".frames.add_frame("side", load(currLook.getEyeBonusPath(2)))
	else:
		$"eyes/eye-bonus".visible = false
	$spodnie.frame = 0
	$body.frame = 0
	$"clothes-top".frame = 0
	$body.playing = 1
	$spodnie.playing = 1
	$"clothes-top".playing = 1
	$nose.frames.add_frame("front", load(currLook.getNosePath()))
	$nose.frames.add_frame("side", load(currLook.getNosePath(2)))
	$mouth.frames.add_frame("front", load(currLook.getMouthPath()))
	$mouth.frames.add_frame("side", load(currLook.getMouthPath(2)))
	$acc.frames.add_frame("front", load(currLook.getAccPath()))
	$acc.frames.add_frame("side", load(currLook.getAccPath(2)))
	$beard.frames.add_frame("front", load(currLook.getBeardPath()))
	$beard.frames.add_frame("side", load(currLook.getBeardPath(2)))
	$wlosy/hair.frames.add_frame("front", load(currLook.getHairPath()))
	$wlosy/hair.frames.add_frame("side", load(currLook.getHairPath(2)))
	$wlosy/hair.frames.add_frame("back", load(currLook.getHairPath(3)))
	if $wlosy/hair.animation == "side":
		$wlosy/hair.position.y = 340
		if $wlosy/hair.flip_h == false:
			$wlosy/hair.position.x = -80
		else:
			$wlosy/hair.position.x = 80
	elif $wlosy/hair.animation == "back":
		$wlosy/hair.position.x = 0
		$wlosy/hair.position.y = 340
	else:
		$wlosy/hair.position.x = 0
		$wlosy/hair.position.y = currLook.getHairPos()

func lookRight():
	$"clothes-top".show_behind_parent = true
	$body.show_behind_parent = true
	$wlosy.show_behind_parent = false
	$face.show_behind_parent = false
	$face.flip_h = false
	$wlosy/hair.position.y = 340
	$wlosy/hair.position.x = -80	
	for i in all_animated_sprites:
		i.flip_h = false
		i.animation = "side"

func lookLeft():
	$"clothes-top".show_behind_parent = true
	$body.show_behind_parent = true
	$wlosy.show_behind_parent = false
	$face.show_behind_parent = false
	$face.flip_h = true
	$wlosy/hair.position.y = 340
	$wlosy/hair.position.x = 80
	for i in all_animated_sprites:
		i.flip_h = true
		i.animation = "side"
		
func lookFront():
	$"clothes-top".show_behind_parent = false
	$body.show_behind_parent = false
	$wlosy.show_behind_parent = true
	$face.show_behind_parent = true
	$face.flip_h = false
	$wlosy/hair.position.y = currLook.getHairPos()
	$wlosy/hair.position.x = 0
	for i in all_animated_sprites:
		i.flip_h = false
		i.animation = "front"
func lookBack():
	$"clothes-top".show_behind_parent = true
	$body.show_behind_parent = true
	$wlosy.show_behind_parent = false
	$face.show_behind_parent = false
	$wlosy/hair.position.x = 0
	$wlosy/hair.position.y = 340
	$face.flip_h = true
	for i in all_animated_sprites:
		i.flip_h = false
		i.animation = "back"

