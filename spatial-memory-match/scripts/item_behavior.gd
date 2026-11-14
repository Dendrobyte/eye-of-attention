extends Node3D
class_name ItemBehavior

func pickup():
	print("Picked up ", name, "!")

func interact():
	pickup()
	return self
