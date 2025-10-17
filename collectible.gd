@tool
extends RigidBody3D

@export var size: float = 1.0:
	set(value):
		size = value
		_apply_size()

@export var model: Mesh = null

@onready var mesh: MeshInstance3D = $Mesh
@onready var collider: CollisionShape3D = $CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_apply_size()
	_apply_model()

func _apply_size():
	if mesh:
		mesh.transform = Transform3D.IDENTITY.scaled(Vector3.ONE * size)
	if collider:
		collider.shape = SphereShape3D.new()
		collider.shape.radius = size * 0.5

func _apply_model():
	if mesh and model:
		mesh.mesh = model