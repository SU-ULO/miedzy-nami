extends Node2D

export var linkedcameras = []
onready var gui_res = "res://gui/cameras/camera-gui.tscn"
onready var world = get_world_2d()

var texture_inactive = "res://textures/dekoracje/kamera.png"
var texture_active = "res://textures/dekoracje/kamera-active.png"

var disabled = false

var player

func _ready():
	self.add_to_group("entities")
	self.add_to_group("interactable")
	self.add_to_group("cameras")
	Globals.start.network.connect("sabotage", self, "exit_gui")
func delete_gui(body):
	if !disabled:
		for lc in linkedcameras:
			get_node(lc).get_node("Camera2D").current = 0
			get_node(lc).get_node("Light2D").visible = 0
			# warning-ignore:return_value_discarded
			get_node(lc).disconnect("camera_detection", body, "camera_visibility")
			get_node(lc).get_node("Area2D").monitoring = 0
		Globals.start.network.request_cameras_enable(false)
	body.get_node("GUI").clear_canvas()

func instance_gui(body):
	var camera_gui = load(gui_res).instance()
	for vp in camera_gui.viewports:
		camera_gui.get_node(vp).world_2d = world
	
	camera_gui.player = body
	body.get_node("GUI").add_to_canvas(camera_gui)
	
	camera_gui.get_node("off").visible = disabled
	if !disabled:
		var iter = 0
		for vp in camera_gui.viewports:
			var camera = get_node(linkedcameras[iter])
			camera.get_node("Camera2D").set_custom_viewport(camera_gui.get_node(vp))
			camera.get_node("Camera2D").current = 1
			camera.get_node("Light2D").visible = 1
			# warning-ignore:return_value_discarded
			camera.connect("camera_detection", body, "camera_visibility")
			camera.get_node("Area2D").monitoring = 1
			camera.detect()
			iter += 1
		Globals.start.network.request_cameras_enable(true)
	
	for vp in camera_gui.viewports:
		camera_gui.get_node(vp).get_parent().get_node("color").visible = disabled

func Interact(body):
	disabled = get_tree().get_root().get_node("Start").network.comms_disabled
	player = body
	instance_gui(body)

func EndInteraction(body):
	player = null
	delete_gui(body)

func exit_gui(type):
	if type == 3:
		if player:
			player.ui_canceled()
