extends Node2D

export var linkedcameras = []
onready var camera_gui = preload("res://gui/cameras/camera-gui.tscn").instance()
onready var canvas = get_owner().get_node("CanvasLayer")
onready var world = get_world_2d()

var texture_inactive = "res://textures/dekoracje/kamera.png"
var texture_active = "res://textures/dekoracje/kamera-active.png"

func _ready():
	self.add_to_group("entities")
	self.add_to_group("interactable")
	self.add_to_group("cameras")

func delete_gui(body):
	for lc in linkedcameras:
		get_node(lc).get_node("Camera2D").current = 0
		get_node(lc).get_node("Light2D").visible = 0
		# warning-ignore:return_value_discarded
		get_node(lc).disconnect("camera_detection", body, "camera_visibility")
		get_node(lc).get_node("Area2D").monitoring = 0
	canvas.remove_child(camera_gui)
	
	get_tree().get_root().get_node('Start').network.request_cameras_enable(false)

func instance_gui(body):
	for vp in camera_gui.viewports:
		camera_gui.get_node(vp).world_2d = world
		
	canvas.add_child(camera_gui)
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
	get_tree().get_root().get_node('Start').network.request_cameras_enable(true)

func Interact(body):
	instance_gui(body)

func EndInteraction(body):
	delete_gui(body)
