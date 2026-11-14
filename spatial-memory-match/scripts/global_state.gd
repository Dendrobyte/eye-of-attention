extends Node

# List of item names we can grab from the scene or whatever
# NOTE: Could keep loaded on the level manager and just pull from there to re-instantiate?
# Will mimic the Escape Simulator inventory system, works for me. UI and all.
var inventory = []