extends Node2D

export var linkedcameras = []
onready var camera_gui = preload("res://gui/cameras/camera-gui.tscn").instance()
onready var canvas = get_owner().get_node("CanvasLayer")
onready var world = get_world_2d()

func _ready():
	self.add_to_group("entities")
	self.add_to_group("interactable")
	self.add_to_group("cameras")

func delete_gui(body):
	for lc in linkedcameras:
		get_node(lc).get_node("Camera2D").current = 0
		get_node(lc).get_node("Light2D").visible = 0
		#warning-ignore:return_value_discarded
		get_node(lc).disconnect("camera_detection", body, "camera_visibility")
		get_node(lc).get_node("Area2D").monitoring = 0
	canvas.remove_child(camera_gui)

func instance_gui(body):
	for vp in camera_gui.viewports:
		camera_gui.get_node(vp).world_2d = world
		
	canvas.add_child(camera_gui)
	var iter = 0
	
	for vp in camera_gui.viewports:
		get_node(linkedcameras[iter]).get_node("Camera2D").set_custom_viewport(camera_gui.get_node(vp))
		get_node(linkedcameras[iter]).get_node("Camera2D").current = 1
		get_node(linkedcameras[iter]).get_node("Light2D").visible = 1
		#warning-ignore:return_value_discarded
		get_node(linkedcameras[iter]).connect("camera_detection", body, "camera_visibility")
		get_node(linkedcameras[iter]).get_node("Area2D").monitoring = 1
		get_node(linkedcameras[iter]).detect()
		iter += 1

func open(body):
	instance_gui(body)

func close(body):
	delete_gui(body)
