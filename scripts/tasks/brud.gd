extends Sprite

var isVisible = true

func _ready():
	# warning-ignore:return_value_discarded
	$Area2D.connect("area_entered", self, "hideSelf")

func hideSelf(area):
	if self.visible:
		if area.name == "gabka":
			self.visible = false
			get_owner().imDone()
			
			
