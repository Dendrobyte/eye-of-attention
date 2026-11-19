extends Node3D
class_name ItemBehavior

var original_position = null
var collider = null

func _ready():
	original_position = position
	collider = self.get_node("StaticBody3D/CollisionShape3D")

func interact():
	collider.disabled = true
	# Keeping inventory decoupled from here
	# GlobalState.add_item_to_inventory(self) # to be revisited
	# TODO: remove this when doing item refs to make sure it works right

	# self.hide() # or could set opacity down? happens when picked up
	return self

func return_to_origin():
	position = original_position
	collider.disabled = false
