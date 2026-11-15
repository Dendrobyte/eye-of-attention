extends Node3D
class_name ItemBehavior

func pickup():
	print("Picked up ", name, "!")
	GlobalState.add_item_to_inventory(self)
	self.get_node("StaticBody3D").queue_free()
	self.hide() # or could set opacity down? etc.

func interact():
	pickup()
	return self
