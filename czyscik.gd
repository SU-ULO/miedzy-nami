extends TextureButton

var closer

var dragging = false
var inProbowka = false
var clickDelta
var cleared = false
var toClear = [2, 2]
var bruud=[[],[]]
var cleaning = 0
var ended = false
func _ready():
	bruud[0].append(get_parent().get_node("brud"))
	bruud[0].append(get_parent().get_node("brud2"))
	bruud[1].append(get_parent().get_node("brud3"))
	bruud[1].append(get_parent().get_node("brud4"))
func _process(_delta):
	if ($czubek.global_position - get_parent().get_node("p1").position).length() < ($czubek.global_position - get_parent().get_node("p2").position).length():
		closer = get_parent().get_node("p1")
		cleaning = 0
	else:
		closer = get_parent().get_node("p2")
		cleaning = 1
	if ($czubek.global_position - closer.position).length() < 50 && $czubek.global_position.x > closer.position.x && abs(rect_rotation) < 45:
		inProbowka = true
	else:
		if inProbowka && $czubek.global_position.x < closer.global_position.x + 50:
			pass
		else:
			inProbowka = false
	if not inProbowka:
		rect_rotation = $czubek.global_position.angle_to_point(closer.position) * 180 /  PI
	else:
		rect_rotation = 0
	if dragging:
		if inProbowka:
			rect_global_position = Vector2(clamp(get_viewport().get_mouse_position().x - clickDelta.x, 45, 100000), closer.position.y - (rect_size.y * rect_scale.y / 2))
			if $czubek.global_position.x < closer.get_node("k").global_position.x:
				cleared = true
			if cleared && $czubek.global_position.x > closer.get_node("k").global_position.x + 400:
				cleared = false
				#wyczysc brud
				if toClear[cleaning] > 0:
					bruud[cleaning][toClear[cleaning]-1].visible = false
				toClear[cleaning]-=1
		else:
			rect_global_position = get_viewport().get_mouse_position()  - clickDelta
	if toClear[0] <= 0 && toClear[1] <=0:
		if !ended:
			endpls()
			ended = true

	


func _on_czyscik_button_down():
	dragging = true
	clickDelta = get_viewport().get_mouse_position() - rect_global_position


func _on_czyscik_button_up():
	dragging = false

func endpls():
		get_parent().get_node("Timer").start()
		yield(get_parent().get_node("Timer"), "timeout")
		var TaskWithGUI = load("res://scripts/tasks/TaskWithGUI.cs")
		TaskWithGUI.TaskWithGUICompleteTask(get_parent())
