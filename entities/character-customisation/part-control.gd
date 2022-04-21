extends Control

export var part_name = ""

var currLook = LookConfiguration.new()

const AtlasHandler = preload("res://scripts/TextureAtlasHandler.cs") 

func load_atlasable(path: String):
	return AtlasHandler.LoadOverride(path)

signal changePart(part, name)

var colorpickers = ["hairColor", "beardColor"]

func _ready():
	for i in $GridContainer.get_children():
		# warning-ignore:return_value_discarded
		i.connect("pressed", self, "_on_button_pressed", [i.name])
		if not colorpickers.has(part_name) && i.name != "bald":
			i.texture_normal = load_atlasable(currLook.get_look_path(part_name, i.name))

func _on_button_pressed(name):
	print(name)
	emit_signal("changePart", part_name, name)
	
func get_random():
	var x = $GridContainer.get_children()
	x.shuffle()
	emit_signal("changePart", part_name, x[0].name)
