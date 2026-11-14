extends Node3D
class_name NPC_Behavior

@export var mask_on = true:
	set(value):
		mask_on = value
		toggle_mask(value)

@export var show_want = true:
	set(value):
		show_want = value
		toggle_want(value)

# Helper functions for state
func toggle_mask(value):
	if value:
		$Mask.show()
	else:
		$Mask.hide()

func toggle_want(value):
	if value:
		$Want.show()
	else:
		$Want.hide()