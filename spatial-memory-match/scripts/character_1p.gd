extends CharacterBody3D


@export var SPEED: float = 10.0
@export var JUMP_VELOCITY = 4.5
@export var MOUSE_SENSITIVITY = 0.0024

var camera: Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera = get_child(0)

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
