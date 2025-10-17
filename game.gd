extends Node3D


var coins: int = 10

var inventory_capacity: int = 8
var claw_grip_strength: float = 0.5
var claw_speed: float = 1.0
var value_multiplier: float = 1.0

var inventory: Array = []
var modifiers: Array = []

func pull() -> void:
	pass

func refill_machine() -> void:
	pass

func sell_item() -> void:
	pass
