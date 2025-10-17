extends Node3D

@export var CollectibleTemplate = preload("res://collectible.tscn")
@export var spawn_count := 10
@export var spawn_delay := 0.5 # seconds between spawns
@export var offset_scale := 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_objects_over_time()

func spawn_objects_over_time() -> void:
	for i in range(spawn_count):
		var obj_instance = CollectibleTemplate.instantiate()
		obj_instance.color = Color(randf(), randf(), randf())
		obj_instance.global_transform.origin = self.global_transform.origin + Vector3(randf() * offset_scale, 0, randf() * offset_scale)
		
		add_child(obj_instance)
		
		# Wait before spawning the next one
		await get_tree().process_frame
		await get_tree().create_timer(spawn_delay).timeout
