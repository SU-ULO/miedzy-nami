extends Sprite

const AtlasHandler = preload("res://scripts/TextureAtlasHandler.cs") 

func load_atlasable(path: String):
	return AtlasHandler.LoadOverride(path)

func _ready():
	texture = load_atlasable("res://textures/character/clothes/jeans/front/2")
