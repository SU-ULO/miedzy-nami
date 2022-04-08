tool
extends EditorScript

func _run():
	var parent = get_scene().get_node("GridContainer")
	for i in dir_contents("res://textures/character/beards/frame1/"):
		if i != ".." and i != ".":
			var node = TextureButton.new()
			node.name = i
			node.texture_normal = load("res://textures/character/beards/frame1/" + i + "/" + i + "_black.png")
			parent.add_child(node)
			node.set_owner(get_scene())

func dir_contents(path):
	var filenames = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			filenames.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return filenames
