extends Node

## Self Assigned References ##
var level_manager: LevelManager = null
var character: Character1P = null

# Contains references to the nodes from the name, to be temporarily duplicated for the npc want
var item_node_map = {} # { "name": node }

# This holds on to the item regardless of parent, used for NPC showing desire
func add_item_node_to_map(item_node):
	item_node_map[item_node.name] = item_node

var START_POSITION: Vector3

func set_start_pos(pos):
	START_POSITION = pos

var TOTAL_NPCS = -1 # -1 to represent default/error state
var SATISFIED_NPCS = 0

func set_total_npcs(new_total_npcs):
	TOTAL_NPCS = new_total_npcs

# This could be a signal emitted by each NPC and an NPC controller handles it
# Feels like it's a better system, since expanded upon means more state modifying, but this works for this scope
func incr_satisfy_npc():
	SATISFIED_NPCS += 1
	if SATISFIED_NPCS == TOTAL_NPCS:
		end_game()

func end_game():
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
