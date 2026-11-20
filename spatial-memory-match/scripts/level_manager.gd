extends Node3D
class_name LevelManager

var ITEM_POSITIONS = [] # NOTE: i don't think we need dicts, just remove when unused
var NPC_TRANSFORMS = [] # { "position": ..., "rotation": ... }

var NPC_MODEL = preload("res://entity_scenes/char_base_scene.tscn")
var NPC_SCRIPT = preload("res://scripts/npc_behavior.gd")
var ITEM_SCENE = preload("res://assets/items.gltf")
var ITEM_SCRIPT = preload("res://scripts/item_behavior.gd")

# Debug Options
@export_enum("prototype_map", "tutorial", "first_floor") var level_scene_name: String
@export var no_randomize: bool = false

# These options mimic what can be configured in menu / game settings
@export var npc_count = 8 # todo: wire up to menu, like this for debug

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Override with debugs only if GlobalState has default values
	# When we play from the menu, total NPCs won't be -1
	# TODO: We can make a list of configurable fields and a map where the value is the empty val
	#		and do this more concisely
	if GlobalState.TOTAL_NPCS != -1:
		npc_count = GlobalState.TOTAL_NPCS
	if GlobalState.SELECTED_LEVEL != "":
		level_scene_name = GlobalState.SELECTED_LEVEL
	GlobalState.IS_GAME_RUNNING = true

	get_child(0).queue_free() # free the prototype map

	# Load the map from selected, must be present in `/assets/levels`
	var map_scene: PackedScene = load("res://assets/levels/" + level_scene_name + ".gltf")
	var map = map_scene.instantiate()
	map.name = "Level_" + level_scene_name
	add_child(map)
	var item_parent = $ItemParent
	var npc_parent = $NPCParent

	# Log all positions
	for child in map.get_children():
		var child_name = child.name
		# log positions and free those nodes
		if child_name.contains("PLAYER_POS"):
			# var num: int = child_name.trim_prefix("PLAYER_POS_").to_int() # prefer hard error here
			var y_offset = 0.02 # slight offset from Blender, beats snap-down
			var new_npc_position = snap_down_pos(child.position, y_offset)
			NPC_TRANSFORMS.append({"position": new_npc_position, "rotation": child.rotation})
			child.queue_free()
		if child_name.contains("ITEM_POS"):
			ITEM_POSITIONS.append(child.position)
			child.queue_free()
		if child_name == "PLAYER_START_POS":
			GlobalState.set_start_pos(child.position)
			child.queue_free()
		if child_name == "START":
			var new_area_3d: Area3D = Area3D.new()
			var area_collider = child.get_child(0).duplicate() # StaticBody3D -> CollisionShape3D
			new_area_3d.position = child.position
			new_area_3d.scale = child.scale
			new_area_3d.add_child(area_collider)
			new_area_3d.body_entered.connect(start_area_entered)
			add_child(new_area_3d)
			new_area_3d.name = "Start_Collider"
			child.queue_free()
		else: # for general environement, make sure we're using vertex colors "as albedo"
			enable_vertex_colors(child)


	print("Loaded item and NPC positions\nNPC Count: ", len(NPC_TRANSFORMS), "\nItem Count: ", len(ITEM_POSITIONS))

	# Get the items and then scatter them at those positions
	var used_item_names = []
	var item_nodes = extract_items(ITEM_SCENE)

	if !no_randomize:
		ITEM_POSITIONS.shuffle()

	# NOTE: Always assuming more items than positions
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
		new_npc.scale = new_npc.scale * 1.7
		new_npc.wanted_item_str = used_item_names.pop_back()
		npc_parent.add_child(new_npc)
	
	GlobalState.level_manager = self
	GlobalState.set_total_npcs(npc_count) # menu -> level manager -> state


# Keeping it here feels fine... but for now
func _process(delta: float):
	if GlobalState.STOPWATCH_STARTED && GlobalState.STOPWATCH_RUNNING:
		GlobalState.TIME_ELAPSED += delta

func extract_items(scene_packed):
	var result_item_nodes = []
	var scene: Node = scene_packed.instantiate()

	for item_node in scene.get_children():
		result_item_nodes.append(item_node.duplicate())

	scene.queue_free()
	return result_item_nodes

var ray_offset = {
	x = 0,
	y = 0,
	z = 0,
}
func snap_down_pos(node_position, y_offset):
	var space_state = get_world_3d().direct_space_state
	var ray_start = Vector3(node_position.x + ray_offset.x, node_position.y + 5, node_position.z + ray_offset.z) # Start above the player?
	var ray_end = Vector3(node_position.x + ray_offset.x, node_position.y - 10, node_position.z + ray_offset.z) # I don't think we need to go too far down?
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if result:
		node_position.y = result.position.y + y_offset
	return node_position

func start_area_entered(_body):
	if !GlobalState.STOPWATCH_STARTED:
		GlobalState.start_game_stopwatch()

func enable_vertex_colors(env_item_node):
	if env_item_node is MeshInstance3D:
		var material = env_item_node.get_active_material(0)
		if material is BaseMaterial3D:
			material.vertex_color_use_as_albedo = true
