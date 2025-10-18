extends Node3D

var original_material = null
var hover_material = null
var is_hovering = false

func _ready():
	# Store the original material and create hover material
	var mesh_instance = $MeshInstance3D
	original_material = mesh_instance.get_active_material(0)
	
	# If no material exists, create a default one
	if original_material == null:
		original_material = StandardMaterial3D.new()
		original_material.albedo_color = Color.WHITE
		mesh_instance.set_surface_override_material(0, original_material)
	
	# Create hover material
	hover_material = original_material.duplicate()
	hover_material.albedo_color = Color.YELLOW
	hover_material.emission = Color.YELLOW * 0.2  # Add slight glow

func on_hover_start():
	is_hovering = true
	var mesh_instance = $MeshInstance3D
	mesh_instance.set_surface_override_material(0, hover_material)

func on_hover_end():
	is_hovering = false
	var mesh_instance = $MeshInstance3D
	mesh_instance.set_surface_override_material(0, original_material)

func on_interact():
	# Don't interact if already in the middle of an interaction
	if is_hovering and original_material != null:
		# change color to green when activated (for 1 second)
		var mesh_instance = $MeshInstance3D
		var activated_material = original_material.duplicate()
		activated_material.albedo_color = Color.GREEN
		activated_material.emission = Color.GREEN * 0.3  # Add green glow
		mesh_instance.set_surface_override_material(0, activated_material)

		# Give a coin
		get_tree().root.get_node("Game").coins += 1

		await get_tree().create_timer(1.0).timeout
		# Return to hover state if still hovering, otherwise to original
		if is_hovering:
			mesh_instance.set_surface_override_material(0, hover_material)
		else:
			mesh_instance.set_surface_override_material(0, original_material)
