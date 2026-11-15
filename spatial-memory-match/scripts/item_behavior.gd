extends Node3D
class_name ItemBehavior

func interact():
	print("Picked up ", name, "!")

	self.get_node("StaticBody3D").queue_free() # maybe not, if putting items down

	# Keeping inventory decoupled from here
	# GlobalState.add_item_to_inventory(self) # to be revisited
	# TODO: remove this when doing item refs to make sure it works right

	# self.hide() # or could set opacity down? happens when picked up
	return self
