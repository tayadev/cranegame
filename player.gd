extends CharacterBody3D

# Player movement settings
@export var speed: float = 5.0
@export var mouse_sensitivity: float = 0.002
@export var gravity: float = 9.8
@export var interaction_range: float = 3.0

# Camera node reference
@onready var camera_3d: Camera3D = $Camera3D

# UI references
@onready var interaction_hint: Label = get_node("../HUD/InteractionHint")

# Interaction system variables
var currently_hovering: Node3D = null
var world_space: PhysicsDirectSpaceState3D

func _ready() -> void:
	# Capture the mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Get the physics world
	world_space = get_world_3d().direct_space_state
	# Initialize UI
	interaction_hint.visible = false

func _input(event: InputEvent) -> void:
	# Handle mouse movement for looking around
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Rotate the player body horizontally
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Rotate the camera vertically (with clamping to prevent over-rotation)
		camera_3d.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_3d.rotation.x = clampf(camera_3d.rotation.x, -PI/2, PI/2)
	
	# Toggle mouse capture with Escape key
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Handle interaction
	if event.is_action_pressed("interact") and currently_hovering != null:
		if currently_hovering.has_method("on_interact"):
			currently_hovering.on_interact()

func _physics_process(delta: float) -> void:
	# Handle gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var input_dir := Vector2.ZERO
	if Input.is_action_pressed("right"):
		input_dir.x += 1
	if Input.is_action_pressed("left"):
		input_dir.x -= 1
	if Input.is_action_pressed("backward"):
		input_dir.y += 1
	if Input.is_action_pressed("forward"):
		input_dir.y -= 1
	
	# Calculate movement direction relative to where the player is facing
	var direction := Vector3.ZERO
	if input_dir != Vector2.ZERO:
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Apply movement
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta * 10)
		velocity.z = move_toward(velocity.z, 0, speed * delta * 10)
	
	# Move the character
	move_and_slide()
	
	# Handle interaction raycast
	_handle_interaction_raycast()

func _handle_interaction_raycast() -> void:
	# Cast a ray from the camera forward
	var camera_transform = camera_3d.global_transform
	var ray_origin = camera_transform.origin
	var ray_direction = -camera_transform.basis.z  # Camera's forward direction
	var ray_end = ray_origin + ray_direction * interaction_range
	
	# Create the raycast query
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = world_space.intersect_ray(query)
	
	var hit_object: Node3D = null
	
	# Check if we hit something
	if result:
		var collider = result.collider
		if collider:
			# Check if the collider itself has the group
			if collider.is_in_group("interactible"):
				hit_object = collider
			# Check if the collider's parent has the group
			elif collider.get_parent() and collider.get_parent().is_in_group("interactible"):
				hit_object = collider.get_parent()
	
	# Handle hover state changes
	if hit_object != currently_hovering:
		# End hover on previous object
		if currently_hovering != null and currently_hovering.has_method("on_hover_end"):
			currently_hovering.on_hover_end()
		
		# Update UI hint visibility
		if hit_object != null:
			# Show interaction hint when hovering over an interactible
			interaction_hint.visible = true
		else:
			# Hide interaction hint when not hovering over anything
			interaction_hint.visible = false
		
		# Start hover on new object
		currently_hovering = hit_object
		if currently_hovering != null and currently_hovering.has_method("on_hover_start"):
			currently_hovering.on_hover_start()
