extends Node2D

onready var player = get_owner()

# canvas for non persistent GUI elements such as task GUIs or other popups
onready var IC = get_node("InteractionCanvas")
# canvas for persistent GUI elements (no option to add nodes to that canvas etc.)
onready var PC = get_node("PlayerCanvas")

var currentGUI:Node = null

# these functions modify interactionCanvas only
# because player GUI should be persistent

func clear_canvas(): # removes all canvas children
	for child in IC.get_children():
		print("removing: ", child.name)
		child.queue_free()
	currentGUI = null

func add_to_canvas(gui:Node = null, gui_name:String = ""): # adds scene as InteractionCanvas child
	if Node == null:
		print("WARRNING: no GUI node. Scene not found")
		return null

	if gui_name == "":
		print("WARRNING: no GUI name. No way to detect GUI later")
		
	else:
		gui.name = gui_name
	
	IC.add_child(gui)
	currentGUI = gui
	print("adding: ", gui.name)

# this method shouldn't be really usefull since there should be no situation 
# when there is more than one GUI on canvas

func remove_form_canvas(gui_name:String = ""):
	if gui_name == "":
		# use clear canvas instead
		print("WARRNING: no GUI name. Assuming GUI is first child of Canvas")
		IC.get_child(0).queue_free()
	else:
		for child in IC.get_children():
			if child.name == gui_name:
				child.queue_free()
				return
	
		print("WARRNING: no GUI with name ", gui_name)


# helper function, clears and if current GUI != new GUI, adds new GUI
# returns false if GUI is not added (current GUI = new GUI) and true otherwise

func replace_on_canvas(gui:Node = null, gui_name:String = ""):
	if currentGUI != null and gui != null:
		if currentGUI.name == gui_name:
				clear_canvas()
				return false

	clear_canvas()
	add_to_canvas(gui, gui_name)
	return true


# this functions work both with IntercationCanvas and PlayerCanvas

# need canvas_name to be specified: IntercationCanvas, PlayerCanvas
# short names work as well: IC, PC
# and gui_item_path which is path relative to CanvasLayer
# and state which is boolean: true = visible, flase = invisible

# example: set_visibility("PC", "playerGUI/ActionButtons", false)

func set_visibility(canvas_name:String = "PC", gui_item_path:String = "", state:bool = false): # of GUI element
	if canvas_name == "IC" or canvas_name == "IntercationCanvas":
		var item = IC.get_node(gui_item_path)
		if item == null:
			print("WARRNING: no item with path ", gui_item_path, " on IntercationCanvas")
		else:
			item.visible = state
	elif canvas_name == "PC" or canvas_name == "PlayerCanvas":
		var item = PC.get_node(gui_item_path)
		if item == null:
			print("WARRNING: no item with path ", gui_item_path, " on PlayerCanvas")
		else:
			item.visible = state
	else:
		print("WARRNING: no Canvas with name ", canvas_name)

