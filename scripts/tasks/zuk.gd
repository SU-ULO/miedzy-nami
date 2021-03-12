extends AnimatedSprite

var velocity = Vector2(600, 600)
var rng = RandomNumberGenerator.new()
var xxx 

func _ready():
	rng.randomize()
	xxx = 0.04
func _physics_process(delta):
	velocity = velocity.rotated(xxx)
	position += velocity * delta
	rotation = velocity.angle() + 90
	if get_parent().get_node("Position2D").position.x > position.x:
		velocity.x = abs(velocity.x)
	if get_parent().get_node("Position2D").position.y > position.y:
		velocity.y = abs(velocity.y)
	if get_parent().get_node("Position2D2").position.x < position.x:
		velocity.x = -abs(velocity.x)
	if get_parent().get_node("Position2D2").position.y < position.y:
		velocity.y = -abs(velocity.y)
func _on_Timer_timeout():
	xxx = 0.06 * rng.randf_range(0.5, 2) * (rng.randi_range(0, 1) * 2 - 1)


func _on_TextureButton_pressed():
	visible = false
	get_parent().bugKilledRIP()
