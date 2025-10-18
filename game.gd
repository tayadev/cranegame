extends Node3D

enum Stat {
	GRIP_STRENGTH,
	CLAW_SPEED,
	INVENTORY_CAPACITY,
	VALUE_MULTIPLIER,
}

enum ModifierType {
	ADDITIVE,
	MULTIPLICATIVE,
}

var coins: int = 10:
	set(value):
		coins = max(value, 0)
		$HUD/CoinLabel.text = "Coins: %d" % coins

var base_stats := {
	Stat.GRIP_STRENGTH: 1.0,
	Stat.CLAW_SPEED: 1.0,
	Stat.INVENTORY_CAPACITY: 8,
	Stat.VALUE_MULTIPLIER: 1.0,
}

var duck_red := Item.new("duck", 5, 1, 0.2, "res://models/duck_red.glb")

var items: Array[Item] = [
	duck_red
]

var itemsets := {
	"duck": {"multiplier": 1.0},
}

var inventory: Array = []

var modifiers: Array = [
	{"stat": Stat.GRIP_STRENGTH, "type": ModifierType.MULTIPLICATIVE, "value": 1.2},
]

func get_stat(stat: Stat) -> float:
	var total: float = base_stats[stat]
		
	for modifier in modifiers:
		if modifier.stat == stat:
			if modifier.type == ModifierType.ADDITIVE:
				total += modifier.value
			elif modifier.type == ModifierType.MULTIPLICATIVE:
				total *= modifier.value

	return total

func select_items() -> Array:
	# Placeholder for item selection logic
	var list: Array = []
	for i in range(50):
		list.append(duck_red)
	return list

func pull() -> Array[Item]:
	return $ClawMachine.pull()

func refill_machine() -> void:
	$ClawMachine.refill(select_items())

func sell_item() -> void:
	pass
