extends Node2D

onready var player = get_owner()

# canvas for non persistent GUI elements such as task GUIs or other popups
onready var IC = get_node("InteractionCanvas")
# canvas for persistent GUI elements (no option to add nodes to that canvas etc.)
onready var PC = get_node("PlayerCanvas")
# close button for Tasks and other interactions (but not for maps)
onready var CB = get_node("CloseButton")

var currentGUI:Node = null

# these functions modify interactionCanvas only
# because player GUI should be persistent

func clear_canvas(): # removes all canvas children
	for child in IC.get_children():
		print("removing: ", child.name)
		child.queue_free()
	currentGUI = null
	set_visibility("PC", "playerGUI", 1)
	set_visibility("PC", "playerGUI", 1)
	set_visibility("CB", "B", 0)

func canvas_empty():
	if IC.get_child_count() > 0:
		return false
	else:
		return true

func add(gui:Node = null): # adds scene as InteractionCanvas child
	if Node == null:
		print("WARRNING: no GUI node. Scene not found")
		return false

	IC.add_child(gui)
	currentGUI = gui
	print("adding: ", gui.name)
	return true

# this method shouldn't be really usefull since there should be no situation 
# when there is more than one GUI on canvas

func remove_form_canvas(gui_name:String = "no name was spacified"):
	var gui = get_node_or_null(gui_name) # get gui by name
	if gui != null: # if gui exist
		gui.queue_free() # remove it
	else: # else print
		print("WARRNING: no GUI with name ", gui_name)

# clears canvas and adds gui to canvas, 
# returns true if GUI was added and false if not

func add_to_canvas(gui:Node = null, show_button:bool = true):
	clear_canvas()
	if add(gui):
		set_visibility("PC", "playerGUI", 0)
		if show_button:
			set_visibility("CB", "B", 1)
		return true
	return false

# helper function, clears canvas and if current GUI != new GUI, adds new GUI
# (basically add to gui but for maps and other popups)
# returns true if GUI was added and false if not

func replace_on_canvas(gui:Node = null):
	
	if currentGUI != null:
		if currentGUI.name == gui.name:
			clear_canvas()
			set_visibility("PC", "playerGUI/ActionButtons", 1)
			set_visibility("PC", "playerGUI/TaskPanel", 1)
			set_visibility("PC", "playerGUI/gamecode", 1)
			
			if player.is_in_group("impostors"):
				set_visibility("PC", "playerGUI/ImpostorButtons", 1)
				set_visibility("PC", "playerGUI/ActionButtons/report", 1)
			return false
	
	clear_canvas()
	if add(gui):
		set_visibility("PC", "playerGUI/ActionButtons", 0)
		set_visibility("PC", "playerGUI/TaskPanel", 0)
		set_visibility("PC", "playerGUI/gamecode", 0)
		
		if player.is_in_group("impostors"):
			set_visibility("PC", "playerGUI/ImpostorButtons", 0)
			set_visibility("PC", "playerGUI/ActionButtons/report", 0)
		return true
	return false

# this function work with all GUI canvases

# needs canvas_name to be specified: IntercationCanvas, PlayerCanvas, CloseButton
# short names work as well: IC, PC, CB
# gui_item_path which is path relative to CanvasLayer
# and state which is boolean: true = visible, flase = invisible

# example: set_visibility("PC", "playerGUI/ActionButtons", false)

func set_visibility(canvas_name:String = "PC", gui_item_path:String = "", state:bool = false): # of GUI element
	var item = null
	if canvas_name == "IC" or canvas_name == "IntercationCanvas":
		item = IC.get_node_or_null(gui_item_path)
	elif canvas_name == "PC" or canvas_name == "PlayerCanvas":
		item = PC.get_node_or_null(gui_item_path)
	elif canvas_name == "CB" or canvas_name == "CloseButton":
		item = CB.get_node_or_null(gui_item_path)
	else:
		print("WARRNING: no Canvas with name ", canvas_name)
		return false
	
	if item == null:
		print("WARRNING: no item with path ", gui_item_path, " on ", canvas_name)
	else:
		item.visible = state