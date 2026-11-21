extends CharacterBody3D
class_name Character1P

@export var SPEED: float = 10.0
@export var JUMP_VELOCITY = 4.5
@export var MOUSE_SENSITIVITY: float = 0.0024
@export var RAY_LENGTH = 12

# If we're holding a picked up item, don't collide with it
var held_item: Node = null
# Maybe we keep it becuase items can be put down since inv size is limited?
var held_item_static_body: StaticBody3D = null # don't need this, don't need it in Teas either
var held_item_parent = null

var item_parent_node = null

var camera: Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera = $Camera
	GlobalState.character = self
	if GlobalState.START_POSITION != null:
		position = GlobalState.START_POSITION

	# We know I prefer references, but this is OK for now	
	held_item_parent = get_node("Camera/HeldItem")
	item_parent_node = get_tree().root.get_node("Main/LevelManager/ItemParent")

func _physics_process(delta: float) -> void:
	# this feels wrong, just to get around end game menu
	if !GlobalState.IS_GAME_RUNNING:
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * 4 * delta

	# TODO: Should have a boolean flag that flips in the input func
	var MULT = 1.0
	if Input.is_action_pressed("SPRINT"):
		MULT = 4.0
	
	if Input.is_action_pressed("JUMP"):
		velocity.y = 8

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
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: # && !is_looking:
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
	
	if event.is_action_pressed("SECONDARY"):
		if held_item != null:
			return_held_item()

	# DELETE ME
	# Key pressed for debugging, menu, etc.
	# Player always in scene so this is fine?
	if event.is_action_pressed("EXIT"):
		GlobalState.end_game() # debug change
		# get_tree().quit()

func check_raycast_collision(exceptions = []):
	var viewport_size = camera.get_viewport().get_visible_rect().size
	var center = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	var origin = camera.project_ray_origin(center)
	var end = origin + camera.project_ray_normal(center) * RAY_LENGTH
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
			print("Canonlyholdoneitematatime")
			return
		pick_up_item(result)
	if entity_node as NPCBehavior: # result is NPC's wanted item name (string)
		var wanted_item_name: String = result # just a rename
		if held_item == null:
			entity_node.display_want()
			# tween_camera_at_npc_item()
		elif wanted_item_name != "": # want fulfilled
			var satisfied = entity_node.maybe_satisfy(held_item.name)
			if satisfied: clear_held_item()
		# otherwise holding an item and npc is satisfied, so do nothing

func pick_up_item(item_node: ItemBehavior):
	held_item = item_node
	# sorta establishing a "pass around" instead of holding on to refs?
	# don't midn it, because parent eventually becomes game inventory?
	item_node.get_parent().remove_child(item_node)
	item_node.position = held_item_parent.position
	held_item_parent.add_child(item_node)

func clear_held_item():
	held_item = null
	held_item_parent.get_child(0).queue_free()

func return_held_item():
	held_item_parent.remove_child(held_item)
	item_parent_node.add_child(held_item)
	held_item.return_to_origin()
	held_item = null

# I don't love this but it's a learning endeavor
# TODO: Revisit this idea
# var is_looking = false
# func tween_camera_at_npc_item():
# 	var original_rotation = camera.rotation
# 	var looking_at_rotation = Vector3(camera.rotation.x + deg_to_rad(30), camera.rotation.y, camera.rotation.z)
# 	# var origin_fov = camera.fov
# 	# var target_fov = camera.fov - 30

# 	is_looking = true
# 	var tween = create_tween()
# 	tween.set_parallel(true)
# 	tween.tween_property(camera, "rotation", looking_at_rotation, 1.0)
# 	# tween.tween_property(camera, "fov", target_fov, 0.5)
# 	await tween.finished
# 	await get_tree().create_timer(0.5).timeout

# 	camera.rotation = original_rotation
# 	# camera.fov = origin_fov
# 	is_looking = false
