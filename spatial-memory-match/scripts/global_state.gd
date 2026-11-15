extends Node

# Contains references to the nodes from the name, to be temporarily duplicated for the npc want
var item_node_map = {} # { "name": node }

func add_item_node_to_map(item_node):
    item_node_map[item_node.name] = item_node

# List of item names we can grab from the scene or whatever
# NOTE: Could keep loaded on the level manager and just pull from there to re-instantiate?
# Will mimic the Escape Simulator inventory system, works for me. UI and all.
var inventory = []