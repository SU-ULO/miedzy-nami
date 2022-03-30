extends Node2D

export var linkedcameras = []
onready var gui_res = "res://gui/cameras/camera-gui.tscn"
onready var world = get_world_2d()

var texture_inactive = "res://textures/dekoracje/kamera.png"
var texture_active = "res://textures/dekoracje/kamera-active.png"

var camera_gui = null
var disabled = false

func _ready():
	self.add_to_group("entities")
	self.add_to_group("interactable")
	self.add_to_group("cameras")

func cameras_off(body):
		for lc in linkedcameras:
			get_node(lc).get_node("Camera2D").current = 0
			get_node(lc).get_node("Camera2D").set_custom_viewport(get_viewport())
			get_node(lc).get_node("Light2D").visible = 0
			# warning-ignore:return_value_discarded
			if get_node(lc).is_connected("camera_detection", body, "camera_visibility"):
				get_node(lc).disconnect("camera_detection", body, "camera_visibility")
			get_node(lc).get_node("Area2D").monitoring = 0
		if !disabled:
			Globals.start.network.request_cameras_enable(false)

func cameras_on(body):
	if camera_gui != null:
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
	disabled = Globals.start.network.comms_disabled
	body.connect("sabotage_event", self, "refresh")
	camera_gui = load(gui_res).instance()
	for vp in camera_gui.viewports:
		camera_gui.get_node(vp).world_2d = world
		
	camera_gui.player = body
	body.get_node("GUI").add_to_canvas(camera_gui)
	cameras_on(body)

func EndInteraction(body):
	cameras_off(body)
	body.disconnect("sabotage_event", self, "refresh")
	body.get_node("GUI").clear_canvas()
	camera_gui = null

func refresh(sabotage):
	if sabotage == 3 or sabotage == 0:
		var body = Globals.start.network.own_player
		cameras_off(body)
		disabled = Globals.start.network.comms_disabled
		cameras_on(body)
