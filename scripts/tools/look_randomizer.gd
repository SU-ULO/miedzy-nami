tool
extends EditorScript
# run in Character-cutomisation.tscn
var alllooks = {}

func _run():
	for i in get_scene().get_node("body-parts-control").get_children():
		var temp = []
		for j in i.get_node("GridContainer").get_children():
			temp.append("\"" + j.name + "\"")
		alllooks["\"" + i.name.trim_suffix("-control") + "\""] = temp
	var color_controlers = ["eye-color", "beard-color", "hair-color"]
	for i in color_controlers:
		var temp = []
		for j in get_scene().get_node(i + "/GridContainer").get_children():
			temp.append("\"" + j.name + "\"")
		alllooks["\"" + i + "\""] = temp
	print(alllooks)
