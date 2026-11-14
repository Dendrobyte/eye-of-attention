extends Node

var level_name = "prototype_map"
var ITEM_POSITIONS = [] # NOTE: i don't think we need dicts, just remove when unused
var PLAYER_POSITIONS = []

var CHARACTER_MODEL = preload("res://assets/char_base.glb")
var ITEM_SCENE = preload("res://assets/items/items.glb")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var map = get_child(0) # always keep map as 0th child I guess
	var item_parent = get_child(1)
	var char_parent = get_child(2)

	# Log all positions
	for child in map.get_children():
		var child_name = child.name
		# log positions and free those nodes
		if child_name.contains("PLAYER_POS"):
			# only trim if the dict ends up being necessary
			# var num: int = child_name.trim_prefix("PLAYER_POS_").to_int() # prefer hard error here
			PLAYER_POSITIONS.append(child.position)
			child.queue_free()
		if child_name.contains("ITEM_POS"):
			# var num: int = child_name.trim_prefix("PLAYER_POS_").to_int() # prefer hard error here
			ITEM_POSITIONS.append(child.position)
			child.queue_free()
	print("Loaded item and player positions\n Player Count: ", len(PLAYER_POSITIONS), "\nItem Count: ", len(ITEM_POSITIONS))

	# Get the items and then scatter them at those positions
	var used_item_names = [] # TODO: Will use this for each character below
	var item_nodes = extract_items(ITEM_SCENE)

	# NOTE: Always assuming more items than positions
	for idx in range(len(ITEM_POSITIONS)):
		var item_pos = ITEM_POSITIONS[idx]
		var item_node = item_nodes[idx]
		item_node.position = item_pos
		item_parent.add_child(item_node)

	used_item_names.clear() # idk, memory

	# Spawn player models at the player positions
	for p_pos in PLAYER_POSITIONS:
		var new_char = CHARACTER_MODEL.instantiate()
		new_char.position = p_pos
		char_parent.add_child(new_char)

func extract_items(scene_packed):
	var result_item_nodes = []
	var scene: Node = scene_packed.instantiate()

	for item_node in scene.get_children():
		result_item_nodes.append(item_node.duplicate())

	scene.queue_free()
	return result_item_nodes
	
# func _process(delta: float) -> void:
# 	pass
