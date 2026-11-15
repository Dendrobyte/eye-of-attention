extends Node3D
class_name NPCBehavior

@export var mask_on = true:
	set(value):
		mask_on = value
		toggle_mask(value)

@export var show_want = false:
	set(value):
		show_want = value
		toggle_want(value)

# This is set in the level manager
var wanted_item_str: String

# Helper functions for state
func toggle_mask(value):
	if value:
		$Mask.show()
	else:
		$Mask.hide()

func toggle_want(value):
	if value:
		$WantedItem.show()
	else:
		$WantedItem.hide()

func _ready():
	# Get the wanted item and spawn it above head, then hide it
	var want_pos = $Want.position
	var want_rot = $Want.rotation
	$Want.queue_free()

	var wanted_item = GlobalState.item_node_map[wanted_item_str].duplicate()
	wanted_item.position = want_pos
	wanted_item.rotation = want_rot
	wanted_item.name = "WantedItem"
	add_child(wanted_item)
	$WantedItem.hide()

# start timer etc
func interact():
	toggle_mask(false)
	toggle_want(true)
	# TODO: Timer to hide
