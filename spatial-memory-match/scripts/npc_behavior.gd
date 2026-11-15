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
var want_timer: Timer

var satisfied = false

# Helper functions for state
func toggle_mask(value):
	if value:
		$Mask.show()
	else:
		$Mask.hide()

func toggle_want(value):
	if value:
		$WantedItem.show()
		want_timer = Timer.new()
		want_timer.wait_time = 3.0
		want_timer.one_shot = true
		want_timer.timeout.connect(func():
			$WantedItem.hide()
			toggle_mask(true)
			want_timer = null
		)

		add_child(want_timer)
		want_timer.start()

	else:
		$WantedItem.hide()

func _ready():
	# Get the wanted item and spawn it above head, then hide it
	var want_pos = $Want.position
	$Want.queue_free()

	var wanted_item = GlobalState.item_node_map[wanted_item_str].duplicate()
	wanted_item.get_node("StaticBody3D").queue_free()
	wanted_item.position = want_pos
	wanted_item.scale = 0.8 * wanted_item.scale
	wanted_item.name = "WantedItem"
	add_child(wanted_item)
	$WantedItem.hide()

func interact():
	if satisfied:
		print("Already gave character what they wanted")
		return
	if GlobalState.has_item(wanted_item_str):
		satisfied = true
		print("Character satisfied!")
	else:
		if not want_timer: # use timer nil state to see if showing item already
			toggle_mask(false)
			toggle_want(true)
