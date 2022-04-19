extends Node2D

class_name NavPoint

enum NavpointType {ROOM_NAVPOINT, PATH_NAVPOINT}

export(NavpointType) var type = NavpointType.ROOM_NAVPOINT
export(float) var skip_chance = 0

func _ready():
	add_to_group("entities")
