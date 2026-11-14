extends CharacterBody3D


@export var SPEED: float = 10.0
@export var JUMP_VELOCITY = 4.5
@export var MOUSE_SENSITIVITY: float = 0.0024
@export var RAY_LENGTH = 5

# If we're holding a picked up item, don't collide with it
var held_item: Node = null
var held_item_static_body: StaticBody3D = null

var camera: Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera = $Camera

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle the movement input
	var input_dir := Input.get_vector("MOVE_LEFT", "MOVE_RIGHT", "MOVE_FORWARD", "MOVE_BACKWARD")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

# true is captured
var mouse_mode_flag = false
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
			var item_node = collided_obj.collider.get_parent()
			if is_interactable(item_node):
				var result = item_node.interact()
				if item_node as ItemBehavior:
					# TODO: show item in held hand or something
					print(result)

	# Key pressed for debugging, menu, etc.
	# Player always in scene so this is fine?
	if event.is_action_pressed("EXIT"):
		get_tree().quit()
	if event.is_action_pressed("ESCAPE"):
		if mouse_mode_flag:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_mode_flag = !mouse_mode_flag

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
