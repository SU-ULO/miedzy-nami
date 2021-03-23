extends HBoxContainer

var value
export var default_value := false

func _ready():
	$CheckBox.pressed = default_value
	value = default_value


func _on_CheckBox_pressed():
	value = $CheckBox.pressed

func get_value():
	return value
func set_value(val):
	$CheckBox.pressed = val
func update_label():
	pass
