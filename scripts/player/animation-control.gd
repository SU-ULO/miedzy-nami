extends Node2D

var stopped = true
var currLook
var all_animated_sprites = []

const AtlasHandler = preload("res://scripts/TextureAtlasHandler.cs") 

func load_atlasable(path: String):
	return AtlasHandler.LoadOverride(path)

func _ready():
	currLook = get_parent().currLook
	all_animated_sprites = [$body, $"clothes-top", $face/eyes, $face/eyes, $"face/eyes/eye-bonus", $face/nose, $face/mouth, $spodnie, $wlosy/hair, $face/acc, $face/beard]

func stopWalk():
#	for i in all_animated_sprites:
#		i.playing = false
#	for i in all_animated_sprites:
#		i.frame = 1
	#stopped = true
	pass

func startWalk():
	if stopped:
		for i in all_animated_sprites:
			i.frame = 0
		stopped = false
	for i in all_animated_sprites:
		i.playing = true
	
func loadLook():
	$spodnie.visible = currLook.hasBottom
	
	if ($spodnie.frames.get_frame_count("front") == 0):
		$spodnie.frames.add_frame("front", load_atlasable("res://textures/character/clothes/jeans/front/0"))	
		$spodnie.frames.add_frame("front", load_atlasable("res://textures/character/clothes/jeans/front/2"))
		$spodnie.frames.add_frame("front", load_atlasable("res://textures/character/clothes/jeans/front/1"))
		$spodnie.frames.add_frame("front", load_atlasable("res://textures/character/clothes/jeans/front/2"))
	if ($spodnie.frames.get_frame_count("side") == 0):
		$spodnie.frames.add_frame("side", load_atlasable("res://textures/character/clothes/jeans/side/0"))
		$spodnie.frames.add_frame("side", load_atlasable("res://textures/character/clothes/jeans/side/2"))
		$spodnie.frames.add_frame("side", load_atlasable("res://textures/character/clothes/jeans/side/1"))
		$spodnie.frames.add_frame("side", load_atlasable("res://textures/character/clothes/jeans/side/2"))

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
	
	for i in $face/acc.frames.get_animation_names():
		$face/acc.frames.clear(i)		
		
	for i in $face/beard.frames.get_animation_names():
		$face/beard.frames.clear(i)		
		
	for i in $wlosy/hair.frames.get_animation_names():
		$wlosy/hair.frames.clear(i)	
				
	$body.frames.add_frame("side", load_atlasable(currLook.getBodyPath(3)))
	$body.frames.add_frame("side", load_atlasable(currLook.getBodyPath(1)))
	$body.frames.add_frame("side", load_atlasable(currLook.getBodyPath(2)))
	$body.frames.add_frame("side", load_atlasable(currLook.getBodyPath(1)))
	$body.frames.add_frame("front", load_atlasable(currLook.getBodyPath(4)))
	$body.frames.add_frame("back", load_atlasable(currLook.getBodyPath(4)))
	
	$"clothes-top".frames.add_frame("front", load_atlasable(currLook.getTopClotes(2, get_parent().color)))
	$"clothes-top".frames.add_frame("front", load_atlasable(currLook.getTopClotes(1, get_parent().color)))
	$"clothes-top".frames.add_frame("front", load_atlasable(currLook.getTopClotes(3, get_parent().color)))
	$"clothes-top".frames.add_frame("front", load_atlasable(currLook.getTopClotes(1, get_parent().color)))
	
	$"clothes-top".frames.add_frame("side", load_atlasable(currLook.getTopClotes(5, get_parent().color)))
	$"clothes-top".frames.add_frame("side", load_atlasable(currLook.getTopClotes(4, get_parent().color)))
	$"clothes-top".frames.add_frame("side", load_atlasable(currLook.getTopClotes(6, get_parent().color)))
	$"clothes-top".frames.add_frame("side", load_atlasable(currLook.getTopClotes(4, get_parent().color)))
	
	print(currLook.getTopClotes(4, get_parent().color))
	
	$"clothes-top".frames.add_frame("back", load_atlasable(currLook.getTopClotes(8, get_parent().color)))
	$"clothes-top".frames.add_frame("back", load_atlasable(currLook.getTopClotes(7, get_parent().color)))
	$"clothes-top".frames.add_frame("back", load_atlasable(currLook.getTopClotes(9, get_parent().color)))
	$"clothes-top".frames.add_frame("back", load_atlasable(currLook.getTopClotes(7, get_parent().color)))
	
	$face.texture = load_atlasable(currLook.getSkinPath())
	$face/eyes.frames.add_frame("front", load_atlasable(currLook.getEyePath(1)))
	$face/eyes.frames.add_frame("side", load_atlasable(currLook.getEyePath(2)))
	if currLook.getEyeBonusPath() != "przykromi":
		$"face/eyes/eye-bonus".visible = true
		$"face/eyes/eye-bonus".frames.add_frame("front", load_atlasable(currLook.getEyeBonusPath(1)))
		$"face/eyes/eye-bonus".frames.add_frame("side", load_atlasable(currLook.getEyeBonusPath(2)))
	else:
		$"face/eyes/eye-bonus".visible = false
	$spodnie.frame = 0
	$body.frame = 0
	$"clothes-top".frame = 0
	$body.playing = 1
	$spodnie.playing = 1
	$"clothes-top".playing = 1
	$face/nose.frames.add_frame("front", load_atlasable(currLook.getNosePath()))
	$face/nose.frames.add_frame("side", load_atlasable(currLook.getNosePath(2)))
	$face/mouth.frames.add_frame("front", load_atlasable(currLook.getMouthPath()))
	$face/mouth.frames.add_frame("side", load_atlasable(currLook.getMouthPath(2)))
	$face/acc.frames.add_frame("front", load_atlasable(currLook.getAccPath()))
	$face/acc.frames.add_frame("side", load_atlasable(currLook.getAccPath(2)))
	$face/beard.frames.add_frame("front", load_atlasable(currLook.getBeardPath()))
	$face/beard.frames.add_frame("side", load_atlasable(currLook.getBeardPath(2)))
	$wlosy/hair.frames.add_frame("front", load_atlasable(currLook.getHairPath()))
	$wlosy/hair.frames.add_frame("side", load_atlasable(currLook.getHairPath(2)))
	$wlosy/hair.frames.add_frame("back", load_atlasable(currLook.getHairPath(3)))
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

