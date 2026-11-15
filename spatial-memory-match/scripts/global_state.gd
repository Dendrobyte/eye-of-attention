extends Node

# Contains references to the nodes from the name, to be temporarily duplicated for the npc want
var item_node_map = {} # { "name": node }

# NOTE: does this maintain a hidden property? So showing want would be hidden?
# So copy may just generally be better
func add_item_node_to_map(item_node):
	item_node_map[item_node.name] = item_node

# List of item names we can grab from the scene or whatever
# NOTE: Could keep loaded on the level manager and just pull from there to re-instantiate?
# Will mimic the Escape Simulator inventory system, works for me. UI and all.
var inventory = [] # all strings right now

# Only need string for now, will show similar to want later
# refactor into a held item, but keep this for the hard mode stretch goal
# where you need to ask everyone, then you pick up everything, then you go back
func add_item_to_inventory(item_node):
	inventory.append(item_node.name)
	print("Full inventory: ", inventory)

func has_item(item_name):
	return item_name in inventory
