extends HBoxContainer

#get value by function get_value(), not by varible directly!!!

signal settingchanged()

var value
export var prefix := ""
export var default_value := 0
export var step := 1
export var min_val := 0
export var max_val := 10
export var div = 1
export var non_numeric_values := false
export(Array, String) var values = [] #only used if non numeric values is true

func _ready():
	value = default_value
	if non_numeric_values:
		$value.text = values[default_value] + prefix
	else:
		$value.text = str(get_value()) + prefix

func _on_plus_pressed():
	value = count_next(step)
	update_label()
	emit_signal("settingchanged")

func _on_minus_pressed():
	value = count_next(-step)
	update_label()
	emit_signal("settingchanged")

func count_next(val):
	if non_numeric_values:
		return wrapi(value + val, 0, values.size())
	else:
		return wrapi(value + val, min_val, max_val + step)

func update_label():
	if non_numeric_values:
		$value.text = values[value] + prefix
	else:
		$value.text = str(get_value()) + prefix

func get_value():
	if non_numeric_values:
		return value
	else:
		return (float(value) / float(div))

func set_value(x):
	if non_numeric_values:
		value = x
	else:
		value = x * div	
