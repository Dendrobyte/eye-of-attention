extends Node3D
class_name ItemBehavior

var original_position = null
var original_scale = null
var original_rotation = null
var collider = null

func _ready():
	# TODO: Just do original transform...
	original_position = position
	original_scale = scale
	rotation.y = rotation.z + PI / 2
	original_rotation = rotation
	collider = self.get_node("StaticBody3D/CollisionShape3D")

func interact():
	collider.disabled = true
	scale = scale * 0.5
	rotation.y -= PI / 2
	# Keeping inventory decoupled from here
	# GlobalState.add_item_to_inventory(self) # to be revisited
	# TODO: remove this when doing item refs to make sure it works right

	# self.hide() # or could set opacity down? happens when picked up
	return self

func return_to_origin():
	position = original_position
	scale = original_scale
	rotation = original_rotation
	collider.disabled = false
