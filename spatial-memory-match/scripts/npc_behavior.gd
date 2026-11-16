extends Node3D
class_name NPCBehavior

# This is set in the level manager
var wanted_item_str: String
var want_timer: Timer

var satisfied = false

# True, take it off. False, put it on.
func toggle_mask(on_or_off):
	if on_or_off:
		$AnimationPlayer.play("mask_off")
		await $AnimationPlayer.animation_finished
	else:
		$AnimationPlayer.play("mask_on")

func display_want():
	if !satisfied && not want_timer: # use timer nil state to see if showing item already
		await toggle_mask(true)
		$WantedItem.show()
		want_timer = Timer.new()
		want_timer.wait_time = 3.0
		want_timer.one_shot = true
		want_timer.timeout.connect(func():
			$WantedItem.hide()
			want_timer = null
			toggle_mask(false)
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
		return ""
	else:
		# may show flicker of item?
		return wanted_item_str

# TODO: Show success and error visuals
func maybe_satisfy(held_item_name: String):
	if !satisfied && wanted_item_str == held_item_name:
		satisfied = true
		GlobalState.incr_satisfy_npc()
	else:
		display_want()
	return satisfied
