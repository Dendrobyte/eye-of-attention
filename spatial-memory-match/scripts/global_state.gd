extends Node

## Self Assigned References ##
var level_manager: LevelManager = null
var character: Character1P = null

var no_randomize = false

var LEVEL_LIST = [] # dynamically loaded in enter tree
# TODO: Load settings in the level, e.g. early traversal to get player position count, etc.
# Things like this could be in a SettingsState too, and cleared when game starts

var end_game_menu: PackedScene = preload("res://menus/end_game_menu.tscn")

func _enter_tree() -> void:
	# Load levels. Hard error ok
	var level_maps_dir = ResourceLoader.list_directory("res://assets/levels")
	# level_maps_dir.list_dir_begin() # get_next() will close when it hits the end

	# var file_name = level_maps_dir.get_next()
	# while file_name != "":
	for file_name in level_maps_dir:
		print(file_name)
		if file_name.ends_with(".gltf"):
			var level_name = file_name.trim_suffix(".gltf")
			print("loaded ", level_name)
			LEVEL_LIST.append(level_name)
		# file_name = level_maps_dir.get_next()

var SELECTED_LEVEL = ""

var SHIRT_COLORS = [
	Color.ALICE_BLUE, Color.AQUA, Color.AQUAMARINE, Color.AZURE, Color.BEIGE, Color.BISQUE, Color.BLACK, Color.BLANCHED_ALMOND, Color.BLUE, Color.BLUE_VIOLET, Color.BROWN, Color.BURLYWOOD, Color.CADET_BLUE, Color.CHARTREUSE, Color.CHOCOLATE, Color.CORAL, Color.CORNFLOWER_BLUE, Color.CORNSILK, Color.CRIMSON, Color.CYAN, Color.DARK_BLUE, Color.DARK_CYAN, Color.DARK_GOLDENROD, Color.DARK_GRAY, Color.DARK_GREEN, Color.DARK_KHAKI, Color.DARK_MAGENTA, Color.DARK_OLIVE_GREEN, Color.DARK_ORANGE, Color.DARK_ORCHID, Color.DARK_RED, Color.DARK_SALMON, Color.DARK_SEA_GREEN, Color.DARK_SLATE_BLUE, Color.DARK_SLATE_GRAY, Color.DARK_TURQUOISE, Color.DARK_VIOLET, Color.DEEP_PINK, Color.DEEP_SKY_BLUE, Color.DIM_GRAY, Color.DODGER_BLUE, Color.FIREBRICK, Color.FOREST_GREEN, Color.FUCHSIA, Color.GAINSBORO, Color.GOLD, Color.GOLDENROD, Color.GRAY, Color.GREEN, Color.GREEN_YELLOW, Color.HONEYDEW, Color.HOT_PINK, Color.INDIAN_RED, Color.INDIGO, Color.IVORY, Color.KHAKI, Color.LAVENDER, Color.LAVENDER_BLUSH, Color.LAWN_GREEN, Color.LEMON_CHIFFON, Color.LIGHT_BLUE, Color.LIGHT_CORAL, Color.LIGHT_CYAN, Color.LIGHT_GOLDENROD, Color.LIGHT_GRAY, Color.LIGHT_GREEN, Color.LIGHT_PINK, Color.LIGHT_SALMON, Color.LIGHT_SEA_GREEN, Color.LIGHT_SKY_BLUE, Color.LIGHT_SLATE_GRAY, Color.LIGHT_STEEL_BLUE, Color.LIGHT_YELLOW, Color.LIME, Color.LIME_GREEN, Color.LINEN, Color.MAGENTA, Color.MAROON, Color.MEDIUM_AQUAMARINE, Color.MEDIUM_BLUE, Color.MEDIUM_ORCHID, Color.MEDIUM_PURPLE, Color.MEDIUM_SEA_GREEN, Color.MEDIUM_SLATE_BLUE, Color.MEDIUM_SPRING_GREEN, Color.MEDIUM_TURQUOISE, Color.MEDIUM_VIOLET_RED, Color.MIDNIGHT_BLUE, Color.MINT_CREAM, Color.MISTY_ROSE, Color.MOCCASIN, Color.NAVY_BLUE, Color.OLD_LACE, Color.OLIVE, Color.OLIVE_DRAB, Color.ORANGE, Color.ORANGE_RED, Color.ORCHID, Color.PALE_GOLDENROD, Color.PALE_GREEN, Color.PALE_TURQUOISE, Color.PALE_VIOLET_RED, Color.PAPAYA_WHIP, Color.PEACH_PUFF, Color.PERU, Color.PINK, Color.PLUM, Color.POWDER_BLUE, Color.PURPLE, Color.REBECCA_PURPLE, Color.RED, Color.ROSY_BROWN, Color.ROYAL_BLUE, Color.SADDLE_BROWN, Color.SALMON, Color.SANDY_BROWN, Color.SEA_GREEN, Color.SEASHELL, Color.SIENNA, Color.SILVER, Color.SKY_BLUE, Color.SLATE_BLUE, Color.SLATE_GRAY, Color.SNOW, Color.SPRING_GREEN, Color.STEEL_BLUE, Color.TAN, Color.TEAL, Color.THISTLE, Color.TOMATO, Color.TRANSPARENT, Color.TURQUOISE, Color.VIOLET, Color.WEB_GRAY, Color.WEB_GREEN, Color.WEB_MAROON, Color.WEB_PURPLE, Color.WHEAT, Color.YELLOW, Color.YELLOW_GREEN
]

# Contains references to the nodes from the name, to be temporarily duplicated for the npc want
var item_node_map = {} # { "name": node }

# This holds on to the item regardless of parent, used for NPC showing desire
func add_item_node_to_map(item_node):
	item_node_map[item_node.name] = item_node

var START_POSITION: Vector3

func set_start_pos(pos):
	START_POSITION = pos

var TOTAL_NPCS = -1 # -1 to represent default/error state, set when in menu
var SATISFIED_NPCS = 0
var ERROR_WRONG_ITEM = 0
# TODO: make a more complex enum if need-be
var IS_GAME_RUNNING = false # set to true in level manager

func set_total_npcs(new_total_npcs):
	TOTAL_NPCS = new_total_npcs

# This could be a signal emitted by each NPC and an NPC controller handles it
# Feels like it's a better system, since expanded upon means more state modifying, but this works for this scope
func incr_satisfy_npc():
	SATISFIED_NPCS += 1
	if SATISFIED_NPCS == TOTAL_NPCS:
		end_game()

# Can follow this pattern for empty handed reviews
func incr_error_wrong_item():
	ERROR_WRONG_ITEM += 1

# Game points, timer, etc.
# These could be handled in LevelManager, which is acting as LevelState (aka whole game lol)
var STOPWATCH_STARTED = false
var STOPWATCH_RUNNING = false
var TIME_ELAPSED = 0.0

func start_game_stopwatch():
	STOPWATCH_STARTED = true
	STOPWATCH_RUNNING = true
	GlobalState.TIME_ELAPSED = 0.0
	print("stopwatch started")

# They won't be able to walk back through a level, so not bothering with the area that triggers start
func end_game_stopwatch():
	STOPWATCH_STARTED = false
	STOPWATCH_RUNNING = false
	print("stopwatch stopped")

func pause_game_stopwatch():
	STOPWATCH_RUNNING = false # maybe not? depends on if it feels like pausing helps

func resume_game_stopwatch():
	if STOPWATCH_STARTED:
		STOPWATCH_RUNNING = true

func show_time_elapsed():
	var seconds_and_ms = str(TIME_ELAPSED).pad_decimals(2).replace(".", ":").split(":")
	var seconds = int(seconds_and_ms[0])
	var ms = int(seconds_and_ms[1])
	var minutes = seconds / 60
	var remaining_seconds = seconds % 60
	if ms <= 9:
		ms = "0" + str(ms) # lol
	var seconds_str = str(remaining_seconds) + "s" + str(ms) + "ms"
	if minutes > 0:
		return str(minutes) + "m" + seconds_str
	else:
		return seconds_str

var STARS = 3 # i think a 5 star system would be better, post-jam TODO
func calc_final_stars():
	# Remove one per condition, versus set concretely
	if ERROR_WRONG_ITEM > 1:
		STARS -= 1
	# 2 stars for 1 / 2 is weird but whatever
	if TOTAL_NPCS > 2 && ERROR_WRONG_ITEM > int(TOTAL_NPCS * 0.25):
		STARS -= 1
	if TOTAL_NPCS > 4 && ERROR_WRONG_ITEM > int(TOTAL_NPCS * 0.25):
		STARS -= 1

func end_game():
	end_game_stopwatch()
	calc_final_stars()
	IS_GAME_RUNNING = false
	var end_game_menu_scene = end_game_menu.instantiate()
	get_tree().root.add_child(end_game_menu_scene)
	print("All NPCs satisfied! Game complete!")

# Will mimic the Escape Simulator inventory system, works for me. UI and all.
# Think of global state as having an InventoryManager.
# No need to make a new node like ToTK's 4 controllers, just try it out.
var held_item: ItemBehavior = null
var inventory = [] # all strings right now
var inventory_size = -1 # -1 for error checking, initialize for npc num later
var inventory_active_idx = 0 # as this changes, held item appearance changes

# TODO: inventory stuff
func add_item_to_inventory(item_node):
	inventory.append(item_node.name)

func has_item(item_name):
	return item_name in inventory
