extends StaticBody2D

export var link = [] # array of nodepaths the vent is supposed to link to
var pos = [] # positions of nodes from array above

# variables for arrows instancing
onready var arrow = preload("res://objects/vents/arrow.tscn")
const radius = 150

func enter(body):
	# center player on vent and make him invisible (but not the light)
	body.position = self.position
	body.get_node("sprites").visible = false
	# also hitbox to prevent player being detected
	body.get_node("PlayerHitbox").visible = false

	# also here probably should be animation of entering in some if
	
	var instance; var iter = 0; var angle
	# for every connected vent instance an arrow pointing to it
	# put arrows on circle perimeter of const radius specified above
	# and centered on vent
	for item in pos:
		$arrows.add_child(arrow.instance())
		instance = $arrows.get_child(iter)
		angle = item.angle_to_point(self.position)
		
		instance.set_position(Vector2(radius * cos(angle), radius * sin(angle)))
		instance.set_rotation(angle)
		
		instance.link = link[iter]
		instance.body = body
		instance.child_number = iter
		iter += 1

func teleport(body, vent): # called by arrow instance after click on it
	
	# remove all arrows first
	for child in $arrows.get_children():
		child.queue_free()
		
	# then call enter function on new vent
	body.currentInteraction = get_node(vent)
	get_node(vent).enter(body)

func exit(body):
	
	# remove all arrows first
	for child in $arrows.get_children():
		child.queue_free()
		
	# then make player visible
	body.get_node("sprites").visible = true
	body.get_node("PlayerHitbox").visible = true

func arrowHighlight(arrow_number = -1):
	for child in $arrows.get_children():
		child.modulate = Color("#FF0000")
	
	if arrow_number >= 0:
		$arrows.get_child(arrow_number).modulate = Color("#00FF00")

func _ready():
	self.add_to_group("entities")
	self.add_to_group("interactable")
	self.add_to_group("vents")
	
	# get all linked vents positions
	for item in link:
		pos.append(get_node(item).position)

func Interact(body):
	enter(body)

func EndInteraction(body):
	exit(body)
