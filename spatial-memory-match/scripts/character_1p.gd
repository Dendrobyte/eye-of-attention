extends CharacterBody3D
class_name Character1P


@export var SPEED: float = 10.0
@export var JUMP_VELOCITY = 4.5
@export var MOUSE_SENSITIVITY: float = 0.0024
@export var RAY_LENGTH = 5

# If we're holding a picked up item, don't collide with it
var held_item: Node = null
# Maybe we keep it becuase items can be put down since inv size is limited?
var held_item_static_body: StaticBody3D = null # don't need this, don't need it in Teas either

var camera: Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera = $Camera
	GlobalState.character = self
	if GlobalState.START_POSITION != null:
		position = GlobalState.START_POSITION

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# TODO: Should have a boolean flag that flips in the input func
	var MULT = 1.0
	if Input.is_action_pressed("SPRINT"):
		MULT = 4.0

	# Handle the movement input
	var input_dir := Input.get_vector("MOVE_LEFT", "MOVE_RIGHT", "MOVE_FORWARD", "MOVE_BACKWARD")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * MULT
		velocity.z = direction.z * SPEED * MULT
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * MULT)
		velocity.z = move_toward(velocity.z, 0, SPEED * MULT)

	move_and_slide()

var camera_pitch = 0.0
func _unhandled_input(event):
	# Camera movement
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera_pitch = clamp(
			camera_pitch - event.relative.y * MOUSE_SENSITIVITY,
			deg_to_rad(-78.0),
			deg_to_rad(78.0)
		)
		camera.rotation.x = camera_pitch

	# Interactions for raycasting
	if event.is_action_pressed("INTERACT"):
		# { "position": (-4.876412, 3.20117, 5.886989), "normal": (1.0, 0.0, 0.0), "face_index": -1, "collider_id": 30400316950, "collider": Pot:<StaticBody3D#30400316950>, "shape": 0, "rid": RID(631360192512) }
		var collided_obj = check_raycast_collision() if not held_item_static_body else check_raycast_collision([held_item_static_body])
		if !collided_obj.is_empty():
			var entity_node = collided_obj.collider.get_parent()
			if is_interactable(entity_node):
				# big if statement, though just two things right now
				handle_entity_interaction(entity_node)

	# Key pressed for debugging, menu, etc.
	# Player always in scene so this is fine?
	if event.is_action_pressed("EXIT"):
		get_tree().quit()

func check_raycast_collision(exceptions = []):
	var origin = camera.project_ray_origin($Control.cursor_pos)
	var end = origin + camera.project_ray_normal($Control.cursor_pos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = exceptions
	query.collide_with_areas = true

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)
	return result

func is_interactable(some_node: Node):
	return some_node.has_method("interact")

# Function to hold on to all of them for slimmer input function
func handle_entity_interaction(entity_node: Node):
	var result = entity_node.interact()
	if entity_node as ItemBehavior: # result is interacted item		# For now, we're only doing one item at a time
		# TODO: Check inventory size here, send a popup message explaining no pickup
		if held_item != null:
			print("Can only hold one item at a time")
			return
		pick_up_item(result)
	if entity_node as NPCBehavior: # result is NPC's wanted item name (string)
		var wanted_item_name: String = result # just a rename
		if held_item == null:
			entity_node.display_want()
		elif wanted_item_name != "": # want fulfilled
			var satisfied = entity_node.maybe_satisfy(held_item.name)
			if satisfied: clear_held_item()
		# otherwise holding an item and npc is satisfied, so do nothing

func pick_up_item(item_node: ItemBehavior):
	held_item = item_node
	# sorta establishing a "pass around" instead of holding on to refs?
	# don't midn it, because parent eventually becomes game inventory?
	item_node.get_parent().remove_child(item_node)
	var held_item_node = get_node("Camera/HeldItem")
	item_node.position = held_item_node.position
	held_item_node.add_child(item_node)

func clear_held_item():
	held_item = null
	var held_item_node = get_node("Camera/HeldItem")
	held_item_node.get_child(0).queue_free()
