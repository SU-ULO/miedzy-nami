extends Node

class_name NetworkManager

var world := preload('res://scenes/school.tscn').instance()

# warning-ignore:unused_signal
signal joined_room()
# warning-ignore:unused_signal
signal left_room()

