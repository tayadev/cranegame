extends Node3D

@export var possible_models: Array[Mesh] = []

@onready var material := preload("res://collectible_material.tres")

@export var spawn_count := 10
@export var spawn_delay := 0.5 # seconds between spawns
@export var offset_scale := 0.2
@export var size := 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_objects_over_time()

func spawn_objects_over_time() -> void:
	for i in range(spawn_count):
	
		# create new rigidbody from scratch
		var obj_instance = RigidBody3D.new()
		obj_instance.scale = Vector3.ONE * size
		obj_instance.add_to_group("collectibles")

		# add mesh instance
		var mesh_instance = MeshInstance3D.new()
		if possible_models.size() > 0:
			var random_model = possible_models[randi() % possible_models.size()]
			mesh_instance.mesh = random_model
			mesh_instance.scale = Vector3.ONE * size
			mesh_instance.material_override = material
		obj_instance.add_child(mesh_instance)

		# add a simple box collider sized to the mesh
		var collider = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		if mesh_instance.mesh:
			var aabb = mesh_instance.mesh.get_aabb()
			box_shape.size = aabb.size * size
		else:
			box_shape.size = Vector3.ONE * size
		collider.shape = box_shape
		obj_instance.add_child(collider)

		# Add the RigidBody3D to the scene
		add_child(obj_instance)

		# Wait before spawning the next one
		await get_tree().process_frame
		await get_tree().create_timer(spawn_delay).timeout
