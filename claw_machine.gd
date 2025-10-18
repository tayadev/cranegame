extends Node

@onready var claw_object: Area3D = $Claw
@onready var railx_object: Node3D = $RailX
@onready var railz_object: Node3D = $RailZ

var claw_rest_position: Vector3
var attached_object: Node3D = null
@export var claw_max_x: float = 5.0
@export var claw_max_z: float = 5.0
@export var claw_lowered_y: float = 0.0
@export var claw_speed: float = 1.0

enum GameStage {
	IDLE,
	SETX,
	SETZ,
	LOWERING,
	GRABBING,
	LIFTING,
	RETURNING,
	RELEASING,
}

var stage: GameStage = GameStage.IDLE

func _ready() -> void:
	claw_rest_position = claw_object.position
	claw_object.body_entered.connect(_on_claw_body_entered)

func _process(delta: float) -> void:
	match stage:
		GameStage.SETX:
			if claw_object.position.x < claw_max_x:
				var movement_claw = Vector3(claw_speed * delta, 0, 0)
				var movement_rail = Vector3(claw_speed * delta, 0, 0)
				claw_object.translate(movement_claw)
				railz_object.translate(movement_rail)
			else:
				stage = GameStage.SETZ
		GameStage.SETZ:
			if claw_object.position.z < claw_max_z:
				var movement_claw = Vector3(0, 0, claw_speed * delta)
				var movement_rail = Vector3(0, 0, claw_speed * delta)
				claw_object.translate(movement_claw)
				railx_object.translate(movement_rail)
			else:
				stage = GameStage.LOWERING
		GameStage.LOWERING:
			if claw_object.position.y > claw_lowered_y:
				claw_object.translate(Vector3(0, -claw_speed * delta, 0))
			else:
				stage = GameStage.GRABBING
		GameStage.GRABBING:
			# Simulate grabbing action
			stage = GameStage.LIFTING
		GameStage.LIFTING:
			if claw_object.position.y < claw_rest_position.y:
				claw_object.translate(Vector3(0, claw_speed * delta, 0))
			else:
				stage = GameStage.RETURNING
		GameStage.RETURNING:
			# go to release position
			if claw_object.position.x > claw_rest_position.x:
				var movement_claw = Vector3(-claw_speed * delta, 0, 0)
				var movement_rail = Vector3(-claw_speed * delta, 0, 0)
				claw_object.translate(movement_claw)
				railz_object.translate(movement_rail)
			elif claw_object.position.z > claw_rest_position.z:
				var movement_claw = Vector3(0, 0, -claw_speed * delta)
				var movement_rail = Vector3(0, 0, -claw_speed * delta)
				claw_object.translate(movement_claw)
				railx_object.translate(movement_rail)
			else:
				stage = GameStage.RELEASING
		GameStage.RELEASING:
			# Simulate releasing action
			if attached_object:
				attached_object.reparent(get_tree().current_scene)
				attached_object.freeze = false  # Resume physics simulation
				attached_object = null
			stage = GameStage.IDLE


func on_button_pressed():
	match stage:
		GameStage.IDLE:
			stage = GameStage.SETX
			print("Stage: SETX")
		GameStage.SETX:
			stage = GameStage.SETZ
			print("Stage: SETZ")
		GameStage.SETZ:
			stage = GameStage.LOWERING

func _on_claw_body_entered(body: Node3D) -> void:
	if stage == GameStage.LOWERING and attached_object == null:
		if body.is_in_group("collectibles"):
			attached_object = body
			body.reparent(claw_object)
			body.freeze = true  # Stop physics simulation
			print("Attached collectible: ", body.name)
			stage = GameStage.GRABBING


# item enters output area
func _on_area_3d_body_entered(body: Node3D) -> void:
	# delete item
	if body.is_in_group("collectibles"):
		body.queue_free()
		# give player a coin
		get_tree().root.get_node("Game").coins += 1
