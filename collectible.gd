@tool
extends RigidBody3D

@export var color: Color = Color.RED:
	set(value):
		color = value
		_apply_color()  # Update in editor immediately when color changes

@onready var mesh: MeshInstance3D = $MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_apply_color()

func _apply_color():
	if not mesh:
		return
	var base_mat := mesh.get_active_material(0)
	if base_mat == null:
		return

	# Duplicate the material so each instance has its own color
	var mat := base_mat.duplicate()
	if mat is StandardMaterial3D:
		mat.albedo_color = color
		mesh.set_surface_override_material(0, mat)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
