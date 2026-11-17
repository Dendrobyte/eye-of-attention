extends Node
class_name LevelManager

var ITEM_POSITIONS = [] # NOTE: i don't think we need dicts, just remove when unused
var NPC_TRANSFORMS = [] # { "position": ..., "rotation": ... }

var NPC_MODEL = preload("res://entity_scenes/char_base_scene.tscn")
var NPC_SCRIPT = preload("res://scripts/npc_behavior.gd")
var ITEM_SCENE = preload("res://assets/items.glb")
var ITEM_SCRIPT = preload("res://scripts/item_behavior.gd")

# Debug Options
@export_enum("prototype_map", "first_floor") var level_scene_name: String
@export var no_randomize: bool = false
@export var npc_count = 8 # todo: wire up to menu, like this for debug

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_child(0).queue_free() # free the prototype map
	# Load the map from selected, must be present in `/assets/levels`
	var map_scene: PackedScene = load("res://assets/levels/" + level_scene_name + ".glb")
	var map = map_scene.instantiate()
	add_child(map)
	var item_parent = $ItemParent
	var npc_parent = $NPCParent

	# Log all positions
	for child in map.get_children():
		var child_name = child.name
		# log positions and free those nodes
		if child_name.contains("PLAYER_POS"):
			# var num: int = child_name.trim_prefix("PLAYER_POS_").to_int() # prefer hard error here
			NPC_TRANSFORMS.append({"position": child.position, "rotation": child.rotation})
			child.queue_free()
		if child_name.contains("ITEM_POS"):
			ITEM_POSITIONS.append(child.position)
			child.queue_free()
		if child_name.contains("PLAYER_START_POS"):
			GlobalState.set_start_pos(child.position)
	print("Loaded item and NPC positions\nNPC Count: ", len(NPC_TRANSFORMS), "\nItem Count: ", len(ITEM_POSITIONS))

	# Get the items and then scatter them at those positions
	var used_item_names = []
	var item_nodes = extract_items(ITEM_SCENE)

	if !no_randomize:
		ITEM_POSITIONS.shuffle()

	# NOTE: Always assuming more items than positions
	print("item pos: ", ITEM_POSITIONS)
	print("item nodes: ", item_nodes)
	for idx in range(len(ITEM_POSITIONS)):
		var item_pos = ITEM_POSITIONS[idx]
		var item_node: Node = item_nodes[idx]
		item_node.position = item_pos
		item_node.set_script(ITEM_SCRIPT)
		item_parent.add_child(item_node)
		used_item_names.append(item_node.name)
		GlobalState.add_item_node_to_map(item_node)

	if !no_randomize:
		used_item_names.shuffle()

	item_nodes.clear()

	if !no_randomize:
		NPC_TRANSFORMS.shuffle()

	# Spawn npc models at positions
	for p_count in range(npc_count):
		var new_npc: Node = NPC_MODEL.instantiate()
		var p_transform = NPC_TRANSFORMS[p_count]
		new_npc.position = p_transform.position
		new_npc.rotation = p_transform.rotation
		new_npc.set_script(NPC_SCRIPT)
		new_npc.wanted_item_str = used_item_names.pop_back()
		npc_parent.add_child(new_npc)
	
	GlobalState.level_manager = self
	GlobalState.set_total_npcs(npc_count) # menu -> level manager -> state

func extract_items(scene_packed):
	var result_item_nodes = []
	var scene: Node = scene_packed.instantiate()

	for item_node in scene.get_children():
		result_item_nodes.append(item_node.duplicate())

	scene.queue_free()
	return result_item_nodes
