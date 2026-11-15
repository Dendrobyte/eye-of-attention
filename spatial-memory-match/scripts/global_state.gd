extends Node

# Contains references to the nodes from the name, to be temporarily duplicated for the npc want
var item_node_map = {} # { "name": node }

# This holds on to the item regardless of parent, used for NPC showing desire
func add_item_node_to_map(item_node):
	item_node_map[item_node.name] = item_node

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
