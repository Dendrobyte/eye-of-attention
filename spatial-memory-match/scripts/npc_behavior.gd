extends Node3D
class_name NPCBehavior

# This is set in the level manager
var wanted_item_str: String
var want_timer: Timer

var satisfied = false

var primary_mat: Material = null
var satisfied_mat: Material = null

# Track if the player gave the wrong item once (or more)
var was_wrong = false

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
		want_timer.wait_time = 2.0
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

	# Load the materials, fine for now with small amount unordered
	# ALL MATERIALS LINKED TO `Arm_L`
	var linked_material_base: MeshInstance3D = get_node("Arm_L")
	primary_mat = linked_material_base.get_active_material(0)
	satisfied_mat = linked_material_base.get_active_material(1)


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
		satisfy_npc()
	elif wanted_item_str != held_item_name && wanted_item_str != "":
		was_wrong = true
		GlobalState.incr_error_wrong_item()
		display_want()
	else:
		display_want()
	return satisfied

func satisfy_npc():
	# TODO: Make them all the same mesh or something
	for body_part in get_children():
		if body_part as MeshInstance3D and body_part.name != "Mask":
			$AnimationPlayer.play("jump")
			body_part.set_surface_override_material(0, satisfied_mat)
	satisfied = true
	GlobalState.incr_satisfy_npc()
