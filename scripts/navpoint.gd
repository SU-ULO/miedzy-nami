extends Node2D

class_name NavPoint

enum NavpointType {ROOM_NAVPOINT, PATH_NAVPOINT}
enum LookDirection {UP, DOWN, LEFT, RIGHT}

export(NavpointType) var type = NavpointType.ROOM_NAVPOINT
export(float) var idling_chance = 0.0
export(LookDirection) var look_dir = LookDirection.DOWN
export(float) var wait_time = 2.0
export(float) var skip_chance = 0.0

func _ready():
	add_to_group("entities")
